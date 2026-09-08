# 🥗 FamilyFood - Grocery & Nutrition Analysis Platform

A modern cross-platform **Flutter** application (Responsive for Web & Mobile) designed for comprehensive family food and grocery inventory tracking, cultural dietary alignment, BMI vital statistics, and proactive nutritional recommendations with automated **Google Sheets synchronization**.

---

## 🌟 Key Features

### 1. 🔐 Multi-Provider Authentication & Session Management
- **Google OAuth Sign-In** with seamless Drive & Google Sheets permissions.
- **GitHub OAuth Sign-In** for developers and personal tracking.
- **Instant Guest / Demo Mode** with pre-seeded realistic family data.

### 2. 🧾 Grocery Bill OCR Scanner & Pantry Inventory
- One unified "Add Grocery Bill" flow with four ways in: on-device camera/gallery OCR, PDF invoice scanning, sharing a forwarded receipt email in from your Mail app, or pulling purchase history from connected Costco/Amazon accounts.
- Native, on-device text recognition (Google ML Kit) — receipts are read directly on the phone, no cloud round-trip.
- Intelligent receipt line-item parsing: item classification, quantity estimation, and smart shelf-life expiration calculation.
- Live pantry inventory with low-stock warnings and expiring-soon alerts (e.g. fresh spinach expiring in 2-3 days).

### 3. 📊 Automated Google Sheets Database Sync
- Seamless two-way integration with user's personal Google Sheets (`PantryInventory` and `DailyIntakeLogs` tabs).
- Full RFC 4180 CSV export and import capabilities.
- Live raw data preview inside the app.

### 4. 🥞 Daily Food Intake & Nutrient Tracking
- **Snap a Meal**: photograph your plate and get on-device food-label suggestions matched against the food database — confirm the dish, meal slot (breakfast/lunch/dinner/snack), and servings to log it in one tap.
- Searchable database featuring rich ethnic and international cuisines:
  - **South Indian**: Masala Dosa, Steamed Idli, Vegetable Sambar, Curd Rice
  - **Mediterranean & Middle Eastern**: Classic Hummus, Whole Wheat Pita, Greek Salad, Falafel
  - **North Indian**: Yellow Dal Tadka, Phulkas / Roti, Palak Paneer, Rajma Chawal
  - **East Asian, Latin American & Western Balanced**
- Real-time macronutrient breakdown: Calories, Protein, Carbohydrates, Fats, Fiber, Sodium, and Potassium.

### 5. 🎯 BMI, Ethnicity Presets & Health Goals Engine
- **BMI Assessment**: Height, Weight, Age, Gender, Activity Level, BMR (Mifflin-St Jeor) and TDEE.
- **Cultural Diet Presets**: Accurately tailors default food vocabulary and flavor profiles for South Asian (Indian), Mediterranean, Middle Eastern, East Asian, Latin American, and Western cuisines.
- **Dietary Lifestyle & Allergens**: Vegetarian, Vegan, Keto, Gluten-Free, Halal, Nut allergies.
- **Health Goals**: Weight Loss, Muscle Gain, Blood Sugar / Diabetic-Friendly, Heart Health / Low Sodium, Everyday Vitality, Athletic Endurance.

### 6. 🍲 Prepared Dishes & Custom Recipe Catalog
- Catalog of favorite and frequently prepared home dishes.
- Instant 1-click recipe-to-intake logger.
- Custom recipe builder comparing required ingredients against pantry stock.

### 7. 💡 AI-Powered Nutrition & Modification Suggestions
- Calculates nutritional gaps between logged meals and health goals.
- Suggests intelligent food swaps (e.g. swapping white rice for foxtail millet or cauliflower rice for diabetic management; adding paneer/tofu for muscle gain).
- Flags excessive sodium intake and offers culinary alternatives (roasted cumin, lemon juice, fresh herbs).

---

## 🏛️ Architecture

Built following clean MVVM (Model-View-ViewModel) and layered Flutter design:

```text
lib/
├── data/
│   ├── models/            # UserProfile, GroceryItem, FoodItem, Recipe, NutritionGoals, GoogleSheetsConfig
│   ├── services/          # AuthService, GoogleSheetsService, OcrBillScannerService, FoodRecognitionService, FoodDatabaseService, LocalStorageService
│   └── repositories/      # InventoryRepository, IntakeRepository, RecipeRepository
├── domain/
│   └── services/          # BmiCalculator, RecommendationEngine, NutritionAnalytics
├── ui/
│   ├── core/              # ResponsiveScaffold, GlassCard, ImageCapture, MacroDonutChart, NutrientProgressBar
│   ├── theme/             # AppTheme (bright/light default, dark mode toggle)
│   ├── view_models/       # MainViewModel (Central ChangeNotifier coordinator)
│   └── features/          # Dashboard, Inventory, Intake, Recipes, Profile & Goals, Recommendations, SheetsSync, Auth
└── main.dart
```

---

## 🚀 Running the Project

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0+)

### Setup
```bash
# Clone the repository
git clone https://github.com/kirankashikar/FamilyFoodAnalysis.git
cd FamilyFoodAnalysis

# Install dependencies
flutter pub get

# Run on Chrome (Web)
flutter run -d chrome

# Run on Mobile (Android / iOS / Windows Desktop)
flutter run
```

### 📱 One-Time Mobile Setup (Camera OCR & Food Recognition)

This repo ships web-first (no `android/`/`ios/` folders are checked in), so the
native on-device OCR / PDF scanning / food-photo recognition features need one
local, one-time setup step before your first mobile build:

```bash
# Safe: only (re)generates platform folders, never touches lib/
flutter create .
```

Then add the camera/photo permissions the new plugins need:

**Android** — in `android/app/src/main/AndroidManifest.xml`, inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
```
And in `android/app/build.gradle`, make sure `minSdkVersion` is at least 21
(required by ML Kit).

**iOS** — in `ios/Runner/Info.plist`, inside the top-level `<dict>`:
```xml
<key>NSCameraUsageDescription</key>
<string>FamilyFood uses the camera to scan grocery receipts and meal photos.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>FamilyFood needs photo library access to pick receipt and meal photos.</string>
```

On-device OCR/labeling (ML Kit) and PDF rendering only ship native
Android/iOS plugin implementations, so these features are unavailable on the
web build — the app falls back to manual text entry / sample receipts there.

#### Extra step for "Forward from Email" (share-to-app)

**Android** — add these inside the `<activity>` block in
`android/app/src/main/AndroidManifest.xml` (and set that activity's
`android:launchMode="singleTask"`):
```xml
<intent-filter>
    <action android:name="android.intent.action.SEND" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="image/*" />
</intent-filter>
<intent-filter>
    <action android:name="android.intent.action.SEND" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="application/pdf" />
</intent-filter>
```

**iOS** is significantly more involved: `receive_sharing_intent` requires
adding a separate Share Extension target in Xcode (plus an App Group shared
between it and the Runner app). This can't be done with simple file edits —
follow the plugin's own iOS setup guide before this works on iPhone/iPad:
https://pub.dev/packages/receive_sharing_intent. Camera/gallery OCR and PDF
scanning work on iOS without this extra step; only the share-to-app path
needs it.

---

## 🧪 Testing

```bash
# Run unit tests
flutter test
```
