import 'dart:math' as math;

import 'package:flutter/material.dart';

class RenacienteLogoMark extends StatelessWidget {
  const RenacienteLogoMark({
    super.key,
    this.size = 72,
    this.backgroundColor = const Color(0x14FFFFFF),
    this.accentColor = const Color(0xFF182127),
    this.glowColor = const Color(0xFFD9A04C),
    this.surfaceColor = Colors.white,
    this.showHalo = true,
  });

  final double size;
  final Color backgroundColor;
  final Color accentColor;
  final Color glowColor;
  final Color surfaceColor;
  final bool showHalo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showHalo)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    glowColor.withValues(alpha: 0.22),
                    backgroundColor,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          CustomPaint(
            size: Size.square(size),
            painter: _RenacienteLogoPainter(
              accentColor: accentColor,
              glowColor: glowColor,
              surfaceColor: surfaceColor,
            ),
          ),
        ],
      ),
    );
  }
}

class RenacienteLogoLockup extends StatelessWidget {
  const RenacienteLogoLockup({
    super.key,
    this.markSize = 68,
    this.foregroundColor = const Color(0xFF182127),
    this.secondaryColor = const Color(0xFF6E6256),
    this.align = CrossAxisAlignment.center,
    this.showTagline = false,
    this.tagline,
    this.center = true,
  });

  final double markSize;
  final Color foregroundColor;
  final Color secondaryColor;
  final CrossAxisAlignment align;
  final bool showTagline;
  final String? tagline;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final textAlign = center ? TextAlign.center : TextAlign.start;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: align,
      children: [
        RenacienteLogoMark(
          size: markSize,
          accentColor: foregroundColor,
          glowColor: const Color(0xFFD59A62),
          surfaceColor: const Color(0xFFFFFAF4),
        ),
        const SizedBox(height: 12),
        Text(
          'Lo Renaciente',
          textAlign: textAlign,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            tagline ?? 'Claridad, símbolo y dirección',
            textAlign: textAlign,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }
}

class _RenacienteLogoPainter extends CustomPainter {
  const _RenacienteLogoPainter({
    required this.accentColor,
    required this.glowColor,
    required this.surfaceColor,
  });

  final Color accentColor;
  final Color glowColor;
  final Color surfaceColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final ringPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.075;

    final innerPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.05;

    final sparkPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.fill;

    final cutPaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;

    final ringRect = Rect.fromCircle(
      center: center,
      radius: radius * 0.36,
    );
    canvas.drawArc(
      ringRect,
      math.pi * 0.16,
      math.pi * 1.7,
      false,
      ringPaint,
    );

    final lowerOrbitRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + size.height * 0.07),
      width: size.width * 0.34,
      height: size.height * 0.18,
    );
    canvas.drawArc(
      lowerOrbitRect,
      math.pi * 0.15,
      math.pi * 0.72,
      false,
      innerPaint,
    );

    final spark = Path()
      ..moveTo(center.dx, center.dy - size.height * 0.18)
      ..lineTo(center.dx + size.width * 0.05, center.dy - size.height * 0.05)
      ..lineTo(center.dx + size.width * 0.18, center.dy)
      ..lineTo(center.dx + size.width * 0.05, center.dy + size.height * 0.05)
      ..lineTo(center.dx, center.dy + size.height * 0.18)
      ..lineTo(center.dx - size.width * 0.05, center.dy + size.height * 0.05)
      ..lineTo(center.dx - size.width * 0.18, center.dy)
      ..lineTo(center.dx - size.width * 0.05, center.dy - size.height * 0.05)
      ..close();
    canvas.drawPath(spark, sparkPaint);

    final cut = Path()
      ..addOval(
        Rect.fromCenter(
          center: center,
          width: size.width * 0.11,
          height: size.height * 0.11,
        ),
      );
    canvas.drawPath(cut, cutPaint);

    canvas.drawCircle(
      Offset(center.dx + size.width * 0.25, center.dy - size.height * 0.2),
      size.width * 0.045,
      dotPaint,
    );

    canvas.drawCircle(
      Offset(center.dx - size.width * 0.22, center.dy + size.height * 0.2),
      size.width * 0.018,
      Paint()
        ..color = accentColor.withValues(alpha: 0.28)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _RenacienteLogoPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.surfaceColor != surfaceColor;
  }
}
