import 'package:flutter/material.dart';

import '../../core/i18n/app_i18n.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_models.dart';
import '../../models/booking_models.dart';

const _specialistCommerceGradient = <Color>[
  AppPalette.midnight,
  AppPalette.indigo,
  AppPalette.royalViolet,
];

const _specialistContentGradient = <Color>[
  AppPalette.indigo,
  AppPalette.royalViolet,
  AppPalette.orchid,
];

const _specialistCommunityGradient = <Color>[
  AppPalette.dusk,
  AppPalette.indigo,
  AppPalette.roseDust,
];

class SpecialistWorkspaceScreen extends StatefulWidget {
  const SpecialistWorkspaceScreen({
    super.key,
    required this.data,
    required this.onRefresh,
    required this.onUpdateService,
    required this.onUpdateBooking,
    required this.onOpenShop,
    required this.onOpenCourses,
    required this.onOpenCommunityChat,
  });

  final AppBootstrap data;
  final Future<void> Function() onRefresh;
  final Future<String?> Function({
    required String serviceId,
    required UpdateServiceOfferInput input,
  }) onUpdateService;
  final Future<String?> Function({
    required String bookingId,
    required UpdateBookingInput input,
  }) onUpdateBooking;
  final VoidCallback onOpenShop;
  final VoidCallback onOpenCourses;
  final Future<void> Function() onOpenCommunityChat;

  @override
  State<SpecialistWorkspaceScreen> createState() =>
      _SpecialistWorkspaceScreenState();
}

class _SpecialistWorkspaceScreenState extends State<SpecialistWorkspaceScreen> {
  String? _busyBookingId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final paidServices = widget.data.services
        .where((service) => service.price.amount > 0)
        .toList(growable: false);
    final activeBookings = widget.data.bookings
        .where((booking) => booking.status != 'cancelled')
        .toList(growable: false);
    final activeOrders = widget.data.shop.orders
        .where(
          (order) => order.status != 'completed' && order.status != 'cancelled',
        )
        .length;
    final featuredCourses =
        widget.data.courses.where((course) => course.featured).length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppPalette.shellGradientTop,
            AppPalette.shellGradientMid,
            AppPalette.shellGradientBottom,
          ],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _SpecialistMetricGrid(
                serviceCount: paidServices.length,
                bookingCount: activeBookings.length,
                courseCount: widget.data.courses.length,
                productCount: widget.data.shop.products.length,
              ),
              const SizedBox(height: 18),
              _PricingCenterCard(
                services: paidServices,
                onOpen: () => _openPricingCenterSheet(paidServices),
              ),
              const SizedBox(height: 18),
              _ActionDeck(
                productCount: widget.data.shop.products.length,
                activeOrderCount: activeOrders,
                courseCount: widget.data.courses.length,
                featuredCourseCount: featuredCourses,
                onOpenShop: widget.onOpenShop,
                onOpenCourses: widget.onOpenCourses,
                onOpenCommunityChat: widget.onOpenCommunityChat,
              ),
              const SizedBox(height: 24),
              _SectionTitle(
                title: l10n.ts('Citas operativas'),
                subtitle: l10n.ts(
                  'Mueve reservas por estado para mantener clara la atención del día.',
                ),
              ),
              const SizedBox(height: 12),
              if (activeBookings.isEmpty)
                _EmptyPanel(
                  title: l10n.ts('Sin citas activas'),
                  subtitle: l10n.ts(
                    'Cuando un cliente reserve una consulta, aparecerá aquí para gestionarla.',
                  ),
                )
              else
                ...activeBookings.map(
                  (booking) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SpecialistBookingCard(
                      booking: booking,
                      busy: _busyBookingId == booking.id,
                      onStatusSelected: (status) =>
                          _updateBookingStatus(booking, status),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              _ContentQualityCard(onOpenCourses: widget.onOpenCourses),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPricingCenterSheet(List<ServiceOffer> services) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppPalette.petalSoft,
      builder: (sheetContext) => _PricingCenterSheet(
        services: services,
        onEdit: (service) {
          Navigator.of(sheetContext).pop();
          _openServicePriceSheet(service);
        },
      ),
    );
  }

  Future<void> _openServicePriceSheet(ServiceOffer service) async {
    final result = await showModalBottomSheet<_ServicePriceUpdate>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppPalette.petalSoft,
      builder: (context) => _ServicePriceSheet(service: service),
    );

    if (result == null || !mounted) {
      return;
    }

    final error = await widget.onUpdateService(
      serviceId: service.id,
      input: UpdateServiceOfferInput(
        priceAmount: result.priceAmount,
        durationMinutes: result.durationMinutes,
      ),
    );

    if (!mounted) {
      return;
    }

    _showSnackBar(
      error ??
          context.l10n.ts('{name} actualizado.', {'name': service.name}),
    );
  }

  Future<void> _updateBookingStatus(Booking booking, String status) async {
    setState(() {
      _busyBookingId = booking.id;
    });

    final error = await widget.onUpdateBooking(
      bookingId: booking.id,
      input: UpdateBookingInput(status: status),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _busyBookingId = null;
    });

    _showSnackBar(
      error ??
          context.l10n.ts(
            'Cita actualizada a {status}.',
            {'status': _bookingStatusLabel(context, status)},
          ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _SpecialistMetricGrid extends StatelessWidget {
  const _SpecialistMetricGrid({
    required this.serviceCount,
    required this.bookingCount,
    required this.courseCount,
    required this.productCount,
  });

  final int serviceCount;
  final int bookingCount;
  final int courseCount;
  final int productCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricTile(
              width: width,
              icon: Icons.payments_outlined,
              value: '$serviceCount',
              label: l10n.ts('Servicios'),
              color: AppPalette.indigo,
            ),
            _MetricTile(
              width: width,
              icon: Icons.calendar_month_outlined,
              value: '$bookingCount',
              label: l10n.ts('Citas'),
              color: AppPalette.royalViolet,
            ),
            _MetricTile(
              width: width,
              icon: Icons.picture_as_pdf_outlined,
              value: '$courseCount',
              label: l10n.ts('Cursos'),
              color: AppPalette.warning,
            ),
            _MetricTile(
              width: width,
              icon: Icons.shopping_bag_outlined,
              value: '$productCount',
              label: l10n.ts('Productos'),
              color: AppPalette.berry,
            ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.width,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final double width;
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppPalette.borderSoft),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppPalette.mutedLavender,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingCenterCard extends StatelessWidget {
  const _PricingCenterCard({
    required this.services,
    required this.onOpen,
  });

  final List<ServiceOffer> services;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lowestService = services.isEmpty
        ? null
        : services.reduce(
            (a, b) => a.price.amount <= b.price.amount ? a : b,
          );
    final totalDuration = services.fold<int>(
      0,
      (sum, service) => sum + service.durationMinutes,
    );
    final averageDuration =
        services.isEmpty ? 0 : (totalDuration / services.length).round();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onOpen,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _specialistCommerceGradient,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppPalette.indigo.withValues(alpha: 0.22),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: AppPalette.candleGlow,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.ts('Servicios y precios'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      services.isEmpty
                          ? l10n.ts(
                              'Configura tus consultas antes de publicarlas.',
                            )
                          : l10n.ts(
                              '{count} consultas · desde {price} · {minutes} min promedio',
                              {
                                'count': '${services.length}',
                                'price': formatMoney(lowestService!.price),
                                'minutes': '$averageDuration',
                              },
                            ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.76),
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppPalette.candleGlow,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppPalette.butterflyInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionDeck extends StatelessWidget {
  const _ActionDeck({
    required this.productCount,
    required this.activeOrderCount,
    required this.courseCount,
    required this.featuredCourseCount,
    required this.onOpenShop,
    required this.onOpenCourses,
    required this.onOpenCommunityChat,
  });

  final int productCount;
  final int activeOrderCount;
  final int courseCount;
  final int featuredCourseCount;
  final VoidCallback onOpenShop;
  final VoidCallback onOpenCourses;
  final Future<void> Function() onOpenCommunityChat;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.ts('Tienda, cursos y comunidad'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppPalette.butterflyInk,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
        ),
        const SizedBox(height: 12),
        _SpotlightActionCard(
          title: l10n.ts('Tienda'),
          metric: l10n.ts('{count} productos', {'count': '$productCount'}),
          detail: activeOrderCount > 0
              ? l10n.ts(
                  '{count} órdenes por revisar',
                  {'count': '$activeOrderCount'},
                )
              : l10n.ts('Catálogo, fotos y stock'),
          actionLabel: l10n.ts('Administrar tienda'),
          icon: Icons.storefront_rounded,
          gradient: _specialistCommerceGradient,
          onTap: onOpenShop,
        ),
        const SizedBox(height: 12),
        _SpotlightActionCard(
          title: l10n.ts('Cursos y PDFs'),
          metric: l10n.ts('{count} cursos activos', {'count': '$courseCount'}),
          detail: featuredCourseCount > 0
              ? l10n.ts(
                  '{count} destacados para alumnos',
                  {'count': '$featuredCourseCount'},
                )
              : l10n.ts('Biblioteca y materiales'),
          actionLabel: l10n.ts('Gestionar contenido'),
          icon: Icons.auto_stories_outlined,
          gradient: _specialistContentGradient,
          onTap: onOpenCourses,
        ),
        const SizedBox(height: 12),
        _SpotlightActionCard(
          title: l10n.ts('Comunidad'),
          metric: l10n.ts('Chat general'),
          detail: l10n.ts('Mensajes, acompañamiento y vínculo con clientes'),
          actionLabel: l10n.ts('Abrir comunidad'),
          icon: Icons.forum_outlined,
          gradient: _specialistCommunityGradient,
          onTap: () {
            onOpenCommunityChat();
          },
        ),
      ],
    );
  }
}

class _SpotlightActionCard extends StatelessWidget {
  const _SpotlightActionCard({
    required this.title,
    required this.metric,
    required this.detail,
    required this.actionLabel,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final String metric;
  final String detail;
  final String actionLabel;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $metric. $actionLabel.',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradient.last.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -24,
                  top: -18,
                  child: Icon(
                    icon,
                    size: 118,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.16),
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: AppPalette.candleGlow,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        decoration: TextDecoration.none,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  metric,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppPalette.roseQuartz,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        detail,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.76),
                          fontSize: 13,
                          height: 1.28,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              actionLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppPalette.butterflyInk,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: AppPalette.butterflyInk,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _PricingCenterSheet extends StatelessWidget {
  const _PricingCenterSheet({
    required this.services,
    required this.onEdit,
  });

  final List<ServiceOffer> services;
  final ValueChanged<ServiceOffer> onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(
            l10n.ts('Servicios y precios'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppPalette.butterflyInk,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.ts(
              'Administra los valores de tus consultas desde este centro, separado del panel principal.',
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPalette.mutedLavender,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 18),
          if (services.isEmpty)
            _EmptyPanel(
              title: l10n.ts('Sin servicios pagados'),
              subtitle: l10n.ts(
                'Cuando exista una consulta con precio, aparecerá aquí para editarla.',
              ),
            )
          else
            ...services.map(
              (service) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ServicePriceCard(
                  service: service,
                  busy: false,
                  onEdit: () => onEdit(service),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ServicePriceCard extends StatelessWidget {
  const _ServicePriceCard({
    required this.service,
    required this.busy,
    required this.onEdit,
  });

  final ServiceOffer service;
  final bool busy;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.borderSoft),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.ts(
                    '{category} · {minutes} min · {modes}',
                    {
                      'category': service.category,
                      'minutes': '${service.durationMinutes}',
                      'modes': service.deliveryModes.join(', '),
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
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatMoney(service.price),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: busy ? null : onEdit,
                child: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.ts('Editar')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpecialistBookingCard extends StatelessWidget {
  const _SpecialistBookingCard({
    required this.booking,
    required this.busy,
    required this.onStatusSelected,
  });

  final Booking booking;
  final bool busy;
  final ValueChanged<String> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final accent = _bookingStatusColor(booking.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.borderSoft),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.event_available_outlined, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.serviceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatSchedule(booking.scheduledAt)} · ${booking.specialistName}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPalette.mutedLavender,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : PopupMenuButton<String>(
                  onSelected: onStatusSelected,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'pending_payment',
                      child: Text(context.l10n.ts('Pendiente de pago')),
                    ),
                    PopupMenuItem(
                      value: 'confirmed',
                      child: Text(context.l10n.ts('Confirmada')),
                    ),
                    PopupMenuItem(
                      value: 'completed',
                      child: Text(context.l10n.ts('Completada')),
                    ),
                    PopupMenuItem(
                      value: 'cancelled',
                      child: Text(context.l10n.ts('Cancelada')),
                    ),
                  ],
                  child: _StatusPill(status: booking.status),
                ),
        ],
      ),
    );
  }
}

class _ServicePriceSheet extends StatefulWidget {
  const _ServicePriceSheet({
    required this.service,
  });

  final ServiceOffer service;

  @override
  State<_ServicePriceSheet> createState() => _ServicePriceSheetState();
}

class _ServicePriceSheetState extends State<_ServicePriceSheet> {
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.service.price.amount.toStringAsFixed(2),
    );
    _durationController = TextEditingController(
      text: '${widget.service.durationMinutes}',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(
            l10n.ts('Editar consulta'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(widget.service.name),
          const SizedBox(height: 18),
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.ts('Precio USD'),
              hintText: '32.00',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.ts('Duración en minutos'),
              hintText: '45',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(
                color: AppPalette.berry,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.save_outlined),
            label: Text(l10n.ts('Guardar cambios')),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final price = double.tryParse(_priceController.text.trim());
    final duration = int.tryParse(_durationController.text.trim());

    if (price == null || price < 0 || duration == null || duration < 0) {
      setState(() {
        _error = context.l10n.ts('Ingresa precio y duración válidos.');
      });
      return;
    }

    Navigator.of(context).pop(
      _ServicePriceUpdate(
        priceAmount: price,
        durationMinutes: duration,
      ),
    );
  }
}

class _ContentQualityCard extends StatelessWidget {
  const _ContentQualityCard({
    required this.onOpenCourses,
  });

  final VoidCallback onOpenCourses;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _specialistContentGradient,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppPalette.orchid.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.ts('Calidad de contenido e imágenes'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.ts(
              'Usa imágenes verticales nítidas, luz suave y fondos limpios. Para PDFs y cursos, mantén portada, descripción y módulos revisados antes de publicar.',
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onOpenCourses,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.32),
              ),
            ),
            icon: const Icon(Icons.auto_stories_outlined),
            label: Text(l10n.ts('Revisar cursos y PDFs')),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
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
                height: 1.45,
              ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final accent = _bookingStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _bookingStatusLabel(context, status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.borderSoft),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPalette.mutedLavender,
                ),
          ),
        ],
      ),
    );
  }
}

class _ServicePriceUpdate {
  const _ServicePriceUpdate({
    required this.priceAmount,
    required this.durationMinutes,
  });

  final double priceAmount;
  final int durationMinutes;
}

String _bookingStatusLabel(BuildContext context, String status) {
  switch (status) {
    case 'pending_payment':
      return context.l10n.ts('Pendiente');
    case 'confirmed':
      return context.l10n.ts('Confirmada');
    case 'completed':
      return context.l10n.ts('Completada');
    case 'cancelled':
      return context.l10n.ts('Cancelada');
    default:
      return status;
  }
}

Color _bookingStatusColor(String status) {
  switch (status) {
    case 'confirmed':
      return AppPalette.royalViolet;
    case 'completed':
      return AppPalette.indigo;
    case 'cancelled':
      return AppPalette.berry;
    default:
      return AppPalette.warning;
  }
}
