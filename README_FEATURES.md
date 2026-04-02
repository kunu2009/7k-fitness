# Fitness Tracker App

A fully functional Flutter fitness tracking application with beautiful UI/UX based on modern design principles.

## Features

### 🏠 Home Screen
- **Daily Overview**: View your daily fitness summary
- **Weekly Progress**: See your activity broken down by day of the week
- **Quick Stats**: Monitor water intake (4.5L) and calorie burn (2.3k)
- **Today's Goals**: Set and track running and cycling goals
- **Friend Challenges**: Connect with friends and compete in fitness challenges
- **Personalized Greeting**: Get personalized messages based on time of day

### 📊 Progress Screen
- **Overall Progress**: Visual circular progress indicator (75% completion)
- **Calorie Burn Charts**: Weekly bar chart showing daily calorie burns
- **Sleep Tracking**: Monitor sleep hours
- **Step Counter**: Track daily steps (4.1k steps)
- **Interactive Charts**: Beautiful visualization of fitness data

### 💪 Workout Screen
- **Workout Timer**: Track workout duration in real-time (0:12:25)
- **Energy Display**: Monitor workout intensity
- **Exercise List**: Comprehensive list of exercises with reps
  - Overhead Press
  - Dumbbell Lunges
  - Incline Bench Press
  - Leg Balance Lunges
- **Workout Statistics**: Duration, calorie burn, and workout count
- **Play/Pause Control**: Control workout timer with playback controls

### 📈 Statistics Screen
- **Calorie Analytics**: Detailed calorie burn statistics with weekly charts
- **Exercise Duration**: Monitor exercise hours with line charts
- **Heart Rate (BPM)**: Track heart rate trends
- **Body Metrics**: Weight and water intake tracking
- **Multiple Data Visualizations**: Line charts and bar charts for different metrics

### 🧭 Navigation
- Bottom navigation bar with 4 main sections
- Smooth transitions between screens
- Persistent state management
- Easy access to all features

## Technical Implementation

### Architecture
- **MVVM Pattern**: Organized folder structure with models, providers, and screens
- **State Management**: Provider package for efficient state management
- **Local Storage**: SharedPreferences for data persistence

### Dependencies
```yaml
fl_chart: ^0.68.0          # Beautiful charts and graphs
shared_preferences: ^2.2.2 # Local data storage
provider: ^6.1.0           # State management
intl: ^0.19.0              # Internationalization
```

### Project Structure
```
lib/
├── main.dart                      # App entry point
├── theme/
│   └── app_theme.dart            # Color schemes and theme configuration
├── models/
│   └── fitness_data.dart         # Data models for fitness tracking
├── providers/
│   └── fitness_provider.dart     # State management and data logic
└── screens/
    ├── home/
    │   └── home_screen.dart      # Home screen with daily overview
    ├── progress/
    │   └── progress_screen.dart  # Progress tracking with charts
    ├── workout/
    │   └── workout_screen.dart   # Workout tracking interface
    └── statistics/
        └── statistics_screen.dart # Detailed statistics and analytics
```

## Color Scheme

| Color | Hex Code | Usage |
|-------|----------|-------|
| Primary | #1E88E5 | Main brand color, buttons, highlights |
| Primary Dark | #1565C0 | Darker shade of primary |
| Accent | #FFA726 | Secondary highlights, call-to-action |
| Success | #66BB6A | Positive indicators |
| Danger | #EF5350 | Heart rate, warnings |
| Sky Blue | #42A5F5 | Water, cool metrics |
| Light Green | #81C784 | Growth, achievements |
| Background | #FAFAFA | App background |
| Surface | #FFFFFF | Card and component backgrounds |

## Key Metrics Tracked

1. **Calories Burned**: Daily calorie burn tracking (Target: 1920 Kcal)
2. **Steps**: Daily step counter (Target: various)
3. **Water Intake**: Glass-based water tracking (12 glasses daily)
4. **Sleep Hours**: Nightly sleep duration (7.5 hours)
5. **Heart Rate**: BPM monitoring (86 bpm average)
6. **Weight**: Body weight tracking (70 kg)
7. **Exercise Duration**: Time spent exercising (2.0 hours)

## Data Persistence

- All fitness data is stored locally using SharedPreferences
- Daily data is automatically saved
- Historical data is maintained for weekly/monthly analysis
- Data survives app restarts

## UI/UX Highlights

✨ **Modern Design**
- Clean, minimalist interface
- Smooth transitions and animations
- Intuitive navigation
- Beautiful card-based layouts

🎨 **Visual Hierarchy**
- Clear typography with multiple text styles
- Color-coded metrics for quick identification
- Icons for visual communication
- Proper spacing and padding

📱 **Responsive Design**
- Adaptive layouts
- Scrollable content areas
- Bottom navigation for easy thumb access
- Safe area padding for notched devices

## Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Windows, macOS, iOS, or Android device

### Installation
```bash
# Clone or download the project
cd fitness_tracker

# Get dependencies
flutter pub get

# Run the app
flutter run -d windows  # for Windows
flutter run -d chrome   # for Web
flutter run            # for connected device
```

## Future Enhancements

- 🔔 Push notifications for workout reminders
- 🤝 Social features and friend connections
- 📅 Monthly/yearly statistics
- 🎯 Custom goal setting
- 🏆 Achievement badges and rewards
- 🔊 Audio feedback for milestones
- 🌙 Dark mode support
- 📱 Wearable device integration

## Performance Optimizations

- Lazy loading of screens
- Efficient chart rendering with fl_chart
- Optimized build methods
- Proper widget disposal
- Memory-efficient data storage

## Troubleshooting

**Issue**: App not building
- Solution: Run `flutter clean` then `flutter pub get`

**Issue**: Charts not displaying
- Solution: Ensure fl_chart package is properly installed

**Issue**: Data not persisting
- Solution: Check SharedPreferences initialization in main.dart

## License

This project is provided as-is for educational and commercial use.

## Support

For issues or questions, please refer to the Flutter documentation or raise an issue in your project repository.

---

**Version**: 1.0.0
**Last Updated**: October 2025
