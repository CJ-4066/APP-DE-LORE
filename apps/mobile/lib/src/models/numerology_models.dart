class NumerologyRequestInput {
  NumerologyRequestInput({
    required this.birthName,
    required this.currentName,
    required this.birthDate,
    this.targetDate,
  });

  final String birthName;
  final String currentName;
  final String birthDate;
  final String? targetDate;

  Map<String, dynamic> toJson() {
    return {
      'birthName': birthName,
      'currentName': currentName,
      'birthDate': birthDate,
      if (targetDate != null && targetDate!.isNotEmpty) 'targetDate': targetDate,
    };
  }
}

class NumerologyGuideData {
  NumerologyGuideData({
    required this.version,
    required this.system,
    required this.concepts,
    required this.references,
  });

  final String version;
  final String system;
  final List<NumerologyConcept> concepts;
  final List<NumerologyReference> references;

  factory NumerologyGuideData.fromJson(Map<String, dynamic> json) {
    return NumerologyGuideData(
      version: json['version'] as String? ?? '',
      system: json['system'] as String? ?? '',
      concepts: _mapList(json['concepts'], NumerologyConcept.fromJson),
      references: _mapList(json['references'], NumerologyReference.fromJson),
    );
  }
}

class NumerologyProfileData {
  NumerologyProfileData({
    required this.version,
    required this.system,
    required this.input,
    required this.coreNumbers,
    required this.cycles,
    required this.patterns,
    required this.narrative,
    required this.references,
  });

  final String version;
  final String system;
  final NumerologyInputData input;
  final NumerologyCoreNumbers coreNumbers;
  final NumerologyCycles cycles;
  final NumerologyPatterns patterns;
  final NumerologyNarrative narrative;
  final List<NumerologyReference> references;

  factory NumerologyProfileData.fromJson(Map<String, dynamic> json) {
    return NumerologyProfileData(
      version: json['version'] as String? ?? '',
      system: json['system'] as String? ?? '',
      input: NumerologyInputData.fromJson(json['input'] as Map<String, dynamic>),
      coreNumbers: NumerologyCoreNumbers.fromJson(
        json['coreNumbers'] as Map<String, dynamic>,
      ),
      cycles: NumerologyCycles.fromJson(json['cycles'] as Map<String, dynamic>),
      patterns: NumerologyPatterns.fromJson(
        json['patterns'] as Map<String, dynamic>,
      ),
      narrative: NumerologyNarrative.fromJson(
        json['narrative'] as Map<String, dynamic>,
      ),
      references: _mapList(json['references'], NumerologyReference.fromJson),
    );
  }
}

class NumerologyInputData {
  NumerologyInputData({
    required this.birthName,
    required this.currentName,
    required this.birthDate,
    required this.targetDate,
  });

  final String birthName;
  final String currentName;
  final String birthDate;
  final String targetDate;

  factory NumerologyInputData.fromJson(Map<String, dynamic> json) {
    return NumerologyInputData(
      birthName: json['birthName'] as String? ?? '',
      currentName: json['currentName'] as String? ?? '',
      birthDate: json['birthDate'] as String? ?? '',
      targetDate: json['targetDate'] as String? ?? '',
    );
  }
}

class NumerologyCoreNumbers {
  NumerologyCoreNumbers({
    required this.lifePath,
    required this.expression,
    required this.soulUrge,
    required this.personality,
    required this.birthday,
    required this.maturity,
    required this.attitude,
    required this.currentNameExpression,
    required this.currentNameSoulUrge,
    required this.currentNamePersonality,
  });

  final NumerologyCard lifePath;
  final NumerologyCard expression;
  final NumerologyCard soulUrge;
  final NumerologyCard personality;
  final NumerologyCard birthday;
  final NumerologyCard maturity;
  final NumerologyCard attitude;
  final NumerologyCard? currentNameExpression;
  final NumerologyCard? currentNameSoulUrge;
  final NumerologyCard? currentNamePersonality;

  factory NumerologyCoreNumbers.fromJson(Map<String, dynamic> json) {
    NumerologyCard? readOptional(String key) {
      final value = json[key];
      if (value is! Map<String, dynamic>) {
        return null;
      }

      return NumerologyCard.fromJson(value);
    }

    return NumerologyCoreNumbers(
      lifePath: NumerologyCard.fromJson(
        json['lifePath'] as Map<String, dynamic>,
      ),
      expression: NumerologyCard.fromJson(
        json['expression'] as Map<String, dynamic>,
      ),
      soulUrge: NumerologyCard.fromJson(
        json['soulUrge'] as Map<String, dynamic>,
      ),
      personality: NumerologyCard.fromJson(
        json['personality'] as Map<String, dynamic>,
      ),
      birthday: NumerologyCard.fromJson(
        json['birthday'] as Map<String, dynamic>,
      ),
      maturity: NumerologyCard.fromJson(
        json['maturity'] as Map<String, dynamic>,
      ),
      attitude: NumerologyCard.fromJson(
        json['attitude'] as Map<String, dynamic>,
      ),
      currentNameExpression: readOptional('currentNameExpression'),
      currentNameSoulUrge: readOptional('currentNameSoulUrge'),
      currentNamePersonality: readOptional('currentNamePersonality'),
    );
  }
}

class NumerologyCycles {
  NumerologyCycles({
    required this.universalYear,
    required this.personalYear,
    required this.personalMonth,
    required this.personalDay,
    required this.pinnacleCycles,
    required this.challengeCycles,
  });

  final NumerologyCard universalYear;
  final NumerologyCard personalYear;
  final NumerologyCard personalMonth;
  final NumerologyCard personalDay;
  final List<NumerologyCycleWindow> pinnacleCycles;
  final List<NumerologyCycleWindow> challengeCycles;

  factory NumerologyCycles.fromJson(Map<String, dynamic> json) {
    return NumerologyCycles(
      universalYear: NumerologyCard.fromJson(
        json['universalYear'] as Map<String, dynamic>,
      ),
      personalYear: NumerologyCard.fromJson(
        json['personalYear'] as Map<String, dynamic>,
      ),
      personalMonth: NumerologyCard.fromJson(
        json['personalMonth'] as Map<String, dynamic>,
      ),
      personalDay: NumerologyCard.fromJson(
        json['personalDay'] as Map<String, dynamic>,
      ),
      pinnacleCycles: _mapList(
        json['pinnacleCycles'],
        NumerologyCycleWindow.fromJson,
      ),
      challengeCycles: _mapList(
        json['challengeCycles'],
        NumerologyCycleWindow.fromJson,
      ),
    );
  }
}

class NumerologyPatterns {
  NumerologyPatterns({
    required this.dominantNumbers,
    required this.hiddenPassion,
    required this.karmicLessons,
    required this.cornerstone,
    required this.capstone,
    required this.firstVowel,
  });

  final List<NumerologyDominantNumber> dominantNumbers;
  final NumerologyCard? hiddenPassion;
  final List<NumerologyCard> karmicLessons;
  final NumerologyLetterTone cornerstone;
  final NumerologyLetterTone capstone;
  final NumerologyLetterTone? firstVowel;

  factory NumerologyPatterns.fromJson(Map<String, dynamic> json) {
    final hiddenPassionJson = json['hiddenPassion'];
    final firstVowelJson = json['firstVowel'];

    return NumerologyPatterns(
      dominantNumbers: _mapList(
        json['dominantNumbers'],
        NumerologyDominantNumber.fromJson,
      ),
      hiddenPassion: hiddenPassionJson is Map<String, dynamic>
          ? NumerologyCard.fromJson(hiddenPassionJson)
          : null,
      karmicLessons: _mapList(json['karmicLessons'], NumerologyCard.fromJson),
      cornerstone: NumerologyLetterTone.fromJson(
        json['cornerstone'] as Map<String, dynamic>,
      ),
      capstone: NumerologyLetterTone.fromJson(
        json['capstone'] as Map<String, dynamic>,
      ),
      firstVowel: firstVowelJson is Map<String, dynamic>
          ? NumerologyLetterTone.fromJson(firstVowelJson)
          : null,
    );
  }
}

class NumerologyNarrative {
  NumerologyNarrative({
    required this.summary,
    required this.vocation,
    required this.relationships,
    required this.timing,
  });

  final String summary;
  final String vocation;
  final String relationships;
  final String timing;

  factory NumerologyNarrative.fromJson(Map<String, dynamic> json) {
    return NumerologyNarrative(
      summary: json['summary'] as String? ?? '',
      vocation: json['vocation'] as String? ?? '',
      relationships: json['relationships'] as String? ?? '',
      timing: json['timing'] as String? ?? '',
    );
  }
}

class NumerologyConcept {
  NumerologyConcept({
    required this.id,
    required this.title,
    required this.summary,
  });

  final String id;
  final String title;
  final String summary;

  factory NumerologyConcept.fromJson(Map<String, dynamic> json) {
    return NumerologyConcept(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
    );
  }
}

class NumerologyReference {
  NumerologyReference({
    required this.label,
    required this.url,
    required this.note,
  });

  final String label;
  final String url;
  final String note;

  factory NumerologyReference.fromJson(Map<String, dynamic> json) {
    return NumerologyReference(
      label: json['label'] as String? ?? '',
      url: json['url'] as String? ?? '',
      note: json['note'] as String? ?? '',
    );
  }
}

class NumerologyCard {
  NumerologyCard({
    required this.title,
    required this.value,
    required this.reduced,
    required this.rawTotal,
    required this.displayValue,
    required this.isMaster,
    required this.isKarmicDebt,
    required this.archetype,
    required this.essence,
    required this.gifts,
    required this.shadows,
    required this.guidance,
  });

  final String title;
  final int value;
  final int reduced;
  final int rawTotal;
  final String displayValue;
  final bool isMaster;
  final bool isKarmicDebt;
  final String archetype;
  final String essence;
  final List<String> gifts;
  final List<String> shadows;
  final String guidance;

  factory NumerologyCard.fromJson(Map<String, dynamic> json) {
    return NumerologyCard(
      title: json['title'] as String? ?? '',
      value: json['value'] as int? ?? 0,
      reduced: json['reduced'] as int? ?? 0,
      rawTotal: json['rawTotal'] as int? ?? 0,
      displayValue: json['displayValue'] as String? ?? '',
      isMaster: json['isMaster'] as bool? ?? false,
      isKarmicDebt: json['isKarmicDebt'] as bool? ?? false,
      archetype: json['archetype'] as String? ?? '',
      essence: json['essence'] as String? ?? '',
      gifts: _stringList(json['gifts']),
      shadows: _stringList(json['shadows']),
      guidance: json['guidance'] as String? ?? '',
    );
  }
}

class NumerologyCycleWindow {
  NumerologyCycleWindow({
    required this.label,
    required this.ageRange,
    required this.focus,
    required this.number,
  });

  final String label;
  final String ageRange;
  final String focus;
  final NumerologyCard number;

  factory NumerologyCycleWindow.fromJson(Map<String, dynamic> json) {
    return NumerologyCycleWindow(
      label: json['label'] as String? ?? '',
      ageRange: json['ageRange'] as String? ?? '',
      focus: json['focus'] as String? ?? '',
      number: NumerologyCard.fromJson(json['number'] as Map<String, dynamic>),
    );
  }
}

class NumerologyDominantNumber {
  NumerologyDominantNumber({
    required this.value,
    required this.count,
    required this.archetype,
  });

  final int value;
  final int count;
  final String archetype;

  factory NumerologyDominantNumber.fromJson(Map<String, dynamic> json) {
    return NumerologyDominantNumber(
      value: json['value'] as int? ?? 0,
      count: json['count'] as int? ?? 0,
      archetype: json['archetype'] as String? ?? '',
    );
  }
}

class NumerologyLetterTone {
  NumerologyLetterTone({
    required this.letter,
    required this.value,
    required this.meaning,
  });

  final String letter;
  final int value;
  final String meaning;

  factory NumerologyLetterTone.fromJson(Map<String, dynamic> json) {
    return NumerologyLetterTone(
      letter: json['letter'] as String? ?? '',
      value: json['value'] as int? ?? 0,
      meaning: json['meaning'] as String? ?? '',
    );
  }
}

List<T> _mapList<T>(
  dynamic rawValue,
  T Function(Map<String, dynamic> json) mapper,
) {
  final items = rawValue as List<dynamic>? ?? const [];
  return items
      .whereType<Map<String, dynamic>>()
      .map(mapper)
      .toList(growable: false);
}

List<String> _stringList(dynamic rawValue) {
  final items = rawValue as List<dynamic>? ?? const [];
  return items
      .whereType<String>()
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
