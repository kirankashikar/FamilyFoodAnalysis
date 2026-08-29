import 'dart:convert';

enum GroceryCategory {
  produce, // Vegetables & Fruits
  grainsAndPulses, // Rice, Dal, Lentils, Flour, Oats, Quinoa
  dairyAndAlternatives, // Milk, Yogurt, Paneer, Tofu, Cheese
  proteinsAndMeat, // Eggs, Chicken, Fish, Beans
  spicesAndOils, // Olive oil, Ghee, Mustard, Turmeric, Cumin
  snacksAndBaking, // Nuts, Seeds, Crackers, Bread
  condimentsAndSauces, // Tahini, Soy Sauce, Vinegar
  beverages, // Tea, Coffee, Juices
  other,
}

extension GroceryCategoryExtension on GroceryCategory {
  String get displayName {
    switch (this) {
      case GroceryCategory.produce:
        return 'Produce & Fresh';
      case GroceryCategory.grainsAndPulses:
        return 'Grains, Dals & Pulses';
      case GroceryCategory.dairyAndAlternatives:
        return 'Dairy & Plant Alternatives';
      case GroceryCategory.proteinsAndMeat:
        return 'Proteins & Eggs';
      case GroceryCategory.spicesAndOils:
        return 'Oils, Ghee & Spices';
      case GroceryCategory.snacksAndBaking:
        return 'Nuts, Seeds & Bakery';
      case GroceryCategory.condimentsAndSauces:
        return 'Condiments & Pastes';
      case GroceryCategory.beverages:
        return 'Beverages';
      case GroceryCategory.other:
        return 'Pantry Essentials';
    }
  }

  String get iconEmoji {
    switch (this) {
      case GroceryCategory.produce:
        return '🥦';
      case GroceryCategory.grainsAndPulses:
        return '🌾';
      case GroceryCategory.dairyAndAlternatives:
        return '🥛';
      case GroceryCategory.proteinsAndMeat:
        return '🥚';
      case GroceryCategory.spicesAndOils:
        return '🫒';
      case GroceryCategory.snacksAndBaking:
        return '🥜';
      case GroceryCategory.condimentsAndSauces:
        return '🫙';
      case GroceryCategory.beverages:
        return '🍵';
      case GroceryCategory.other:
        return '📦';
    }
  }
}

class GroceryItem {
  final String id;
  final String name;
  final GroceryCategory category;
  final double quantity;
  final String unit; // kg, g, lbs, count, liters, ml
  final double estimatedCost;
  final DateTime purchaseDate;
  final DateTime? expiryDate;
  final String? brand;
  final String? storeName;
  final double remainingQuantity;
  final bool isSyncedToSheets;

  GroceryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.estimatedCost,
    required this.purchaseDate,
    this.expiryDate,
    this.brand,
    this.storeName,
    required this.remainingQuantity,
    this.isSyncedToSheets = false,
  });

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final diff = expiryDate!.difference(DateTime.now()).inDays;
    return diff <= 3 && diff >= 0;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  bool get isLowStock {
    return remainingQuantity <= (quantity * 0.25);
  }

  GroceryItem copyWith({
    String? id,
    String? name,
    GroceryCategory? category,
    double? quantity,
    String? unit,
    double? estimatedCost,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    String? brand,
    String? storeName,
    double? remainingQuantity,
    bool? isSyncedToSheets,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      brand: brand ?? this.brand,
      storeName: storeName ?? this.storeName,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      isSyncedToSheets: isSyncedToSheets ?? this.isSyncedToSheets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'quantity': quantity,
      'unit': unit,
      'estimatedCost': estimatedCost,
      'purchaseDate': purchaseDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'brand': brand,
      'storeName': storeName,
      'remainingQuantity': remainingQuantity,
      'isSyncedToSheets': isSyncedToSheets,
    };
  }

  factory GroceryItem.fromMap(Map<String, dynamic> map) {
    return GroceryItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: GroceryCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => GroceryCategory.other,
      ),
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: map['unit'] ?? 'units',
      estimatedCost: (map['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      purchaseDate: map['purchaseDate'] != null
          ? DateTime.parse(map['purchaseDate'])
          : DateTime.now(),
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse(map['expiryDate'])
          : null,
      brand: map['brand'],
      storeName: map['storeName'],
      remainingQuantity: (map['remainingQuantity'] as num?)?.toDouble() ?? 1.0,
      isSyncedToSheets: map['isSyncedToSheets'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());
  factory GroceryItem.fromJson(String source) => GroceryItem.fromMap(json.decode(source));
}

class GroceryReceipt {
  final String id;
  final String storeName;
  final DateTime date;
  final double totalAmount;
  final List<GroceryItem> extractedItems;
  final String? receiptImageUrl;
  final String rawText;

  GroceryReceipt({
    required this.id,
    required this.storeName,
    required this.date,
    required this.totalAmount,
    required this.extractedItems,
    this.receiptImageUrl,
    required this.rawText,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storeName': storeName,
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
      'extractedItems': extractedItems.map((x) => x.toMap()).toList(),
      'receiptImageUrl': receiptImageUrl,
      'rawText': rawText,
    };
  }

  factory GroceryReceipt.fromMap(Map<String, dynamic> map) {
    return GroceryReceipt(
      id: map['id'] ?? '',
      storeName: map['storeName'] ?? 'Grocery Store',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      extractedItems: List<GroceryItem>.from(
        (map['extractedItems'] as List? ?? []).map((x) => GroceryItem.fromMap(x)),
      ),
      receiptImageUrl: map['receiptImageUrl'],
      rawText: map['rawText'] ?? '',
    );
  }
}
