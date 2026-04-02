import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../providers/fitness_provider.dart';

/// Dialog to input calories for the day
Future<void> showCalorieInputDialog(
  BuildContext context,
  FitnessProvider fitnessProvider,
) async {
  double calories = fitnessProvider.getTodayData().calories.toDouble();

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Log Calories'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Calories',
                suffixText: 'kcal',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.local_fire_department),
              ),
              controller: TextEditingController(
                text: calories.toStringAsFixed(0),
              ),
              onChanged: (value) {
                calories = double.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: AppColors.accent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Daily Goal: ${fitnessProvider.userProfile?.dailyCalorieGoal.toStringAsFixed(0) ?? '2000'} kcal',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              fitnessProvider.updateTodayData(calories: calories);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${calories.toStringAsFixed(0)} kcal logged'),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

/// Dialog to input water intake
Future<void> showWaterInputDialog(
  BuildContext context,
  FitnessProvider fitnessProvider,
) async {
  int waterGlasses = fitnessProvider.getTodayData().waterGlasses;

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Log Water Intake'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Glasses of water (8oz each)'),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    if (waterGlasses > 0) waterGlasses--;
                  }),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$waterGlasses',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.skyBlue,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() {
                    if (waterGlasses < 20) waterGlasses++;
                  }),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.skyBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_drink, color: AppColors.skyBlue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${(waterGlasses * 0.237).toStringAsFixed(1)} L (${waterGlasses * 236} ml)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              fitnessProvider.updateTodayData(waterGlasses: waterGlasses);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$waterGlasses glasses logged'),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.skyBlue),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

/// Dialog to input steps
Future<void> showStepsInputDialog(
  BuildContext context,
  FitnessProvider fitnessProvider,
) async {
  int steps = fitnessProvider.getTodayData().steps;

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Log Steps'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Steps',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.directions_walk),
              ),
              controller: TextEditingController(text: steps.toString()),
              onChanged: (value) {
                steps = int.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: AppColors.lightGreen, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '≈ ${(steps / 1300).toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              fitnessProvider.updateTodayData(steps: steps);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$steps steps logged'),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightGreen,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

/// Dialog to input sleep hours
Future<void> showSleepInputDialog(
  BuildContext context,
  FitnessProvider fitnessProvider,
) async {
  double sleepHours = fitnessProvider.getTodayData().sleepHours;

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Log Sleep'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Hours of sleep'),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    if (sleepHours > 0) sleepHours -= 0.5;
                  }),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${sleepHours.toStringAsFixed(1)}h',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() {
                    if (sleepHours < 14) sleepHours += 0.5;
                  }),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.nights_stay, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      sleepHours >= 7 && sleepHours <= 9
                          ? 'Great sleep! 😴'
                          : sleepHours > 9
                          ? 'Too much sleep'
                          : 'Need more sleep',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              fitnessProvider.updateTodayData(sleepHours: sleepHours);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${sleepHours.toStringAsFixed(1)} hours logged',
                  ),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

/// Dialog to input heart rate (BPM)
Future<void> showHeartRateInputDialog(
  BuildContext context,
  FitnessProvider fitnessProvider,
) async {
  int bpm = fitnessProvider.getTodayData().bpm;

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Log Heart Rate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Heart Rate',
                suffixText: 'BPM',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.favorite),
              ),
              controller: TextEditingController(text: bpm.toString()),
              onChanged: (value) {
                bpm = int.tryParse(value) ?? 72;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: AppColors.danger, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      bpm < 60
                          ? 'Low - rest more'
                          : bpm > 100
                          ? 'High - cool down'
                          : 'Normal range',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              fitnessProvider.updateTodayData(bpm: bpm);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$bpm BPM logged'),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
