import 'dart:async';
import '../models/user_profile.dart';
import '../models/nutrition_goals.dart';

class AuthService {
  UserProfile? _currentUser;

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  final _userController = StreamController<UserProfile?>.broadcast();
  Stream<UserProfile?> get authStateChanges => _userController.stream;

  AuthService() {
    // Default initial user for instant development & demonstration
    _currentUser = _createDefaultUser();
  }

  Future<UserProfile> signInWithGoogle({String? customEmail, String? customName}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final email = customEmail ?? 'kiran.foodanalyst@gmail.com';
    final name = customName ?? 'Kiran Kashikar';

    _currentUser = UserProfile(
      id: 'usr_google_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: name,
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      authProvider: AuthProviderType.google,
      familyMembers: _createDefaultFamilyMembers(primaryName: name),
      activeMemberId: 'self',
    );

    _userController.add(_currentUser);
    return _currentUser!;
  }

  Future<UserProfile> signInWithGithub({String? customUsername}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final username = customUsername ?? 'kirankashikar';

    _currentUser = UserProfile(
      id: 'usr_github_${DateTime.now().millisecondsSinceEpoch}',
      email: '$username@users.noreply.github.com',
      displayName: username,
      photoUrl: 'https://avatars.githubusercontent.com/u/583231?v=4',
      authProvider: AuthProviderType.github,
      familyMembers: _createDefaultFamilyMembers(primaryName: username),
      activeMemberId: 'self',
    );

    _userController.add(_currentUser);
    return _currentUser!;
  }

  Future<UserProfile> signInAsGuest() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = _createDefaultUser();
    _userController.add(_currentUser);
    return _currentUser!;
  }

  Future<void> signOut() async {
    _currentUser = null;
    _userController.add(null);
  }

  void switchActiveMember(String memberId) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(activeMemberId: memberId);
    _userController.add(_currentUser);
  }

  void updateFamilyMember(FamilyMemberProfile updated) {
    if (_currentUser == null) return;
    final updatedList = _currentUser!.familyMembers.map((m) {
      return m.id == updated.id ? updated : m;
    }).toList();

    _currentUser = _currentUser!.copyWith(familyMembers: updatedList);
    _userController.add(_currentUser);
  }

  void addFamilyMember(FamilyMemberProfile newMember) {
    if (_currentUser == null) return;
    final updatedList = List<FamilyMemberProfile>.from(_currentUser!.familyMembers)..add(newMember);
    _currentUser = _currentUser!.copyWith(familyMembers: updatedList);
    _userController.add(_currentUser);
  }

  void removeFamilyMember(String memberId) {
    if (_currentUser == null || memberId == 'self') return;
    final updatedList = _currentUser!.familyMembers.where((m) => m.id != memberId).toList();
    _currentUser = _currentUser!.copyWith(
      familyMembers: updatedList,
      activeMemberId: _currentUser!.activeMemberId == memberId ? 'self' : _currentUser!.activeMemberId,
    );
    _userController.add(_currentUser);
  }

  static UserProfile _createDefaultUser() {
    return UserProfile(
      id: 'usr_demo_01',
      email: 'demo.family@gmail.com',
      displayName: 'Kiran Kashikar',
      photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      authProvider: AuthProviderType.google,
      familyMembers: _createDefaultFamilyMembers(primaryName: 'Kiran'),
      activeMemberId: 'self',
    );
  }

  static List<FamilyMemberProfile> _createDefaultFamilyMembers({required String primaryName}) {
    return [
      FamilyMemberProfile(
        id: 'self',
        name: primaryName,
        relationship: 'Self',
        age: 32,
        gender: 'Male',
        heightCm: 175.0,
        weightKg: 72.0,
        activityLevel: 'Moderate',
        ethnicity: 'South Asian (Indian)',
        dietaryPreferences: ['Vegetarian', 'Gut-Friendly Fermented'],
        allergies: ['Peanuts'],
        goal: HealthGoal.muscleGain,
        customMacroBudget: DailyMacroBudget(
          targetCalories: 2200,
          targetProteinGrams: 110,
          targetCarbsGrams: 260,
          targetFatGrams: 60,
          targetFiberGrams: 35,
          targetSodiumMg: 2000,
          targetPotassiumMg: 3500,
        ),
      ),
      FamilyMemberProfile(
        id: 'member_spouse',
        name: 'Ananya',
        relationship: 'Spouse',
        age: 30,
        gender: 'Female',
        heightCm: 162.0,
        weightKg: 58.0,
        activityLevel: 'Light',
        ethnicity: 'South Asian (Indian)',
        dietaryPreferences: ['Vegetarian', 'Low-Dairy'],
        allergies: [],
        goal: HealthGoal.balancedMaintenance,
        customMacroBudget: DailyMacroBudget(
          targetCalories: 1800,
          targetProteinGrams: 70,
          targetCarbsGrams: 220,
          targetFatGrams: 50,
          targetFiberGrams: 28,
          targetSodiumMg: 1900,
          targetPotassiumMg: 3000,
        ),
      ),
      FamilyMemberProfile(
        id: 'member_child',
        name: 'Aarav',
        relationship: 'Child',
        age: 6,
        gender: 'Male',
        heightCm: 115.0,
        weightKg: 21.0,
        activityLevel: 'Active',
        ethnicity: 'South Asian (Indian)',
        dietaryPreferences: ['Vegetarian'],
        allergies: [],
        goal: HealthGoal.athleticPerformance,
        customMacroBudget: DailyMacroBudget(
          targetCalories: 1500,
          targetProteinGrams: 45,
          targetCarbsGrams: 200,
          targetFatGrams: 45,
          targetFiberGrams: 20,
          targetSodiumMg: 1500,
          targetPotassiumMg: 2500,
        ),
      ),
    ];
  }
}
