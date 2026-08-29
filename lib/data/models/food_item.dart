import 'dart:convert';

enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack & Beverages';
    }
  }

  String get iconEmoji {
    switch (this) {
      case MealType.breakfast:
        return '🥞';
      case MealType.lunch:
        return '🍲';
      case MealType.dinner:
        return '🥗';
      case MealType.snack:
        return '🍎';
    }
  }
}

class MacroNutrients {
  final double calories; // kcal
  final double proteinGrams; // g
  final double carbsGrams; // g
  final double fatGrams; // g
  final double fiberGrams; // g
  final double sodiumMg; // mg
  final double potassiumMg; // mg
  final double ironMg; // mg
  final double calciumMg; // mg

  const MacroNutrients({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.fiberGrams = 0.0,
    this.sodiumMg = 0.0,
    this.potassiumMg = 0.0,
    this.ironMg = 0.0,
    this.calciumMg = 0.0,
  });

  MacroNutrients operator +(MacroNutrients other) {
    return MacroNutrients(
      calories: calories + other.calories,
      proteinGrams: proteinGrams + other.proteinGrams,
      carbsGrams: carbsGrams + other.carbsGrams,
      fatGrams: fatGrams + other.fatGrams,
      fiberGrams: fiberGrams + other.fiberGrams,
      sodiumMg: sodiumMg + other.sodiumMg,
      potassiumMg: potassiumMg + other.potassiumMg,
      ironMg: ironMg + other.ironMg,
      calciumMg: calciumMg + other.calciumMg,
    );
  }

  MacroNutrients scale(double factor) {
    return MacroNutrients(
      calories: calories * factor,
      proteinGrams: proteinGrams * factor,
      carbsGrams: carbsGrams * factor,
      fatGrams: fatGrams * factor,
      fiberGrams: fiberGrams * factor,
      sodiumMg: sodiumMg * factor,
      potassiumMg: potassiumMg * factor,
      ironMg: ironMg * factor,
      calciumMg: calciumMg * factor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'fiberGrams': fiberGrams,
      'sodiumMg': sodiumMg,
      'potassiumMg': potassiumMg,
      'ironMg': ironMg,
      'calciumMg': calciumMg,
    };
  }

  factory MacroNutrients.fromMap(Map<String, dynamic> map) {
    return MacroNutrients(
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      proteinGrams: (map['proteinGrams'] as num?)?.toDouble() ?? 0.0,
      carbsGrams: (map['carbsGrams'] as num?)?.toDouble() ?? 0.0,
      fatGrams: (map['fatGrams'] as num?)?.toDouble() ?? 0.0,
      fiberGrams: (map['fiberGrams'] as num?)?.toDouble() ?? 0.0,
      sodiumMg: (map['sodiumMg'] as num?)?.toDouble() ?? 0.0,
      potassiumMg: (map['potassiumMg'] as num?)?.toDouble() ?? 0.0,
      ironMg: (map['ironMg'] as num?)?.toDouble() ?? 0.0,
      calciumMg: (map['calciumMg'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class FoodItem {
  final String id;
  final String name;
  final String cuisineCategory; // South Indian, North Indian, Mediterranean, East Asian, etc.
  final String defaultServingUnit; // piece, bowl, plate, cup, 100g, tbsp
  final double defaultServingSize;
  final MacroNutrients nutrientsPerServing;
  final List<String> tags; // Vegetarian, Vegan, Gluten-Free, High-Protein, Fermented
  final String? description;
  final List<String> commonIngredients;

  const FoodItem({
    required this.id,
    required this.name,
    required this.cuisineCategory,
    required this.defaultServingUnit,
    required this.defaultServingSize,
    required this.nutrientsPerServing,
    required this.tags,
    this.description,
    this.commonIngredients = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cuisineCategory': cuisineCategory,
      'defaultServingUnit': defaultServingUnit,
      'defaultServingSize': defaultServingSize,
      'nutrientsPerServing': nutrientsPerServing.toMap(),
      'tags': tags,
      'description': description,
      'commonIngredients': commonIngredients,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      cuisineCategory: map['cuisineCategory'] ?? 'General',
      defaultServingUnit: map['defaultServingUnit'] ?? 'serving',
      defaultServingSize: (map['defaultServingSize'] as num?)?.toDouble() ?? 1.0,
      nutrientsPerServing: map['nutrientsPerServing'] != null
          ? MacroNutrients.fromMap(map['nutrientsPerServing'])
          : const MacroNutrients(calories: 0, proteinGrams: 0, carbsGrams: 0, fatGrams: 0),
      tags: List<String>.from(map['tags'] ?? []),
      description: map['description'],
      commonIngredients: List<String>.from(map['commonIngredients'] ?? []),
    );
  }
}

class MealEntry {
  final String id;
  final String memberId;
  final String foodItemId;
  final String foodName;
  final MealType mealType;
  final double servings;
  final String servingUnit;
  final MacroNutrients calculatedNutrients;
  final DateTime timestamp;
  final String? notes;
  final bool isSyncedToSheets;

  MealEntry({
    required this.id,
    required this.memberId,
    required this.foodItemId,
    required this.foodName,
    required this.mealType,
    required this.servings,
    required this.servingUnit,
    required this.calculatedNutrients,
    required this.timestamp,
    this.notes,
    this.isSyncedToSheets = false,
  });

  MealEntry copyWith({
    String? id,
    String? memberId,
    String? foodItemId,
    String? foodName,
    MealType? mealType,
    double? servings,
    String? servingUnit,
    MacroNutrients? calculatedNutrients,
    DateTime? timestamp,
    String? notes,
    bool? isSyncedToSheets,
  }) {
    return MealEntry(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      foodItemId: foodItemId ?? this.foodItemId,
      foodName: foodName ?? this.foodName,
      mealType: mealType ?? this.mealType,
      servings: servings ?? this.servings,
      servingUnit: servingUnit ?? this.servingUnit,
      calculatedNutrients: calculatedNutrients ?? this.calculatedNutrients,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      isSyncedToSheets: isSyncedToSheets ?? this.isSyncedToSheets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'foodItemId': foodItemId,
      'foodName': foodName,
      'mealType': mealType.name,
      'servings': servings,
      'servingUnit': servingUnit,
      'calculatedNutrients': calculatedNutrients.toMap(),
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'isSyncedToSheets': isSyncedToSheets,
    };
  }

  factory MealEntry.fromMap(Map<String, dynamic> map) {
    return MealEntry(
      id: map['id'] ?? '',
      memberId: map['memberId'] ?? 'self',
      foodItemId: map['foodItemId'] ?? '',
      foodName: map['foodName'] ?? '',
      mealType: MealType.values.firstWhere(
        (e) => e.name == map['mealType'],
        orElse: () => MealType.breakfast,
      ),
      servings: (map['servings'] as num?)?.toDouble() ?? 1.0,
      servingUnit: map['servingUnit'] ?? 'serving',
      calculatedNutrients: map['calculatedNutrients'] != null
          ? MacroNutrients.fromMap(map['calculatedNutrients'])
          : const MacroNutrients(calories: 0, proteinGrams: 0, carbsGrams: 0, fatGrams: 0),
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      notes: map['notes'],
      isSyncedToSheets: map['isSyncedToSheets'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());
  factory MealEntry.fromJson(String source) => MealEntry.fromMap(json.decode(source));
}
