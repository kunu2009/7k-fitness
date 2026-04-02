import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/settings_service.dart';
import '../tutorial/app_tutorial_screen.dart';
import '../profile/profile_setup_screen.dart';

/// App Launcher that handles the onboarding flow
/// Flow: Welcome → Tutorial → Profile Setup → Main App
class AppLauncher extends StatefulWidget {
  final Widget mainApp;
  final SettingsService settingsService;

  const AppLauncher({
    super.key,
    required this.mainApp,
    required this.settingsService,
  });

  @override
  State<AppLauncher> createState() => _AppLauncherState();
}

class _AppLauncherState extends State<AppLauncher> {
  bool _isLoading = true;
  LaunchStep _currentStep = LaunchStep.loading;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    // SettingsService is already initialized in main.dart
    // But we ensure it's ready just in case
    if (!widget.settingsService.tutorialCompleted &&
        !widget.settingsService.profileSetupCompleted) {
      // If both are false, it might be uninitialized or fresh install
      // We can re-check or just proceed
    }

    setState(() {
      _isLoading = false;
      if (!widget.settingsService.tutorialCompleted) {
        _currentStep = LaunchStep.tutorial;
      } else if (!widget.settingsService.profileSetupCompleted) {
        _currentStep = LaunchStep.profileSetup;
      } else {
        _currentStep = LaunchStep.mainApp;
      }
    });
  }

  void _onTutorialComplete() {
    widget.settingsService.setTutorialCompleted(true);
    setState(() {
      if (!widget.settingsService.profileSetupCompleted) {
        _currentStep = LaunchStep.profileSetup;
      } else {
        _currentStep = LaunchStep.mainApp;
      }
    });
  }

  void _onProfileSetupComplete() {
    setState(() {
      _currentStep = LaunchStep.mainApp;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fitness_center,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'FitTrack',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    switch (_currentStep) {
      case LaunchStep.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));

      case LaunchStep.tutorial:
        return AppTutorialScreen(onComplete: _onTutorialComplete);

      case LaunchStep.profileSetup:
        return ProfileSetupScreen(
          settingsService: widget.settingsService,
          onComplete: _onProfileSetupComplete,
        );

      case LaunchStep.mainApp:
        return widget.mainApp;
    }
  }
}

enum LaunchStep { loading, tutorial, profileSetup, mainApp }
