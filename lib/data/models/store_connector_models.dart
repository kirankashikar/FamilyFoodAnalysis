import 'dart:convert';
import 'grocery_item.dart';

enum StoreType {
  costco,
  amazonFresh,
  amazonWholeFoods,
  amazonStandard,
}

extension StoreTypeExtension on StoreType {
  String get displayName {
    switch (this) {
      case StoreType.costco:
        return 'Costco Wholesale';
      case StoreType.amazonFresh:
        return 'Amazon Fresh';
      case StoreType.amazonWholeFoods:
        return 'Whole Foods Market (Amazon)';
      case StoreType.amazonStandard:
        return 'Amazon.com Grocery';
    }
  }

  String get iconEmoji {
    switch (this) {
      case StoreType.costco:
        return '🛒';
      case StoreType.amazonFresh:
        return '🥬';
      case StoreType.amazonWholeFoods:
        return '🥑';
      case StoreType.amazonStandard:
        return '📦';
    }
  }

  String get logoColorHex {
    switch (this) {
      case StoreType.costco:
        return '#0060A9'; // Costco Blue / Red accent
      case StoreType.amazonFresh:
        return '#00A8E1'; // Amazon Fresh Cyan
      case StoreType.amazonWholeFoods:
        return '#006747'; // Whole Foods Green
      case StoreType.amazonStandard:
        return '#FF9900'; // Amazon Orange
    }
  }
}

enum StoreConnectionStatus {
  disconnected,
  connecting,
  connected,
  authExpired,
  error,
}

class StoreAccountConfig {
  final StoreType store;
  final StoreConnectionStatus status;
  final String? accountEmail;
  final String? membershipNumber;
  final DateTime? lastSyncTime;
  final bool autoImportEnabled;
  final String? syncMessage;

  StoreAccountConfig({
    required this.store,
    this.status = StoreConnectionStatus.disconnected,
    this.accountEmail,
    this.membershipNumber,
    this.lastSyncTime,
    this.autoImportEnabled = true,
    this.syncMessage,
  });

  bool get isConnected => status == StoreConnectionStatus.connected;

  StoreAccountConfig copyWith({
    StoreType? store,
    StoreConnectionStatus? status,
    String? accountEmail,
    String? membershipNumber,
    DateTime? lastSyncTime,
    bool? autoImportEnabled,
    String? syncMessage,
  }) {
    return StoreAccountConfig(
      store: store ?? this.store,
      status: status ?? this.status,
      accountEmail: accountEmail ?? this.accountEmail,
      membershipNumber: membershipNumber ?? this.membershipNumber,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      autoImportEnabled: autoImportEnabled ?? this.autoImportEnabled,
      syncMessage: syncMessage ?? this.syncMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'store': store.name,
      'status': status.name,
      'accountEmail': accountEmail,
      'membershipNumber': membershipNumber,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'autoImportEnabled': autoImportEnabled,
      'syncMessage': syncMessage,
    };
  }

  factory StoreAccountConfig.fromMap(Map<String, dynamic> map) {
    return StoreAccountConfig(
      store: StoreType.values.firstWhere(
        (e) => e.name == map['store'],
        orElse: () => StoreType.costco,
      ),
      status: StoreConnectionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StoreConnectionStatus.disconnected,
      ),
      accountEmail: map['accountEmail'],
      membershipNumber: map['membershipNumber'],
      lastSyncTime: map['lastSyncTime'] != null ? DateTime.tryParse(map['lastSyncTime']) : null,
      autoImportEnabled: map['autoImportEnabled'] ?? true,
      syncMessage: map['syncMessage'],
    );
  }

  String toJson() => json.encode(toMap());
  factory StoreAccountConfig.fromJson(String source) => StoreAccountConfig.fromMap(json.decode(source));
}

class StoreOrder {
  final String orderId;
  final StoreType store;
  final DateTime orderDate;
  final double totalAmount;
  final String deliveryStatus;
  final List<GroceryItem> items;
  final bool isImportedToPantry;

  StoreOrder({
    required this.orderId,
    required this.store,
    required this.orderDate,
    required this.totalAmount,
    required this.deliveryStatus,
    required this.items,
    this.isImportedToPantry = false,
  });

  StoreOrder copyWith({
    String? orderId,
    StoreType? store,
    DateTime? orderDate,
    double? totalAmount,
    String? deliveryStatus,
    List<GroceryItem>? items,
    bool? isImportedToPantry,
  }) {
    return StoreOrder(
      orderId: orderId ?? this.orderId,
      store: store ?? this.store,
      orderDate: orderDate ?? this.orderDate,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      items: items ?? this.items,
      isImportedToPantry: isImportedToPantry ?? this.isImportedToPantry,
    );
  }
}
