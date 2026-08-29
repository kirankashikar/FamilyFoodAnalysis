import 'package:flutter_test/flutter_test.dart';
import 'package:family_food_analysis/data/models/store_connector_models.dart';
import 'package:family_food_analysis/data/models/grocery_item.dart';
import 'package:family_food_analysis/data/services/costco_connector_service.dart';
import 'package:family_food_analysis/data/services/amazon_connector_service.dart';

void main() {
  group('Costco Wholesale Connector Tests', () {
    late CostcoConnectorService costcoService;

    setUp(() {
      costcoService = CostcoConnectorService();
    });

    test('Connects Costco account successfully with valid membership number', () async {
      expect(costcoService.config.isConnected, isFalse);

      final result = await costcoService.connectAccount(
        membershipNumber: '883920194821',
        accountEmail: 'kiran@example.com',
      );

      expect(result.isConnected, isTrue);
      expect(result.store, equals(StoreType.costco));
      expect(result.membershipNumber, equals('883920194821'));
      expect(costcoService.config.lastSyncTime, isNotNull);
    });

    test('Fails Costco connection with invalid membership number', () async {
      final result = await costcoService.connectAccount(
        membershipNumber: '123', // < 6 digits
        accountEmail: 'kiran@example.com',
      );

      expect(result.isConnected, isFalse);
      expect(result.status, equals(StoreConnectionStatus.error));
    });

    test('Fetches Costco purchase history and parses bulk line items accurately', () async {
      await costcoService.connectAccount(
        membershipNumber: '883920194821',
        accountEmail: 'kiran@example.com',
      );

      final orders = await costcoService.fetchPurchaseHistory();
      expect(orders.isNotEmpty, isTrue);
      expect(orders.length, greaterThanOrEqualTo(2));

      final warehouseOrder = orders.first;
      expect(warehouseOrder.orderId, startsWith('COSTCO-WH'));
      expect(warehouseOrder.items.length, greaterThanOrEqualTo(5));

      // Verify bulk items normalization
      final eggs = warehouseOrder.items.firstWhere((it) => it.name.contains('Eggs'));
      expect(eggs.quantity, equals(24));
      expect(eggs.unit, equals('count'));
      expect(eggs.category, equals(GroceryCategory.proteinsAndMeat));

      final oliveOil = warehouseOrder.items.firstWhere((it) => it.name.contains('Olive Oil'));
      expect(oliveOil.quantity, equals(2.0));
      expect(oliveOil.unit, equals('liters'));
      expect(oliveOil.category, equals(GroceryCategory.spicesAndOils));

      final spinach = warehouseOrder.items.firstWhere((it) => it.name.contains('Spinach'));
      expect(spinach.isExpiringSoon, isTrue);
    });
  });

  group('Amazon Fresh & Whole Foods Connector Tests', () {
    late AmazonConnectorService amazonService;

    setUp(() {
      amazonService = AmazonConnectorService();
    });

    test('Connects Amazon Fresh and Whole Foods accounts independently', () async {
      final freshConfig = await amazonService.connectAmazonAccount(
        accountEmail: 'kiran@example.com',
        storeType: StoreType.amazonFresh,
      );
      expect(freshConfig.isConnected, isTrue);
      expect(amazonService.freshConfig.isConnected, isTrue);
      expect(amazonService.wholeFoodsConfig.isConnected, isFalse);

      final wfConfig = await amazonService.connectAmazonAccount(
        accountEmail: 'kiran@example.com',
        storeType: StoreType.amazonWholeFoods,
      );
      expect(wfConfig.isConnected, isTrue);
      expect(amazonService.wholeFoodsConfig.isConnected, isTrue);
    });

    test('Fetches Amazon purchase orders with ethnic foods and organic groceries', () async {
      await amazonService.connectAmazonAccount(
        accountEmail: 'kiran@example.com',
        storeType: StoreType.amazonFresh,
      );

      final orders = await amazonService.fetchPurchaseHistory();
      expect(orders.isNotEmpty, isTrue);

      final freshOrder = orders.firstWhere((o) => o.store == StoreType.amazonFresh);
      expect(freshOrder.items.any((it) => it.name.contains('Dosa & Idli Batter')), isTrue);
      expect(freshOrder.items.any((it) => it.name.contains('Hummus')), isTrue);
      expect(freshOrder.items.any((it) => it.name.contains('Whole Milk')), isTrue);

      final wfOrder = orders.firstWhere((o) => o.store == StoreType.amazonWholeFoods);
      expect(wfOrder.items.any((it) => it.name.contains('Chickpeas')), isTrue);
      expect(wfOrder.items.any((it) => it.name.contains('Pita')), isTrue);
    });
  });
}
