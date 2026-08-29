import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/auth_service.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/food_database_service.dart';
import 'data/services/google_sheets_service.dart';
import 'data/services/ocr_bill_scanner_service.dart';
import 'data/repositories/app_repositories.dart';
import 'ui/theme/app_theme.dart';
import 'ui/view_models/main_view_model.dart';
import 'ui/core/widgets/responsive_scaffold.dart';
import 'ui/features/auth/views/login_view.dart';
import 'ui/features/dashboard/views/dashboard_view.dart';
import 'ui/features/inventory/views/inventory_view.dart';
import 'ui/features/intake/views/intake_view.dart';
import 'ui/features/recipes/views/recipes_view.dart';
import 'ui/features/profile/views/profile_and_goals_view.dart';
import 'ui/features/recommendations/views/recommendations_view.dart';
import 'ui/features/sheets_sync/views/sheets_sync_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStorage = LocalStorageService();
  final ocrService = OcrBillScannerService();
  final authService = AuthService();
  final foodDb = FoodDatabaseService();
  final sheetsService = GoogleSheetsService();

  final inventoryRepo = InventoryRepository(
    localStorage: localStorage,
    ocrService: ocrService,
  );
  final intakeRepo = IntakeRepository(localStorage: localStorage);
  final recipeRepo = RecipeRepository(localStorage: localStorage);

  await Future.wait([
    inventoryRepo.init(),
    intakeRepo.init(),
    recipeRepo.init(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MainViewModel(
            authService: authService,
            inventoryRepo: inventoryRepo,
            intakeRepo: intakeRepo,
            recipeRepo: recipeRepo,
            foodDb: foodDb,
            sheetsService: sheetsService,
            ocrService: ocrService,
          ),
        ),
      ],
      child: const FamilyFoodAnalysisApp(),
    ),
  );
}

class FamilyFoodAnalysisApp extends StatelessWidget {
  const FamilyFoodAnalysisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FamilyFood - Grocery & Nutrition Analysis',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const AppHome(),
    );
  }
}

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();

    if (!vm.isAuthenticated) {
      return const LoginView();
    }

    final pages = [
      const DashboardView(),
      const InventoryView(),
      const IntakeView(),
      const RecipesView(),
      const ProfileAndGoalsView(),
      const RecommendationsView(),
      const SheetsSyncView(),
    ];

    return ResponsiveScaffold(
      body: IndexedStack(
        index: vm.selectedTabIndex.clamp(0, pages.length - 1),
        children: pages,
      ),
    );
  }
}
