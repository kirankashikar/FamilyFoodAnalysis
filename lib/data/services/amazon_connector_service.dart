import '../models/store_connector_models.dart';
import '../models/grocery_item.dart';

class AmazonConnectorService {
  StoreAccountConfig _freshConfig = StoreAccountConfig(
    store: StoreType.amazonFresh,
    status: StoreConnectionStatus.disconnected,
  );

  StoreAccountConfig _wholeFoodsConfig = StoreAccountConfig(
    store: StoreType.amazonWholeFoods,
    status: StoreConnectionStatus.disconnected,
  );

  StoreAccountConfig get freshConfig => _freshConfig;
  StoreAccountConfig get wholeFoodsConfig => _wholeFoodsConfig;

  /// Connects Amazon account with email and 2FA auth token
  Future<StoreAccountConfig> connectAmazonAccount({
    required String accountEmail,
    required StoreType storeType,
    String? otpCode,
  }) async {
    if (storeType == StoreType.amazonFresh) {
      _freshConfig = _freshConfig.copyWith(
        status: StoreConnectionStatus.connecting,
        accountEmail: accountEmail,
        syncMessage: 'Connecting to Amazon Fresh Grocery API...',
      );
    } else {
      _wholeFoodsConfig = _wholeFoodsConfig.copyWith(
        status: StoreConnectionStatus.connecting,
        accountEmail: accountEmail,
        syncMessage: 'Connecting to Amazon Whole Foods Market...',
      );
    }

    await Future.delayed(const Duration(milliseconds: 700));

    if (!accountEmail.contains('@')) {
      final err = StoreAccountConfig(
        store: storeType,
        status: StoreConnectionStatus.error,
        syncMessage: 'Invalid Amazon account email address.',
      );
      if (storeType == StoreType.amazonFresh) {
        _freshConfig = err;
      } else {
        _wholeFoodsConfig = err;
      }
      return err;
    }

    final updated = StoreAccountConfig(
      store: storeType,
      status: StoreConnectionStatus.connected,
      accountEmail: accountEmail,
      lastSyncTime: DateTime.now(),
      syncMessage: 'Active Amazon Grocery Session ($accountEmail)',
    );

    if (storeType == StoreType.amazonFresh) {
      _freshConfig = updated;
    } else {
      _wholeFoodsConfig = updated;
    }

    return updated;
  }

  /// Disconnects the specified Amazon service
  void disconnect(StoreType storeType) {
    if (storeType == StoreType.amazonFresh) {
      _freshConfig = StoreAccountConfig(
        store: StoreType.amazonFresh,
        status: StoreConnectionStatus.disconnected,
      );
    } else {
      _wholeFoodsConfig = StoreAccountConfig(
        store: StoreType.amazonWholeFoods,
        status: StoreConnectionStatus.disconnected,
      );
    }
  }

  /// Fetches recent Amazon Fresh and Whole Foods purchase orders
  Future<List<StoreOrder>> fetchPurchaseHistory() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now();

    return [
      StoreOrder(
        orderId: 'AMZN-FRESH-114-8920182',
        store: StoreType.amazonFresh,
        orderDate: now.subtract(const Duration(days: 1)),
        totalAmount: 43.82,
        deliveryStatus: 'Delivered (Doorstep Delivery)',
        isImportedToPantry: true,
        items: [
          GroceryItem(
            id: 'amzn_fresh_01',
            name: 'Deep Authentic South Indian Dosa & Idli Batter',
            category: GroceryCategory.grainsAndPulses,
            quantity: 32,
            unit: 'oz',
            remainingQuantity: 32,
            estimatedCost: 5.49,
            purchaseDate: now.subtract(const Duration(days: 1)),
            expiryDate: now.add(const Duration(days: 10)),
            storeName: 'Amazon Fresh',
            isSyncedToSheets: true,
          ),
          GroceryItem(
            id: 'amzn_fresh_02',
            name: '365 by Whole Foods Market Organic Classic Hummus',
            category: GroceryCategory.condimentsAndSauces,
            quantity: 8,
            unit: 'oz',
            remainingQuantity: 8,
            estimatedCost: 3.29,
            purchaseDate: now.subtract(const Duration(days: 1)),
            expiryDate: now.add(const Duration(days: 14)),
            storeName: 'Amazon Fresh',
            isSyncedToSheets: true,
          ),
          GroceryItem(
            id: 'amzn_fresh_03',
            name: 'Organic Whole Milk (1 Gallon)',
            category: GroceryCategory.dairyAndAlternatives,
            quantity: 1,
            unit: 'gallon',
            remainingQuantity: 0.9,
            estimatedCost: 4.89,
            purchaseDate: now.subtract(const Duration(days: 1)),
            expiryDate: now.add(const Duration(days: 9)),
            storeName: 'Amazon Fresh',
            isSyncedToSheets: true,
          ),
          GroceryItem(
            id: 'amzn_fresh_04',
            name: 'Organic Persian Cucumbers (1 lb bag)',
            category: GroceryCategory.produce,
            quantity: 1,
            unit: 'lbs',
            remainingQuantity: 1,
            estimatedCost: 2.99,
            purchaseDate: now.subtract(const Duration(days: 1)),
            expiryDate: now.add(const Duration(days: 5)),
            storeName: 'Amazon Fresh',
            isSyncedToSheets: true,
          ),
          GroceryItem(
            id: 'amzn_fresh_05',
            name: '365 by Whole Foods Organic Old Fashioned Rolled Oats',
            category: GroceryCategory.grainsAndPulses,
            quantity: 32,
            unit: 'oz',
            remainingQuantity: 32,
            estimatedCost: 4.29,
            purchaseDate: now.subtract(const Duration(days: 1)),
            expiryDate: now.add(const Duration(days: 280)),
            storeName: 'Amazon Fresh',
            isSyncedToSheets: true,
          ),
        ],
      ),
      StoreOrder(
        orderId: 'AMZN-WF-112-4029104',
        store: StoreType.amazonWholeFoods,
        orderDate: now.subtract(const Duration(days: 6)),
        totalAmount: 37.15,
        deliveryStatus: 'Delivered (Whole Foods Pickup)',
        isImportedToPantry: false,
        items: [
          GroceryItem(
            id: 'amzn_wf_01',
            name: '365 Organic Garbanzo Chickpeas (3-pack cans)',
            category: GroceryCategory.proteinsAndMeat,
            quantity: 3,
            unit: 'cans',
            remainingQuantity: 3,
            estimatedCost: 4.50,
            purchaseDate: now.subtract(const Duration(days: 6)),
            expiryDate: now.add(const Duration(days: 700)),
            storeName: 'Whole Foods Market',
            isSyncedToSheets: true,
          ),
          GroceryItem(
            id: 'amzn_wf_02',
            name: 'Organic Whole Wheat Pita Bread (6-pack)',
            category: GroceryCategory.snacksAndBaking,
            quantity: 6,
            unit: 'count',
            remainingQuantity: 5,
            estimatedCost: 3.99,
            purchaseDate: now.subtract(const Duration(days: 6)),
            expiryDate: now.add(const Duration(days: 6)),
            storeName: 'Whole Foods Market',
            isSyncedToSheets: true,
          ),
          GroceryItem(
            id: 'amzn_wf_03',
            name: 'Organic Medjool Dates 1lb Tub',
            category: GroceryCategory.snacksAndBaking,
            quantity: 1,
            unit: 'lbs',
            remainingQuantity: 0.9,
            estimatedCost: 8.99,
            purchaseDate: now.subtract(const Duration(days: 6)),
            expiryDate: now.add(const Duration(days: 120)),
            storeName: 'Whole Foods Market',
            isSyncedToSheets: true,
          ),
        ],
      ),
    ];
  }
}
