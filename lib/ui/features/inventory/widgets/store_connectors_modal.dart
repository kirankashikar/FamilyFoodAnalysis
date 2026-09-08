import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_food_analysis/ui/theme/app_theme.dart';
import 'package:family_food_analysis/ui/view_models/main_view_model.dart';
import 'package:family_food_analysis/ui/core/glass_card.dart';
import 'package:family_food_analysis/data/models/store_connector_models.dart';
import 'package:family_food_analysis/data/models/grocery_item.dart';

class StoreConnectorsModal extends StatefulWidget {
  const StoreConnectorsModal({super.key});

  /// Shows the modal responsively: a centered dialog on desktop widths, or a
  /// full-height bottom sheet on mobile.
  static void show(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    if (isDesktop) {
      showDialog(context: context, builder: (ctx) => const StoreConnectorsModal());
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (ctx) => const StoreConnectorsModal(),
      );
    }
  }

  @override
  State<StoreConnectorsModal> createState() => _StoreConnectorsModalState();
}

class _StoreConnectorsModalState extends State<StoreConnectorsModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final content = Container(
      width: isDesktop ? 820 : double.infinity,
      height: isDesktop ? 680 : MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: isDesktop
            ? BorderRadius.circular(24)
            : const BorderRadius.vertical(top: Radius.circular(20)),
        border: isDesktop
            ? Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)
            : null,
        boxShadow: isDesktop
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                )
              ]
            : null,
      ),
      child: Column(
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
          // Modal Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0060A9), Color(0xFF00A8E1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.hub_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Store Connectors Hub',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Automate grocery inventory sync from Costco & Amazon purchases',
                        style: TextStyle(fontSize: 12, color: AppColors.muted(context)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.store_rounded, size: 18),
                text: 'Connected Stores',
              ),
              Tab(
                icon: Icon(Icons.receipt_long_rounded, size: 18),
                text: 'Purchase Order History',
              ),
            ],
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildConnectedStoresTab(context, vm, isDark),
                _buildOrderHistoryTab(context, vm, isDark),
              ],
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

  Widget _buildConnectedStoresTab(BuildContext context, MainViewModel vm, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Costco Card
        _buildStoreCard(
          context: context,
          vm: vm,
          isDark: isDark,
          storeName: 'Costco Wholesale',
          storeType: StoreType.costco,
          iconEmoji: '🛒',
          brandColor: const Color(0xFF0060A9),
          config: vm.costcoConfig,
          description: 'Sync warehouse purchases, 2-Day delivery orders, and bulk Kirkland signature food items.',
          onConnect: () => _showCostcoConnectDialog(context, vm),
          onDisconnect: () => vm.disconnectCostco(),
          onSync: () => vm.syncCostcoPurchases(),
        ),
        const SizedBox(height: 16),

        // Amazon Fresh Card
        _buildStoreCard(
          context: context,
          vm: vm,
          isDark: isDark,
          storeName: 'Amazon Fresh',
          storeType: StoreType.amazonFresh,
          iconEmoji: '🥬',
          brandColor: const Color(0xFF00A8E1),
          config: vm.amazonFreshConfig,
          description: 'Import fresh produce, South Indian Dosa/Idli batters, dairy, and household grocery deliveries.',
          onConnect: () => _showAmazonConnectDialog(context, vm, StoreType.amazonFresh),
          onDisconnect: () => vm.disconnectAmazon(StoreType.amazonFresh),
          onSync: () => vm.syncAmazonPurchases(),
        ),
        const SizedBox(height: 16),

        // Amazon Whole Foods Market Card
        _buildStoreCard(
          context: context,
          vm: vm,
          isDark: isDark,
          storeName: 'Whole Foods Market (Amazon)',
          storeType: StoreType.amazonWholeFoods,
          iconEmoji: '🥑',
          brandColor: const Color(0xFF006747),
          config: vm.amazonWholeFoodsConfig,
          description: 'Fetch organic pantry essentials, hummus, Mediterranean pita breads, and specialty ingredients.',
          onConnect: () => _showAmazonConnectDialog(context, vm, StoreType.amazonWholeFoods),
          onDisconnect: () => vm.disconnectAmazon(StoreType.amazonWholeFoods),
          onSync: () => vm.syncAmazonPurchases(),
        ),
      ],
    );
  }

  Widget _buildStoreCard({
    required BuildContext context,
    required MainViewModel vm,
    required bool isDark,
    required String storeName,
    required StoreType storeType,
    required String iconEmoji,
    required Color brandColor,
    required StoreAccountConfig config,
    required String description,
    required VoidCallback onConnect,
    required VoidCallback onDisconnect,
    required VoidCallback onSync,
  }) {
    final isConnected = config.isConnected;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConnected ? brandColor.withOpacity(0.5) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isConnected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: brandColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: brandColor.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(iconEmoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          storeName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isConnected
                                ? AppColors.primary.withOpacity(0.2)
                                : (isDark ? Colors.white10 : Colors.black12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isConnected ? Icons.check_circle_rounded : Icons.circle_outlined,
                                size: 12,
                                color: isConnected ? AppColors.primaryLight : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isConnected ? 'CONNECTED' : 'NOT LINKED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isConnected ? AppColors.primaryLight : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              if (isConnected && config.lastSyncTime != null) ...[
                const Icon(Icons.sync_rounded, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(
                  'Last synced: ${_formatDate(config.lastSyncTime!)}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const Spacer(),
              ] else ...[
                const Spacer(),
              ],
              if (isConnected) ...[
                OutlinedButton.icon(
                  onPressed: vm.isSyncingStore ? null : onSync,
                  icon: vm.isSyncingStore
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Sync Purchases', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: onDisconnect,
                  style: TextButton.styleFrom(foregroundColor: AppColors.roseAlert),
                  child: const Text('Disconnect', style: TextStyle(fontSize: 12)),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: onConnect,
                  icon: const Icon(Icons.link_rounded, size: 16),
                  label: Text('Connect $storeName', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistoryTab(BuildContext context, MainViewModel vm, bool isDark) {
    final allOrders = [...vm.costcoOrders, ...vm.amazonOrders];
    allOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

    if (allOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'No Store Orders Synced Yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Connect your Costco or Amazon accounts in the "Connected Stores" tab to import orders.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(0),
              child: const Text('Go to Connected Stores'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: allOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (ctx, idx) {
        final order = allOrders[idx];
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: ExpansionTile(
            shape: const Border(),
            leading: Text(order.store.iconEmoji, style: const TextStyle(fontSize: 24)),
            title: Row(
              children: [
                Text(
                  order.store.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(width: 8),
                Text(
                  '#${order.orderId}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
            subtitle: Text(
              '${_formatDate(order.orderDate)} • \$${order.totalAmount.toStringAsFixed(2)} • ${order.items.length} items',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    ...order.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(item.category.iconEmoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              '${item.quantity.toStringAsFixed(0)} ${item.unit}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '\$${item.estimatedCost.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            vm.importStoreOrderToPantry(order);
                          },
                          icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
                          label: const Text('Import Items to Pantry Inventory', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCostcoConnectDialog(BuildContext context, MainViewModel vm) {
    final membershipCtrl = TextEditingController(text: '883920194821');
    final emailCtrl = TextEditingController(text: 'kiran.kashikar@example.com');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Text('🛒 ', style: TextStyle(fontSize: 22)),
              Text('Connect Costco Membership', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your 12-digit Costco membership number to synchronize warehouse receipts and 2-Day grocery orders.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: membershipCtrl,
                decoration: const InputDecoration(
                  labelText: 'Membership Number',
                  prefixIcon: Icon(Icons.credit_card_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Costco Account Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                vm.connectCostco(membershipCtrl.text.trim(), emailCtrl.text.trim());
              },
              child: const Text('Link & Sync'),
            ),
          ],
        );
      },
    );
  }

  void _showAmazonConnectDialog(BuildContext context, MainViewModel vm, StoreType storeType) {
    final emailCtrl = TextEditingController(text: 'kiran.kashikar@example.com');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Text(storeType.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text('Link ${storeType.displayName}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Connect your Amazon account to automatically pull recent ${storeType.displayName} purchase history.',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Amazon Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                vm.connectAmazon(emailCtrl.text.trim(), storeType);
              },
              child: const Text('Authorize & Sync'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
