import '../../data/models/food_item.dart';
import '../../data/models/nutrition_goals.dart';

class DailyIntakeSummary {
  final DateTime date;
  final MacroNutrients totalNutrients;
  final Map<MealType, List<MealEntry>> mealsByType;
  final double calorieProgressRatio; // e.g. 0.75 for 75%
  final double proteinProgressRatio;
  final double carbsProgressRatio;
  final double fatProgressRatio;
  final double fiberProgressRatio;
  final double sodiumProgressRatio;
  final double proteinCaloriePercentage;
  final double carbsCaloriePercentage;
  final double fatCaloriePercentage;

  DailyIntakeSummary({
    required this.date,
    required this.totalNutrients,
    required this.mealsByType,
    required this.calorieProgressRatio,
    required this.proteinProgressRatio,
    required this.carbsProgressRatio,
    required this.fatProgressRatio,
    required this.fiberProgressRatio,
    required this.sodiumProgressRatio,
    required this.proteinCaloriePercentage,
    required this.carbsCaloriePercentage,
    required this.fatCaloriePercentage,
  });
}

class NutritionAnalytics {
  static DailyIntakeSummary analyzeDay({
    required DateTime date,
    required List<MealEntry> entries,
    required DailyMacroBudget budget,
  }) {
    // Filter for the selected day
    final dayEntries = entries.where((e) {
      return e.timestamp.year == date.year &&
          e.timestamp.month == date.month &&
          e.timestamp.day == date.day;
    }).toList();

    final Map<MealType, List<MealEntry>> mealsByType = {
      MealType.breakfast: [],
      MealType.lunch: [],
      MealType.dinner: [],
      MealType.snack: [],
    };

    var total = const MacroNutrients(
      calories: 0,
      proteinGrams: 0,
      carbsGrams: 0,
      fatGrams: 0,
      fiberGrams: 0,
      sodiumMg: 0,
      potassiumMg: 0,
    );

    for (final entry in dayEntries) {
      mealsByType[entry.mealType]?.add(entry);
      total = total + entry.calculatedNutrients;
    }

    final calRatio = budget.targetCalories > 0 ? (total.calories / budget.targetCalories) : 0.0;
    final protRatio = budget.targetProteinGrams > 0 ? (total.proteinGrams / budget.targetProteinGrams) : 0.0;
    final carbRatio = budget.targetCarbsGrams > 0 ? (total.carbsGrams / budget.targetCarbsGrams) : 0.0;
    final fatRatio = budget.targetFatGrams > 0 ? (total.fatGrams / budget.targetFatGrams) : 0.0;
    final fibRatio = budget.targetFiberGrams > 0 ? (total.fiberGrams / budget.targetFiberGrams) : 0.0;
    final sodRatio = budget.targetSodiumMg > 0 ? (total.sodiumMg / budget.targetSodiumMg) : 0.0;

    final totalCalFromMacros = (total.proteinGrams * 4) + (total.carbsGrams * 4) + (total.fatGrams * 9);
    final protCalPct = totalCalFromMacros > 0 ? ((total.proteinGrams * 4) / totalCalFromMacros) * 100 : 0.0;
    final carbCalPct = totalCalFromMacros > 0 ? ((total.carbsGrams * 4) / totalCalFromMacros) * 100 : 0.0;
    final fatCalPct = totalCalFromMacros > 0 ? ((total.fatGrams * 9) / totalCalFromMacros) * 100 : 0.0;

    return DailyIntakeSummary(
      date: date,
      totalNutrients: total,
      mealsByType: mealsByType,
      calorieProgressRatio: calRatio,
      proteinProgressRatio: protRatio,
      carbsProgressRatio: carbRatio,
      fatProgressRatio: fatRatio,
      fiberProgressRatio: fibRatio,
      sodiumProgressRatio: sodRatio,
      proteinCaloriePercentage: protCalPct,
      carbsCaloriePercentage: carbCalPct,
      fatCaloriePercentage: fatCalPct,
    );
  }
}
