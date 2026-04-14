part of 'astral_chart_screen.dart';

const _planetSelectionOptions = <({String key, String label, String note})>[
  (key: 'sun', label: 'Sol', note: 'Identidad y centro vital'),
  (key: 'moon', label: 'Luna', note: 'Emociones y memoria'),
  (key: 'mercury', label: 'Mercurio', note: 'Mente y lenguaje'),
  (key: 'venus', label: 'Venus', note: 'Vinculos y deseo'),
  (key: 'mars', label: 'Marte', note: 'Acción y deseo'),
  (key: 'jupiter', label: 'Júpiter', note: 'Expansión y fe'),
  (key: 'saturn', label: 'Saturno', note: 'Limites y estructura'),
  (key: 'uranus', label: 'Urano', note: 'Cambio y visión'),
  (key: 'neptune', label: 'Neptuno', note: 'Sensibilidad e ideal'),
  (key: 'pluto', label: 'Plutón', note: 'Poder y transformación'),
];

const _technicalPointOptions = <({String key, String label, String note})>[
  (key: 'north_node', label: 'Nodo Norte', note: 'Dirección evolutiva'),
  (key: 'south_node', label: 'Nodo Sur', note: 'Patrones y memoria'),
  (key: 'lilith', label: 'Lilith', note: 'Instinto y sombra'),
  (key: 'fortune', label: 'Parte Fortuna', note: 'Flujo y facilidad'),
  (
    key: 'misfortune',
    label: 'Parte Infortunio',
    note: 'Fricción y pruebas',
  ),
  (key: 'vertex', label: 'Vertex', note: 'Encuentros clave'),
  (key: 'chiron', label: 'Quirón', note: 'Herida y maestría'),
  (key: 'ceres', label: 'Ceres', note: 'Nutrición y cuidado'),
  (key: 'pallas', label: 'Palas', note: 'Estrategia y patrón'),
  (key: 'juno', label: 'Juno', note: 'Compromiso y acuerdos'),
  (key: 'vesta', label: 'Vesta', note: 'Foco y devoción'),
  (key: 'pholus', label: 'Pholus', note: 'Catalizador profundo'),
  (key: 'chariklo', label: 'Chariklo', note: 'Sostener y contener'),
  (key: 'eros', label: 'Eros', note: 'Deseo y magnetismo'),
  (key: 'eris', label: 'Eris', note: 'Disrupción y verdad'),
  (key: 'icarus', label: 'Ícaro', note: 'Riesgo y vuelo alto'),
  (key: 'nessus', label: 'Nessus', note: 'Patrones tóxicos'),
  (key: 'psyche', label: 'Psique', note: 'Alma y sensibilidad'),
];

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    super.key,
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
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _CalculationConfigurationPanel extends StatelessWidget {
  const _CalculationConfigurationPanel({
    required this.selectedPlanetKeys,
    required this.nodeType,
    required this.lilithType,
    required this.arabicPartsMode,
    required this.selectedTechnicalPointKeys,
    required this.isLoading,
    required this.onPlanetChanged,
    required this.onNodeTypeChanged,
    required this.onLilithTypeChanged,
    required this.onArabicPartsModeChanged,
    required this.onTechnicalPointChanged,
  });

  final Set<String> selectedPlanetKeys;
  final String nodeType;
  final String lilithType;
  final String arabicPartsMode;
  final Set<String> selectedTechnicalPointKeys;
  final bool isLoading;
  final void Function(String key, bool selected) onPlanetChanged;
  final ValueChanged<String> onNodeTypeChanged;
  final ValueChanged<String> onLilithTypeChanged;
  final ValueChanged<String> onArabicPartsModeChanged;
  final void Function(String key, bool selected) onTechnicalPointChanged;

  @override
  Widget build(BuildContext context) {
    final nodePointOptions = _technicalPointOptions
        .where(
            (point) => point.key == 'north_node' || point.key == 'south_node')
        .toList();
    final coreTechnicalPoints = _technicalPointOptions
        .where(
          (point) =>
              point.key != 'north_node' &&
              point.key != 'south_node' &&
              point.key != 'chariklo' &&
              point.key != 'eros' &&
              point.key != 'eris' &&
              point.key != 'icarus' &&
              point.key != 'nessus' &&
              point.key != 'psyche',
        )
        .toList();
    final asteroidTechnicalPoints = _technicalPointOptions
        .where(
          (point) =>
              point.key == 'chariklo' ||
              point.key == 'eros' ||
              point.key == 'eris' ||
              point.key == 'icarus' ||
              point.key == 'nessus' ||
              point.key == 'psyche',
        )
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFFBF7F2),
        border: Border.all(color: const Color(0xFFE5D9CB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración profesional',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Define qué cuerpos visibles quieres usar, el criterio de nodos, el tipo de Lilith y la lógica de partes arábigas antes de generar la carta.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.35,
              color: Color(0xFF5E5750),
            ),
          ),
          const SizedBox(height: 12),
          _MultiSelectMenuCard(
            title: 'Planetas visibles',
            subtitle:
                'Selecciona los cuerpos que quieres dibujar y listar dentro de la rueda natal.',
            emptyLabel: 'Sin planetas visibles',
            items: _planetSelectionOptions
                .map(
                  (planet) => _MultiSelectOption(
                    key: planet.key,
                    label: planet.label,
                    note: planet.note,
                    selected: selectedPlanetKeys.contains(planet.key),
                  ),
                )
                .toList(),
            enabled: !isLoading,
            onItemToggle: onPlanetChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: nodeType,
            decoration: const InputDecoration(
              labelText: 'Tipo de nodo',
              hintText: 'Selecciona el criterio de cálculo',
            ),
            items: const [
              DropdownMenuItem(
                value: 'true',
                child: Text('Nodo verdadero'),
              ),
              DropdownMenuItem(
                value: 'mean',
                child: Text('Nodo medio'),
              ),
            ],
            onChanged: isLoading
                ? null
                : (value) {
                    if (value != null) {
                      onNodeTypeChanged(value);
                    }
                  },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: lilithType,
            decoration: const InputDecoration(
              labelText: 'Lilith',
              hintText: 'Selecciona el criterio de Lilith',
            ),
            items: const [
              DropdownMenuItem(
                value: 'mean',
                child: Text('Lilith media'),
              ),
              DropdownMenuItem(
                value: 'true',
                child: Text('Lilith verdadera'),
              ),
            ],
            onChanged: isLoading
                ? null
                : (value) {
                    if (value != null) {
                      onLilithTypeChanged(value);
                    }
                  },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: arabicPartsMode,
            decoration: const InputDecoration(
              labelText: 'Partes arábigas',
              hintText: 'Selecciona la lógica de cálculo',
            ),
            items: const [
              DropdownMenuItem(
                value: 'same',
                child: Text('Día = Noche'),
              ),
              DropdownMenuItem(
                value: 'sect',
                child: Text('Día ≠ Noche'),
              ),
            ],
            onChanged: isLoading
                ? null
                : (value) {
                    if (value != null) {
                      onArabicPartsModeChanged(value);
                    }
                  },
          ),
          const SizedBox(height: 12),
          _MultiSelectMenuCard(
            title: 'Nodos visibles',
            subtitle:
                'Elige si quieres mostrar Nodo Norte, Nodo Sur o ambos dentro de la carta.',
            emptyLabel: 'Sin nodos activos',
            items: nodePointOptions
                .map(
                  (point) => _MultiSelectOption(
                    key: point.key,
                    label: _displayAstroLabel(point.label),
                    note: point.note,
                    selected: selectedTechnicalPointKeys.contains(point.key),
                  ),
                )
                .toList(),
            enabled: !isLoading,
            onItemToggle: onTechnicalPointChanged,
          ),
          const SizedBox(height: 12),
          _MultiSelectMenuCard(
            title: 'Puntos técnicos',
            subtitle:
                'Activa partes, puntos menores y auxiliares clásicos que quieras mostrar en la carta.',
            emptyLabel: 'Sin puntos técnicos activos',
            items: coreTechnicalPoints
                .map(
                  (point) => _MultiSelectOption(
                    key: point.key,
                    label: _displayAstroLabel(point.label),
                    note: point.note,
                    selected: selectedTechnicalPointKeys.contains(point.key),
                  ),
                )
                .toList(),
            enabled: !isLoading,
            onItemToggle: onTechnicalPointChanged,
          ),
          const SizedBox(height: 12),
          _MultiSelectMenuCard(
            title: 'Asteroides y centauros',
            subtitle:
                'Incluye cuerpos complementarios. Algunos requieren efemérides extra para aparecer en la carta.',
            emptyLabel: 'Sin asteroides activos',
            items: asteroidTechnicalPoints
                .map(
                  (point) => _MultiSelectOption(
                    key: point.key,
                    label: _displayAstroLabel(point.label),
                    note: point.note,
                    selected: selectedTechnicalPointKeys.contains(point.key),
                  ),
                )
                .toList(),
            enabled: !isLoading,
            onItemToggle: onTechnicalPointChanged,
          ),
        ],
      ),
    );
  }
}

class _MultiSelectMenuCard extends StatelessWidget {
  const _MultiSelectMenuCard({
    required this.title,
    required this.subtitle,
    required this.emptyLabel,
    required this.items,
    required this.enabled,
    required this.onItemToggle,
  });

  final String title;
  final String subtitle;
  final String emptyLabel;
  final List<_MultiSelectOption> items;
  final bool enabled;
  final void Function(String key, bool selected) onItemToggle;

  @override
  Widget build(BuildContext context) {
    final selectedLabels = items
        .where((item) => item.selected)
        .map((item) => item.label)
        .join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6D3BE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Color(0xFF675F58),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedLabels.isEmpty ? emptyLabel : selectedLabels,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D252B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            enabled: enabled,
            tooltip: 'Seleccionar nodos',
            onSelected: (key) {
              final item = items.firstWhere((entry) => entry.key == key);
              onItemToggle(key, !item.selected);
            },
            itemBuilder: (context) {
              return items
                  .map(
                    (item) => CheckedPopupMenuItem<String>(
                      value: item.key,
                      checked: item.selected,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.label),
                          Text(
                            item.note,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color:
                    enabled ? const Color(0xFFF8EFE5) : const Color(0xFFF2EEEA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE1D2C2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_drop_down_circle_outlined, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Elegir',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MultiSelectOption {
  const _MultiSelectOption({
    required this.key,
    required this.label,
    required this.note,
    required this.selected,
  });

  final String key;
  final String label;
  final String note;
  final bool selected;
}

class _BigThreeCard extends StatelessWidget {
  const _BigThreeCard({
    required this.result,
  });

  final AstroNatalChartResult result;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Tu tríada central',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 680;
          final itemWidth =
              isWide ? (constraints.maxWidth - 24) / 3 : constraints.maxWidth;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sol, Luna y Ascendente resumen tu identidad, tu mundo emocional y la energía con la que entras en escena.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _buildBigThreeItems(itemWidth),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildBigThreeItems(double itemWidth) {
    final themes = const [
      _BigThreeItemTheme.sun(),
      _BigThreeItemTheme.moon(),
      _BigThreeItemTheme.ascendant(),
    ];
    final placements = [
      (
        sign: result.bigThree.sun.sign,
        degreeFormatted: result.bigThree.sun.degreeFormatted,
      ),
      (
        sign: result.bigThree.moon.sign,
        degreeFormatted: result.bigThree.moon.degreeFormatted,
      ),
      (
        sign: result.bigThree.ascendant.sign,
        degreeFormatted: result.bigThree.ascendant.degreeFormatted,
      ),
    ];

    return List.generate(themes.length, (index) {
      final theme = themes[index];
      final placement = placements[index];
      return SizedBox(
        width: itemWidth,
        child: _BigThreeItem(
          emoji: theme.emoji,
          label: theme.label,
          sign: placement.sign,
          detail: placement.degreeFormatted,
          note: theme.note,
          startColor: theme.startColor,
          endColor: theme.endColor,
        ),
      );
    });
  }
}

class _BigThreeItemTheme {
  const _BigThreeItemTheme({
    required this.emoji,
    required this.label,
    required this.note,
    required this.startColor,
    required this.endColor,
  });

  const _BigThreeItemTheme.sun()
      : emoji = '☀️',
        label = 'Sol',
        note = 'Tu identidad esencial',
        startColor = const Color(0xFFD9813A),
        endColor = const Color(0xFFF1B24A);

  const _BigThreeItemTheme.moon()
      : emoji = '🌙',
        label = 'Luna',
        note = 'Tu mundo emocional',
        startColor = const Color(0xFF506A8A),
        endColor = const Color(0xFF8FA7C7);

  const _BigThreeItemTheme.ascendant()
      : emoji = '⬆️',
        label = 'Ascendente',
        note = 'Como te perciben',
        startColor = const Color(0xFF355B52),
        endColor = const Color(0xFF5E8C7F);

  final String emoji;
  final String label;
  final String note;
  final Color startColor;
  final Color endColor;
}

class _BigThreeItem extends StatelessWidget {
  const _BigThreeItem({
    required this.emoji,
    required this.label,
    required this.sign,
    required this.detail,
    required this.note,
    required this.startColor,
    required this.endColor,
  });

  final String emoji;
  final String label;
  final String sign;
  final String detail;
  final String note;
  final Color startColor;
  final Color endColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            startColor,
            endColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: startColor.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            sign,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              note,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TriadDetailsCard extends StatelessWidget {
  const _TriadDetailsCard({
    required this.result,
  });

  final AstroNatalChartResult result;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Detalles de la tríada',
      child: Column(
        children: [
          _DetailBox(
            icon: '☀️',
            title: 'Sol',
            value:
                '${result.bigThree.sun.sign} · ${result.bigThree.sun.degreeFormatted} · Casa ${result.bigThree.sun.house}',
            description:
                'Regente ${_rulerDescription(result.bigThree.sun.sign, result)}',
            trailing: _aspectDescription(result.aspects, 'Sol') ??
                'Sin aspecto dominante visible',
          ),
          const SizedBox(height: 12),
          _DetailBox(
            icon: '🌙',
            title: 'Luna',
            value:
                '${result.bigThree.moon.sign} · ${result.bigThree.moon.degreeFormatted} · Casa ${result.bigThree.moon.house}',
            description:
                'Regente ${_rulerDescription(result.bigThree.moon.sign, result)}',
            trailing: _aspectDescription(result.aspects, 'Luna') ??
                'Sin aspecto dominante visible',
          ),
          const SizedBox(height: 12),
          _DetailBox(
            icon: '⬆️',
            title: 'Ascendente',
            value:
                '${result.bigThree.ascendant.sign} · ${result.bigThree.ascendant.degreeFormatted}',
            description:
                'Regente ${_rulerDescription(result.bigThree.ascendant.sign, result)}',
            trailing: _aspectDescription(result.aspects, 'Ascendente') ??
                'Define la forma en que entras en escena y das tu primera impresión.',
          ),
        ],
      ),
    );
  }
}

class _RulershipsCard extends StatelessWidget {
  const _RulershipsCard({
    required this.result,
  });

  final AstroNatalChartResult result;

  @override
  Widget build(BuildContext context) {
    final chartRulerPlacement =
        _findPlanet(result.planets, result.summary.chartRuler);
    final ascRuler = result.bigThree.ascendant.ruler;
    final ascRulerPlacement = _findPlanet(result.planets, ascRuler);

    return _SectionCard(
      title: 'Regencias',
      child: Column(
        children: [
          _InsightPanel(
            icon: '🪐',
            title: 'Regente de carta',
            value: chartRulerPlacement == null
                ? result.summary.chartRuler
                : '${result.summary.chartRuler} en ${chartRulerPlacement.sign}, casa ${chartRulerPlacement.house}',
            description:
                'Marca el tono general de la carta y el área donde tu energía central busca expresarse con más fuerza.',
          ),
          const SizedBox(height: 12),
          _InsightPanel(
            icon: '⬆️',
            title: 'Regente del Ascendente',
            value: ascRulerPlacement == null
                ? ascRuler
                : '$ascRuler en ${ascRulerPlacement.sign}, casa ${ascRulerPlacement.house}',
            description:
                'Muestra cómo arrancas procesos, cómo te proyectas y en qué escenario se mueve tu impulso personal.',
          ),
        ],
      ),
    );
  }
}

class _DominantsCard extends StatelessWidget {
  const _DominantsCard({
    required this.result,
  });

  final AstroNatalChartResult result;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Dominantes de la carta',
      child: Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _PillStat(
                title: 'Elemento dominante',
                value: result.summary.dominantElement,
              ),
              _PillStat(
                title: 'Cualidad dominante',
                value: result.summary.dominantQuality,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InsightPanel(
            icon: '🔥',
            title: 'Elemento dominante',
            value: result.summary.dominantElement,
            description: _elementMeaning(result.summary.dominantElement),
          ),
          const SizedBox(height: 12),
          _InsightPanel(
            icon: '🧭',
            title: 'Cualidad dominante',
            value: result.summary.dominantQuality,
            description: _qualityMeaning(result.summary.dominantQuality),
          ),
        ],
      ),
    );
  }
}

class _MidheavenCard extends StatelessWidget {
  const _MidheavenCard({
    required this.result,
  });

  final AstroNatalChartResult result;

  @override
  Widget build(BuildContext context) {
    final mcRuler = result.angles.midheaven.ruler;
    final mcRulerPlacement = _findPlanet(result.planets, mcRuler);

    return _SectionCard(
      title: 'MC y proyección',
      child: Column(
        children: [
          _InsightPanel(
            icon: '🏛️',
            title: 'Medio Cielo',
            value:
                '${result.angles.midheaven.sign} · ${result.angles.midheaven.degreeFormatted} · Casa ${result.angles.midheaven.house}',
            description: _mcMeaning(result.angles.midheaven.sign),
          ),
          const SizedBox(height: 12),
          _InsightPanel(
            icon: '🎯',
            title: 'Regente del MC',
            value: mcRulerPlacement == null
                ? mcRuler
                : '$mcRuler en ${mcRulerPlacement.sign}, casa ${mcRulerPlacement.house}',
            description:
                'Ayuda a leer hacia dónde se ordena tu vocación, tu imagen pública y tu forma de consolidar metas.',
          ),
        ],
      ),
    );
  }
}

class _TechnicalPointsCard extends StatelessWidget {
  const _TechnicalPointsCard({
    required this.result,
  });

  final AstroNatalChartResult result;

  @override
  Widget build(BuildContext context) {
    if (result.points.isEmpty) {
      return const SizedBox.shrink();
    }

    return _SectionCard(
      title: 'Puntos técnicos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PillStat(
                title: 'Nodo',
                value: result.meta.nodeType == 'mean'
                    ? 'Nodo medio'
                    : 'Nodo verdadero',
              ),
              _PillStat(
                title: 'Efemerides',
                value: result.meta.ephemerisSource == 'swisseph'
                    ? 'Swiss Ephemeris'
                    : result.meta.ephemerisSource == 'moshier'
                        ? 'Moshier'
                        : 'Astronomy Engine',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: result.points
                .map(
                  (point) => _PillStat(
                    title: _displayAstroLabel(point.label),
                    value:
                        '${point.sign} · ${point.degreeFormatted} · Casa ${point.house}${point.retrograde ? ' · R' : ''}',
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PillStat extends StatelessWidget {
  const _PillStat({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6D3BE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7D5B47),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _InsightPanel extends StatelessWidget {
  const _InsightPanel({
    required this.icon,
    required this.title,
    required this.value,
    required this.description,
  });

  final String icon;
  final String title;
  final String value;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF9F1E6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEFD8BF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBox extends StatelessWidget {
  const _DetailBox({
    required this.icon,
    required this.title,
    required this.value,
    required this.description,
    required this.trailing,
  });

  final String icon;
  final String title;
  final String value;
  final String description;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6D3BE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(description),
          const SizedBox(height: 8),
          Text(
            trailing,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _HouseSystemChip extends StatelessWidget {
  const _HouseSystemChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected == null ? null : (_) => onSelected!(),
      selectedColor: const Color(0xFFF2D5B4),
      side: BorderSide(
        color: selected ? const Color(0xFFB26E39) : const Color(0xFFE4D6C7),
      ),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: selected ? const Color(0xFF6E3F16) : const Color(0xFF453C35),
      ),
    );
  }
}

class _ChartWheelExportImage extends StatelessWidget {
  const _ChartWheelExportImage({
    required this.result,
  });

  final AstroNatalChartResult result;

  @override
  Widget build(BuildContext context) {
    return AstroChartExportBoard(
      result: result,
      size: 2100,
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFB96C3D),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(value),
              const SizedBox(height: 2),
              Text(
                detail,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _rulerForSign(String sign) {
  switch (sign) {
    case 'Aries':
      return 'Marte';
    case 'Tauro':
      return 'Venus';
    case 'Geminis':
      return 'Mercurio';
    case 'Cancer':
      return 'Luna';
    case 'Leo':
      return 'Sol';
    case 'Virgo':
      return 'Mercurio';
    case 'Libra':
      return 'Venus';
    case 'Escorpio':
      return 'Plutón';
    case 'Sagitario':
      return 'Júpiter';
    case 'Capricornio':
      return 'Saturno';
    case 'Acuario':
      return 'Urano';
    case 'Piscis':
      return 'Neptuno';
    default:
      return '';
  }
}

AstroPlacement? _findPlanet(List<AstroPlacement> planets, String label) {
  for (final planet in planets) {
    if (_foldAstroLabel(planet.label) == _foldAstroLabel(label)) {
      return planet;
    }
  }

  return null;
}

AstroAspect? _findPrimaryAspect(List<AstroAspect> aspects, String label) {
  final matches = aspects.where(
    (aspect) => aspect.left == label || aspect.right == label,
  );
  if (matches.isEmpty) {
    return null;
  }

  final ordered = matches.toList()
    ..sort((left, right) => left.orb.compareTo(right.orb));
  return ordered.first;
}

String _otherBody(AstroAspect aspect, String label) {
  return aspect.left == label ? aspect.right : aspect.left;
}

String _rulerDescription(String sign, AstroNatalChartResult result) {
  final ruler = _rulerForSign(sign);
  final placement = _findPlanet(result.planets, ruler);
  if (placement == null) {
    return _displayAstroLabel(ruler);
  }

  return '${_displayAstroLabel(ruler)} en ${placement.sign}, casa ${placement.house}';
}

String _displayAstroLabel(String value) {
  switch (value) {
    case 'Jupiter':
      return 'Júpiter';
    case 'Pluton':
      return 'Plutón';
    case 'Quiron':
      return 'Quirón';
    case 'Icaro':
      return 'Ícaro';
    default:
      return value;
  }
}

String _foldAstroLabel(String value) {
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

String? _aspectDescription(List<AstroAspect> aspects, String label) {
  final aspect = _findPrimaryAspect(aspects, label);
  if (aspect == null) {
    return null;
  }

  return '${aspect.type} con ${_otherBody(aspect, label)} · orb ${aspect.orb.toStringAsFixed(1)}°/${aspect.maxOrb.toStringAsFixed(1)}°';
}

String _aspectPrecisionLabel(String precision) {
  switch (precision) {
    case 'cerrado':
      return 'muy exacto';
    case 'moderado':
      return 'activo';
    case 'amplio':
      return 'abierto';
    default:
      return precision;
  }
}

String _elementMeaning(String element) {
  switch (element) {
    case 'Fuego':
      return 'Predomina iniciativa, intensidad, deseo de avanzar y expresarte con decisión.';
    case 'Tierra':
      return 'Predomina realismo, constancia, necesidad de resultados concretos y estabilidad.';
    case 'Aire':
      return 'Predomina lo mental, la observación, el intercambio y la necesidad de comprender.';
    case 'Agua':
      return 'Predomina sensibilidad, intuición, memoria emocional y lectura profunda del entorno.';
    default:
      return '';
  }
}

String _qualityMeaning(String quality) {
  switch (quality) {
    case 'Cardinal':
      return 'Hay impulso de iniciar procesos, mover energía y abrir nuevas etapas.';
    case 'Fijo':
      return 'Hay capacidad de sostener, profundizar, consolidar y resistir cambios bruscos.';
    case 'Mutable':
      return 'Hay adaptación, flexibilidad, lectura del contexto y facilidad para cambiar de enfoque.';
    default:
      return '';
  }
}

String _formatBirthDateForForm(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value.trim());
  if (match == null) {
    return value;
  }

  return '${match.group(3)}-${match.group(2)}-${match.group(1)}';
}

String _mcMeaning(String sign) {
  switch (sign) {
    case 'Aries':
      return 'Tu vocación tiende a afirmarse con iniciativa, autonomía y deseo de abrir camino propio.';
    case 'Tauro':
      return 'Tu proyección pública busca construir valor, estabilidad y resultados sostenibles.';
    case 'Geminis':
      return 'Tu camino visible se potencia a traves de la palabra, el aprendizaje y la multiplicidad de intereses.';
    case 'Cancer':
      return 'Tu imagen pública se vincula a cuidado, contención, memoria y sensibilidad social.';
    case 'Leo':
      return 'Tu proyección profesional pide presencia, creatividad, liderazgo y expresión auténtica.';
    case 'Virgo':
      return 'Tu vocación se fortalece en servicio, precisión, mejora continua y criterio práctico.';
    case 'Libra':
      return 'Tu desarrollo visible crece en vínculos, armonización, estética y negociación.';
    case 'Escorpio':
      return 'Tu imagen pública se carga de intensidad, transformación, estrategia y profundidad.';
    case 'Sagitario':
      return 'Tu camino profesional busca expansión, sentido, enseñanza y horizontes amplios.';
    case 'Capricornio':
      return 'Tu vocación se construye con disciplina, responsabilidad, estructura y ambición realista.';
    case 'Acuario':
      return 'Tu proyección laboral se apoya en innovación, originalidad, redes y visión de futuro.';
    case 'Piscis':
      return 'Tu camino visible pide sensibilidad, inspiración, imaginación y lectura simbólica.';
    default:
      return '';
  }
}
