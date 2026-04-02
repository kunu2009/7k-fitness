import 'package:intl/intl.dart';

class FitnessUtils {
  // Format date to readable format
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format time duration
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // Calculate calories burned based on activity
  static double calculateCalories(String activity, int duration) {
    Map<String, double> caloriesPerMinute = {
      'running': 10.0,
      'cycling': 8.0,
      'swimming': 11.0,
      'walking': 4.0,
      'yoga': 4.5,
      'gym': 8.0,
    };

    double rate = caloriesPerMinute[activity.toLowerCase()] ?? 5.0;
    return rate * duration;
  }

  // Get achievement badge based on steps
  static String getStepsBadge(int steps) {
    if (steps >= 10000) return '🏆 Excellent';
    if (steps >= 8000) return '⭐ Great';
    if (steps >= 5000) return '👍 Good';
    return '🔄 Keep Going';
  }

  // Get hydration status
  static String getHydrationStatus(int glasses) {
    if (glasses >= 8) return '✅ Well Hydrated';
    if (glasses >= 5) return '💧 Good Hydration';
    return '⚠️ Drink More Water';
  }

  // Get sleep quality
  static String getSleepQuality(double hours) {
    if (hours >= 7.5 && hours <= 9) return '😴 Excellent Sleep';
    if (hours >= 6.5) return '👍 Good Sleep';
    return '⚠️ Need More Sleep';
  }

  // Calculate progress percentage
  static double calculateProgress(double current, double target) {
    if (target == 0) return 0;
    double progress = (current / target) * 100;
    return progress > 100 ? 100 : progress;
  }

  // Get day of week abbreviation
  static String getDayAbbr(int dayOfWeek) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dayOfWeek - 1];
  }

  // Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else if (hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  // Format large numbers with K, M suffix
  static String formatLargeNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Get week dates
  static List<DateTime> getWeekDates() {
    DateTime now = DateTime.now();
    DateTime firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(
      7,
      (index) => firstDayOfWeek.add(Duration(days: index)),
    );
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Get color based on intensity level
  static String getIntensityLevel(int heartRate) {
    if (heartRate < 100) return 'Low';
    if (heartRate < 130) return 'Moderate';
    if (heartRate < 160) return 'High';
    return 'Very High';
  }

  // Calculate BMI
  static double calculateBMI(double weight, double height) {
    // height in cm, weight in kg
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Format time to 12-hour format
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }
}
