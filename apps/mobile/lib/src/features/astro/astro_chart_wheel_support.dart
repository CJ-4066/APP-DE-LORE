part of 'astro_chart_wheel.dart';

class AstroChartTechnicalHeader extends StatelessWidget {
  const AstroChartTechnicalHeader({
    super.key,
    required this.result,
    this.classic = false,
  });

  final AstroNatalChartResult result;
  final bool classic;

  @override
  Widget build(BuildContext context) {
    final meta = result.meta;
    final birthUtc = DateTime.tryParse(meta.birthDateTimeUtc)?.toUtc();
    final subjectName = meta.subjectName.trim().isEmpty
        ? 'CARTA NATAL'
        : meta.subjectName.trim().toUpperCase();
    final localBirth = [
      _formatDateLabel(meta.birthDate),
      meta.birthTime,
      if (meta.utcOffset.isNotEmpty) '(${meta.utcOffset})',
    ].join(' ');
    final utcBirth = birthUtc == null
        ? ''
        : '${_formatDateLabel(_formatIsoDate(birthUtc))} ${_formatUtcTime(birthUtc)} UT';
    final coordinates =
        '${_formatLatitude(meta.coordinates.latitude)} ${_formatLongitude(meta.coordinates.longitude)}';

    final textColor =
        classic ? const Color(0xFF1A1A1A) : const Color(0xFF302E2B);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(classic ? 0 : 16),
      decoration: classic
          ? null
          : BoxDecoration(
              color: const Color(0xFFFBF8F4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE4D8CB)),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Carta natal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: classic
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFF21345A),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subjectName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color:
                  classic ? const Color(0xFF1A1A1A) : const Color(0xFF254C9B),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            localBirth,
            style: TextStyle(fontSize: 13.5, color: textColor),
          ),
          if (utcBirth.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              utcBirth,
              style: TextStyle(fontSize: 13.5, color: textColor),
            ),
          ],
          if (meta.locationLabel.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              meta.locationLabel,
              style: TextStyle(fontSize: 13.5, color: textColor),
            ),
          ],
          const SizedBox(height: 2),
          Text(
            coordinates,
            style: TextStyle(fontSize: 13.5, color: textColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Tropical/geocéntrico · Carta eclíptica · Casas: ${_capitalize(meta.houseSystem)}',
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF5D5953),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Nodos: ${_nodeTypeLabel(meta.nodeType)} · Fuente: ${_ephemerisSourceLabel(meta.ephemerisSource)}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6A625B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class AstroCuspsSidebar extends StatelessWidget {
  const AstroCuspsSidebar({
    super.key,
    required this.result,
    this.compact = false,
    this.classic = false,
  });

  final AstroNatalChartResult result;
  final bool compact;
  final bool classic;

  @override
  Widget build(BuildContext context) {
    final rows = <_CuspRowData>[
      _CuspRowData(
        label: 'AC',
        degree: result.angles.ascendant.degreeFormatted.split(' ').first,
        signIndex: result.angles.ascendant.signIndex,
      ),
      ...result.houses
          .where((house) => house.number >= 2 && house.number <= 9)
          .map(
            (house) => _CuspRowData(
              label: '${house.number}',
              degree: house.cuspDegreeFormatted.split(' ').first,
              signIndex: house.signIndex,
            ),
          ),
      _CuspRowData(
        label: 'MC',
        degree: result.angles.midheaven.degreeFormatted.split(' ').first,
        signIndex: result.angles.midheaven.signIndex,
      ),
      ...result.houses.where((house) => house.number >= 11).map(
            (house) => _CuspRowData(
              label: '${house.number}',
              degree: house.cuspDegreeFormatted.split(' ').first,
              signIndex: house.signIndex,
            ),
          ),
    ];

    return Container(
      width: compact ? double.infinity : 170,
      padding: EdgeInsets.all(compact
          ? 12
          : classic
              ? 10
              : 14),
      decoration: classic
          ? BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFBDB7AF)),
              borderRadius: BorderRadius.circular(4),
            )
          : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFCFC7BF)),
            ),
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: row.label.length > 1 ? 24 : 16,
                      child: Text(
                        row.label,
                        style: TextStyle(
                          fontSize: classic ? 12 : 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F1F1F),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.degree,
                        style: TextStyle(
                          fontSize: classic ? 12 : 13,
                          color: const Color(0xFF1F1F1F),
                        ),
                      ),
                    ),
                    Text(
                      _zodiacSigns[row.signIndex].glyph,
                      style: TextStyle(
                        fontSize: classic ? 16 : 18,
                        fontWeight: FontWeight.w700,
                        color: _zodiacSigns[row.signIndex].color,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CuspRowData {
  const _CuspRowData({
    required this.label,
    required this.degree,
    required this.signIndex,
  });

  final String label;
  final String degree;
  final int signIndex;
}

class AstroChartWheelLegend extends StatelessWidget {
  const AstroChartWheelLegend({
    super.key,
    required this.result,
  });

  final AstroNatalChartResult result;

  @override
  Widget build(BuildContext context) {
    final items = [
      ...result.planets.map(
        (planet) => _LegendItemData(
          glyph: _planetGlyph(planet.label),
          color: _planetColor(planet.label),
          title: _displayWheelLabel(planet.label),
          value:
              '${planet.sign} · ${planet.degreeFormatted} · Casa ${planet.house}${planet.retrograde ? ' · R' : ''}',
        ),
      ),
      ...result.points.map(
        (point) => _LegendItemData(
          glyph: _planetGlyph(point.label),
          color: _planetColor(point.label),
          title: _displayWheelLabel(point.label),
          value:
              '${point.sign} · ${point.degreeFormatted} · Casa ${point.house}${point.retrograde ? ' · R' : ''}',
        ),
      ),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items
          .map(
            (item) => SizedBox(
              width: 156,
              child: _LegendInfoChip(item: item),
            ),
          )
          .toList(),
    );
  }
}

class _WheelFactsPanel extends StatelessWidget {
  const _WheelFactsPanel({
    required this.result,
  });

  final AstroNatalChartResult result;

  @override
  Widget build(BuildContext context) {
    final meta = result.meta;
    final subjectName = meta.subjectName.trim().isEmpty
        ? 'Carta natal'
        : meta.subjectName.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF7F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5D9CB)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _FactPill(label: 'Carta', value: subjectName),
          _FactPill(
            label: 'Nacimiento',
            value: '${meta.birthDate} · ${meta.birthTime}',
          ),
          _FactPill(label: 'Ubicación', value: meta.locationLabel),
          _FactPill(label: 'Casas', value: _capitalize(meta.houseSystem)),
          _FactPill(label: 'Nodos', value: _nodeTypeLabel(meta.nodeType)),
          _FactPill(label: 'Lilith', value: _lilithTypeLabel(meta.lilithType)),
          _FactPill(
            label: 'Partes',
            value: _arabicPartsModeLabel(meta.arabicPartsMode),
          ),
          _FactPill(
            label: 'Fuente',
            value: _ephemerisSourceLabel(meta.ephemerisSource),
          ),
          _FactPill(
              label: 'AC', value: result.angles.ascendant.degreeFormatted),
          _FactPill(
              label: 'MC', value: result.angles.midheaven.degreeFormatted),
          if (meta.computedTechnicalPoints.isNotEmpty)
            _FactPill(
              label: 'Puntos',
              value: meta.computedTechnicalPoints
                  .map(_technicalPointShortLabel)
                  .join(' · '),
            ),
        ],
      ),
    );
  }
}

class _FactPill extends StatelessWidget {
  const _FactPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6D3BE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B625B),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C242A),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItemData {
  const _LegendItemData({
    required this.glyph,
    required this.color,
    required this.title,
    required this.value,
  });

  final String glyph;
  final Color color;
  final String title;
  final String value;
}

class _LegendInfoChip extends StatelessWidget {
  const _LegendInfoChip({
    required this.item,
  });

  final _LegendItemData item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F1E6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6D3BE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                item.glyph,
                style: TextStyle(
                  color: item.color,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF182127),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.value,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.3,
              color: Color(0xFF4B4844),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZodiacSignStyle {
  const _ZodiacSignStyle({
    required this.glyph,
    required this.color,
  });

  final String glyph;
  final Color color;
}

const _zodiacSigns = <_ZodiacSignStyle>[
  _ZodiacSignStyle(glyph: '♈', color: Color(0xFFE64524)),
  _ZodiacSignStyle(glyph: '♉', color: Color(0xFF47A31A)),
  _ZodiacSignStyle(glyph: '♊', color: Color(0xFFF07900)),
  _ZodiacSignStyle(glyph: '♋', color: Color(0xFF3467D9)),
  _ZodiacSignStyle(glyph: '♌', color: Color(0xFFD72E1E)),
  _ZodiacSignStyle(glyph: '♍', color: Color(0xFF3A8B1B)),
  _ZodiacSignStyle(glyph: '♎', color: Color(0xFFF07900)),
  _ZodiacSignStyle(glyph: '♏', color: Color(0xFF2049A8)),
  _ZodiacSignStyle(glyph: '♐', color: Color(0xFFD72E1E)),
  _ZodiacSignStyle(glyph: '♑', color: Color(0xFF3A8B1B)),
  _ZodiacSignStyle(glyph: '♒', color: Color(0xFFF07900)),
  _ZodiacSignStyle(glyph: '♓', color: Color(0xFF3467D9)),
];

Color _signBackgroundColor(int index) {
  return index.isEven ? const Color(0xFFFFFEFC) : const Color(0xFFFCF8F2);
}

Color _aspectColor(String type) {
  switch (type) {
    case 'Trigono':
      return const Color(0xFF2B5DDE);
    case 'Sextil':
      return const Color(0xFF2B8B57);
    case 'Conjuncion':
      return const Color(0xFF6C5A90);
    case 'Cuadratura':
      return const Color(0xFFE13A2D);
    case 'Oposicion':
      return const Color(0xFFCD2A1B);
    default:
      return const Color(0xFF6D6A67);
  }
}

Color _planetColor(String label) {
  switch (label) {
    case 'Sol':
      return const Color(0xFFF1AA00);
    case 'Luna':
      return const Color(0xFF8BA6E8);
    case 'Mercurio':
      return const Color(0xFF9D6B00);
    case 'Venus':
      return const Color(0xFF31A223);
    case 'Marte':
      return const Color(0xFFD9291C);
    case 'Jupiter':
      return const Color(0xFFEF6B00);
    case 'Saturno':
      return const Color(0xFF8A7B6E);
    case 'Urano':
      return const Color(0xFF255CE0);
    case 'Neptuno':
      return const Color(0xFF6A3DB3);
    case 'Pluton':
      return const Color(0xFF111111);
    case 'Nodo Norte':
      return const Color(0xFF3E8D25);
    case 'Nodo Sur':
      return const Color(0xFF5C9F3A);
    case 'Quiron':
      return const Color(0xFF6A3B18);
    case 'Lilith':
      return const Color(0xFF111111);
    case 'Parte Fortuna':
      return const Color(0xFF0A5B56);
    case 'Parte Infortunio':
      return const Color(0xFF9F3A2D);
    case 'Vertex':
      return const Color(0xFF514D9C);
    case 'Ceres':
      return const Color(0xFF3C8C65);
    case 'Palas':
      return const Color(0xFF3969C8);
    case 'Juno':
      return const Color(0xFF8B4CC7);
    case 'Vesta':
      return const Color(0xFFD68600);
    case 'Chariklo':
      return const Color(0xFF5B707E);
    case 'Eros':
      return const Color(0xFFB53C5A);
    case 'Eris':
      return const Color(0xFF4B4B4B);
    case 'Icaro':
      return const Color(0xFFCE5B1A);
    case 'Nessus':
      return const Color(0xFF6E2A7A);
    case 'Pholus':
      return const Color(0xFF226F5A);
    case 'Psique':
      return const Color(0xFF4C5FB4);
    default:
      return const Color(0xFF303030);
  }
}

String _planetGlyph(String label) {
  switch (label) {
    case 'Sol':
      return '☉';
    case 'Luna':
      return '☽';
    case 'Mercurio':
      return '☿';
    case 'Venus':
      return '♀';
    case 'Marte':
      return '♂';
    case 'Jupiter':
      return '♃';
    case 'Saturno':
      return '♄';
    case 'Urano':
      return '♅';
    case 'Neptuno':
      return '♆';
    case 'Pluton':
      return '♇';
    case 'Nodo Norte':
      return '☊';
    case 'Nodo Sur':
      return '☋';
    case 'Quiron':
      return '⚷';
    case 'Lilith':
      return '⚸';
    case 'Parte Fortuna':
      return '⊗';
    case 'Parte Infortunio':
      return '⊘';
    case 'Vertex':
      return 'Vx';
    case 'Ceres':
      return '⚳';
    case 'Palas':
      return '⚴';
    case 'Juno':
      return '⚵';
    case 'Vesta':
      return '⚶';
    case 'Chariklo':
      return 'Ch';
    case 'Eros':
      return 'Er';
    case 'Eris':
      return 'Ea';
    case 'Icaro':
      return 'Ic';
    case 'Nessus':
      return 'Ns';
    case 'Pholus':
      return 'Ph';
    case 'Psique':
      return 'Ψ';
    default:
      return '•';
  }
}

double _toCanvasRadians(double longitude, double ascLongitude) {
  final degrees = (180 + _normalizedDelta(ascLongitude, longitude)) % 360;
  return _degreesToRadians(degrees);
}

double _degreesToRadians(double value) => value * (math.pi / 180);

double _normalizedDelta(double start, double end) {
  final raw = (end - start) % 360;
  return raw < 0 ? raw + 360 : raw;
}

double normalizeLongitude(double value) {
  final raw = value % 360;
  return raw < 0 ? raw + 360 : raw;
}

double _clusterCenter(List<AstroPlacement> cluster) {
  if (cluster.length == 1) {
    return cluster.first.longitude;
  }

  final base = cluster.first.longitude;
  final adjusted = cluster.map((item) {
    final delta = _normalizedDelta(base, item.longitude);
    return base + delta;
  }).toList();
  final sum = adjusted.reduce((left, right) => left + right);
  return normalizeLongitude(sum / cluster.length);
}

bool _isTechnicalPoint(String label) {
  return label == 'Nodo Norte' ||
      label == 'Nodo Sur' ||
      label == 'Quiron' ||
      label == 'Lilith' ||
      label == 'Parte Fortuna' ||
      label == 'Parte Infortunio' ||
      label == 'Vertex' ||
      label == 'Ceres' ||
      label == 'Palas' ||
      label == 'Juno' ||
      label == 'Vesta' ||
      label == 'Chariklo' ||
      label == 'Eros' ||
      label == 'Eris' ||
      label == 'Icaro' ||
      label == 'Nessus' ||
      label == 'Pholus' ||
      label == 'Psique';
}

int _planetClusterLane(double centeredIndex, int count, bool isTechnicalPoint) {
  if (count <= 3) {
    return isTechnicalPoint && centeredIndex.abs() > 0.5 ? 1 : 0;
  }

  final distance = centeredIndex.abs();
  if (count <= 5) {
    return distance > 1 || (isTechnicalPoint && distance > 0.5) ? 1 : 0;
  }
  if (count <= 7) {
    return distance > 2
        ? 2
        : distance > 0.5
            ? 1
            : 0;
  }
  return distance > 3
      ? 3
      : distance > 1.5
          ? 2
          : 1;
}

String _formatDateLabel(String isoDate) {
  final parts = isoDate.split('-');
  if (parts.length == 3) {
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  return isoDate;
}

String _formatIsoDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _formatUtcTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  final second = value.second.toString().padLeft(2, '0');
  return '$hour:$minute:$second';
}

String _formatLatitude(double value) {
  final suffix = value >= 0 ? 'N' : 'S';
  return '${value.abs().toStringAsFixed(2)}$suffix';
}

String _formatLongitude(double value) {
  final suffix = value >= 0 ? 'E' : 'W';
  return '${value.abs().toStringAsFixed(2)}$suffix';
}

String _capitalize(String value) {
  if (value.isEmpty) {
    return value;
  }

  return '${value[0].toUpperCase()}${value.substring(1)}';
}

Offset _polarToOffset(Offset center, double radius, double radians) {
  return Offset(
    center.dx + (math.cos(radians) * radius),
    center.dy + (math.sin(radians) * radius),
  );
}

void _paintText(
  Canvas canvas,
  String text,
  Offset center, {
  double fontSize = 14,
  Color color = Colors.black,
  FontWeight fontWeight = FontWeight.w600,
  Color? glowColor,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: 1,
        shadows: glowColor == null
            ? null
            : [
                Shadow(
                  color: glowColor,
                  blurRadius: 4,
                ),
                Shadow(
                  color: glowColor,
                  blurRadius: 8,
                ),
              ],
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  painter.paint(
    canvas,
    Offset(center.dx - (painter.width / 2), center.dy - (painter.height / 2)),
  );
}

void _paintPositionLabel(
  Canvas canvas,
  AstroPlacement planet,
  Offset center, {
  double fontSize = 12,
}) {
  final position = _roundedPosition(planet.longitude);
  final degrees = position.degrees.toString().padLeft(2, '0');
  final minutes = position.minutes.toString().padLeft(2, '0');
  final signGlyph = _zodiacSigns[position.signIndex].glyph;
  final painter = TextPainter(
    text: TextSpan(
      children: [
        TextSpan(
          text: "$degrees°$minutes' ",
          style: TextStyle(
            color: const Color(0xFF3E3A35),
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            height: 1,
            shadows: const [
              Shadow(color: Colors.white, blurRadius: 4),
              Shadow(color: Colors.white, blurRadius: 8),
            ],
          ),
        ),
        TextSpan(
          text: signGlyph,
          style: TextStyle(
            color: _zodiacSigns[planet.signIndex].color,
            fontSize: fontSize + 1,
            fontWeight: FontWeight.w700,
            height: 1,
            shadows: const [
              Shadow(color: Colors.white, blurRadius: 4),
              Shadow(color: Colors.white, blurRadius: 8),
            ],
          ),
        ),
        if (planet.retrograde)
          TextSpan(
            text: ' ℞',
            style: TextStyle(
              color: const Color(0xFF3E3A35),
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              height: 1,
              shadows: const [
                Shadow(color: Colors.white, blurRadius: 4),
                Shadow(color: Colors.white, blurRadius: 8),
              ],
            ),
          ),
      ],
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  painter.paint(
    canvas,
    Offset(center.dx - (painter.width / 2), center.dy - (painter.height / 2)),
  );
}

({int signIndex, int degrees, int minutes}) _roundedPosition(double longitude) {
  final totalMinutes = (normalizeLongitude(longitude) * 60).round();
  final signIndex = ((totalMinutes ~/ 1800) % 12).clamp(0, 11);
  final inSignMinutes = totalMinutes % 1800;
  return (
    signIndex: signIndex,
    degrees: inSignMinutes ~/ 60,
    minutes: inSignMinutes % 60,
  );
}

String _nodeTypeLabel(String value) {
  return value == 'mean' ? 'Nodo medio' : 'Nodo verdadero';
}

String _lilithTypeLabel(String value) {
  return value == 'true' ? 'Verdadera' : 'Media';
}

String _arabicPartsModeLabel(String value) {
  return value == 'same' ? 'Día = Noche' : 'Día ≠ Noche';
}

String _ephemerisSourceLabel(String value) {
  switch (value) {
    case 'swisseph':
      return 'Swiss Ephemeris';
    case 'moshier':
      return 'Moshier';
    case 'astronomy-engine':
      return 'Astronomy Engine';
    default:
      return value;
  }
}

String _technicalPointShortLabel(String key) {
  switch (key) {
    case 'north_node':
      return 'Nodo N.';
    case 'south_node':
      return 'Nodo S.';
    case 'chiron':
      return 'Quirón';
    case 'lilith':
      return 'Lilith';
    case 'fortune':
      return 'Fortuna';
    case 'misfortune':
      return 'Infortunio';
    case 'vertex':
      return 'Vertex';
    case 'ceres':
      return 'Ceres';
    case 'pallas':
      return 'Palas';
    case 'juno':
      return 'Juno';
    case 'vesta':
      return 'Vesta';
    case 'chariklo':
      return 'Chariklo';
    case 'eros':
      return 'Eros';
    case 'eris':
      return 'Eris';
    case 'icarus':
      return 'Ícaro';
    case 'nessus':
      return 'Nessus';
    case 'pholus':
      return 'Pholus';
    case 'psyche':
      return 'Psique';
    default:
      return key;
  }
}

String _displayWheelLabel(String value) {
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
