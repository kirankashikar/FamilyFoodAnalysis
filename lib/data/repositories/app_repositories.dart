import '../models/grocery_item.dart';
import '../models/food_item.dart';
import '../models/recipe.dart';
import '../services/local_storage_service.dart';
import '../services/ocr_bill_scanner_service.dart';

class InventoryRepository {
  final LocalStorageService _localStorage;
  List<GroceryItem> _items = [];

  InventoryRepository({
    required LocalStorageService localStorage,
    required OcrBillScannerService ocrService,
  }) : _localStorage = localStorage;

  List<GroceryItem> get items => List.unmodifiable(_items);

  Future<void> init() async {
    final loaded = await _localStorage.loadInventory();
    if (loaded != null && loaded.isNotEmpty) {
      _items = loaded;
    } else {
      // Seed with initial realistic pantry & grocery items
      _items = _getInitialSeedItems();
      await _localStorage.saveInventory(_items);
    }
  }

  Future<void> addItem(GroceryItem item) async {
    _items.insert(0, item);
    await _localStorage.saveInventory(_items);
  }

  Future<void> updateItem(GroceryItem item) async {
    final index = _items.indexWhere((x) => x.id == item.id);
    if (index != -1) {
      _items[index] = item;
      await _localStorage.saveInventory(_items);
    }
  }

  Future<void> removeItem(String id) async {
    _items.removeWhere((x) => x.id == id);
    await _localStorage.saveInventory(_items);
  }

  Future<void> deleteItem(String id) => removeItem(id);

  Future<void> updateQuantity(String id, double remaining) async {
    final index = _items.indexWhere((x) => x.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(remainingQuantity: remaining);
      await _localStorage.saveInventory(_items);
    }
  }

  Future<void> addItemsFromReceipt(GroceryReceipt receipt) async {
    for (final it in receipt.extractedItems) {
      _items.insert(0, it);
    }
    await _localStorage.saveInventory(_items);
  }

  Future<void> setAllItems(List<GroceryItem> newItems) async {
    _items = List.from(newItems);
    await _localStorage.saveInventory(_items);
  }

  List<GroceryItem> get expiringSoonItems => _items.where((x) => x.isExpiringSoon).toList();
  List<GroceryItem> get lowStockItems => _items.where((x) => x.isLowStock).toList();

  static List<GroceryItem> _getInitialSeedItems() {
    final now = DateTime.now();
    return [
      GroceryItem(
        id: 'seed_1',
        name: 'Idli Dosa Batter (Organic)',
        category: GroceryCategory.grainsAndPulses,
        quantity: 2,
        unit: 'lbs',
        estimatedCost: 4.99,
        purchaseDate: now.subtract(const Duration(days: 1)),
        expiryDate: now.add(const Duration(days: 4)),
        remainingQuantity: 1.5,
        storeName: 'Patel Brothers',
      ),
      GroceryItem(
        id: 'seed_2',
        name: 'Organic Tahini Paste',
        category: GroceryCategory.condimentsAndSauces,
        quantity: 16,
        unit: 'oz',
        estimatedCost: 7.99,
        purchaseDate: now.subtract(const Duration(days: 3)),
        expiryDate: now.add(const Duration(days: 120)),
        remainingQuantity: 14.0,
        storeName: 'Trader Joe\'s',
      ),
      GroceryItem(
        id: 'seed_3',
        name: 'Organic Chickpeas (Garbanzo)',
        category: GroceryCategory.grainsAndPulses,
        quantity: 4,
        unit: 'cans',
        estimatedCost: 5.20,
        purchaseDate: now.subtract(const Duration(days: 3)),
        expiryDate: now.add(const Duration(days: 300)),
        remainingQuantity: 3.0,
        storeName: 'Whole Foods',
      ),
      GroceryItem(
        id: 'seed_4',
        name: 'Fresh Palak Spinach',
        category: GroceryCategory.produce,
        quantity: 2,
        unit: 'bunches',
        estimatedCost: 2.99,
        purchaseDate: now.subtract(const Duration(days: 1)),
        expiryDate: now.add(const Duration(days: 3)), // Expiring soon!
        remainingQuantity: 2.0,
        storeName: 'Patel Brothers',
      ),
      GroceryItem(
        id: 'seed_5',
        name: 'Organic Fresh Paneer',
        category: GroceryCategory.dairyAndAlternatives,
        quantity: 400,
        unit: 'g',
        estimatedCost: 6.29,
        purchaseDate: now.subtract(const Duration(days: 1)),
        expiryDate: now.add(const Duration(days: 8)),
        remainingQuantity: 400.0,
        storeName: 'Patel Brothers',
      ),
      GroceryItem(
        id: 'seed_6',
        name: 'Extra Virgin Cold-Pressed Olive Oil',
        category: GroceryCategory.spicesAndOils,
        quantity: 1,
        unit: 'liter',
        estimatedCost: 12.99,
        purchaseDate: now.subtract(const Duration(days: 5)),
        expiryDate: now.add(const Duration(days: 365)),
        remainingQuantity: 0.85,
        storeName: 'Mediterranean Market',
      ),
      GroceryItem(
        id: 'seed_7',
        name: 'Whole Wheat Pita Pockets',
        category: GroceryCategory.snacksAndBaking,
        quantity: 6,
        unit: 'pockets',
        estimatedCost: 3.49,
        purchaseDate: now.subtract(const Duration(days: 2)),
        expiryDate: now.add(const Duration(days: 5)),
        remainingQuantity: 4.0,
        storeName: 'Cedars Marketplace',
      ),
    ];
  }
}

class IntakeRepository {
  final LocalStorageService _localStorage;
  List<MealEntry> _entries = [];

  IntakeRepository({required LocalStorageService localStorage}) : _localStorage = localStorage;

  List<MealEntry> get entries => List.unmodifiable(_entries);

  Future<void> init() async {
    final loaded = await _localStorage.loadIntakeLogs();
    if (loaded != null && loaded.isNotEmpty) {
      _entries = loaded;
    } else {
      _entries = _getInitialSeedIntake();
      await _localStorage.saveIntakeLogs(_entries);
    }
  }

  Future<void> logMeal(MealEntry entry) async {
    _entries.insert(0, entry);
    await _localStorage.saveIntakeLogs(_entries);
  }

  Future<void> addEntry(MealEntry entry) => logMeal(entry);

  Future<void> removeEntry(String id) async {
    _entries.removeWhere((x) => x.id == id);
    await _localStorage.saveIntakeLogs(_entries);
  }

  Future<void> deleteEntry(String id) => removeEntry(id);

  Future<void> setAllEntries(List<MealEntry> newEntries) async {
    _entries = List.from(newEntries);
    await _localStorage.saveIntakeLogs(_entries);
  }

  List<MealEntry> getEntriesForMemberAndDate(String memberId, DateTime date) {
    return _entries.where((e) {
      return e.memberId == memberId &&
          e.timestamp.year == date.year &&
          e.timestamp.month == date.month &&
          e.timestamp.day == date.day;
    }).toList();
  }

  List<MealEntry> getEntriesForDate(DateTime date, String memberId) => getEntriesForMemberAndDate(memberId, date);

  static List<MealEntry> _getInitialSeedIntake() {
    final now = DateTime.now();
    return [
      MealEntry(
        id: 'meal_seed_1',
        memberId: 'self',
        foodItemId: 'food_dosa_masala',
        foodName: 'Masala Dosa with Chutney',
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
          potassiumMg: 280,
        ),
        timestamp: DateTime(now.year, now.month, now.day, 8, 30),
      ),
      MealEntry(
        id: 'meal_seed_2',
        memberId: 'self',
        foodItemId: 'food_hummus',
        foodName: 'Hummus & Whole Wheat Pita',
        mealType: MealType.lunch,
        servings: 1.5,
        servingUnit: 'serving',
        calculatedNutrients: const MacroNutrients(
          calories: 390,
          proteinGrams: 14.5,
          carbsGrams: 52.0,
          fatGrams: 15.0,
          fiberGrams: 10.5,
          sodiumMg: 520,
          potassiumMg: 380,
        ),
        timestamp: DateTime(now.year, now.month, now.day, 13, 0),
      ),
    ];
  }
}

class RecipeRepository {
  final LocalStorageService _localStorage;
  List<Recipe> _recipes = [];

  RecipeRepository({required LocalStorageService localStorage}) : _localStorage = localStorage;

  List<Recipe> get recipes => List.unmodifiable(_recipes);

  Future<void> init() async {
    final loaded = await _localStorage.loadRecipes();
    if (loaded != null && loaded.isNotEmpty) {
      _recipes = loaded;
    } else {
      _recipes = _getInitialSeedRecipes();
      await _localStorage.saveRecipes(_recipes);
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    _recipes.insert(0, recipe);
    await _localStorage.saveRecipes(_recipes);
  }

  Future<void> toggleFavorite(String id) async {
    final idx = _recipes.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _recipes[idx] = _recipes[idx].copyWith(isFavorite: !_recipes[idx].isFavorite);
      await _localStorage.saveRecipes(_recipes);
    }
  }

  Future<void> toggleFrequentlyPrepared(String id) async {
    final idx = _recipes.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _recipes[idx] = _recipes[idx].copyWith(isFrequentlyPrepared: !_recipes[idx].isFrequentlyPrepared);
      await _localStorage.saveRecipes(_recipes);
    }
  }

  static List<Recipe> _getInitialSeedRecipes() {
    return [
      Recipe(
        id: 'rec_dosa_home',
        name: 'Crispy Masala Dosa with Potato Curry',
        cuisine: 'South Indian',
        prepTimeMinutes: 10,
        cookTimeMinutes: 15,
        defaultServings: 2,
        ingredients: [
          RecipeIngredient(name: 'Idli Dosa Batter', quantity: 200, unit: 'g'),
          RecipeIngredient(name: 'Potatoes (boiled & mashed)', quantity: 150, unit: 'g'),
          RecipeIngredient(name: 'Onion & Green Chilies', quantity: 50, unit: 'g'),
          RecipeIngredient(name: 'Sesame Gingelly Oil', quantity: 10, unit: 'ml'),
          RecipeIngredient(name: 'Mustard Seeds & Curry Leaves', quantity: 5, unit: 'g'),
        ],
        instructions: [
          'Heat a cast iron tawa until water drops sizzle and evaporate.',
          'Pour a ladleful of fermented batter and spread evenly in concentric circles from center outwards.',
          'Drizzle a few drops of sesame oil around the edges until golden and crisp.',
          'Place tempered spiced potato filling in center, fold, and serve hot with fresh coconut chutney and sambar.',
        ],
        nutrientsPerServing: const MacroNutrients(
          calories: 260,
          proteinGrams: 6.0,
          carbsGrams: 42.0,
          fatGrams: 8.0,
          fiberGrams: 3.8,
          sodiumMg: 360,
          potassiumMg: 290,
        ),
        dietaryTags: ['Vegetarian', 'Vegan', 'Fermented', 'Gut-Friendly'],
        isFavorite: true,
        isFrequentlyPrepared: true,
        description: 'Authentic South Indian golden fermented crepe stuffed with fragrant tempered potato filling.',
      ),
      Recipe(
        id: 'rec_hummus_home',
        name: 'Creamy Homemade Tahini Hummus & Warm Pita',
        cuisine: 'Mediterranean',
        prepTimeMinutes: 10,
        cookTimeMinutes: 0,
        defaultServings: 3,
        ingredients: [
          RecipeIngredient(name: 'Organic Chickpeas (boiled)', quantity: 250, unit: 'g'),
          RecipeIngredient(name: 'Organic Tahini Paste', quantity: 45, unit: 'g'),
          RecipeIngredient(name: 'Extra Virgin Olive Oil', quantity: 20, unit: 'ml'),
          RecipeIngredient(name: 'Garlic & Fresh Lemon Juice', quantity: 25, unit: 'ml'),
          RecipeIngredient(name: 'Cumin, Sea Salt & Ice Water', quantity: 5, unit: 'g'),
        ],
        instructions: [
          'Add tahini and fresh lemon juice into a food processor and blend for 1 minute until whipped and creamy.',
          'Add garlic clove, cumin, and sea salt; pulse to combine.',
          'Rinse chickpeas in warm water and add to the processor; blend while drizzling olive oil and ice water until ultra-smooth.',
          'Transfer to a shallow bowl, create a swirl with a spoon, drizzle extra virgin olive oil, sprinkle sumac/paprika, and serve with toasted pita pockets.',
        ],
        nutrientsPerServing: const MacroNutrients(
          calories: 190,
          proteinGrams: 6.5,
          carbsGrams: 16.0,
          fatGrams: 11.5,
          fiberGrams: 4.8,
          sodiumMg: 240,
          potassiumMg: 210,
        ),
        dietaryTags: ['Vegetarian', 'Vegan', 'Heart-Healthy', 'High-Fiber', 'Low-GI'],
        isFavorite: true,
        isFrequentlyPrepared: true,
        description: 'Velvety smooth Mediterranean chickpea dip with nutty roasted sesame tahini, garlic, and cold-pressed olive oil.',
      ),
      Recipe(
        id: 'rec_palak_paneer_home',
        name: 'Homestyle Palak Paneer with Phulkas',
        cuisine: 'North Indian',
        prepTimeMinutes: 15,
        cookTimeMinutes: 20,
        defaultServings: 3,
        ingredients: [
          RecipeIngredient(name: 'Fresh Palak Spinach', quantity: 300, unit: 'g'),
          RecipeIngredient(name: 'Organic Paneer Cubes', quantity: 200, unit: 'g'),
          RecipeIngredient(name: 'Onion, Ginger & Garlic', quantity: 80, unit: 'g'),
          RecipeIngredient(name: 'Ghee / Olive Oil', quantity: 15, unit: 'ml'),
          RecipeIngredient(name: 'Garam Masala & Kasoori Methi', quantity: 5, unit: 'g'),
        ],
        instructions: [
          'Blanch washed spinach in boiling water for 2 minutes and immediately shock in ice water to retain vibrant green color.',
          'Puree blanched spinach with ginger and green chilies into a smooth gravy.',
          'Heat ghee in a pan, sauté onions, garlic, and aromatic spices until golden.',
          'Pour in spinach puree, simmer for 5 minutes, fold in fresh paneer cubes and kasoori methi, and serve hot with puffed rotis.',
        ],
        nutrientsPerServing: const MacroNutrients(
          calories: 275,
          proteinGrams: 15.2,
          carbsGrams: 9.0,
          fatGrams: 19.5,
          fiberGrams: 4.5,
          sodiumMg: 410,
          potassiumMg: 480,
        ),
        dietaryTags: ['Vegetarian', 'High-Protein', 'Low-Carb', 'Keto-Friendly', 'Iron-Rich'],
        isFavorite: true,
        isFrequentlyPrepared: true,
        description: 'Rich and vibrant cottage cheese cubes in spiced spinach puree, loaded with protein and bioavailable iron.',
      ),
    ];
  }
}
