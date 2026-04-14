class UpdateProfileInput {
  UpdateProfileInput({
    this.firstName,
    this.lastName,
    this.nickname,
    this.email,
    this.location,
    this.zodiacSign,
    this.accountType,
    this.subjectName,
    this.birthDate,
    this.birthTime,
    this.birthTimeUnknown,
    this.city,
    this.state,
    this.country,
    this.timeZoneId,
    this.utcOffset,
    this.latitude,
    this.longitude,
    this.avatarUrl,
  });

  final String? firstName;
  final String? lastName;
  final String? nickname;
  final String? email;
  final String? location;
  final String? zodiacSign;
  final String? accountType;
  final String? subjectName;
  final String? birthDate;
  final String? birthTime;
  final bool? birthTimeUnknown;
  final String? city;
  final String? state;
  final String? country;
  final String? timeZoneId;
  final String? utcOffset;
  final double? latitude;
  final double? longitude;
  final String? avatarUrl;

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{};
    final natalChart = <String, dynamic>{};

    if (firstName != null) {
      payload['firstName'] = firstName;
    }
    if (lastName != null) {
      payload['lastName'] = lastName;
    }
    if (nickname != null) {
      payload['nickname'] = nickname;
    }
    if (email != null) {
      payload['email'] = email;
    }
    if (avatarUrl != null) {
      payload['avatarUrl'] = avatarUrl;
    }
    if (location != null) {
      payload['location'] = location;
    }
    if (zodiacSign != null) {
      payload['zodiacSign'] = zodiacSign;
    }
    if (accountType != null) {
      payload['accountType'] = accountType;
    }
    if (birthDate != null) {
      natalChart['birthDate'] = birthDate;
    }
    if (birthTime != null) {
      natalChart['birthTime'] = birthTime;
    }
    if (birthTimeUnknown != null) {
      natalChart['birthTimeUnknown'] = birthTimeUnknown;
    }
    if (subjectName != null) {
      natalChart['subjectName'] = subjectName;
    }
    if (city != null) {
      natalChart['city'] = city;
    }
    if (state != null) {
      natalChart['state'] = state;
    }
    if (country != null) {
      natalChart['country'] = country;
    }
    if (timeZoneId != null) {
      natalChart['timeZoneId'] = timeZoneId;
    }
    if (utcOffset != null) {
      natalChart['utcOffset'] = utcOffset;
    }
    if (latitude != null) {
      natalChart['latitude'] = latitude;
    }
    if (longitude != null) {
      natalChart['longitude'] = longitude;
    }

    if (natalChart.isNotEmpty) {
      payload['natalChart'] = natalChart;
    }

    return payload;
  }
}
