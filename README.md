# 🥗 FamilyFood - Grocery & Nutrition Analysis Platform

A modern cross-platform **Flutter** application (Responsive for Web & Mobile) designed for comprehensive family food and grocery inventory tracking, cultural dietary alignment, BMI vital statistics, and proactive nutritional recommendations with automated **Google Sheets synchronization**.

---

## 🌟 Key Features

### 1. 🔐 Multi-Provider Authentication & Session Management
- **Google OAuth Sign-In** with seamless Drive & Google Sheets permissions.
- **GitHub OAuth Sign-In** for developers and personal tracking.
- **Instant Guest / Demo Mode** with pre-seeded realistic family data.

### 2. 🧾 Grocery Bill OCR Scanner & Pantry Inventory
- Upload paper receipts, supermarket bills, or PDF invoices via camera or file picker.
- Intelligent receipt line-item parsing: item classification, quantity estimation, and smart shelf-life expiration calculation.
- Live pantry inventory with low-stock warnings and expiring-soon alerts (e.g. fresh spinach expiring in 2-3 days).

### 3. 📊 Automated Google Sheets Database Sync
- Seamless two-way integration with user's personal Google Sheets (`PantryInventory` and `DailyIntakeLogs` tabs).
- Full RFC 4180 CSV export and import capabilities.
- Live raw data preview inside the app.

### 4. 🥞 Daily Food Intake & Nutrient Tracking
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
│   ├── services/          # AuthService, GoogleSheetsService, OcrBillScannerService, FoodDatabaseService, LocalStorageService
│   └── repositories/      # InventoryRepository, IntakeRepository, RecipeRepository
├── domain/
│   └── services/          # BmiCalculator, RecommendationEngine, NutritionAnalytics
├── ui/
│   ├── core/              # ResponsiveScaffold, GlassCard, MacroDonutChart, NutrientProgressBar
│   ├── theme/             # AppTheme (Curated Dark/Light health-tech styling)
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

---

## 🧪 Testing

```bash
# Run unit tests
flutter test
```
