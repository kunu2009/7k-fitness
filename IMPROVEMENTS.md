# Fitness Tracker - Improvement Plan

## Overview
This document outlines the planned improvements and new features for the Fitness Tracker app.
All features are designed to work **offline-first** with **no AI dependencies** (except optional meal photo recognition with user-provided API key).

---

## 📋 Features to Implement

### 1. ✅ Workout Streak & Gamification (Solo Mode)
### 2. ✅ Body Transformation Timeline (Photo Progress)
### 3. ✅ Smart Workout Suggestions (Rule-Based, No AI)
### 4. ✅ Enhanced Nutrition Screen (with optional AI meal recognition)
### 5. ✅ Better Workout Tracking
### 6. ✅ Progress Screen Enhancements
### 7. ✅ Home Screen Dashboard Improvements
### 8. ✅ Overall UX Enhancements

---

## 🎮 Feature 1: Workout Streak & Gamification (Solo)

### Description
Track daily workout streaks, earn XP points, and unlock achievements for consistency.

### Components to Create/Modify

#### New Files:
- `lib/models/gamification.dart` - Streak, XP, Badge models
- `lib/providers/gamification_provider.dart` - State management
- `lib/screens/achievements/badges_screen.dart` - View all badges
- `lib/widgets/streak_widget.dart` - Streak display widget

#### Modifications:
- `lib/screens/home/home_screen.dart` - Add streak widget
- `lib/providers/fitness_provider.dart` - Track workout completions

### Data Model:
```dart
class UserStreak {
  int currentStreak;
  int longestStreak;
  DateTime lastWorkoutDate;
  int totalXP;
  int level;
  List<String> unlockedBadges;
}

class Badge {
  String id;
  String name;
  String description;
  String iconPath;
  BadgeType type; // streak, workout_count, weight_lifted, etc.
  int requirement;
  bool isUnlocked;
}
```

### XP System:
| Action | XP Earned |
|--------|-----------|
| Complete workout | 100 XP |
| Log all meals | 50 XP |
| Hit water goal | 25 XP |
| Hit step goal | 50 XP |
| 7-day streak bonus | 200 XP |
| 30-day streak bonus | 1000 XP |

### Badges to Implement:
- 🔥 **First Flame** - Complete first workout
- 📅 **Week Warrior** - 7-day streak
- 🏆 **Monthly Master** - 30-day streak
- 💯 **Century** - 100 workouts completed
- 🏋️ **Heavy Lifter** - Lift 10,000 kg total
- 🚶 **Step Champion** - 100,000 total steps
- 💧 **Hydration Hero** - 30 days water goal met
- 🥗 **Nutrition Ninja** - Log meals for 30 days

### Implementation Steps:
1. Create gamification model and provider
2. Add streak tracking logic
3. Create badge definitions
4. Build streak widget for home screen
5. Create badges/achievements detail screen
6. Add XP notifications on actions
7. Store data in SharedPreferences

---

## 📸 Feature 2: Body Transformation Timeline

### Description
Take progress photos, compare before/after, and visualize transformation over time.

### Components to Create/Modify

#### New Files:
- `lib/models/progress_photo.dart` - Photo model
- `lib/providers/photo_provider.dart` - Photo state management
- `lib/screens/progress/photo_timeline_screen.dart` - Timeline view
- `lib/screens/progress/photo_comparison_screen.dart` - Side-by-side compare
- `lib/screens/progress/take_photo_screen.dart` - Camera screen
- `lib/widgets/photo_card.dart` - Photo display widget

#### Modifications:
- `lib/screens/progress/progress_screen.dart` - Add photo section

### Data Model:
```dart
class ProgressPhoto {
  String id;
  DateTime date;
  String imagePath; // Local storage path
  PhotoType type; // front, side, back
  double? weight;
  Map<String, double>? measurements; // Optional linked measurements
  String? notes;
}

enum PhotoType { front, side, back }
```

### Features:
- 📷 Take photos with pose guide overlay
- 🖼️ View timeline gallery
- ↔️ Side-by-side comparison slider
- 📊 Overlay measurements on photos
- 📅 Filter by date range
- 🔒 Photos stored locally only (privacy)

### Implementation Steps:
1. Create photo model
2. Set up local image storage (path_provider)
3. Build camera/gallery picker screen
4. Create timeline gallery view
5. Implement comparison slider widget
6. Add photo section to progress screen
7. Optional: Add pose guide overlay

---

## 🧠 Feature 3: Smart Workout Suggestions (Rule-Based)

### Description
Suggest today's workout based on training history, muscle recovery, and user preferences.
**No AI - Pure rule-based logic.**

### Components to Create/Modify

#### New Files:
- `lib/services/workout_suggestion_service.dart` - Suggestion logic
- `lib/widgets/suggested_workout_card.dart` - Suggestion display

#### Modifications:
- `lib/screens/home/home_screen.dart` - Add suggestion card
- `lib/screens/workout/workout_screen.dart` - Quick start suggested

### Suggestion Logic (Rule-Based):

```dart
class WorkoutSuggestionService {
  // Rules:
  // 1. Don't suggest muscles trained in last 48 hours
  // 2. Follow push/pull/legs or upper/lower split
  // 3. Consider user's preferred workout days
  // 4. Factor in available equipment
  // 5. Match workout duration to available time
  
  WorkoutSuggestion getSuggestion({
    required List<WorkoutSession> recentWorkouts,
    required List<MuscleGroup> preferredMuscles,
    required List<Equipment> availableEquipment,
    required int availableMinutes,
  });
}
```

### Muscle Recovery Rules:
| Muscle Group | Recovery Time |
|--------------|---------------|
| Large (Legs, Back, Chest) | 72 hours |
| Medium (Shoulders, Arms) | 48 hours |
| Small (Abs, Calves) | 24 hours |

### Implementation Steps:
1. Create suggestion service with rules
2. Track last trained muscle groups
3. Build suggestion algorithm
4. Create suggestion card widget
5. Add to home screen
6. Quick-start button to begin suggested workout

---

## 🍽️ Feature 4: Enhanced Nutrition Screen

### Description
Improve food logging with recipes, quick-add, and optional AI meal recognition.

### Components to Create/Modify

#### New Files:
- `lib/models/recipe.dart` - Recipe model
- `lib/screens/nutrition/recipe_builder_screen.dart` - Create recipes
- `lib/screens/nutrition/quick_add_screen.dart` - Frequent meals
- `lib/screens/nutrition/meal_recognition_screen.dart` - AI photo (optional)
- `lib/services/meal_recognition_service.dart` - API integration
- `lib/screens/settings/api_settings_screen.dart` - API key input

#### Modifications:
- `lib/screens/nutrition/nutrition_screen.dart` - Add new options
- `lib/screens/settings/settings_screen.dart` - Add API settings

### Data Model:
```dart
class Recipe {
  String id;
  String name;
  List<RecipeIngredient> ingredients;
  int servings;
  NutritionInfo totalNutrition;
  NutritionInfo perServingNutrition;
  String? imageUrl;
  bool isFavorite;
}

class RecipeIngredient {
  String foodId;
  double quantity;
  String unit;
}

class QuickMeal {
  String id;
  String name;
  List<FoodItem> foods;
  int useCount; // For sorting by frequency
}
```

### AI Meal Recognition (Optional):
- User provides their own API key (OpenAI/Google Vision)
- Photo → API → Identified foods
- User confirms/edits before logging
- Works without API key (manual entry only)

### API Key Storage:
```dart
// Stored securely in SharedPreferences (encrypted)
class ApiSettings {
  String? mealRecognitionApiKey;
  ApiProvider provider; // openai, google_vision
}
```

### Implementation Steps:
1. Create recipe model and storage
2. Build recipe builder screen
3. Implement quick-add frequent meals
4. Add API settings screen
5. Create meal recognition service (optional)
6. Update nutrition screen with new options
7. Add weekly nutrition summary

---

## 🏋️ Feature 5: Better Workout Tracking

### Description
Enhanced workout experience with supersets, rest timers, and progress comparison.

### Components to Create/Modify

#### New Files:
- `lib/widgets/rest_timer_widget.dart` - Auto rest timer
- `lib/widgets/previous_workout_overlay.dart` - Compare last session
- `lib/screens/workout/one_rep_max_screen.dart` - 1RM calculator

#### Modifications:
- `lib/screens/workout/active_workout_screen.dart` - Add features
- `lib/models/workout_session.dart` - Support supersets

### New Features:

#### Superset Support:
```dart
class ExerciseSet {
  // Existing fields...
  String? supersetGroupId; // Group exercises together
  int orderInSuperset;
}
```

#### Auto Rest Timer:
- Configurable rest duration (30s, 60s, 90s, 120s)
- Auto-start after logging set
- Audio/vibration alert when done
- Skip button available

#### Previous Workout Overlay:
- Show last session's weight/reps
- Highlight if current > previous (PR!)
- Easy +2.5kg / +5kg buttons

#### One Rep Max Calculator:
- Input weight and reps
- Calculate estimated 1RM
- Track 1RM history per exercise
- Formulas: Epley, Brzycki, Lombardi

### Implementation Steps:
1. Add superset grouping to workout model
2. Create enhanced rest timer widget
3. Build previous workout comparison
4. Implement 1RM calculator
5. Add PR detection and celebration
6. Update active workout screen

---

## 📊 Feature 6: Progress Screen Enhancements

### Description
Better visualizations, insights, and export options.

### Components to Create/Modify

#### New Files:
- `lib/screens/progress/insights_screen.dart` - Smart insights
- `lib/screens/progress/export_report_screen.dart` - PDF export
- `lib/widgets/charts/body_composition_chart.dart` - Pie chart
- `lib/services/insights_service.dart` - Generate insights

#### Modifications:
- `lib/screens/progress/progress_screen.dart` - Add new sections

### New Charts:
- 📊 Body composition pie chart (muscle/fat estimate)
- 📈 Strength progression per exercise
- 📉 Weight trend with moving average
- 🔄 Period comparison (this week vs last week)

### Insights (Rule-Based):
```dart
class InsightsService {
  List<Insight> generateInsights(UserData data) {
    // Examples:
    // "You're 15% stronger on chest exercises this month"
    // "Best workout day: Monday (avg 45 min)"
    // "You've hit your step goal 80% of days"
    // "Predicted goal weight date: Jan 15, 2026"
  }
}
```

### Export Options:
- 📄 PDF report with charts
- 📊 CSV data export
- 📅 Weekly/Monthly summaries
- 📧 Share via email/apps

### Implementation Steps:
1. Create new chart widgets
2. Build insights service
3. Implement PDF generation
4. Add period comparison
5. Create export screen
6. Update progress screen layout

---

## 🏠 Feature 7: Home Screen Dashboard Improvements

### Description
Customizable, informative dashboard with quick actions.

### Components to Create/Modify

#### New Files:
- `lib/widgets/dashboard/quick_actions_widget.dart` - Quick buttons
- `lib/widgets/dashboard/today_summary_widget.dart` - Daily overview
- `lib/widgets/dashboard/motivation_widget.dart` - Quotes
- `lib/screens/home/customize_dashboard_screen.dart` - Widget order

#### Modifications:
- `lib/screens/home/home_screen.dart` - New layout
- `lib/services/settings_service.dart` - Dashboard preferences

### Dashboard Widgets:
1. **Today's Summary Card**
   - Calories in/out
   - Steps / Step goal
   - Water / Water goal
   - Workout status (done/pending)

2. **Quick Actions Row**
   - 💧 Add Water (+250ml)
   - 🍽️ Log Meal
   - 🏃 Start Workout
   - ⚖️ Log Weight

3. **Streak & XP Display**
   - Current streak fire 🔥
   - XP bar with level

4. **Suggested Workout Card**
   - Today's recommendation
   - One-tap start

5. **Motivation Quote**
   - Daily rotating quotes
   - 100+ fitness quotes database

### Customization:
- Drag & drop to reorder widgets
- Show/hide specific widgets
- Accent color picker
- Dark/Light theme toggle

### Implementation Steps:
1. Create individual widget components
2. Build widget ordering system
3. Add quick action buttons
4. Create motivation quotes database
5. Implement customization screen
6. Add theme/color settings

---

## ✨ Feature 8: Overall UX Enhancements

### Description
Polish the app with better onboarding, animations, and platform features.

### Components to Create/Modify

#### New Files:
- `lib/screens/onboarding/tutorial_screen.dart` - Interactive tutorial
- `lib/widgets/celebration_overlay.dart` - Confetti animations
- `lib/services/backup_service.dart` - Local backup/restore

#### Modifications:
- Multiple screens for animations
- `lib/main.dart` - Theme improvements

### Enhancements:

#### Interactive Onboarding:
- Step-by-step feature tour
- Highlight key buttons
- Skip option available
- Show on first launch only

#### Animations:
- Page transitions (slide, fade)
- Button press feedback
- Confetti on achievements/PRs
- Progress bar animations
- Pull-to-refresh animations

#### Bottom Navigation Improvements:
- 5 main tabs: Home, Workout, Nutrition, Progress, Profile
- Long-press for quick actions
- Badge indicators (streak, notifications)

#### Data Management:
- Local backup to file
- Restore from backup
- Export all data as JSON
- Clear data option

#### Offline Mode:
- All features work offline
- Data synced to local storage
- No internet required

### Implementation Steps:
1. Create tutorial overlay system
2. Add page transition animations
3. Build celebration confetti widget
4. Implement backup/restore service
5. Add pull-to-refresh where needed
6. Polish bottom navigation
7. Add haptic feedback

---

## 📅 Implementation Schedule

### Phase 1 (Core Features) - Week 1-2
- [ ] Gamification system (streaks, XP, badges)
- [ ] Smart workout suggestions
- [ ] Quick actions on home screen

### Phase 2 (Nutrition & Tracking) - Week 3-4
- [ ] Recipe builder
- [ ] Quick-add frequent meals
- [ ] Optional AI meal recognition
- [ ] Better workout tracking (supersets, rest timer)

### Phase 3 (Progress & Photos) - Week 5-6
- [ ] Photo timeline
- [ ] Photo comparison
- [ ] Enhanced charts
- [ ] Insights system

### Phase 4 (Polish) - Week 7-8
- [ ] Dashboard customization
- [ ] Animations & transitions
- [ ] Onboarding tutorial
- [ ] Backup/restore
- [ ] Final testing

---

## 🗂️ File Structure (New Files)

```
lib/
├── models/
│   ├── gamification.dart       [NEW]
│   ├── progress_photo.dart     [NEW]
│   └── recipe.dart             [NEW]
├── providers/
│   ├── gamification_provider.dart  [NEW]
│   └── photo_provider.dart         [NEW]
├── services/
│   ├── workout_suggestion_service.dart  [NEW]
│   ├── meal_recognition_service.dart    [NEW]
│   ├── insights_service.dart            [NEW]
│   └── backup_service.dart              [NEW]
├── screens/
│   ├── progress/
│   │   ├── photo_timeline_screen.dart    [NEW]
│   │   ├── photo_comparison_screen.dart  [NEW]
│   │   ├── insights_screen.dart          [NEW]
│   │   └── export_report_screen.dart     [NEW]
│   ├── nutrition/
│   │   ├── recipe_builder_screen.dart    [NEW]
│   │   ├── quick_add_screen.dart         [NEW]
│   │   └── meal_recognition_screen.dart  [NEW]
│   ├── workout/
│   │   └── one_rep_max_screen.dart       [NEW]
│   ├── settings/
│   │   └── api_settings_screen.dart      [NEW]
│   ├── achievements/
│   │   └── badges_screen.dart            [NEW]
│   └── onboarding/
│       └── tutorial_screen.dart          [NEW]
└── widgets/
    ├── streak_widget.dart                [NEW]
    ├── suggested_workout_card.dart       [NEW]
    ├── rest_timer_widget.dart            [NEW]
    ├── celebration_overlay.dart          [NEW]
    ├── photo_card.dart                   [NEW]
    └── dashboard/
        ├── quick_actions_widget.dart     [NEW]
        ├── today_summary_widget.dart     [NEW]
        └── motivation_widget.dart        [NEW]
```

---

## ✅ Summary Checklist

- [ ] **Gamification**: Streaks, XP, Badges (Solo mode)
- [ ] **Photo Progress**: Timeline, Comparison
- [ ] **Smart Suggestions**: Rule-based workout recommendations
- [ ] **Nutrition**: Recipes, Quick-add, Optional AI recognition
- [ ] **Workout**: Supersets, Rest timer, Previous comparison, 1RM
- [ ] **Progress**: New charts, Insights, Export
- [ ] **Dashboard**: Quick actions, Customization, Motivation
- [ ] **UX**: Onboarding, Animations, Backup/Restore

---

## 🚫 Excluded (As Requested)
- ❌ Social/Competition features
- ❌ AI-based features (except optional meal recognition with user API key)
- ❌ Cloud sync (local storage only)
- ❌ Leaderboards

---

*Last Updated: December 2, 2025*
