import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_food_analysis/ui/theme/app_theme.dart';
import 'package:family_food_analysis/ui/view_models/main_view_model.dart';
import 'package:family_food_analysis/data/models/nutrition_goals.dart';
import 'package:family_food_analysis/ui/features/inventory/widgets/add_bill_sheet.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;

  const ResponsiveScaffold({
    super.key,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navItems = [
      const _NavDestination(icon: Icons.dashboard_rounded, label: 'Dashboard'),
      _NavDestination(
        icon: Icons.inventory_2_rounded,
        label: 'Pantry & Bills',
        badgeCount: vm.expiringSoonItems.isNotEmpty ? vm.expiringSoonItems.length : null,
      ),
      const _NavDestination(icon: Icons.restaurant_rounded, label: 'Food Intake'),
      const _NavDestination(icon: Icons.menu_book_rounded, label: 'Recipes'),
      const _NavDestination(icon: Icons.person_pin_rounded, label: 'Profile'),
      _NavDestination(
        icon: Icons.auto_awesome_rounded,
        label: 'Suggestions',
        badgeCount: vm.currentRecommendations.isNotEmpty ? vm.currentRecommendations.length : null,
      ),
      const _NavDestination(icon: Icons.settings_rounded, label: 'Settings'),
    ];

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Desktop Sidebar
            Container(
              width: 270,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(
                  right: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // App Branding
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.zero,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'FamilyFood',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Nutrition & Grocery AI',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.muted(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Family Member Switcher Pill
                  if (vm.currentUser != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                          borderRadius: BorderRadius.zero,
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                              child: Text(
                                vm.activeMember.name.isNotEmpty ? vm.activeMember.name[0] : 'U',
                                style: const TextStyle(
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vm.activeMember.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${vm.activeMember.relationship} • ${vm.activeMember.goal.displayName.split(' ')[0]}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF7D7979),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                              tooltip: 'Switch Member',
                              onSelected: (id) => vm.switchActiveFamilyMember(id),
                              itemBuilder: (ctx) {
                                return vm.currentUser!.familyMembers.map((m) {
                                  return PopupMenuItem(
                                    value: m.id,
                                    child: Row(
                                      children: [
                                        Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        const SizedBox(width: 8),
                                        Text('(${m.relationship})', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                        if (m.id == vm.activeMember.id) ...[
                                          const Spacer(),
                                          const Icon(Icons.check, size: 16, color: AppColors.primary),
                                        ]
                                      ],
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const Divider(height: 16),

                  // Navigation Links
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: navItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (ctx, idx) {
                        final item = navItems[idx];
                        final isSelected = vm.selectedTabIndex == idx;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => vm.setTabIndex(idx),
                            borderRadius: BorderRadius.zero,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.zero,
                                border: isSelected
                                    ? Border.all(color: AppColors.primary.withValues(alpha: 0.4))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    color: isSelected ? AppColors.primaryLight : AppColors.muted(context),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? (isDark ? Colors.white : AppColors.primaryDark)
                                            : (isDark ? const Color(0xFFD7D3D3) : const Color(0xFF444141)),
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  if (item.badgeCount != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: item.label.contains('Pantry') ? AppColors.warmAmber : AppColors.primary,
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      child: Text(
                                        '${item.badgeCount}',
                                        style: const TextStyle(
                                          color: AppColors.bg,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings_rounded, color: AppColors.accent),
                    title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      vm.sheetsConfig.syncStatus.contains('Connected') ? 'Sheets sync: live' : 'Sheets sync: ready',
                      style: TextStyle(fontSize: 11, color: AppColors.muted(context)),
                    ),
                    onTap: () => vm.setTabIndex(6),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(navItems[vm.selectedTabIndex].label),
                  actions: [
                    if (vm.statusNotification != null) ...[
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.zero,
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primaryLight),
                              const SizedBox(width: 6),
                              Text(
                                vm.statusNotification!,
                                style: const TextStyle(fontSize: 12, color: AppColors.primaryLight, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () => vm.clearNotification(),
                                child: const Icon(Icons.close, size: 14, color: AppColors.primaryLight),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    IconButton(
                      icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                      tooltip: isDark ? 'Switch to bright mode' : 'Switch to dark mode',
                      onPressed: () => vm.toggleDarkMode(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.sync_rounded),
                      tooltip: 'Sync with Google Sheets',
                      onPressed: () => vm.syncToGoogleSheets(),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
                body: body,
              ),
            ),
          ],
        ),
      );
    }

    // Mobile Viewport — Recipes(3)/Suggestions(5)/Settings(6) aren't on the
    // bottom bar; they're reached via Dashboard quick actions / Profile
    // links, so they get a back arrow to Dashboard instead of persistent nav.
    const secondaryIndices = [3, 5, 6];
    final isSecondaryScreen = secondaryIndices.contains(vm.selectedTabIndex);

    return Scaffold(
      appBar: AppBar(
        leading: isSecondaryScreen
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => vm.setTabIndex(0),
              )
            : null,
        title: Text(navItems[vm.selectedTabIndex].label),
        actions: [
          if (vm.currentUser != null)
            PopupMenuButton<String>(
              icon: CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                child: Text(
                  vm.activeMember.name.isNotEmpty ? vm.activeMember.name[0] : 'U',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent),
                ),
              ),
              tooltip: 'Family Members',
              onSelected: (id) => vm.switchActiveFamilyMember(id),
              itemBuilder: (ctx) {
                return vm.currentUser!.familyMembers.map((m) {
                  return PopupMenuItem(
                    value: m.id,
                    child: Text('${m.name} (${m.relationship})'),
                  );
                }).toList();
              },
            ),
        ],
      ),
      body: body,
      bottomNavigationBar: _MobileNavBar(selectedTabIndex: vm.selectedTabIndex, onSelect: vm.setTabIndex),
    );
  }
}

/// The design's 5-slot bar: Home / Pantry / a raised center camera FAB /
/// Intake / Profile. The FAB opens the receipt scanner directly rather than
/// selecting a tab.
class _MobileNavBar extends StatelessWidget {
  final int selectedTabIndex;
  final ValueChanged<int> onSelect;

  const _MobileNavBar({required this.selectedTabIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? AppColors.darkBg : AppColors.bg;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.divider;

    return SizedBox(
      height: 74,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            top: 8,
            child: Container(
              decoration: BoxDecoration(color: barColor, border: Border(top: BorderSide(color: borderColor, width: 2))),
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  _navItem(context, icon: Icons.home_rounded, label: 'Home', index: 0),
                  _navItem(context, icon: Icons.kitchen_rounded, label: 'Pantry', index: 1),
                  const Expanded(child: SizedBox()), // space for the FAB
                  _navItem(context, icon: Icons.restaurant_rounded, label: 'Intake', index: 2),
                  _navItem(context, icon: Icons.person_rounded, label: 'Profile', index: 4),
                ],
              ),
            ),
          ),
          Positioned(
            top: -18,
            child: GestureDetector(
              onTap: () => AddBillSheet.show(context),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: barColor, width: 4),
                  boxShadow: AppColors.shadowLg(isDark),
                ),
                child: Icon(Icons.camera_alt_rounded, color: AppColors.bg, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, {required IconData icon, required String label, required int index}) {
    final isSelected = selectedTabIndex == index;
    final color = isSelected ? AppColors.accent : AppColors.muted(context);
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }
}

class _NavDestination {
  final IconData icon;
  final String label;
  final int? badgeCount;

  const _NavDestination({
    required this.icon,
    required this.label,
    this.badgeCount,
  });
}
