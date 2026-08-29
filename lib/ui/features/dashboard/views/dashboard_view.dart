import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../view_models/main_view_model.dart';
import '../../../core/glass_card.dart';
import '../../../core/macro_donut_chart.dart';
import '../../../core/nutrient_progress_bar.dart';
import '../../../../data/models/food_item.dart';
import '../../../../data/models/nutrition_goals.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();
    final summary = vm.todaySummary;
    final budget = vm.activeMember.customMacroBudget;
    final assessment = vm.activeMemberBmiAssessment;
    final recommendations = vm.currentRecommendations;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Active Member Header
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${vm.activeMember.name} 👋',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('EEEE, MMMM d').format(vm.selectedDate)} • Goal: ${vm.activeMember.goal.displayName}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => vm.setTabIndex(2), // Navigate to Food Intake
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Log Intake'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Main Hero Grid: Macros on Left, BMI & Goals on Right
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildNutritionCard(context, summary, budget),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: _buildBmiAndGoalsCard(context, vm, assessment),
                ),
              ],
            )
          else ...[
            _buildNutritionCard(context, summary, budget),
            const SizedBox(height: 16),
            _buildBmiAndGoalsCard(context, vm, assessment),
          ],

          const SizedBox(height: 24),

          // Micronutrients & Fiber Tracking Card
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics_rounded, color: AppColors.secondary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Micronutrients & Heart Health Breakdown',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Target Budget Active',
                        style: TextStyle(fontSize: 11, color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                NutrientProgressBar(
                  title: 'Dietary Fiber (Soluble & Insoluble)',
                  current: summary.totalNutrients.fiberGrams,
                  target: budget.targetFiberGrams,
                  unit: 'g',
                  color: AppColors.fiberColor,
                  subtitle: 'Gut biome & Glycemic balance',
                ),
                const SizedBox(height: 14),
                NutrientProgressBar(
                  title: 'Sodium',
                  current: summary.totalNutrients.sodiumMg,
                  target: budget.targetSodiumMg,
                  unit: 'mg',
                  color: AppColors.sodiumColor,
                  subtitle: 'Upper limit threshold',
                  isLimit: true,
                ),
                const SizedBox(height: 14),
                NutrientProgressBar(
                  title: 'Potassium',
                  current: summary.totalNutrients.potassiumMg,
                  target: budget.targetPotassiumMg,
                  unit: 'mg',
                  color: AppColors.warmAmber,
                  subtitle: 'Cellular electrolyte balance',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Action Cards: Expiring Inventory + Top Smart Suggestions
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildExpiringPantryCard(context, vm)),
                const SizedBox(width: 20),
                Expanded(child: _buildTopSuggestionsCard(context, vm, recommendations)),
              ],
            )
          else ...[
            _buildExpiringPantryCard(context, vm),
            const SizedBox(height: 16),
            _buildTopSuggestionsCard(context, vm, recommendations),
          ],

          const SizedBox(height: 24),

          // Today's Meals Timeline
          _buildTodayMealsTimeline(context, vm, summary),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(BuildContext context, DailyIntakeSummary summary, DailyMacroBudget budget) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_rounded, color: AppColors.primaryLight, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Today\'s Nutrient Distribution',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${summary.totalNutrients.calories.toStringAsFixed(0)} / ${budget.targetCalories.toStringAsFixed(0)} kcal',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 20),
          MacroDonutChart(
            consumed: summary.totalNutrients,
            budget: budget,
          ),
        ],
      ),
    );
  }

  Widget _buildBmiAndGoalsCard(BuildContext context, MainViewModel vm, BmiAssessment assessment) {
    final member = vm.activeMember;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monitor_heart_rounded, color: AppColors.roseAlert, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Profile & BMI Vitality',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              InkWell(
                onTap: () => vm.setTabIndex(4), // Navigate to Family Profile
                child: const Text(
                  'Edit',
                  style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      assessment.bmi.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryLight),
                    ),
                    const Text('BMI', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${assessment.category} (${member.heightCm.toInt()}cm, ${member.weightKg.toInt()}kg)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BMR: ${assessment.bmr.toInt()} kcal • TDEE: ${assessment.tdee.toInt()} kcal/day',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkCardElevated
                  : AppColors.lightCardElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.restaurant_menu_rounded, size: 14, color: AppColors.warmAmber),
                    const SizedBox(width: 6),
                    Text(
                      'Dietary Preset: ${member.ethnicity}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Preferences: ${member.dietaryPreferences.join(', ')}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringPantryCard(BuildContext context, MainViewModel vm) {
    final expiring = vm.expiringSoonItems;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: AppColors.warmAmber, size: 18),
              const SizedBox(width: 8),
              const Text('Expiring Soon in Pantry', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const Spacer(),
              InkWell(
                onTap: () => vm.setTabIndex(1), // Pantry tab
                child: const Text('View All', style: TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (expiring.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '✨ All pantry ingredients are fresh!',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
            )
          else
            ...expiring.take(3).map((it) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(it.category.iconEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        it.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.roseAlert.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${it.expiryDate != null ? it.expiryDate!.difference(DateTime.now()).inDays : 0}d left',
                        style: const TextStyle(fontSize: 11, color: AppColors.roseAlert, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTopSuggestionsCard(BuildContext context, MainViewModel vm, List<RecommendationItem> recs) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryLight, size: 18),
              const SizedBox(width: 8),
              const Text('Smart Health Suggestions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const Spacer(),
              InkWell(
                onTap: () => vm.setTabIndex(5), // Suggestions tab
                child: const Text('All Insights', style: TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Goals are perfectly on track today!', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
            )
          else
            ...recs.take(2).map((r) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.iconEmoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(r.suggestedAction, style: const TextStyle(fontSize: 11, color: Color(0xFFCBD5E1))),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTodayMealsTimeline(BuildContext context, MainViewModel vm, DailyIntakeSummary summary) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              const Text('Logged Meals for Today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => vm.setTabIndex(2),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Meal'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...MealType.values.map((type) {
            final meals = summary.mealsByType[type] ?? [];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(type.iconEmoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(type.displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text('(${meals.length} items)', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (meals.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 24, bottom: 4),
                      child: Text('Nothing logged yet for ${type.displayName}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    )
                  else
                    ...meals.map((m) {
                      return Container(
                        margin: const EdgeInsets.only(left: 24, bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkCardElevated
                              : AppColors.lightCardElevated,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${m.foodName} (${m.servings.toStringAsFixed(1)} ${m.servingUnit})',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'P: ${m.calculatedNutrients.proteinGrams.toStringAsFixed(0)}g • C: ${m.calculatedNutrients.carbsGrams.toStringAsFixed(0)}g • F: ${m.calculatedNutrients.fatGrams.toStringAsFixed(0)}g',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${m.calculatedNutrients.calories.toStringAsFixed(0)} kcal',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryLight),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.grey),
                              onPressed: () => vm.removeMealEntry(m.id),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
