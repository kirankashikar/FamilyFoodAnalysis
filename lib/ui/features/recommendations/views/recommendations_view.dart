import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../view_models/main_view_model.dart';
import '../../../core/glass_card.dart';
import '../../../../domain/services/recommendation_engine.dart';
import '../../../../data/models/nutrition_goals.dart';

class RecommendationsView extends StatelessWidget {
  const RecommendationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();
    final recommendations = vm.currentRecommendations;
    final member = vm.activeMember;
    final summary = vm.todaySummary;
    final budget = member.customMacroBudget;
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Meal & Nutrient Suggestions for ${member.name}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Goal: ${member.goal.displayName} • Context: ${member.ethnicity} • ${recommendations.length} active suggestions',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.primaryLight, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'AI Engine Active',
                      style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Goal & Gaps Card
          GlassCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.tune_rounded, color: AppColors.primaryLight, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Active Goal Strategy: ${member.goal.displayName.split('&')[0]}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.goal.description,
                        style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Actionable Meal & Ingredient Modifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (recommendations.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.primary),
                    const SizedBox(height: 12),
                    const Text('Outstanding! Your diet is perfectly balanced today.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Intake aligns seamlessly with your ${member.goal.displayName} targets.', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (ctx, i) {
                final rec = recommendations[i];
                return _buildRecommendationCard(context, vm, rec, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, MainViewModel vm, RecommendationItem rec, bool isDark) {
    Color badgeColor;
    String categoryLabel;

    switch (rec.category) {
      case RecommendationCategory.deficitBoost:
        badgeColor = AppColors.proteinColor;
        categoryLabel = 'NUTRIENT BOOST';
        break;
      case RecommendationCategory.swap:
        badgeColor = AppColors.secondary;
        categoryLabel = 'INGREDIENT SWAP';
        break;
      case RecommendationCategory.excessWarning:
        badgeColor = AppColors.roseAlert;
        categoryLabel = 'NUTRIENT LIMIT';
        break;
      case RecommendationCategory.pantryUsage:
        badgeColor = AppColors.warmAmber;
        categoryLabel = 'PANTRY EXPIRY';
        break;
      case RecommendationCategory.culturalOptimization:
        badgeColor = AppColors.purpleVibrant;
        categoryLabel = 'CULTURAL PAIRING';
        break;
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(rec.iconEmoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            categoryLabel,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: badgeColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Impact: ${rec.affectedNutrient}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      rec.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rec.description,
                      style: const TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Suggested Action Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: AppColors.warmAmber, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    rec.suggestedAction,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (rec.targetFoodName != null) ...[
                OutlinedButton.icon(
                  onPressed: () {
                    vm.setTabIndex(3); // Navigate to recipes
                  },
                  icon: const Icon(Icons.restaurant_menu_rounded, size: 14),
                  label: const Text('View Recipe Ideas'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              ElevatedButton.icon(
                onPressed: () {
                  vm.setTabIndex(2); // Navigate to intake logger
                },
                icon: const Icon(Icons.add_task_rounded, size: 14),
                label: const Text('Log Modification'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
