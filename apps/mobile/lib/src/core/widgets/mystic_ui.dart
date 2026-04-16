import 'package:flutter/material.dart';

enum MysticGlyphKind {
  astral,
  numerology,
  tarot,
  course,
  agenda,
  video,
  audio,
  chat,
  person,
  ritual,
  card,
  specialist,
  subscription,
  generic,
}

class MysticGlyphBadge extends StatelessWidget {
  const MysticGlyphBadge({
    super.key,
    required this.accent,
    required this.background,
    this.kind = MysticGlyphKind.generic,
    this.icon,
    this.size = 88,
  });

  final Color accent;
  final Color background;
  final MysticGlyphKind kind;
  final IconData? icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.92,
            height: size * 0.92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  background.withValues(alpha: 0.26),
                  background.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _MysticHaloPainter(
                accent: accent,
                background: background,
              ),
            ),
          ),
          Container(
            width: size * 0.22,
            height: size * 0.22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.11),
            ),
          ),
          if (kind == MysticGlyphKind.generic && icon != null)
            Icon(
              icon,
              color: accent,
              size: size * 0.4,
            )
          else
            CustomPaint(
              size: Size.square(size * 0.44),
              painter: _MysticGlyphPainter(
                kind: kind,
                color: accent,
              ),
            ),
          Positioned(
            top: size * 0.14,
            left: size * 0.1,
            child: _OrbDot(
              size: size * 0.08,
              color: accent.withValues(alpha: 0.2),
            ),
          ),
          Positioned(
            top: size * 0.16,
            right: size * 0.08,
            child: _OrbDot(
              size: size * 0.1,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          Positioned(
            bottom: size * 0.14,
            right: size * 0.14,
            child: _OrbDot(
              size: size * 0.08,
              color: accent.withValues(alpha: 0.48),
            ),
          ),
        ],
      ),
    );
  }
}

class MysticBannerCard extends StatelessWidget {
  const MysticBannerCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.glyphKind,
    required this.gradient,
    required this.tags,
    required this.primaryLabel,
    this.onPrimaryTap,
    this.secondaryLabel,
    this.onSecondaryTap,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final MysticGlyphKind glyphKind;
  final List<Color> gradient;
  final List<String> tags;
  final String primaryLabel;
  final VoidCallback? onPrimaryTap;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withValues(alpha: 0.18),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  eyebrow,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              MysticGlyphBadge(
                kind: glyphKind,
                accent: const Color(0xFFFFF5E8),
                background: Colors.white.withValues(alpha: 0.14),
                size: 72,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.none,
                ),
          ),
          if (subtitle.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.45,
                decoration: TextDecoration.none,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .take(4)
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton(
                onPressed: onPrimaryTap,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF4E8),
                  foregroundColor: const Color(0xFF182127),
                ),
                child: Text(primaryLabel),
              ),
              if (secondaryLabel != null)
                OutlinedButton(
                  onPressed: onSecondaryTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Text(secondaryLabel!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class MysticPageDots extends StatelessWidget {
  const MysticPageDots({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: activeIndex == index ? 26 : 9,
          height: 9,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: activeIndex == index
                ? const Color(0xFF182127)
                : const Color(0xFFD8D3CB),
          ),
        ),
      ),
    );
  }
}

class MysticMenuTile extends StatelessWidget {
  const MysticMenuTile({
    super.key,
    required this.glyphKind,
    required this.label,
    required this.caption,
    required this.accent,
    this.onTap,
    this.selected = false,
  });

  final MysticGlyphKind glyphKind;
  final String label;
  final String caption;
  final Color accent;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 152,
          height: 172,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.14) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.42)
                  : const Color(0xFFE7DED3),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              MysticGlyphBadge(
                kind: glyphKind,
                accent: accent,
                background: accent.withValues(alpha: 0.16),
                size: 50,
              ),
              const SizedBox(height: 14),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.none,
                    ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF54656B),
                        height: 1.35,
                        decoration: TextDecoration.none,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MysticFlowOption {
  const MysticFlowOption({
    required this.label,
    required this.caption,
    required this.glyphKind,
  });

  final String label;
  final String caption;
  final MysticGlyphKind glyphKind;
}

class MysticFlowNavigator extends StatelessWidget {
  const MysticFlowNavigator({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    required this.accent,
  });

  final List<MysticFlowOption> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index == items.length - 1 ? 0 : 12,
            ),
            child: MysticMenuTile(
              glyphKind: item.glyphKind,
              label: item.label,
              caption: item.caption,
              accent: accent,
              selected: index == selectedIndex,
              onTap: () => onSelect(index),
            ),
          );
        }),
      ),
    );
  }
}

class MysticSlideSwitcher extends StatelessWidget {
  const MysticSlideSwitcher({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class MysticMiniBanner extends StatelessWidget {
  const MysticMiniBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.glyphKind,
    required this.accent,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final MysticGlyphKind glyphKind;
  final Color accent;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE8DED2)),
          ),
          child: Row(
            children: [
              MysticGlyphBadge(
                kind: glyphKind,
                accent: accent,
                background: accent.withValues(alpha: 0.16),
                size: 58,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.none,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: trailing == null ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF55666C),
                            height: 1.35,
                            decoration: TextDecoration.none,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    color: accent,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrbDot extends StatelessWidget {
  const _OrbDot({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _MysticGlyphPainter extends CustomPainter {
  const _MysticGlyphPainter({
    required this.kind,
    required this.color,
  });

  final MysticGlyphKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width * 0.42;

    switch (kind) {
      case MysticGlyphKind.astral:
        canvas.drawCircle(center, radius, stroke);
        canvas.drawLine(
          Offset(center.dx - radius, center.dy),
          Offset(center.dx + radius, center.dy),
          stroke,
        );
        canvas.drawLine(
          Offset(center.dx, center.dy - radius),
          Offset(center.dx, center.dy + radius),
          stroke,
        );
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 0.68),
          0.6,
          1.8,
          false,
          stroke,
        );
        return;
      case MysticGlyphKind.numerology:
        final step = size.width / 3.4;
        for (var row = 0; row < 3; row += 1) {
          for (var col = 0; col < 3; col += 1) {
            final cell = RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(
                  size.width * 0.22 + col * step,
                  size.height * 0.22 + row * step,
                ),
                width: size.width * 0.18,
                height: size.width * 0.18,
              ),
              Radius.circular(size.width * 0.04),
            );
            canvas.drawRRect(cell, (row + col).isEven ? fill : stroke);
            if ((row + col).isEven) {
              canvas.drawRRect(cell, stroke);
            }
          }
        }
        return;
      case MysticGlyphKind.tarot:
      case MysticGlyphKind.card:
        final back = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.18,
            size.height * 0.16,
            size.width * 0.48,
            size.height * 0.62,
          ),
          Radius.circular(size.width * 0.08),
        );
        final front = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.34,
            size.height * 0.24,
            size.width * 0.48,
            size.height * 0.62,
          ),
          Radius.circular(size.width * 0.08),
        );
        canvas.drawRRect(back, stroke);
        canvas.drawRRect(front, stroke);
        canvas.drawCircle(
          Offset(size.width * 0.58, size.height * 0.54),
          size.width * 0.08,
          stroke,
        );
        return;
      case MysticGlyphKind.course:
        final book = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.22,
            size.height * 0.18,
            size.width * 0.56,
            size.height * 0.64,
          ),
          Radius.circular(size.width * 0.08),
        );
        canvas.drawRRect(book, stroke);
        canvas.drawLine(
          Offset(size.width * 0.5, size.height * 0.22),
          Offset(size.width * 0.5, size.height * 0.78),
          stroke,
        );
        canvas.drawLine(
          Offset(size.width * 0.3, size.height * 0.34),
          Offset(size.width * 0.44, size.height * 0.34),
          stroke,
        );
        canvas.drawLine(
          Offset(size.width * 0.56, size.height * 0.34),
          Offset(size.width * 0.7, size.height * 0.34),
          stroke,
        );
        return;
      case MysticGlyphKind.agenda:
        final calendar = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.18,
            size.height * 0.2,
            size.width * 0.64,
            size.height * 0.56,
          ),
          Radius.circular(size.width * 0.08),
        );
        canvas.drawRRect(calendar, stroke);
        canvas.drawLine(
          Offset(size.width * 0.18, size.height * 0.36),
          Offset(size.width * 0.82, size.height * 0.36),
          stroke,
        );
        canvas.drawCircle(Offset(size.width * 0.34, size.height * 0.52),
            size.width * 0.05, fill);
        canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.52),
            size.width * 0.05, fill);
        canvas.drawCircle(Offset(size.width * 0.66, size.height * 0.52),
            size.width * 0.05, fill);
        return;
      case MysticGlyphKind.video:
        final screen = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.18,
            size.height * 0.24,
            size.width * 0.42,
            size.height * 0.38,
          ),
          Radius.circular(size.width * 0.07),
        );
        canvas.drawRRect(screen, stroke);
        final path = Path()
          ..moveTo(size.width * 0.64, size.height * 0.32)
          ..lineTo(size.width * 0.82, size.height * 0.24)
          ..lineTo(size.width * 0.82, size.height * 0.62)
          ..lineTo(size.width * 0.64, size.height * 0.54)
          ..close();
        canvas.drawPath(path, stroke);
        return;
      case MysticGlyphKind.audio:
        canvas.drawArc(
          Rect.fromLTWH(
            size.width * 0.2,
            size.height * 0.18,
            size.width * 0.6,
            size.height * 0.5,
          ),
          3.4,
          2.6,
          false,
          stroke,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              size.width * 0.18,
              size.height * 0.42,
              size.width * 0.16,
              size.height * 0.24,
            ),
            Radius.circular(size.width * 0.06),
          ),
          stroke,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              size.width * 0.66,
              size.height * 0.42,
              size.width * 0.16,
              size.height * 0.24,
            ),
            Radius.circular(size.width * 0.06),
          ),
          stroke,
        );
        return;
      case MysticGlyphKind.chat:
        final bubble = Path()
          ..moveTo(size.width * 0.2, size.height * 0.26)
          ..lineTo(size.width * 0.8, size.height * 0.26)
          ..lineTo(size.width * 0.8, size.height * 0.62)
          ..lineTo(size.width * 0.52, size.height * 0.62)
          ..lineTo(size.width * 0.38, size.height * 0.78)
          ..lineTo(size.width * 0.4, size.height * 0.62)
          ..lineTo(size.width * 0.2, size.height * 0.62)
          ..close();
        canvas.drawPath(bubble, stroke);
        return;
      case MysticGlyphKind.person:
      case MysticGlyphKind.specialist:
        canvas.drawCircle(
          Offset(size.width * 0.5, size.height * 0.34),
          size.width * 0.12,
          stroke,
        );
        canvas.drawArc(
          Rect.fromLTWH(
            size.width * 0.24,
            size.height * 0.42,
            size.width * 0.52,
            size.height * 0.34,
          ),
          3.35,
          2.72,
          false,
          stroke,
        );
        return;
      case MysticGlyphKind.ritual:
        final flame = Path()
          ..moveTo(size.width * 0.54, size.height * 0.18)
          ..quadraticBezierTo(
            size.width * 0.82,
            size.height * 0.42,
            size.width * 0.58,
            size.height * 0.8,
          )
          ..quadraticBezierTo(
            size.width * 0.32,
            size.height * 0.64,
            size.width * 0.36,
            size.height * 0.44,
          )
          ..quadraticBezierTo(
            size.width * 0.42,
            size.height * 0.26,
            size.width * 0.54,
            size.height * 0.18,
          );
        canvas.drawPath(flame, stroke);
        return;
      case MysticGlyphKind.subscription:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              size.width * 0.18,
              size.height * 0.24,
              size.width * 0.64,
              size.height * 0.42,
            ),
            Radius.circular(size.width * 0.08),
          ),
          stroke,
        );
        canvas.drawLine(
          Offset(size.width * 0.32, size.height * 0.68),
          Offset(size.width * 0.68, size.height * 0.68),
          stroke,
        );
        canvas.drawLine(
          Offset(size.width * 0.38, size.height * 0.22),
          Offset(size.width * 0.38, size.height * 0.08),
          stroke,
        );
        canvas.drawLine(
          Offset(size.width * 0.62, size.height * 0.22),
          Offset(size.width * 0.62, size.height * 0.08),
          stroke,
        );
        return;
      case MysticGlyphKind.generic:
        canvas.drawCircle(center, radius * 0.82, stroke);
        canvas.drawLine(
          Offset(center.dx - radius * 0.5, center.dy),
          Offset(center.dx + radius * 0.5, center.dy),
          stroke,
        );
        return;
    }
  }

  @override
  bool shouldRepaint(covariant _MysticGlyphPainter oldDelegate) {
    return oldDelegate.kind != kind || oldDelegate.color != color;
  }
}

class _MysticHaloPainter extends CustomPainter {
  const _MysticHaloPainter({
    required this.accent,
    required this.background,
  });

  final Color accent;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final softStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    softStroke
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = size.width * 0.018;
    canvas.drawCircle(
      size.center(Offset.zero),
      size.width * 0.38,
      softStroke,
    );

    softStroke
      ..color = accent.withValues(alpha: 0.24)
      ..strokeWidth = size.width * 0.024;
    canvas.drawArc(
      Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: size.width * 0.31,
      ),
      0.45,
      1.65,
      false,
      softStroke,
    );
    canvas.drawArc(
      Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: size.width * 0.31,
      ),
      3.2,
      1.1,
      false,
      softStroke,
    );

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          background.withValues(alpha: 0.22),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawCircle(
      size.center(Offset.zero),
      size.width * 0.28,
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant _MysticHaloPainter oldDelegate) {
    return oldDelegate.accent != accent || oldDelegate.background != background;
  }
}
