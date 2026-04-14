class AstroRequestInput {
  AstroRequestInput({
    this.subjectName,
    required this.birthDate,
    required this.birthTime,
    this.birthTimeUnknown = false,
    required this.utcOffset,
    this.timeZoneId,
    this.selectedPlanets = const [
      'sun',
      'moon',
      'mercury',
      'venus',
      'mars',
      'jupiter',
      'saturn',
      'uranus',
      'neptune',
      'pluto',
    ],
    this.nodeType = 'true',
    this.lilithType = 'mean',
    this.arabicPartsMode = 'sect',
    this.technicalPoints = const [],
    required this.latitude,
    required this.longitude,
    required this.locationLabel,
    required this.houseSystem,
    this.targetDate,
    this.from,
  });

  final String? subjectName;
  final String birthDate;
  final String birthTime;
  final bool birthTimeUnknown;
  final String utcOffset;
  final String? timeZoneId;
  final List<String> selectedPlanets;
  final String nodeType;
  final String lilithType;
  final String arabicPartsMode;
  final List<String> technicalPoints;
  final double latitude;
  final double longitude;
  final String locationLabel;
  final String houseSystem;
  final String? targetDate;
  final String? from;

  Map<String, dynamic> toJson() {
    return {
      'birthDate': birthDate,
      'birthTime': birthTime,
      'birthTimeUnknown': birthTimeUnknown,
      'utcOffset': utcOffset,
      if (timeZoneId != null && timeZoneId!.isNotEmpty)
        'timeZoneId': timeZoneId,
      if (selectedPlanets.isNotEmpty) 'selectedPlanets': selectedPlanets,
      'nodeType': nodeType,
      'lilithType': lilithType,
      'arabicPartsMode': arabicPartsMode,
      if (technicalPoints.isNotEmpty) 'technicalPoints': technicalPoints,
      'latitude': latitude,
      'longitude': longitude,
      'locationLabel': locationLabel,
      'houseSystem': houseSystem,
      if (subjectName != null && subjectName!.isNotEmpty)
        'subjectName': subjectName,
      if (targetDate != null) 'targetDate': targetDate,
      if (from != null) 'from': from,
    };
  }
}

class AstroOverviewData {
  AstroOverviewData({
    required this.natalChart,
    required this.transits,
    required this.returns,
    required this.events,
  });

  final AstroNatalChartResult natalChart;
  final AstroTransitsResult transits;
  final AstroReturnsResult returns;
  final AstroEventsResult events;
}

class AstroUtcOffsetResult {
  AstroUtcOffsetResult({
    required this.timeZoneId,
    required this.utcOffset,
    required this.birthDate,
    required this.birthTime,
    required this.timeAccuracy,
  });

  final String timeZoneId;
  final String utcOffset;
  final String birthDate;
  final String birthTime;
  final String timeAccuracy;

  factory AstroUtcOffsetResult.fromJson(Map<String, dynamic> json) {
    return AstroUtcOffsetResult(
      timeZoneId: json['timeZoneId'] as String? ?? '',
      utcOffset: json['utcOffset'] as String? ?? '',
      birthDate: json['birthDate'] as String? ?? '',
      birthTime: json['birthTime'] as String? ?? '',
      timeAccuracy: json['timeAccuracy'] as String? ?? '',
    );
  }
}

class AstroNatalChartResult {
  AstroNatalChartResult({
    required this.meta,
    required this.bigThree,
    required this.angles,
    required this.planets,
    required this.points,
    required this.houses,
    required this.aspects,
    required this.summary,
    required this.interpretation,
  });

  final AstroMeta meta;
  final AstroBigThree bigThree;
  final AstroAngles angles;
  final List<AstroPlacement> planets;
  final List<AstroPlacement> points;
  final List<AstroHouse> houses;
  final List<AstroAspect> aspects;
  final AstroSummary summary;
  final List<String> interpretation;

  factory AstroNatalChartResult.fromJson(Map<String, dynamic> json) {
    return AstroNatalChartResult(
      meta: AstroMeta.fromJson(json['meta'] as Map<String, dynamic>),
      bigThree:
          AstroBigThree.fromJson(json['bigThree'] as Map<String, dynamic>),
      angles: AstroAngles.fromJson(json['angles'] as Map<String, dynamic>),
      planets: _mapList(json['planets'], AstroPlacement.fromJson),
      points: _mapList(json['points'], AstroPlacement.fromJson),
      houses: _mapList(json['houses'], AstroHouse.fromJson),
      aspects: _mapList(json['aspects'], AstroAspect.fromJson),
      summary: AstroSummary.fromJson(json['summary'] as Map<String, dynamic>),
      interpretation: _stringList(json['interpretation']),
    );
  }
}

class AstroMeta {
  AstroMeta({
    required this.engine,
    required this.version,
    required this.computedAt,
    required this.birthDateTimeUtc,
    required this.birthDate,
    required this.birthTime,
    required this.timeAccuracy,
    required this.subjectName,
    required this.utcOffset,
    required this.timeZoneId,
    required this.selectedPlanets,
    required this.nodeType,
    required this.lilithType,
    required this.arabicPartsMode,
    required this.technicalPoints,
    required this.computedTechnicalPoints,
    required this.unsupportedTechnicalPoints,
    required this.ephemerisSource,
    required this.locationLabel,
    required this.coordinates,
    required this.houseSystem,
  });

  final String engine;
  final String version;
  final String computedAt;
  final String birthDateTimeUtc;
  final String birthDate;
  final String birthTime;
  final String timeAccuracy;
  final String subjectName;
  final String utcOffset;
  final String timeZoneId;
  final List<String> selectedPlanets;
  final String nodeType;
  final String lilithType;
  final String arabicPartsMode;
  final List<String> technicalPoints;
  final List<String> computedTechnicalPoints;
  final List<String> unsupportedTechnicalPoints;
  final String ephemerisSource;
  final String locationLabel;
  final AstroCoordinates coordinates;
  final String houseSystem;

  factory AstroMeta.fromJson(Map<String, dynamic> json) {
    return AstroMeta(
      engine: json['engine'] as String? ?? '',
      version: json['version'] as String? ?? '',
      computedAt: json['computedAt'] as String? ?? '',
      birthDateTimeUtc: json['birthDateTimeUtc'] as String? ?? '',
      birthDate: json['birthDate'] as String? ?? '',
      birthTime: json['birthTime'] as String? ?? '',
      timeAccuracy: json['timeAccuracy'] as String? ?? '',
      subjectName: json['subjectName'] as String? ?? '',
      utcOffset: json['utcOffset'] as String? ?? '',
      timeZoneId: json['timeZoneId'] as String? ?? '',
      selectedPlanets: _stringList(json['selectedPlanets']),
      nodeType: json['nodeType'] as String? ?? 'true',
      lilithType: json['lilithType'] as String? ?? 'mean',
      arabicPartsMode: json['arabicPartsMode'] as String? ?? 'sect',
      technicalPoints: _stringList(json['technicalPoints']),
      computedTechnicalPoints: _stringList(json['computedTechnicalPoints']),
      unsupportedTechnicalPoints:
          _stringList(json['unsupportedTechnicalPoints']),
      ephemerisSource: json['ephemerisSource'] as String? ?? '',
      locationLabel: json['locationLabel'] as String? ?? '',
      coordinates: AstroCoordinates.fromJson(
        json['coordinates'] as Map<String, dynamic>? ?? const {},
      ),
      houseSystem: json['houseSystem'] as String? ?? '',
    );
  }
}

class AstroCoordinates {
  AstroCoordinates({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  factory AstroCoordinates.fromJson(Map<String, dynamic> json) {
    return AstroCoordinates(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }
}

class AstroBigThree {
  AstroBigThree({
    required this.sun,
    required this.moon,
    required this.ascendant,
  });

  final AstroPlacement sun;
  final AstroPlacement moon;
  final AstroAnglePoint ascendant;

  factory AstroBigThree.fromJson(Map<String, dynamic> json) {
    return AstroBigThree(
      sun: AstroPlacement.fromJson(json['sun'] as Map<String, dynamic>),
      moon: AstroPlacement.fromJson(json['moon'] as Map<String, dynamic>),
      ascendant: AstroAnglePoint.fromJson(
        json['ascendant'] as Map<String, dynamic>,
      ),
    );
  }
}

class AstroAngles {
  AstroAngles({
    required this.ascendant,
    required this.midheaven,
  });

  final AstroAnglePoint ascendant;
  final AstroAnglePoint midheaven;

  factory AstroAngles.fromJson(Map<String, dynamic> json) {
    return AstroAngles(
      ascendant: AstroAnglePoint.fromJson(
        json['ascendant'] as Map<String, dynamic>,
      ),
      midheaven: AstroAnglePoint.fromJson(
        json['midheaven'] as Map<String, dynamic>,
      ),
    );
  }
}

class AstroPlacement {
  AstroPlacement({
    required this.key,
    required this.label,
    required this.longitude,
    required this.latitude,
    required this.sign,
    required this.signIndex,
    required this.degreeInSign,
    required this.degreeFormatted,
    required this.house,
    required this.retrograde,
  });

  final String key;
  final String label;
  final double longitude;
  final double latitude;
  final String sign;
  final int signIndex;
  final double degreeInSign;
  final String degreeFormatted;
  final int house;
  final bool retrograde;

  factory AstroPlacement.fromJson(Map<String, dynamic> json) {
    return AstroPlacement(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      sign: json['sign'] as String? ?? '',
      signIndex: json['signIndex'] as int? ?? 0,
      degreeInSign: (json['degreeInSign'] as num?)?.toDouble() ?? 0,
      degreeFormatted: json['degreeFormatted'] as String? ?? '',
      house: json['house'] as int? ?? 0,
      retrograde: json['retrograde'] as bool? ?? false,
    );
  }
}

class AstroAnglePoint {
  AstroAnglePoint({
    required this.key,
    required this.label,
    required this.longitude,
    required this.sign,
    required this.signIndex,
    required this.degreeInSign,
    required this.degreeFormatted,
    required this.house,
    required this.ruler,
  });

  final String key;
  final String label;
  final double longitude;
  final String sign;
  final int signIndex;
  final double degreeInSign;
  final String degreeFormatted;
  final int house;
  final String ruler;

  factory AstroAnglePoint.fromJson(Map<String, dynamic> json) {
    return AstroAnglePoint(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      sign: json['sign'] as String? ?? '',
      signIndex: json['signIndex'] as int? ?? 0,
      degreeInSign: (json['degreeInSign'] as num?)?.toDouble() ?? 0,
      degreeFormatted: json['degreeFormatted'] as String? ?? '',
      house: json['house'] as int? ?? 0,
      ruler: json['ruler'] as String? ?? '',
    );
  }
}

class AstroHouse {
  AstroHouse({
    required this.number,
    required this.sign,
    required this.signIndex,
    required this.cuspLongitude,
    required this.cuspDegreeFormatted,
    required this.ruler,
  });

  final int number;
  final String sign;
  final int signIndex;
  final double cuspLongitude;
  final String cuspDegreeFormatted;
  final String ruler;

  factory AstroHouse.fromJson(Map<String, dynamic> json) {
    return AstroHouse(
      number: json['number'] as int? ?? 0,
      sign: json['sign'] as String? ?? '',
      signIndex: json['signIndex'] as int? ?? 0,
      cuspLongitude: (json['cuspLongitude'] as num?)?.toDouble() ?? 0,
      cuspDegreeFormatted: json['cuspDegreeFormatted'] as String? ?? '',
      ruler: json['ruler'] as String? ?? '',
    );
  }
}

class AstroAspect {
  AstroAspect({
    required this.type,
    required this.exactAngle,
    required this.orb,
    required this.maxOrb,
    required this.precision,
    required this.left,
    required this.right,
  });

  final String type;
  final double exactAngle;
  final double orb;
  final double maxOrb;
  final String precision;
  final String left;
  final String right;

  factory AstroAspect.fromJson(Map<String, dynamic> json) {
    return AstroAspect(
      type: json['type'] as String? ?? '',
      exactAngle: (json['exactAngle'] as num?)?.toDouble() ?? 0,
      orb: (json['orb'] as num?)?.toDouble() ?? 0,
      maxOrb: (json['maxOrb'] as num?)?.toDouble() ?? 0,
      precision: json['precision'] as String? ?? '',
      left: json['left'] as String? ?? '',
      right: json['right'] as String? ?? '',
    );
  }
}

class AstroSummary {
  AstroSummary({
    required this.chartRuler,
    required this.dominantElement,
    required this.dominantQuality,
    required this.solarSign,
    required this.lunarSign,
    required this.ascendantSign,
  });

  final String chartRuler;
  final String dominantElement;
  final String dominantQuality;
  final String solarSign;
  final String lunarSign;
  final String ascendantSign;

  factory AstroSummary.fromJson(Map<String, dynamic> json) {
    return AstroSummary(
      chartRuler: json['chartRuler'] as String? ?? '',
      dominantElement: json['dominantElement'] as String? ?? '',
      dominantQuality: json['dominantQuality'] as String? ?? '',
      solarSign: json['solarSign'] as String? ?? '',
      lunarSign: json['lunarSign'] as String? ?? '',
      ascendantSign: json['ascendantSign'] as String? ?? '',
    );
  }
}

class AstroTransitsResult {
  AstroTransitsResult({
    required this.targetDateUtc,
    required this.transits,
    required this.aspectsToNatal,
    required this.highlights,
    this.activeWindow,
  });

  final String targetDateUtc;
  final List<AstroPlacement> transits;
  final List<AstroAspect> aspectsToNatal;
  final List<String> highlights;
  final AstroTransitWindow? activeWindow;

  factory AstroTransitsResult.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    return AstroTransitsResult(
      targetDateUtc: meta['targetDateUtc'] as String? ?? '',
      transits: _mapList(json['transits'], AstroPlacement.fromJson),
      aspectsToNatal: _mapList(
        json['aspectsToNatal'],
        AstroAspect.fromJson,
      ),
      highlights: _stringList(json['highlights']),
      activeWindow: json['activeWindow'] == null
          ? null
          : AstroTransitWindow.fromJson(
              json['activeWindow'] as Map<String, dynamic>,
            ),
    );
  }
}

class AstroTransitWindow {
  AstroTransitWindow({
    required this.transitLabel,
    required this.natalLabel,
    required this.type,
    required this.startsAt,
    required this.endsAt,
  });

  final String transitLabel;
  final String natalLabel;
  final String type;
  final String startsAt;
  final String endsAt;

  factory AstroTransitWindow.fromJson(Map<String, dynamic> json) {
    return AstroTransitWindow(
      transitLabel: json['transitLabel'] as String? ?? '',
      natalLabel: json['natalLabel'] as String? ?? '',
      type: json['type'] as String? ?? '',
      startsAt: json['startsAt'] as String? ?? '',
      endsAt: json['endsAt'] as String? ?? '',
    );
  }
}

class AstroReturnsResult {
  AstroReturnsResult({
    required this.solarReturn,
    required this.lunarReturn,
  });

  final AstroReturnItem solarReturn;
  final AstroReturnItem lunarReturn;

  factory AstroReturnsResult.fromJson(Map<String, dynamic> json) {
    return AstroReturnsResult(
      solarReturn: AstroReturnItem.fromJson(
        json['solarReturn'] as Map<String, dynamic>,
      ),
      lunarReturn: AstroReturnItem.fromJson(
        json['lunarReturn'] as Map<String, dynamic>,
      ),
    );
  }
}

class AstroReturnItem {
  AstroReturnItem({
    required this.startsAt,
    required this.degree,
  });

  final String startsAt;
  final String degree;

  factory AstroReturnItem.fromJson(Map<String, dynamic> json) {
    return AstroReturnItem(
      startsAt: json['startsAt'] as String? ?? '',
      degree: (json['sunDegree'] ?? json['moonDegree']) as String? ?? '',
    );
  }
}

class AstroEventsResult {
  AstroEventsResult({
    required this.moonPhases,
    required this.eclipses,
  });

  final List<AstroEventItem> moonPhases;
  final List<AstroEventItem> eclipses;

  factory AstroEventsResult.fromJson(Map<String, dynamic> json) {
    return AstroEventsResult(
      moonPhases: _mapList(json['moonPhases'], AstroEventItem.fromJson),
      eclipses: _mapList(json['eclipses'], AstroEventItem.fromJson),
    );
  }
}

class AstroEventItem {
  AstroEventItem({
    required this.type,
    required this.label,
    required this.kind,
    required this.startsAt,
    required this.visibility,
    this.sourceLabel = '',
    this.sourceUrl = '',
  });

  final String type;
  final String label;
  final String kind;
  final String startsAt;
  final String visibility;
  final String sourceLabel;
  final String sourceUrl;

  factory AstroEventItem.fromJson(Map<String, dynamic> json) {
    return AstroEventItem(
      type: json['type'] as String? ?? '',
      label: json['label'] as String? ?? '',
      kind: json['kind'] as String? ?? '',
      startsAt: json['startsAt'] as String? ?? '',
      visibility: json['visibility'] as String? ?? '',
      sourceLabel: json['sourceLabel'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String? ?? '',
    );
  }
}

List<T> _mapList<T>(
  Object? raw,
  T Function(Map<String, dynamic> json) factory,
) {
  final list = raw as List<dynamic>? ?? const [];
  return list.map((item) => factory(item as Map<String, dynamic>)).toList();
}

List<String> _stringList(Object? raw) {
  final list = raw as List<dynamic>? ?? const [];
  return list.map((item) => item.toString()).toList();
}
