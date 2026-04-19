import 'package:flutter/material.dart';

import '../../core/i18n/app_i18n.dart';
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
        _errorMessage = context.l10n.ts(
          'Ingresa tu nombre completo al nacer y tu fecha de nacimiento.',
        );
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
    final l10n = context.l10n;
    final mediaQuery = MediaQuery.of(context);
    final textScale = mediaQuery.textScaler.scale(1).clamp(1.0, 1.02);
    final menuFlow = <MysticFlowOption>[
      MysticFlowOption(
        label: l10n.ts('Panorama'),
        caption: l10n.ts('Resumen vivo del mapa'),
        glyphKind: MysticGlyphKind.numerology,
      ),
      MysticFlowOption(
        label: l10n.ts('Números'),
        caption: l10n.ts('Núcleos y patrones'),
        glyphKind: MysticGlyphKind.generic,
      ),
      MysticFlowOption(
        label: l10n.ts('Ciclos'),
        caption: l10n.ts('Timing y pináculos'),
        glyphKind: MysticGlyphKind.ritual,
      ),
      MysticFlowOption(
        label: l10n.ts('Especialistas'),
        caption: l10n.ts('Acompañamiento humano'),
        glyphKind: MysticGlyphKind.specialist,
      ),
      MysticFlowOption(
        label: l10n.ts('Cursos'),
        caption: l10n.ts('Rutas y práctica guiada'),
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
                          l10n.ts('Numerología'),
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
                        Text(
                          l10n.ts(
                            'Calcula tus números nucleares, tus ciclos y la lectura de tu nombre natal dentro del sistema pitagórico.',
                          ),
                          style: const TextStyle(
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
                                label: l10n.ts('Sendero'),
                                value:
                                    _profile!.coreNumbers.lifePath.displayValue,
                              ),
                              _HeroMetricPill(
                                label: l10n.ts('Expresión'),
                                value: _profile!
                                    .coreNumbers.expression.displayValue,
                              ),
                              _HeroMetricPill(
                                label: l10n.ts('Año'),
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
                    title: l10n.ts('Generar perfil numerológico'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _birthNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: l10n.ts('Nombre completo al nacer'),
                            hintText: l10n.ts('Ejemplo: Maria Fernanda Quispe'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _currentNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: l10n.ts('Nombre actual o social'),
                            hintText: l10n.ts('Opcional, para matiz actual'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _birthDateController,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            labelText: l10n.ts('Fecha de nacimiento'),
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
                                    ? l10n.ts('Calculando...')
                                    : l10n.ts('Generar numerología'),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: numerologyServices.isEmpty
                                  ? null
                                  : () => widget.onCreateBooking(
                                        numerologyServices.first.id,
                                      ),
                              icon: const Icon(Icons.calendar_month_outlined),
                              label: Text(l10n.ts('Agendar consulta')),
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
    final l10n = context.l10n;

    switch (selectedMenu) {
      case _NumerologyMenu.panorama:
        final appliedInsights = profile == null
            ? const <_AppliedInsightData>[]
            : _buildAppliedInsights(profile!, l10n);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (profile != null) ...[
              _SectionCard(
                title: l10n.ts('Mapa central'),
                child: _NumerologyHeroMatrix(profile: profile!),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: l10n.ts('Lectura integrada'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_buildLocalizedNumerologySummary(profile!, l10n)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _StatCard(
                          title: l10n.ts('Sendero'),
                          value: profile!.coreNumbers.lifePath.displayValue,
                          description: profile!.coreNumbers.lifePath.archetype,
                          accent: _numerologyInk,
                        ),
                        _StatCard(
                          title: l10n.ts('Expresión'),
                          value: profile!.coreNumbers.expression.displayValue,
                          description:
                              profile!.coreNumbers.expression.archetype,
                          accent: _numerologyAccent,
                        ),
                        _StatCard(
                          title: l10n.ts('Año personal'),
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
                title: l10n.ts('Aplicación real'),
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
                title: l10n.ts('Alineación del nombre y del mapa'),
                child: _AlignmentNarrative(profile: profile!),
              ),
              const SizedBox(height: 16),
            ],
            _SectionCard(
              title: l10n.ts('Conceptos base'),
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
                                        l10n.ts(concept.title),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(l10n.ts(concept.summary)),
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
                title: l10n.ts('Enfoque profesional'),
                child: Text(_buildLocalizedNumerologyVocation(profile!, l10n)),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: l10n.ts('Vinculos y deseo'),
                child: Text(
                  _buildLocalizedNumerologyRelationships(profile!, l10n),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: l10n.ts('Radar del momento'),
                child: _TimingRadar(profile: profile!),
              ),
            ],
          ],
        );
      case _NumerologyMenu.numeros:
        if (profile == null) {
          return _EmptyState(
            title: l10n.ts('Genera tu perfil numerológico'),
            subtitle: l10n.ts(
              'Necesitamos tu nombre completo al nacer y tu fecha de nacimiento para desplegar los números nucleares.',
            ),
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
              title: l10n.ts('Patrones del nombre'),
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
                              l10n.ts(
                                '{value} · {count} repeticiones',
                                {
                                  'value': '${item.value}',
                                  'count': '${item.count}',
                                },
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile!.patterns.hiddenPassion == null
                        ? l10n.ts(
                            'No aparece una pasión oculta dominante marcada.',
                          )
                        : l10n.ts(
                            'Pasión oculta {value}: {essence}',
                            {
                              'value':
                                  profile!.patterns.hiddenPassion!.displayValue,
                              'essence': l10n.ts(
                                profile!.patterns.hiddenPassion!.essence,
                              ),
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.ts(
                      'Letra inicial {letter}: {meaning}',
                      {
                        'letter': profile!.patterns.cornerstone.letter,
                        'meaning': profile!.patterns.cornerstone.meaning,
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.ts(
                      'Letra final {letter}: {meaning}',
                      {
                        'letter': profile!.patterns.capstone.letter,
                        'meaning': profile!.patterns.capstone.meaning,
                      },
                    ),
                  ),
                  if (profile!.patterns.firstVowel != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.ts(
                        'Primera vocal {letter}: {meaning}',
                        {
                          'letter': profile!.patterns.firstVowel!.letter,
                          'meaning': profile!.patterns.firstVowel!.meaning,
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      case _NumerologyMenu.ciclos:
        if (profile == null) {
          return _EmptyState(
            title: l10n.ts('Sin ciclos aún'),
            subtitle: l10n.ts(
              'Primero genera el perfil para desplegar año personal, pináculos y desafíos.',
            ),
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
                  title: l10n.ts('Año personal'),
                  value: profile!.cycles.personalYear.displayValue,
                  description: profile!.cycles.personalYear.archetype,
                  accent: _numerologyInk,
                ),
                _StatCard(
                  title: l10n.ts('Mes personal'),
                  value: profile!.cycles.personalMonth.displayValue,
                  description: profile!.cycles.personalMonth.archetype,
                  accent: _numerologyAccent,
                ),
                _StatCard(
                  title: l10n.ts('Día personal'),
                  value: profile!.cycles.personalDay.displayValue,
                  description: profile!.cycles.personalDay.archetype,
                  accent: _numerologyAccentAlt,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: l10n.ts('Timing del momento'),
              child: Text(_buildLocalizedNumerologyTiming(profile!, l10n)),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: l10n.ts('Pináculos'),
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
              title: l10n.ts('Desafíos'),
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
                title: l10n.ts('Lecciones kármicas'),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile!.patterns.karmicLessons
                      .map(
                        (item) => Chip(
                          label: Text(
                            '${item.displayValue} · ${l10n.ts(item.guidance)}',
                          ),
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
                        Text(l10n.ts(specialist.headline)),
                        const SizedBox(height: 12),
                        Text(l10n.ts(specialist.bio)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(
                              label: Text(
                                l10n.ts(
                                  '{count} años',
                                  {'count': '${specialist.yearsExperience}'},
                                ),
                              ),
                            ),
                            SpecialistRatingBadge(rating: specialist.rating),
                            ...specialist.specialties.take(3).map(
                                  (item) => Chip(label: Text(l10n.ts(item))),
                                ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.ts(
                            'Próxima disponibilidad: {date}',
                            {
                              'date':
                                  formatSchedule(specialist.nextAvailableAt),
                            },
                          ),
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
                  title: l10n.ts(item.title),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.ts(
                          '{category} · {count} lecciones · {hours} h',
                          {
                            'category': l10n.ts(item.category),
                            'count': '${item.lessonCount}',
                            'hours': item.estimatedHours.toStringAsFixed(1),
                          },
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.ts(item.subtitle),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(l10n.ts(item.description)),
                    ],
                  ),
                ),
              ),
            ),
            if (guide != null)
              _SectionCard(
                title: l10n.ts('Referencias online'),
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
                              Text(l10n.ts(reference.note)),
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
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.ts(
            'La base del mapa se organiza entre tu sendero, tu forma de expresarte y el deseo interno que empuja tus decisiones.',
          ),
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
                title: l10n.ts('Sendero'),
                subtitle: profile.coreNumbers.lifePath.archetype,
                value: profile.coreNumbers.lifePath.displayValue,
                accent: _numerologyInk,
              ),
              const SizedBox(width: 12),
              _AppliedCoreNumberCard(
                title: l10n.ts('Expresión'),
                subtitle: profile.coreNumbers.expression.archetype,
                value: profile.coreNumbers.expression.displayValue,
                accent: _numerologyAccent,
              ),
              const SizedBox(width: 12),
              _AppliedCoreNumberCard(
                title: l10n.ts('Alma'),
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
    final l10n = context.l10n;

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
              l10n.ts(subtitle),
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
    final l10n = context.l10n;

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
            l10n.ts('Activa: {move}', {'move': item.move}),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.ts('Cuida: {caution}', {'caution': item.caution}),
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
    final l10n = context.l10n;
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
              ? l10n.ts(
                  'Tu nombre actual está vibrando igual que tu nombre base, así que la expresión externa del mapa se mantiene bastante coherente.',
                )
              : l10n.ts(
                  'Tu nombre actual mueve una capa distinta del mapa: la expresión pasa a {value} y el deseo visible se ajusta con el nombre que usas hoy.',
                  {'value': currentExpression.displayValue},
                ),
        ),
        if (currentSoulUrge != null) ...[
          const SizedBox(height: 12),
          Text(
            l10n.ts(
              'Hoy tu deseo visible toma tono {value}, lo que cambia cómo pides, recibes y priorizas energía en los vínculos.',
              {'value': currentSoulUrge.displayValue},
            ),
          ),
        ],
        if (dominant != null) ...[
          const SizedBox(height: 12),
          Text(
            l10n.ts(
              'La frecuencia más repetida de tu nombre es {value}, por eso el mapa insiste una y otra vez en un estilo {archetype}.',
              {
                'value': '${dominant.value}',
                'archetype': l10n.ts(dominant.archetype).toLowerCase(),
              },
            ),
          ),
        ],
        if (profile.patterns.karmicLessons.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            l10n.ts(
              'Tus lecciones kármicas más visibles ahora piden trabajo en {lessons}.',
              {
                'lessons': profile.patterns.karmicLessons
                    .take(2)
                    .map((item) => item.displayValue)
                    .join(' ${l10n.ts('y')} '),
              },
            ),
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
    final l10n = context.l10n;
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
              title: l10n.ts('Año personal'),
              value: year.displayValue,
              description: year.archetype,
              accent: _numerologyInk,
            ),
            _StatCard(
              title: l10n.ts('Mes personal'),
              value: month.displayValue,
              description: month.archetype,
              accent: _numerologyAccent,
            ),
            _StatCard(
              title: l10n.ts('Día personal'),
              value: day.displayValue,
              description: day.archetype,
              accent: const Color(0xFF5E819A),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          l10n.ts(
            'El año marca el clima grande, el mes baja el tono operativo y el día afina cómo te conviene moverte hoy. Tu mejor timing aparece cuando no peleas esas tres capas entre sí.',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.ts(
            'Movimiento recomendado: {guidance}',
            {'guidance': l10n.ts(year.guidance)},
          ),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.ts(
            'Evita: {items}.',
            {
              'items':
                  year.shadows.take(2).map(l10n.ts).join(' ${l10n.ts('y')} '),
            },
          ),
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
    final l10n = context.l10n;

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
                        l10n.ts(card.title),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(l10n.ts(card.archetype)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(l10n.ts(card.essence)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...card.gifts.map(
                  (item) => Chip(label: Text(l10n.ts(item))),
                ),
                if (card.isMaster) Chip(label: Text(l10n.ts('Maestro'))),
                if (card.isKarmicDebt)
                  Chip(label: Text(l10n.ts('Deuda karmica'))),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.ts(
                'Sombra: {items}',
                {'items': card.shadows.map(l10n.ts).join(' · ')},
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.ts('Guia: {guidance}', {
                'guidance': l10n.ts(card.guidance),
              }),
            ),
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
    final l10n = context.l10n;

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
                  l10n.ts(cycle.label),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(_localizedAgeRange(cycle.ageRange, l10n)),
                const SizedBox(height: 6),
                Text(l10n.ts(cycle.focus)),
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
    final l10n = context.l10n;

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
              l10n.ts(description),
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

String _localizedAgeRange(String value, AppLocalizations l10n) {
  return value.replaceAll(' a ', ' ${l10n.ts('a')} ');
}

String _buildLocalizedNumerologySummary(
  NumerologyProfileData profile,
  AppLocalizations l10n,
) {
  final dominant = profile.patterns.dominantNumbers.isEmpty
      ? null
      : profile.patterns.dominantNumbers.first;
  final base = l10n.ts(
    'Tu Sendero de Vida {lifePath} marca el tono central del camino, mientras tu Expresión {expression} describe la forma en que despliegas tus talentos. Tu Alma {soul} muestra la motivación profunda y tu Personalidad {personality} la primera capa que leen los demás.',
    {
      'lifePath': profile.coreNumbers.lifePath.displayValue,
      'expression': profile.coreNumbers.expression.displayValue,
      'soul': profile.coreNumbers.soulUrge.displayValue,
      'personality': profile.coreNumbers.personality.displayValue,
    },
  );
  if (dominant == null) {
    return base;
  }
  final dominantLine = l10n.ts(
    'La frecuencia más repetida de tu nombre es {value}, lo que refuerza un estilo {archetype}.',
    {
      'value': '${dominant.value}',
      'archetype': l10n.ts(dominant.archetype).toLowerCase(),
    },
  );
  return '$base $dominantLine';
}

String _buildLocalizedNumerologyVocation(
  NumerologyProfileData profile,
  AppLocalizations l10n,
) {
  return l10n.ts(
    'Profesionalmente conviene unir la dirección {lifePathArchetype} de tu camino con la forma {expressionArchetype} en que ejecutas. Si honras tu número de Expresión, el trabajo deja de ser solo obligación y se vuelve canal de realización.',
    {
      'lifePathArchetype':
          l10n.ts(profile.coreNumbers.lifePath.archetype).toLowerCase(),
      'expressionArchetype':
          l10n.ts(profile.coreNumbers.expression.archetype).toLowerCase(),
    },
  );
}

String _buildLocalizedNumerologyRelationships(
  NumerologyProfileData profile,
  AppLocalizations l10n,
) {
  final hiddenPassion = profile.patterns.hiddenPassion;
  final hiddenPassionText = hiddenPassion == null
      ? l10n.ts(
          'No aparece una pasión oculta dominante; el mapa está más repartido.',
        )
      : l10n.ts(
          'Tu pasión oculta {value} empuja procesos donde {essence}',
          {
            'value': hiddenPassion.displayValue,
            'essence': l10n.ts(hiddenPassion.essence).toLowerCase(),
          },
        );

  return l10n.ts(
    'En vínculos pesa especialmente tu Alma {soul}, porque ahí se ve lo que realmente necesitas para sentirte reconocido. Tu Personalidad {personality} actúa como filtro externo, así que no siempre lo que muestras coincide con lo que deseas por dentro. {hiddenPassion}',
    {
      'soul': profile.coreNumbers.soulUrge.displayValue,
      'personality': profile.coreNumbers.personality.displayValue,
      'hiddenPassion': hiddenPassionText,
    },
  );
}

String _buildLocalizedNumerologyTiming(
  NumerologyProfileData profile,
  AppLocalizations l10n,
) {
  return l10n.ts(
    'El Año Personal {personalYear} describe el clima actual de tus decisiones. Toma este ciclo como una capa externa: abre oportunidades y pruebas, pero se expresa mejor cuando la alineas con tus números base.',
    {
      'personalYear': profile.cycles.personalYear.displayValue,
    },
  );
}

List<_AppliedInsightData> _buildAppliedInsights(
  NumerologyProfileData profile,
  AppLocalizations l10n,
) {
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
    final caution = card.shadows.take(2).map(l10n.ts).join(' ${l10n.ts('y')} ');
    return _AppliedInsightData(
      title: l10n.ts(title),
      number: card.displayValue,
      archetype: l10n.ts(card.archetype),
      summary: '${l10n.ts(prefix)} ${l10n.ts(card.essence)}',
      move: l10n.ts(card.guidance),
      caution: caution.isEmpty ? l10n.ts('No fuerces este eje.') : caution,
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
