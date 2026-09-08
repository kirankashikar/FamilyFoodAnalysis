import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NutrientProgressBar extends StatelessWidget {
  final String title;
  final double current;
  final double target;
  final String unit;
  final Color color;
  final String? subtitle;
  final bool isLimit; // e.g. Sodium is an upper limit, whereas Fiber is a minimum goal

  const NutrientProgressBar({
    super.key,
    required this.title,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
    this.subtitle,
    this.isLimit = false,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = target > 0 ? (current / target).clamp(0.0, 1.5) : 0.0;
    final isExceeded = isLimit ? current > target : current >= target;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 6),
              Text(
                '($subtitle)',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7D7979),
                ),
              ),
            ],
            const Spacer(),
            Text(
              '${current.toStringAsFixed(0)} $unit',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isLimit && isExceeded ? AppColors.roseAlert : null,
              ),
            ),
            Text(
              ' / ${target.toStringAsFixed(0)} $unit',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF7D7979),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: LinearProgressIndicator(
            value: (ratio > 1.0) ? 1.0 : ratio,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(
              isLimit && isExceeded ? AppColors.roseAlert : color,
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
