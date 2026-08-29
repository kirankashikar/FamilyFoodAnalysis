import '../../data/models/user_profile.dart';
import '../../data/models/nutrition_goals.dart';
import '../../data/models/food_item.dart';
import '../../data/models/grocery_item.dart';
import '../../data/models/cultural_preset.dart';

enum RecommendationCategory {
  swap,
  deficitBoost,
  excessWarning,
  pantryUsage,
  culturalOptimization,
}

class RecommendationItem {
  final String id;
  final String title;
  final RecommendationCategory category;
  final String description;
  final String suggestedAction;
  final String iconEmoji;
  final String affectedNutrient;
  final double priorityScore; // 1 to 10
  final String? targetFoodName;

  RecommendationItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.suggestedAction,
    required this.iconEmoji,
    required this.affectedNutrient,
    required this.priorityScore,
    this.targetFoodName,
  });
}

class RecommendationEngine {
  static List<RecommendationItem> generateRecommendations({
    required FamilyMemberProfile member,
    required MacroNutrients todayIntake,
    required List<GroceryItem> inventory,
  }) {
    final List<RecommendationItem> list = [];
    final budget = member.customMacroBudget;

    // 1. Protein Gap Analysis
    final proteinRatio = todayIntake.proteinGrams / (budget.targetProteinGrams > 0 ? budget.targetProteinGrams : 1);
    if (proteinRatio < 0.65) {
      final deficit = (budget.targetProteinGrams - todayIntake.proteinGrams).round();
      if (member.goal == HealthGoal.muscleGain || member.goal == HealthGoal.weightLoss) {
        list.add(RecommendationItem(
          id: 'rec_protein_boost',
          title: 'Boost Protein by ${deficit}g for ${member.name}',
          category: RecommendationCategory.deficitBoost,
          description: 'Current intake is ${todayIntake.proteinGrams.toStringAsFixed(0)}g against the ${budget.targetProteinGrams.toStringAsFixed(0)}g target. Adequate protein prevents muscle breakdown and enhances metabolic rate.',
          suggestedAction: member.dietaryPreferences.contains('Vegan')
              ? 'Add 150g firm tofu or 1 cup boiled chickpeas to lunch/dinner.'
              : 'Add 100g grilled paneer, 2 eggs, or 1 cup thick Greek yogurt to reach your target.',
          iconEmoji: '💪',
          affectedNutrient: 'Protein',
          priorityScore: 9.0,
          targetFoodName: 'Organic Paneer',
        ));
      }
    }

    // 2. Fiber Gap & Glycemic Load
    final fiberRatio = todayIntake.fiberGrams / (budget.targetFiberGrams > 0 ? budget.targetFiberGrams : 1);
    if (fiberRatio < 0.60) {
      final deficit = (budget.targetFiberGrams - todayIntake.fiberGrams).round();
      list.add(RecommendationItem(
        id: 'rec_fiber_swap',
        title: 'Increase Dietary Fiber (+${deficit}g needed)',
        category: RecommendationCategory.swap,
        description: 'You have consumed ${todayIntake.fiberGrams.toStringAsFixed(0)}g fiber today. High fiber improves gut microbiome health and stabilizes postprandial glucose.',
        suggestedAction: member.ethnicity.contains('Indian')
            ? 'Swap refined rice for Foxtail Millet or add 1 bowl of Vegetable Sambar / Palak Sabzi.'
            : 'Add 2 tbsp Chia seeds or switch to Whole Grain Sourdough / Hummus dip.',
        iconEmoji: '🌾',
        affectedNutrient: 'Fiber',
        priorityScore: 8.0,
        targetFoodName: 'Foxtail Millet',
      ));
    }

    // 3. Sodium Excess Check (Heart Health & Blood Pressure)
    if (todayIntake.sodiumMg > (budget.targetSodiumMg * 0.85)) {
      list.add(RecommendationItem(
        id: 'rec_sodium_warning',
        title: 'Approaching Daily Sodium Limit (${todayIntake.sodiumMg.toStringAsFixed(0)}mg / ${budget.targetSodiumMg.toStringAsFixed(0)}mg)',
        category: RecommendationCategory.excessWarning,
        description: 'Sodium intake is nearing your daily recommended threshold. High sodium promotes water retention and cardiovascular strain.',
        suggestedAction: 'For your next meal, season dishes with lemon juice, roasted cumin powder (Jeera), and fresh herbs instead of added table salt.',
        iconEmoji: '🧂',
        affectedNutrient: 'Sodium',
        priorityScore: 8.5,
      ));
    }

    // 4. Cultural Diet Adaptation
    final preset = CulturalDietPreset.presets.firstWhere(
      (p) => member.ethnicity.toLowerCase().contains(p.name.toLowerCase()) || p.name.toLowerCase().contains(member.ethnicity.toLowerCase()),
      orElse: () => CulturalDietPreset.presets.first,
    );

    if (member.goal == HealthGoal.bloodSugarControl) {
      list.add(RecommendationItem(
        id: 'rec_cultural_glycemic',
        title: 'Diabetic-Friendly ${preset.name} Meal Pairing',
        category: RecommendationCategory.culturalOptimization,
        description: 'To lower glycemic index, pair fermented dishes (like Dosa or Idli) with a double serving of fiber-rich vegetable stew (Sambar) or flaxseed chutney.',
        suggestedAction: 'Substitute 50% of the white rice in dosa batter with whole ragi (finger millet) or sprouted moong.',
        iconEmoji: preset.iconEmoji,
        affectedNutrient: 'Glycemic Index',
        priorityScore: 7.5,
      ));
    }

    // 5. Expiring Inventory & Pantry Prevention Waste
    final expiringItems = inventory.where((it) => it.isExpiringSoon).toList();
    if (expiringItems.isNotEmpty) {
      final firstExpiring = expiringItems.first;
      list.add(RecommendationItem(
        id: 'rec_pantry_expiry_${firstExpiring.id}',
        title: 'Cook with ${firstExpiring.name} (Expiring in 2-3 days)',
        category: RecommendationCategory.pantryUsage,
        description: '${firstExpiring.name} in your pantry should be prepared soon to retain maximum micronutrient potency and prevent food waste.',
        suggestedAction: 'Prepare a fresh batch of Palak Paneer or a hearty vegetable curry for dinner tonight.',
        iconEmoji: '⏰',
        affectedNutrient: 'Pantry Freshness',
        priorityScore: 7.0,
        targetFoodName: firstExpiring.name,
      ));
    }

    // 6. Healthy Fats & Micronutrients
    if (todayIntake.fatGrams < (budget.targetFatGrams * 0.5) && todayIntake.calories > 1000) {
      list.add(RecommendationItem(
        id: 'rec_healthy_fats',
        title: 'Incorporate Heart-Healthy Monounsaturated Fats',
        category: RecommendationCategory.deficitBoost,
        description: 'Fat intake is very low today. Healthy essential fatty acids are required for fat-soluble vitamins (A, D, E, K) absorption and hormone synthesis.',
        suggestedAction: 'Add 1 tbsp of cold-pressed Sesame Gingelly Oil, Extra Virgin Olive Oil, or a handful of soaked almonds/walnuts.',
        iconEmoji: '🥑',
        affectedNutrient: 'Healthy Fats',
        priorityScore: 6.5,
      ));
    }

    // Sort by priority descending
    list.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
    return list;
  }
}
