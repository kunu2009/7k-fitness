# 📋 Implementation Plan - Technical Specifications

> **Purpose:** Detailed technical implementation guide for each major feature

---

## 🏗️ Architecture Overview

### Current Architecture
```
lib/
├── main.dart                 # App entry point
├── theme/
│   └── app_theme.dart       # Theme configuration
├── models/
│   └── fitness_data.dart    # Data models
├── providers/
│   └── fitness_provider.dart # State management
├── screens/                  # UI screens
├── utils/                    # Utility functions
└── widgets/                  # Reusable widgets
```

### Proposed Architecture (Enhanced)
```
lib/
├── main.dart
├── app/
│   ├── app.dart              # App configuration
│   ├── routes.dart           # Navigation routes
│   └── themes/
│       ├── app_theme.dart
│       ├── colors.dart
│       └── typography.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   │   ├── api_client.dart
│   │   └── endpoints.dart
│   ├── storage/
│   │   ├── local_storage.dart
│   │   └── secure_storage.dart
│   └── utils/
├── data/
│   ├── models/
│   │   ├── user/
│   │   ├── workout/
│   │   ├── nutrition/
│   │   ├── social/
│   │   └── achievement/
│   ├── repositories/
│   │   ├── user_repository.dart
│   │   ├── workout_repository.dart
│   │   ├── nutrition_repository.dart
│   │   └── social_repository.dart
│   └── datasources/
│       ├── local/
│       └── remote/
├── domain/
│   ├── entities/
│   ├── repositories/         # Abstract interfaces
│   └── usecases/
│       ├── workout/
│       ├── nutrition/
│       └── social/
├── presentation/
│   ├── providers/            # State management
│   ├── screens/
│   │   ├── home/
│   │   ├── workout/
│   │   ├── nutrition/
│   │   ├── social/
│   │   ├── profile/
│   │   └── settings/
│   └── widgets/
│       ├── common/
│       ├── charts/
│       └── forms/
└── services/
    ├── health_service.dart   # Apple Health/Google Fit
    ├── notification_service.dart
    ├── analytics_service.dart
    └── ai_service.dart
```

---

## 📦 Dependencies to Add

### Phase 1 Dependencies
```yaml
dependencies:
  # State Management (already have provider)
  provider: ^6.1.0
  
  # Database
  sqflite: ^2.3.0              # Local SQLite database
  path: ^1.8.3
  
  # Health Integration
  health: ^10.0.0              # Apple Health & Google Fit
  permission_handler: ^11.0.0  # Handle permissions
  
  # Notifications
  flutter_local_notifications: ^16.0.0
  
  # Animations
  lottie: ^2.7.0               # Achievement animations
  
  # Images
  cached_network_image: ^3.3.0
  
  # Utils
  uuid: ^4.2.0
  equatable: ^2.0.5
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

### Phase 3 Dependencies (Nutrition)
```yaml
dependencies:
  # Barcode Scanner
  mobile_scanner: ^3.5.0
  
  # Food API
  http: ^1.1.0                 # API calls
  
  # Image handling
  image_picker: ^1.0.0
```

### Phase 4 Dependencies (Social)
```yaml
dependencies:
  # Authentication
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
  google_sign_in: ^6.1.0
  sign_in_with_apple: ^5.0.0
  
  # Cloud Storage
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  
  # Push Notifications
  firebase_messaging: ^14.7.0
```

### Phase 5 Dependencies (AI)
```yaml
dependencies:
  # ML
  tflite_flutter: ^0.10.0      # On-device ML
  
  # Analytics
  firebase_analytics: ^10.8.0
```

---

## 🗄️ Database Schema

### SQLite Local Database

```sql
-- Users Table
CREATE TABLE users (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT,
    age INTEGER,
    height REAL,
    weight REAL,
    gender TEXT,
    activity_level TEXT,
    daily_calorie_goal REAL,
    created_at TEXT,
    updated_at TEXT
);

-- Exercises Table
CREATE TABLE exercises (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    muscle_groups TEXT,  -- JSON array
    equipment TEXT,       -- JSON array
    difficulty TEXT,      -- beginner, intermediate, advanced
    instructions TEXT,    -- JSON array of steps
    gif_url TEXT,
    video_url TEXT,
    calories_per_minute REAL,
    created_at TEXT
);

-- Workouts Table
CREATE TABLE workouts (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    name TEXT,
    date TEXT,
    duration_minutes INTEGER,
    calories_burned REAL,
    notes TEXT,
    is_completed INTEGER DEFAULT 0,
    created_at TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Workout Exercises (Junction Table)
CREATE TABLE workout_exercises (
    id TEXT PRIMARY KEY,
    workout_id TEXT,
    exercise_id TEXT,
    order_index INTEGER,
    sets_completed INTEGER,
    target_sets INTEGER,
    target_reps INTEGER,
    weight_kg REAL,
    rest_seconds INTEGER,
    notes TEXT,
    FOREIGN KEY (workout_id) REFERENCES workouts(id),
    FOREIGN KEY (exercise_id) REFERENCES exercises(id)
);

-- Sets Table (detailed tracking)
CREATE TABLE exercise_sets (
    id TEXT PRIMARY KEY,
    workout_exercise_id TEXT,
    set_number INTEGER,
    reps INTEGER,
    weight_kg REAL,
    duration_seconds INTEGER,
    is_warmup INTEGER DEFAULT 0,
    is_dropset INTEGER DEFAULT 0,
    is_failure INTEGER DEFAULT 0,
    rest_after_seconds INTEGER,
    completed_at TEXT,
    FOREIGN KEY (workout_exercise_id) REFERENCES workout_exercises(id)
);

-- Programs Table
CREATE TABLE programs (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    difficulty TEXT,
    duration_weeks INTEGER,
    days_per_week INTEGER,
    category TEXT,
    image_url TEXT,
    is_premium INTEGER DEFAULT 0,
    created_at TEXT
);

-- Program Days Table
CREATE TABLE program_days (
    id TEXT PRIMARY KEY,
    program_id TEXT,
    day_number INTEGER,
    name TEXT,
    focus TEXT,
    FOREIGN KEY (program_id) REFERENCES programs(id)
);

-- User Programs (enrollment)
CREATE TABLE user_programs (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    program_id TEXT,
    start_date TEXT,
    current_day INTEGER DEFAULT 1,
    is_active INTEGER DEFAULT 1,
    completed_at TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (program_id) REFERENCES programs(id)
);

-- Goals Table
CREATE TABLE goals (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    type TEXT,  -- weight_loss, muscle_gain, strength, habit
    target_value REAL,
    current_value REAL,
    unit TEXT,
    start_date TEXT,
    target_date TEXT,
    is_completed INTEGER DEFAULT 0,
    completed_at TEXT,
    created_at TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Achievements Table
CREATE TABLE achievements (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    category TEXT,
    requirement_type TEXT,
    requirement_value REAL,
    points INTEGER DEFAULT 0,
    is_hidden INTEGER DEFAULT 0
);

-- User Achievements (unlocked)
CREATE TABLE user_achievements (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    achievement_id TEXT,
    unlocked_at TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (achievement_id) REFERENCES achievements(id)
);

-- Daily Logs Table
CREATE TABLE daily_logs (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    date TEXT,
    steps INTEGER DEFAULT 0,
    water_glasses INTEGER DEFAULT 0,
    sleep_hours REAL,
    weight_kg REAL,
    calories_consumed REAL DEFAULT 0,
    calories_burned REAL DEFAULT 0,
    notes TEXT,
    mood TEXT,
    energy_level INTEGER,
    created_at TEXT,
    updated_at TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Streaks Table
CREATE TABLE streaks (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    type TEXT,  -- workout, logging, steps
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_activity_date TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Foods Table (cached from API)
CREATE TABLE foods (
    id TEXT PRIMARY KEY,
    barcode TEXT,
    name TEXT NOT NULL,
    brand TEXT,
    serving_size REAL,
    serving_unit TEXT,
    calories REAL,
    protein REAL,
    carbs REAL,
    fat REAL,
    fiber REAL,
    sugar REAL,
    sodium REAL,
    is_user_created INTEGER DEFAULT 0,
    created_at TEXT
);

-- Meal Logs Table
CREATE TABLE meal_logs (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    date TEXT,
    meal_type TEXT,  -- breakfast, lunch, dinner, snack
    food_id TEXT,
    serving_count REAL DEFAULT 1,
    calories REAL,
    protein REAL,
    carbs REAL,
    fat REAL,
    logged_at TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (food_id) REFERENCES foods(id)
);

-- Indexes for performance
CREATE INDEX idx_workouts_user_date ON workouts(user_id, date);
CREATE INDEX idx_daily_logs_user_date ON daily_logs(user_id, date);
CREATE INDEX idx_meal_logs_user_date ON meal_logs(user_id, date);
CREATE INDEX idx_exercises_muscle ON exercises(muscle_groups);
CREATE INDEX idx_foods_barcode ON foods(barcode);
```

---

## 🔌 API Integrations

### Health Platform Integration

```dart
// services/health_service.dart
import 'package:health/health.dart';

class HealthService {
  final HealthFactory _health = HealthFactory();
  
  // Data types to read
  static const List<HealthDataType> readTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WEIGHT,
    HealthDataType.WORKOUT,
  ];
  
  // Data types to write
  static const List<HealthDataType> writeTypes = [
    HealthDataType.WORKOUT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WEIGHT,
  ];
  
  Future<bool> requestPermissions() async {
    return await _health.requestAuthorization(
      readTypes,
      permissions: writeTypes.map((e) => HealthDataAccess.READ_WRITE).toList(),
    );
  }
  
  Future<int> getStepsToday() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    
    final steps = await _health.getTotalStepsInInterval(midnight, now);
    return steps ?? 0;
  }
  
  Future<void> writeWorkout({
    required DateTime start,
    required DateTime end,
    required double calories,
    required String workoutType,
  }) async {
    await _health.writeWorkoutData(
      HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING,
      start,
      end,
      totalEnergyBurned: calories.toInt(),
      totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
    );
  }
}
```

### Food Database API

```dart
// services/food_api_service.dart
// Using Open Food Facts API (free, open-source)

class FoodApiService {
  static const String baseUrl = 'https://world.openfoodfacts.org/api/v2';
  
  Future<Food?> searchByBarcode(String barcode) async {
    final response = await http.get(
      Uri.parse('$baseUrl/product/$barcode.json'),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 1) {
        return Food.fromOpenFoodFacts(data['product']);
      }
    }
    return null;
  }
  
  Future<List<Food>> searchByName(String query, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search?search_terms=$query&page=$page&page_size=20'),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['products'] as List)
          .map((p) => Food.fromOpenFoodFacts(p))
          .toList();
    }
    return [];
  }
}
```

---

## 🎨 UI Components to Build

### Common Widgets

```dart
// widgets/common/stat_card.dart
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  
  // Implementation...
}

// widgets/common/progress_ring.dart
class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color color;
  final Widget? child;
  
  // Implementation...
}

// widgets/common/achievement_badge.dart
class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final VoidCallback? onTap;
  
  // Implementation with Lottie animation...
}

// widgets/workout/exercise_card.dart
class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int? sets;
  final int? reps;
  final VoidCallback? onTap;
  
  // Implementation...
}

// widgets/workout/rest_timer.dart
class RestTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback onComplete;
  final VoidCallback? onSkip;
  
  // Implementation with countdown...
}

// widgets/nutrition/food_item.dart
class FoodItem extends StatelessWidget {
  final Food food;
  final double? servings;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  
  // Implementation...
}

// widgets/nutrition/macro_breakdown.dart
class MacroBreakdown extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;
  final double? proteinGoal;
  final double? carbsGoal;
  final double? fatGoal;
  
  // Implementation with pie chart...
}
```

---

## 🧪 Testing Strategy

### Unit Tests
```dart
// test/repositories/workout_repository_test.dart
void main() {
  group('WorkoutRepository', () {
    late WorkoutRepository repository;
    late MockDatabase mockDb;
    
    setUp(() {
      mockDb = MockDatabase();
      repository = WorkoutRepository(database: mockDb);
    });
    
    test('should create workout', () async {
      final workout = Workout(name: 'Test Workout');
      await repository.create(workout);
      verify(mockDb.insert('workouts', workout.toMap())).called(1);
    });
    
    test('should calculate total volume', () {
      final workout = Workout(
        exercises: [
          WorkoutExercise(sets: 3, reps: 10, weight: 50),
          WorkoutExercise(sets: 3, reps: 10, weight: 40),
        ],
      );
      expect(workout.totalVolume, equals(2700)); // (3*10*50) + (3*10*40)
    });
  });
}
```

### Widget Tests
```dart
// test/widgets/rest_timer_test.dart
void main() {
  testWidgets('RestTimer counts down', (tester) async {
    bool completed = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: RestTimer(
          seconds: 60,
          onComplete: () => completed = true,
        ),
      ),
    );
    
    expect(find.text('1:00'), findsOneWidget);
    
    // Fast forward time
    await tester.pump(Duration(seconds: 30));
    expect(find.text('0:30'), findsOneWidget);
    
    await tester.pump(Duration(seconds: 30));
    expect(completed, isTrue);
  });
}
```

### Integration Tests
```dart
// integration_test/workout_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Complete workout flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // Navigate to workout
    await tester.tap(find.byIcon(Icons.fitness_center));
    await tester.pumpAndSettle();
    
    // Start workout
    await tester.tap(find.text('Start Workout'));
    await tester.pumpAndSettle();
    
    // Add exercise
    await tester.tap(find.text('Add Exercise'));
    await tester.pumpAndSettle();
    
    // Select exercise
    await tester.tap(find.text('Bench Press'));
    await tester.pumpAndSettle();
    
    // Log set
    await tester.tap(find.text('Log Set'));
    await tester.pumpAndSettle();
    
    // Verify set logged
    expect(find.text('1 set'), findsOneWidget);
  });
}
```

---

## 📱 Platform-Specific Setup

### iOS Configuration

```xml
<!-- ios/Runner/Info.plist -->
<key>NSHealthShareUsageDescription</key>
<string>We need access to your health data to track your fitness progress</string>
<key>NSHealthUpdateUsageDescription</key>
<string>We need to write workout data to Apple Health</string>
<key>NSCameraUsageDescription</key>
<string>Camera is used to scan food barcodes</string>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### Android Configuration

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

<!-- For Google Fit -->
<uses-permission android:name="android.permission.health.READ_STEPS"/>
<uses-permission android:name="android.permission.health.WRITE_EXERCISE"/>
```

---

## 🚀 Deployment Checklist

### Pre-Launch
- [ ] App icons for all platforms
- [ ] Splash screen
- [ ] App Store screenshots
- [ ] App Store description
- [ ] Privacy policy URL
- [ ] Terms of service URL
- [ ] Support email configured
- [ ] Analytics configured
- [ ] Crash reporting configured
- [ ] Performance monitoring setup

### App Store Optimization
- [ ] Keywords research
- [ ] Localized descriptions
- [ ] Feature graphics
- [ ] Video preview (optional)
- [ ] Category selection
- [ ] Age rating

### Launch Day
- [ ] Staged rollout (10% → 50% → 100%)
- [ ] Monitor crash reports
- [ ] Monitor reviews
- [ ] Support team ready
- [ ] Social media announcement

---

*Next: See [BEST_PRACTICES.md](./BEST_PRACTICES.md) for what to do and what to avoid*
