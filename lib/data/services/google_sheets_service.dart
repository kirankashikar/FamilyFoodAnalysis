import '../models/google_sheets_config.dart';
import '../models/grocery_item.dart';
import '../models/food_item.dart';
import '../models/recipe.dart';

class SyncResult {
  final bool isSuccess;
  final String message;
  final int inventoryCount;
  final int intakeCount;
  final DateTime timestamp;

  SyncResult({
    required this.isSuccess,
    required this.message,
    required this.inventoryCount,
    required this.intakeCount,
    required this.timestamp,
  });
}

class GoogleSheetsService {
  GoogleSheetsConfig _config = GoogleSheetsConfig(
    spreadsheetId: '1A2B3C4D_FamilyFoodDatabase_Sample',
  );

  GoogleSheetsConfig get config => _config;

  void updateConfig(GoogleSheetsConfig newConfig) {
    _config = newConfig;
  }

  /// Sync local inventory and food intake logs to Google Sheets
  Future<SyncResult> syncToGoogleSheets({
    required List<GroceryItem> inventory,
    required List<MealEntry> intakeLogs,
    required List<Recipe> recipes,
    String? customSpreadsheetId,
  }) async {
    final sheetId = customSpreadsheetId ?? _config.spreadsheetId;
    
    // Simulate network API call to Google Sheets REST API / Apps Script
    await Future.delayed(const Duration(milliseconds: 600));

    if (sheetId.trim().isEmpty) {
      return SyncResult(
        isSuccess: false,
        message: 'Spreadsheet ID is missing. Please configure your Google Sheet link.',
        inventoryCount: 0,
        intakeCount: 0,
        timestamp: DateTime.now(),
      );
    }

    _config = _config.copyWith(
      spreadsheetId: sheetId,
      lastSyncTime: DateTime.now(),
      syncStatus: 'Synced & Active',
    );

    return SyncResult(
      isSuccess: true,
      message: 'Successfully synchronized ${inventory.length} grocery items & ${intakeLogs.length} intake logs to Google Sheets.',
      inventoryCount: inventory.length,
      intakeCount: intakeLogs.length,
      timestamp: DateTime.now(),
    );
  }

  /// Converts Grocery Items list to a Google Sheets compatible CSV string
  String generateInventoryCsv(List<GroceryItem> items) {
    final buffer = StringBuffer();
    buffer.writeln('Item ID,Item Name,Category,Quantity,Unit,Remaining,Estimated Cost,Purchase Date,Expiry Date,Store,Status');
    
    for (final item in items) {
      final purchaseStr = _formatDate(item.purchaseDate);
      final expiryStr = item.expiryDate != null ? _formatDate(item.expiryDate!) : 'N/A';
      final status = item.isExpired ? 'EXPIRED' : (item.isExpiringSoon ? 'EXPIRING SOON' : 'FRESH');
      
      buffer.writeln(
        '"${item.id}","${item.name}","${item.category.displayName}",${item.quantity},"${item.unit}",${item.remainingQuantity},${item.estimatedCost},"$purchaseStr","$expiryStr","${item.storeName ?? ''}","$status"',
      );
    }
    return buffer.toString();
  }

  /// Converts Meal Intake Logs to a Google Sheets compatible CSV string
  String generateIntakeCsv(List<MealEntry> logs) {
    final buffer = StringBuffer();
    buffer.writeln('Entry ID,Member ID,Food Item,Meal Type,Servings,Serving Unit,Calories (kcal),Protein (g),Carbs (g),Fat (g),Fiber (g),Sodium (mg),Timestamp');
    
    for (final entry in logs) {
      final timeStr = _formatDateTime(entry.timestamp);
      final nut = entry.calculatedNutrients;
      buffer.writeln(
        '"${entry.id}","${entry.memberId}","${entry.foodName}","${entry.mealType.displayName}",${entry.servings},"${entry.servingUnit}",${nut.calories.toStringAsFixed(1)},${nut.proteinGrams.toStringAsFixed(1)},${nut.carbsGrams.toStringAsFixed(1)},${nut.fatGrams.toStringAsFixed(1)},${nut.fiberGrams.toStringAsFixed(1)},${nut.sodiumMg.toStringAsFixed(0)},"$timeStr"',
      );
    }
    return buffer.toString();
  }

  /// Parses CSV string imported from Google Sheets into GroceryItem list
  List<GroceryItem> parseInventoryCsv(String csvContent) {
    final lines = csvContent.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.length <= 1) return [];

    final List<GroceryItem> result = [];
    for (int i = 1; i < lines.length; i++) {
      final row = _parseCsvLine(lines[i]);
      if (row.length < 7) continue;

      try {
        final id = row[0];
        final name = row[1];
        final categoryStr = row[2];
        final quantity = double.tryParse(row[3]) ?? 1.0;
        final unit = row[4];
        final remaining = row.length > 5 ? (double.tryParse(row[5]) ?? quantity) : quantity;
        final cost = row.length > 6 ? (double.tryParse(row[6]) ?? 0.0) : 0.0;
        final purchase = row.length > 7 ? (DateTime.tryParse(row[7]) ?? DateTime.now()) : DateTime.now();
        final expiry = row.length > 8 && row[8] != 'N/A' ? DateTime.tryParse(row[8]) : null;
        final store = row.length > 9 ? row[9] : null;

        final category = GroceryCategory.values.firstWhere(
          (c) => c.displayName.toLowerCase() == categoryStr.toLowerCase() || c.name.toLowerCase() == categoryStr.toLowerCase(),
          orElse: () => GroceryCategory.other,
        );

        result.add(GroceryItem(
          id: id.isNotEmpty ? id : 'item_${DateTime.now().microsecondsSinceEpoch}',
          name: name,
          category: category,
          quantity: quantity,
          unit: unit,
          estimatedCost: cost,
          purchaseDate: purchase,
          expiryDate: expiry,
          remainingQuantity: remaining,
          storeName: store,
          isSyncedToSheets: true,
        ));
      } catch (_) {}
    }
    return result;
  }

  static String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static String _formatDateTime(DateTime d) {
    return '${_formatDate(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  List<String> _parseCsvLine(String line) {
    final List<String> fields = [];
    final sb = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        fields.add(sb.toString().trim());
        sb.clear();
      } else {
        sb.write(char);
      }
    }
    fields.add(sb.toString().trim());
    return fields;
  }
}
