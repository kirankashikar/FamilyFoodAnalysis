import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../view_models/main_view_model.dart';
import '../core/glass_card.dart';

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
      const _NavDestination(icon: Icons.person_pin_rounded, label: 'Family & BMI'),
      _NavDestination(
        icon: Icons.auto_awesome_rounded,
        label: 'Suggestions',
        badgeCount: vm.currentRecommendations.isNotEmpty ? vm.currentRecommendations.length : null,
      ),
      const _NavDestination(icon: Icons.cloud_sync_rounded, label: 'Google Sheets'),
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
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
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
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary.withOpacity(0.2),
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
                                      color: Color(0xFF94A3B8),
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
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(isDark ? 0.18 : 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: isSelected
                                    ? Border.all(color: AppColors.primary.withOpacity(0.4))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    color: isSelected ? AppColors.primaryLight : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? (isDark ? Colors.white : AppColors.primaryDark)
                                            : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
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
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${item.badgeCount}',
                                        style: const TextStyle(
                                          color: Colors.black,
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

                  // Bottom User Info & Sheets Indicator
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCardElevated.withOpacity(0.5) : AppColors.lightCardElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.circle, color: AppColors.primary, size: 10),
                            const SizedBox(width: 6),
                            const Text(
                              'Google Sheets Sync',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Text(
                              vm.sheetsConfig.syncStatus.contains('Connected') ? 'LIVE' : 'READY',
                              style: const TextStyle(fontSize: 9, color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sheet: ${vm.sheetsConfig.spreadsheetId.substring(0, 12)}...',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
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
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
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

    // Mobile Viewport
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.eco_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(navItems[vm.selectedTabIndex].label),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Text(
                vm.activeMember.name.isNotEmpty ? vm.activeMember.name[0] : 'U',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
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
          IconButton(
            icon: const Icon(Icons.cloud_sync_rounded),
            onPressed: () => vm.syncToGoogleSheets(),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: vm.selectedTabIndex,
        onDestinationSelected: (idx) => vm.setTabIndex(idx),
        destinations: navItems.map((item) {
          return NavigationDestination(
            icon: item.badgeCount != null
                ? Badge(
                    label: Text('${item.badgeCount}'),
                    child: Icon(item.icon),
                  )
                : Icon(item.icon),
            label: item.label.split(' ')[0],
          );
        }).toList(),
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
