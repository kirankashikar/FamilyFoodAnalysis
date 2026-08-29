import 'package:flutter/foundation.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/grocery_item.dart';
import '../../data/models/food_item.dart';
import '../../data/models/recipe.dart';
import '../../data/models/nutrition_goals.dart';
import '../../data/models/google_sheets_config.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/food_database_service.dart';
import '../../data/services/google_sheets_service.dart';
import '../../data/services/ocr_bill_scanner_service.dart';
import '../../data/repositories/app_repositories.dart';
import '../../domain/services/bmi_calculator.dart';
import '../../domain/services/nutrition_analytics.dart';
import '../../domain/services/recommendation_engine.dart';

class MainViewModel extends ChangeNotifier {
  final AuthService _authService;
  final InventoryRepository _inventoryRepo;
  final IntakeRepository _intakeRepo;
  final RecipeRepository _recipeRepo;
  final FoodDatabaseService _foodDb;
  final GoogleSheetsService _sheetsService;
  final OcrBillScannerService _ocrService;

  int _selectedTabIndex = 0;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _statusNotification;

  MainViewModel({
    required AuthService authService,
    required InventoryRepository inventoryRepo,
    required IntakeRepository intakeRepo,
    required RecipeRepository recipeRepo,
    required FoodDatabaseService foodDb,
    required GoogleSheetsService sheetsService,
    required OcrBillScannerService ocrService,
  })  : _authService = authService,
        _inventoryRepo = inventoryRepo,
        _intakeRepo = intakeRepo,
        _recipeRepo = recipeRepo,
        _foodDb = foodDb,
        _sheetsService = sheetsService,
        _ocrService = ocrService;

  // Getters
  int get selectedTabIndex => _selectedTabIndex;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get statusNotification => _statusNotification;

  UserProfile? get currentUser => _authService.currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;
  FamilyMemberProfile get activeMember => _authService.currentUser?.activeMember ?? _createFallbackMember();

  List<GroceryItem> get inventoryItems => _inventoryRepo.items;
  List<GroceryItem> get expiringSoonItems => _inventoryRepo.expiringSoonItems;
  List<GroceryItem> get lowStockItems => _inventoryRepo.lowStockItems;

  List<MealEntry> get allIntakeLogs => _intakeRepo.entries;
  List<Recipe> get recipes => _recipeRepo.recipes;
  List<Recipe> get favoriteRecipes => _recipeRepo.recipes.where((r) => r.isFavorite).toList();
  List<Recipe> get frequentlyPreparedRecipes => _recipeRepo.recipes.where((r) => r.isFrequentlyPrepared).toList();

  FoodDatabaseService get foodDb => _foodDb;
  GoogleSheetsConfig get sheetsConfig => _sheetsService.config;
  OcrBillScannerService get ocrService => _ocrService;

  // Daily Summary Calculation
  DailyIntakeSummary get todaySummary {
    final memberId = activeMember.id;
    final entries = _intakeRepo.getEntriesForMemberAndDate(memberId, _selectedDate);
    final budget = activeMember.customMacroBudget;
    return NutritionAnalytics.analyzeDay(
      date: _selectedDate,
      entries: entries,
      budget: budget,
    );
  }

  // Active Member BMI Assessment
  BmiAssessment get activeMemberBmiAssessment {
    return BmiCalculator.calculate(activeMember);
  }

  // Real-time AI Recommendations
  List<RecommendationItem> get currentRecommendations {
    return RecommendationEngine.generateRecommendations(
      member: activeMember,
      todayIntake: todaySummary.totalNutrients,
      inventory: _inventoryRepo.items,
    );
  }

  // Actions & State Updates
  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void switchActiveFamilyMember(String memberId) {
    _authService.switchActiveMember(memberId);
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _authService.signInWithGoogle();
      _setNotification('Signed in with Google as ${currentUser?.displayName}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGithub() async {
    _setLoading(true);
    try {
      await _authService.signInWithGithub();
      _setNotification('Signed in with GitHub as ${currentUser?.displayName}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInAsGuest() async {
    _setLoading(true);
    try {
      await _authService.signInAsGuest();
      _setNotification('Started demo session with sample family data');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _selectedTabIndex = 0;
    notifyListeners();
  }

  Future<void> updateActiveMemberProfile({
    required String name,
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    required String activityLevel,
    required String ethnicity,
    required List<String> dietaryPreferences,
    required List<String> allergies,
    required HealthGoal goal,
    DailyMacroBudget? customBudget,
  }) async {
    final updatedMember = activeMember.copyWith(
      name: name,
      age: age,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      activityLevel: activityLevel,
      ethnicity: ethnicity,
      dietaryPreferences: dietaryPreferences,
      allergies: allergies,
      goal: goal,
      customMacroBudget: customBudget ?? BmiCalculator.calculate(activeMember.copyWith(
        heightCm: heightCm,
        weightKg: weightKg,
        age: age,
        gender: gender,
        activityLevel: activityLevel,
        goal: goal,
      )).recommendedBudget,
    );

    _authService.updateFamilyMember(updatedMember);
    _setNotification('Profile & BMI goals updated for $name');
    notifyListeners();
  }

  Future<void> addFamilyMember(FamilyMemberProfile newMember) async {
    _authService.addFamilyMember(newMember);
    _setNotification('Added family member: ${newMember.name}');
    notifyListeners();
  }

  // Inventory Management
  Future<void> addGroceryItem(GroceryItem item) async {
    await _inventoryRepo.addItem(item);
    _setNotification('Added ${item.name} to pantry inventory');
    notifyListeners();
  }

  Future<void> updateGroceryItemQuantity(String id, double newRemaining) async {
    final it = _inventoryRepo.items.firstWhere((x) => x.id == id);
    await _inventoryRepo.updateItem(it.copyWith(remainingQuantity: newRemaining));
    notifyListeners();
  }

  Future<void> removeGroceryItem(String id) async {
    await _inventoryRepo.removeItem(id);
    _setNotification('Removed item from inventory');
    notifyListeners();
  }

  Future<void> processReceiptBill(String rawText, {String? storeName, String? imagePath}) async {
    _setLoading(true);
    try {
      final receipt = await _ocrService.parseReceiptText(rawText, storeNameHint: storeName, imagePath: imagePath);
      await _inventoryRepo.addItemsFromReceipt(receipt);
      _setNotification('Scanned receipt from ${receipt.storeName}: Added ${receipt.extractedItems.length} items to inventory');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Meal Intake Logging
  Future<void> logFoodItem({
    required FoodItem food,
    required MealType mealType,
    required double servings,
    String? notes,
  }) async {
    final entry = MealEntry(
      id: 'meal_${DateTime.now().millisecondsSinceEpoch}',
      memberId: activeMember.id,
      foodItemId: food.id,
      foodName: food.name,
      mealType: mealType,
      servings: servings,
      servingUnit: food.defaultServingUnit,
      calculatedNutrients: food.nutrientsPerServing.scale(servings),
      timestamp: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        DateTime.now().hour,
        DateTime.now().minute,
      ),
      notes: notes,
    );

    await _intakeRepo.logMeal(entry);
    _setNotification('Logged ${food.name} for ${mealType.displayName}');
    notifyListeners();
  }

  Future<void> logRecipeToMeal({
    required Recipe recipe,
    required MealType mealType,
    required double servings,
  }) async {
    final entry = MealEntry(
      id: 'meal_rec_${DateTime.now().millisecondsSinceEpoch}',
      memberId: activeMember.id,
      foodItemId: recipe.id,
      foodName: recipe.name,
      mealType: mealType,
      servings: servings,
      servingUnit: 'serving',
      calculatedNutrients: recipe.nutrientsPerServing.scale(servings),
      timestamp: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        DateTime.now().hour,
        DateTime.now().minute,
      ),
      notes: 'Prepared from recipe catalog',
    );

    await _intakeRepo.logMeal(entry);
    _setNotification('Logged ${recipe.name} (${servings.toStringAsFixed(1)} serv) for ${mealType.displayName}');
    notifyListeners();
  }

  Future<void> removeMealEntry(String id) async {
    await _intakeRepo.removeEntry(id);
    _setNotification('Deleted meal entry');
    notifyListeners();
  }

  // Recipes
  Future<void> toggleRecipeFavorite(String id) async {
    await _recipeRepo.toggleFavorite(id);
    notifyListeners();
  }

  Future<void> toggleRecipeFrequentlyPrepared(String id) async {
    await _recipeRepo.toggleFrequentlyPrepared(id);
    notifyListeners();
  }

  Future<void> addCustomRecipe(Recipe recipe) async {
    await _recipeRepo.addRecipe(recipe);
    _setNotification('Saved new recipe: ${recipe.name}');
    notifyListeners();
  }

  // Google Sheets Synchronization
  Future<SyncResult> syncToGoogleSheets() async {
    _setLoading(true);
    try {
      final res = await _sheetsService.syncToGoogleSheets(
        inventory: _inventoryRepo.items,
        intakeLogs: _intakeRepo.entries,
        recipes: _recipeRepo.recipes,
      );
      _setNotification(res.message);
      return res;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void updateSheetsConfig(GoogleSheetsConfig newConfig) {
    _sheetsService.updateConfig(newConfig);
    _setNotification('Updated Google Sheets configuration');
    notifyListeners();
  }

  String exportInventoryAsCsv() => _sheetsService.generateInventoryCsv(_inventoryRepo.items);
  String exportIntakeAsCsv() => _sheetsService.generateIntakeCsv(_intakeRepo.entries);

  void importInventoryFromCsv(String csv) {
    final parsed = _sheetsService.parseInventoryCsv(csv);
    if (parsed.isNotEmpty) {
      _inventoryRepo.setAllItems(parsed);
      _setNotification('Imported ${parsed.length} items from CSV into pantry inventory');
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setNotification(String msg) {
    _statusNotification = msg;
    notifyListeners();
  }

  void clearNotification() {
    _statusNotification = null;
    notifyListeners();
  }

  FamilyMemberProfile _createFallbackMember() {
    return FamilyMemberProfile(
      id: 'self',
      name: 'User',
      relationship: 'Self',
      age: 30,
      gender: 'Male',
      heightCm: 175.0,
      weightKg: 70.0,
      activityLevel: 'Moderate',
      ethnicity: 'South Asian (Indian)',
      dietaryPreferences: ['Vegetarian'],
      allergies: [],
      goal: HealthGoal.balancedMaintenance,
      customMacroBudget: DailyMacroBudget.defaultBudget(),
    );
  }
}
