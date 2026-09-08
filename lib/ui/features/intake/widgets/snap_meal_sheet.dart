import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:family_food_analysis/data/models/food_item.dart';
import 'package:family_food_analysis/ui/core/image_capture.dart';
import 'package:family_food_analysis/ui/theme/app_theme.dart';
import 'package:family_food_analysis/ui/view_models/main_view_model.dart';

enum _SnapStage { capture, working, results }

/// "Snap a Meal": photograph food, get on-device label suggestions matched
/// against the food database, confirm the dish, meal type, and servings,
/// then log it via the existing MainViewModel.logFoodItem pipeline.
class SnapMealSheet extends StatefulWidget {
  const SnapMealSheet({super.key});

  static void show(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    if (isDesktop) {
      showDialog(context: context, builder: (ctx) => const SnapMealSheet());
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (ctx) => const SnapMealSheet(),
      );
    }
  }

  @override
  State<SnapMealSheet> createState() => _SnapMealSheetState();
}

class _SnapMealSheetState extends State<SnapMealSheet> {
  _SnapStage _stage = _SnapStage.capture;
  String? _infoMessage;
  List<FoodItem> _candidates = [];
  String _manualQuery = '';
  FoodItem? _selectedFood;
  double _servings = 1.0;
  late MealType _mealType;

  @override
  void initState() {
    super.initState();
    _mealType = _guessMealTypeForNow();
  }

  MealType _guessMealTypeForNow() {
    final hour = DateTime.now().hour;
    if (hour < 11) return MealType.breakfast;
    if (hour < 15) return MealType.lunch;
    if (hour < 18) return MealType.snack;
    return MealType.dinner;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final content = Container(
      width: isDesktop ? 560 : double.infinity,
      constraints: isDesktop ? const BoxConstraints(maxHeight: 720) : null,
      height: isDesktop ? null : MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: isDesktop
            ? BorderRadius.circular(24)
            : const BorderRadius.vertical(top: Radius.circular(20)),
        border: isDesktop
            ? Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)
            : null,
      ),
      child: Column(
        mainAxisSize: isDesktop ? MainAxisSize.min : MainAxisSize.max,
        children: [
          if (!isDesktop)
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Snap a Meal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _buildStageBody(context),
            ),
          ),
        ],
      ),
    );

    if (!isDesktop) {
      return SafeArea(child: content);
    }
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: content,
    );
  }

  Widget _buildStageBody(BuildContext context) {
    switch (_stage) {
      case _SnapStage.capture:
        return _buildCapture(context);
      case _SnapStage.working:
        return _buildWorking(context);
      case _SnapStage.results:
        return _buildResults(context);
    }
  }

  Widget _buildCapture(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photograph your plate and we\'ll suggest a match from the food database.',
          style: TextStyle(fontSize: 13, color: AppColors.muted(context)),
        ),
        const SizedBox(height: 16),
        _actionTile(
          context,
          icon: Icons.camera_alt_rounded,
          title: 'Take Photo',
          onTap: () => _capture(ImageSource.camera),
        ),
        _actionTile(
          context,
          icon: Icons.photo_library_rounded,
          title: 'Choose from Gallery',
          onTap: () => _capture(ImageSource.gallery),
        ),
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: () => setState(() => _stage = _SnapStage.results),
          icon: const Icon(Icons.search_rounded, size: 18),
          label: const Text('Skip photo, search manually'),
        ),
        if (_infoMessage != null) ...[
          const SizedBox(height: 8),
          Text(_infoMessage!, style: const TextStyle(fontSize: 12, color: AppColors.roseAlert)),
        ],
      ],
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                const Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorking(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Identifying food on-device...', style: TextStyle(fontSize: 13, color: AppColors.muted(context))),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final vm = context.read<MainViewModel>();
    final searchResults = _manualQuery.isEmpty ? _candidates : vm.searchFoodDatabase(query: _manualQuery);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_infoMessage != null) ...[
          Text(_infoMessage!, style: TextStyle(fontSize: 12, color: AppColors.muted(context))),
          const SizedBox(height: 10),
        ],
        const Text('Meal:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: MealType.values.map((m) {
            return ChoiceChip(
              label: Text('${m.iconEmoji} ${m.displayName}', style: const TextStyle(fontSize: 12)),
              selected: _mealType == m,
              onSelected: (_) => setState(() => _mealType = m),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search food (e.g., Dosa, Hummus, Rice)...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (val) => setState(() => _manualQuery = val),
        ),
        const SizedBox(height: 10),
        if (_candidates.isNotEmpty && _manualQuery.isEmpty)
          Text('Suggested matches:', style: TextStyle(fontSize: 12, color: AppColors.muted(context))),
        const SizedBox(height: 6),
        Container(
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.muted(context).withOpacity(0.3)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: searchResults.isEmpty
              ? Center(
                  child: Text(
                    'No matches yet — try a different search term.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted(context)),
                  ),
                )
              : ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (ctx, i) {
                    final item = searchResults[i];
                    final isSelected = _selectedFood?.id == item.id;
                    return ListTile(
                      dense: true,
                      selected: isSelected,
                      selectedTileColor: AppColors.primary.withOpacity(0.15),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('${item.cuisineCategory} • ${item.nutrientsPerServing.calories.toInt()} kcal'),
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
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
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
                    const Text('Servings: ', style: TextStyle(fontSize: 12)),
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: () => setState(() => _servings = (_servings - 0.5).clamp(0.5, 10.0)),
                    ),
                    Text(_servings.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () => setState(() => _servings = _servings + 0.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() {
                _stage = _SnapStage.capture;
                _candidates = [];
                _selectedFood = null;
                _infoMessage = null;
              }),
              child: const Text('Retake'),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _selectedFood == null ? null : _confirmLog,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Log Meal'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _capture(ImageSource source) async {
    setState(() => _infoMessage = null);
    final XFile? picked = await ImageCapture.pickImage(source: source);
    if (picked == null || !mounted) return;

    setState(() => _stage = _SnapStage.working);

    final vm = context.read<MainViewModel>();
    try {
      final labels = await vm.foodRecognitionService.labelImage(picked.path);
      final matches = <String, FoodItem>{};
      for (final label in labels) {
        for (final item in vm.searchFoodDatabase(query: label)) {
          matches[item.id] = item;
        }
        if (matches.length >= 8) break;
      }
      if (!mounted) return;
      setState(() {
        _candidates = matches.values.toList();
        _infoMessage = _candidates.isEmpty
            ? 'Couldn\'t confidently match that photo — search for your dish below.'
            : 'Matched from: ${labels.take(3).join(', ')}';
        _stage = _SnapStage.results;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _candidates = [];
        _infoMessage = kIsWeb
            ? 'On-device food recognition needs the mobile app — search for your dish below.'
            : 'Couldn\'t identify that photo — search for your dish below.';
        _stage = _SnapStage.results;
      });
    }
  }

  void _confirmLog() {
    final vm = context.read<MainViewModel>();
    vm.logFoodItem(food: _selectedFood!, mealType: _mealType, servings: _servings);
    Navigator.of(context).pop();
  }
}
