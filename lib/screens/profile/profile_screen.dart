import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/fitness_data.dart';
import '../../providers/fitness_provider.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String _gender = 'Male';
  String _activityLevel = 'Moderate';
  String _fitnessGoal = 'Maintain Weight';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<FitnessProvider>().userProfile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _ageController = TextEditingController(text: profile?.age.toString() ?? '');
    _heightController = TextEditingController(
      text: profile?.height.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: profile?.weight.toString() ?? '',
    );
    _gender = profile?.gender ?? 'Male';
    _activityLevel = profile?.activityLevel ?? 'Moderate';
    _fitnessGoal = profile?.fitnessGoal ?? 'Maintain Weight';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<FitnessProvider>().userProfile;

    if (userProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_outline,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text('No profile created yet'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/onboarding'),
                child: const Text('Create Profile'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _isEditing
                ? _saveProfile
                : () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        userProfile.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!_isEditing) ...[
                      Text(
                        userProfile.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${userProfile.age} years old',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Health Metrics
              if (!_isEditing) ...[
                _buildMetricCard(
                  'BMI',
                  userProfile.bmi.toStringAsFixed(1),
                  userProfile.bmiCategory,
                  Icons.scale,
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  'Daily Calorie Goal',
                  userProfile.dailyCalorieGoal.toStringAsFixed(0),
                  'kcal',
                  Icons.local_fire_department,
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  'Activity Level',
                  userProfile.activityLevel,
                  '',
                  Icons.fitness_center,
                ),
                const SizedBox(height: 32),
              ],

              // Edit Form
              if (_isEditing) ...[
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField('Full Name', _nameController),
                const SizedBox(height: 12),
                _buildTextField(
                  'Age',
                  _ageController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildGenderSelector(),
                const SizedBox(height: 12),
                _buildTextField(
                  'Height (cm)',
                  _heightController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Weight (kg)',
                  _weightController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildActivityLevelSelector(),
                const SizedBox(height: 32),
              ],

              // Statistics Section (if not editing)
              if (!_isEditing) ...[
                Text(
                  'Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatRow(
                  'Height',
                  '${userProfile.height.toStringAsFixed(0)} cm',
                ),
                _buildStatRow(
                  'Weight',
                  '${userProfile.weight.toStringAsFixed(1)} kg',
                ),
                _buildStatRow('Gender', userProfile.gender),
                _buildStatRow(
                  'Member Since',
                  _formatDate(userProfile.createdAt),
                ),
                const SizedBox(height: 32),
              ],

              // Danger Zone
              if (!_isEditing) ...[
                Text(
                  'Danger Zone',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showResetConfirmation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Reset Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Male'),
                selected: _gender == 'Male',
                onSelected: (selected) {
                  if (!selected) return;
                  setState(() {
                    _gender = 'Male';
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('Female'),
                selected: _gender == 'Female',
                onSelected: (selected) {
                  if (!selected) return;
                  setState(() {
                    _gender = 'Female';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity Level',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _activityLevel,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items:
              ['Sedentary', 'Light', 'Moderate', 'Very active', 'Extra active']
                  .map(
                    (activity) => DropdownMenuItem(
                      value: activity,
                      child: Text(activity),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            setState(() {
              _activityLevel = value ?? 'Moderate';
            });
          },
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _saveProfile() {
    final userProfile = UserProfile(
      name: _nameController.text,
      age: int.parse(_ageController.text),
      height: double.parse(_heightController.text),
      weight: double.parse(_weightController.text),
      gender: _gender,
      activityLevel: _activityLevel,
      fitnessGoal: _fitnessGoal,
      createdAt: context.read<FitnessProvider>().userProfile?.createdAt,
    );

    context.read<FitnessProvider>().setUserProfile(userProfile);

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Profile?'),
        content: const Text(
          'This will delete your profile and all fitness data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<FitnessProvider>().resetProfileAndData();
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile reset. Please create a new profile.'),
                ),
              );
              Navigator.of(context).pushReplacementNamed('/onboarding');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
