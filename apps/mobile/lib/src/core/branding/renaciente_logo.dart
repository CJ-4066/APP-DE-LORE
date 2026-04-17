import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

const String renacienteLogoAsset = 'assets/branding/lo-renaciente-isotipo.png';
const String renacienteAppIconAsset =
    'assets/branding/lo-renaciente-app-icon.png';

class RenacienteLogoMark extends StatelessWidget {
  const RenacienteLogoMark({
    super.key,
    this.size = 72,
    this.backgroundColor = const Color(0x14FFFFFF),
    this.accentColor = AppPalette.indigo,
    this.wingInsetColor = AppPalette.orchid,
    this.glowColor = AppPalette.flameGold,
    this.surfaceColor = AppPalette.moonIvory,
    this.showHalo = true,
    this.useImageAsset = true,
    this.assetPath = renacienteLogoAsset,
  });

  final double size;
  final Color backgroundColor;
  final Color accentColor;
  final Color wingInsetColor;
  final Color glowColor;
  final Color surfaceColor;
  final bool showHalo;
  final bool useImageAsset;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final vectorMark = CustomPaint(
      size: Size.square(size),
      painter: _RenacienteLogoPainter(
        accentColor: accentColor,
        insetColor: wingInsetColor,
      ),
    );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showHalo && !useImageAsset)
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
          if (useImageAsset)
            _RenacienteImageLogoMark(
              size: size,
              assetPath: assetPath,
              fallback: vectorMark,
            )
          else
            vectorMark,
        ],
      ),
    );
  }
}

class RenacienteAnimatedLogoMark extends StatefulWidget {
  const RenacienteAnimatedLogoMark({
    super.key,
    this.size = 72,
    this.accentColor = AppPalette.indigo,
    this.wingInsetColor = AppPalette.orchid,
    this.glowColor = AppPalette.flameGold,
    this.surfaceColor = AppPalette.moonIvory,
    this.useImageAsset = true,
    this.assetPath = renacienteLogoAsset,
    this.duration = const Duration(milliseconds: 7200),
  });

  final double size;
  final Color accentColor;
  final Color wingInsetColor;
  final Color glowColor;
  final Color surfaceColor;
  final bool useImageAsset;
  final String assetPath;
  final Duration duration;

  @override
  State<RenacienteAnimatedLogoMark> createState() =>
      _RenacienteAnimatedLogoMarkState();
}

class _RenacienteAnimatedLogoMarkState extends State<RenacienteAnimatedLogoMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final orbit = _controller.value * math.pi * 2;
        final flapWave = math.sin(orbit * 3.8);
        final flapProgress = 0.5 + 0.5 * flapWave;
        final bodyLift = math.sin(orbit * 1.4) * widget.size * 0.018;
        final bodyYaw = math.sin(orbit * 0.8) * 0.08;
        final bodyRoll = math.sin(orbit * 1.2) * 0.025;
        final bodyPitch = -(0.02 + flapProgress * 0.08);
        final auraColor =
            Color.lerp(widget.glowColor, widget.surfaceColor, 0.32) ??
                widget.glowColor;
        final auraOpacity = 0.06 + flapProgress * 0.12;
        final shadowWidth = widget.size * (0.36 + (1 - flapProgress) * 0.2);
        final shadowBlur = 10 + (1 - flapProgress) * 12;
        final shadowColor = widget.accentColor.withValues(alpha: 0.18);
        final leftWingMatrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0022)
          ..rotateX(-(0.1 + flapProgress * 0.34))
          ..rotateY(0.12 + flapProgress * 0.82)
          ..rotateZ(-(0.03 + flapProgress * 0.14));
        final rightWingMatrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0022)
          ..rotateX(-(0.1 + flapProgress * 0.34))
          ..rotateY(-(0.12 + flapProgress * 0.82))
          ..rotateZ(0.03 + flapProgress * 0.14);

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: widget.size * 0.02,
                child: Container(
                  width: shadowWidth,
                  height: widget.size * 0.14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.size),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: shadowBlur,
                        spreadRadius: 1.5,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: widget.size * 1.08,
                height: widget.size * 1.08,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      auraColor.withValues(alpha: auraOpacity),
                      widget.glowColor.withValues(alpha: auraOpacity * 0.42),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.56, 1],
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, bodyLift),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0018)
                    ..rotateX(bodyPitch)
                    ..rotateY(bodyYaw)
                    ..rotateZ(bodyRoll),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform(
                        alignment: const Alignment(-0.04, 0.02),
                        transform: leftWingMatrix,
                        child: CustomPaint(
                          size: Size.square(widget.size),
                          painter: _RenacienteWingPainter(
                            side: _WingSide.left,
                            accentColor: widget.accentColor,
                            insetColor: widget.wingInsetColor,
                          ),
                        ),
                      ),
                      Transform(
                        alignment: const Alignment(0.04, 0.02),
                        transform: rightWingMatrix,
                        child: CustomPaint(
                          size: Size.square(widget.size),
                          painter: _RenacienteWingPainter(
                            side: _WingSide.right,
                            accentColor: widget.accentColor,
                            insetColor: widget.wingInsetColor,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(
                            0, -widget.size * (0.004 + flapProgress * 0.01)),
                        child: Transform.scale(
                          scale: 0.99 + flapProgress * 0.025,
                          child: CustomPaint(
                            size: Size.square(widget.size),
                            painter: _RenacienteBodyPainter(
                              accentColor: widget.accentColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _WingSide {
  left,
  right,
}

class _RenacienteWingPainter extends CustomPainter {
  const _RenacienteWingPainter({
    required this.side,
    required this.accentColor,
    required this.insetColor,
  });

  final _WingSide side;
  final Color accentColor;
  final Color insetColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final unit = size.width / 1024;

    Offset p(double x, double y) => Offset(x * unit, y * unit);

    Path mirror(Path path) => path
        .shift(Offset(-center.dx, 0))
        .transform(Matrix4.diagonal3Values(-1, 1, 1).storage)
        .shift(Offset(center.dx, 0));

    Path sidePath(Path path) {
      return side == _WingSide.left ? path : mirror(path);
    }

    final wingPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final insetPaint = Paint()
      ..color = insetColor.withValues(alpha: 0.94)
      ..style = PaintingStyle.fill;

    final upperWing = Path()
      ..moveTo(p(494, 506).dx, p(494, 506).dy)
      ..cubicTo(p(412, 382).dx, p(412, 382).dy, p(237, 257).dx, p(237, 257).dy,
          p(112, 253).dx, p(112, 253).dy)
      ..cubicTo(p(72, 343).dx, p(72, 343).dy, p(139, 535).dx, p(139, 535).dy,
          p(274, 586).dx, p(274, 586).dy)
      ..cubicTo(p(374, 625).dx, p(374, 625).dy, p(454, 575).dx, p(454, 575).dy,
          p(494, 506).dx, p(494, 506).dy)
      ..close();
    canvas.drawPath(sidePath(upperWing), wingPaint);

    final lowerWing = Path()
      ..moveTo(p(489, 536).dx, p(489, 536).dy)
      ..cubicTo(p(414, 582).dx, p(414, 582).dy, p(337, 662).dx, p(337, 662).dy,
          p(253, 762).dx, p(253, 762).dy)
      ..cubicTo(p(163, 738).dx, p(163, 738).dy, p(119, 657).dx, p(119, 657).dy,
          p(151, 591).dx, p(151, 591).dy)
      ..cubicTo(p(190, 511).dx, p(190, 511).dy, p(355, 501).dx, p(355, 501).dy,
          p(489, 536).dx, p(489, 536).dy)
      ..close();
    canvas.drawPath(sidePath(lowerWing), wingPaint);

    final upperInset = Path()
      ..moveTo(p(203, 343).dx, p(203, 343).dy)
      ..cubicTo(p(272, 334).dx, p(272, 334).dy, p(354, 374).dx, p(354, 374).dy,
          p(427, 454).dx, p(427, 454).dy)
      ..cubicTo(p(333, 433).dx, p(333, 433).dy, p(239, 407).dx, p(239, 407).dy,
          p(174, 401).dx, p(174, 401).dy)
      ..cubicTo(p(165, 376).dx, p(165, 376).dy, p(176, 351).dx, p(176, 351).dy,
          p(203, 343).dx, p(203, 343).dy)
      ..close();
    canvas.drawPath(sidePath(upperInset), insetPaint);

    final middleInset = Path()
      ..moveTo(p(191, 474).dx, p(191, 474).dy)
      ..cubicTo(p(274, 462).dx, p(274, 462).dy, p(350, 478).dx, p(350, 478).dy,
          p(432, 514).dx, p(432, 514).dy)
      ..cubicTo(p(345, 523).dx, p(345, 523).dy, p(263, 524).dx, p(263, 524).dy,
          p(191, 516).dx, p(191, 516).dy)
      ..cubicTo(p(175, 503).dx, p(175, 503).dy, p(175, 486).dx, p(175, 486).dy,
          p(191, 474).dx, p(191, 474).dy)
      ..close();
    canvas.drawPath(sidePath(middleInset), insetPaint);

    final lowerInset = Path()
      ..moveTo(p(252, 640).dx, p(252, 640).dy)
      ..cubicTo(p(301, 597).dx, p(301, 597).dy, p(358, 569).dx, p(358, 569).dy,
          p(438, 547).dx, p(438, 547).dy)
      ..cubicTo(p(383, 619).dx, p(383, 619).dy, p(337, 680).dx, p(337, 680).dy,
          p(282, 722).dx, p(282, 722).dy)
      ..cubicTo(p(253, 710).dx, p(253, 710).dy, p(239, 681).dx, p(239, 681).dy,
          p(252, 640).dx, p(252, 640).dy)
      ..close();
    canvas.drawPath(sidePath(lowerInset), insetPaint);
  }

  @override
  bool shouldRepaint(covariant _RenacienteWingPainter oldDelegate) {
    return oldDelegate.side != side ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.insetColor != insetColor;
  }
}

class _RenacienteBodyPainter extends CustomPainter {
  const _RenacienteBodyPainter({
    required this.accentColor,
  });

  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final unit = size.width / 1024;

    Offset p(double x, double y) => Offset(x * unit, y * unit);

    final linePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 19 * unit;

    final bodyPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    canvas.drawLine(p(511, 347), p(511, 718), linePaint);
    canvas.drawPath(
      Path()
        ..moveTo(p(507, 352).dx, p(507, 352).dy)
        ..cubicTo(
          p(482, 328).dx,
          p(482, 328).dy,
          p(449, 313).dx,
          p(449, 313).dy,
          p(421, 314).dx,
          p(421, 314).dy,
        ),
      linePaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(p(517, 352).dx, p(517, 352).dy)
        ..cubicTo(
          p(542, 328).dx,
          p(542, 328).dy,
          p(575, 313).dx,
          p(575, 313).dy,
          p(603, 314).dx,
          p(603, 314).dy,
        ),
      linePaint,
    );

    canvas.drawOval(
      Rect.fromCenter(center: center, width: 68 * unit, height: 132 * unit),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: p(512, 429), width: 52 * unit, height: 72 * unit),
      bodyPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RenacienteBodyPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor;
  }
}

class RenacienteLogoLockup extends StatelessWidget {
  const RenacienteLogoLockup({
    super.key,
    this.markSize = 68,
    this.foregroundColor = AppPalette.indigo,
    this.secondaryColor = AppPalette.mutedLavender,
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
          wingInsetColor: AppPalette.orchid,
          glowColor: AppPalette.flameGold,
          surfaceColor: AppPalette.moonIvory,
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

class _RenacienteImageLogoMark extends StatelessWidget {
  const _RenacienteImageLogoMark({
    required this.size,
    required this.assetPath,
    required this.fallback,
  });

  final double size;
  final String assetPath;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(size * 0.06),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}

class _RenacienteLogoPainter extends CustomPainter {
  const _RenacienteLogoPainter({
    required this.accentColor,
    required this.insetColor,
  });

  final Color accentColor;
  final Color insetColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final unit = size.width / 1024;

    Offset p(double x, double y) => Offset(x * unit, y * unit);

    Path mirror(Path path) => path
        .shift(Offset(-center.dx, 0))
        .transform(Matrix4.diagonal3Values(-1, 1, 1).storage)
        .shift(Offset(center.dx, 0));

    final wingPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final insetPaint = Paint()
      ..color = insetColor.withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 19 * unit;

    final bodyPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final upperWing = Path()
      ..moveTo(p(494, 506).dx, p(494, 506).dy)
      ..cubicTo(p(412, 382).dx, p(412, 382).dy, p(237, 257).dx, p(237, 257).dy,
          p(112, 253).dx, p(112, 253).dy)
      ..cubicTo(p(72, 343).dx, p(72, 343).dy, p(139, 535).dx, p(139, 535).dy,
          p(274, 586).dx, p(274, 586).dy)
      ..cubicTo(p(374, 625).dx, p(374, 625).dy, p(454, 575).dx, p(454, 575).dy,
          p(494, 506).dx, p(494, 506).dy)
      ..close();
    canvas.drawPath(upperWing, wingPaint);
    canvas.drawPath(mirror(upperWing), wingPaint);

    final lowerWing = Path()
      ..moveTo(p(489, 536).dx, p(489, 536).dy)
      ..cubicTo(p(414, 582).dx, p(414, 582).dy, p(337, 662).dx, p(337, 662).dy,
          p(253, 762).dx, p(253, 762).dy)
      ..cubicTo(p(163, 738).dx, p(163, 738).dy, p(119, 657).dx, p(119, 657).dy,
          p(151, 591).dx, p(151, 591).dy)
      ..cubicTo(p(190, 511).dx, p(190, 511).dy, p(355, 501).dx, p(355, 501).dy,
          p(489, 536).dx, p(489, 536).dy)
      ..close();
    canvas.drawPath(lowerWing, wingPaint);
    canvas.drawPath(mirror(lowerWing), wingPaint);

    void drawInset(Path path) {
      canvas.drawPath(path, insetPaint);
      canvas.drawPath(mirror(path), insetPaint);
    }

    drawInset(Path()
      ..moveTo(p(203, 343).dx, p(203, 343).dy)
      ..cubicTo(p(272, 334).dx, p(272, 334).dy, p(354, 374).dx, p(354, 374).dy,
          p(427, 454).dx, p(427, 454).dy)
      ..cubicTo(p(333, 433).dx, p(333, 433).dy, p(239, 407).dx, p(239, 407).dy,
          p(174, 401).dx, p(174, 401).dy)
      ..cubicTo(p(165, 376).dx, p(165, 376).dy, p(176, 351).dx, p(176, 351).dy,
          p(203, 343).dx, p(203, 343).dy)
      ..close());
    drawInset(Path()
      ..moveTo(p(191, 474).dx, p(191, 474).dy)
      ..cubicTo(p(274, 462).dx, p(274, 462).dy, p(350, 478).dx, p(350, 478).dy,
          p(432, 514).dx, p(432, 514).dy)
      ..cubicTo(p(345, 523).dx, p(345, 523).dy, p(263, 524).dx, p(263, 524).dy,
          p(191, 516).dx, p(191, 516).dy)
      ..cubicTo(p(175, 503).dx, p(175, 503).dy, p(175, 486).dx, p(175, 486).dy,
          p(191, 474).dx, p(191, 474).dy)
      ..close());
    drawInset(Path()
      ..moveTo(p(252, 640).dx, p(252, 640).dy)
      ..cubicTo(p(301, 597).dx, p(301, 597).dy, p(358, 569).dx, p(358, 569).dy,
          p(438, 547).dx, p(438, 547).dy)
      ..cubicTo(p(383, 619).dx, p(383, 619).dy, p(337, 680).dx, p(337, 680).dy,
          p(282, 722).dx, p(282, 722).dy)
      ..cubicTo(p(253, 710).dx, p(253, 710).dy, p(239, 681).dx, p(239, 681).dy,
          p(252, 640).dx, p(252, 640).dy)
      ..close());

    canvas.drawLine(p(511, 347), p(511, 718), linePaint);
    canvas.drawPath(
      Path()
        ..moveTo(p(507, 352).dx, p(507, 352).dy)
        ..cubicTo(
          p(482, 328).dx,
          p(482, 328).dy,
          p(449, 313).dx,
          p(449, 313).dy,
          p(421, 314).dx,
          p(421, 314).dy,
        ),
      linePaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(p(517, 352).dx, p(517, 352).dy)
        ..cubicTo(
          p(542, 328).dx,
          p(542, 328).dy,
          p(575, 313).dx,
          p(575, 313).dy,
          p(603, 314).dx,
          p(603, 314).dy,
        ),
      linePaint,
    );

    canvas.drawOval(
        Rect.fromCenter(center: center, width: 68 * unit, height: 132 * unit),
        bodyPaint);
    canvas.drawOval(
        Rect.fromCenter(
            center: p(512, 429), width: 52 * unit, height: 72 * unit),
        bodyPaint);
  }

  @override
  bool shouldRepaint(covariant _RenacienteLogoPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor ||
        oldDelegate.insetColor != insetColor;
  }
}
