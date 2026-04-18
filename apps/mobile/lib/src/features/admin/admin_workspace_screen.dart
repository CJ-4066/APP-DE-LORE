import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_models.dart';

class AdminWorkspaceScreen extends StatelessWidget {
  const AdminWorkspaceScreen({
    super.key,
    required this.data,
    required this.onRefresh,
    required this.onOpenShop,
    required this.onOpenCourses,
    required this.onOpenBookings,
    required this.onOpenProfile,
    required this.onUpdateOrderStatus,
  });

  final AppBootstrap data;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenShop;
  final VoidCallback onOpenCourses;
  final VoidCallback onOpenBookings;
  final VoidCallback onOpenProfile;
  final Future<ShopOrder> Function({
    required String orderId,
    required String status,
  }) onUpdateOrderStatus;

  @override
  Widget build(BuildContext context) {
    final userName = _displayUserName(data.user);
    final recentOrders = data.shop.orders.take(4).toList(growable: false);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _AdminHero(
              userName: userName,
              summary: data.admin,
              orderCount: data.shop.orders.length,
              specialistAccess: data.user.accountType == 'specialist',
            ),
            const SizedBox(height: 18),
            _AdminMetricGrid(
              cards: [
                _AdminMetricCardData(
                  label: 'Usuarios',
                  value: '${data.admin.activeUsers}',
                  icon: Icons.people_alt_outlined,
                  color: AppPalette.midnight,
                ),
                _AdminMetricCardData(
                  label: 'Premium',
                  value: '${data.admin.premiumSubscribers}',
                  icon: Icons.workspace_premium_outlined,
                  color: AppPalette.flameGold,
                ),
                _AdminMetricCardData(
                  label: 'Órdenes',
                  value: '${data.shop.orders.length}',
                  icon: Icons.receipt_long_rounded,
                  color: AppPalette.indigo,
                ),
                _AdminMetricCardData(
                  label: 'Reservas',
                  value: '${data.admin.monthlyBookings}',
                  icon: Icons.calendar_month_outlined,
                  color: AppPalette.royalViolet,
                ),
                _AdminMetricCardData(
                  label: 'Especialistas',
                  value: '${data.admin.activeSpecialists}',
                  icon: Icons.auto_awesome_outlined,
                  color: AppPalette.orchid,
                ),
                _AdminMetricCardData(
                  label: 'Incidencias',
                  value: '${data.admin.openIncidents}',
                  icon: Icons.warning_amber_rounded,
                  color: AppPalette.berry,
                ),
              ],
            ),
            const SizedBox(height: 22),
            const _AdminSectionTitle(
              title: 'Mandos rápidos',
              subtitle:
                  'Accesos directos al estado global de la operación, sin mezclar la vista madre con la vista especialista.',
            ),
            const SizedBox(height: 12),
            _AdminQuickActions(
              onOpenShop: onOpenShop,
              onOpenCourses: onOpenCourses,
              onOpenBookings: onOpenBookings,
              onOpenProfile: onOpenProfile,
            ),
            const SizedBox(height: 22),
            _AdminSectionTitle(
              title: 'Órdenes globales',
              subtitle: recentOrders.isEmpty
                  ? 'Todavía no hay órdenes sincronizadas en la API.'
                  : 'Vista madre de las últimas órdenes con cambio rápido de estado.',
            ),
            const SizedBox(height: 12),
            if (recentOrders.isEmpty)
              const _AdminEmptyState(
                title: 'Sin órdenes recientes',
                subtitle:
                    'Cuando entren compras desde especialistas o clientes, aparecerán aquí.',
              )
            else
              ...recentOrders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AdminOrderCard(
                    order: order,
                    onUpdateOrderStatus: onUpdateOrderStatus,
                  ),
                ),
              ),
            const SizedBox(height: 22),
            const _AdminSectionTitle(
              title: 'Radar de especialistas',
              subtitle:
                  'Lectura rápida de quién sostiene la operación visible en esta sesión.',
            ),
            const SizedBox(height: 12),
            ...data.specialists.take(4).map(
              (specialist) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SpecialistPulseCard(
                  specialist: specialist,
                  serviceCount: data.services
                      .where((service) => service.specialistIds.contains(specialist.id))
                      .length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminHero extends StatelessWidget {
  const _AdminHero({
    required this.userName,
    required this.summary,
    required this.orderCount,
    required this.specialistAccess,
  });

  final String userName;
  final AdminSummary summary;
  final int orderCount;
  final bool specialistAccess;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPalette.midnight,
            AppPalette.indigo,
            AppPalette.orchid,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppPalette.indigo.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Usuario madre',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Panel central de $userName',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            specialistAccess
                ? 'Aquí ves la operación completa de la app y además conservas tus herramientas de especialista.'
                : 'Aquí ves la operación completa de la app sin mezclarla con el trabajo operativo de un especialista.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroPill(
                label: '${summary.monthlyBookings} reservas este mes',
              ),
              _HeroPill(
                label: '$orderCount órdenes visibles',
              ),
              _HeroPill(
                label: '${summary.activeSpecialists} especialistas activos',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _AdminMetricCardData {
  const _AdminMetricCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _AdminMetricGrid extends StatelessWidget {
  const _AdminMetricGrid({required this.cards});

  final List<_AdminMetricCardData> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map(
                (card) => SizedBox(
                  width: tileWidth,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppPalette.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: card.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(card.icon, color: card.color),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          card.value,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppPalette.midnight,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card.label,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppPalette.mutedLavender,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _AdminQuickActions extends StatelessWidget {
  const _AdminQuickActions({
    required this.onOpenShop,
    required this.onOpenCourses,
    required this.onOpenBookings,
    required this.onOpenProfile,
  });

  final VoidCallback onOpenShop;
  final VoidCallback onOpenCourses;
  final VoidCallback onOpenBookings;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _QuickActionCard(
          title: 'Shop global',
          subtitle: 'Catálogo y órdenes por tienda',
          icon: Icons.shopping_bag_outlined,
          color: AppPalette.indigo,
          onTap: onOpenShop,
        ),
        _QuickActionCard(
          title: 'Biblioteca',
          subtitle: 'Cursos y piezas formativas',
          icon: Icons.auto_stories_outlined,
          color: AppPalette.orchid,
          onTap: onOpenCourses,
        ),
        _QuickActionCard(
          title: 'Agenda',
          subtitle: 'Reserva, seguimiento y estado',
          icon: Icons.calendar_month_outlined,
          color: AppPalette.royalViolet,
          onTap: onOpenBookings,
        ),
        _QuickActionCard(
          title: 'Perfil',
          subtitle: 'Cuenta, idioma e insignias',
          icon: Icons.person_outline,
          color: AppPalette.flameGold,
          onTap: onOpenProfile,
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: color.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPalette.mutedLavender,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminSectionTitle extends StatelessWidget {
  const _AdminSectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppPalette.mutedLavender,
                height: 1.4,
              ),
        ),
      ],
    );
  }
}

class _AdminOrderCard extends StatefulWidget {
  const _AdminOrderCard({
    required this.order,
    required this.onUpdateOrderStatus,
  });

  final ShopOrder order;
  final Future<ShopOrder> Function({
    required String orderId,
    required String status,
  }) onUpdateOrderStatus;

  @override
  State<_AdminOrderCard> createState() => _AdminOrderCardState();
}

class _AdminOrderCardState extends State<_AdminOrderCard> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final status = _shopOrderStatus(widget.order.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.shopping_bag_outlined, color: status.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.order.orderCode,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.order.storeName} · ${formatMoney(widget.order.total)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPalette.indigo,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.order.itemCount} artículos · ${formatSchedule(widget.order.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPalette.mutedLavender,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: _isUpdating ? null : _updateStatus,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'pending', child: Text('Pendiente')),
              PopupMenuItem(value: 'confirmed', child: Text('Confirmada')),
              PopupMenuItem(value: 'preparing', child: Text('Preparando')),
              PopupMenuItem(value: 'shipped', child: Text('Enviada')),
            ],
            child: _isUpdating
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: status.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: status.color,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String status) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final updated = await widget.onUpdateOrderStatus(
        orderId: widget.order.id,
        status: status,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${updated.orderCode} actualizado a ${_shopOrderStatus(updated.status).label}.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }
}

class _SpecialistPulseCard extends StatelessWidget {
  const _SpecialistPulseCard({
    required this.specialist,
    required this.serviceCount,
  });

  final Specialist specialist;
  final int serviceCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppPalette.softLilac,
            child: Text(
              specialist.name.isEmpty ? '?' : specialist.name.substring(0, 1),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppPalette.midnight,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  specialist.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${specialist.headline} · $serviceCount servicios',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPalette.mutedLavender,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppPalette.softLilac,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              specialist.nextAvailableAt.isEmpty
                  ? 'Disponibilidad por revisar'
                  : specialist.nextAvailableAt,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppPalette.indigo,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminEmptyState extends StatelessWidget {
  const _AdminEmptyState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPalette.mutedLavender,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _ShopOrderStatusCopy {
  const _ShopOrderStatusCopy({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;
}

_ShopOrderStatusCopy _shopOrderStatus(String status) {
  switch (status) {
    case 'confirmed':
      return const _ShopOrderStatusCopy(
        label: 'Confirmada',
        color: AppPalette.success,
      );
    case 'preparing':
      return const _ShopOrderStatusCopy(
        label: 'Preparando',
        color: AppPalette.flameGold,
      );
    case 'shipped':
      return const _ShopOrderStatusCopy(
        label: 'Enviada',
        color: AppPalette.indigo,
      );
    default:
      return const _ShopOrderStatusCopy(
        label: 'Pendiente',
        color: AppPalette.berry,
      );
  }
}

String _displayUserName(UserProfile user) {
  final fullName = '${user.firstName} ${user.lastName}'.trim();
  if (fullName.isNotEmpty) {
    return fullName;
  }
  if (user.nickname.trim().isNotEmpty) {
    return user.nickname.trim();
  }
  return 'Lo Renaciente';
}
