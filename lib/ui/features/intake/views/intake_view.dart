import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:family_food_analysis/ui/theme/app_theme.dart';
import 'package:family_food_analysis/ui/view_models/main_view_model.dart';
import 'package:family_food_analysis/ui/core/glass_card.dart';
import 'package:family_food_analysis/data/models/food_item.dart';
import 'package:family_food_analysis/data/models/nutrition_goals.dart';
import 'package:family_food_analysis/ui/features/intake/widgets/snap_meal_sheet.dart';

class IntakeView extends StatelessWidget {
  const IntakeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();
    final summary = vm.todaySummary;
    final budget = vm.activeMember.customMacroBudget;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & Member Selection Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Intake for ${vm.activeMember.name}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track meals, analyze nutrient absorption, and optimize your ${vm.activeMember.goal.displayName.split(' ')[0]} goal.',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF7D7979)),
                    ),
                  ],
                ),
              ),
              // Date Controls
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      onPressed: () {
                        vm.setSelectedDate(vm.selectedDate.subtract(const Duration(days: 1)));
                      },
                    ),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: vm.selectedDate,
                          firstDate: DateTime(2025),
                          lastDate: DateTime(2027),
                        );
                        if (picked != null) vm.setSelectedDate(picked);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Text(
                          DateFormat('EEE, MMM d').format(vm.selectedDate),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 20),
                      onPressed: () {
                        vm.setSelectedDate(vm.selectedDate.add(const Duration(days: 1)));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Snap-a-Meal Entry Point
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => SnapMealSheet.show(context),
              icon: const Icon(Icons.camera_alt_rounded, size: 18),
              label: const Text('Snap a Meal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Daily Progress Overview Bar
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildMetricStat('Calories', '${summary.totalNutrients.calories.toStringAsFixed(0)} / ${budget.targetCalories.toStringAsFixed(0)} kcal', AppColors.caloriesColor),
                _buildDivider(),
                _buildMetricStat('Protein', '${summary.totalNutrients.proteinGrams.toStringAsFixed(0)} / ${budget.targetProteinGrams.toStringAsFixed(0)}g', AppColors.proteinColor),
                _buildDivider(),
                _buildMetricStat('Carbs', '${summary.totalNutrients.carbsGrams.toStringAsFixed(0)} / ${budget.targetCarbsGrams.toStringAsFixed(0)}g', AppColors.carbsColor),
                _buildDivider(),
                _buildMetricStat('Fat', '${summary.totalNutrients.fatGrams.toStringAsFixed(0)} / ${budget.targetFatGrams.toStringAsFixed(0)}g', AppColors.fatColor),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4 Meal Sections: Breakfast, Lunch, Dinner, Snack
          ...MealType.values.map((mealType) {
            final items = summary.mealsByType[mealType] ?? [];
            final mealCalories = items.fold(0.0, (sum, it) => sum + it.calculatedNutrients.calories);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(mealType.iconEmoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mealType.displayName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${mealCalories.toStringAsFixed(0)} kcal total',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF7D7979)),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => _showLogFoodDialog(context, vm, mealType),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Log Dish'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (items.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCardElevated.withValues(alpha: 0.4) : AppColors.lightCardElevated,
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Center(
                          child: Text(
                            'No items logged for ${mealType.displayName}. Tap "Log Dish" to search foods (Dosa, Hummus, Salads, etc.).',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF7D7979)),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final entry = items[i];
                          final nut = entry.calculatedNutrients;

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                              borderRadius: BorderRadius.zero,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.foodName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${entry.servings.toStringAsFixed(1)} serving (${entry.servingUnit}) • ${nut.proteinGrams.toStringAsFixed(0)}g Protein, ${nut.carbsGrams.toStringAsFixed(0)}g Carbs, ${nut.fatGrams.toStringAsFixed(0)}g Fat, ${nut.fiberGrams.toStringAsFixed(1)}g Fiber',
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF7D7979)),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${nut.calories.toStringAsFixed(0)} kcal',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primaryLight),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                                  onPressed: () => vm.removeMealEntry(entry.id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetricStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF7D7979), fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 28, color: const Color(0xFF444141));
  }

  void _showLogFoodDialog(BuildContext context, MainViewModel vm, MealType mealType) {
    showDialog(
      context: context,
      builder: (ctx) => _LogFoodModal(vm: vm, mealType: mealType),
    );
  }
}

class _LogFoodModal extends StatefulWidget {
  final MainViewModel vm;
  final MealType mealType;

  const _LogFoodModal({required this.vm, required this.mealType});

  @override
  State<_LogFoodModal> createState() => _LogFoodModalState();
}

class _LogFoodModalState extends State<_LogFoodModal> {
  String _searchQuery = '';
  String _selectedCuisine = 'All';
  FoodItem? _selectedFood;
  double _servings = 1.0;
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final foodItems = widget.vm.foodDb.search(
      query: _searchQuery,
      cuisine: _selectedCuisine,
    );

    final cuisines = ['All', 'South Indian', 'North Indian', 'Mediterranean', 'Middle Eastern', 'East Asian', 'Latin American', 'Western Balanced'];

    return AlertDialog(
      title: Row(
        children: [
          Text(widget.mealType.iconEmoji),
          const SizedBox(width: 8),
          Text('Log Food for ${widget.mealType.displayName}'),
        ],
      ),
      content: SizedBox(
        width: (MediaQuery.of(context).size.width * 0.92).clamp(0, 650).toDouble(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search & Filter
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search food (e.g., Dosa, Hummus, Palak Paneer, Oats, Rice)...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),

              const SizedBox(height: 10),

              // Cuisine filter tags
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: cuisines.map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(c, style: const TextStyle(fontSize: 11)),
                        selected: _selectedCuisine == c,
                        onSelected: (sel) => setState(() => _selectedCuisine = sel ? c : 'All'),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 14),

              const Text('Select Food Item:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),

              Container(
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF444141)),
                  borderRadius: BorderRadius.zero,
                ),
                child: ListView.builder(
                  itemCount: foodItems.length,
                  itemBuilder: (ctx, i) {
                    final item = foodItems[i];
                    final isSelected = _selectedFood?.id == item.id;

                    return ListTile(
                      dense: true,
                      selected: isSelected,
                      selectedTileColor: AppColors.primary.withValues(alpha: 0.15),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('${item.cuisineCategory} • ${item.defaultServingUnit} • ${item.nutrientsPerServing.calories.toInt()} kcal'),
                      trailing: Text(
                        'P: ${item.nutrientsPerServing.proteinGrams.toInt()}g | C: ${item.nutrientsPerServing.carbsGrams.toInt()}g',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF7D7979)),
                      ),
                      onTap: () => setState(() => _selectedFood = item),
                    );
                  },
                ),
              ),

              if (_selectedFood != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.zero,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_selectedFood!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const Spacer(),
                          Text(
                            '${(_selectedFood!.nutrientsPerServing.calories * _servings).toStringAsFixed(0)} kcal',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLight, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text('Servings / Quantity: ', style: TextStyle(fontSize: 12)),
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: () => setState(() => _servings = (_servings - 0.5).clamp(0.5, 10.0)),
                          ),
                          Text(_servings.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () => setState(() => _servings = _servings + 0.5),
                          ),
                          const SizedBox(width: 8),
                          Text('(${_selectedFood!.defaultServingUnit})', style: const TextStyle(fontSize: 11, color: Color(0xFF7D7979))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nutrients: Protein ${(_selectedFood!.nutrientsPerServing.proteinGrams * _servings).toStringAsFixed(1)}g • Carbs ${(_selectedFood!.nutrientsPerServing.carbsGrams * _servings).toStringAsFixed(1)}g • Fat ${(_selectedFood!.nutrientsPerServing.fatGrams * _servings).toStringAsFixed(1)}g • Fiber ${(_selectedFood!.nutrientsPerServing.fiberGrams * _servings).toStringAsFixed(1)}g • Sodium ${(_selectedFood!.nutrientsPerServing.sodiumMg * _servings).toStringAsFixed(0)}mg',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFD7D3D3)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedFood == null
              ? null
              : () {
                  widget.vm.logFoodItem(
                    food: _selectedFood!,
                    mealType: widget.mealType,
                    servings: _servings,
                    notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
                  );
                  Navigator.pop(context);
                },
          child: const Text('Log to Meals'),
        ),
      ],
    );
  }
}
