import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/fitness_data.dart';
import '../../providers/fitness_provider.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late int _age;
  late double _height;
  late double _weight;
  String _gender = 'Male';
  String _activityLevel = 'Moderate';
  String _fitnessGoal = 'Maintain weight';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Welcome to Fitness Tracker',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Let\'s get to know you better',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Name Field
                  Text(
                    'Full Name',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value ?? '';
                    },
                  ),
                  const SizedBox(height: 20),

                  // Age Field
                  Text(
                    'Age',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter your age',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixText: 'years',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid age';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _age = int.parse(value ?? '25');
                    },
                  ),
                  const SizedBox(height: 20),

                  // Gender Selection
                  Text(
                    'Gender',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                  const SizedBox(height: 20),

                  // Height Field
                  Text(
                    'Height',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter your height',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.straighten),
                      suffixText: 'cm',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your height';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid height';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _height = double.parse(value ?? '170');
                    },
                  ),
                  const SizedBox(height: 20),

                  // Weight Field
                  Text(
                    'Weight',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter your weight',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.balance),
                      suffixText: 'kg',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your weight';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid weight';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _weight = double.parse(value ?? '70');
                    },
                  ),
                  const SizedBox(height: 20),

                  // Activity Level
                  Text(
                    'Activity Level',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _activityLevel,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.fitness_center),
                    ),
                    items:
                        [
                              'Sedentary (little or no exercise)',
                              'Light (exercise 1-3 days/week)',
                              'Moderate (exercise 3-5 days/week)',
                              'Very active (exercise 6-7 days/week)',
                              'Extra active (physical job or training)',
                            ]
                            .map(
                              (activity) => DropdownMenuItem(
                                value: activity.split(' ')[0],
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
                  const SizedBox(height: 20),

                  // Fitness Goal
                  Text(
                    'Fitness Goal',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _fitnessGoal,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.flag),
                    ),
                    items:
                        [
                              'Lose weight',
                              'Maintain weight',
                              'Build muscle',
                              'Improve endurance',
                              'Increase strength',
                              'General fitness',
                            ]
                            .map(
                              (goal) => DropdownMenuItem(
                                value: goal,
                                child: Text(goal),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _fitnessGoal = value ?? 'Maintain weight';
                      });
                    },
                  ),
                  const SizedBox(height: 40),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Get Started',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      // Create user profile
      final userProfile = UserProfile(
        name: _name,
        age: _age,
        height: _height,
        weight: _weight,
        gender: _gender,
        activityLevel: _activityLevel,
        fitnessGoal: _fitnessGoal,
      );

      // Save to provider
      context.read<FitnessProvider>().setUserProfile(userProfile);

      // Show success message and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome $_name!'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Small delay for better UX
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }
}
