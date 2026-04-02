import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/fitness_provider.dart';
import 'notification_settings_screen.dart';
import '../health/health_sync_screen.dart';
import '../tutorial/app_tutorial_screen.dart';
import 'help_center_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<FitnessProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Appearance Section
              _buildSectionHeader('Appearance'),
              _buildSettingsCard([
                _buildSwitchTile(
                  'Dark Mode',
                  'Switch to dark theme',
                  Icons.dark_mode,
                  provider.isDarkMode,
                  (value) => provider.toggleDarkMode(),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  'Theme Color',
                  'Orange',
                  Icons.palette,
                  () => _showThemeColorDialog(context),
                ),
              ]),
              const SizedBox(height: 24),

              // Units Section
              _buildSectionHeader('Units'),
              _buildSettingsCard([
                _buildNavigationTile(
                  'Weight Unit',
                  'kg',
                  Icons.monitor_weight,
                  () => _showUnitDialog(context, 'Weight', ['kg', 'lbs']),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  'Height Unit',
                  'cm',
                  Icons.height,
                  () => _showUnitDialog(context, 'Height', ['cm', 'ft/in']),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  'Distance Unit',
                  'km',
                  Icons.straighten,
                  () => _showUnitDialog(context, 'Distance', ['km', 'miles']),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  'Water Unit',
                  'ml',
                  Icons.water_drop,
                  () => _showUnitDialog(context, 'Water', ['ml', 'oz', 'cups']),
                ),
              ]),
              const SizedBox(height: 24),

              // Notifications Section
              _buildSectionHeader('Notifications'),
              _buildSettingsCard([
                _buildSwitchTile(
                  'Workout Reminders',
                  'Get reminded to work out',
                  Icons.notifications_active,
                  true,
                  (value) {},
                ),
                _buildDivider(),
                _buildSwitchTile(
                  'Water Reminders',
                  'Stay hydrated throughout the day',
                  Icons.water_drop,
                  true,
                  (value) {},
                ),
                _buildDivider(),
                _buildSwitchTile(
                  'Goal Achievements',
                  'Celebrate when you reach goals',
                  Icons.emoji_events,
                  true,
                  (value) {},
                ),
                _buildDivider(),
                _buildNavigationTile(
                  'Reminder Time',
                  '8:00 AM',
                  Icons.access_time,
                  () => _showTimePicker(context),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  'Notification Settings',
                  'Manage all notifications',
                  Icons.notifications,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen(),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 24),

              // Goals Section
              _buildSectionHeader('Daily Goals'),
              _buildSettingsCard([
                _buildNavigationTile(
                  'Step Goal',
                  '10,000 steps',
                  Icons.directions_walk,
                  () => _showGoalDialog(context, 'Step Goal', 10000, 'steps'),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  'Calorie Goal',
                  '2,000 kcal',
                  Icons.local_fire_department,
                  () => _showGoalDialog(context, 'Calorie Goal', 2000, 'kcal'),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  'Water Goal',
                  '2,500 ml',
                  Icons.water_drop,
                  () => _showGoalDialog(context, 'Water Goal', 2500, 'ml'),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  'Sleep Goal',
                  '8 hours',
                  Icons.bedtime,
                  () => _showGoalDialog(context, 'Sleep Goal', 8, 'hours'),
                ),
              ]),
              const SizedBox(height: 24),

              // Privacy Section
              _buildSectionHeader('Privacy & Data'),
              _buildSettingsCard([
                _buildNavigationTile(
                  'Health Data Sync',
                  'Sync with Apple Health / Google Fit',
                  Icons.sync,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HealthSyncScreen()),
                  ),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  'Export Data',
                  'Download your data',
                  Icons.download,
                  () => _showExportDialog(context),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  'Delete All Data',
                  'Permanently delete your data',
                  Icons.delete_forever,
                  () => _showDeleteDialog(context),
                  isDestructive: true,
                ),
              ]),
              const SizedBox(height: 24),

              // Help & Support Section
              _buildSectionHeader('Help & Support'),
              _buildSettingsCard([
                _buildNavigationTile(
                  'App Tutorial',
                  'Learn how to use the app',
                  Icons.school,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AppTutorialScreen(
                        onComplete: () => Navigator.pop(context),
                        isFirstLaunch: false,
                      ),
                    ),
                  ),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  'Help Center',
                  'FAQs and guides',
                  Icons.help_outline,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
                  ),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  'Calorie Calculator',
                  'Understand your calorie needs',
                  Icons.calculate,
                  () => _showCalorieExplanation(context),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  'Quick Tips',
                  'Daily usage tips',
                  Icons.tips_and_updates,
                  () => _showQuickTips(context),
                ),
              ]),
              const SizedBox(height: 24),

              // About Section
              _buildSectionHeader('About'),
              _buildSettingsCard([
                _buildNavigationTile(
                  'App Version',
                  '1.0.0',
                  Icons.info_outline,
                  null,
                ),
                _buildDivider(),
                _buildNavigationTile(
                  'Rate App',
                  'Love the app? Rate us!',
                  Icons.star,
                  () {},
                ),
                _buildDivider(),
                _buildNavigationTile(
                  'Send Feedback',
                  'Help us improve',
                  Icons.feedback,
                  () {},
                ),
                _buildDivider(),
                _buildNavigationTile(
                  'Privacy Policy',
                  '',
                  Icons.privacy_tip,
                  () {},
                ),
                _buildDivider(),
                _buildNavigationTile(
                  'Terms of Service',
                  '',
                  Icons.description,
                  () {},
                ),
              ]),
              const SizedBox(height: 40),

              // App branding
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(
                        child: Text(
                          '7K',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '7K Fit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Your fitness companion',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Made with ❤️',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56, endIndent: 16);
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  Widget _buildNavigationTile(
    String title,
    String value,
    IconData icon,
    VoidCallback? onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withAlpha(26)
              : AppColors.primary.withAlpha(26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : AppColors.primary,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value.isNotEmpty)
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary.withAlpha(128),
            ),
          ],
        ],
      ),
    );
  }

  void _showThemeColorDialog(BuildContext context) {
    final colors = [
      ('Orange', const Color(0xFFFF6B35)),
      ('Blue', Colors.blue),
      ('Green', Colors.green),
      ('Purple', Colors.purple),
      ('Pink', Colors.pink),
      ('Teal', Colors.teal),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Color'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${color.$1} theme selected')),
                );
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.$2,
                  shape: BoxShape.circle,
                  border: color.$1 == 'Orange'
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                  boxShadow: [
                    BoxShadow(color: color.$2.withAlpha(100), blurRadius: 8),
                  ],
                ),
                child: color.$1 == 'Orange'
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showUnitDialog(
    BuildContext context,
    String title,
    List<String> options,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$title Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return ListTile(
              title: Text(option),
              trailing: option == options.first
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTimePicker(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (time != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder set for ${time.format(context)}')),
      );
    }
  }

  void _showGoalDialog(
    BuildContext context,
    String title,
    int currentValue,
    String unit,
  ) {
    final controller = TextEditingController(text: currentValue.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: unit,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$title updated')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'Your data will be exported as a JSON file. This includes your profile, workouts, nutrition logs, and progress data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data exported successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Export', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'Are you sure you want to delete all your data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data has been deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCalorieExplanation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 32,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Understanding Calories',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoCard(
                'What is BMR?',
                'Basal Metabolic Rate (BMR) is the number of calories your body burns at rest just to maintain basic functions like breathing, circulation, and cell production.',
                Icons.monitor_heart,
                Colors.red,
              ),
              _buildInfoCard(
                'What is TDEE?',
                'Total Daily Energy Expenditure (TDEE) is your BMR plus calories burned through daily activities and exercise. This is your maintenance calorie level.',
                Icons.trending_up,
                Colors.blue,
              ),
              _buildInfoCard(
                'Weight Loss',
                'To lose weight, eat 300-500 calories less than your TDEE. This creates a calorie deficit, causing your body to use stored fat for energy. Aim for 0.5-1 lb/week.',
                Icons.trending_down,
                Colors.green,
              ),
              _buildInfoCard(
                'Muscle Gain',
                'To build muscle, eat 200-300 calories more than your TDEE while strength training. The surplus provides energy for muscle growth.',
                Icons.fitness_center,
                Colors.purple,
              ),
              _buildInfoCard(
                'Macros Matter',
                '• Protein: 1.6-2.2g per kg body weight (muscle repair)\n• Carbs: 45-65% of calories (energy source)\n• Fat: 20-35% of calories (hormones, vitamins)',
                Icons.pie_chart,
                Colors.orange,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📱 How to use in this app:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Your calorie goal is calculated from your profile\n'
                      '2. Log all meals in Nutrition section\n'
                      '3. Logged workouts add to calories burned\n'
                      '4. Check progress on Home screen\n'
                      '5. Adjust goals in Settings as needed',
                      style: TextStyle(height: 1.6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }

  void _showQuickTips(BuildContext context) {
    final tips = [
      {
        'icon': Icons.wb_sunny,
        'tip': 'Log breakfast within 1 hour of waking',
        'color': Colors.orange,
      },
      {
        'icon': Icons.water_drop,
        'tip': 'Drink water before each meal',
        'color': Colors.blue,
      },
      {
        'icon': Icons.restaurant,
        'tip': 'Log meals immediately after eating',
        'color': Colors.green,
      },
      {
        'icon': Icons.fitness_center,
        'tip': 'Schedule workouts at consistent times',
        'color': Colors.purple,
      },
      {
        'icon': Icons.bedtime,
        'tip': 'Log sleep as soon as you wake up',
        'color': Colors.indigo,
      },
      {
        'icon': Icons.scale,
        'tip': 'Weigh yourself same time daily',
        'color': Colors.teal,
      },
      {
        'icon': Icons.photo_camera,
        'tip': 'Take progress photos weekly',
        'color': Colors.pink,
      },
      {
        'icon': Icons.trending_up,
        'tip': 'Review weekly stats every Sunday',
        'color': Colors.amber,
      },
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Quick Tips for Success',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: tips.length,
                itemBuilder: (context, index) {
                  final tip = tips[index];
                  return ListTile(
                    leading: Icon(
                      tip['icon'] as IconData,
                      color: tip['color'] as Color,
                    ),
                    title: Text(tip['tip'] as String),
                    dense: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
