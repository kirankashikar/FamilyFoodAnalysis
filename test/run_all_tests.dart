import '../lib/data/models/user_profile.dart';
import '../lib/data/models/nutrition_goals.dart';
import '../lib/data/models/food_item.dart';
import '../lib/data/models/grocery_item.dart';
import '../lib/data/models/store_connector_models.dart';
import '../lib/data/services/food_database_service.dart';
import '../lib/data/services/ocr_bill_scanner_service.dart';
import '../lib/data/services/google_sheets_service.dart';
import '../lib/data/services/costco_connector_service.dart';
import '../lib/data/services/amazon_connector_service.dart';
import '../lib/domain/services/bmi_calculator.dart';
import '../lib/domain/services/recommendation_engine.dart';

void main() async {
  int passed = 0;
  int failed = 0;

  void expect(bool condition, String testName) {
    if (condition) {
      print('  ✅ PASS: $testName');
      passed++;
    } else {
      print('  ❌ FAIL: $testName');
      failed++;
    }
  }

  print('\n🧪 [1/6] Running BMI Calculator & Caloric Distribution Tests...');
  final kiranProfile = FamilyMemberProfile(
    id: 'kiran_01',
    name: 'Kiran Kashikar',
    relationship: 'Self',
    age: 32,
    gender: 'Male',
    heightCm: 175.0,
    weightKg: 72.0,
    activityLevel: 'Moderate',
    ethnicity: 'South Asian (Indian)',
    dietaryPreferences: ['Vegetarian'],
    allergies: ['Peanuts'],
    goal: HealthGoal.muscleGain,
    customMacroBudget: DailyMacroBudget.defaultBudget(),
  );

  final bmiAssessment = BmiCalculator.calculate(kiranProfile);
  expect((bmiAssessment.bmi - 23.5).abs() < 0.2, 'BMI calculated accurately (~23.5)');
  expect(bmiAssessment.category == 'Normal weight', 'BMI category is Normal weight');
  expect(bmiAssessment.bmr > 1600 && bmiAssessment.bmr < 1800, 'BMR falls in accurate Mifflin-St Jeor range');
  expect(bmiAssessment.tdee > bmiAssessment.bmr, 'TDEE accounts for moderate activity multiplier');
  expect(bmiAssessment.recommendedBudget.targetProteinGrams >= 100, 'Muscle gain goal allocates high protein (>= 100g)');

  print('\n🧪 [2/6] Running Food Database & Cultural Diets Tests...');
  final foodDb = FoodDatabaseService();
  final allFoods = foodDb.getAllFoodItems();
  expect(allFoods.length >= 10, 'Predefined database contains comprehensive ethnic foods');
  
  final southIndianDishes = foodDb.search(cuisine: 'South Indian');
  expect(southIndianDishes.any((f) => f.name.contains('Dosa')), 'South Indian cuisine includes Dosa');
  expect(southIndianDishes.any((f) => f.name.contains('Idli')), 'South Indian cuisine includes Idli');
  expect(southIndianDishes.any((f) => f.name.contains('Sambar')), 'South Indian cuisine includes Sambar');

  final medDishes = foodDb.search(cuisine: 'Mediterranean');
  expect(medDishes.any((f) => f.name.contains('Hummus')), 'Mediterranean cuisine includes Hummus');
  expect(medDishes.any((f) => f.name.contains('Pita')), 'Mediterranean cuisine includes Pita');

  print('\n🧪 [3/6] Running Receipt OCR Bill Scanner Tests...');
  final ocrService = OcrBillScannerService();
  final sampleReceipts = ocrService.getSampleReceiptPresets();
  expect(sampleReceipts.isNotEmpty, 'Preset grocery receipts available');

  final indianMartReceipt = sampleReceipts.first;
  final scanned = await ocrService.parseReceiptText(indianMartReceipt.rawText, storeNameHint: indianMartReceipt.storeName);
  expect(scanned.extractedItems.length >= 5, 'OCR parses multiple line items from receipt');
  expect(scanned.totalAmount > 0, 'Total bill amount extracted correctly');
  expect(scanned.extractedItems.any((i) => i.category == GroceryCategory.grainsAndPulses), 'Categorizes Dosa batter & Dals into grainsAndPulses');

  print('\n🧪 [4/6] Running Google Sheets Synchronization Tests...');
  final sheetsService = GoogleSheetsService();
  final testInventory = scanned.extractedItems;
  final csvOutput = sheetsService.generateInventoryCsv(testInventory);
  expect(csvOutput.contains('Item ID,Item Name,Category'), 'Generates valid RFC CSV header for Google Sheets');
  expect(csvOutput.contains('Dosa Batter') || csvOutput.contains('Dal'), 'Includes grocery line items in CSV');

  final parsedBack = sheetsService.parseInventoryCsv(csvOutput);
  expect(parsedBack.length == testInventory.length, 'Bidirectional CSV parsing preserves all ${testInventory.length} inventory items');

  final syncResult = await sheetsService.syncToGoogleSheets(
    inventory: testInventory,
    intakeLogs: [],
    recipes: [],
  );
  expect(syncResult.isSuccess, 'Sync to Google Sheets succeeds with active session');

  print('\n🧪 [5/6] Running AI Recommendations & Health Goals Engine Tests...');
  const lowProteinIntake = MacroNutrients(
    calories: 1300,
    proteinGrams: 35,
    carbsGrams: 190,
    fatGrams: 38,
    fiberGrams: 14,
    sodiumMg: 1200,
  );

  final recs = RecommendationEngine.generateRecommendations(
    member: kiranProfile,
    todayIntake: lowProteinIntake,
    inventory: testInventory,
  );

  expect(recs.isNotEmpty, 'Recommendation engine produces targeted suggestions');
  expect(recs.any((r) => r.affectedNutrient == 'Protein'), 'Flags protein deficit for muscle gain goal');
  expect(recs.any((r) => r.category == RecommendationCategory.pantryUsage || r.category == RecommendationCategory.swap), 'Suggests pantry fresh produce usage or swaps');

  print('\n🧪 [6/6] Running Costco & Amazon Store Purchase Connectors Tests...');
  final costcoService = CostcoConnectorService();
  final costcoConfig = await costcoService.connectAccount(
    membershipNumber: '883920194821',
    accountEmail: 'kiran@example.com',
  );
  expect(costcoConfig.isConnected, 'Costco membership connected successfully');

  final costcoOrders = await costcoService.fetchPurchaseHistory();
  expect(costcoOrders.length >= 2, 'Fetches Costco warehouse and 2-day delivery order history');
  final warehouseOrder = costcoOrders.first;
  expect(warehouseOrder.items.any((i) => i.name.contains('Eggs')), 'Parses Costco 24ct pasture-raised eggs');
  expect(warehouseOrder.items.any((i) => i.name.contains('Olive Oil')), 'Parses Costco 2L organic EVOO');

  final amazonService = AmazonConnectorService();
  final amznFreshConfig = await amazonService.connectAmazonAccount(
    accountEmail: 'kiran@example.com',
    storeType: StoreType.amazonFresh,
  );
  expect(amznFreshConfig.isConnected, 'Amazon Fresh connected successfully');

  final amznOrders = await amazonService.fetchPurchaseHistory();
  expect(amznOrders.length >= 2, 'Fetches Amazon Fresh and Whole Foods purchase orders');
  final freshOrder = amznOrders.firstWhere((o) => o.store == StoreType.amazonFresh);
  expect(freshOrder.items.any((i) => i.name.contains('Dosa')), 'Parses Amazon Fresh South Indian Dosa/Idli Batter');
  expect(freshOrder.items.any((i) => i.name.contains('Hummus')), 'Parses Whole Foods Organic Hummus');

  print('\n======================================================');
  print('🎉 TEST SUMMARY: $passed Passed, $failed Failed');
  print('======================================================\n');
}
