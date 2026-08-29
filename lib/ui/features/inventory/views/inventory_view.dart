import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../view_models/main_view_model.dart';
import '../../../core/glass_card.dart';
import '../../../../data/models/grocery_item.dart';

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
          (it.storeName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchesCategory = _selectedCategory == null || it.category == _selectedCategory;
      return matchesQuery && matchesCategory;
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
                      'Pantry & Grocery Inventory',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vm.inventoryItems.length} tracked items • Auto-synchronized to Google Sheets (${vm.sheetsConfig.inventorySheetName})',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showBillUploadDialog(context, vm),
                icon: const Icon(Icons.receipt_long_rounded, size: 18),
                label: const Text('Upload Bill / OCR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
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
                  AppColors.primary.withOpacity(0.15),
                  AppColors.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
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
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
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
              borderRadius: BorderRadius.circular(10),
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
                          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.storeName!,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
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
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(width: 10),
                    if (item.expiryDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: item.isExpired
                              ? AppColors.roseAlert.withOpacity(0.15)
                              : (item.isExpiringSoon ? AppColors.warmAmber.withOpacity(0.15) : AppColors.primary.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(4),
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

  void _showBillUploadDialog(BuildContext context, MainViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => _BillUploadDialog(vm: vm),
    );
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
                      value: selectedCategory,
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

class _BillUploadDialog extends StatefulWidget {
  final MainViewModel vm;

  const _BillUploadDialog({required this.vm});

  @override
  State<_BillUploadDialog> createState() => _BillUploadDialogState();
}

class _BillUploadDialogState extends State<_BillUploadDialog> {
  final TextEditingController _receiptTextCtrl = TextEditingController();
  final TextEditingController _storeCtrl = TextEditingController(text: 'Patel Brothers Indian Market');
  bool _isScanning = false;
  GroceryReceipt? _parsedReceipt;

  @override
  void initState() {
    super.initState();
    // Default to Indian Grocery Mart sample receipt
    final sample = widget.vm.ocrService.getSampleReceiptPresets().first;
    _receiptTextCtrl.text = sample.rawText;
    _storeCtrl.text = sample.storeName;
  }

  @override
  Widget build(BuildContext context) {
    final presets = widget.vm.ocrService.getSampleReceiptPresets();

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.document_scanner_rounded, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Upload Grocery Bill / OCR'),
        ],
      ),
      content: SizedBox(
        width: 650,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Upload a receipt image / PDF or select a sample receipt to parse line items directly into your pantry inventory and Google Sheets.',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),

              // Sample Presets Chips
              const Text('Load Preset Receipt Samples:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: presets.map((p) {
                  return ActionChip(
                    avatar: const Icon(Icons.receipt_rounded, size: 16),
                    label: Text(p.storeName),
                    onPressed: () {
                      setState(() {
                        _receiptTextCtrl.text = p.rawText;
                        _storeCtrl.text = p.storeName;
                        _parsedReceipt = null;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _storeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Store Name / Supermarket',
                  prefixIcon: Icon(Icons.store_rounded),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _receiptTextCtrl,
                maxLines: 8,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                decoration: const InputDecoration(
                  labelText: 'Receipt OCR Text Stream / Line Items',
                  hintText: 'Item Name   Qty   Price...',
                ),
              ),

              const SizedBox(height: 16),

              // Parse Action Button
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isScanning ? null : _runOcrScan,
                    icon: _isScanning
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.bolt_rounded, size: 18),
                    label: Text(_isScanning ? 'Extracting Items...' : 'Extract & Parse Items'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Simulated camera / file upload
                      setState(() {
                        final sample = widget.vm.ocrService.getSampleReceiptPresets()[1];
                        _receiptTextCtrl.text = sample.rawText;
                        _storeCtrl.text = sample.storeName;
                        _parsedReceipt = null;
                      });
                    },
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text('Pick Image / Camera'),
                  ),
                ],
              ),

              if (_parsedReceipt != null) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Detected ${_parsedReceipt!.extractedItems.length} items (Total: \$${_parsedReceipt!.totalAmount.toStringAsFixed(2)})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkCardElevated
                        : AppColors.lightCardElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _parsedReceipt!.extractedItems.length,
                    itemBuilder: (ctx, i) {
                      final it = _parsedReceipt!.extractedItems[i];
                      return ListTile(
                        dense: true,
                        leading: Text(it.category.iconEmoji),
                        title: Text(it.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: Text('${it.quantity} ${it.unit} • ${it.category.displayName}'),
                        trailing: Text('\$${it.estimatedCost.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
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
          child: const Text('Close'),
        ),
        if (_parsedReceipt != null)
          ElevatedButton.icon(
            onPressed: () {
              widget.vm.processReceiptBill(
                _receiptTextCtrl.text,
                storeName: _storeCtrl.text,
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.save_rounded, size: 18),
            label: const Text('Confirm & Save to Inventory'),
          ),
      ],
    );
  }

  Future<void> _runOcrScan() async {
    setState(() => _isScanning = true);
    final receipt = await widget.vm.ocrService.parseReceiptText(
      _receiptTextCtrl.text,
      storeNameHint: _storeCtrl.text,
    );
    setState(() {
      _isScanning = false;
      _parsedReceipt = receipt;
    });
  }
}
