import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/mystic_ui.dart';
import '../../core/widgets/specialist_rating_badge.dart';
import '../../models/app_models.dart';
import '../../models/numerology_models.dart';

const _numerologyInk = Color(0xFF182127);
const _numerologyAccent = Color(0xFFB96C3D);
const _numerologyAccentAlt = Color(0xFF5C7A72);
const _numerologyAccentSoft = Color(0xFFF4E7D3);
const _numerologyBorder = Color(0xFFE8DAC7);
const _numerologySurface = Colors.white;
const _numerologyPaper = Color(0xFFFFFAF4);

enum _NumerologyMenu {
  panorama,
  numeros,
  ciclos,
  especialistas,
  cursos,
}

class NumerologyScreen extends StatefulWidget {
  const NumerologyScreen({
    super.key,
    required this.data,
    required this.onRefresh,
    required this.onCreateBooking,
    required this.onLoadGuide,
    required this.onGenerate,
  });

  final AppBootstrap data;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String? initialServiceId) onCreateBooking;
  final Future<NumerologyGuideData> Function() onLoadGuide;
  final Future<NumerologyProfileData> Function(NumerologyRequestInput input)
      onGenerate;

  @override
  State<NumerologyScreen> createState() => _NumerologyScreenState();
}

class _NumerologyScreenState extends State<NumerologyScreen> {
  late final TextEditingController _birthNameController;
  late final TextEditingController _currentNameController;
  late final TextEditingController _birthDateController;

  _NumerologyMenu _selectedMenu = _NumerologyMenu.panorama;
  NumerologyGuideData? _guide;
  NumerologyProfileData? _profile;
  String? _errorMessage;
  bool _isGuideLoading = true;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    final fallbackName = [
      widget.data.user.firstName.trim(),
      widget.data.user.lastName.trim(),
    ].where((item) => item.isNotEmpty).join(' ');
    final birthName = widget.data.user.natalChart.subjectName.trim().isNotEmpty
        ? widget.data.user.natalChart.subjectName.trim()
        : fallbackName;

    _birthNameController = TextEditingController(text: birthName);
    _currentNameController = TextEditingController(
      text: widget.data.user.nickname.trim().isNotEmpty
          ? widget.data.user.nickname.trim()
          : birthName,
    );
    _birthDateController = TextEditingController(
      text: _formatBirthDateForForm(widget.data.user.natalChart.birthDate),
    );

    Future<void>.microtask(_bootstrapScreen);
  }

  Future<void> _bootstrapScreen() async {
    await _loadGuide();
    if (_birthNameController.text.trim().isNotEmpty &&
        _birthDateController.text.trim().isNotEmpty) {
      await _generateProfile();
    }
  }

  Future<void> _loadGuide() async {
    setState(() {
      _isGuideLoading = true;
    });

    try {
      final guide = await widget.onLoadGuide();
      if (!mounted) {
        return;
      }

      setState(() {
        _guide = guide;
        _isGuideLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isGuideLoading = false;
      });
    }
  }

  Future<void> _generateProfile() async {
    final birthName = _birthNameController.text.trim();
    final birthDate = _normalizeBirthDateForApi(_birthDateController.text);
    if (birthName.isEmpty || birthDate.isEmpty) {
      setState(() {
        _errorMessage =
            'Ingresa tu nombre completo al nacer y tu fecha de nacimiento.';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final profile = await widget.onGenerate(
        NumerologyRequestInput(
          birthName: birthName,
          currentName: _currentNameController.text.trim(),
          birthDate: birthDate,
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _profile = profile;
        _isGenerating = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isGenerating = false;
      });
    }
  }

  @override
  void dispose() {
    _birthNameController.dispose();
    _currentNameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textScale = mediaQuery.textScaler.scale(1).clamp(1.0, 1.02);
    const menuFlow = <MysticFlowOption>[
      MysticFlowOption(
        label: 'Panorama',
        caption: 'Resumen vivo del mapa',
        glyphKind: MysticGlyphKind.numerology,
      ),
      MysticFlowOption(
        label: 'Números',
        caption: 'Núcleos y patrones',
        glyphKind: MysticGlyphKind.generic,
      ),
      MysticFlowOption(
        label: 'Ciclos',
        caption: 'Timing y pináculos',
        glyphKind: MysticGlyphKind.ritual,
      ),
      MysticFlowOption(
        label: 'Especialistas',
        caption: 'Acompañamiento humano',
        glyphKind: MysticGlyphKind.specialist,
      ),
      MysticFlowOption(
        label: 'Cursos',
        caption: 'Rutas y práctica guiada',
        glyphKind: MysticGlyphKind.course,
      ),
    ];
    final numerologyServices = widget.data.services
        .where((service) => _foldAccents(service.category) == 'numerologia')
        .toList();
    final numerologySpecialistIds =
        numerologyServices.expand((service) => service.specialistIds).toSet();
    final numerologySpecialists = widget.data.specialists.where((specialist) {
      final hasNumerologySpecialty = specialist.specialties.any(
        (item) => _foldAccents(item).contains('numerologia'),
      );
      return hasNumerologySpecialty ||
          numerologySpecialistIds.contains(specialist.id);
    }).toList();
    final numerologyCourses = widget.data.courses
        .where((item) => _foldAccents(item.category).contains('numer'))
        .toList();

    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: TextScaler.linear(textScale)),
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          decoration: TextDecoration.none,
          color: _numerologyInk,
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF7EE),
                _numerologyPaper,
              ],
            ),
          ),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await widget.onRefresh();
                await _loadGuide();
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2A241E),
                          Color(0xFF6A4A36),
                          Color(0xFF5C7A72),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Numerología',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                decoration: TextDecoration.none,
                              ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Calcula tus números nucleares, tus ciclos y la lectura de tu nombre natal dentro del sistema pitagórico.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.45,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 16),
                        MysticFlowNavigator(
                          items: menuFlow,
                          selectedIndex:
                              _NumerologyMenu.values.indexOf(_selectedMenu),
                          onSelect: (index) {
                            setState(() {
                              _selectedMenu = _NumerologyMenu.values[index];
                            });
                          },
                          accent: _numerologyAccent,
                        ),
                        if (_profile != null) ...[
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _HeroMetricPill(
                                label: 'Sendero',
                                value:
                                    _profile!.coreNumbers.lifePath.displayValue,
                              ),
                              _HeroMetricPill(
                                label: 'Expresión',
                                value: _profile!
                                    .coreNumbers.expression.displayValue,
                              ),
                              _HeroMetricPill(
                                label: 'Año',
                                value:
                                    _profile!.cycles.personalYear.displayValue,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Generar perfil numerológico',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _birthNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo al nacer',
                            hintText: 'Ejemplo: Maria Fernanda Quispe',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _currentNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Nombre actual o social',
                            hintText: 'Opcional, para matiz actual',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _birthDateController,
                          keyboardType: TextInputType.datetime,
                          decoration: const InputDecoration(
                            labelText: 'Fecha de nacimiento',
                            hintText: 'DD-MM-YYYY',
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: _numerologyAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FilledButton.icon(
                              onPressed:
                                  _isGenerating ? null : _generateProfile,
                              icon: _isGenerating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.calculate_outlined),
                              label: Text(
                                _isGenerating
                                    ? 'Calculando...'
                                    : 'Generar numerología',
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: numerologyServices.isEmpty
                                  ? null
                                  : () => widget.onCreateBooking(
                                        numerologyServices.first.id,
                                      ),
                              icon: const Icon(Icons.calendar_month_outlined),
                              label: const Text('Agendar consulta'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_isGuideLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    MysticSlideSwitcher(
                      child: _NumerologySectionBody(
                        key: ValueKey(_selectedMenu),
                        selectedMenu: _selectedMenu,
                        guide: _guide,
                        profile: _profile,
                        numerologyServices: numerologyServices,
                        numerologySpecialists: numerologySpecialists,
                        numerologyCourses: numerologyCourses,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatBirthDateForForm(String rawValue) {
  final match = rawValue.trim().split('-');
  if (match.length != 3) {
    return rawValue;
  }

  if (match[0].length == 4) {
    return '${match[2]}-${match[1]}-${match[0]}';
  }

  return rawValue;
}

String _normalizeBirthDateForApi(String rawValue) {
  final value = rawValue.trim();
  final isoMatch = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  if (isoMatch.hasMatch(value)) {
    return value;
  }

  final dayFirstMatch = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$').firstMatch(value);
  if (dayFirstMatch == null) {
    return value;
  }

  return '${dayFirstMatch.group(3)}-${dayFirstMatch.group(2)}-${dayFirstMatch.group(1)}';
}

String _foldAccents(String value) {
  return value
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ñ', 'n');
}

class _NumerologySectionBody extends StatelessWidget {
  const _NumerologySectionBody({
    super.key,
    required this.selectedMenu,
    required this.guide,
    required this.profile,
    required this.numerologyServices,
    required this.numerologySpecialists,
    required this.numerologyCourses,
  });

  final _NumerologyMenu selectedMenu;
  final NumerologyGuideData? guide;
  final NumerologyProfileData? profile;
  final List<ServiceOffer> numerologyServices;
  final List<Specialist> numerologySpecialists;
  final List<Course> numerologyCourses;

  @override
  Widget build(BuildContext context) {
    switch (selectedMenu) {
      case _NumerologyMenu.panorama:
        final appliedInsights = profile == null
            ? const <_AppliedInsightData>[]
            : _buildAppliedInsights(profile!);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (profile != null) ...[
              _SectionCard(
                title: 'Mapa central',
                child: _NumerologyHeroMatrix(profile: profile!),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Lectura integrada',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile!.narrative.summary),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _StatCard(
                          title: 'Sendero',
                          value: profile!.coreNumbers.lifePath.displayValue,
                          description: profile!.coreNumbers.lifePath.archetype,
                          accent: _numerologyInk,
                        ),
                        _StatCard(
                          title: 'Expresión',
                          value: profile!.coreNumbers.expression.displayValue,
                          description:
                              profile!.coreNumbers.expression.archetype,
                          accent: _numerologyAccent,
                        ),
                        _StatCard(
                          title: 'Año personal',
                          value: profile!.cycles.personalYear.displayValue,
                          description: profile!.cycles.personalYear.archetype,
                          accent: _numerologyAccentAlt,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Aplicación real',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: appliedInsights
                      .map((item) => _AppliedInsightCard(item: item))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Alineación del nombre y del mapa',
                child: _AlignmentNarrative(profile: profile!),
              ),
              const SizedBox(height: 16),
            ],
            _SectionCard(
              title: 'Conceptos base',
              child: Column(
                children: guide?.concepts
                        .map(
                          (concept) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: _numerologyAccentSoft,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome_outlined,
                                    color: _numerologyInk,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        concept.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(concept.summary),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList() ??
                    const [],
              ),
            ),
            if (profile != null) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Enfoque profesional',
                child: Text(profile!.narrative.vocation),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Vinculos y deseo',
                child: Text(profile!.narrative.relationships),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Radar del momento',
                child: _TimingRadar(profile: profile!),
              ),
            ],
          ],
        );
      case _NumerologyMenu.numeros:
        if (profile == null) {
          return const _EmptyState(
            title: 'Genera tu perfil numerológico',
            subtitle:
                'Necesitamos tu nombre completo al nacer y tu fecha de nacimiento para desplegar los números nucleares.',
          );
        }

        final cards = [
          profile!.coreNumbers.lifePath,
          profile!.coreNumbers.expression,
          profile!.coreNumbers.soulUrge,
          profile!.coreNumbers.personality,
          profile!.coreNumbers.birthday,
          profile!.coreNumbers.maturity,
          profile!.coreNumbers.attitude,
          if (profile!.coreNumbers.currentNameExpression != null)
            profile!.coreNumbers.currentNameExpression!,
          if (profile!.coreNumbers.currentNameSoulUrge != null)
            profile!.coreNumbers.currentNameSoulUrge!,
          if (profile!.coreNumbers.currentNamePersonality != null)
            profile!.coreNumbers.currentNamePersonality!,
        ];

        return Column(
          children: [
            ...cards.map(
              (card) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _NumberCard(card: card),
              ),
            ),
            _SectionCard(
              title: 'Patrones del nombre',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile!.patterns.dominantNumbers
                        .map(
                          (item) => Chip(
                            label: Text(
                              '${item.value} · ${item.count} repeticiones',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile!.patterns.hiddenPassion == null
                        ? 'No aparece una pasión oculta dominante marcada.'
                        : 'Pasión oculta ${profile!.patterns.hiddenPassion!.displayValue}: ${profile!.patterns.hiddenPassion!.essence}',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Letra inicial ${profile!.patterns.cornerstone.letter}: ${profile!.patterns.cornerstone.meaning}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Letra final ${profile!.patterns.capstone.letter}: ${profile!.patterns.capstone.meaning}',
                  ),
                  if (profile!.patterns.firstVowel != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Primera vocal ${profile!.patterns.firstVowel!.letter}: ${profile!.patterns.firstVowel!.meaning}',
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      case _NumerologyMenu.ciclos:
        if (profile == null) {
          return const _EmptyState(
            title: 'Sin ciclos aún',
            subtitle:
                'Primero genera el perfil para desplegar año personal, pináculos y desafíos.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatCard(
                  title: 'Año personal',
                  value: profile!.cycles.personalYear.displayValue,
                  description: profile!.cycles.personalYear.archetype,
                  accent: _numerologyInk,
                ),
                _StatCard(
                  title: 'Mes personal',
                  value: profile!.cycles.personalMonth.displayValue,
                  description: profile!.cycles.personalMonth.archetype,
                  accent: _numerologyAccent,
                ),
                _StatCard(
                  title: 'Día personal',
                  value: profile!.cycles.personalDay.displayValue,
                  description: profile!.cycles.personalDay.archetype,
                  accent: _numerologyAccentAlt,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Timing del momento',
              child: Text(profile!.narrative.timing),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Pináculos',
              child: Column(
                children: profile!.cycles.pinnacleCycles
                    .map(
                      (cycle) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CycleTile(cycle: cycle),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Desafíos',
              child: Column(
                children: profile!.cycles.challengeCycles
                    .map(
                      (cycle) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CycleTile(cycle: cycle),
                      ),
                    )
                    .toList(),
              ),
            ),
            if (profile!.patterns.karmicLessons.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Lecciones kármicas',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile!.patterns.karmicLessons
                      .map(
                        (item) => Chip(
                          label:
                              Text('${item.displayValue} · ${item.guidance}'),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        );
      case _NumerologyMenu.especialistas:
        return Column(
          children: numerologySpecialists
              .map(
                (specialist) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SectionCard(
                    title: specialist.name,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(specialist.headline),
                        const SizedBox(height: 12),
                        Text(specialist.bio),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(
                              label: Text('${specialist.yearsExperience} años'),
                            ),
                            SpecialistRatingBadge(rating: specialist.rating),
                            ...specialist.specialties
                                .take(3)
                                .map((item) => Chip(label: Text(item))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Próxima disponibilidad: ${formatSchedule(specialist.nextAvailableAt)}',
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      case _NumerologyMenu.cursos:
        return Column(
          children: [
            ...numerologyCourses.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SectionCard(
                  title: item.title,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.category} · ${item.lessonCount} lecciones · ${item.estimatedHours.toStringAsFixed(1)} h',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.subtitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(item.description),
                    ],
                  ),
                ),
              ),
            ),
            if (guide != null)
              _SectionCard(
                title: 'Referencias online',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: guide!.references
                      .map(
                        (reference) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reference.label,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(reference.note),
                              const SizedBox(height: 4),
                              Text(
                                reference.url,
                                style: const TextStyle(
                                  color: _numerologyAccent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        );
    }
  }
}

class _HeroMetricPill extends StatelessWidget {
  const _HeroMetricPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumerologyHeroMatrix extends StatelessWidget {
  const _NumerologyHeroMatrix({
    required this.profile,
  });

  final NumerologyProfileData profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'La base del mapa se organiza entre tu sendero, tu forma de expresarte y el deseo interno que empuja tus decisiones.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5F6E72),
                height: 1.4,
              ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _AppliedCoreNumberCard(
                title: 'Sendero',
                subtitle: profile.coreNumbers.lifePath.archetype,
                value: profile.coreNumbers.lifePath.displayValue,
                accent: _numerologyInk,
              ),
              const SizedBox(width: 12),
              _AppliedCoreNumberCard(
                title: 'Expresión',
                subtitle: profile.coreNumbers.expression.archetype,
                value: profile.coreNumbers.expression.displayValue,
                accent: _numerologyAccent,
              ),
              const SizedBox(width: 12),
              _AppliedCoreNumberCard(
                title: 'Alma',
                subtitle: profile.coreNumbers.soulUrge.archetype,
                value: profile.coreNumbers.soulUrge.displayValue,
                accent: _numerologyAccentAlt,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppliedCoreNumberCard extends StatelessWidget {
  const _AppliedCoreNumberCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 126,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _numerologySurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _numerologyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6A6157),
              decoration: TextDecoration.none,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: accent,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF4F5E63),
                height: 1.25,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppliedInsightCard extends StatelessWidget {
  const _AppliedInsightCard({
    required this.item,
  });

  final _AppliedInsightData item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: _numerologySurface,
        border: Border.all(color: _numerologyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _numerologyAccentSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.number} · ${item.archetype}',
                      style: TextStyle(
                        color: item.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(item.summary),
          const SizedBox(height: 10),
          Text(
            'Activa: ${item.move}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuida: ${item.caution}',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _AlignmentNarrative extends StatelessWidget {
  const _AlignmentNarrative({
    required this.profile,
  });

  final NumerologyProfileData profile;

  @override
  Widget build(BuildContext context) {
    final currentExpression = profile.coreNumbers.currentNameExpression;
    final currentSoulUrge = profile.coreNumbers.currentNameSoulUrge;
    final dominant = profile.patterns.dominantNumbers.isEmpty
        ? null
        : profile.patterns.dominantNumbers.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentExpression == null
              ? 'Tu nombre actual está vibrando igual que tu nombre base, así que la expresión externa del mapa se mantiene bastante coherente.'
              : 'Tu nombre actual mueve una capa distinta del mapa: la expresión pasa a ${currentExpression.displayValue} y el deseo visible se ajusta con el nombre que usas hoy.',
        ),
        if (currentSoulUrge != null) ...[
          const SizedBox(height: 12),
          Text(
            'Hoy tu deseo visible toma tono ${currentSoulUrge.displayValue}, lo que cambia cómo pides, recibes y priorizas energía en los vínculos.',
          ),
        ],
        if (dominant != null) ...[
          const SizedBox(height: 12),
          Text(
            'La frecuencia más repetida de tu nombre es ${dominant.value}, por eso el mapa insiste una y otra vez en un estilo ${dominant.archetype.toLowerCase()}.',
          ),
        ],
        if (profile.patterns.karmicLessons.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Tus lecciones kármicas más visibles ahora piden trabajo en ${profile.patterns.karmicLessons.take(2).map((item) => item.displayValue).join(' y ')}.',
          ),
        ],
      ],
    );
  }
}

class _TimingRadar extends StatelessWidget {
  const _TimingRadar({
    required this.profile,
  });

  final NumerologyProfileData profile;

  @override
  Widget build(BuildContext context) {
    final year = profile.cycles.personalYear;
    final month = profile.cycles.personalMonth;
    final day = profile.cycles.personalDay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatCard(
              title: 'Año personal',
              value: year.displayValue,
              description: year.archetype,
              accent: _numerologyInk,
            ),
            _StatCard(
              title: 'Mes personal',
              value: month.displayValue,
              description: month.archetype,
              accent: _numerologyAccent,
            ),
            _StatCard(
              title: 'Día personal',
              value: day.displayValue,
              description: day.archetype,
              accent: const Color(0xFF5E819A),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'El año marca el clima grande, el mes baja el tono operativo y el día afina cómo te conviene moverte hoy. Tu mejor timing aparece cuando no peleas esas tres capas entre sí.',
        ),
        const SizedBox(height: 12),
        Text(
          'Movimiento recomendado: ${year.guidance}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Evita: ${year.shadows.take(2).join(' y ')}.',
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _NumberCard extends StatelessWidget {
  const _NumberCard({
    required this.card,
  });

  final NumerologyCard card;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _numerologyAccentSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    card.displayValue,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _numerologyInk,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(card.archetype),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(card.essence),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...card.gifts.map((item) => Chip(label: Text(item))),
                if (card.isMaster) const Chip(label: Text('Maestro')),
                if (card.isKarmicDebt) const Chip(label: Text('Deuda karmica')),
              ],
            ),
            const SizedBox(height: 12),
            Text('Sombra: ${card.shadows.join(' · ')}'),
            const SizedBox(height: 8),
            Text('Guia: ${card.guidance}'),
          ],
        ),
      ),
    );
  }
}

class _CycleTile extends StatelessWidget {
  const _CycleTile({
    required this.cycle,
  });

  final NumerologyCycleWindow cycle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _numerologySurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _numerologyBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _numerologyAccentSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              cycle.number.displayValue,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _numerologyInk,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cycle.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(cycle.ageRange),
                const SizedBox(height: 6),
                Text(cycle.focus),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.description,
    required this.accent,
  });

  final String title;
  final String value;
  final String description;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: _numerologySurface,
        border: Border.all(color: _numerologyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
              decoration: TextDecoration.none,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: accent,
                decoration: TextDecoration.none,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.auto_graph_outlined,
              size: 44,
              color: _numerologyAccent,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AppliedInsightData {
  const _AppliedInsightData({
    required this.title,
    required this.number,
    required this.archetype,
    required this.summary,
    required this.move,
    required this.caution,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String number;
  final String archetype;
  final String summary;
  final String move;
  final String caution;
  final IconData icon;
  final Color accent;
}

List<_AppliedInsightData> _buildAppliedInsights(NumerologyProfileData profile) {
  final love = profile.coreNumbers.soulUrge;
  final work = profile.coreNumbers.expression;
  final money = profile.coreNumbers.maturity;
  final wellbeing = profile.coreNumbers.attitude;
  final year = profile.cycles.personalYear;

  _AppliedInsightData build({
    required String title,
    required NumerologyCard card,
    required String prefix,
    required IconData icon,
    required Color accent,
  }) {
    final caution = card.shadows.take(2).join(' y ');
    return _AppliedInsightData(
      title: title,
      number: card.displayValue,
      archetype: card.archetype,
      summary: '$prefix ${card.essence}',
      move: card.guidance,
      caution: caution.isEmpty ? 'No fuerces este eje.' : caution,
      icon: icon,
      accent: accent,
    );
  }

  return [
    build(
      title: 'Amor',
      card: love,
      prefix: 'En amor y vínculos tu mapa pide',
      icon: Icons.favorite_border,
      accent: _numerologyAccent,
    ),
    build(
      title: 'Trabajo',
      card: work,
      prefix: 'En trabajo y oficio te favorece',
      icon: Icons.work_outline,
      accent: _numerologyInk,
    ),
    build(
      title: 'Dinero',
      card: money,
      prefix: 'En recursos y consolidación conviene',
      icon: Icons.payments_outlined,
      accent: _numerologyAccentAlt,
    ),
    build(
      title: 'Bienestar',
      card: wellbeing,
      prefix: 'Para regular tu energía diaria necesitas',
      icon: Icons.spa_outlined,
      accent: _numerologyInk,
    ),
    build(
      title: 'Momento actual',
      card: year,
      prefix: 'El clima numerológico del año te pide',
      icon: Icons.schedule_outlined,
      accent: _numerologyAccentAlt,
    ),
  ];
}
