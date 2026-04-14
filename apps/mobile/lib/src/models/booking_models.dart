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
