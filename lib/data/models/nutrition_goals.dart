import 'dart:convert';

enum HealthGoal {
  weightLoss,
  muscleGain,
  bloodSugarControl,
  heartHealth,
  balancedMaintenance,
  athleticPerformance,
}

extension HealthGoalExtension on HealthGoal {
  String get displayName {
    switch (this) {
      case HealthGoal.weightLoss:
        return 'Weight Loss & Calorie Deficit';
      case HealthGoal.muscleGain:
        return 'Muscle Gain & High Protein';
      case HealthGoal.bloodSugarControl:
        return 'Diabetic & Low Glycemic Index';
      case HealthGoal.heartHealth:
        return 'Cardiovascular & Low Sodium';
      case HealthGoal.balancedMaintenance:
        return 'Balanced Everyday Vitality';
      case HealthGoal.athleticPerformance:
        return 'High Energy & Endurance';
    }
  }

  String get description {
    switch (this) {
      case HealthGoal.weightLoss:
        return 'Optimizes for moderate caloric deficit, high fiber, and satiety.';
      case HealthGoal.muscleGain:
        return 'Targets 1.6-2.2g of protein per kg bodyweight and steady caloric surplus.';
      case HealthGoal.bloodSugarControl:
        return 'Emphasizes complex carbohydrates, millets, whole pulses, and low glycemic load.';
      case HealthGoal.heartHealth:
        return 'Limits sodium to <1800mg, increases potassium, and favors healthy unsaturated fats.';
      case HealthGoal.balancedMaintenance:
        return 'Provides nutrient-dense, balanced 50/25/25 carb/protein/fat split.';
      case HealthGoal.athleticPerformance:
        return 'High clean energy carbs, optimal electrolyte replenishment, and fast recovery proteins.';
    }
  }

  String get iconName {
    switch (this) {
      case HealthGoal.weightLoss:
        return 'trending_down';
      case HealthGoal.muscleGain:
        return 'fitness_center';
      case HealthGoal.bloodSugarControl:
        return 'monitor_heart';
      case HealthGoal.heartHealth:
        return 'favorite';
      case HealthGoal.balancedMaintenance:
        return 'balance';
      case HealthGoal.athleticPerformance:
        return 'bolt';
    }
  }
}

class DailyMacroBudget {
  final double targetCalories;
  final double targetProteinGrams;
  final double targetCarbsGrams;
  final double targetFatGrams;
  final double targetFiberGrams;
  final double targetSodiumMg;
  final double targetPotassiumMg;

  DailyMacroBudget({
    required this.targetCalories,
    required this.targetProteinGrams,
    required this.targetCarbsGrams,
    required this.targetFatGrams,
    required this.targetFiberGrams,
    required this.targetSodiumMg,
    required this.targetPotassiumMg,
  });

  factory DailyMacroBudget.defaultBudget() {
    return DailyMacroBudget(
      targetCalories: 2000,
      targetProteinGrams: 75,
      targetCarbsGrams: 250,
      targetFatGrams: 55,
      targetFiberGrams: 30,
      targetSodiumMg: 2000,
      targetPotassiumMg: 3500,
    );
  }

  DailyMacroBudget copyWith({
    double? targetCalories,
    double? targetProteinGrams,
    double? targetCarbsGrams,
    double? targetFatGrams,
    double? targetFiberGrams,
    double? targetSodiumMg,
    double? targetPotassiumMg,
  }) {
    return DailyMacroBudget(
      targetCalories: targetCalories ?? this.targetCalories,
      targetProteinGrams: targetProteinGrams ?? this.targetProteinGrams,
      targetCarbsGrams: targetCarbsGrams ?? this.targetCarbsGrams,
      targetFatGrams: targetFatGrams ?? this.targetFatGrams,
      targetFiberGrams: targetFiberGrams ?? this.targetFiberGrams,
      targetSodiumMg: targetSodiumMg ?? this.targetSodiumMg,
      targetPotassiumMg: targetPotassiumMg ?? this.targetPotassiumMg,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'targetCalories': targetCalories,
      'targetProteinGrams': targetProteinGrams,
      'targetCarbsGrams': targetCarbsGrams,
      'targetFatGrams': targetFatGrams,
      'targetFiberGrams': targetFiberGrams,
      'targetSodiumMg': targetSodiumMg,
      'targetPotassiumMg': targetPotassiumMg,
    };
  }

  factory DailyMacroBudget.fromMap(Map<String, dynamic> map) {
    return DailyMacroBudget(
      targetCalories: (map['targetCalories'] as num?)?.toDouble() ?? 2000.0,
      targetProteinGrams: (map['targetProteinGrams'] as num?)?.toDouble() ?? 75.0,
      targetCarbsGrams: (map['targetCarbsGrams'] as num?)?.toDouble() ?? 250.0,
      targetFatGrams: (map['targetFatGrams'] as num?)?.toDouble() ?? 55.0,
      targetFiberGrams: (map['targetFiberGrams'] as num?)?.toDouble() ?? 30.0,
      targetSodiumMg: (map['targetSodiumMg'] as num?)?.toDouble() ?? 2000.0,
      targetPotassiumMg: (map['targetPotassiumMg'] as num?)?.toDouble() ?? 3500.0,
    );
  }

  String toJson() => json.encode(toMap());
  factory DailyMacroBudget.fromJson(String source) => DailyMacroBudget.fromMap(json.decode(source));
}
