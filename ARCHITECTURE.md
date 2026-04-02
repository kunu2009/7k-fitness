# Architecture & Data Flow Diagrams

## 📊 App Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   FITNESS TRACKER APP                   │
└─────────────────────────────────────────────────────────┘
                            │
                ┌───────────┼───────────┐
                │           │           │
         ┌──────▼──────┐   │       ┌────▼─────┐
         │   Theme     │   │       │  Models  │
         │   System    │   │       │          │
         │  (Colors)   │   │       │ Fitness  │
         └─────────────┘   │       │  Data    │
                           │       └──────────┘
                    ┌──────▼──────────┐
                    │   Provider      │
                    │  (State Mgmt)   │
                    │ FitnessProvider │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
    ┌───▼────┐          ┌────▼────┐          ┌───▼────┐
    │ Screens│          │ Widgets │          │ Utils  │
    ├────────┤          ├─────────┤          ├────────┤
    │Home    │          │Custom   │          │Fitness │
    │Progress│          │Metrics  │          │Utils   │
    │Workout │          │Cards    │          │(20+)   │
    │Stats   │          │Buttons  │          │        │
    └────────┘          └─────────┘          └────────┘
        │
        └────────────────┬─────────────────┘
                         │
            ┌────────────▼─────────────┐
            │  Bottom Navigation Bar   │
            │  (4 Tabs)                │
            └────────────────────────┘
```

## 🔄 Data Flow Diagram

```
                   USER INTERACTION
                          │
                          ▼
                    ┌─────────────┐
                    │  UI Widget  │
                    │  (Screen)   │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────────┐
                    │  Provider Method│
                    │  updateTodayData│
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Update Local    │
                    │ FitnessData     │
                    │ Object          │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Convert to JSON │
                    │ Serialize       │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │SharedPreferences│
                    │  Save Data      │
                    │ ('todayData')   │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │notifyListeners()│
                    │  Update State   │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Rebuild Widgets│
                    │ (Those watching)│
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Display Updated │
                    │ Data to User    │
                    └─────────────────┘
```

## 📁 File Structure Tree

```
fitness_tracker/
│
├── lib/
│   ├── main.dart                           [App Entry Point]
│   │
│   ├── theme/
│   │   └── app_theme.dart                  [Color Scheme & Theme]
│   │       └── AppColors (9 colors)
│   │       └── AppTheme.lightTheme()
│   │
│   ├── models/
│   │   └── fitness_data.dart               [Data Structures]
│   │       ├── FitnessData
│   │       ├── Exercise
│   │       └── Workout
│   │
│   ├── providers/
│   │   └── fitness_provider.dart           [State Management]
│   │       ├── _fitnessHistory
│   │       ├── _todayData
│   │       ├── updateTodayData()
│   │       └── getWeeklyData()
│   │
│   ├── screens/
│   │   ├── home/
│   │   │   └── home_screen.dart            [350 lines]
│   │   │       ├── Daily greeting
│   │   │       ├── Weekly calendar
│   │   │       ├── Stats cards
│   │   │       ├── Goals section
│   │   │       └── Friends list
│   │   │
│   │   ├── progress/
│   │   │   └── progress_screen.dart        [280 lines]
│   │   │       ├── Progress circle
│   │   │       ├── Calorie chart
│   │   │       ├── Sleep tracker
│   │   │       └── Steps display
│   │   │
│   │   ├── workout/
│   │   │   └── workout_screen.dart         [300 lines]
│   │   │       ├── Workout timer
│   │   │       ├── Exercise list
│   │   │       ├── Play/pause controls
│   │   │       └── Start button
│   │   │
│   │   └── statistics/
│   │       └── statistics_screen.dart      [350 lines]
│   │           ├── Calorie stats
│   │           ├── Exercise charts
│   │           ├── Heart rate monitor
│   │           ├── Body metrics
│   │           └── Multiple visualizations
│   │
│   ├── widgets/
│   │   └── custom_widgets.dart             [400 lines, 10+ widgets]
│   │       ├── buildCircularProgress()
│   │       ├── buildMetricCard()
│   │       ├── buildGoalCard()
│   │       ├── buildPrimaryButton()
│   │       ├── buildExerciseItem()
│   │       └── [6+ more widgets]
│   │
│   └── utils/
│       └── fitness_utils.dart              [250 lines, 20+ functions]
│           ├── formatDate()
│           ├── calculateCalories()
│           ├── getStepsBadge()
│           ├── getSleepQuality()
│           ├── calculateBMI()
│           └── [15+ more functions]
│
├── test/
│   ├── widget_test.dart                    [Widget Tests]
│   └── fitness_utils_test.dart             [20+ Unit Tests]
│
├── pubspec.yaml                            [Dependencies]
├── analysis_options.yaml                   [Lint Rules]
│
└── Documentation/
    ├── README_FEATURES.md                  [Features Overview]
    ├── INSTALLATION.md                     [Setup Guide]
    ├── API_DOCUMENTATION.md                [Backend Integration]
    ├── DEVELOPER_GUIDE.md                  [Architecture Guide]
    ├── PROJECT_SUMMARY.md                  [Project Overview]
    └── QUICK_REFERENCE.md                  [Quick Reference]
```

## 🎯 Component Hierarchy

```
MainApp (MyApp)
│
├── MaterialApp
│   │
│   └── MainNavigation (StatefulWidget)
│       │
│       ├── [Screen Index]
│       │
│       ├── HomeScreen (index: 0)
│       │   ├── SafeArea
│       │   │   └── SingleChildScrollView
│       │   │       └── Column
│       │   │           ├── Header (User greeting)
│       │   │           ├── Daily Intake Card
│       │   │           ├── Stat Cards (Water, Calories)
│       │   │           ├── Today's Goals
│       │   │           └── Friend Challenge
│       │   │
│       ├── ProgressScreen (index: 1)
│       │   ├── AppBar
│       │   └── SingleChildScrollView
│       │       └── Column
│       │           ├── Overall Progress Circle
│       │           ├── Calorie Burn Chart
│       │           ├── Sleep Card
│       │           └── Steps Card
│       │
│       ├── WorkoutScreen (index: 2)
│       │   ├── AppBar
│       │   └── SingleChildScrollView
│       │       └── Column
│       │           ├── Workout Header
│       │           ├── Stat Boxes
│       │           ├── Exercise List
│       │           └── Start Button
│       │
│       ├── StatisticsScreen (index: 3)
│       │   ├── AppBar
│       │   └── SingleChildScrollView
│       │       └── Column
│       │           ├── Calorie Analytics
│       │           ├── Exercise Chart
│       │           ├── BPM Monitor
│       │           └── Body Metrics
│       │
│       └── BottomNavigationBar (4 items)
│           ├── Home
│           ├── Progress
│           ├── Workout
│           └── Statistics
```

## 💾 Data Persistence Flow

```
┌──────────────────────┐
│  FitnessData Object  │
│                      │
│ - date               │
│ - calories           │
│ - steps              │
│ - waterGlasses       │
│ - sleepHours         │
│ - bpm                │
│ - weight             │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  toJson() Method     │
│ Serialization        │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  JSON String         │
│ "{...}"              │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  SharedPreferences   │
│  Local Device        │
│  Storage             │
│                      │
│  'todayData'         │
│  'fitnessHistory'    │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  fromJson()          │
│  Deserialization     │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  FitnessData Object  │
│ (Loaded from Storage)│
└──────────────────────┘
```

## 🎨 Theme Color System

```
┌─────────────────────────────────┐
│      App Color System (9)        │
├─────────────────────────────────┤
│                                 │
│ Primary Section                 │
│ ├─ Primary: #1E88E5 (Blue)     │
│ └─ Primary Dark: #1565C0       │
│                                 │
│ Secondary Section               │
│ ├─ Accent: #FFA726 (Orange)    │
│ ├─ Sky Blue: #42A5F5           │
│ └─ Light Green: #81C784        │
│                                 │
│ Status Indicators               │
│ ├─ Success: #66BB6A (Green)    │
│ ├─ Danger: #EF5350 (Red)       │
│                                 │
│ Background Section              │
│ ├─ Background: #FAFAFA         │
│ └─ Surface: #FFFFFF            │
│                                 │
└─────────────────────────────────┘
```

## 🧪 Testing Architecture

```
Test Suite (20+ Tests)
│
├── Unit Tests
│   ├── formatDate()
│   ├── calculateCalories()
│   ├── getStepsBadge()
│   ├── getHydrationStatus()
│   ├── getSleepQuality()
│   ├── calculateProgress()
│   ├── getDayAbbr()
│   ├── getGreeting()
│   ├── formatLargeNumber()
│   ├── isValidEmail()
│   ├── isToday()
│   ├── getIntensityLevel()
│   ├── calculateBMI()
│   └── getBMICategory()
│
└── Widget Tests
    ├── HomeScreen
    ├── ProgressScreen
    ├── WorkoutScreen
    └── StatisticsScreen
```

## 📊 State Management Flow

```
Provider Pattern Implementation:

User Action
    ↓
Screen Widget (Stateful)
    ↓
context.read<FitnessProvider>()
    ↓
updateTodayData() Method
    ↓
Update _todayData Object
    ↓
_saveTodayData()
    ↓
SharedPreferences.setString()
    ↓
notifyListeners()
    ↓
Rebuild watching Widgets
    ↓
context.watch<FitnessProvider>()
    ↓
Display Updated Data
```

## 🚀 Build & Deployment Pipeline

```
┌──────────────┐
│ Source Code  │
└──────┬───────┘
       │
       ▼
┌──────────────────┐
│ flutter pub get  │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ flutter analyze  │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ flutter test     │
└──────┬───────────┘
       │
       ├─────────────┬────────────┬──────────────┐
       │             │            │              │
       ▼             ▼            ▼              ▼
   ┌──────┐   ┌──────────┐  ┌────────┐  ┌──────────┐
   │ Web  │   │ Windows  │  │ macOS  │  │ Mobile   │
   │.wasm │   │.exe      │  │.app    │  │.apk/ipa  │
   └──────┘   └──────────┘  └────────┘  └──────────┘
```

---

**Diagrams Updated**: October 2025
**Architecture Version**: 1.0
