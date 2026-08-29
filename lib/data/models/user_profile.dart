import 'dart:convert';
import 'nutrition_goals.dart';

enum AuthProviderType { google, github, demo }

class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final AuthProviderType authProvider;
  final List<FamilyMemberProfile> familyMembers;
  final String activeMemberId;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.authProvider,
    required this.familyMembers,
    required this.activeMemberId,
  });

  FamilyMemberProfile get activeMember {
    return familyMembers.firstWhere(
      (m) => m.id == activeMemberId,
      orElse: () => familyMembers.first,
    );
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    AuthProviderType? authProvider,
    List<FamilyMemberProfile>? familyMembers,
    String? activeMemberId,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      authProvider: authProvider ?? this.authProvider,
      familyMembers: familyMembers ?? this.familyMembers,
      activeMemberId: activeMemberId ?? this.activeMemberId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'authProvider': authProvider.name,
      'familyMembers': familyMembers.map((x) => x.toMap()).toList(),
      'activeMemberId': activeMemberId,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      authProvider: AuthProviderType.values.firstWhere(
        (e) => e.name == map['authProvider'],
        orElse: () => AuthProviderType.demo,
      ),
      familyMembers: List<FamilyMemberProfile>.from(
        (map['familyMembers'] as List? ?? []).map((x) => FamilyMemberProfile.fromMap(x)),
      ),
      activeMemberId: map['activeMemberId'] ?? 'self',
    );
  }

  String toJson() => json.encode(toMap());
  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}

class FamilyMemberProfile {
  final String id;
  final String name;
  final String relationship; // e.g. Self, Spouse, Child, Parent
  final int age;
  final String gender; // Male, Female, Other
  final double heightCm;
  final double weightKg;
  final String activityLevel; // Sedentary, Light, Moderate, Active, Very Active
  final String ethnicity; // South Asian (Indian), Mediterranean, East Asian, Western, etc.
  final List<String> dietaryPreferences; // Vegetarian, Vegan, Halal, Gluten-Free, etc.
  final List<String> allergies; // Peanuts, Dairy, Shellfish, etc.
  final HealthGoal goal; // Weight Loss, Muscle Gain, Blood Sugar Control, etc.
  final DailyMacroBudget customMacroBudget;

  FamilyMemberProfile({
    required this.id,
    required this.name,
    required this.relationship,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.ethnicity,
    required this.dietaryPreferences,
    required this.allergies,
    required this.goal,
    required this.customMacroBudget,
  });

  double get bmi {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100.0;
    return weightKg / (heightM * heightM);
  }

  String get bmiCategory {
    final val = bmi;
    if (val < 18.5) return 'Underweight';
    if (val < 24.9) return 'Normal weight';
    if (val < 29.9) return 'Overweight';
    return 'Obesity';
  }

  FamilyMemberProfile copyWith({
    String? id,
    String? name,
    String? relationship,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? activityLevel,
    String? ethnicity,
    List<String>? dietaryPreferences,
    List<String>? allergies,
    HealthGoal? goal,
    DailyMacroBudget? customMacroBudget,
  }) {
    return FamilyMemberProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      ethnicity: ethnicity ?? this.ethnicity,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      allergies: allergies ?? this.allergies,
      goal: goal ?? this.goal,
      customMacroBudget: customMacroBudget ?? this.customMacroBudget,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'activityLevel': activityLevel,
      'ethnicity': ethnicity,
      'dietaryPreferences': dietaryPreferences,
      'allergies': allergies,
      'goal': goal.name,
      'customMacroBudget': customMacroBudget.toMap(),
    };
  }

  factory FamilyMemberProfile.fromMap(Map<String, dynamic> map) {
    return FamilyMemberProfile(
      id: map['id'] ?? 'self',
      name: map['name'] ?? 'Primary User',
      relationship: map['relationship'] ?? 'Self',
      age: (map['age'] as num?)?.toInt() ?? 30,
      gender: map['gender'] ?? 'Male',
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 172.0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 70.0,
      activityLevel: map['activityLevel'] ?? 'Moderate',
      ethnicity: map['ethnicity'] ?? 'South Asian (Indian)',
      dietaryPreferences: List<String>.from(map['dietaryPreferences'] ?? ['Vegetarian']),
      allergies: List<String>.from(map['allergies'] ?? []),
      goal: HealthGoal.values.firstWhere(
        (e) => e.name == map['goal'],
        orElse: () => HealthGoal.balancedMaintenance,
      ),
      customMacroBudget: map['customMacroBudget'] != null
          ? DailyMacroBudget.fromMap(map['customMacroBudget'])
          : DailyMacroBudget.defaultBudget(),
    );
  }
}
