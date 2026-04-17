import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/specialist_rating_badge.dart';
import '../../models/app_models.dart';
import '../../models/booking_models.dart';

class ScheduleBookingScreen extends StatefulWidget {
  const ScheduleBookingScreen({
    super.key,
    required this.data,
    required this.onSave,
    required this.onLoadAvailability,
    this.initialServiceId,
  });

  final AppBootstrap data;
  final Future<String?> Function(CreateBookingInput input) onSave;
  final Future<List<SpecialistAvailabilitySlot>> Function({
    required String specialistId,
    required DateTime from,
    required DateTime to,
    String? mode,
    String? serviceId,
  }) onLoadAvailability;
  final String? initialServiceId;

  @override
  State<ScheduleBookingScreen> createState() => _ScheduleBookingScreenState();
}

class _ScheduleBookingScreenState extends State<ScheduleBookingScreen> {
  late final TextEditingController _notesController;
  late final List<ServiceOffer> _consultationServices;

  String? _selectedServiceId;
  String? _selectedSpecialistId;
  String? _selectedMode;
  DateTime? _selectedDate;
  String? _selectedSlotId;
  String? _errorMessage;
  String? _availabilityMessage;
  bool _isSaving = false;
  bool _isLoadingAvailability = false;
  int _availabilityRequestId = 0;
  List<SpecialistAvailabilitySlot> _availabilitySlots = const [];

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _consultationServices = widget.data.services
        .where((service) =>
            service.durationMinutes > 0 && service.specialistIds.isNotEmpty)
        .toList();
    if (_consultationServices.isNotEmpty) {
      final preferredService = widget.initialServiceId;
      final hasPreferredService = preferredService != null &&
          _consultationServices.any((service) => service.id == preferredService);
      _selectedServiceId =
          hasPreferredService ? preferredService : _consultationServices.first.id;
      _syncSelection();
      _ensureSelectedDate();
      Future<void>.microtask(_loadAvailabilityForSelection);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  ServiceOffer? get _selectedService {
    final id = _selectedServiceId;
    if (id == null) {
      return null;
    }

    return _consultationServices.where((service) => service.id == id).firstOrNull;
  }

  SpecialistAvailabilitySlot? get _selectedSlot {
    final slotId = _selectedSlotId;
    if (slotId == null) {
      return null;
    }

    return _availabilitySlots.where((slot) => slot.id == slotId).firstOrNull;
  }

  List<Specialist> get _availableSpecialists {
    final service = _selectedService;
    if (service == null) {
      return const [];
    }

    return widget.data.specialists
        .where((specialist) => service.specialistIds.contains(specialist.id))
        .toList();
  }

  List<String> get _availableModes {
    final service = _selectedService;
    final specialistId = _selectedSpecialistId;
    if (service == null) {
      return const [];
    }

    final specialist = widget.data.specialists
        .where((item) => item.id == specialistId)
        .firstOrNull;
    if (specialist == null) {
      return service.deliveryModes;
    }

    return service.deliveryModes
        .where((mode) => specialist.sessionModes.contains(mode))
        .toList();
  }

  bool get _isSpecialistView => widget.data.user.accountType == 'specialist';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 120)),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDate = DateUtils.dateOnly(picked);
      _selectedSlotId = null;
      _availabilityMessage = null;
      _errorMessage = null;
    });

    await _loadAvailabilityForSelection();
  }

  void _syncSelection() {
    final specialists = _availableSpecialists;
    if (specialists.isEmpty) {
      _selectedSpecialistId = null;
      _selectedMode = null;
      _resetAvailabilityState();
      return;
    }

    final stillSelected =
        specialists.any((item) => item.id == _selectedSpecialistId);
    _selectedSpecialistId =
        stillSelected ? _selectedSpecialistId : specialists.first.id;

    final modes = _availableModes;
    if (modes.isEmpty) {
      _selectedMode = null;
      _resetAvailabilityState();
      return;
    }

    final stillValidMode = modes.contains(_selectedMode);
    _selectedMode = stillValidMode ? _selectedMode : modes.first;
  }

  void _ensureSelectedDate() {
    if (_selectedDate != null) {
      return;
    }

    final specialist = _availableSpecialists
        .where((item) => item.id == _selectedSpecialistId)
        .firstOrNull;
    final suggestedDate =
        DateTime.tryParse(specialist?.nextAvailableAt ?? '')?.toLocal();
    final fallback = DateTime.now().add(const Duration(days: 1));
    _selectedDate = DateUtils.dateOnly(suggestedDate ?? fallback);
  }

  void _resetAvailabilityState() {
    _availabilitySlots = const [];
    _selectedSlotId = null;
    _availabilityMessage = null;
  }

  Future<void> _loadAvailabilityForSelection() async {
    final serviceId = _selectedServiceId;
    final specialistId = _selectedSpecialistId;
    final mode = _selectedMode;
    final selectedDate = _selectedDate;

    if (serviceId == null ||
        specialistId == null ||
        mode == null ||
        selectedDate == null) {
      if (mounted) {
        setState(_resetAvailabilityState);
      }
      return;
    }

    final requestId = ++_availabilityRequestId;
    final from = DateUtils.dateOnly(selectedDate);
    final to = from.add(const Duration(days: 1));

    setState(() {
      _isLoadingAvailability = true;
      _selectedSlotId = null;
      _availabilityMessage = null;
      _errorMessage = null;
    });

    try {
      final slots = await widget.onLoadAvailability(
        specialistId: specialistId,
        serviceId: serviceId,
        mode: mode,
        from: from,
        to: to,
      );

      if (!mounted || requestId != _availabilityRequestId) {
        return;
      }

      final availableSlots = slots
          .where((slot) => slot.isAvailable)
          .toList()
        ..sort((left, right) => left.startsAt.compareTo(right.startsAt));

      setState(() {
        _availabilitySlots = availableSlots;
        _selectedSlotId = availableSlots.firstOrNull?.id;
        _availabilityMessage = availableSlots.isEmpty
            ? 'No encontramos horarios disponibles para ese día. Prueba con otra fecha o modalidad.'
            : null;
        _isLoadingAvailability = false;
      });
    } catch (error) {
      if (!mounted || requestId != _availabilityRequestId) {
        return;
      }

      setState(() {
        _availabilitySlots = const [];
        _selectedSlotId = null;
        _availabilityMessage = error.toString().replaceFirst('Exception: ', '');
        _isLoadingAvailability = false;
      });
    }
  }

  Future<void> _save() async {
    final serviceId = _selectedServiceId;
    final specialistId = _selectedSpecialistId;
    final mode = _selectedMode;
    final slot = _selectedSlot;

    if (serviceId == null || specialistId == null || mode == null || slot == null) {
      setState(() {
        _errorMessage =
            'Selecciona servicio, especialista, modalidad y un horario disponible para agendar la cita.';
      });
      return;
    }

    final scheduledAt = DateTime.tryParse(slot.startsAt);
    if (scheduledAt == null || scheduledAt.isBefore(DateTime.now())) {
      setState(() {
        _errorMessage = 'El horario seleccionado ya no está disponible.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final errorMessage = await widget.onSave(
      CreateBookingInput(
        specialistId: specialistId,
        serviceId: serviceId,
        scheduledAt: slot.startsAt,
        mode: mode,
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
    final service = _selectedService;
    final specialists = _availableSpecialists;
    final modes = _availableModes;
    final selectedSpecialist = specialists
        .where((item) => item.id == _selectedSpecialistId)
        .firstOrNull;
    final selectedSlot = _selectedSlot;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSpecialistView ? 'Registrar cita' : 'Agendar cita'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(
              _isSpecialistView
                  ? 'Agenda una sesión dentro de tu panel'
                  : 'Reserva tu próxima consulta',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _isSpecialistView
                  ? 'Elige servicio, especialista, modalidad y un horario real disponible en la agenda.'
                  : 'Selecciona servicio, especialista, modalidad y uno de los horarios disponibles. La reserva se agrega directo a tu agenda.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              key: ValueKey('service-${_selectedServiceId ?? 'empty'}'),
              initialValue: _selectedServiceId,
              decoration: const InputDecoration(labelText: 'Servicio'),
              items: _consultationServices
                  .map(
                    (service) => DropdownMenuItem<String>(
                      value: service.id,
                      child: Text(service.name),
                    ),
                  )
                  .toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() {
                        _selectedServiceId = value;
                        _syncSelection();
                        _ensureSelectedDate();
                      });
                      _loadAvailabilityForSelection();
                    },
            ),
            if (service != null) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(label: Text(service.category)),
                          Chip(label: Text('${service.durationMinutes} min')),
                          Chip(label: Text(formatMoney(service.price))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey('specialist-${_selectedSpecialistId ?? 'empty'}'),
              initialValue: _selectedSpecialistId,
              decoration: const InputDecoration(labelText: 'Especialista'),
              items: specialists
                  .map(
                    (specialist) => DropdownMenuItem<String>(
                      value: specialist.id,
                      child: Text(specialist.name),
                    ),
                  )
                  .toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() {
                        _selectedSpecialistId = value;
                        _syncSelection();
                        _ensureSelectedDate();
                      });
                      _loadAvailabilityForSelection();
                    },
            ),
            if (selectedSpecialist != null) ...[
              const SizedBox(height: 12),
              Text(
                selectedSpecialist.headline,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              SpecialistRatingBadge(rating: selectedSpecialist.rating),
              const SizedBox(height: 10),
              Text(
                'Próxima disponibilidad sugerida: ${formatSchedule(selectedSpecialist.nextAvailableAt)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey('mode-${_selectedMode ?? 'empty'}'),
              initialValue: _selectedMode,
              decoration: const InputDecoration(labelText: 'Modalidad'),
              items: modes
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
                      setState(() {
                        _selectedMode = value;
                      });
                      _loadAvailabilityForSelection();
                    },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _pickDate,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(
                _selectedDate == null
                    ? 'Elegir día'
                    : _formatDate(_selectedDate!),
              ),
            ),
            const SizedBox(height: 16),
            _AvailabilitySection(
              service: service,
              selectedDate: _selectedDate,
              slots: _availabilitySlots,
              selectedSlotId: _selectedSlotId,
              isLoading: _isLoadingAvailability,
              message: _availabilityMessage,
              onSelected: _isSaving
                  ? null
                  : (slotId) {
                      setState(() {
                        _selectedSlotId = slotId;
                        _errorMessage = null;
                      });
                    },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Notas para la consulta',
                hintText: 'Cuéntanos qué tema quieres trabajar en la sesión',
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen de la cita',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(service == null
                        ? 'Sin servicio seleccionado'
                        : service.name),
                    const SizedBox(height: 4),
                    Text(selectedSpecialist?.name ??
                        'Sin especialista seleccionado'),
                    const SizedBox(height: 4),
                    Text(_selectedMode == null
                        ? 'Sin modalidad'
                        : _modeLabel(_selectedMode!)),
                    const SizedBox(height: 4),
                    Text(selectedSlot == null
                        ? 'Sin horario confirmado'
                        : formatSchedule(selectedSlot.startsAt)),
                  ],
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECE8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Color(0xFF8B2C1F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed:
                  _isSaving || _consultationServices.isEmpty ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.calendar_month),
              label: Text(
                _isSpecialistView ? 'Registrar cita' : 'Confirmar cita',
              ),
            ),
          ],
        ),
      ),
    );
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

  String _formatDate(DateTime date) {
    const weekDays = [
      'Lun',
      'Mar',
      'Mie',
      'Jue',
      'Vie',
      'Sab',
      'Dom',
    ];
    final weekDay = weekDays[date.weekday - 1];
    return '$weekDay ${date.day}/${date.month}/${date.year}';
  }
}

class _AvailabilitySection extends StatelessWidget {
  const _AvailabilitySection({
    required this.service,
    required this.selectedDate,
    required this.slots,
    required this.selectedSlotId,
    required this.isLoading,
    required this.message,
    required this.onSelected,
  });

  final ServiceOffer? service;
  final DateTime? selectedDate;
  final List<SpecialistAvailabilitySlot> slots;
  final String? selectedSlotId;
  final bool isLoading;
  final String? message;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    final serviceDuration = service?.durationMinutes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Horarios disponibles',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              selectedDate == null
                  ? 'Elige un día para consultar la agenda disponible.'
                  : serviceDuration == null
                      ? 'Selecciona un servicio para ver horarios.'
                      : 'Se muestran horarios reales para sesiones de $serviceDuration minutos.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (message != null)
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else if (slots.isEmpty)
              Text(
                'No hay horarios cargados todavía para esta selección.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: slots
                    .map(
                      (slot) => ChoiceChip(
                        label: Text(_formatSlotLabel(slot)),
                        selected: slot.id == selectedSlotId,
                        onSelected: onSelected == null
                            ? null
                            : (_) => onSelected!(slot.id),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  String _formatSlotLabel(SpecialistAvailabilitySlot slot) {
    final startsAt = DateTime.tryParse(slot.startsAt)?.toLocal();
    final endsAt = DateTime.tryParse(slot.endsAt)?.toLocal();
    if (startsAt == null || endsAt == null) {
      return slot.startsAt;
    }

    return '${_formatTime(startsAt)} - ${_formatTime(endsAt)}';
  }

  String _formatTime(DateTime value) {
    final hours = value.hour.toString().padLeft(2, '0');
    final minutes = value.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
