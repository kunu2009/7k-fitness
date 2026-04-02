import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/fitness_provider.dart';
import '../services/workout_suggestion_service.dart';

/// Widget that displays a suggested workout based on recovery and history
class SuggestedWorkoutCard extends StatelessWidget {
  final VoidCallback? onStartWorkout;
  final VoidCallback? onDismiss;

  const SuggestedWorkoutCard({super.key, this.onStartWorkout, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Consumer<FitnessProvider>(
      builder: (context, provider, _) {
        final suggestion = WorkoutSuggestionService.getSuggestion(
          recentWorkouts: provider.workoutSessions,
          availableMinutes: 45,
        );

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getGradientColors(suggestion.type),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _getGradientColors(suggestion.type)[0].withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  _getTypeIcon(suggestion.type),
                  size: 120,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Suggested',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (onDismiss != null)
                          GestureDetector(
                            onTap: onDismiss,
                            child: Icon(
                              Icons.close,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Title and description
                    Text(
                      suggestion.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestion.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Reason
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              suggestion.reason,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stats row
                    Row(
                      children: [
                        _buildStatChip(
                          Icons.timer_outlined,
                          '${suggestion.estimatedMinutes} min',
                        ),
                        const SizedBox(width: 12),
                        _buildStatChip(
                          Icons.local_fire_department,
                          '~${suggestion.estimatedCalories} cal',
                        ),
                        if (suggestion.suggestedExercises.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          _buildStatChip(
                            Icons.fitness_center,
                            '${suggestion.suggestedExercises.length} exercises',
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Start button
                    if (suggestion.type != SuggestionType.rest)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onStartWorkout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _getGradientColors(
                              suggestion.type,
                            )[0],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow),
                              SizedBox(width: 8),
                              Text(
                                'Start Workout',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.self_improvement, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Take a Rest Day',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors(SuggestionType type) {
    switch (type) {
      case SuggestionType.push:
        return [Colors.orange, Colors.deepOrange];
      case SuggestionType.pull:
        return [Colors.blue, Colors.indigo];
      case SuggestionType.legs:
        return [Colors.purple, Colors.deepPurple];
      case SuggestionType.upper:
        return [Colors.teal, Colors.cyan];
      case SuggestionType.lower:
        return [Colors.pink, Colors.red];
      case SuggestionType.fullBody:
        return [AppColors.primary, AppColors.secondary];
      case SuggestionType.cardio:
        return [Colors.green, Colors.teal];
      case SuggestionType.rest:
        return [Colors.grey, Colors.blueGrey];
    }
  }

  IconData _getTypeIcon(SuggestionType type) {
    switch (type) {
      case SuggestionType.push:
        return Icons.fitness_center;
      case SuggestionType.pull:
        return Icons.accessibility_new;
      case SuggestionType.legs:
        return Icons.directions_run;
      case SuggestionType.upper:
        return Icons.sports_martial_arts;
      case SuggestionType.lower:
        return Icons.directions_walk;
      case SuggestionType.fullBody:
        return Icons.accessibility;
      case SuggestionType.cardio:
        return Icons.favorite;
      case SuggestionType.rest:
        return Icons.self_improvement;
    }
  }
}

/// Compact version of the suggested workout card for use in lists
class SuggestedWorkoutTile extends StatelessWidget {
  final VoidCallback? onTap;

  const SuggestedWorkoutTile({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<FitnessProvider>(
      builder: (context, provider, _) {
        final suggestion = WorkoutSuggestionService.getSuggestion(
          recentWorkouts: provider.workoutSessions,
          availableMinutes: 45,
        );

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getGradientColors(suggestion.type),
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTypeIcon(suggestion.type),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Suggested',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        suggestion.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        suggestion.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (suggestion.type != SuggestionType.rest)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: _getGradientColors(suggestion.type)[0],
                      size: 24,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.spa, color: Colors.white, size: 24),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Color> _getGradientColors(SuggestionType type) {
    switch (type) {
      case SuggestionType.push:
        return [Colors.orange, Colors.deepOrange];
      case SuggestionType.pull:
        return [Colors.blue, Colors.indigo];
      case SuggestionType.legs:
        return [Colors.purple, Colors.deepPurple];
      case SuggestionType.upper:
        return [Colors.teal, Colors.cyan];
      case SuggestionType.lower:
        return [Colors.pink, Colors.red];
      case SuggestionType.fullBody:
        return [AppColors.primary, AppColors.secondary];
      case SuggestionType.cardio:
        return [Colors.green, Colors.teal];
      case SuggestionType.rest:
        return [Colors.grey, Colors.blueGrey];
    }
  }

  IconData _getTypeIcon(SuggestionType type) {
    switch (type) {
      case SuggestionType.push:
        return Icons.fitness_center;
      case SuggestionType.pull:
        return Icons.accessibility_new;
      case SuggestionType.legs:
        return Icons.directions_run;
      case SuggestionType.upper:
        return Icons.sports_martial_arts;
      case SuggestionType.lower:
        return Icons.directions_walk;
      case SuggestionType.fullBody:
        return Icons.accessibility;
      case SuggestionType.cardio:
        return Icons.favorite;
      case SuggestionType.rest:
        return Icons.self_improvement;
    }
  }
}

