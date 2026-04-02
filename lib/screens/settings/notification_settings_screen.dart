import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  late NotificationSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = _notificationService.settings;
  }

  void _updateSettings(NotificationSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
    _notificationService.updateSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: [
          // Master toggle
          SwitchListTile(
            value: _settings.enabled,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(enabled: value));
            },
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive reminders and updates'),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _settings.enabled
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _settings.enabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: _settings.enabled ? AppColors.primary : Colors.grey,
              ),
            ),
          ),

          const Divider(),

          // Workout reminders
          _buildSectionHeader('Workout Reminders'),
          SwitchListTile(
            value: _settings.workoutReminders,
            onChanged: _settings.enabled
                ? (value) {
                    _updateSettings(
                      _settings.copyWith(workoutReminders: value),
                    );
                  }
                : null,
            title: const Text('Workout Reminders'),
            subtitle: const Text('Get reminded to work out'),
          ),

          if (_settings.workoutReminders && _settings.enabled) ...[
            ListTile(
              title: const Text('Reminder Time'),
              subtitle: Text(
                '${_settings.morningReminderTime.hour.toString().padLeft(2, '0')}:'
                '${_settings.morningReminderTime.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selectTime(
                currentTime: _settings.morningReminderTime,
                onSelected: (time) {
                  _updateSettings(
                    _settings.copyWith(morningReminderTime: time),
                  );
                },
              ),
            ),
            ListTile(
              title: const Text('Workout Days'),
              subtitle: Text(_formatWorkoutDays(_settings.workoutDays)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectWorkoutDays,
            ),
          ],

          const Divider(),

          // Nutrition reminders
          _buildSectionHeader('Nutrition Reminders'),
          SwitchListTile(
            value: _settings.mealReminders,
            onChanged: _settings.enabled
                ? (value) {
                    _updateSettings(_settings.copyWith(mealReminders: value));
                  }
                : null,
            title: const Text('Meal Logging Reminders'),
            subtitle: const Text('Remember to log your meals'),
          ),

          SwitchListTile(
            value: _settings.waterReminders,
            onChanged: _settings.enabled
                ? (value) {
                    _updateSettings(_settings.copyWith(waterReminders: value));
                  }
                : null,
            title: const Text('Water Reminders'),
            subtitle: const Text('Stay hydrated throughout the day'),
          ),

          const Divider(),

          // Achievement & social
          _buildSectionHeader('Achievements & Social'),
          SwitchListTile(
            value: _settings.achievementAlerts,
            onChanged: _settings.enabled
                ? (value) {
                    _updateSettings(
                      _settings.copyWith(achievementAlerts: value),
                    );
                  }
                : null,
            title: const Text('Achievement Alerts'),
            subtitle: const Text('When you earn badges or reach goals'),
          ),

          SwitchListTile(
            value: _settings.socialUpdates,
            onChanged: _settings.enabled
                ? (value) {
                    _updateSettings(_settings.copyWith(socialUpdates: value));
                  }
                : null,
            title: const Text('Social Updates'),
            subtitle: const Text('Friend activity and challenge updates'),
          ),

          const Divider(),

          // Reports
          _buildSectionHeader('Reports'),
          SwitchListTile(
            value: _settings.weeklyReports,
            onChanged: _settings.enabled
                ? (value) {
                    _updateSettings(_settings.copyWith(weeklyReports: value));
                  }
                : null,
            title: const Text('Weekly Progress Reports'),
            subtitle: const Text('Summary of your weekly activity'),
          ),

          const Divider(),

          // Quick actions
          _buildSectionHeader('Quick Actions'),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Schedule Workout Reminder'),
            subtitle: const Text('Set up a custom reminder'),
            onTap: _scheduleCustomReminder,
          ),
          ListTile(
            leading: const Icon(Icons.water_drop),
            title: const Text('Set Up Water Reminders'),
            subtitle: const Text('Configure hydration reminders'),
            onTap: _setupWaterReminders,
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear All Reminders'),
            subtitle: const Text('Remove all scheduled notifications'),
            onTap: _clearAllReminders,
          ),

          const SizedBox(height: 24),

          // Test notification
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: _sendTestNotification,
              icon: const Icon(Icons.send),
              label: const Text('Send Test Notification'),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Future<void> _selectTime({
    required TimeOfDay currentTime,
    required Function(TimeOfDay) onSelected,
  }) async {
    final time = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );
    if (time != null) {
      onSelected(time);
    }
  }

  void _selectWorkoutDays() {
    showDialog(
      context: context,
      builder: (context) {
        List<int> selectedDays = List.from(_settings.workoutDays);

        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Select Workout Days'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDayChip('Monday', 1, selectedDays, setDialogState),
                _buildDayChip('Tuesday', 2, selectedDays, setDialogState),
                _buildDayChip('Wednesday', 3, selectedDays, setDialogState),
                _buildDayChip('Thursday', 4, selectedDays, setDialogState),
                _buildDayChip('Friday', 5, selectedDays, setDialogState),
                _buildDayChip('Saturday', 6, selectedDays, setDialogState),
                _buildDayChip('Sunday', 7, selectedDays, setDialogState),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  _updateSettings(
                    _settings.copyWith(workoutDays: selectedDays),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayChip(
    String name,
    int day,
    List<int> selectedDays,
    StateSetter setDialogState,
  ) {
    final isSelected = selectedDays.contains(day);
    return CheckboxListTile(
      value: isSelected,
      onChanged: (value) {
        setDialogState(() {
          if (value == true) {
            selectedDays.add(day);
          } else {
            selectedDays.remove(day);
          }
        });
      },
      title: Text(name),
    );
  }

  String _formatWorkoutDays(List<int> days) {
    if (days.isEmpty) return 'No days selected';
    if (days.length == 7) return 'Every day';
    if (days.length == 5 && !days.contains(6) && !days.contains(7)) {
      return 'Weekdays';
    }
    if (days.length == 2 && days.contains(6) && days.contains(7)) {
      return 'Weekends';
    }

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map((d) => dayNames[d - 1]).join(', ');
  }

  void _scheduleCustomReminder() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Schedule Reminder',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Reminder Message',
                  hintText: 'Time to work out!',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Time'),
                subtitle: const Text('8:00 AM'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Repeat'),
                subtitle: const Text('Daily'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reminder scheduled!')),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Schedule Reminder'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setupWaterReminders() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Water Reminders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set up hourly reminders to drink water throughout the day.',
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start Time'),
              subtitle: const Text('8:00 AM'),
              trailing: const Icon(Icons.chevron_right),
            ),
            ListTile(
              title: const Text('End Time'),
              subtitle: const Text('10:00 PM'),
              trailing: const Icon(Icons.chevron_right),
            ),
            ListTile(
              title: const Text('Interval'),
              subtitle: const Text('Every 2 hours'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _notificationService.scheduleWaterReminders(
                startTime: const TimeOfDay(hour: 8, minute: 0),
                endTime: const TimeOfDay(hour: 22, minute: 0),
                interval: const Duration(hours: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Water reminders set up!')),
              );
            },
            child: const Text('Set Up'),
          ),
        ],
      ),
    );
  }

  void _clearAllReminders() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Reminders'),
        content: const Text(
          'Are you sure you want to remove all scheduled notifications?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _notificationService.cancelAllNotifications();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All reminders cleared')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _sendTestNotification() {
    _notificationService.showNotification(
      title: '🏋️ Test Notification',
      body: 'This is a test notification from 7K Fit!',
      type: NotificationType.workoutReminder,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Test notification sent!')));
  }
}
