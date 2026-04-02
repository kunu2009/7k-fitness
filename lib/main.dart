import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/fitness_provider.dart';
import 'providers/gamification_provider.dart';
import 'providers/photo_timeline_provider.dart';
import 'providers/sleep_provider.dart';
import 'providers/step_provider.dart';
import 'providers/heart_rate_provider.dart';
import 'providers/water_provider.dart';
import 'providers/nutrition_provider.dart';
import 'providers/workout_history_provider.dart';
import 'providers/body_measurement_provider.dart';
import 'services/settings_service.dart';
import 'screens/home/home_screen.dart';
import 'screens/progress/progress_screen.dart';
import 'screens/workout/workout_screen.dart';
import 'screens/statistics/statistics_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/onboarding/app_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize providers
  final fitnessProvider = FitnessProvider();
  final settingsService = SettingsService();
  final gamificationProvider = GamificationProvider();
  final photoTimelineProvider = PhotoTimelineProvider();
  final sleepProvider = SleepProvider();
  final stepProvider = StepProvider();
  final heartRateProvider = HeartRateProvider();
  final waterProvider = WaterProvider();
  final nutritionProvider = NutritionProvider();
  final workoutHistoryProvider = WorkoutHistoryProvider();
  final bodyMeasurementProvider = BodyMeasurementProvider();

  try {
    await fitnessProvider.init();
    await settingsService.init();
    await gamificationProvider.init();
    await photoTimelineProvider.init();
    await sleepProvider.init();
    await stepProvider.init();
    await waterProvider.initialize();
    await nutritionProvider.initialize();
    await workoutHistoryProvider.initialize();
    await bodyMeasurementProvider.initialize();
  } catch (e) {
    debugPrint('Initialization failed: $e');
    // Continue anyway, the app might recover or show error states
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => fitnessProvider),
        ChangeNotifierProvider(create: (_) => settingsService),
        ChangeNotifierProvider(create: (_) => gamificationProvider),
        ChangeNotifierProvider(create: (_) => photoTimelineProvider),
        ChangeNotifierProvider(create: (_) => sleepProvider),
        ChangeNotifierProvider(create: (_) => stepProvider),
        ChangeNotifierProvider(create: (_) => heartRateProvider),
        ChangeNotifierProvider(create: (_) => waterProvider),
        ChangeNotifierProvider(create: (_) => nutritionProvider),
        ChangeNotifierProvider(create: (_) => workoutHistoryProvider),
        ChangeNotifierProvider(create: (_) => bodyMeasurementProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<FitnessProvider, SettingsService>(
      builder: (context, fitnessProvider, settingsService, _) {
        return MaterialApp(
          title: '7K Fit',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: fitnessProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: AppLauncher(
            settingsService: settingsService,
            mainApp: const MainNavigation(),
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ProgressScreen(),
    WorkoutScreen(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
