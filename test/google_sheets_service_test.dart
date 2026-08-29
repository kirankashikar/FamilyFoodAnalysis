import 'package:flutter_test/flutter_test.dart';
import 'package:family_food_analysis/data/models/grocery_item.dart';
import 'package:family_food_analysis/data/models/food_item.dart';
import 'package:family_food_analysis/data/services/google_sheets_service.dart';

void main() {
  group('GoogleSheetsService Tests', () {
    late GoogleSheetsService service;

    setUp(() {
      service = GoogleSheetsService();
    });

    test('Generates valid CSV for inventory items and parses back correctly', () {
      final items = [
        GroceryItem(
          id: 'test_item_1',
          name: 'Idli Dosa Batter',
          category: GroceryCategory.grainsAndPulses,
          quantity: 2.0,
          unit: 'lbs',
          estimatedCost: 4.99,
          purchaseDate: DateTime(2026, 8, 28),
          expiryDate: DateTime(2026, 9, 2),
          remainingQuantity: 2.0,
          storeName: 'Patel Brothers',
        ),
        GroceryItem(
          id: 'test_item_2',
          name: 'Organic Tahini Paste',
          category: GroceryCategory.condimentsAndSauces,
          quantity: 16.0,
          unit: 'oz',
          estimatedCost: 7.99,
          purchaseDate: DateTime(2026, 8, 25),
          expiryDate: DateTime(2026, 12, 1),
          remainingQuantity: 14.0,
          storeName: 'Trader Joe\'s',
        ),
      ];

      final csv = service.generateInventoryCsv(items);

      expect(csv, contains('Item ID,Item Name,Category'));
      expect(csv, contains('"Idli Dosa Batter"'));
      expect(csv, contains('"Organic Tahini Paste"'));

      final parsed = service.parseInventoryCsv(csv);
      expect(parsed.length, 2);
      expect(parsed[0].name, 'Idli Dosa Batter');
      expect(parsed[0].category, GroceryCategory.grainsAndPulses);
      expect(parsed[1].name, 'Organic Tahini Paste');
      expect(parsed[1].category, GroceryCategory.condimentsAndSauces);
    });

    test('Generates valid CSV for daily intake logs', () {
      final logs = [
        MealEntry(
          id: 'meal_1',
          memberId: 'self',
          foodItemId: 'food_dosa_masala',
          foodName: 'Masala Dosa',
          mealType: MealType.breakfast,
          servings: 1.0,
          servingUnit: 'piece',
          calculatedNutrients: const MacroNutrients(
            calories: 250,
            proteinGrams: 5.5,
            carbsGrams: 39.0,
            fatGrams: 8.2,
            fiberGrams: 3.4,
            sodiumMg: 380,
          ),
          timestamp: DateTime(2026, 8, 29, 8, 30),
        ),
      ];

      final csv = service.generateIntakeCsv(logs);

      expect(csv, contains('Entry ID,Member ID,Food Item,Meal Type'));
      expect(csv, contains('"Masala Dosa"'));
      expect(csv, contains('"Breakfast"'));
      expect(csv, contains('250.0'));
    });
  });
}
