import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_food_analysis/ui/theme/app_theme.dart';
import 'package:family_food_analysis/ui/view_models/main_view_model.dart';
import 'package:family_food_analysis/ui/core/glass_card.dart';
import 'package:family_food_analysis/data/models/recipe.dart';
import 'package:family_food_analysis/data/models/food_item.dart';

class RecipesView extends StatefulWidget {
  const RecipesView({super.key});

  @override
  State<RecipesView> createState() => _RecipesViewState();
}

class _RecipesViewState extends State<RecipesView> {
  String _searchQuery = '';
  String _selectedCuisine = 'All';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final filteredRecipes = vm.recipes.where((r) {
      final matchesQuery = _searchQuery.isEmpty ||
          r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.ingredients.any((i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesCuisine = _selectedCuisine == 'All' || r.cuisine.toLowerCase().contains(_selectedCuisine.toLowerCase());
      return matchesQuery && matchesCuisine;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Prepared Meals & Quick Recipes',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Frequently prepared home dishes, matched against your available pantry inventory with 1-click meal logging.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddRecipeDialog(context, vm),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Recipe'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Search & Cuisine Filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search dishes (Dosa, Hummus, Palak Paneer, Sambar, etc.)...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'South Indian', 'Mediterranean', 'North Indian', 'Middle Eastern', 'East Asian', 'Western Balanced'].map((c) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: _selectedCuisine == c,
                    onSelected: (sel) => setState(() => _selectedCuisine = sel ? c : 'All'),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Recipes Grid / Cards
          if (filteredRecipes.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('No recipes found matching your search.', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 900 ? 2 : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 260,
                  ),
                  itemCount: filteredRecipes.length,
                  itemBuilder: (ctx, i) {
                    final recipe = filteredRecipes[i];
                    return _buildRecipeCard(context, vm, recipe);
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, MainViewModel vm, Recipe recipe) {
    final nut = recipe.nutrientsPerServing;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${recipe.cuisine} • ${recipe.prepTimeMinutes + recipe.cookTimeMinutes} mins • ${recipe.defaultServings} servings',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  recipe.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: recipe.isFavorite ? AppColors.warmAmber : Colors.grey,
                  size: 22,
                ),
                onPressed: () => vm.toggleRecipeFavorite(recipe.id),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            recipe.description,
            style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // Dietary tags
          Wrap(
            spacing: 6,
            children: recipe.dietaryTags.take(3).map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(fontSize: 10, color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),

          const Spacer(),

          const Divider(height: 16),

          // Bottom Bar: Nutrients & Quick Log Action
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${nut.calories.toStringAsFixed(0)} kcal / serv',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryLight),
                  ),
                  Text(
                    'P: ${nut.proteinGrams.toStringAsFixed(0)}g | C: ${nut.carbsGrams.toStringAsFixed(0)}g | F: ${nut.fatGrams.toStringAsFixed(0)}g',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showQuickLogRecipeDialog(context, vm, recipe),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Log Dish'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQuickLogRecipeDialog(BuildContext context, MainViewModel vm, Recipe recipe) {
    MealType selectedMeal = MealType.breakfast;
    double servings = 1.0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('Log ${recipe.name} to Daily Meals'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Meal Category:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<MealType>(
                    value: selectedMeal,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    items: MealType.values.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text('${m.iconEmoji} ${m.displayName}'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedMeal = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Servings to Log: ', style: TextStyle(fontSize: 13)),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 18),
                        onPressed: () => setModalState(() => servings = (servings - 0.5).clamp(0.5, 10.0)),
                      ),
                      Text(servings.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        onPressed: () => setModalState(() => servings = servings + 0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Nutrients: ${(recipe.nutrientsPerServing.calories * servings).toStringAsFixed(0)} kcal • ${(recipe.nutrientsPerServing.proteinGrams * servings).toStringAsFixed(1)}g Protein',
                    style: const TextStyle(fontSize: 11, color: AppColors.primaryLight, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    vm.logRecipeToMeal(
                      recipe: recipe,
                      mealType: selectedMeal,
                      servings: servings,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Confirm & Log'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddRecipeDialog(BuildContext context, MainViewModel vm) {
    final nameCtrl = TextEditingController();
    final cuisineCtrl = TextEditingController(text: 'South Indian');
    final descCtrl = TextEditingController();
    final calCtrl = TextEditingController(text: '250');
    final protCtrl = TextEditingController(text: '8');
    final carbCtrl = TextEditingController(text: '35');
    final fatCtrl = TextEditingController(text: '6');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Create New Recipe'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Recipe Name (e.g. Masala Dosa, Quinoa Salad)')),
                const SizedBox(height: 10),
                TextField(controller: cuisineCtrl, decoration: const InputDecoration(labelText: 'Cuisine (e.g. South Indian, Mediterranean)')),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Short Description')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: calCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calories (kcal)'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: protCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Protein (g)'))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: carbCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Carbs (g)'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: fatCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fat (g)'))),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final newRecipe = Recipe(
                  id: 'rec_custom_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  cuisine: cuisineCtrl.text.trim(),
                  prepTimeMinutes: 15,
                  cookTimeMinutes: 20,
                  defaultServings: 2,
                  ingredients: [
                    RecipeIngredient(name: 'Pantry Ingredients', quantity: 100, unit: 'g'),
                  ],
                  instructions: ['Prepare and cook according to recipe.'],
                  nutrientsPerServing: MacroNutrients(
                    calories: double.tryParse(calCtrl.text) ?? 250,
                    proteinGrams: double.tryParse(protCtrl.text) ?? 8,
                    carbsGrams: double.tryParse(carbCtrl.text) ?? 35,
                    fatGrams: double.tryParse(fatCtrl.text) ?? 6,
                    fiberGrams: 3.0,
                    sodiumMg: 250,
                  ),
                  dietaryTags: ['Custom Home Recipe'],
                  isFrequentlyPrepared: true,
                  description: descCtrl.text.trim(),
                );
                vm.addCustomRecipe(newRecipe);
                Navigator.pop(ctx);
              },
              child: const Text('Save Recipe'),
            ),
          ],
        );
      },
    );
  }
}
