import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/mystic_ui.dart';
import '../chat/community_chat_screen.dart';
import '../../models/app_models.dart';
import '../../models/booking_models.dart';
import '../../models/chat_models.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({
    super.key,
    required this.data,
    required this.onRefresh,
    required this.onCreateBooking,
    required this.onLoadAvailability,
    required this.onUpdateBooking,
    required this.onCancelBooking,
    required this.onLoadCommunityChat,
    required this.onSendCommunityChatMessage,
    this.canManageBookings = false,
  });

  final AppBootstrap data;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onCreateBooking;
  final Future<List<SpecialistAvailabilitySlot>> Function({
    required String specialistId,
    required DateTime from,
    required DateTime to,
    String? mode,
    String? serviceId,
  }) onLoadAvailability;
  final Future<String?> Function({
    required String bookingId,
    required UpdateBookingInput input,
  }) onUpdateBooking;
  final Future<String?> Function(String bookingId) onCancelBooking;
  final Future<List<CommunityChatMessage>> Function() onLoadCommunityChat;
  final Future<List<CommunityChatMessage>> Function(String body)
      onSendCommunityChatMessage;
  final bool canManageBookings;

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String? _busyBookingId;

  Future<void> _openCommunityChat() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CommunityChatScreen(
          onLoadMessages: widget.onLoadCommunityChat,
          onSendMessage: widget.onSendCommunityChatMessage,
        ),
      ),
    );
  }

  bool _canManageBooking(Booking booking) {
    return booking.status != 'cancelled' && booking.status != 'completed';
  }

  Future<void> _handleCancelBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancelar reserva'),
          content: Text(
            'Se cancelará ${booking.serviceName} con ${booking.specialistName}. Esta acción no se puede deshacer desde la app.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Volver'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cancelar reserva'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _busyBookingId = booking.id;
    });

    final errorMessage = await widget.onCancelBooking(booking.id);
    if (!mounted) {
      return;
    }

    setState(() {
      _busyBookingId = null;
    });

    _showSnackBar(
      errorMessage ?? 'La reserva fue cancelada y ya no aparece como activa.',
    );
  }

  Future<void> _handleRescheduleBooking(Booking booking) async {
    final service = widget.data.services
        .where((item) => item.id == booking.serviceId)
        .firstOrNull;
    if (service == null) {
      _showSnackBar(
          'No encontramos el servicio para reprogramar esta reserva.');
      return;
    }

    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppPalette.petalSoft,
      builder: (_) => _RescheduleBookingSheet(
        booking: booking,
        service: service,
        onLoadAvailability: widget.onLoadAvailability,
        onSave: (input) async {
          setState(() {
            _busyBookingId = booking.id;
          });

          final errorMessage = await widget.onUpdateBooking(
            bookingId: booking.id,
            input: input,
          );

          if (!mounted) {
            return errorMessage;
          }

          setState(() {
            _busyBookingId = null;
          });

          if (errorMessage == null) {
            _showSnackBar('La cita fue reprogramada correctamente.');
          }
          return errorMessage;
        },
      ),
    );

    if (changed == true && mounted) {
      setState(() {
        _busyBookingId = null;
      });
    }
  }

  Future<void> _handleSpecialistStatus(Booking booking, String status) async {
    setState(() {
      _busyBookingId = booking.id;
    });

    final errorMessage = await widget.onUpdateBooking(
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
      errorMessage ?? 'Cita actualizada a ${_statusLabel(status)}.',
    );
  }

  void _showBookingDetail(Booking booking) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.serviceName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('${booking.specialistName} · ${_modeLabel(booking.mode)}'),
              const SizedBox(height: 6),
              Text(formatSchedule(booking.scheduledAt)),
              const SizedBox(height: 6),
              Text('Estado: ${_statusLabel(booking.status)}'),
              const SizedBox(height: 12),
              Text(
                booking.notes.trim().isEmpty
                    ? 'Sin notas añadidas para esta consulta.'
                    : booking.notes,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildSpecialistAgenda({
    required int confirmedCount,
    required int pendingPaymentCount,
    required int cancelledCount,
  }) {
    final activeBookings = widget.data.bookings
        .where((booking) => booking.status != 'cancelled')
        .toList(growable: false);

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
              MysticBannerCard(
                eyebrow: 'Agenda especialista',
                title: 'Citas recibidas',
                subtitle:
                    'Gestiona pagos, confirmaciones y cierre de sesiones sin crear reservas como cliente.',
                glyphKind: MysticGlyphKind.agenda,
                gradient: AppPalette.darkBrandGradient,
                tags: [
                  '${widget.data.bookings.length} reservas',
                  '$confirmedCount confirmadas',
                  '$pendingPaymentCount pendientes',
                  if (cancelledCount > 0) '$cancelledCount canceladas',
                ],
                primaryLabel: 'Chat comunidad',
                onPrimaryTap: _openCommunityChat,
              ),
              const SizedBox(height: 20),
              Text(
                'Operación de citas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppPalette.butterflyInk,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),
              if (activeBookings.isEmpty)
                const MysticMiniBanner(
                  title: 'Sin citas activas',
                  subtitle:
                      'Cuando un cliente reserve una consulta, aparecerá aquí para cambiar estado y revisar notas.',
                  glyphKind: MysticGlyphKind.agenda,
                  accent: AppPalette.orchid,
                )
              else
                ...activeBookings.map(
                  (booking) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SpecialistAgendaBookingCard(
                      booking: booking,
                      busy: _busyBookingId == booking.id,
                      onOpen: () => _showBookingDetail(booking),
                      onStatusSelected: (status) =>
                          _handleSpecialistStatus(booking, status),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tarotSpecialists = widget.data.specialists.where((specialist) {
      return specialist.specialties.any(
        (item) => item.toLowerCase().contains('tarot'),
      );
    }).toList();
    final confirmedCount = widget.data.bookings
        .where((booking) => booking.status == 'confirmed')
        .length;
    final pendingPaymentCount = widget.data.bookings
        .where((booking) => booking.status == 'pending_payment')
        .length;
    final cancelledCount = widget.data.bookings
        .where((booking) => booking.status == 'cancelled')
        .length;

    if (widget.canManageBookings) {
      return _buildSpecialistAgenda(
        confirmedCount: confirmedCount,
        pendingPaymentCount: pendingPaymentCount,
        cancelledCount: cancelledCount,
      );
    }

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
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => widget.onCreateBooking(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppPalette.royalViolet,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Agendar nueva consulta'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Atajos de citas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    MysticMenuTile(
                      glyphKind: MysticGlyphKind.chat,
                      label: 'Chat general',
                      caption:
                          'Espacio abierto para que toda la gente comente.',
                      accent: const Color(0xFF9A5A33),
                      onTap: _openCommunityChat,
                    ),
                  ],
                ),
              ),
              if (tarotSpecialists.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Especialistas sugeridos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                ...tarotSpecialists.take(3).map(
                      (specialist) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MysticMiniBanner(
                          title: specialist.name,
                          subtitle:
                              '${specialist.headline}\n${joinList(specialist.specialties.take(2).toList())}',
                          glyphKind: MysticGlyphKind.specialist,
                          accent: const Color(0xFF6E5033),
                          onTap: () => widget.onCreateBooking(),
                        ),
                      ),
                    ),
              ],
              const SizedBox(height: 20),
              if (widget.data.bookings.isEmpty)
                MysticMiniBanner(
                  title: 'Aún no tienes citas agendadas',
                  subtitle:
                      'Crea tu primera consulta y elige el día y la hora que mejor te funcione.',
                  glyphKind: MysticGlyphKind.agenda,
                  accent: AppPalette.orchid,
                  onTap: () => widget.onCreateBooking(),
                )
              else
                ...widget.data.bookings.map(
                  (booking) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        MysticMiniBanner(
                          title:
                              '${booking.specialistName} · ${booking.serviceName}',
                          subtitle:
                              '${formatSchedule(booking.scheduledAt)} · ${formatMoney(booking.price)}\n${_modeLabel(booking.mode)}',
                          glyphKind: booking.mode == 'video'
                              ? MysticGlyphKind.video
                              : booking.mode == 'audio'
                                  ? MysticGlyphKind.audio
                                  : MysticGlyphKind.chat,
                          accent: _statusAccent(booking.status),
                          onTap: () => _showBookingDetail(booking),
                          trailing: _BookingStatusPill(booking: booking),
                        ),
                        if (_canManageBooking(booking)) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _busyBookingId == booking.id
                                      ? null
                                      : () => _handleRescheduleBooking(booking),
                                  icon: _busyBookingId == booking.id
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.calendar_month_outlined,
                                        ),
                                  label: const Text('Reprogramar'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: _busyBookingId == booking.id
                                      ? null
                                      : () => _handleCancelBooking(booking),
                                  icon: const Icon(Icons.close_rounded),
                                  label: const Text('Cancelar'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingStatusPill extends StatelessWidget {
  const _BookingStatusPill({
    required this.booking,
  });

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final accent = _statusAccent(booking.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(booking.status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: accent,
        ),
      ),
    );
  }
}

class _SpecialistAgendaBookingCard extends StatelessWidget {
  const _SpecialistAgendaBookingCard({
    required this.booking,
    required this.busy,
    required this.onOpen,
    required this.onStatusSelected,
  });

  final Booking booking;
  final bool busy;
  final VoidCallback onOpen;
  final ValueChanged<String> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final accent = _statusAccent(booking.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onOpen,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppPalette.borderSoft),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
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
                            color: AppPalette.butterflyInk,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatSchedule(booking.scheduledAt)} · ${formatMoney(booking.price)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppPalette.mutedLavender,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_modeLabel(booking.mode)} · ${booking.notes.trim().isEmpty ? 'Sin notas' : booking.notes.trim()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppPalette.mutedLavender,
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
                      tooltip: 'Cambiar estado',
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
                      child: _BookingStatusPill(booking: booking),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RescheduleBookingSheet extends StatefulWidget {
  const _RescheduleBookingSheet({
    required this.booking,
    required this.service,
    required this.onSave,
  });

  final Booking booking;
  final ServiceOffer service;
  final Future<String?> Function(UpdateBookingInput input) onSave;

  @override
  State<_RescheduleBookingSheet> createState() =>
      _RescheduleBookingSheetState();
}

class _RescheduleBookingSheetState extends State<_RescheduleBookingSheet> {
  late final TextEditingController _notesController;
  late DateTime _selectedDateTime;
  late String _selectedMode;
  String? _errorMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.booking.notes);
    _selectedDateTime =
        DateTime.tryParse(widget.booking.scheduledAt)?.toLocal() ??
            DateTime.now().add(const Duration(days: 1));
    _selectedMode = widget.service.deliveryModes.contains(widget.booking.mode)
        ? widget.booking.mode
        : widget.service.deliveryModes.firstOrNull ?? widget.booking.mode;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 120)),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDateTime = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_selectedDateTime.isBefore(DateTime.now())) {
      setState(() {
        _errorMessage = 'Elige una fecha futura para reprogramar la cita.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final errorMessage = await widget.onSave(
      UpdateBookingInput(
        scheduledAt: _selectedDateTime.toIso8601String(),
        mode: _selectedMode,
        notes: _notesController.text.trim(),
      ),
    );

    if (!mounted) {
      return;
    }

    if (errorMessage == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isSaving = false;
      _errorMessage = errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(
            'Reprogramar cita',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.booking.serviceName} con ${widget.booking.specialistName}',
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            initialValue: _selectedMode,
            decoration: const InputDecoration(labelText: 'Modalidad'),
            items: widget.service.deliveryModes
                .map(
                  (mode) => DropdownMenuItem<String>(
                    value: mode,
                    child: Text(_modeLabel(mode)),
                  ),
                )
                .toList(),
            onChanged: _isSaving
                ? null
                : (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _selectedMode = value;
                    });
                  },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSaving ? null : _pickDate,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                    '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year}',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSaving ? null : _pickTime,
                  icon: const Icon(Icons.schedule_outlined),
                  label: Text(
                    TimeOfDay.fromDateTime(_selectedDateTime).format(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Notas actualizadas',
              hintText: 'Aclara el enfoque o el contexto de esta sesión',
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Color(0xFF8B2C1F),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline),
            label: const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }
}

Color _statusAccent(String status) {
  switch (status) {
    case 'confirmed':
      return AppPalette.royalViolet;
    case 'cancelled':
      return AppPalette.berry;
    case 'completed':
      return AppPalette.indigo;
    default:
      return AppPalette.warning;
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'confirmed':
      return 'Confirmada';
    case 'pending_payment':
      return 'Pend. pago';
    case 'completed':
      return 'Completada';
    case 'cancelled':
      return 'Cancelada';
    default:
      return status;
  }
}

String _modeLabel(String mode) {
  switch (mode) {
    case 'audio':
      return 'Audio';
    case 'video':
      return 'Video';
    default:
      return 'Chat';
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
