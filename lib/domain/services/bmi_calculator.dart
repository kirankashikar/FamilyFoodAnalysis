import '../../data/models/user_profile.dart';
import '../../data/models/nutrition_goals.dart';

class BmiAssessment {
  final double bmi;
  final String category; // Underweight, Normal, Overweight, Obese
  final double bmr; // Basal Metabolic Rate (kcal)
  final double tdee; // Total Daily Energy Expenditure (kcal)
  final DailyMacroBudget recommendedBudget;

  BmiAssessment({
    required this.bmi,
    required this.category,
    required this.bmr,
    required this.tdee,
    required this.recommendedBudget,
  });
}

class BmiCalculator {
  static BmiAssessment calculate(FamilyMemberProfile profile) {
    final heightM = profile.heightCm / 100.0;
    final bmi = heightM > 0 ? (profile.weightKg / (heightM * heightM)) : 22.0;

    String category;
    if (bmi < 18.5) {
      category = 'Underweight';
    } else if (bmi < 24.9) {
      category = 'Normal weight';
    } else if (bmi < 29.9) {
      category = 'Overweight';
    } else {
      category = 'Obese';
    }

    // Mifflin-St Jeor Equation for BMR
    double bmr;
    if (profile.gender.toLowerCase() == 'female') {
      bmr = (10 * profile.weightKg) + (6.25 * profile.heightCm) - (5 * profile.age) - 161;
    } else {
      bmr = (10 * profile.weightKg) + (6.25 * profile.heightCm) - (5 * profile.age) + 5;
    }

    // Activity multiplier
    double multiplier;
    switch (profile.activityLevel.toLowerCase()) {
      case 'sedentary':
        multiplier = 1.2;
        break;
      case 'light':
        multiplier = 1.375;
        break;
      case 'active':
        multiplier = 1.725;
        break;
      case 'very active':
        multiplier = 1.9;
        break;
      case 'moderate':
      default:
        multiplier = 1.55;
        break;
    }

    final tdee = bmr * multiplier;
    final budget = _calculateTargetMacros(profile, tdee);

    return BmiAssessment(
      bmi: double.parse(bmi.toStringAsFixed(1)),
      category: category,
      bmr: double.parse(bmr.toStringAsFixed(0)),
      tdee: double.parse(tdee.toStringAsFixed(0)),
      recommendedBudget: budget,
    );
  }

  static DailyMacroBudget _calculateTargetMacros(FamilyMemberProfile profile, double tdee) {
    double targetCalories;
    double proteinRatio;
    double carbsRatio;
    double fatRatio;
    double targetFiber = 30.0;
    double targetSodium = 2000.0;
    double targetPotassium = 3500.0;

    switch (profile.goal) {
      case HealthGoal.weightLoss:
        targetCalories = (tdee - 450).clamp(1200.0, 3500.0);
        proteinRatio = 0.30; // 30% protein
        carbsRatio = 0.40;   // 40% carbs
        fatRatio = 0.30;     // 30% fat
        targetFiber = 35.0;  // Higher fiber for satiety
        break;

      case HealthGoal.muscleGain:
        targetCalories = (tdee + 350).clamp(1800.0, 4500.0);
        proteinRatio = 0.30; // High protein
        carbsRatio = 0.45;   // Adequate carbs for fueling workouts
        fatRatio = 0.25;
        targetFiber = 32.0;
        break;

      case HealthGoal.bloodSugarControl:
        targetCalories = tdee.clamp(1400.0, 3200.0);
        proteinRatio = 0.25;
        carbsRatio = 0.35;   // Lower carbs with high fiber emphasis
        fatRatio = 0.40;     // Healthy fats (MUFA/PUFA)
        targetFiber = 40.0;  // High fiber for glycemic control
        break;

      case HealthGoal.heartHealth:
        targetCalories = tdee.clamp(1400.0, 3200.0);
        proteinRatio = 0.22;
        carbsRatio = 0.50;
        fatRatio = 0.28;
        targetSodium = 1500.0; // Restrict sodium to 1500mg
        targetPotassium = 4000.0; // Higher potassium
        targetFiber = 35.0;
        break;

      case HealthGoal.athleticPerformance:
        targetCalories = (tdee + 500).clamp(2000.0, 5000.0);
        proteinRatio = 0.25;
        carbsRatio = 0.55;   // High carbs
        fatRatio = 0.20;
        targetFiber = 30.0;
        break;

      case HealthGoal.balancedMaintenance:
        targetCalories = tdee.clamp(1400.0, 3500.0);
        proteinRatio = 0.22;
        carbsRatio = 0.50;
        fatRatio = 0.28;
        targetFiber = 28.0;
        break;
    }

    // 1g Protein = 4 kcal, 1g Carbs = 4 kcal, 1g Fat = 9 kcal
    final proteinGrams = (targetCalories * proteinRatio) / 4.0;
    final carbsGrams = (targetCalories * carbsRatio) / 4.0;
    final fatGrams = (targetCalories * fatRatio) / 9.0;

    return DailyMacroBudget(
      targetCalories: double.parse(targetCalories.toStringAsFixed(0)),
      targetProteinGrams: double.parse(proteinGrams.toStringAsFixed(0)),
      targetCarbsGrams: double.parse(carbsGrams.toStringAsFixed(0)),
      targetFatGrams: double.parse(fatGrams.toStringAsFixed(0)),
      targetFiberGrams: targetFiber,
      targetSodiumMg: targetSodium,
      targetPotassiumMg: targetPotassium,
    );
  }
}
