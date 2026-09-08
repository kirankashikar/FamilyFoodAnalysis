import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_food_analysis/ui/theme/app_theme.dart';
import 'package:family_food_analysis/ui/view_models/main_view_model.dart';
import 'package:family_food_analysis/ui/features/sheets_sync/views/sheets_sync_view.dart';

/// Not part of the source design (it has no Settings screen of its own) —
/// styled to match it: flat segmented control, hairline dividers, Archivo.
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  int _segment = 0; // 0 = Appearance, 1 = Google Sheets

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Expanded(child: _segButton('Appearance', 0)),
              Expanded(child: _segButton('Google Sheets', 1)),
            ],
          ),
        ),
        Expanded(
          child: _segment == 0 ? _buildAppearance(context, vm, isDark) : const SheetsSyncView(),
        ),
      ],
    );
  }

  Widget _segButton(String label, int index) {
    final isSelected = _segment == index;
    return GestureDetector(
      onTap: () => setState(() => _segment = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          border: Border.all(color: AppColors.dividerColor(context)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isSelected ? AppColors.bg : null,
          ),
        ),
      ),
    );
  }

  Widget _buildAppearance(BuildContext context, MainViewModel vm, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Theme', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _appearanceOption(
                  context,
                  icon: Icons.light_mode_rounded,
                  label: 'Bright',
                  selected: !isDark,
                  onTap: () {
                    if (isDark) vm.toggleDarkMode();
                  },
                ),
              ),
              Expanded(
                child: _appearanceOption(
                  context,
                  icon: Icons.dark_mode_rounded,
                  label: 'Dark',
                  selected: isDark,
                  onTap: () {
                    if (!isDark) vm.toggleDarkMode();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Bright is the default look for FamilyFood.',
            style: TextStyle(fontSize: 12, color: AppColors.muted(context)),
          ),
        ],
      ),
    );
  }

  Widget _appearanceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent100 : null,
            border: Border.all(color: selected ? AppColors.accent : AppColors.dividerColor(context)),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.accent700 : AppColors.muted(context)),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.accent700 : AppColors.muted(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
