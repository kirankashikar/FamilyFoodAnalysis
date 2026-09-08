import '../models/store_connector_models.dart';
import '../models/grocery_item.dart';

class CostcoConnectorService {
  StoreAccountConfig _config = StoreAccountConfig(
    store: StoreType.costco,
    status: StoreConnectionStatus.disconnected,
  );

  StoreAccountConfig get config => _config;

  /// Connects to Costco account using membership number and email
  Future<StoreAccountConfig> connectAccount({
    required String membershipNumber,
    required String accountEmail,
    String? password,
  }) async {
    _config = _config.copyWith(
      status: StoreConnectionStatus.connecting,
      membershipNumber: membershipNumber,
      accountEmail: accountEmail,
      syncMessage: 'Authenticating with Costco Wholesale SSO...',
    );

    // Simulate authentication roundtrip
    await Future.delayed(const Duration(milliseconds: 750));

    if (membershipNumber.trim().length < 6) {
      _config = _config.copyWith(
        status: StoreConnectionStatus.error,
        syncMessage: 'Invalid Costco membership number. Please enter at least 6 digits.',
      );
      return _config;
    }

    _config = _config.copyWith(
      status: StoreConnectionStatus.connected,
      lastSyncTime: DateTime.now(),
      syncMessage: 'Connected to Costco Membership #$membershipNumber',
    );

    return _config;
  }

  /// Disconnects the Costco account
  void disconnect() {
    _config = StoreAccountConfig(
      store: StoreType.costco,
      status: StoreConnectionStatus.disconnected,
    );
  }

  /// Fetches recent Costco order history and normalizes into GroceryItem line-items
  Future<List<StoreOrder>> fetchPurchaseHistory() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now();

    return [
      StoreOrder(
        orderId: 'COSTCO-WH-8849201',
        store: StoreType.costco,
        orderDate: now.subtract(const Duration(days: 2)),
        totalAmount: 118.47,
        deliveryStatus: 'Completed (Warehouse Pickup/Receipt)',
        isImportedToPantry: true,
        items: [
          GroceryItem(
            id: 'costco_item_01',
            name: 'Kirkland Signature Organic Pasture-Raised Eggs',
            category: GroceryCategory.proteinsAndMeat,
            quantity: 24,
            unit: 'count',
            remainingQuantity: 22,
            estimatedCost: 7.99,
            purchaseDate: now.subtract(const Duration(days: 2)),
            expiryDate: now.add(const Duration(days: 28)),
            storeName: 'Costco Wholesale',
            isSyncedToSheets: true,
          ),
          GroceryItem(
            id: 'costco_item_02',
            name: 'Kirkland Signature Organic Greek Whole Milk Yogurt',
            category: GroceryCategory.dairyAndAlternatives,
            quantity: 48,
            unit: 'oz',
            remainingQuantity: 40,
            estimatedCost: 6.49,
            purchaseDate: now.subtract(const Duration(days: 2)),
            expiryDate: now.add(const Duration(days: 18)),
            storeName: 'Costco Wholesale',
            isSyncedToSheets: true,
          ),
          GroceryItem(
            id: 'costco_item_03',
            name: 'Earthbound Farm Organic Baby Spinach',
            category: GroceryCategory.produce,
            quantity: 16,
            unit: 'oz',
            remainingQuantity: 14,
            estimatedCost: 4.99,
            purchaseDate: now.subtract(const Duration(days: 2)),
            expiryDate: now.add(const Duration(days: 4)), // Expiring soon!
            storeName: 'Costco Wholesale',
            isSyncedToSheets: true,
          ),
          GroceryItem(
            id: 'costco_item_04',
            name: 'Kirkland Signature Organic Extra Virgin Olive Oil',
            category: GroceryCategory.spicesAndOils,
            quantity: 2.0,
            unit: 'liters',
            remainingQuantity: 1.9,
            estimatedCost: 21.99,
            purchaseDate: now.subtract(const Duration(days: 2)),
            expiryDate: now.add(const Duration(days: 360)),
            storeName: 'Costco Wholesale',
            isSyncedToSheets: true,
          ),
          GroceryItem(
            id: 'costco_item_05',
            name: 'Kirkland Signature Organic Whole White Quinoa',
            category: GroceryCategory.grainsAndPulses,
            quantity: 4.5,
            unit: 'lbs',
            remainingQuantity: 4.5,
            estimatedCost: 10.99,
            purchaseDate: now.subtract(const Duration(days: 2)),
            expiryDate: now.add(const Duration(days: 400)),
            storeName: 'Costco Wholesale',
            isSyncedToSheets: true,
          ),
          GroceryItem(
            id: 'costco_item_06',
            name: 'Kirkland Signature Supreme Whole Raw Almonds',
            category: GroceryCategory.snacksAndBaking,
            quantity: 3.0,
            unit: 'lbs',
            remainingQuantity: 2.8,
            estimatedCost: 12.99,
            purchaseDate: now.subtract(const Duration(days: 2)),
            expiryDate: now.add(const Duration(days: 240)),
            storeName: 'Costco Wholesale',
            isSyncedToSheets: true,
          ),
        ],
      ),
      StoreOrder(
        orderId: 'COSTCO-2DAY-4910283',
        store: StoreType.costco,
        orderDate: now.subtract(const Duration(days: 12)),
        totalAmount: 84.50,
        deliveryStatus: 'Delivered (Costco 2-Day)',
        isImportedToPantry: false,
        items: [
          GroceryItem(
            id: 'costco_item_07',
            name: 'Wild Planet Wild Sockeye Salmon Cans (6-pack)',
            category: GroceryCategory.proteinsAndMeat,
            quantity: 6,
            unit: 'cans',
            remainingQuantity: 6,
            estimatedCost: 19.99,
            purchaseDate: now.subtract(const Duration(days: 12)),
            expiryDate: now.add(const Duration(days: 500)),
            storeName: 'Costco 2-Day Delivery',
            isSyncedToSheets: true,
          ),
          GroceryItem(
            id: 'costco_item_08',
            name: 'Organic Hass Avocados (6-pack)',
            category: GroceryCategory.produce,
            quantity: 6,
            unit: 'count',
            remainingQuantity: 3,
            estimatedCost: 8.99,
            purchaseDate: now.subtract(const Duration(days: 12)),
            expiryDate: now.add(const Duration(days: 2)),
            storeName: 'Costco 2-Day Delivery',
            isSyncedToSheets: true,
          ),
          GroceryItem(
            id: 'costco_item_09',
            name: 'Organic Chia Seeds 3lb Bag',
            category: GroceryCategory.snacksAndBaking,
            quantity: 3.0,
            unit: 'lbs',
            remainingQuantity: 2.9,
            estimatedCost: 9.49,
            purchaseDate: now.subtract(const Duration(days: 12)),
            expiryDate: now.add(const Duration(days: 365)),
            storeName: 'Costco 2-Day Delivery',
            isSyncedToSheets: true,
          ),
        ],
      ),
    ];
  }
}
