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
    this.initialServiceId,
  });

  final AppBootstrap data;
  final Future<String?> Function(CreateBookingInput input) onSave;
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
  TimeOfDay? _selectedTime;
  String? _errorMessage;
  bool _isSaving = false;

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
          _consultationServices
              .any((service) => service.id == preferredService);
      _selectedServiceId = hasPreferredService
          ? preferredService
          : _consultationServices.first.id;
      _syncSelection();
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

    return _consultationServices
        .where((service) => service.id == id)
        .firstOrNull;
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
      _selectedDate = picked;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 10, minute: 0),
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
      _selectedTime = picked;
    });
  }

  void _syncSelection() {
    final specialists = _availableSpecialists;
    if (specialists.isEmpty) {
      _selectedSpecialistId = null;
      _selectedMode = null;
      return;
    }

    final stillSelected =
        specialists.any((item) => item.id == _selectedSpecialistId);
    _selectedSpecialistId =
        stillSelected ? _selectedSpecialistId : specialists.first.id;

    final modes = _availableModes;
    if (modes.isEmpty) {
      _selectedMode = null;
      return;
    }

    final stillValidMode = modes.contains(_selectedMode);
    _selectedMode = stillValidMode ? _selectedMode : modes.first;
  }

  Future<void> _save() async {
    final serviceId = _selectedServiceId;
    final specialistId = _selectedSpecialistId;
    final mode = _selectedMode;
    final date = _selectedDate;
    final time = _selectedTime;

    if (serviceId == null ||
        specialistId == null ||
        mode == null ||
        date == null ||
        time == null) {
      setState(() {
        _errorMessage =
            'Selecciona servicio, especialista, modalidad, día y hora para agendar la cita.';
      });
      return;
    }

    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (scheduledAt.isBefore(DateTime.now())) {
      setState(() {
        _errorMessage = 'La fecha y hora seleccionadas ya pasaron.';
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
        scheduledAt: scheduledAt.toIso8601String(),
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
    final selectedDateTime = _selectedDate == null || _selectedTime == null
        ? null
        : DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar cita'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(
              'Reserva tu próxima consulta',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona servicio, especialista, modalidad, día y hora. La reserva se agregará directo a tu agenda.',
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
                      });
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
                      });
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
                      _selectedDate == null
                          ? 'Elegir día'
                          : _formatDate(_selectedDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : _pickTime,
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text(
                      _selectedTime == null
                          ? 'Elegir hora'
                          : _selectedTime!.format(context),
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
                    Text(selectedDateTime == null
                        ? 'Sin fecha y hora'
                        : formatSchedule(selectedDateTime.toIso8601String())),
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
              label: const Text('Confirmar cita'),
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

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
