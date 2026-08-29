import 'dart:convert';
import 'food_item.dart';

class RecipeIngredient {
  final String name;
  final double quantity;
  final String unit; // g, ml, tbsp, cup, piece
  final String? matchedInventoryItemId;

  RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.matchedInventoryItemId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'matchedInventoryItemId': matchedInventoryItemId,
    };
  }

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      name: map['name'] ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: map['unit'] ?? 'g',
      matchedInventoryItemId: map['matchedInventoryItemId'],
    );
  }
}

class Recipe {
  final String id;
  final String name;
  final String cuisine; // South Indian, Mediterranean, Middle Eastern, etc.
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int defaultServings;
  final List<RecipeIngredient> ingredients;
  final List<String> instructions;
  final MacroNutrients nutrientsPerServing;
  final List<String> dietaryTags; // Vegetarian, Vegan, High-Fiber, Low-GI
  final bool isFavorite;
  final bool isFrequentlyPrepared;
  final String? imageUrl;
  final String description;

  Recipe({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.defaultServings,
    required this.ingredients,
    required this.instructions,
    required this.nutrientsPerServing,
    required this.dietaryTags,
    this.isFavorite = false,
    this.isFrequentlyPrepared = false,
    this.imageUrl,
    required this.description,
  });

  Recipe copyWith({
    String? id,
    String? name,
    String? cuisine,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? defaultServings,
    List<RecipeIngredient>? ingredients,
    List<String>? instructions,
    MacroNutrients? nutrientsPerServing,
    List<String>? dietaryTags,
    bool? isFavorite,
    bool? isFrequentlyPrepared,
    String? imageUrl,
    String? description,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      cuisine: cuisine ?? this.cuisine,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      defaultServings: defaultServings ?? this.defaultServings,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      nutrientsPerServing: nutrientsPerServing ?? this.nutrientsPerServing,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      isFavorite: isFavorite ?? this.isFavorite,
      isFrequentlyPrepared: isFrequentlyPrepared ?? this.isFrequentlyPrepared,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cuisine': cuisine,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'defaultServings': defaultServings,
      'ingredients': ingredients.map((x) => x.toMap()).toList(),
      'instructions': instructions,
      'nutrientsPerServing': nutrientsPerServing.toMap(),
      'dietaryTags': dietaryTags,
      'isFavorite': isFavorite,
      'isFrequentlyPrepared': isFrequentlyPrepared,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      cuisine: map['cuisine'] ?? 'General',
      prepTimeMinutes: (map['prepTimeMinutes'] as num?)?.toInt() ?? 15,
      cookTimeMinutes: (map['cookTimeMinutes'] as num?)?.toInt() ?? 20,
      defaultServings: (map['defaultServings'] as num?)?.toInt() ?? 2,
      ingredients: List<RecipeIngredient>.from(
        (map['ingredients'] as List? ?? []).map((x) => RecipeIngredient.fromMap(x)),
      ),
      instructions: List<String>.from(map['instructions'] ?? []),
      nutrientsPerServing: map['nutrientsPerServing'] != null
          ? MacroNutrients.fromMap(map['nutrientsPerServing'])
          : const MacroNutrients(calories: 0, proteinGrams: 0, carbsGrams: 0, fatGrams: 0),
      dietaryTags: List<String>.from(map['dietaryTags'] ?? []),
      isFavorite: map['isFavorite'] ?? false,
      isFrequentlyPrepared: map['isFrequentlyPrepared'] ?? false,
      imageUrl: map['imageUrl'],
      description: map['description'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());
  factory Recipe.fromJson(String source) => Recipe.fromMap(json.decode(source));
}
