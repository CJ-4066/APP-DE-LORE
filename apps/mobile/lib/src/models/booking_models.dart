class CreateBookingInput {
  CreateBookingInput({
    required this.specialistId,
    required this.serviceId,
    required this.scheduledAt,
    required this.mode,
    required this.notes,
  });

  final String specialistId;
  final String serviceId;
  final String scheduledAt;
  final String mode;
  final String notes;

  Map<String, dynamic> toJson() {
    return {
      'specialistId': specialistId,
      'serviceId': serviceId,
      'scheduledAt': scheduledAt,
      'mode': mode,
      'notes': notes,
    };
  }
}

class SpecialistAvailabilitySlot {
  SpecialistAvailabilitySlot({
    required this.id,
    required this.specialistId,
    required this.startsAt,
    required this.endsAt,
    required this.mode,
    required this.isAvailable,
  });

  final String id;
  final String specialistId;
  final String startsAt;
  final String endsAt;
  final String mode;
  final bool isAvailable;

  factory SpecialistAvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return SpecialistAvailabilitySlot(
      id: json['id'] as String? ?? '',
      specialistId: json['specialistId'] as String? ?? '',
      startsAt: json['startsAt'] as String? ?? '',
      endsAt: json['endsAt'] as String? ?? '',
      mode: json['mode'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? false,
    );
  }
}

class UpdateBookingInput {
  UpdateBookingInput({
    this.scheduledAt,
    this.mode,
    this.notes,
    this.status,
  });

  final String? scheduledAt;
  final String? mode;
  final String? notes;
  final String? status;

  Map<String, dynamic> toJson() {
    return {
      if (scheduledAt != null) 'scheduledAt': scheduledAt,
      if (mode != null) 'mode': mode,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
    };
  }
}
