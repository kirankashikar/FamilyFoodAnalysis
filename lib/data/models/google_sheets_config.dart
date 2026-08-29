import 'dart:convert';

class GoogleSheetsConfig {
  final String spreadsheetId;
  final String inventorySheetName;
  final String intakeSheetName;
  final String recipesSheetName;
  final bool isAutoSyncEnabled;
  final DateTime? lastSyncTime;
  final String syncStatus;
  final String? googleAccountEmail;

  GoogleSheetsConfig({
    required this.spreadsheetId,
    this.inventorySheetName = 'PantryInventory',
    this.intakeSheetName = 'DailyIntakeLogs',
    this.recipesSheetName = 'SavedRecipes',
    this.isAutoSyncEnabled = true,
    this.lastSyncTime,
    this.syncStatus = 'Connected (Cloud & Local)',
    this.googleAccountEmail,
  });

  bool get isConfigured => spreadsheetId.isNotEmpty;

  String get sheetsUrl {
    if (spreadsheetId.isEmpty) return '';
    if (spreadsheetId.startsWith('http')) return spreadsheetId;
    return 'https://docs.google.com/spreadsheets/d/$spreadsheetId/edit';
  }

  GoogleSheetsConfig copyWith({
    String? spreadsheetId,
    String? inventorySheetName,
    String? intakeSheetName,
    String? recipesSheetName,
    bool? isAutoSyncEnabled,
    DateTime? lastSyncTime,
    String? syncStatus,
    String? googleAccountEmail,
  }) {
    return GoogleSheetsConfig(
      spreadsheetId: spreadsheetId ?? this.spreadsheetId,
      inventorySheetName: inventorySheetName ?? this.inventorySheetName,
      intakeSheetName: intakeSheetName ?? this.intakeSheetName,
      recipesSheetName: recipesSheetName ?? this.recipesSheetName,
      isAutoSyncEnabled: isAutoSyncEnabled ?? this.isAutoSyncEnabled,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      syncStatus: syncStatus ?? this.syncStatus,
      googleAccountEmail: googleAccountEmail ?? this.googleAccountEmail,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'spreadsheetId': spreadsheetId,
      'inventorySheetName': inventorySheetName,
      'intakeSheetName': intakeSheetName,
      'recipesSheetName': recipesSheetName,
      'isAutoSyncEnabled': isAutoSyncEnabled,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'syncStatus': syncStatus,
      'googleAccountEmail': googleAccountEmail,
    };
  }

  factory GoogleSheetsConfig.fromMap(Map<String, dynamic> map) {
    return GoogleSheetsConfig(
      spreadsheetId: map['spreadsheetId'] ?? '1A2B3C4D_FamilyFoodDatabase_Sample',
      inventorySheetName: map['inventorySheetName'] ?? 'PantryInventory',
      intakeSheetName: map['intakeSheetName'] ?? 'DailyIntakeLogs',
      recipesSheetName: map['recipesSheetName'] ?? 'SavedRecipes',
      isAutoSyncEnabled: map['isAutoSyncEnabled'] ?? true,
      lastSyncTime: map['lastSyncTime'] != null
          ? DateTime.parse(map['lastSyncTime'])
          : DateTime.now().subtract(const Duration(minutes: 12)),
      syncStatus: map['syncStatus'] ?? 'Connected (Active)',
      googleAccountEmail: map['googleAccountEmail'] ?? 'user@gmail.com',
    );
  }

  String toJson() => json.encode(toMap());
  factory GoogleSheetsConfig.fromJson(String source) => GoogleSheetsConfig.fromMap(json.decode(source));
}
