import 'package:flutter/material.dart';

import '../../core/i18n/app_i18n.dart';
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
    final l10n = context.l10n;
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
                  label: l10n.ts('Usuarios'),
                  value: '${data.admin.activeUsers}',
                  icon: Icons.people_alt_outlined,
                  color: AppPalette.midnight,
                ),
                _AdminMetricCardData(
                  label: l10n.ts('Premium'),
                  value: '${data.admin.premiumSubscribers}',
                  icon: Icons.workspace_premium_outlined,
                  color: AppPalette.flameGold,
                ),
                _AdminMetricCardData(
                  label: l10n.ts('Órdenes'),
                  value: '${data.shop.orders.length}',
                  icon: Icons.receipt_long_rounded,
                  color: AppPalette.indigo,
                ),
                _AdminMetricCardData(
                  label: l10n.ts('Reservas'),
                  value: '${data.admin.monthlyBookings}',
                  icon: Icons.calendar_month_outlined,
                  color: AppPalette.royalViolet,
                ),
                _AdminMetricCardData(
                  label: l10n.ts('Especialistas'),
                  value: '${data.admin.activeSpecialists}',
                  icon: Icons.auto_awesome_outlined,
                  color: AppPalette.orchid,
                ),
                _AdminMetricCardData(
                  label: l10n.ts('Incidencias'),
                  value: '${data.admin.openIncidents}',
                  icon: Icons.warning_amber_rounded,
                  color: AppPalette.berry,
                ),
              ],
            ),
            const SizedBox(height: 22),
            _AdminSectionTitle(
              title: l10n.ts('Mandos rápidos'),
              subtitle: l10n.ts(
                'Accesos directos al estado global de la operación, sin mezclar la vista madre con la vista especialista.',
              ),
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
              title: l10n.ts('Órdenes globales'),
              subtitle: recentOrders.isEmpty
                  ? l10n.ts('Todavía no hay órdenes sincronizadas en la API.')
                  : l10n.ts(
                      'Vista madre de las últimas órdenes con cambio rápido de estado.',
                    ),
            ),
            const SizedBox(height: 12),
            if (recentOrders.isEmpty)
              _AdminEmptyState(
                title: l10n.ts('Sin órdenes recientes'),
                subtitle: l10n.ts(
                  'Cuando entren compras desde especialistas o clientes, aparecerán aquí.',
                ),
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
            _AdminSectionTitle(
              title: l10n.ts('Radar de especialistas'),
              subtitle: l10n.ts(
                'Lectura rápida de quién sostiene la operación visible en esta sesión.',
              ),
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
    final l10n = context.l10n;
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
            child: Text(
              l10n.ts('Usuario madre'),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.ts('Panel central de {name}', {'name': userName}),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            specialistAccess
                ? l10n.ts(
                    'Aquí ves la operación completa de la app y además conservas tus herramientas de especialista.',
                  )
                : l10n.ts(
                    'Aquí ves la operación completa de la app sin mezclarla con el trabajo operativo de un especialista.',
                  ),
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
                label: l10n.ts(
                  '{count} reservas este mes',
                  {'count': '${summary.monthlyBookings}'},
                ),
              ),
              _HeroPill(
                label: l10n.ts(
                  '{count} órdenes visibles',
                  {'count': '$orderCount'},
                ),
              ),
              _HeroPill(
                label: l10n.ts(
                  '{count} especialistas activos',
                  {'count': '${summary.activeSpecialists}'},
                ),
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
    final l10n = context.l10n;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _QuickActionCard(
          title: l10n.ts('Shop global'),
          subtitle: l10n.ts('Catálogo y órdenes por tienda'),
          icon: Icons.shopping_bag_outlined,
          color: AppPalette.indigo,
          onTap: onOpenShop,
        ),
        _QuickActionCard(
          title: l10n.ts('Biblioteca'),
          subtitle: l10n.ts('Cursos y piezas formativas'),
          icon: Icons.auto_stories_outlined,
          color: AppPalette.orchid,
          onTap: onOpenCourses,
        ),
        _QuickActionCard(
          title: l10n.ts('Agenda'),
          subtitle: l10n.ts('Reserva, seguimiento y estado'),
          icon: Icons.calendar_month_outlined,
          color: AppPalette.royalViolet,
          onTap: onOpenBookings,
        ),
        _QuickActionCard(
          title: l10n.ts('Perfil'),
          subtitle: l10n.ts('Cuenta, idioma e insignias'),
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
    final l10n = context.l10n;
    final status = _shopOrderStatus(context, widget.order.status);

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
                  l10n.ts(
                    '{count} artículos · {date}',
                    {
                      'count': '${widget.order.itemCount}',
                      'date': formatSchedule(widget.order.createdAt),
                    },
                  ),
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
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pending',
                child: Text(context.l10n.ts('Pendiente')),
              ),
              PopupMenuItem(
                value: 'confirmed',
                child: Text(context.l10n.ts('Confirmada')),
              ),
              PopupMenuItem(
                value: 'preparing',
                child: Text(context.l10n.ts('Preparando')),
              ),
              PopupMenuItem(
                value: 'shipped',
                child: Text(context.l10n.ts('Enviada')),
              ),
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
            context.l10n.ts(
              '{code} actualizado a {status}.',
              {
                'code': updated.orderCode,
                'status': _shopOrderStatus(context, updated.status).label,
              },
            ),
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
                  context.l10n.ts(
                    '{headline} · {count} servicios',
                    {
                      'headline': specialist.headline,
                      'count': '$serviceCount',
                    },
                  ),
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
                  ? context.l10n.ts('Disponibilidad por revisar')
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

_ShopOrderStatusCopy _shopOrderStatus(BuildContext context, String status) {
  switch (status) {
    case 'confirmed':
      return _ShopOrderStatusCopy(
        label: context.l10n.ts('Confirmada'),
        color: AppPalette.success,
      );
    case 'preparing':
      return _ShopOrderStatusCopy(
        label: context.l10n.ts('Preparando'),
        color: AppPalette.flameGold,
      );
    case 'shipped':
      return _ShopOrderStatusCopy(
        label: context.l10n.ts('Enviada'),
        color: AppPalette.indigo,
      );
    default:
      return _ShopOrderStatusCopy(
        label: context.l10n.ts('Pendiente'),
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
