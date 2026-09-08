import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'data/services/auth_service.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/food_database_service.dart';
import 'data/services/google_sheets_service.dart';
import 'data/services/ocr_bill_scanner_service.dart';
import 'data/services/food_recognition_service.dart';
import 'data/repositories/app_repositories.dart';
import 'ui/theme/app_theme.dart';
import 'ui/view_models/main_view_model.dart';
import 'ui/core/widgets/responsive_scaffold.dart';
import 'ui/features/auth/views/login_view.dart';
import 'ui/features/dashboard/views/dashboard_view.dart';
import 'ui/features/inventory/views/inventory_view.dart';
import 'ui/features/inventory/widgets/add_bill_sheet.dart';
import 'ui/features/intake/views/intake_view.dart';
import 'ui/features/recipes/views/recipes_view.dart';
import 'ui/features/profile/views/profile_and_goals_view.dart';
import 'ui/features/recommendations/views/recommendations_view.dart';
import 'ui/features/sheets_sync/views/sheets_sync_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStorage = LocalStorageService();
  final ocrService = OcrBillScannerService();
  final foodRecognitionService = FoodRecognitionService();
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
            foodRecognitionService: foodRecognitionService,
            localStorage: localStorage,
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
    final vm = context.watch<MainViewModel>();
    return MaterialApp(
      title: 'FamilyFood - Grocery & Nutrition Analysis',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: vm.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AppHome(),
    );
  }
}

class AppHome extends StatefulWidget {
  const AppHome({super.key});

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  StreamSubscription<List<SharedMediaFile>>? _shareSub;
  bool _shareListenerReady = false;

  @override
  void dispose() {
    _shareSub?.cancel();
    super.dispose();
  }

  void _setUpShareListenerOnce() {
    if (_shareListenerReady || kIsWeb) return;
    _shareListenerReady = true;

    void handleShared(List<SharedMediaFile> files) {
      if (files.isEmpty || !mounted) return;
      context.read<MainViewModel>().setPendingSharedFile(files.first.path);
    }

    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      handleShared(files);
      ReceiveSharingIntent.instance.reset();
    });
    _shareSub = ReceiveSharingIntent.instance.getMediaStream().listen(handleShared);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();
    _setUpShareListenerOnce();

    if (!vm.isAuthenticated) {
      return const LoginView();
    }

    if (vm.pendingSharedFilePath != null) {
      final sharedPath = vm.pendingSharedFilePath!;
      vm.consumePendingSharedFile();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) AddBillSheet.show(context, initialFilePath: sharedPath);
      });
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
