import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/mystic_ui.dart';
import '../../models/app_models.dart';
import '../../models/booking_models.dart';

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
  String? _busyServiceId;
  String? _busyBookingId;

  @override
  Widget build(BuildContext context) {
    final paidServices = widget.data.services
        .where((service) => service.price.amount > 0)
        .toList(growable: false);
    final activeBookings = widget.data.bookings
        .where((booking) => booking.status != 'cancelled')
        .toList(growable: false);
    final pendingBookings = widget.data.bookings
        .where((booking) =>
            booking.status == 'pending_payment' ||
            booking.status == 'confirmed')
        .length;
    final featuredProducts =
        widget.data.shop.products.where((product) => product.featured).length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF8F0),
            Color(0xFFFFFCF8),
          ],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              MysticBannerCard(
                eyebrow: 'Modo especialista',
                title: 'Gestiona tu práctica, agenda y tienda',
                subtitle:
                    'Controla precios, citas, comunidad, productos y materiales desde un solo centro operativo.',
                glyphKind: MysticGlyphKind.specialist,
                gradient: const [
                  Color(0xFF1F1820),
                  Color(0xFF5B3A4F),
                  Color(0xFFB47658),
                ],
                tags: [
                  '${paidServices.length} servicios',
                  '$pendingBookings citas activas',
                  '${widget.data.courses.length} cursos',
                  '$featuredProducts productos destacados',
                ],
                primaryLabel: 'Gestionar precios',
                onPrimaryTap: () => _scrollToServices(context),
                secondaryLabel: 'Chat comunidad',
                onSecondaryTap: widget.onOpenCommunityChat,
              ),
              const SizedBox(height: 18),
              _SpecialistMetricGrid(
                serviceCount: paidServices.length,
                bookingCount: activeBookings.length,
                courseCount: widget.data.courses.length,
                productCount: widget.data.shop.products.length,
              ),
              const SizedBox(height: 18),
              _ActionDeck(
                onOpenShop: widget.onOpenShop,
                onOpenCourses: widget.onOpenCourses,
                onOpenCommunityChat: widget.onOpenCommunityChat,
              ),
              const SizedBox(height: 24),
              KeyedSubtree(
                key: _servicesKey,
                child: _SectionTitle(
                  title: 'Precios de consultas',
                  subtitle:
                      'Edita el valor de tus servicios sin duplicar el catálogo público.',
                ),
              ),
              const SizedBox(height: 12),
              ...paidServices.map(
                (service) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ServicePriceCard(
                    service: service,
                    busy: _busyServiceId == service.id,
                    onEdit: () => _openServicePriceSheet(service),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SectionTitle(
                title: 'Citas operativas',
                subtitle:
                    'Mueve reservas por estado para mantener clara la atención del día.',
              ),
              const SizedBox(height: 12),
              if (activeBookings.isEmpty)
                const _EmptyPanel(
                  title: 'Sin citas activas',
                  subtitle:
                      'Cuando un cliente reserve una consulta, aparecerá aquí para gestionarla.',
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

  void _scrollToServices(BuildContext context) {
    final target = _servicesKey.currentContext;
    if (target == null) {
      return;
    }

    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openServicePriceSheet(ServiceOffer service) async {
    final result = await showModalBottomSheet<_ServicePriceUpdate>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFFFCF8),
      builder: (context) => _ServicePriceSheet(service: service),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _busyServiceId = service.id;
    });

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

    setState(() {
      _busyServiceId = null;
    });

    _showSnackBar(error ?? '${service.name} actualizado.');
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
        error ?? 'Cita actualizada a ${_bookingStatusLabel(status)}.');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

final GlobalKey _servicesKey = GlobalKey();

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
              label: 'Servicios',
              color: const Color(0xFF5C3B52),
            ),
            _MetricTile(
              width: width,
              icon: Icons.calendar_month_outlined,
              value: '$bookingCount',
              label: 'Citas',
              color: const Color(0xFF4F7B67),
            ),
            _MetricTile(
              width: width,
              icon: Icons.picture_as_pdf_outlined,
              value: '$courseCount',
              label: 'Cursos',
              color: const Color(0xFF8C6239),
            ),
            _MetricTile(
              width: width,
              icon: Icons.shopping_bag_outlined,
              value: '$productCount',
              label: 'Productos',
              color: const Color(0xFF8C4C43),
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
          border: Border.all(color: const Color(0xFFE7DED3)),
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
                          color: const Color(0xFF6E625B),
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

class _ActionDeck extends StatelessWidget {
  const _ActionDeck({
    required this.onOpenShop,
    required this.onOpenCourses,
    required this.onOpenCommunityChat,
  });

  final VoidCallback onOpenShop;
  final VoidCallback onOpenCourses;
  final Future<void> Function() onOpenCommunityChat;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            title: 'Tienda',
            subtitle: 'Fotos, stock y productos',
            icon: Icons.storefront_rounded,
            color: const Color(0xFF8C4C43),
            onTap: onOpenShop,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            title: 'Cursos/PDF',
            subtitle: 'Materiales y rutas',
            icon: Icons.auto_stories_outlined,
            color: const Color(0xFF8C6239),
            onTap: onOpenCourses,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            title: 'Comunidad',
            subtitle: 'Chat abierto',
            icon: Icons.forum_outlined,
            color: const Color(0xFF4F7B67),
            onTap: () {
              onOpenCommunityChat();
            },
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE7DED3)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6E625B),
                      height: 1.25,
                    ),
              ),
            ],
          ),
        ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7DED3)),
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
                  '${service.category} · ${service.durationMinutes} min · ${service.deliveryModes.join(', ')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6E625B),
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
                    : const Text('Editar'),
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
        border: Border.all(color: const Color(0xFFE7DED3)),
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
                        color: const Color(0xFF6E625B),
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
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'pending_payment',
                      child: Text('Pendiente de pago'),
                    ),
                    PopupMenuItem(
                      value: 'confirmed',
                      child: Text('Confirmada'),
                    ),
                    PopupMenuItem(
                      value: 'completed',
                      child: Text('Completada'),
                    ),
                    PopupMenuItem(
                      value: 'cancelled',
                      child: Text('Cancelada'),
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
            'Editar consulta',
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
            decoration: const InputDecoration(
              labelText: 'Precio USD',
              hintText: '32.00',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Duración en minutos',
              hintText: '45',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(
                color: Color(0xFF8B2C1F),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Guardar cambios'),
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
        _error = 'Ingresa precio y duración válidos.';
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF24191F),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calidad de contenido e imágenes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Usa imágenes verticales nítidas, luz suave y fondos limpios. Para PDFs y cursos, mantén portada, descripción y módulos revisados antes de publicar.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onOpenCourses,
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.auto_stories_outlined),
            label: const Text('Revisar cursos y PDFs'),
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
                color: const Color(0xFF5E676E),
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
        _bookingStatusLabel(status),
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
        border: Border.all(color: const Color(0xFFE7DED3)),
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
                  color: const Color(0xFF5E676E),
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

String _bookingStatusLabel(String status) {
  switch (status) {
    case 'pending_payment':
      return 'Pendiente';
    case 'confirmed':
      return 'Confirmada';
    case 'completed':
      return 'Completada';
    case 'cancelled':
      return 'Cancelada';
    default:
      return status;
  }
}

Color _bookingStatusColor(String status) {
  switch (status) {
    case 'confirmed':
      return const Color(0xFF4F7B67);
    case 'completed':
      return const Color(0xFF3E6381);
    case 'cancelled':
      return const Color(0xFF8C4C43);
    default:
      return const Color(0xFF8C6239);
  }
}
