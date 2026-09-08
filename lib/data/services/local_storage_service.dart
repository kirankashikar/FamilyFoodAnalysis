import 'package:shared_preferences/shared_preferences.dart';
import '../models/grocery_item.dart';
import '../models/food_item.dart';
import '../models/recipe.dart';
import '../models/user_profile.dart';
import '../models/google_sheets_config.dart';

class LocalStorageService {
  static const String _keyInventory = 'ffa_inventory_items';
  static const String _keyIntakeLogs = 'ffa_intake_logs';
  static const String _keyRecipes = 'ffa_recipes';
  static const String _keyUserProfile = 'ffa_user_profile';
  static const String _keySheetsConfig = 'ffa_sheets_config';
  static const String _keyDarkMode = 'ffa_dark_mode';

  Future<void> saveInventory(List<GroceryItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = items.map((x) => x.toJson()).toList();
      await prefs.setStringList(_keyInventory, listJson);
    } catch (_) {}
  }

  Future<List<GroceryItem>?> loadInventory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyInventory);
      if (list != null) {
        return list.map((x) => GroceryItem.fromJson(x)).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveIntakeLogs(List<MealEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = entries.map((x) => x.toJson()).toList();
      await prefs.setStringList(_keyIntakeLogs, listJson);
    } catch (_) {}
  }

  Future<List<MealEntry>?> loadIntakeLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyIntakeLogs);
      if (list != null) {
        return list.map((x) => MealEntry.fromJson(x)).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveRecipes(List<Recipe> recipes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = recipes.map((x) => x.toJson()).toList();
      await prefs.setStringList(_keyRecipes, listJson);
    } catch (_) {}
  }

  Future<List<Recipe>?> loadRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyRecipes);
      if (list != null) {
        return list.map((x) => Recipe.fromJson(x)).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveUserProfile(UserProfile user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserProfile, user.toJson());
    } catch (_) {}
  }

  Future<UserProfile?> loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keyUserProfile);
      if (str != null) {
        return UserProfile.fromJson(str);
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveSheetsConfig(GoogleSheetsConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySheetsConfig, config.toJson());
    } catch (_) {}
  }

  Future<GoogleSheetsConfig?> loadSheetsConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keySheetsConfig);
      if (str != null) {
        return GoogleSheetsConfig.fromJson(str);
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveDarkMode(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyDarkMode, isDark);
    } catch (_) {}
  }

  Future<bool?> loadDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyDarkMode);
    } catch (_) {}
    return null;
  }
}
