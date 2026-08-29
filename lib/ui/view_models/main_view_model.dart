import 'package:flutter/foundation.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/grocery_item.dart';
import '../../data/models/food_item.dart';
import '../../data/models/recipe.dart';
import '../../data/models/nutrition_goals.dart';
import '../../data/models/google_sheets_config.dart';
import '../../data/models/store_connector_models.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/food_database_service.dart';
import '../../data/services/google_sheets_service.dart';
import '../../data/services/ocr_bill_scanner_service.dart';
import '../../data/services/costco_connector_service.dart';
import '../../data/services/amazon_connector_service.dart';
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
  final CostcoConnectorService _costcoService;
  final AmazonConnectorService _amazonService;

  int _selectedTabIndex = 0;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isSyncingStore = false;
  String? _statusNotification;

  List<StoreOrder> _costcoOrders = [];
  List<StoreOrder> _amazonOrders = [];

  MainViewModel({
    required AuthService authService,
    required InventoryRepository inventoryRepo,
    required IntakeRepository intakeRepo,
    required RecipeRepository recipeRepo,
    required FoodDatabaseService foodDb,
    required GoogleSheetsService sheetsService,
    required OcrBillScannerService ocrService,
    CostcoConnectorService? costcoService,
    AmazonConnectorService? amazonService,
  })  : _authService = authService,
        _inventoryRepo = inventoryRepo,
        _intakeRepo = intakeRepo,
        _recipeRepo = recipeRepo,
        _foodDb = foodDb,
        _sheetsService = sheetsService,
        _ocrService = ocrService,
        _costcoService = costcoService ?? CostcoConnectorService(),
        _amazonService = amazonService ?? AmazonConnectorService();

  // Getters
  int get selectedTabIndex => _selectedTabIndex;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  bool get isSyncingStore => _isSyncingStore;
  String? get statusNotification => _statusNotification;

  UserProfile? get currentUser => _authService.currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;
  FamilyMemberProfile get activeMember => _authService.currentUser?.activeMember ?? _createFallbackMember();

  OcrBillScannerService get ocrService => _ocrService;
  FoodDatabaseService get foodDb => _foodDb;
  InventoryRepository get inventoryRepo => _inventoryRepo;
  IntakeRepository get intakeRepo => _intakeRepo;
  RecipeRepository get recipeRepo => _recipeRepo;

  List<GroceryItem> get inventoryItems => _inventoryRepo.items;
  List<GroceryItem> get expiringSoonItems => _inventoryRepo.expiringSoonItems;
  List<GroceryItem> get lowStockItems => _inventoryRepo.lowStockItems;

  List<MealEntry> get todayIntakeLogs => _intakeRepo.getEntriesForDate(_selectedDate, activeMember.id);
  DailyIntakeSummary get todaySummary => NutritionAnalytics.calculateDailySummary(todayIntakeLogs);

  List<Recipe> get recipes => _recipeRepo.recipes;
  GoogleSheetsConfig get sheetsConfig => _sheetsService.config;

  BmiAssessment get activeMemberBmiAssessment => BmiCalculator.calculate(activeMember);

  List<RecommendationItem> get currentRecommendations {
    return RecommendationEngine.generateRecommendations(
      member: activeMember,
      todayIntake: todaySummary.totalMacros,
      inventory: _inventoryRepo.items,
    );
  }

  // Store Connectors Getters
  StoreAccountConfig get costcoConfig => _costcoService.config;
  StoreAccountConfig get amazonFreshConfig => _amazonService.freshConfig;
  StoreAccountConfig get amazonWholeFoodsConfig => _amazonService.wholeFoodsConfig;
  List<StoreOrder> get costcoOrders => _costcoOrders;
  List<StoreOrder> get amazonOrders => _amazonOrders;

  // Actions & Tab Navigation
  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Auth Operations
  Future<void> loginWithGoogle() async {
    _setLoading(true);
    try {
      final user = await _authService.signInWithGoogle();
      _setNotification('Welcome back, ${user.displayName}!');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() => loginWithGoogle();

  Future<void> loginWithGithub() async {
    _setLoading(true);
    try {
      final user = await _authService.signInWithGithub();
      _setNotification('Logged in with GitHub as ${user.displayName}');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> signInWithGithub() => loginWithGithub();

  Future<void> loginAsGuest() async {
    _setLoading(true);
    try {
      await _authService.signInAsGuest();
      _setNotification('Logged in as Demo Family Account');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> signInAsGuest() => loginAsGuest();

  Future<void> logout() async {
    await _authService.signOut();
    _setNotification('Signed out');
    notifyListeners();
  }

  Future<void> signOut() => logout();

  void switchActiveFamilyMember(String memberId) {
    _authService.switchActiveMember(memberId);
    _setNotification('Switched to ${activeMember.name}');
    notifyListeners();
  }

  void switchFamilyMember(String memberId) => switchActiveFamilyMember(memberId);

  Future<void> updateActiveMemberProfile({
    FamilyMemberProfile? profile,
    String? name,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? activityLevel,
    String? ethnicity,
    List<String>? dietaryPreferences,
    List<String>? allergies,
    HealthGoal? goal,
    DailyMacroBudget? customMacroBudget,
  }) async {
    final current = activeMember;
    final updated = profile ?? current.copyWith(
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
      customMacroBudget: customMacroBudget,
    );
    _authService.updateFamilyMember(updated);
    _setNotification('Updated profile and goals for ${updated.name}');
    notifyListeners();
  }

  Future<void> addFamilyMember(FamilyMemberProfile newMember) async {
    _authService.addFamilyMember(newMember);
    _setNotification('Added family member: ${newMember.name}');
    notifyListeners();
  }

  // Inventory Operations
  Future<void> addGroceryItem(GroceryItem item) async {
    await _inventoryRepo.addItem(item);
    _setNotification('Added ${item.name} to pantry');
    notifyListeners();
  }

  Future<void> updateGroceryItem(GroceryItem item) async {
    await _inventoryRepo.updateItem(item);
    notifyListeners();
  }

  Future<void> removeGroceryItem(String itemId) async {
    await _inventoryRepo.deleteItem(itemId);
    _setNotification('Removed item from pantry');
    notifyListeners();
  }

  Future<void> updateItemQuantity(String itemId, double newRemaining) async {
    await _inventoryRepo.updateQuantity(itemId, newRemaining);
    notifyListeners();
  }

  Future<void> updateGroceryItemQuantity(String itemId, double newRemaining) => updateItemQuantity(itemId, newRemaining);

  // Receipt Scanner Operations
  Future<GroceryReceipt> scanReceiptImage(String imagePathOrBase64, {String? storeName}) async {
    _setLoading(true);
    try {
      final receipt = await _ocrService.parseReceiptImage(imagePathOrBase64, storeNameHint: storeName);
      return receipt;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<GroceryReceipt> parseReceiptText(String text, {String? storeName}) async {
    _setLoading(true);
    try {
      final receipt = await _ocrService.parseReceiptText(text, storeNameHint: storeName);
      return receipt;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> processReceiptBill(
    dynamic billOrItems, {
    String? storeName,
    String? rawText,
    List<GroceryItem>? items,
    double? totalAmount,
  }) async {
    if (billOrItems is GroceryReceipt) {
      await importReceiptItemsToPantry(billOrItems.extractedItems);
    } else if (billOrItems is List<GroceryItem>) {
      await importReceiptItemsToPantry(billOrItems);
    } else if (items != null) {
      await importReceiptItemsToPantry(items);
    }
  }

  Future<void> importReceiptItemsToPantry(List<GroceryItem> items) async {
    for (final it in items) {
      await _inventoryRepo.addItem(it);
    }
    _setNotification('Imported ${items.length} grocery items into pantry!');
    notifyListeners();
  }

  // Store Connectors Operations (Costco & Amazon)
  Future<void> connectCostco(String membershipNumber, String email) async {
    _isSyncingStore = true;
    notifyListeners();
    try {
      final res = await _costcoService.connectAccount(
        membershipNumber: membershipNumber,
        accountEmail: email,
      );
      if (res.isConnected) {
        _setNotification('Costco connected! Syncing recent warehouse purchase history...');
        await syncCostcoPurchases();
      } else {
        _setNotification(res.syncMessage ?? 'Costco connection failed');
      }
    } finally {
      _isSyncingStore = false;
      notifyListeners();
    }
  }

  void disconnectCostco() {
    _costcoService.disconnect();
    _costcoOrders.clear();
    _setNotification('Disconnected Costco account');
    notifyListeners();
  }

  Future<void> syncCostcoPurchases() async {
    _isSyncingStore = true;
    notifyListeners();
    try {
      final orders = await _costcoService.fetchPurchaseHistory();
      _costcoOrders = orders;
      int importedCount = 0;
      for (final o in orders) {
        if (o.isImportedToPantry) {
          for (final it in o.items) {
            final exists = _inventoryRepo.items.any((existing) => existing.id == it.id || existing.name.toLowerCase() == it.name.toLowerCase());
            if (!exists) {
              await _inventoryRepo.addItem(it);
              importedCount++;
            }
          }
        }
      }
      _setNotification('Costco sync complete! ($importedCount new items added to pantry)');
    } finally {
      _isSyncingStore = false;
      notifyListeners();
    }
  }

  Future<void> connectAmazon(String email, StoreType storeType) async {
    _isSyncingStore = true;
    notifyListeners();
    try {
      final res = await _amazonService.connectAmazonAccount(
        accountEmail: email,
        storeType: storeType,
      );
      if (res.isConnected) {
        _setNotification('${storeType.displayName} connected! Syncing grocery orders...');
        await syncAmazonPurchases();
      } else {
        _setNotification(res.syncMessage ?? 'Amazon connection failed');
      }
    } finally {
      _isSyncingStore = false;
      notifyListeners();
    }
  }

  void disconnectAmazon(StoreType storeType) {
    _amazonService.disconnect(storeType);
    _amazonOrders.removeWhere((o) => o.store == storeType);
    _setNotification('Disconnected ${storeType.displayName}');
    notifyListeners();
  }

  Future<void> syncAmazonPurchases() async {
    _isSyncingStore = true;
    notifyListeners();
    try {
      final orders = await _amazonService.fetchPurchaseHistory();
      _amazonOrders = orders;
      int importedCount = 0;
      for (final o in orders) {
        if (o.isImportedToPantry) {
          for (final it in o.items) {
            final exists = _inventoryRepo.items.any((existing) => existing.id == it.id || existing.name.toLowerCase() == it.name.toLowerCase());
            if (!exists) {
              await _inventoryRepo.addItem(it);
              importedCount++;
            }
          }
        }
      }
      _setNotification('Amazon grocery sync complete! ($importedCount new items added to pantry)');
    } finally {
      _isSyncingStore = false;
      notifyListeners();
    }
  }

  Future<void> importStoreOrderToPantry(StoreOrder order) async {
    int count = 0;
    for (final it in order.items) {
      final exists = _inventoryRepo.items.any((existing) => existing.id == it.id);
      if (!exists) {
        await _inventoryRepo.addItem(it);
        count++;
      }
    }
    _setNotification('Imported $count items from ${order.store.displayName} (Order #${order.orderId}) to pantry!');
    notifyListeners();
  }

  // Food Intake Operations
  Future<void> logFoodIntake({
    required FoodItem foodItem,
    required MealType mealType,
    required double servings,
    String? notes,
  }) async {
    final entry = MealEntry.fromFoodItem(
      food: foodItem,
      memberId: activeMember.id,
      mealType: mealType,
      servings: servings,
      timestamp: DateTime.now(),
      notes: notes,
    );

    await _intakeRepo.addEntry(entry);

    // If matching inventory item exists, deduct proportional quantity
    await _deductInventoryFromMeal(foodItem.name, servings);

    _setNotification('Logged ${foodItem.name} (${mealType.displayName})');
    notifyListeners();
  }

  Future<void> logFoodItem({
    FoodItem? food,
    FoodItem? foodItem,
    required MealType mealType,
    required double servings,
    String? notes,
  }) {
    final target = food ?? foodItem;
    if (target == null) return Future.value();
    return logFoodIntake(foodItem: target, mealType: mealType, servings: servings, notes: notes);
  }

  Future<void> removeIntakeEntry(String entryId) async {
    await _intakeRepo.deleteEntry(entryId);
    _setNotification('Removed meal entry');
    notifyListeners();
  }

  Future<void> removeMealEntry(String entryId) => removeIntakeEntry(entryId);

  Future<void> _deductInventoryFromMeal(String foodName, double servings) async {
    final search = foodName.toLowerCase();
    for (final it in _inventoryRepo.items) {
      if (search.contains(it.name.toLowerCase()) || it.name.toLowerCase().contains(search.split(' ').first)) {
        final deduct = (1.0 * servings).clamp(0.0, it.remainingQuantity);
        if (deduct > 0) {
          await _inventoryRepo.updateQuantity(it.id, it.remainingQuantity - deduct);
        }
        break;
      }
    }
  }

  // Food Database & Recipe Operations
  List<FoodItem> searchFoodDatabase({String? query, String? cuisine}) {
    return _foodDb.search(query: query ?? '', cuisine: cuisine);
  }

  List<String> get availableCuisines => _foodDb.getAllCuisines();

  Future<void> quickLogRecipe({
    required Recipe recipe,
    required MealType mealType,
    double servings = 1.0,
  }) async {
    final food = recipe.toFoodItem();
    await logFoodIntake(
      foodItem: food,
      mealType: mealType,
      servings: servings,
      notes: 'Quick logged from recipe: ${recipe.name}',
    );

    for (final ing in recipe.ingredients) {
      for (final it in _inventoryRepo.items) {
        if (it.name.toLowerCase().contains(ing.name.toLowerCase())) {
          final deduct = (ing.quantity * servings).clamp(0.0, it.remainingQuantity);
          if (deduct > 0) {
            await _inventoryRepo.updateQuantity(it.id, it.remainingQuantity - deduct);
          }
          break;
        }
      }
    }
  }

  Future<void> logRecipeToMeal({
    required Recipe recipe,
    required MealType mealType,
    double servings = 1.0,
  }) => quickLogRecipe(recipe: recipe, mealType: mealType, servings: servings);

  Future<void> toggleRecipeFavorite(String recipeId) async {
    await _recipeRepo.toggleFavorite(recipeId);
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
