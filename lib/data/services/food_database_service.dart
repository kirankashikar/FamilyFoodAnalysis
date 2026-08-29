import '../models/food_item.dart';

class FoodDatabaseService {
  static final List<FoodItem> _predefinedDatabase = [
    // South Indian
    const FoodItem(
      id: 'food_dosa_plain',
      name: 'Plain Dosa',
      cuisineCategory: 'South Indian',
      defaultServingUnit: 'piece (approx 80g)',
      defaultServingSize: 1.0,
      nutrientsPerServing: MacroNutrients(
        calories: 133,
        proteinGrams: 3.1,
        carbsGrams: 23.5,
        fatGrams: 3.0,
        fiberGrams: 1.5,
        sodiumMg: 160,
        potassiumMg: 75,
        ironMg: 0.8,
        calciumMg: 12,
      ),
      tags: ['Vegetarian', 'Vegan', 'Fermented', 'Gut-Friendly'],
      description: 'Crispy fermented rice and black gram (urad dal) crepe.',
      commonIngredients: ['Parboiled Rice', 'Urad Dal', 'Fenugreek Seeds', 'Sesame Oil'],
    ),
    const FoodItem(
      id: 'food_dosa_masala',
      name: 'Masala Dosa',
      cuisineCategory: 'South Indian',
      defaultServingUnit: 'piece with potato masala',
      defaultServingSize: 1.0,
      nutrientsPerServing: MacroNutrients(
        calories: 250,
        proteinGrams: 5.5,
        carbsGrams: 39.0,
        fatGrams: 8.2,
        fiberGrams: 3.4,
        sodiumMg: 380,
        potassiumMg: 280,
        ironMg: 1.8,
        calciumMg: 25,
      ),
      tags: ['Vegetarian', 'Vegan', 'Fermented'],
      description: 'Golden fermented crepe filled with spiced tempered potato and onion.',
      commonIngredients: ['Parboiled Rice', 'Urad Dal', 'Potatoes', 'Onions', 'Mustard Seeds', 'Turmeric'],
    ),
    const FoodItem(
      id: 'food_idli',
      name: 'Steamed Idli',
      cuisineCategory: 'South Indian',
      defaultServingUnit: '2 pieces (100g)',
      defaultServingSize: 2.0,
      nutrientsPerServing: MacroNutrients(
        calories: 140,
        proteinGrams: 4.2,
        carbsGrams: 28.0,
        fatGrams: 0.4,
        fiberGrams: 2.0,
        sodiumMg: 130,
        potassiumMg: 90,
        ironMg: 0.9,
        calciumMg: 15,
      ),
      tags: ['Vegetarian', 'Vegan', 'Fermented', 'Oil-Free', 'Low-Fat'],
      description: 'Steamed fluffy savory cake from fermented rice & lentil batter.',
      commonIngredients: ['Rice', 'Urad Dal', 'Fenugreek'],
    ),
    const FoodItem(
      id: 'food_sambar',
      name: 'Vegetable Sambar',
      cuisineCategory: 'South Indian',
      defaultServingUnit: '1 bowl (150ml)',
      defaultServingSize: 1.0,
      nutrientsPerServing: MacroNutrients(
        calories: 110,
        proteinGrams: 5.8,
        carbsGrams: 16.5,
        fatGrams: 2.5,
        fiberGrams: 4.2,
        sodiumMg: 420,
        potassiumMg: 310,
        ironMg: 1.5,
        calciumMg: 40,
      ),
      tags: ['Vegetarian', 'Vegan', 'High-Fiber', 'Lentil-Based'],
      description: 'Tangy lentil and vegetable stew tempered with mustard, curry leaves, and tamarind.',
      commonIngredients: ['Toor Dal', 'Drumsticks', 'Carrots', 'Tamarind', 'Sambar Powder', 'Curry Leaves'],
    ),
    const FoodItem(
      id: 'food_curd_rice',
      name: 'Curd Rice (Thayir Sadam)',
      cuisineCategory: 'South Indian',
      defaultServingUnit: '1 bowl (200g)',
      defaultServingSize: 1.0,
      nutrientsPerServing: MacroNutrients(
        calories: 220,
        proteinGrams: 6.2,
        carbsGrams: 32.0,
        fatGrams: 7.5,
        fiberGrams: 1.2,
        sodiumMg: 290,
        potassiumMg: 210,
        ironMg: 0.6,
        calciumMg: 160,
      ),
      tags: ['Vegetarian', 'Probiotic', 'Calcium-Rich', 'Cooling'],
      description: 'Comforting soft cooked rice blended with fresh yogurt and tempered with mustard and ginger.',
      commonIngredients: ['Rice', 'Yogurt', 'Mustard Seeds', 'Green Chili', 'Ginger', 'Curry Leaves'],
    ),

    // Mediterranean & Middle Eastern
    const FoodItem(
      id: 'food_hummus',
      name: 'Classic Hummus',
      cuisineCategory: 'Mediterranean',
      defaultServingUnit: '1/4 cup (60g)',
      defaultServingSize: 1.0,
      nutrientsPerServing: MacroNutrients(
        calories: 166,
        proteinGrams: 4.8,
        carbsGrams: 14.3,
        fatGrams: 9.6,
        fiberGrams: 4.0,
        sodiumMg: 235,
        potassiumMg: 175,
        ironMg: 1.6,
        calciumMg: 38,
      ),
      tags: ['Vegetarian', 'Vegan', 'High-Fiber', 'Heart-Healthy', 'Low-GI'],
      description: 'Creamy chickpea dip blended with tahini, extra virgin olive oil, garlic, and fresh lemon.',
      commonIngredients: ['Chickpeas', 'Tahini', 'Extra Virgin Olive Oil', 'Garlic', 'Lemon Juice', 'Cumin'],
    ),
    const FoodItem(
      id: 'food_pita_whole_wheat',
      name: 'Whole Wheat Pita',
      cuisineCategory: 'Mediterranean',
      defaultServingUnit: '1 pocket (60g)',
      defaultServingSize: 1.0,
      nutrientsPerServing: MacroNutrients(
        calories: 150,
        proteinGrams: 5.5,
        carbsGrams: 31.0,
        fatGrams: 1.0,
        fiberGrams: 4.5,
        sodiumMg: 280,
        potassiumMg: 120,
        ironMg: 1.4,
        calciumMg: 20,
      ),
      tags: ['Vegetarian', 'Vegan', 'Whole-Grain', 'High-Fiber'],
      description: 'Oven-baked traditional whole grain flatbread with a hollow pocket.',
      commonIngredients: ['Whole Wheat Flour', 'Yeast', 'Water', 'Salt'],
    ),
    const FoodItem(
      id: 'food_greek_salad',
      name: 'Greek Salad with Feta & Olives',
      cuisineCategory: 'Mediterranean',
      defaultServingUnit: '1 plate (200g)',
      defaultServingSize: 1.0,
      nutrientsPerServing: MacroNutrients(
        calories: 190,
        proteinGrams: 6.0,
        carbsGrams: 9.5,
        fatGrams: 14.5,
        fiberGrams: 3.2,
        sodiumMg: 480,
        potassiumMg: 340,
        ironMg: 1.1,
        calciumMg: 140,
      ),
      tags: ['Vegetarian', 'Low-Carb', 'Keto-Friendly', 'Antioxidant-Rich'],
      description: 'Crisp cucumbers, ripe tomatoes, red onions, Kalamata olives, and Greek feta cheese with oregano & olive oil.',
      commonIngredients: ['Cucumber', 'Tomatoes', 'Feta Cheese', 'Kalamata Olives', 'Extra Virgin Olive Oil', 'Oregano'],
    ),
    const FoodItem(
      id: 'food_falafel',
      name: 'Baked/Air-Fried Falafel',
      cuisineCategory: 'Middle Eastern',
      defaultServingUnit: '3 pieces (75g)',
      defaultServingSize: 3.0,
      nutrientsPerServing: MacroNutrients(
        calories: 175,
        proteinGrams: 7.2,
        carbsGrams: 21.0,
        fatGrams: 6.8,
        fiberGrams: 5.1,
        sodiumMg: 260,
        potassiumMg: 220,
        ironMg: 2.1,
        calciumMg: 45,
      ),
      tags: ['Vegetarian', 'Vegan', 'High-Protein', 'High-Fiber'],
      description: 'Herb-infused ground chickpea and parsley patties seasoned with coriander and cumin.',
      commonIngredients: ['Chickpeas', 'Parsley', 'Coriander', 'Garlic', 'Cumin', 'Baking Powder'],
    ),

    // North Indian
    const FoodItem(
      id: 'food_dal_tadka',
      name: 'Yellow Dal Tadka',
      cuisineCategory: 'North Indian',
      defaultServingUnit: '1 bowl (180g)',
      defaultServingSize: 1.0,
      nutrientsPerServing: MacroNutrients(
        calories: 165,
        proteinGrams: 9.2,
        carbsGrams: 22.5,
        fatGrams: 4.8,
        fiberGrams: 5.5,
        sodiumMg: 340,
        potassiumMg: 380,
        ironMg: 2.4,
        calciumMg: 35,
      ),
      tags: ['Vegetarian', 'Vegan', 'High-Protein', 'High-Fiber'],
      description: 'Hearty yellow pigeon peas and split moong lentils tempered with ghee, cumin, garlic, and dried chili.',
      commonIngredients: ['Toor Dal', 'Moong Dal', 'Tomatoes', 'Ghee', 'Cumin', 'Garlic', 'Turmeric'],
    ),
    const FoodItem(
      id: 'food_roti_chapati',
      name: 'Whole Wheat Roti / Phulka',
      cuisineCategory: 'North Indian',
      defaultServingUnit: '1 piece (35g)',
      defaultServingSize: 1.0,
      nutrientsPerServing: MacroNutrients(
        calories: 85,
        proteinGrams: 2.8,
        carbsGrams: 16.5,
        fatGrams: 0.8,
        fiberGrams: 2.3,
        sodiumMg: 60,
        potassiumMg: 95,
        ironMg: 0.9,
        calciumMg: 10,
      ),
      tags: ['Vegetarian', 'Vegan', 'Low-Fat', 'Whole-Grain'],
      description: 'Unleavened whole wheat flatbread cooked puffed on an open flame.',
      commonIngredients: ['Whole Wheat Atta', 'Water'],
    ),
    const FoodItem(
      id: 'food_palak_paneer',
      name: 'Palak Paneer',
      cuisineCategory: 'North Indian',
      defaultServingUnit: '1 bowl (180g)',
      defaultServingSize: 1.0,
      nutrientsPerServing: MacroNutrients(
        calories: 260,
        proteinGrams: 14.0,
        carbsGrams: 8.5,
        fatGrams: 18.5,
        fiberGrams: 4.1,
        sodiumMg: 410,
        potassiumMg: 450,
        ironMg: 3.5,
        calciumMg: 280,
      ),
      tags: ['Vegetarian', 'High-Protein', 'Low-Carb', 'Keto-Friendly', 'Iron-Rich'],
      description: 'Cottage cheese cubes simmered in a creamy, spiced fresh spinach gravy.',
      commonIngredients: ['Spinach', 'Paneer', 'Onions', 'Garlic', 'Garam Masala', 'Fresh Cream'],
    ),
    const FoodItem(
      id: 'food_rajma',
      name: 'Rajma Masala (Kidney Bean Curry)',
      cuisineCategory: 'North Indian',
      defaultServingUnit: '1 bowl (200g)',
      defaultServingSize: 1.0,
      nutrientsPerServing: MacroNutrients(
        calories: 210,
        proteinGrams: 11.5,
        carbsGrams: 32.0,
        fatGrams: 4.2,
        fiberGrams: 8.5,
        sodiumMg: 390,
        potassiumMg: 520,
        ironMg: 3.2,
        calciumMg: 65,
      ),
      tags: ['Vegetarian', 'Vegan', 'High-Protein', 'High-Fiber', 'Low-GI'],
      description: 'Slow-cooked red kidney beans in a spiced tomato, ginger, and onion gravy.',
      commonIngredients: ['Red Kidney Beans', 'Tomatoes', 'Onions', 'Ginger-Garlic', 'Garam Masala'],
    ),

    // East Asian & Global Balanced
    const FoodItem(
      id: 'food_tofu_stirfry',
      name: 'Tofu & Vegetable Stir-Fry',
      cuisineCategory: 'East Asian',
      defaultServingUnit: '1 plate (220g)',
      defaultServingSize: 1.0,
      nutrientsPerServing: MacroNutrients(
        calories: 195,
        proteinGrams: 13.5,
        carbsGrams: 12.0,
        fatGrams: 11.0,
        fiberGrams: 3.8,
        sodiumMg: 460,
        potassiumMg: 410,
        ironMg: 2.8,
        calciumMg: 190,
      ),
      tags: ['Vegetarian', 'Vegan', 'High-Protein', 'Low-Carb'],
      description: 'Seared firm tofu with broccoli, bell peppers, and snap peas in a light sesame-soy glaze.',
      commonIngredients: ['Firm Tofu', 'Broccoli', 'Bell Peppers', 'Sesame Oil', 'Low-Sodium Soy Sauce', 'Ginger'],
    ),
    const FoodItem(
      id: 'food_overnight_oats',
      name: 'Overnight Chia Oats with Berries',
      cuisineCategory: 'Western Balanced',
      defaultServingUnit: '1 jar (200g)',
      defaultServingSize: 1.0,
      nutrientsPerServing: MacroNutrients(
        calories: 280,
        proteinGrams: 11.0,
        carbsGrams: 44.0,
        fatGrams: 6.8,
        fiberGrams: 8.2,
        sodiumMg: 90,
        potassiumMg: 310,
        ironMg: 2.2,
        calciumMg: 180,
      ),
      tags: ['Vegetarian', 'High-Fiber', 'Heart-Healthy', 'Low-Sodium'],
      description: 'Rolled oats soaked in almond milk with chia seeds, blueberries, and cinnamon.',
      commonIngredients: ['Rolled Oats', 'Almond Milk', 'Chia Seeds', 'Blueberries', 'Cinnamon'],
    ),
    const FoodItem(
      id: 'food_avocado_toast',
      name: 'Avocado & Egg Sourdough Toast',
      cuisineCategory: 'Western Balanced',
      defaultServingUnit: '1 slice loaded',
      defaultServingSize: 1.0,
      nutrientsPerServing: MacroNutrients(
        calories: 310,
        proteinGrams: 12.5,
        carbsGrams: 26.0,
        fatGrams: 17.5,
        fiberGrams: 5.5,
        sodiumMg: 340,
        potassiumMg: 420,
        ironMg: 2.0,
        calciumMg: 45,
      ),
      tags: ['Vegetarian', 'High-Protein', 'Heart-Healthy'],
      description: 'Toasted sourdough topped with mashed ripe avocado, a poached egg, and chili flakes.',
      commonIngredients: ['Sourdough Bread', 'Avocado', 'Egg', 'Lemon Juice', 'Chili Flakes'],
    ),
    const FoodItem(
      id: 'food_black_bean_bowl',
      name: 'Mexican Black Bean & Quinoa Bowl',
      cuisineCategory: 'Latin American',
      defaultServingUnit: '1 bowl (250g)',
      defaultServingSize: 1.0,
      nutrientsPerServing: MacroNutrients(
        calories: 340,
        proteinGrams: 13.8,
        carbsGrams: 52.0,
        fatGrams: 8.5,
        fiberGrams: 11.2,
        sodiumMg: 380,
        potassiumMg: 560,
        ironMg: 3.6,
        calciumMg: 55,
      ),
      tags: ['Vegetarian', 'Vegan', 'High-Protein', 'High-Fiber', 'Gluten-Free'],
      description: 'Fluffy quinoa layered with seasoned black beans, sweet corn, salsa fresca, and lime.',
      commonIngredients: ['Quinoa', 'Black Beans', 'Corn', 'Tomatoes', 'Cilantro', 'Lime Juice'],
    ),
  ];

  List<FoodItem> getAllFoodItems() => List.unmodifiable(_predefinedDatabase);

  FoodItem? getById(String id) {
    try {
      return _predefinedDatabase.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  List<FoodItem> search({String query = '', String? cuisine, String? dietaryTag}) {
    return _predefinedDatabase.where((item) {
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query.toLowerCase()) ||
          item.description?.toLowerCase().contains(query.toLowerCase()) == true ||
          item.commonIngredients.any((i) => i.toLowerCase().contains(query.toLowerCase()));

      final matchesCuisine = cuisine == null || cuisine.isEmpty || cuisine == 'All' ||
          item.cuisineCategory.toLowerCase().contains(cuisine.toLowerCase());

      final matchesTag = dietaryTag == null || dietaryTag.isEmpty || dietaryTag == 'All' ||
          item.tags.any((t) => t.toLowerCase() == dietaryTag.toLowerCase());

      return matchesQuery && matchesCuisine && matchesTag;
    }).toList();
  }

  List<String> getAllCuisines() {
    final cuisines = _predefinedDatabase.map((e) => e.cuisineCategory).toSet().toList();
    cuisines.sort();
    return ['All', ...cuisines];
  }
}
