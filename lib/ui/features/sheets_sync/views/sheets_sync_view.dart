import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:family_food_analysis/ui/theme/app_theme.dart';
import 'package:family_food_analysis/ui/view_models/main_view_model.dart';
import 'package:family_food_analysis/ui/core/glass_card.dart';

class SheetsSyncView extends StatefulWidget {
  const SheetsSyncView({super.key});

  @override
  State<SheetsSyncView> createState() => _SheetsSyncViewState();
}

class _SheetsSyncViewState extends State<SheetsSyncView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _sheetIdCtrl;
  late TextEditingController _inventoryTabCtrl;
  late TextEditingController _intakeTabCtrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final config = context.read<MainViewModel>().sheetsConfig;
    _sheetIdCtrl = TextEditingController(text: config.spreadsheetId);
    _inventoryTabCtrl = TextEditingController(text: config.inventorySheetName);
    _intakeTabCtrl = TextEditingController(text: config.intakeSheetName);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();
    final config = vm.sheetsConfig;
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    final inventoryCsv = vm.exportInventoryAsCsv();
    final intakeCsv = vm.exportIntakeAsCsv();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Google Sheets Database Synchronization',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Connected to: ${config.googleAccountEmail ?? vm.currentUser?.email ?? 'Logged-in Google User'}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: vm.isLoading ? null : () => vm.syncToGoogleSheets(),
                icon: vm.isLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.sync_rounded, size: 18),
                label: Text(vm.isLoading ? 'Syncing...' : 'Sync Cloud & Local'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Status & Connection Overview
          GlassCard(
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.table_chart_rounded, color: AppColors.primaryLight, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            config.syncStatus,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle, size: 16, color: AppColors.primaryLight),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last Sync: ${config.lastSyncTime != null ? dateFormat.format(config.lastSyncTime!) : 'Never'} • 2 Active Tabs',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Config Sheet ID & Tabs
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sheet URL & Tab Structure', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                TextField(
                  controller: _sheetIdCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Google Sheet ID or Full Spreadsheet URL',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inventoryTabCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Pantry Inventory Tab Name',
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: _intakeTabCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Daily Intake Logs Tab Name',
                          prefixIcon: Icon(Icons.restaurant_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        final newCfg = config.copyWith(
                          spreadsheetId: _sheetIdCtrl.text.trim(),
                          inventorySheetName: _inventoryTabCtrl.text.trim(),
                          intakeSheetName: _intakeTabCtrl.text.trim(),
                        );
                        vm.updateSheetsConfig(newCfg);
                      },
                      icon: const Icon(Icons.save_outlined, size: 16),
                      label: const Text('Save Settings'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Live Sheet Data Previews
          const Text('Live Google Sheets Raw Data Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.inventory_2_rounded), text: 'Tab: PantryInventory'),
              Tab(icon: Icon(Icons.restaurant_rounded), text: 'Tab: DailyIntakeLogs'),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: 320,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCsvViewer(context, inventoryCsv, 'Inventory CSV (Auto-synced to Sheets)'),
                _buildCsvViewer(context, intakeCsv, 'Intake Logs CSV (Auto-synced to Sheets)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCsvViewer(BuildContext context, String csvContent, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
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
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('RFC 4180 Format', style: TextStyle(fontSize: 10, color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                csvContent,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
