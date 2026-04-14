import 'app_models.dart';

class PhoneAuthStartResult {
  PhoneAuthStartResult({
    required this.phoneNumber,
    required this.expiresInSeconds,
    required this.resendInSeconds,
    required this.debugCode,
  });

  final String phoneNumber;
  final int expiresInSeconds;
  final int resendInSeconds;
  final String debugCode;

  factory PhoneAuthStartResult.fromJson(Map<String, dynamic> json) {
    return PhoneAuthStartResult(
      phoneNumber: json['phoneNumber'] as String? ?? '',
      expiresInSeconds: json['expiresInSeconds'] as int? ?? 0,
      resendInSeconds: json['resendInSeconds'] as int? ?? 0,
      debugCode: json['debugCode'] as String? ?? '',
    );
  }
}

class PhoneAuthSession {
  PhoneAuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.phoneNumber,
    required this.profileCompleted,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final String phoneNumber;
  final bool profileCompleted;
  final UserProfile user;

  factory PhoneAuthSession.fromJson(Map<String, dynamic> json) {
    return PhoneAuthSession(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      profileCompleted: json['profileCompleted'] as bool? ?? false,
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'phoneNumber': phoneNumber,
      'profileCompleted': profileCompleted,
      'user': user.toJson(),
    };
  }
}

class CompletePhoneProfileInput {
  CompletePhoneProfileInput({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.city,
    required this.country,
    required this.birthDate,
    required this.birthTime,
    this.birthTimeUnknown = false,
    this.subjectName = '',
    this.state = '',
    this.timeZoneId = '',
    required this.utcOffset,
    required this.latitude,
    required this.longitude,
    this.location = '',
    this.zodiacSign = '',
    this.accountType = 'client',
  });

  final String firstName;
  final String lastName;
  final String email;
  final String city;
  final String country;
  final String birthDate;
  final String birthTime;
  final bool birthTimeUnknown;
  final String subjectName;
  final String state;
  final String timeZoneId;
  final String utcOffset;
  final double latitude;
  final double longitude;
  final String location;
  final String zodiacSign;
  final String accountType;

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'city': city,
      'country': country,
      'birthDate': birthDate,
      'birthTime': birthTime,
      'birthTimeUnknown': birthTimeUnknown,
      'subjectName': subjectName,
      'state': state,
      'timeZoneId': timeZoneId,
      'utcOffset': utcOffset,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'zodiacSign': zodiacSign,
      'accountType': accountType,
    };
  }
}
