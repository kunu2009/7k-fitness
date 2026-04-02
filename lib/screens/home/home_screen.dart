import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/fitness_provider.dart';
import '../../services/settings_service.dart';
import '../../utils/metric_input_dialogs.dart';
import '../../widgets/goal_widgets.dart';
import '../../widgets/achievement_widgets.dart';
import '../../widgets/gamification_widgets.dart';
import '../../widgets/dashboard_widgets.dart';
import '../../widgets/suggested_workout_card.dart';
import '../exercises/exercises_screen.dart';
import '../achievements/achievements_screen.dart';
import '../achievements/badges_screen.dart';
import '../goals/goals_screen.dart';
import '../programs/programs_screen.dart';
import '../workout/active_workout_screen.dart';
import '../nutrition/nutrition_screen.dart';
import '../social/social_screen.dart';
import '../measurements/measurements_screen.dart';
import '../water/water_tracker_screen.dart';
import '../sleep/sleep_tracker_screen.dart';
import '../steps/step_counter_screen.dart';
import '../heart_rate/heart_rate_screen.dart';
import '../calculator/calorie_calculator_screen.dart';
import '../workouts/workout_templates_screen.dart';
import '../body/body_composition_screen.dart';
import '../timer/workout_timer_screen.dart';
import '../progress/progress_photos_screen.dart';
import '../records/personal_records_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer2<FitnessProvider, SettingsService>(
          builder: (context, fitnessProvider, settingsService, _) {
            final userData = fitnessProvider.userProfile;
            // Fallback to SettingsService if FitnessProvider hasn't loaded the profile yet
            final userName = (userData?.name.isNotEmpty == true)
                ? userData!.name
                : (settingsService.userName.isNotEmpty
                      ? settingsService.userName
                      : 'User');

            final userInitial = userName.isNotEmpty
                ? userName[0].toUpperCase()
                : 'U';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            Text(
                              userName,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            userInitial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TodayDashboardSection(
                      onOpenWorkout: () {
                        if (fitnessProvider.hasActiveWorkout) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ActiveWorkoutScreen(),
                            ),
                          );
                        } else {
                          fitnessProvider.startWorkout();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ActiveWorkoutScreen(),
                            ),
                          );
                        }
                      },
                      onOpenWater: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WaterTrackerScreen(),
                        ),
                      ),
                      onOpenNutrition: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NutritionScreen(),
                        ),
                      ),
                      onOpenSteps: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StepCounterScreen(),
                        ),
                      ),
                      onOpenSleep: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SleepTrackerScreen(),
                        ),
                      ),
                      onQuickAddWater: () =>
                          showWaterInputDialog(context, fitnessProvider),
                      onQuickLogMeal: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NutritionScreen(),
                        ),
                      ),
                      onQuickLogWeight: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MeasurementsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Streak & Quick Actions Row
                    Row(
                      children: [
                        Expanded(
                          child: StreakDisplay(
                            streak: fitnessProvider.workoutStreak,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Quick workout button
                        GestureDetector(
                          onTap: () {
                            if (fitnessProvider.hasActiveWorkout) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ActiveWorkoutScreen(),
                                ),
                              );
                            } else {
                              fitnessProvider.startWorkout();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ActiveWorkoutScreen(),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: fitnessProvider.hasActiveWorkout
                                  ? Colors.green
                                  : AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  fitnessProvider.hasActiveWorkout
                                      ? Icons.play_arrow
                                      : Icons.fitness_center,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  fitnessProvider.hasActiveWorkout
                                      ? 'Continue'
                                      : 'Workout',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // XP Bar and Level Display
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BadgesScreen(),
                        ),
                      ),
                      child: const XPBarWidget(),
                    ),
                    const SizedBox(height: 16),
                    // Daily Challenges
                    const DailyChallengesWidget(),
                    const SizedBox(height: 20),
                    // Quick access cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAccessCard(
                            context,
                            'Exercises',
                            Icons.list_alt,
                            AppColors.primary,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ExercisesScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAccessCard(
                            context,
                            'Programs',
                            Icons.calendar_month,
                            AppColors.secondary,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProgramsScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAccessCard(
                            context,
                            'Nutrition',
                            Icons.restaurant_menu,
                            Colors.green,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NutritionScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAccessCard(
                            context,
                            'Templates',
                            Icons.assignment,
                            Colors.indigo,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const WorkoutTemplatesScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAccessCard(
                            context,
                            'Measurements',
                            Icons.straighten,
                            Colors.purple,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MeasurementsScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAccessCard(
                            context,
                            'Goals',
                            Icons.flag,
                            Colors.amber,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GoalsScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // New row for health tracking features
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAccessCard(
                            context,
                            'Calculator',
                            Icons.calculate,
                            Colors.orange,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CalorieCalculatorScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAccessCard(
                            context,
                            'Social',
                            Icons.people,
                            Colors.blue,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SocialScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Health Tracking Section
                    Text(
                      "Health Tracking",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildHealthTrackingCard(
                            context,
                            'Water',
                            Icons.water_drop,
                            Colors.cyan,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const WaterTrackerScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildHealthTrackingCard(
                            context,
                            'Sleep',
                            Icons.bedtime,
                            Colors.indigo,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SleepTrackerScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildHealthTrackingCard(
                            context,
                            'Steps',
                            Icons.directions_walk,
                            Colors.green,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const StepCounterScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildHealthTrackingCard(
                            context,
                            'Heart Rate',
                            Icons.favorite,
                            Colors.red,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HeartRateScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildHealthTrackingCard(
                            context,
                            'Body',
                            Icons.accessibility,
                            Colors.purple,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const BodyCompositionScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildHealthTrackingCard(
                            context,
                            'Timer',
                            Icons.timer,
                            Colors.teal,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const WorkoutTimerScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildHealthTrackingCard(
                            context,
                            'Photos',
                            Icons.photo_library,
                            Colors.indigo,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ProgressPhotosScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildHealthTrackingCard(
                            context,
                            'PRs',
                            Icons.emoji_events,
                            Colors.amber,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PersonalRecordsScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Suggested Workout
                    Text(
                      "Suggested For You",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SuggestedWorkoutTile(
                      onTap: () {
                        if (fitnessProvider.hasActiveWorkout) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ActiveWorkoutScreen(),
                            ),
                          );
                        } else {
                          fitnessProvider.startWorkout();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ActiveWorkoutScreen(),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    // Motivation Quote
                    const MotivationQuoteWidget(),
                    const SizedBox(height: 20),
                    // Goals Summary
                    if (fitnessProvider.todayGoals.isNotEmpty)
                      GoalsSummary(
                        goals: fitnessProvider.todayGoals,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GoalsScreen(),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Achievements Summary
                    AchievementSummary(
                      achievements: fitnessProvider.achievements,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AchievementsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (userData != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accent, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Today's Calorie Goal",
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const Icon(
                                  Icons.local_fire_department,
                                  color: AppColors.accent,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${userData.dailyCalorieGoal.toStringAsFixed(0)} kcal',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Based on ${userData.activityLevel} activity level',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Metrics logging section
                    Text(
                      "Today's Metrics",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildMetricButton(
                          context,
                          fitnessProvider,
                          'Calories',
                          Icons.local_fire_department,
                          AppColors.accent,
                          () =>
                              showCalorieInputDialog(context, fitnessProvider),
                        ),
                        _buildMetricButton(
                          context,
                          fitnessProvider,
                          'Water',
                          Icons.water_drop,
                          AppColors.skyBlue,
                          () => showWaterInputDialog(context, fitnessProvider),
                        ),
                        _buildMetricButton(
                          context,
                          fitnessProvider,
                          'Steps',
                          Icons.directions_walk,
                          AppColors.lightGreen,
                          () => showStepsInputDialog(context, fitnessProvider),
                        ),
                        _buildMetricButton(
                          context,
                          fitnessProvider,
                          'Sleep',
                          Icons.nights_stay,
                          AppColors.primary,
                          () => showSleepInputDialog(context, fitnessProvider),
                        ),
                        _buildMetricButton(
                          context,
                          fitnessProvider,
                          'Heart Rate',
                          Icons.favorite,
                          AppColors.danger,
                          () => showHeartRateInputDialog(
                            context,
                            fitnessProvider,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricButton(
    BuildContext context,
    FitnessProvider fitnessProvider,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to log',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTrackingCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.8), color],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
