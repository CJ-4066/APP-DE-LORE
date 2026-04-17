import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../utils/formatters.dart';

class SpecialistRatingBadge extends StatelessWidget {
  const SpecialistRatingBadge({
    super.key,
    required this.rating,
    this.maxStars = 4,
    this.backgroundColor = AppPalette.moonIvory,
    this.borderColor = AppPalette.border,
    this.filledStarColor = AppPalette.flameGold,
    this.emptyStarColor = AppPalette.softLilac,
    this.textColor = AppPalette.indigo,
  });

  final double rating;
  final int maxStars;
  final Color backgroundColor;
  final Color borderColor;
  final Color filledStarColor;
  final Color emptyStarColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final filledStars = specialistRatingStars(rating, maxStars: maxStars);
    final percent = specialistRatingPercent(rating);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              maxStars,
              (index) {
                final isFilled = index < filledStars;
                return Padding(
                  padding:
                      EdgeInsets.only(right: index == maxStars - 1 ? 0 : 2),
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 16,
                    color: isFilled ? filledStarColor : emptyStarColor,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$percent%',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
