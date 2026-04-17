import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../models/astro_models.dart';

part 'astro_chart_wheel_support.dart';

class AstroChartWheelCard extends StatelessWidget {
  const AstroChartWheelCard({
    super.key,
    required this.result,
  });

  final AstroNatalChartResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final wheelSize = math.min(maxWidth, 390.0).clamp(260.0, 390.0);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rueda natal',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'La rueda muestra signos, casas, grados, ejes y aspectos con una lectura más técnica. Debajo queda la ficha resumida para revisar posiciones y cúspides con claridad.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                AstroChartTechnicalHeader(result: result),
                const SizedBox(height: 18),
                Center(
                  child: AstroChartWheelGraphic(
                    result: result,
                    size: wheelSize,
                    showPlanetDegreeLabels: true,
                  ),
                ),
                const SizedBox(height: 18),
                AstroCuspsSidebar(
                  result: result,
                  compact: true,
                ),
                const SizedBox(height: 14),
                _WheelFactsPanel(result: result),
                const SizedBox(height: 14),
                AstroChartWheelLegend(result: result),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AstroChartExportBoard extends StatelessWidget {
  const AstroChartExportBoard({
    super.key,
    required this.result,
    required this.size,
  });

  final AstroNatalChartResult result;
  final double size;

  @override
  Widget build(BuildContext context) {
    final width = size;
    final height = size * 0.74;
    final wheelSize = math.min(height * 0.94, width * 0.57);

    return Container(
      width: width,
      height: height,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(32, 24, 28, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.205,
            child: AstroChartTechnicalHeader(
              result: result,
              classic: true,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Center(
              child: AstroChartWheelGraphic(
                result: result,
                size: wheelSize,
                showPlanetDegreeLabels: true,
              ),
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: width * 0.14,
            child: AstroCuspsSidebar(
              result: result,
              classic: true,
            ),
          ),
        ],
      ),
    );
  }
}

class AstroChartWheelGraphic extends StatelessWidget {
  const AstroChartWheelGraphic({
    super.key,
    required this.result,
    required this.size,
    this.showPlanetDegreeLabels = true,
  });

  final AstroNatalChartResult result;
  final double size;
  final bool showPlanetDegreeLabels;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AstroChartWheelPainter(
          result: result,
          showPlanetDegreeLabels: showPlanetDegreeLabels,
        ),
      ),
    );
  }
}

class _AstroChartWheelPainter extends CustomPainter {
  const _AstroChartWheelPainter({
    required this.result,
    required this.showPlanetDegreeLabels,
  });

  final AstroNatalChartResult result;
  final bool showPlanetDegreeLabels;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final outerRadius = radius - 8;
    final signOuterRadius = outerRadius;
    final signInnerRadius = radius * 0.78;
    final houseOuterRadius = radius * 0.59;
    final houseInnerRadius = radius * 0.40;
    final aspectRadius = radius * 0.34;
    final ascLongitude = result.angles.ascendant.longitude;

    _drawBaseRings(
      canvas,
      center,
      outerRadius,
      signInnerRadius,
      houseOuterRadius,
      houseInnerRadius,
    );
    _drawSignSectors(
      canvas,
      center,
      ascLongitude,
      signOuterRadius,
      signInnerRadius,
    );
    _drawTicks(canvas, center, ascLongitude, signOuterRadius, signInnerRadius);
    _drawAngleAxes(
      canvas,
      center,
      ascLongitude,
      outerRadius,
      signInnerRadius,
      houseInnerRadius,
    );
    _drawHouseCusps(
      canvas,
      center,
      ascLongitude,
      signInnerRadius,
      houseOuterRadius,
      houseInnerRadius,
    );
    _drawAspects(canvas, center, ascLongitude, aspectRadius);
    _drawPlanets(
      canvas,
      center,
      ascLongitude,
      signInnerRadius,
      houseOuterRadius,
      outerRadius,
    );
    _drawHouseNumbers(
      canvas,
      center,
      ascLongitude,
      houseOuterRadius,
      houseInnerRadius,
    );
  }

  void _drawBaseRings(
    Canvas canvas,
    Offset center,
    double outerRadius,
    double signInnerRadius,
    double houseOuterRadius,
    double houseInnerRadius,
  ) {
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFF203A64)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;

    canvas.drawCircle(center, outerRadius, fillPaint);
    canvas.drawCircle(center, outerRadius, strokePaint);
    canvas.drawCircle(center, signInnerRadius, strokePaint);
    canvas.drawCircle(
      center,
      outerRadius - 12,
      Paint()
        ..color = const Color(0xFF203A64)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    canvas.drawCircle(
      center,
      houseOuterRadius,
      Paint()
        ..color = const Color(0xFF1E3762)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawCircle(
      center,
      houseInnerRadius,
      Paint()
        ..color = const Color(0xFF8F8A85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  void _drawSignSectors(
    Canvas canvas,
    Offset center,
    double ascLongitude,
    double outerRadius,
    double innerRadius,
  ) {
    final rect = Rect.fromCircle(center: center, radius: outerRadius);
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    for (var index = 0; index < _zodiacSigns.length; index++) {
      final startLongitude = index * 30.0;
      final startAngle = _toCanvasRadians(startLongitude, ascLongitude);
      final sweep = _degreesToRadians(30);
      final sectorPaint = Paint()
        ..color = _signBackgroundColor(index)
        ..style = PaintingStyle.fill;

      final path = Path()
        ..arcTo(rect, startAngle, sweep, false)
        ..arcTo(innerRect, startAngle + sweep, -sweep, false)
        ..close();
      canvas.drawPath(path, sectorPaint);

      final borderPaint = Paint()
        ..color = const Color(0xFF1E3762)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      final startPoint = _polarToOffset(center, innerRadius, startAngle);
      final endPoint = _polarToOffset(center, outerRadius, startAngle);
      canvas.drawLine(startPoint, endPoint, borderPaint);

      final middleAngle = startAngle + (sweep / 2);
      final glyphOffset =
          _polarToOffset(center, (outerRadius + innerRadius) / 2, middleAngle);
      _paintText(
        canvas,
        _zodiacSigns[index].glyph,
        glyphOffset,
        fontSize: outerRadius * 0.1,
        color: _zodiacSigns[index].color,
        fontWeight: FontWeight.w700,
        glowColor: Colors.white,
      );
    }
  }

  void _drawTicks(
    Canvas canvas,
    Offset center,
    double ascLongitude,
    double outerRadius,
    double innerRadius,
  ) {
    final tickPaint = Paint()
      ..color = const Color(0xFF203A64)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var degree = 0; degree < 360; degree += 1) {
      final angle = _toCanvasRadians(degree.toDouble(), ascLongitude);
      final isMajor = degree % 10 == 0;
      final isMedium = degree % 5 == 0;
      final startRadius = isMajor
          ? outerRadius - 14
          : isMedium
              ? outerRadius - 9
              : outerRadius - 5;
      tickPaint.strokeWidth = isMajor
          ? 1.05
          : isMedium
              ? 0.75
              : 0.45;
      final start = _polarToOffset(center, startRadius, angle);
      final end = _polarToOffset(center, outerRadius, angle);
      canvas.drawLine(start, end, tickPaint);
    }

    canvas.drawCircle(
      center,
      innerRadius,
      Paint()
        ..color = const Color(0xFF203A64)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawAngleAxes(
    Canvas canvas,
    Offset center,
    double ascLongitude,
    double outerRadius,
    double signInnerRadius,
    double houseInnerRadius,
  ) {
    final horizontalPaint = Paint()
      ..color = const Color(0xFF9D2F2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final verticalPaint = Paint()
      ..color = const Color(0xFF315FB0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final acAngle =
        _toCanvasRadians(result.angles.ascendant.longitude, ascLongitude);
    final dcAngle = _toCanvasRadians(
      (result.angles.ascendant.longitude + 180) % 360,
      ascLongitude,
    );
    final mcAngle =
        _toCanvasRadians(result.angles.midheaven.longitude, ascLongitude);
    final icAngle = _toCanvasRadians(
      (result.angles.midheaven.longitude + 180) % 360,
      ascLongitude,
    );

    canvas.drawLine(
      _polarToOffset(center, outerRadius - 12, acAngle),
      _polarToOffset(center, outerRadius - 12, dcAngle),
      horizontalPaint,
    );
    canvas.drawLine(
      _polarToOffset(center, outerRadius - 12, mcAngle),
      _polarToOffset(center, outerRadius - 12, icAngle),
      verticalPaint,
    );

    final axes = [
      (acAngle, 'AC', horizontalPaint.color),
      (dcAngle, 'DC', horizontalPaint.color),
      (mcAngle, 'MC', verticalPaint.color),
      (icAngle, 'IC', verticalPaint.color),
    ];

    for (final axis in axes) {
      final labelOffset = _polarToOffset(center, signInnerRadius - 10, axis.$1);
      _paintText(
        canvas,
        axis.$2,
        labelOffset,
        fontSize: signInnerRadius * 0.032,
        color: axis.$3,
        fontWeight: FontWeight.w700,
      );
    }
  }

  void _drawHouseCusps(
    Canvas canvas,
    Offset center,
    double ascLongitude,
    double signInnerRadius,
    double houseOuterRadius,
    double houseInnerRadius,
  ) {
    final linePaint = Paint()
      ..color = const Color(0xFF7E7872)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    final anglePaint = Paint()
      ..color = const Color(0xFF2C55A0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (final house in result.houses) {
      final angle = _toCanvasRadians(house.cuspLongitude, ascLongitude);
      final isAngleHouse = house.number == 1 ||
          house.number == 4 ||
          house.number == 7 ||
          house.number == 10;
      final start = _polarToOffset(center, houseInnerRadius, angle);
      final end = _polarToOffset(center, signInnerRadius, angle);
      canvas.drawLine(start, end, isAngleHouse ? anglePaint : linePaint);
    }
  }

  void _drawHouseNumbers(
    Canvas canvas,
    Offset center,
    double ascLongitude,
    double houseOuterRadius,
    double houseInnerRadius,
  ) {
    final houses = result.houses;
    for (var index = 0; index < houses.length; index++) {
      final current = houses[index];
      final next = houses[(index + 1) % houses.length];
      final delta = _normalizedDelta(current.cuspLongitude, next.cuspLongitude);
      final middleLongitude = (current.cuspLongitude + (delta / 2)) % 360;
      final angle = _toCanvasRadians(middleLongitude, ascLongitude);
      final labelRadius = (houseOuterRadius + houseInnerRadius) / 2;
      final labelOffset = _polarToOffset(center, labelRadius, angle);
      _paintText(
        canvas,
        current.number.toString(),
        labelOffset,
        fontSize: houseOuterRadius * 0.12,
        color: const Color(0xFF32312E),
        fontWeight: FontWeight.w500,
      );
    }
  }

  void _drawAspects(
    Canvas canvas,
    Offset center,
    double ascLongitude,
    double aspectRadius,
  ) {
    final planetMap = {
      for (final planet in result.planets) planet.label: planet,
    };

    for (final aspect in result.aspects.take(18)) {
      final left = planetMap[aspect.left];
      final right = planetMap[aspect.right];
      if (left == null || right == null) {
        continue;
      }

      final start = _polarToOffset(
        center,
        aspectRadius,
        _toCanvasRadians(left.longitude, ascLongitude),
      );
      final end = _polarToOffset(
        center,
        aspectRadius,
        _toCanvasRadians(right.longitude, ascLongitude),
      );

      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = _aspectColor(aspect.type)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  void _drawPlanets(
    Canvas canvas,
    Offset center,
    double ascLongitude,
    double signInnerRadius,
    double houseOuterRadius,
    double outerRadius,
  ) {
    final sorted = result.planets.toList()
      ..addAll(result.points)
      ..sort((left, right) => left.longitude.compareTo(right.longitude));
    final placements = _spreadPlanets(sorted);

    for (final placement in placements) {
      final exactAngle =
          _toCanvasRadians(placement.planet.longitude, ascLongitude);
      final displayAngle = _toCanvasRadians(
        placement.displayLongitude,
        ascLongitude,
      );
      final anchorOffset =
          _polarToOffset(center, signInnerRadius - 4, exactAngle);
      final orbitRadius = signInnerRadius - 20 - (placement.lane * 15);
      final glyphOffset = _polarToOffset(center, orbitRadius, displayAngle);
      final degreeRadius = orbitRadius - 18;
      final degreeOffset = _polarToOffset(center, degreeRadius, displayAngle);
      final tangentDirection = math.sin(displayAngle) >= 0 ? 1.0 : -1.0;
      final tangentOffset = Offset(
        math.cos(displayAngle + (math.pi / 2)) * (8 * tangentDirection),
        math.sin(displayAngle + (math.pi / 2)) * (8 * tangentDirection),
      );
      final radialOffset = Offset(
        math.cos(displayAngle) * (placement.lane * 1.8),
        math.sin(displayAngle) * (placement.lane * 1.8),
      );
      final labelOffset = degreeOffset + tangentOffset + radialOffset;

      canvas.drawCircle(
        anchorOffset,
        outerRadius * 0.006,
        Paint()
          ..color = _planetColor(placement.planet.label)
          ..style = PaintingStyle.fill,
      );
      canvas.drawLine(
        anchorOffset,
        glyphOffset,
        Paint()
          ..color = const Color(0xFF8C847C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
      _paintText(
        canvas,
        _planetGlyph(placement.planet.label),
        glyphOffset,
        fontSize: _isTechnicalPoint(placement.planet.label)
            ? outerRadius * 0.048
            : outerRadius * 0.056,
        color: _planetColor(placement.planet.label),
        fontWeight: FontWeight.w700,
        glowColor: Colors.white,
      );

      if (showPlanetDegreeLabels) {
        _paintPositionLabel(
          canvas,
          placement.planet,
          labelOffset,
          fontSize: outerRadius * 0.022,
        );
      }
    }
  }

  List<_PlanetPlacement> _spreadPlanets(List<AstroPlacement> planets) {
    if (planets.isEmpty) {
      return const <_PlanetPlacement>[];
    }

    const clusterThreshold = 10.5;
    final clusters = <List<AstroPlacement>>[];
    var currentCluster = <AstroPlacement>[planets.first];

    for (var index = 1; index < planets.length; index++) {
      final previous = planets[index - 1];
      final current = planets[index];
      if (_normalizedDelta(previous.longitude, current.longitude) <=
          clusterThreshold) {
        currentCluster.add(current);
      } else {
        clusters.add(currentCluster);
        currentCluster = <AstroPlacement>[current];
      }
    }
    clusters.add(currentCluster);

    if (clusters.length > 1) {
      final firstCluster = clusters.first;
      final lastCluster = clusters.last;
      final wrapDelta = _normalizedDelta(
        lastCluster.last.longitude,
        firstCluster.first.longitude + 360,
      );
      if (wrapDelta <= clusterThreshold) {
        final merged = <AstroPlacement>[
          ...lastCluster,
          ...firstCluster,
        ];
        clusters
          ..removeLast()
          ..removeAt(0)
          ..insert(0, merged);
      }
    }

    final placements = <_PlanetPlacement>[];
    for (final cluster in clusters) {
      final count = cluster.length;
      final centerLongitude = _clusterCenter(cluster);
      final minGap = count >= 7
          ? 5.2
          : count >= 5
              ? 5.8
              : 6.4;
      final startLongitude = centerLongitude - ((count - 1) * minGap / 2);
      for (var index = 0; index < count; index++) {
        final centeredIndex = index - ((count - 1) / 2);
        final lane = _planetClusterLane(
          centeredIndex,
          count,
          _isTechnicalPoint(cluster[index].label),
        );
        placements.add(
          _PlanetPlacement(
            planet: cluster[index],
            lane: lane,
            displayLongitude:
                normalizeLongitude(startLongitude + (index * minGap)),
          ),
        );
      }
    }

    return placements;
  }

  @override
  bool shouldRepaint(covariant _AstroChartWheelPainter oldDelegate) {
    return oldDelegate.result != result ||
        oldDelegate.showPlanetDegreeLabels != showPlanetDegreeLabels;
  }
}

class _PlanetPlacement {
  const _PlanetPlacement({
    required this.planet,
    required this.lane,
    required this.displayLongitude,
  });

  final AstroPlacement planet;
  final int lane;
  final double displayLongitude;
}
