import 'package:flutter_test/flutter_test.dart';
import 'package:family_food_analysis/data/models/user_profile.dart';
import 'package:family_food_analysis/data/models/nutrition_goals.dart';
import 'package:family_food_analysis/domain/services/bmi_calculator.dart';

void main() {
  group('BmiCalculator Tests', () {
    test('Calculates BMI accurately for normal weight adult', () {
      final profile = FamilyMemberProfile(
        id: 'test_1',
        name: 'Kiran',
        relationship: 'Self',
        age: 30,
        gender: 'Male',
        heightCm: 175,
        weightKg: 70,
        activityLevel: 'Moderate',
        ethnicity: 'South Asian (Indian)',
        dietaryPreferences: ['Vegetarian'],
        allergies: [],
        goal: HealthGoal.balancedMaintenance,
        customMacroBudget: DailyMacroBudget.defaultBudget(),
      );

      final assessment = BmiCalculator.calculate(profile);

      // BMI = 70 / (1.75 * 1.75) = 22.86 -> 22.9
      expect(assessment.bmi, closeTo(22.9, 0.2));
      expect(assessment.category, 'Normal weight');
      expect(assessment.bmr, greaterThan(1500));
      expect(assessment.tdee, greaterThan(assessment.bmr));
      expect(assessment.recommendedBudget.targetCalories, greaterThan(1500));
    });

    test('Calculates custom protein-heavy budget for Muscle Gain goal', () {
      final profile = FamilyMemberProfile(
        id: 'test_2',
        name: 'Alex',
        relationship: 'Self',
        age: 25,
        gender: 'Male',
        heightCm: 180,
        weightKg: 75,
        activityLevel: 'Active',
        ethnicity: 'Western Balanced',
        dietaryPreferences: [],
        allergies: [],
        goal: HealthGoal.muscleGain,
        customMacroBudget: DailyMacroBudget.defaultBudget(),
      );

      final assessment = BmiCalculator.calculate(profile);

      expect(assessment.recommendedBudget.targetProteinGrams, greaterThanOrEqualTo(100));
      expect(assessment.recommendedBudget.targetCalories, greaterThan(assessment.tdee));
    });

    test('Calculates low-sodium and high-potassium budget for Heart Health goal', () {
      final profile = FamilyMemberProfile(
        id: 'test_3',
        name: 'Parent',
        relationship: 'Parent',
        age: 62,
        gender: 'Female',
        heightCm: 158,
        weightKg: 65,
        activityLevel: 'Light',
        ethnicity: 'South Asian (Indian)',
        dietaryPreferences: ['Vegetarian'],
        allergies: [],
        goal: HealthGoal.heartHealth,
        customMacroBudget: DailyMacroBudget.defaultBudget(),
      );

      final assessment = BmiCalculator.calculate(profile);

      expect(assessment.recommendedBudget.targetSodiumMg, lessThanOrEqualTo(1500.0));
      expect(assessment.recommendedBudget.targetPotassiumMg, greaterThanOrEqualTo(3500.0));
    });
  });
}
