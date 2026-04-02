# Installation & Setup Guide

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (version 3.9.2 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   
2. **Dart SDK** (typically bundled with Flutter)

3. **IDE** (one of the following)
   - Android Studio
   - Visual Studio Code with Flutter extension
   - IntelliJ IDEA

4. **Platform Requirements**
   - **Windows**: Visual Studio Build Tools
   - **macOS**: Xcode Command Line Tools
   - **iOS**: Xcode 12.0+
   - **Android**: Android SDK API level 21+
   - **Web**: Chrome/Firefox browser

## Installation Steps

### 1. Clone/Download the Project
```bash
cd path/to/your/projects
# If using git
git clone <repository-url>
# OR download and extract the zip file
```

### 2. Navigate to Project Directory
```bash
cd fitness_tracker
```

### 3. Get Flutter Dependencies
```bash
flutter pub get
```

This command will download and install all required packages:
- `fl_chart` - For beautiful charts and graphs
- `shared_preferences` - For local data storage
- `provider` - For state management
- `intl` - For date/time formatting

### 4. Clean Build (If Needed)
```bash
flutter clean
flutter pub get
```

### 5. Run the Application

#### On Chrome (Web)
```bash
flutter run -d chrome
```

#### On Windows Desktop
```bash
flutter run -d windows
```

#### On macOS Desktop
```bash
flutter run -d macos
```

#### On Android Emulator/Device
```bash
flutter run -d android
# OR
flutter run  # auto-detects connected device
```

#### On iOS Simulator
```bash
flutter run -d ios
```

## Project Structure

```
fitness_tracker/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── theme/
│   │   └── app_theme.dart          # Theme configuration
│   ├── models/
│   │   └── fitness_data.dart       # Data models
│   ├── providers/
│   │   └── fitness_provider.dart   # State management
│   ├── screens/
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── progress/
│   │   │   └── progress_screen.dart
│   │   ├── workout/
│   │   │   └── workout_screen.dart
│   │   └── statistics/
│   │       └── statistics_screen.dart
│   ├── widgets/
│   │   └── custom_widgets.dart     # Reusable widgets
│   └── utils/
│       └── fitness_utils.dart      # Utility functions
├── test/
│   └── widget_test.dart             # Widget tests
├── pubspec.yaml                     # Dependencies
├── analysis_options.yaml            # Lint rules
└── README.md                        # Documentation
```

## Configuration

### Theme Customization

Edit `lib/theme/app_theme.dart` to modify colors:

```dart
class AppColors {
  static const primary = Color(0xFF1E88E5);      // Change primary color
  static const accent = Color(0xFFFFA726);       // Change accent color
  // ... more colors
}
```

### Data Storage

The app uses `SharedPreferences` for local storage. Data is automatically saved when:
- User updates fitness metrics
- Day changes
- App is closed

To clear all data programmatically:
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.clear();
```

## Running in Debug Mode

```bash
# Run with verbose output
flutter run -v

# Run with specific device
flutter run -d <device-id>

# List connected devices
flutter devices
```

## Building for Release

### Android
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
# Output: build/web/
```

### Windows Desktop
```bash
flutter build windows --release
# Output: build/windows/runner/Release/
```

## Troubleshooting

### Issue: "Building with plugins requires symlink support" (Windows)
**Solution**: Enable Developer Mode
1. Press `Win + I` to open Settings
2. Go to "Update & Security" > "For developers"
3. Enable "Developer Mode"
4. Or run: `start ms-settings:developers`

### Issue: "Unable to locate Android SDK"
**Solution**: Set Android SDK path
```bash
flutter config --android-sdk /path/to/android/sdk
```

### Issue: Packages not found
**Solution**: Clear and reinstall
```bash
flutter clean
flutter pub get
flutter pub cache repair
```

### Issue: Hot reload not working
**Solution**: Use hot restart
```bash
# In the Flutter console, type:
r  # Hot reload
R  # Hot restart
```

### Issue: Port already in use
**Solution**: Specify a different port
```bash
flutter run --debug-port 52000
```

## Development Tips

1. **Use Hot Reload** - Save changes automatically reload during development
2. **Enable Dartfmt** - Format code automatically
3. **Use Analyzer** - Check code for issues
4. **Enable Debug Paint** - View widget boundaries
5. **Profile App** - Check performance

### Enable Debug Paint
```dart
// Add to main.dart temporarily
debugPaintSizeEnabled = true;
```

## Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test
```bash
flutter test test/widget_test.dart
```

### Generate Coverage Report
```bash
flutter test --coverage
```

## Performance Optimization

1. **Use const constructors** where possible
2. **Avoid rebuilds** with proper state management
3. **Lazy load** screens and data
4. **Optimize images** before adding to assets
5. **Profile** regularly with DevTools

## Environment Variables

Create `.env` file for sensitive data:
```
API_BASE_URL=https://api.example.com
API_KEY=your_api_key_here
```

## IDE Setup

### Visual Studio Code
Install extensions:
- Flutter
- Dart
- Awesome Flutter Snippets

### Android Studio
1. Open plugin settings
2. Install Flutter plugin
3. Install Dart plugin

## Common Commands

```bash
# Check Flutter version
flutter --version

# List devices
flutter devices

# Get package version
flutter pub show-outdated

# Update packages
flutter pub upgrade

# Format code
flutter format lib/

# Analyze code
flutter analyze

# Doctor (check setup)
flutter doctor

# Doctor verbose
flutter doctor -v
```

## Next Steps

1. Explore the UI by navigating between screens
2. Customize colors and theme in `app_theme.dart`
3. Add more workout types in the workout screen
4. Implement backend integration for cloud sync
5. Add notifications for fitness reminders
6. Integrate wearable devices

## Resources

- [Flutter Official Docs](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Material Design](https://material.io/design)
- [fl_chart Documentation](https://pub.dev/packages/fl_chart)
- [Provider Package](https://pub.dev/packages/provider)

## Support

For issues or questions:
1. Check Flutter documentation
2. Search existing GitHub issues
3. Create a new issue with detailed information
4. Include error messages and logs

## License

This project is provided for educational and commercial purposes.

---

**Last Updated**: October 2025
**Flutter Version**: 3.9.2+
