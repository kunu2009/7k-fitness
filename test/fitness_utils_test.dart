// test/fitness_utils_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker/utils/fitness_utils.dart';

void main() {
  group('FitnessUtils', () {
    group('formatDate', () {
      test('formats date correctly', () {
        final date = DateTime(2025, 10, 16);
        final formatted = FitnessUtils.formatDate(date);
        expect(formatted, 'Oct 16, 2025');
      });
    });

    group('formatDuration', () {
      test('formats duration correctly', () {
        final duration = Duration(hours: 1, minutes: 30, seconds: 45);
        final formatted = FitnessUtils.formatDuration(duration);
        expect(formatted, '01:30:45');
      });

      test('formats zero duration', () {
        final duration = Duration.zero;
        final formatted = FitnessUtils.formatDuration(duration);
        expect(formatted, '00:00:00');
      });
    });

    group('calculateCalories', () {
      test('calculates running calories correctly', () {
        final calories = FitnessUtils.calculateCalories('running', 30);
        expect(calories, 300.0); // 10 * 30
      });

      test('calculates cycling calories correctly', () {
        final calories = FitnessUtils.calculateCalories('cycling', 30);
        expect(calories, 240.0); // 8 * 30
      });

      test('handles unknown activity', () {
        final calories = FitnessUtils.calculateCalories('unknown', 30);
        expect(calories, 150.0); // 5 * 30 (default)
      });
    });

    group('getStepsBadge', () {
      test('returns excellent badge for 10000+ steps', () {
        final badge = FitnessUtils.getStepsBadge(10000);
        expect(badge, '🏆 Excellent');
      });

      test('returns great badge for 8000+ steps', () {
        final badge = FitnessUtils.getStepsBadge(8000);
        expect(badge, '⭐ Great');
      });

      test('returns good badge for 5000+ steps', () {
        final badge = FitnessUtils.getStepsBadge(5000);
        expect(badge, '👍 Good');
      });

      test('returns keep going badge for less steps', () {
        final badge = FitnessUtils.getStepsBadge(3000);
        expect(badge, '🔄 Keep Going');
      });
    });

    group('getHydrationStatus', () {
      test('returns well hydrated status for 8+ glasses', () {
        final status = FitnessUtils.getHydrationStatus(8);
        expect(status, '✅ Well Hydrated');
      });

      test('returns good hydration for 5+ glasses', () {
        final status = FitnessUtils.getHydrationStatus(5);
        expect(status, '💧 Good Hydration');
      });

      test('returns drink more water for less glasses', () {
        final status = FitnessUtils.getHydrationStatus(3);
        expect(status, '⚠️ Drink More Water');
      });
    });

    group('getSleepQuality', () {
      test('returns excellent sleep for 7.5-9 hours', () {
        final quality = FitnessUtils.getSleepQuality(8.0);
        expect(quality, '😴 Excellent Sleep');
      });

      test('returns good sleep for 6.5+ hours', () {
        final quality = FitnessUtils.getSleepQuality(7.0);
        expect(quality, '👍 Good Sleep');
      });

      test('returns need more sleep for less hours', () {
        final quality = FitnessUtils.getSleepQuality(5.0);
        expect(quality, '⚠️ Need More Sleep');
      });
    });

    group('calculateProgress', () {
      test('calculates progress percentage correctly', () {
        final progress = FitnessUtils.calculateProgress(750, 1000);
        expect(progress, 75.0);
      });

      test('caps progress at 100 percent', () {
        final progress = FitnessUtils.calculateProgress(1500, 1000);
        expect(progress, 100.0);
      });

      test('returns 0 for 0 target', () {
        final progress = FitnessUtils.calculateProgress(500, 0);
        expect(progress, 0.0);
      });
    });

    group('getDayAbbr', () {
      test('returns correct abbreviation for Monday', () {
        expect(FitnessUtils.getDayAbbr(1), 'Mon');
      });

      test('returns correct abbreviation for Friday', () {
        expect(FitnessUtils.getDayAbbr(5), 'Fri');
      });

      test('returns correct abbreviation for Sunday', () {
        expect(FitnessUtils.getDayAbbr(7), 'Sun');
      });
    });

    group('getGreeting', () {
      test('returns valid greeting', () {
        final greeting = FitnessUtils.getGreeting();
        expect(
          greeting,
          anyOf('Good Morning', 'Good Afternoon', 'Good Evening', 'Good Night'),
        );
      });
    });

    group('formatLargeNumber', () {
      test('formats millions correctly', () {
        expect(FitnessUtils.formatLargeNumber(1500000), '1.5M');
      });

      test('formats thousands correctly', () {
        expect(FitnessUtils.formatLargeNumber(5500), '5.5k');
      });

      test('returns number as string if less than 1000', () {
        expect(FitnessUtils.formatLargeNumber(500), '500');
      });
    });

    group('isValidEmail', () {
      test('validates correct email', () {
        expect(FitnessUtils.isValidEmail('user@example.com'), true);
      });

      test('rejects invalid email', () {
        expect(FitnessUtils.isValidEmail('invalid-email'), false);
      });

      test('rejects email without domain', () {
        expect(FitnessUtils.isValidEmail('user@'), false);
      });
    });

    group('isToday', () {
      test('returns true for today', () {
        expect(FitnessUtils.isToday(DateTime.now()), true);
      });

      test('returns false for tomorrow', () {
        final tomorrow = DateTime.now().add(Duration(days: 1));
        expect(FitnessUtils.isToday(tomorrow), false);
      });

      test('returns false for yesterday', () {
        final yesterday = DateTime.now().subtract(Duration(days: 1));
        expect(FitnessUtils.isToday(yesterday), false);
      });
    });

    group('getIntensityLevel', () {
      test('returns low for heart rate < 100', () {
        expect(FitnessUtils.getIntensityLevel(90), 'Low');
      });

      test('returns moderate for 100-130 bpm', () {
        expect(FitnessUtils.getIntensityLevel(120), 'Moderate');
      });

      test('returns high for 130-160 bpm', () {
        expect(FitnessUtils.getIntensityLevel(150), 'High');
      });

      test('returns very high for 160+ bpm', () {
        expect(FitnessUtils.getIntensityLevel(170), 'Very High');
      });
    });

    group('calculateBMI', () {
      test('calculates BMI correctly', () {
        // weight: 70 kg, height: 175 cm
        final bmi = FitnessUtils.calculateBMI(70, 175);
        expect(bmi, closeTo(22.86, 0.01));
      });
    });

    group('getBMICategory', () {
      test('returns underweight for BMI < 18.5', () {
        expect(FitnessUtils.getBMICategory(18.0), 'Underweight');
      });

      test('returns normal weight for BMI 18.5-25', () {
        expect(FitnessUtils.getBMICategory(22.0), 'Normal weight');
      });

      test('returns overweight for BMI 25-30', () {
        expect(FitnessUtils.getBMICategory(27.0), 'Overweight');
      });

      test('returns obese for BMI 30+', () {
        expect(FitnessUtils.getBMICategory(32.0), 'Obese');
      });
    });
  });
}
