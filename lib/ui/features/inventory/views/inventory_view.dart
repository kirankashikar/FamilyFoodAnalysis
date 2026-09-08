import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:family_food_analysis/ui/theme/app_theme.dart';
import 'package:family_food_analysis/ui/view_models/main_view_model.dart';
import 'package:family_food_analysis/ui/core/glass_card.dart';
import 'package:family_food_analysis/data/models/grocery_item.dart';

import 'package:family_food_analysis/ui/features/inventory/widgets/store_connectors_modal.dart';
import 'package:family_food_analysis/ui/features/inventory/widgets/add_bill_sheet.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  String _searchQuery = '';
  GroceryCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final filteredItems = vm.inventoryItems.where((it) {
      final matchesQuery = _searchQuery.isEmpty ||
          it.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (it.storeName != null && it.storeName!.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesCategory = _selectedCategory == null || it.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Text(
            'Pantry & Grocery Inventory',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Text(
            '${vm.inventoryItems.length} tracked items • Auto-synchronized to Google Sheets (${vm.sheetsConfig.inventorySheetName})',
            style: TextStyle(fontSize: 13, color: AppColors.muted(context)),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () => AddBillSheet.show(context),
                icon: const Icon(Icons.receipt_long_rounded, size: 18),
                label: Text(isDesktop ? 'Add Grocery Bill' : 'Add Bill'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showStoreConnectorsModal(context),
                icon: const Icon(Icons.hub_rounded, size: 18),
                label: Text(isDesktop ? 'Store Connectors (Costco & Amazon)' : 'Connectors'),
              ),
              OutlinedButton.icon(
                onPressed: () => _showManualAddItemDialog(context, vm),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Item'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Google Sheets Live Sync Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.secondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.zero,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_done_rounded, color: AppColors.primaryLight, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Google Sheets Database Linked',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'Pantry inventory changes automatically sync to your connected Google Sheet tab "${vm.sheetsConfig.inventorySheetName}".',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF7D7979)),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => vm.syncToGoogleSheets(),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Sync Now'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primaryLight),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Search and Category Chips
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search pantry items, stores, or ingredients...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

          // Category Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Categories'),
                  selected: _selectedCategory == null,
                  onSelected: (_) => setState(() => _selectedCategory = null),
                ),
                const SizedBox(width: 8),
                ...GroceryCategory.values.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('${cat.iconEmoji} ${cat.displayName}'),
                      selected: _selectedCategory == cat,
                      onSelected: (sel) => setState(() => _selectedCategory = sel ? cat : null),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Inventory Table / List
          if (filteredItems.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text('No items match your filter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Upload a grocery bill or add items to populate your pantry.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final item = filteredItems[idx];
                return _buildInventoryItemCard(context, vm, item);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInventoryItemCard(BuildContext context, MainViewModel vm, GroceryItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d');

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Emoji Icon Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
              borderRadius: BorderRadius.zero,
            ),
            child: Center(
              child: Text(
                item.category.iconEmoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Title, Category & Store
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    if (item.storeName != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Text(
                          item.storeName!,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF7D7979)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      item.category.displayName,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF7D7979)),
                    ),
                    const SizedBox(width: 10),
                    if (item.expiryDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: item.isExpired
                              ? AppColors.roseAlert.withValues(alpha: 0.15)
                              : (item.isExpiringSoon ? AppColors.warmAmber.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Text(
                          item.isExpired
                              ? 'Expired (${dateFormat.format(item.expiryDate!)})'
                              : (item.isExpiringSoon
                                  ? 'Exp: ${dateFormat.format(item.expiryDate!)} (${item.expiryDate!.difference(DateTime.now()).inDays}d left)'
                                  : 'Exp: ${dateFormat.format(item.expiryDate!)}'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: item.isExpired
                                ? AppColors.roseAlert
                                : (item.isExpiringSoon ? AppColors.warmAmber : AppColors.primaryLight),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Quantity Adjuster (+ / -)
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: () {
                  final next = (item.remainingQuantity - 0.5).clamp(0.0, item.quantity);
                  vm.updateGroceryItemQuantity(item.id, next);
                },
              ),
              Text(
                '${item.remainingQuantity.toStringAsFixed(item.remainingQuantity % 1 == 0 ? 0 : 1)} ${item.unit}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () {
                  final next = item.remainingQuantity + 0.5;
                  vm.updateGroceryItemQuantity(item.id, next);
                },
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Cost
          Text(
            '\$${item.estimatedCost.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),

          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
            onPressed: () => vm.removeGroceryItem(item.id),
          ),
        ],
      ),
    );
  }

  void _showStoreConnectorsModal(BuildContext context) {
    StoreConnectorsModal.show(context);
  }

  void _showManualAddItemDialog(BuildContext context, MainViewModel vm) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final unitCtrl = TextEditingController(text: 'lbs');
    final costCtrl = TextEditingController(text: '4.99');
    final storeCtrl = TextEditingController(text: 'Grocery Store');
    GroceryCategory selectedCategory = GroceryCategory.produce;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Pantry Grocery Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Item Name (e.g., Organic Paneer, Brown Rice)'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<GroceryCategory>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: GroceryCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text('${cat.iconEmoji} ${cat.displayName}'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: qtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Quantity'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: unitCtrl,
                            decoration: const InputDecoration(labelText: 'Unit (g, kg, lbs, count)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: costCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Estimated Cost (\$)'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: storeCtrl,
                            decoration: const InputDecoration(labelText: 'Store / Source'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final qty = double.tryParse(qtyCtrl.text) ?? 1.0;
                    final cost = double.tryParse(costCtrl.text) ?? 0.0;

                    final newItem = GroceryItem(
                      id: 'item_${DateTime.now().microsecondsSinceEpoch}',
                      name: nameCtrl.text.trim(),
                      category: selectedCategory,
                      quantity: qty,
                      unit: unitCtrl.text.trim(),
                      estimatedCost: cost,
                      purchaseDate: DateTime.now(),
                      expiryDate: DateTime.now().add(const Duration(days: 14)),
                      remainingQuantity: qty,
                      storeName: storeCtrl.text.trim(),
                    );

                    vm.addGroceryItem(newItem);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add to Inventory'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

