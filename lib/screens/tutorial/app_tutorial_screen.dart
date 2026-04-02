import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

class AppTutorialScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isFirstLaunch;

  const AppTutorialScreen({
    super.key,
    required this.onComplete,
    this.isFirstLaunch = true,
  });

  @override
  State<AppTutorialScreen> createState() => _AppTutorialScreenState();
}

class _AppTutorialScreenState extends State<AppTutorialScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<TutorialPage> _tutorialPages = [
    TutorialPage(
      title: 'Welcome to FitTrack! 💪',
      description:
          'Your complete fitness companion for tracking workouts, nutrition, and achieving your health goals.',
      icon: Icons.fitness_center,
      color: AppColors.primary,
      tips: [
        'Track workouts & exercises',
        'Monitor nutrition & calories',
        'Set and achieve goals',
        'View detailed progress',
      ],
    ),
    TutorialPage(
      title: 'Set Up Your Profile 👤',
      description:
          'First, let\'s set up your profile with your personal details to calculate accurate calorie needs.',
      icon: Icons.person,
      color: Colors.blue,
      tips: [
        'Enter your height, weight, and age',
        'Select your activity level',
        'Choose your fitness goal',
        'Pick your preferred units (kg/lbs, cm/ft)',
      ],
      actionText: 'Go to Profile',
      actionRoute: 'profile',
    ),
    TutorialPage(
      title: 'Understanding Your Calories 🔥',
      description:
          'Your daily calorie needs are calculated based on your profile. Here\'s how it works:',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      tips: [
        'BMR = Base calories your body needs at rest',
        'TDEE = Total daily calories based on activity',
        'Deficit = Eat less to lose weight',
        'Surplus = Eat more to gain muscle',
      ],
      detailedInfo: '''
**Your Daily Workflow:**
1. Check your calorie goal on Home screen
2. Log meals in Nutrition section
3. Track workouts (burns extra calories)
4. Stay within your target range

**Calorie Formula:**
• Weight Loss: TDEE - 500 cal/day
• Maintenance: TDEE
• Muscle Gain: TDEE + 300 cal/day
''',
    ),
    TutorialPage(
      title: 'Track Your Nutrition 🥗',
      description:
          'Log your meals to stay on track with your calorie and macro goals.',
      icon: Icons.restaurant_menu,
      color: Colors.green,
      tips: [
        'Tap + to add meals (breakfast, lunch, dinner)',
        'Search from 500+ foods database',
        'Scan barcodes for packaged foods',
        'Track protein, carbs, and fats',
      ],
      workflow: [
        WorkflowStep('Morning', 'Log breakfast after eating', Icons.wb_sunny),
        WorkflowStep('Midday', 'Add lunch and snacks', Icons.wb_cloudy),
        WorkflowStep('Evening', 'Complete dinner entry', Icons.nights_stay),
        WorkflowStep('Review', 'Check daily summary', Icons.assessment),
      ],
    ),
    TutorialPage(
      title: 'Log Your Workouts 🏋️',
      description: 'Track exercises to monitor progress and burn calories.',
      icon: Icons.sports_gymnastics,
      color: Colors.purple,
      tips: [
        'Choose from workout templates or create custom',
        'Log sets, reps, and weight for each exercise',
        'Track cardio duration and intensity',
        'Calories burned are added to your daily total',
      ],
      workflow: [
        WorkflowStep('Select', 'Pick workout type', Icons.list),
        WorkflowStep('Exercise', 'Add exercises to routine', Icons.add),
        WorkflowStep('Track', 'Log sets and reps', Icons.edit_note),
        WorkflowStep(
          'Complete',
          'Save workout & view stats',
          Icons.check_circle,
        ),
      ],
    ),
    TutorialPage(
      title: 'Health Tracking 📊',
      description: 'Monitor all aspects of your health in one place.',
      icon: Icons.favorite,
      color: Colors.red,
      tips: [
        '💧 Water - Track 8+ glasses daily',
        '😴 Sleep - Log sleep hours & quality',
        '👣 Steps - Monitor daily activity',
        '❤️ Heart Rate - Track resting & active BPM',
      ],
      detailedInfo: '''
**Quick Access from Home:**
Scroll horizontally on Health Tracking cards:
• Water Tracker
• Sleep Logger  
• Step Counter
• Heart Rate Monitor
• Body Composition
• Workout Timer
• Progress Photos
• Personal Records
''',
    ),
    TutorialPage(
      title: 'Set Your Goals 🎯',
      description: 'Create specific, measurable goals to stay motivated.',
      icon: Icons.flag,
      color: Colors.teal,
      tips: [
        'Set weight goals (lose/gain)',
        'Create workout frequency targets',
        'Track nutrition consistency',
        'Earn achievements for milestones',
      ],
      workflow: [
        WorkflowStep('Define', 'Set a clear, measurable goal', Icons.edit),
        WorkflowStep('Track', 'Log progress daily', Icons.trending_up),
        WorkflowStep('Review', 'Check weekly progress', Icons.analytics),
        WorkflowStep('Achieve', 'Celebrate & set new goals', Icons.celebration),
      ],
    ),
    TutorialPage(
      title: 'Your Daily Routine 📅',
      description: 'Here\'s the recommended daily workflow for best results:',
      icon: Icons.schedule,
      color: Colors.indigo,
      tips: [],
      dailyRoutine: [
        DailyRoutineItem('🌅 Morning', [
          'Weigh yourself (optional)',
          'Log breakfast',
          'Check daily calorie goal',
        ]),
        DailyRoutineItem('🏃 Workout Time', [
          'Start workout from Templates',
          'Log all exercises',
          'Complete & save session',
        ]),
        DailyRoutineItem('🍽️ Throughout Day', [
          'Log all meals & snacks',
          'Track water intake',
          'Monitor remaining calories',
        ]),
        DailyRoutineItem('🌙 Evening', [
          'Review daily summary',
          'Log sleep when going to bed',
          'Plan tomorrow\'s meals',
        ]),
      ],
    ),
    TutorialPage(
      title: 'You\'re All Set! 🚀',
      description:
          'Start your fitness journey today. Remember, consistency is key!',
      icon: Icons.rocket_launch,
      color: AppColors.primary,
      tips: [
        '✅ Log meals consistently',
        '✅ Track workouts regularly',
        '✅ Monitor your progress weekly',
        '✅ Adjust goals as needed',
      ],
      detailedInfo: '''
**Pro Tips:**
• Start with small, achievable goals
• Don't skip logging - even bad days count
• Take progress photos weekly
• Celebrate small victories!

**Need Help?**
Access this tutorial anytime from:
Settings → Help & Tutorial
''',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _tutorialPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTutorial();
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

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);
    widget.onComplete();
  }

  void _skipTutorial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Tutorial?'),
        content: const Text(
          'You can access the tutorial anytime from Settings → Help & Tutorial',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Tutorial'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completeTutorial();
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currentPage + 1}/${_tutorialPages.length}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: _skipTutorial,
                      child: const Text('Skip'),
                    ),
                  ],
                ),
              ),

              // Page indicator
              _buildPageIndicator(),
              const SizedBox(height: 16),

              // Tutorial content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _tutorialPages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildTutorialPage(_tutorialPages[index]);
                  },
                ),
              ),

              // Navigation buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _tutorialPages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? _tutorialPages[_currentPage].color
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialPage(TutorialPage page) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 50, color: page.color),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            page.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            page.description,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Tips
          if (page.tips.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: page.color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: page.color.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: page.tips
                    .map(
                      (tip) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: page.color,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tip,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Workflow steps
          if (page.workflow != null && page.workflow!.isNotEmpty) ...[
            _buildWorkflowSection(page.workflow!, page.color),
            const SizedBox(height: 16),
          ],

          // Daily routine
          if (page.dailyRoutine != null && page.dailyRoutine!.isNotEmpty) ...[
            _buildDailyRoutineSection(page.dailyRoutine!),
            const SizedBox(height: 16),
          ],

          // Detailed info
          if (page.detailedInfo != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                page.detailedInfo!,
                style: const TextStyle(fontSize: 13, height: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkflowSection(List<WorkflowStep> steps, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Workflow:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
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
                    child: Icon(step.icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    step.description,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  if (index < steps.length - 1)
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDailyRoutineSection(List<DailyRoutineItem> routine) {
    return Column(
      children: routine
          .map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.timeOfDay,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...item.tasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 6, color: Colors.grey[400]),
                          const SizedBox(width: 8),
                          Text(task, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentPage == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: _tutorialPages[_currentPage].color,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _currentPage == _tutorialPages.length - 1
                    ? 'Get Started!'
                    : 'Next',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Data classes
class TutorialPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> tips;
  final String? detailedInfo;
  final String? actionText;
  final String? actionRoute;
  final List<WorkflowStep>? workflow;
  final List<DailyRoutineItem>? dailyRoutine;

  TutorialPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.tips,
    this.detailedInfo,
    this.actionText,
    this.actionRoute,
    this.workflow,
    this.dailyRoutine,
  });
}

class WorkflowStep {
  final String title;
  final String description;
  final IconData icon;

  WorkflowStep(this.title, this.description, this.icon);
}

class DailyRoutineItem {
  final String timeOfDay;
  final List<String> tasks;

  DailyRoutineItem(this.timeOfDay, this.tasks);
}
