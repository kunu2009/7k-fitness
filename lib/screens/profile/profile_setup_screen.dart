import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/settings_service.dart';
import '../../providers/fitness_provider.dart';
import '../../models/fitness_data.dart';

class ProfileSetupScreen extends StatefulWidget {
  final SettingsService settingsService;
  final VoidCallback onComplete;

  const ProfileSetupScreen({
    super.key,
    required this.settingsService,
    required this.onComplete,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Form values
  final _nameController = TextEditingController();
  int _age = 25;
  Gender _gender = Gender.male;

  // Height in current unit
  int _heightFeet = 5;
  int _heightInches = 8;
  int _heightCm = 170;
  HeightUnit _heightUnit = HeightUnit.ftIn;

  // Weight
  double _weight = 70.0;
  WeightUnit _weightUnit = WeightUnit.kg;

  ActivityLevel _activityLevel = ActivityLevel.moderate;
  FitnessGoal _fitnessGoal = FitnessGoal.maintain;

  // Calculated values
  Map<String, int>? _calculatedGoals;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  void _loadExistingProfile() {
    final settings = widget.settingsService;
    if (settings.profileSetupCompleted) {
      _nameController.text = settings.userName;
      _age = settings.userAge;
      _gender = settings.userGender;
      _heightCm = settings.userHeight.round();
      _weight = settings.userWeight;
      _activityLevel = settings.activityLevel;
      _fitnessGoal = settings.fitnessGoal;
      _weightUnit = settings.weightUnit;
      _heightUnit = settings.heightUnit;

      // Convert height for display
      if (_heightUnit == HeightUnit.ftIn) {
        final converted = settings.convertHeightToDisplay(settings.userHeight);
        _heightFeet = converted['feet'] ?? 5;
        _heightInches = converted['inches'] ?? 8;
      }

      // Convert weight for display
      if (_weightUnit == WeightUnit.lbs) {
        _weight = settings.convertWeightToDisplay(settings.userWeight);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      if (_currentPage == 0 && _nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveProfile();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _calculateGoals() {
    // Convert to metric for calculation
    double heightInCm = _heightUnit == HeightUnit.ftIn
        ? widget.settingsService.convertHeightToCm(_heightFeet, _heightInches)
        : _heightCm.toDouble();

    double weightInKg = _weightUnit == WeightUnit.lbs
        ? widget.settingsService.convertWeightToKg(_weight)
        : _weight;

    setState(() {
      _calculatedGoals = widget.settingsService.calculateCalorieGoals(
        weight: weightInKg,
        height: heightInCm,
        age: _age,
        gender: _gender,
        activityLevel: _activityLevel,
        fitnessGoal: _fitnessGoal,
      );
    });
  }

  Future<void> _saveProfile() async {
    // Convert to metric
    double heightInCm = _heightUnit == HeightUnit.ftIn
        ? widget.settingsService.convertHeightToCm(_heightFeet, _heightInches)
        : _heightCm.toDouble();

    double weightInKg = _weightUnit == WeightUnit.lbs
        ? widget.settingsService.convertWeightToKg(_weight)
        : _weight;

    // Save unit preferences first
    await widget.settingsService.setWeightUnit(_weightUnit);
    await widget.settingsService.setHeightUnit(_heightUnit);

    // Save profile
    await widget.settingsService.saveProfile(
      name: _nameController.text.trim(),
      age: _age,
      gender: _gender,
      height: heightInCm,
      weight: weightInKg,
      activityLevel: _activityLevel,
      fitnessGoal: _fitnessGoal,
    );

    // Sync with FitnessProvider
    if (mounted) {
      final fitnessProvider = Provider.of<FitnessProvider>(
        context,
        listen: false,
      );
      fitnessProvider.setUserProfile(
        UserProfile(
          name: _nameController.text.trim(),
          age: _age,
          gender: _gender.label,
          height: heightInCm,
          weight: weightInKg,
          activityLevel: _activityLevel.label,
          fitnessGoal: _fitnessGoal.label,
        ),
      );
    }

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _currentPage > 0 ? _previousPage : null,
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / 5,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_currentPage + 1}/5',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  if (index == 4) _calculateGoals();
                },
                children: [
                  _buildBasicInfoPage(),
                  _buildMeasurementsPage(),
                  _buildActivityPage(),
                  _buildGoalPage(),
                  _buildSummaryPage(),
                ],
              ),
            ),

            // Next button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    _currentPage == 4 ? 'Complete Setup' : 'Continue',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person, size: 60, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            'Let\'s Get Started!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us a bit about yourself',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Name
          const Text(
            'What\'s your name?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 24),

          // Age
          const Text(
            'How old are you?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _buildAgePicker(),
          const SizedBox(height: 24),

          // Gender
          const Text(
            'What\'s your gender?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _buildGenderSelector(),
        ],
      ),
    );
  }

  Widget _buildAgePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: _age > 13 ? () => setState(() => _age--) : null,
          ),
          Expanded(
            child: Text(
              '$_age years',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _age < 100 ? () => setState(() => _age++) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: Gender.values.map((gender) {
        final isSelected = _gender == gender;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _gender = gender),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    gender == Gender.male
                        ? Icons.male
                        : gender == Gender.female
                        ? Icons.female
                        : Icons.person,
                    color: isSelected ? AppColors.primary : Colors.grey[600],
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gender.label,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.grey[600],
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMeasurementsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.straighten, size: 60, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Your Measurements',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'We need this to calculate your calorie needs',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Height Unit Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Height',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              ToggleButtons(
                isSelected: [
                  _heightUnit == HeightUnit.ftIn,
                  _heightUnit == HeightUnit.cm,
                ],
                onPressed: (index) {
                  setState(() {
                    _heightUnit = index == 0 ? HeightUnit.ftIn : HeightUnit.cm;
                    if (_heightUnit == HeightUnit.cm) {
                      _heightCm = widget.settingsService
                          .convertHeightToCm(_heightFeet, _heightInches)
                          .round();
                    } else {
                      final converted = widget.settingsService
                          .convertHeightToDisplay(_heightCm.toDouble());
                      _heightFeet = converted['feet'] ?? 5;
                      _heightInches = converted['inches'] ?? 8;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(8),
                selectedColor: AppColors.primary,
                fillColor: AppColors.primary.withValues(alpha: 0.1),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('ft/in'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('cm'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildHeightPicker(),
          const SizedBox(height: 32),

          // Weight Unit Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weight',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              ToggleButtons(
                isSelected: [
                  _weightUnit == WeightUnit.kg,
                  _weightUnit == WeightUnit.lbs,
                ],
                onPressed: (index) {
                  setState(() {
                    final newUnit = index == 0 ? WeightUnit.kg : WeightUnit.lbs;
                    if (newUnit != _weightUnit) {
                      if (newUnit == WeightUnit.lbs) {
                        _weight = _weight * 2.20462;
                      } else {
                        _weight = _weight / 2.20462;
                      }
                      _weightUnit = newUnit;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(8),
                selectedColor: AppColors.primary,
                fillColor: AppColors.primary.withValues(alpha: 0.1),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('kg'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('lbs'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildWeightPicker(),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your units preference will be saved and used throughout the app.',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeightPicker() {
    if (_heightUnit == HeightUnit.ftIn) {
      return Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _heightFeet > 3
                        ? () => setState(() => _heightFeet--)
                        : null,
                  ),
                  Expanded(
                    child: Text(
                      '$_heightFeet ft',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _heightFeet < 8
                        ? () => setState(() => _heightFeet++)
                        : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _heightInches > 0
                        ? () => setState(() => _heightInches--)
                        : null,
                  ),
                  Expanded(
                    child: Text(
                      '$_heightInches in',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _heightInches < 11
                        ? () => setState(() => _heightInches++)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: _heightCm > 100
                  ? () => setState(() => _heightCm--)
                  : null,
            ),
            Expanded(
              child: Text(
                '$_heightCm cm',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _heightCm < 250
                  ? () => setState(() => _heightCm++)
                  : null,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildWeightPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '${_weight.toStringAsFixed(1)} ${_weightUnit == WeightUnit.kg ? 'kg' : 'lbs'}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _weight,
            min: _weightUnit == WeightUnit.kg ? 30 : 66,
            max: _weightUnit == WeightUnit.kg ? 200 : 440,
            divisions: _weightUnit == WeightUnit.kg ? 170 : 374,
            activeColor: AppColors.primary,
            onChanged: (value) => setState(() => _weight = value),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _weightUnit == WeightUnit.kg ? '30 kg' : '66 lbs',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                _weightUnit == WeightUnit.kg ? '200 kg' : '440 lbs',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.directions_run, size: 60, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Activity Level',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'How active are you on a typical week?',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          ...ActivityLevel.values.map((level) => _buildActivityOption(level)),
        ],
      ),
    );
  }

  Widget _buildActivityOption(ActivityLevel level) {
    final isSelected = _activityLevel == level;
    return GestureDetector(
      onTap: () => setState(() => _activityLevel = level),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  Text(
                    level.description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.flag, size: 60, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            'Your Goal',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'What do you want to achieve?',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          ...FitnessGoal.values.map((goal) => _buildGoalOption(goal)),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'How it works:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _fitnessGoal == FitnessGoal.lose
                      ? '• We\'ll create a 500 calorie deficit\n• Aim for 0.5-1 lb/week loss\n• Focus on high protein to preserve muscle'
                      : _fitnessGoal == FitnessGoal.gain
                      ? '• We\'ll add 300 calories to your needs\n• Aim for 0.25-0.5 lb/week gain\n• Pair with strength training for best results'
                      : '• Calories matched to your activity\n• Great for body recomposition\n• Focus on consistency',
                  style: TextStyle(color: Colors.orange[800], height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalOption(FitnessGoal goal) {
    final isSelected = _fitnessGoal == goal;
    return GestureDetector(
      onTap: () => setState(() => _fitnessGoal = goal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              goal.icon,
              color: isSelected ? AppColors.primary : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  Text(
                    goal.description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 60, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Your Plan is Ready! 🎉',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s your personalized nutrition plan',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Profile summary
          _buildSummaryCard(
            'Profile',
            [
              'Name: ${_nameController.text}',
              'Age: $_age years • ${_gender.label}',
              'Height: ${_heightUnit == HeightUnit.ftIn ? "$_heightFeet'$_heightInches\"" : "$_heightCm cm"}',
              'Weight: ${_weight.toStringAsFixed(1)} ${_weightUnit == WeightUnit.kg ? "kg" : "lbs"}',
            ],
            Icons.person,
            Colors.blue,
          ),

          _buildSummaryCard(
            'Activity & Goal',
            [
              'Activity: ${_activityLevel.label}',
              'Goal: ${_fitnessGoal.label}',
            ],
            Icons.flag,
            Colors.orange,
          ),

          if (_calculatedGoals != null) ...[
            _buildCalorieCard(),
            _buildMacroCard(),
          ],

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.green),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You can adjust these goals anytime in Settings!',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Divider(),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Daily Calorie Target',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${_calculatedGoals!['calories']} kcal',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCalorieDetail('BMR', '${_calculatedGoals!['bmr']}'),
              Container(width: 1, height: 30, color: Colors.white30),
              _buildCalorieDetail('TDEE', '${_calculatedGoals!['tdee']}'),
              Container(width: 1, height: 30, color: Colors.white30),
              _buildCalorieDetail(
                'Adjust',
                _fitnessGoal == FitnessGoal.lose
                    ? '-500'
                    : _fitnessGoal == FitnessGoal.gain
                    ? '+300'
                    : '0',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart, color: Colors.purple, size: 20),
              SizedBox(width: 8),
              Text(
                'Daily Macros',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMacroItem(
                'Protein',
                '${_calculatedGoals!['protein']}g',
                Colors.red,
              ),
              _buildMacroItem(
                'Carbs',
                '${_calculatedGoals!['carbs']}g',
                Colors.blue,
              ),
              _buildMacroItem(
                'Fat',
                '${_calculatedGoals!['fat']}g',
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}
