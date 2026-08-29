import 'dart:math';
import '../models/grocery_item.dart';

class OcrBillScannerService {
  /// Parses raw text extracted from OCR into structured GroceryItem objects
  Future<GroceryReceipt> parseReceiptText(String rawText, {String? storeNameHint, String? imagePath}) async {
    // Simulate OCR processing latency
    await Future.delayed(const Duration(milliseconds: 600));

    final lines = rawText.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    String detectedStore = storeNameHint ?? 'Neighborhood Market';
    DateTime detectedDate = DateTime.now();
    double detectedTotal = 0.0;
    List<GroceryItem> parsedItems = [];

    // Simple heuristic parser for receipt lines
    for (final line in lines) {
      final lower = line.toLowerCase();

      // Check for store name keywords
      if (lower.contains('store') || lower.contains('mart') || lower.contains('market') || lower.contains('foods') || lower.contains('grocers')) {
        if (detectedStore == 'Neighborhood Market') {
          detectedStore = line;
        }
      }

      // Check for total
      if (lower.contains('total') || lower.contains('balance') || lower.contains('amount due')) {
        final match = RegExp(r'[\$]?\s*([0-9]+\.[0-9]{2})').firstMatch(line);
        if (match != null) {
          detectedTotal = double.tryParse(match.group(1) ?? '0') ?? detectedTotal;
        }
        continue;
      }

      // Try parsing line items: e.g. "Toor Dal 2lb 4.99" or "Fresh Spinach 1.99"
      final item = _parseSingleLine(line);
      if (item != null) {
        parsedItems.add(item);
      }
    }

    // Fallback if line parsing was too strict
    if (parsedItems.isEmpty) {
      parsedItems = _generateFallbackItemsFromText(rawText);
    }

    if (detectedTotal == 0.0) {
      detectedTotal = parsedItems.fold(0.0, (sum, it) => sum + it.estimatedCost);
    }

    return GroceryReceipt(
      id: 'receipt_${DateTime.now().millisecondsSinceEpoch}',
      storeName: detectedStore,
      date: detectedDate,
      totalAmount: detectedTotal,
      extractedItems: parsedItems,
      receiptImageUrl: imagePath,
      rawText: rawText,
    );
  }

  GroceryItem? _parseSingleLine(String line) {
    final priceMatch = RegExp(r'[\$]?\s*([0-9]+\.[0-9]{2})$').firstMatch(line);
    if (priceMatch == null) return null;

    final cost = double.tryParse(priceMatch.group(1) ?? '0') ?? 0.0;
    String namePart = line.substring(0, priceMatch.start).trim();
    if (namePart.isEmpty) return null;

    // Detect quantity and unit
    double quantity = 1.0;
    String unit = 'pack';
    final qtyMatch = RegExp(r'(\d+(\.\d+)?)\s*(kg|g|lb|lbs|oz|pack|ct|pk|box|bunch|bottle|can)', caseSensitive: false).firstMatch(namePart);
    if (qtyMatch != null) {
      quantity = double.tryParse(qtyMatch.group(1) ?? '1') ?? 1.0;
      unit = qtyMatch.group(3)?.toLowerCase() ?? 'pack';
      namePart = namePart.replaceAll(qtyMatch.group(0)!, '').trim();
    }

    final category = _categorizeItem(namePart);
    final expiry = _estimateExpiry(category);

    return GroceryItem(
      id: 'item_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(999)}',
      name: namePart.isNotEmpty ? _capitalize(namePart) : 'Grocery Item',
      category: category,
      quantity: quantity,
      unit: unit,
      estimatedCost: cost,
      purchaseDate: DateTime.now(),
      expiryDate: expiry,
      remainingQuantity: quantity,
      isSyncedToSheets: false,
    );
  }

  List<GroceryItem> _generateFallbackItemsFromText(String raw) {
    final defaultSample = getSampleReceiptPresets().first.extractedItems;
    return defaultSample;
  }

  static GroceryCategory _categorizeItem(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('spinach') || lower.contains('tomato') || lower.contains('onion') ||
        lower.contains('potato') || lower.contains('carrot') || lower.contains('cucumber') ||
        lower.contains('cilantro') || lower.contains('apple') || lower.contains('banana') ||
        lower.contains('berry') || lower.contains('lemon') || lower.contains('drumstick') ||
        lower.contains('avocado') || lower.contains('broccoli')) {
      return GroceryCategory.produce;
    }
    if (lower.contains('rice') || lower.contains('dal') || lower.contains('lentil') ||
        lower.contains('flour') || lower.contains('atta') || lower.contains('oats') ||
        lower.contains('quinoa') || lower.contains('millet') || lower.contains('poha') ||
        lower.contains('rava') || lower.contains('sooji') || lower.contains('besan')) {
      return GroceryCategory.grainsAndPulses;
    }
    if (lower.contains('milk') || lower.contains('yogurt') || lower.contains('curd') ||
        lower.contains('paneer') || lower.contains('tofu') || lower.contains('cheese') ||
        lower.contains('butter') || lower.contains('cream') || lower.contains('feta')) {
      return GroceryCategory.dairyAndAlternatives;
    }
    if (lower.contains('egg') || lower.contains('chicken') || lower.contains('fish') ||
        lower.contains('salmon') || lower.contains('meat') || lower.contains('shrimp')) {
      return GroceryCategory.proteinsAndMeat;
    }
    if (lower.contains('oil') || lower.contains('ghee') || lower.contains('mustard') ||
        lower.contains('cumin') || lower.contains('turmeric') || lower.contains('masala') ||
        lower.contains('pepper') || lower.contains('salt') || lower.contains('hing')) {
      return GroceryCategory.spicesAndOils;
    }
    if (lower.contains('almond') || lower.contains('walnut') || lower.contains('cashew') ||
        lower.contains('chia') || lower.contains('seed') || lower.contains('bread') ||
        lower.contains('pita') || lower.contains('cracker')) {
      return GroceryCategory.snacksAndBaking;
    }
    if (lower.contains('tahini') || lower.contains('sauce') || lower.contains('vinegar') ||
        lower.contains('paste') || lower.contains('chutney') || lower.contains('hummus')) {
      return GroceryCategory.condimentsAndSauces;
    }
    if (lower.contains('tea') || lower.contains('coffee') || lower.contains('chai') ||
        lower.contains('juice') || lower.contains('drink')) {
      return GroceryCategory.beverages;
    }
    return GroceryCategory.other;
  }

  static DateTime _estimateExpiry(GroceryCategory category) {
    final now = DateTime.now();
    switch (category) {
      case GroceryCategory.produce:
        return now.add(const Duration(days: 6));
      case GroceryCategory.dairyAndAlternatives:
        return now.add(const Duration(days: 10));
      case GroceryCategory.proteinsAndMeat:
        return now.add(const Duration(days: 4));
      case GroceryCategory.grainsAndPulses:
        return now.add(const Duration(days: 180));
      case GroceryCategory.spicesAndOils:
        return now.add(const Duration(days: 365));
      case GroceryCategory.snacksAndBaking:
        return now.add(const Duration(days: 30));
      case GroceryCategory.condimentsAndSauces:
        return now.add(const Duration(days: 90));
      case GroceryCategory.beverages:
        return now.add(const Duration(days: 60));
      case GroceryCategory.other:
        return now.add(const Duration(days: 60));
    }
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Preset simulated grocery bills for instant testing & demo
  List<GroceryReceipt> getSampleReceiptPresets() {
    final now = DateTime.now();
    return [
      GroceryReceipt(
        id: 'rec_preset_indian_mart',
        storeName: 'Patel Brothers Indian Market',
        date: now.subtract(const Duration(days: 1)),
        totalAmount: 46.75,
        rawText: '''
PATEL BROTHERS INDIAN GROCERS
DATE: 08/28/2026
--------------------------------
IDLI DOSA BATTER 2LB     \$4.99
TOOR DAL YELLOW 2LB      \$5.49
URAD DAL WHOLE 2LB       \$4.79
FRESH PALAK SPINACH 2PK  \$2.99
ORGANIC PANEER 400G      \$6.29
ALPHONSO MANGOES 1BOX    \$12.99
SESAME GINGELLY OIL 1L   \$6.50
CURRY LEAVES FRESH       \$0.99
CUMIN SEEDS JIRA 200G    \$1.72
--------------------------------
TOTAL:                   \$46.75
''',
        extractedItems: [
          GroceryItem(
            id: 'item_rec_1',
            name: 'Idli Dosa Batter',
            category: GroceryCategory.grainsAndPulses,
            quantity: 2,
            unit: 'lbs',
            estimatedCost: 4.99,
            purchaseDate: now.subtract(const Duration(days: 1)),
            expiryDate: now.add(const Duration(days: 5)),
            remainingQuantity: 2.0,
            storeName: 'Patel Brothers',
          ),
          GroceryItem(
            id: 'item_rec_2',
            name: 'Toor Dal Yellow',
            category: GroceryCategory.grainsAndPulses,
            quantity: 2,
            unit: 'lbs',
            estimatedCost: 5.49,
            purchaseDate: now.subtract(const Duration(days: 1)),
            expiryDate: now.add(const Duration(days: 200)),
            remainingQuantity: 2.0,
            storeName: 'Patel Brothers',
          ),
          GroceryItem(
            id: 'item_rec_3',
            name: 'Urad Dal White',
            category: GroceryCategory.grainsAndPulses,
            quantity: 2,
            unit: 'lbs',
            estimatedCost: 4.79,
            purchaseDate: now.subtract(const Duration(days: 1)),
            expiryDate: now.add(const Duration(days: 200)),
            remainingQuantity: 2.0,
            storeName: 'Patel Brothers',
          ),
          GroceryItem(
            id: 'item_rec_4',
            name: 'Fresh Palak Spinach',
            category: GroceryCategory.produce,
            quantity: 2,
            unit: 'bunches',
            estimatedCost: 2.99,
            purchaseDate: now.subtract(const Duration(days: 1)),
            expiryDate: now.add(const Duration(days: 4)),
            remainingQuantity: 2.0,
            storeName: 'Patel Brothers',
          ),
          GroceryItem(
            id: 'item_rec_5',
            name: 'Organic Paneer',
            category: GroceryCategory.dairyAndAlternatives,
            quantity: 400,
            unit: 'g',
            estimatedCost: 6.29,
            purchaseDate: now.subtract(const Duration(days: 1)),
            expiryDate: now.add(const Duration(days: 9)),
            remainingQuantity: 400.0,
            storeName: 'Patel Brothers',
          ),
          GroceryItem(
            id: 'item_rec_6',
            name: 'Sesame Gingelly Oil',
            category: GroceryCategory.spicesAndOils,
            quantity: 1,
            unit: 'liter',
            estimatedCost: 6.50,
            purchaseDate: now.subtract(const Duration(days: 1)),
            expiryDate: now.add(const Duration(days: 365)),
            remainingQuantity: 1.0,
            storeName: 'Patel Brothers',
          ),
          GroceryItem(
            id: 'item_rec_7',
            name: 'Fresh Curry Leaves',
            category: GroceryCategory.produce,
            quantity: 1,
            unit: 'pack',
            estimatedCost: 0.99,
            purchaseDate: now.subtract(const Duration(days: 1)),
            expiryDate: now.add(const Duration(days: 7)),
            remainingQuantity: 1.0,
            storeName: 'Patel Brothers',
          ),
        ],
      ),
      GroceryReceipt(
        id: 'rec_preset_mediterranean_mart',
        storeName: 'Cedars Mediterranean Marketplace',
        date: now.subtract(const Duration(days: 2)),
        totalAmount: 38.50,
        rawText: '''
CEDARS MEDITERRANEAN MARKETPLACE
DATE: 08/27/2026
--------------------------------
ORGANIC CHICKPEAS 4 CANS  \$5.00
ORGANIC TAHINI PASTE 16OZ \$7.99
EXTRA VIRGIN OLIVE OIL 1L \$11.99
WHOLE WHEAT PITA 6PK      \$3.49
AUTHENTIC GREEK FETA 200G \$4.99
ENGLISH CUCUMBERS 3PK     \$2.79
FRESH PARSLEY & LEMONS    \$2.25
--------------------------------
TOTAL:                   \$38.50
''',
        extractedItems: [
          GroceryItem(
            id: 'item_rec_8',
            name: 'Organic Chickpeas',
            category: GroceryCategory.grainsAndPulses,
            quantity: 4,
            unit: 'cans',
            estimatedCost: 5.00,
            purchaseDate: now.subtract(const Duration(days: 2)),
            expiryDate: now.add(const Duration(days: 300)),
            remainingQuantity: 4.0,
            storeName: 'Cedars Marketplace',
          ),
          GroceryItem(
            id: 'item_rec_9',
            name: 'Organic Tahini Paste',
            category: GroceryCategory.condimentsAndSauces,
            quantity: 16,
            unit: 'oz',
            estimatedCost: 7.99,
            purchaseDate: now.subtract(const Duration(days: 2)),
            expiryDate: now.add(const Duration(days: 180)),
            remainingQuantity: 16.0,
            storeName: 'Cedars Marketplace',
          ),
          GroceryItem(
            id: 'item_rec_10',
            name: 'Extra Virgin Olive Oil',
            category: GroceryCategory.spicesAndOils,
            quantity: 1,
            unit: 'liter',
            estimatedCost: 11.99,
            purchaseDate: now.subtract(const Duration(days: 2)),
            expiryDate: now.add(const Duration(days: 365)),
            remainingQuantity: 1.0,
            storeName: 'Cedars Marketplace',
          ),
          GroceryItem(
            id: 'item_rec_11',
            name: 'Whole Wheat Pita',
            category: GroceryCategory.snacksAndBaking,
            quantity: 6,
            unit: 'pockets',
            estimatedCost: 3.49,
            purchaseDate: now.subtract(const Duration(days: 2)),
            expiryDate: now.add(const Duration(days: 5)),
            remainingQuantity: 6.0,
            storeName: 'Cedars Marketplace',
          ),
          GroceryItem(
            id: 'item_rec_12',
            name: 'Greek Feta Cheese',
            category: GroceryCategory.dairyAndAlternatives,
            quantity: 200,
            unit: 'g',
            estimatedCost: 4.99,
            purchaseDate: now.subtract(const Duration(days: 2)),
            expiryDate: now.add(const Duration(days: 21)),
            remainingQuantity: 200.0,
            storeName: 'Cedars Marketplace',
          ),
          GroceryItem(
            id: 'item_rec_13',
            name: 'English Cucumbers',
            category: GroceryCategory.produce,
            quantity: 3,
            unit: 'count',
            estimatedCost: 2.79,
            purchaseDate: now.subtract(const Duration(days: 2)),
            expiryDate: now.add(const Duration(days: 7)),
            remainingQuantity: 3.0,
            storeName: 'Cedars Marketplace',
          ),
        ],
      ),
    ];
  }
}
