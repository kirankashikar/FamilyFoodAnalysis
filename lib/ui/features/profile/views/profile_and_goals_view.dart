import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../view_models/main_view_model.dart';
import '../../../core/glass_card.dart';
import '../../../../data/models/user_profile.dart';
import '../../../../data/models/nutrition_goals.dart';
import '../../../../data/models/cultural_preset.dart';

class ProfileAndGoalsView extends StatefulWidget {
  const ProfileAndGoalsView({super.key});

  @override
  State<ProfileAndGoalsView> createState() => _ProfileAndGoalsViewState();
}

class _ProfileAndGoalsViewState extends State<ProfileAndGoalsView> {
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late String _selectedGender;
  late String _selectedActivity;
  late String _selectedEthnicity;
  late HealthGoal _selectedGoal;
  late List<String> _selectedPreferences;
  late List<String> _selectedAllergies;

  String? _loadedMemberId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final member = context.read<MainViewModel>().activeMember;
    if (_loadedMemberId != member.id) {
      _loadedMemberId = member.id;
      _nameCtrl = TextEditingController(text: member.name);
      _ageCtrl = TextEditingController(text: member.age.toString());
      _heightCtrl = TextEditingController(text: member.heightCm.toInt().toString());
      _weightCtrl = TextEditingController(text: member.weightKg.toInt().toString());
      _selectedGender = member.gender;
      _selectedActivity = member.activityLevel;
      _selectedEthnicity = member.ethnicity;
      _selectedGoal = member.goal;
      _selectedPreferences = List.from(member.dietaryPreferences);
      _selectedAllergies = List.from(member.allergies);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();
    final user = vm.currentUser;
    final assessment = vm.activeMemberBmiAssessment;
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allPreferences = ['Vegetarian', 'Vegan', 'Eggetarian', 'Pescatarian', 'Keto', 'Low-Carb', 'Gluten-Free', 'Dairy-Free', 'Halal', 'Kosher'];
    final allAllergies = ['Peanuts', 'Tree Nuts', 'Dairy / Lactose', 'Shellfish', 'Soy', 'Wheat / Gluten', 'Eggs'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header & Family Members Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Family Health Profiles & Goals',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Personalize BMI metrics, ethnic diet defaults, food goals, and nutritional targets for every family member.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddMemberDialog(context, vm),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Add Family Member'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Family Members Switcher Bar
          if (user != null) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: user.familyMembers.map((m) {
                  final isSelected = m.id == vm.activeMember.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      avatar: CircleAvatar(
                        radius: 12,
                        backgroundColor: isSelected ? Colors.white : AppColors.primary,
                        child: Text(
                          m.name[0],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.primary : Colors.white,
                          ),
                        ),
                      ),
                      label: Text('${m.name} (${m.relationship})'),
                      selected: isSelected,
                      onSelected: (_) {
                        vm.switchActiveFamilyMember(m.id);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Main Form: BMI & Biological Parameters
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildBiometricsForm(context, isDark)),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: _buildBmiLiveScoreCard(context, assessment, vm.activeMember)),
              ],
            )
          else ...[
            _buildBmiLiveScoreCard(context, assessment, vm.activeMember),
            const SizedBox(height: 16),
            _buildBiometricsForm(context, isDark),
          ],

          const SizedBox(height: 24),

          // Ethnicity & Cultural Diet Presets
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.public_rounded, color: AppColors.secondary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Cultural & Ethnicity Diet Preset',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Configuring ethnicity defaults food vocabulary (Dosa, Hummus, Rotis, Tofu), staple grains, and spices for intelligent menu suggestions.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: CulturalDietPreset.presets.map((preset) {
                    final isSelected = _selectedEthnicity.toLowerCase().contains(preset.name.toLowerCase());
                    return InkWell(
                      onTap: () => setState(() => _selectedEthnicity = preset.name),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.18) : (isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(preset.iconEmoji, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(preset.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? AppColors.primaryLight : null)),
                                Text('${preset.stapleCarbs.take(2).join(', ')}...', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Dietary Preferences & Allergies
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.checklist_rtl_rounded, color: AppColors.warmAmber, size: 20),
                    SizedBox(width: 8),
                    Text('Dietary Preferences & Allergens', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Dietary Lifestyle:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allPreferences.map((pref) {
                    final isSel = _selectedPreferences.contains(pref);
                    return FilterChip(
                      label: Text(pref),
                      selected: isSel,
                      onSelected: (sel) {
                        setState(() {
                          if (sel) {
                            _selectedPreferences.add(pref);
                          } else {
                            _selectedPreferences.remove(pref);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Allergies & Sensitivities (Dishes will warn if these ingredients are detected):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allAllergies.map((allergy) {
                    final isSel = _selectedAllergies.contains(allergy);
                    return FilterChip(
                      label: Text(allergy),
                      selected: isSel,
                      selectedColor: AppColors.roseAlert.withOpacity(0.2),
                      checkmarkColor: AppColors.roseAlert,
                      onSelected: (sel) {
                        setState(() {
                          if (sel) {
                            _selectedAllergies.add(allergy);
                          } else {
                            _selectedAllergies.remove(allergy);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Primary Health Goal Selection
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.flag_rounded, color: AppColors.primaryLight, size: 20),
                    SizedBox(width: 8),
                    Text('Target Food & Health Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 14),
                ...HealthGoal.values.map((goal) {
                  final isSelected = _selectedGoal == goal;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.15) : (isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                    child: RadioListTile<HealthGoal>(
                      value: goal,
                      groupValue: _selectedGoal,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedGoal = val);
                      },
                      title: Text(goal.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(goal.description, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Save Button
          Center(
            child: SizedBox(
              width: 320,
              child: ElevatedButton.icon(
                onPressed: () => _saveProfileChanges(vm),
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text('Save Profile & Re-Calculate Goals'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricsForm(BuildContext context, bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Biological & BMI Input Parameters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Age (years)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _heightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Height (cm)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedGender = val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedActivity,
                  decoration: const InputDecoration(labelText: 'Activity Level'),
                  items: ['Sedentary', 'Light', 'Moderate', 'Active', 'Very Active'].map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedActivity = val);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBmiLiveScoreCard(BuildContext context, BmiAssessment assessment, FamilyMemberProfile member) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Live BMI & Caloric Engine', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  Text(
                    assessment.bmi.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.primaryLight),
                  ),
                  Text(
                    assessment.category.toUpperCase(),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildScoreRow('Basal Metabolic Rate (BMR)', '${assessment.bmr.toInt()} kcal/day'),
          const Divider(height: 16),
          _buildScoreRow('Total Daily Energy (TDEE)', '${assessment.tdee.toInt()} kcal/day'),
          const Divider(height: 16),
          _buildScoreRow('Recommended Daily Target', '${assessment.recommendedBudget.targetCalories.toInt()} kcal'),
          const Divider(height: 16),
          _buildScoreRow('Target Protein Ratio', '${assessment.recommendedBudget.targetProteinGrams.toInt()}g / day'),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, String val) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        const Spacer(),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  void _saveProfileChanges(MainViewModel vm) {
    final age = int.tryParse(_ageCtrl.text) ?? 30;
    final height = double.tryParse(_heightCtrl.text) ?? 172.0;
    final weight = double.tryParse(_weightCtrl.text) ?? 70.0;

    vm.updateActiveMemberProfile(
      name: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : vm.activeMember.name,
      age: age,
      gender: _selectedGender,
      heightCm: height,
      weightKg: weight,
      activityLevel: _selectedActivity,
      ethnicity: _selectedEthnicity,
      dietaryPreferences: _selectedPreferences,
      allergies: _selectedAllergies,
      goal: _selectedGoal,
    );
  }

  void _showAddMemberDialog(BuildContext context, MainViewModel vm) {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController(text: '28');
    final heightCtrl = TextEditingController(text: '165');
    final weightCtrl = TextEditingController(text: '62');
    String rel = 'Spouse';
    String gender = 'Female';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Family Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name (e.g., Ananya, Aarav)')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: rel,
                decoration: const InputDecoration(labelText: 'Relationship'),
                items: ['Spouse', 'Child', 'Parent', 'Sibling', 'Roommate'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (val) => rel = val ?? rel,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age'))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: gender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (val) => gender = val ?? gender,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: heightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Height (cm)'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight (kg)'))),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final newMember = FamilyMemberProfile(
                  id: 'member_${DateTime.now().microsecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  relationship: rel,
                  age: int.tryParse(ageCtrl.text) ?? 25,
                  gender: gender,
                  heightCm: double.tryParse(heightCtrl.text) ?? 165.0,
                  weightKg: double.tryParse(weightCtrl.text) ?? 60.0,
                  activityLevel: 'Moderate',
                  ethnicity: 'South Asian (Indian)',
                  dietaryPreferences: ['Vegetarian'],
                  allergies: [],
                  goal: HealthGoal.balancedMaintenance,
                  customMacroBudget: DailyMacroBudget.defaultBudget(),
                );
                vm.addFamilyMember(newMember);
                Navigator.pop(ctx);
              },
              child: const Text('Add Member'),
            ),
          ],
        );
      },
    );
  }
}
