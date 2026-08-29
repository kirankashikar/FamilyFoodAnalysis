import 'package:flutter_test/flutter_test.dart';
import 'package:family_food_analysis/data/models/user_profile.dart';
import 'package:family_food_analysis/data/models/nutrition_goals.dart';
import 'package:family_food_analysis/data/models/food_item.dart';
import 'package:family_food_analysis/data/models/grocery_item.dart';
import 'package:family_food_analysis/domain/services/recommendation_engine.dart';

void main() {
  group('RecommendationEngine Tests', () {
    test('Triggers protein boost suggestion when intake is deficient', () {
      final member = FamilyMemberProfile(
        id: 'self',
        name: 'Kiran',
        relationship: 'Self',
        age: 30,
        gender: 'Male',
        heightCm: 175,
        weightKg: 72,
        activityLevel: 'Moderate',
        ethnicity: 'South Asian (Indian)',
        dietaryPreferences: ['Vegetarian'],
        allergies: [],
        goal: HealthGoal.muscleGain,
        customMacroBudget: DailyMacroBudget(
          targetCalories: 2200,
          targetProteinGrams: 110,
          targetCarbsGrams: 260,
          targetFatGrams: 60,
          targetFiberGrams: 35,
          targetSodiumMg: 2000,
          targetPotassiumMg: 3500,
        ),
      );

      // Low protein intake (only 30g logged out of 110g)
      const lowProteinIntake = MacroNutrients(
        calories: 1200,
        proteinGrams: 30,
        carbsGrams: 180,
        fatGrams: 35,
        fiberGrams: 12,
        sodiumMg: 1100,
      );

      final recs = RecommendationEngine.generateRecommendations(
        member: member,
        todayIntake: lowProteinIntake,
        inventory: [],
      );

      final proteinRec = recs.where((r) => r.affectedNutrient == 'Protein').toList();
      expect(proteinRec, isNotEmpty);
      expect(proteinRec.first.category, RecommendationCategory.deficitBoost);
      expect(proteinRec.first.suggestedAction, contains('paneer'));
    });

    test('Triggers sodium warning when daily threshold is approached', () {
      final member = FamilyMemberProfile(
        id: 'self',
        name: 'User',
        relationship: 'Self',
        age: 45,
        gender: 'Female',
        heightCm: 160,
        weightKg: 65,
        activityLevel: 'Light',
        ethnicity: 'South Asian (Indian)',
        dietaryPreferences: [],
        allergies: [],
        goal: HealthGoal.heartHealth,
        customMacroBudget: DailyMacroBudget(
          targetCalories: 1600,
          targetProteinGrams: 70,
          targetCarbsGrams: 190,
          targetFatGrams: 45,
          targetFiberGrams: 30,
          targetSodiumMg: 1500, // Strict 1500mg budget
          targetPotassiumMg: 3800,
        ),
      );

      // Sodium logged at 1450mg (approaching limit)
      const highSodiumIntake = MacroNutrients(
        calories: 1100,
        proteinGrams: 45,
        carbsGrams: 130,
        fatGrams: 30,
        fiberGrams: 15,
        sodiumMg: 1450,
      );

      final recs = RecommendationEngine.generateRecommendations(
        member: member,
        todayIntake: highSodiumIntake,
        inventory: [],
      );

      final sodiumRec = recs.where((r) => r.affectedNutrient == 'Sodium').toList();
      expect(sodiumRec, isNotEmpty);
      expect(sodiumRec.first.category, RecommendationCategory.excessWarning);
    });

    test('Triggers expiring pantry item notification to prevent food waste', () {
      final member = FamilyMemberProfile(
        id: 'self',
        name: 'User',
        relationship: 'Self',
        age: 30,
        gender: 'Male',
        heightCm: 170,
        weightKg: 70,
        activityLevel: 'Moderate',
        ethnicity: 'South Asian (Indian)',
        dietaryPreferences: [],
        allergies: [],
        goal: HealthGoal.balancedMaintenance,
        customMacroBudget: DailyMacroBudget.defaultBudget(),
      );

      final inventory = [
        GroceryItem(
          id: 'item_spinach',
          name: 'Fresh Palak Spinach',
          category: GroceryCategory.produce,
          quantity: 2,
          unit: 'bunches',
          estimatedCost: 2.99,
          purchaseDate: DateTime.now().subtract(const Duration(days: 4)),
          expiryDate: DateTime.now().add(const Duration(days: 2)), // Expiring in 2 days
          remainingQuantity: 2.0,
        ),
      ];

      final recs = RecommendationEngine.generateRecommendations(
        member: member,
        todayIntake: const MacroNutrients(calories: 1000, proteinGrams: 50, carbsGrams: 120, fatGrams: 30),
        inventory: inventory,
      );

      final pantryRec = recs.where((r) => r.category == RecommendationCategory.pantryUsage).toList();
      expect(pantryRec, isNotEmpty);
      expect(pantryRec.first.targetFoodName, 'Fresh Palak Spinach');
    });
  });
}
