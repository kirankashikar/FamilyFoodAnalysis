import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../data/models/food_item.dart';
import '../../data/models/nutrition_goals.dart';

class MacroDonutChart extends StatelessWidget {
  final MacroNutrients consumed;
  final DailyMacroBudget budget;
  final double size;

  const MacroDonutChart({
    super.key,
    required this.consumed,
    required this.budget,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    final calConsumed = consumed.calories;
    final calTarget = budget.targetCalories;
    final calRatio = calTarget > 0 ? (calConsumed / calTarget).clamp(0.0, 1.5) : 0.0;

    final protG = consumed.proteinGrams;
    final carbsG = consumed.carbsGrams;
    final fatG = consumed.fatGrams;

    final protCal = protG * 4;
    final carbsCal = carbsG * 4;
    final fatCal = fatG * 9;
    final totalMacroCal = protCal + carbsCal + fatCal;

    final protPct = totalMacroCal > 0 ? (protCal / totalMacroCal) : 0.0;
    final carbsPct = totalMacroCal > 0 ? (carbsCal / totalMacroCal) : 0.0;
    final fatPct = totalMacroCal > 0 ? (fatCal / totalMacroCal) : 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Radial Gauge
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _DonutChartPainter(
                  proteinRatio: protPct,
                  carbsRatio: carbsPct,
                  fatRatio: fatPct,
                  calorieProgress: calRatio,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    calConsumed.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'of ${calTarget.toStringAsFixed(0)} kcal',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7D7979),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Text(
                      '${(calRatio * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 24),

        // Legend Breakdown
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMacroStat(
                context,
                label: 'Protein',
                color: AppColors.proteinColor,
                consumedGrams: protG,
                targetGrams: budget.targetProteinGrams,
                percentage: (protPct * 100).toStringAsFixed(0),
              ),
              const SizedBox(height: 12),
              _buildMacroStat(
                context,
                label: 'Carbs',
                color: AppColors.carbsColor,
                consumedGrams: carbsG,
                targetGrams: budget.targetCarbsGrams,
                percentage: (carbsPct * 100).toStringAsFixed(0),
              ),
              const SizedBox(height: 12),
              _buildMacroStat(
                context,
                label: 'Fat',
                color: AppColors.fatColor,
                consumedGrams: fatG,
                targetGrams: budget.targetFatGrams,
                percentage: (fatPct * 100).toStringAsFixed(0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroStat(
    BuildContext context, {
    required String label,
    required Color color,
    required double consumedGrams,
    required double targetGrams,
    required String percentage,
  }) {
    final ratio = targetGrams > 0 ? (consumedGrams / targetGrams).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${consumedGrams.toStringAsFixed(0)}g',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              ' / ${targetGrams.toStringAsFixed(0)}g',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF7D7979),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double proteinRatio;
  final double carbsRatio;
  final double fatRatio;
  final double calorieProgress;

  _DonutChartPainter({
    required this.proteinRatio,
    required this.carbsRatio,
    required this.fatRatio,
    required this.calorieProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 8;
    final strokeWidth = 14.0;

    // Background track
    final bgPaint = Paint()
      ..color = const Color(0xFF444141).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, outerRadius, bgPaint);

    if (proteinRatio == 0 && carbsRatio == 0 && fatRatio == 0) {
      return;
    }

    double startAngle = -pi / 2;

    void drawSegment(double ratio, Color color) {
      if (ratio <= 0) return;
      final sweepAngle = 2 * pi * ratio;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      final rect = Rect.fromCircle(center: center, radius: outerRadius);
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    drawSegment(proteinRatio, AppColors.proteinColor);
    drawSegment(carbsRatio, AppColors.carbsColor);
    drawSegment(fatRatio, AppColors.fatColor);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.proteinRatio != proteinRatio ||
        oldDelegate.carbsRatio != carbsRatio ||
        oldDelegate.fatRatio != fatRatio ||
        oldDelegate.calorieProgress != calorieProgress;
  }
}
