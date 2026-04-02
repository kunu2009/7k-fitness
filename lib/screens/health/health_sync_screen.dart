import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/health_service.dart';

class HealthSyncScreen extends StatefulWidget {
  const HealthSyncScreen({super.key});

  @override
  State<HealthSyncScreen> createState() => _HealthSyncScreenState();
}

class _HealthSyncScreenState extends State<HealthSyncScreen> {
  final HealthService _healthService = HealthService();
  bool _isConnecting = false;
  final List<HealthDataType> _selectedTypes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Sync')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Connection status card
          _buildConnectionCard(),

          const SizedBox(height: 24),

          // Data types
          if (_healthService.status == HealthSyncStatus.connected) ...[
            _buildSyncedDataSection(),
            const SizedBox(height: 24),
            _buildTodayStats(),
          ] else ...[
            _buildConnectSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionCard() {
    final isConnected = _healthService.status == HealthSyncStatus.connected;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isConnected
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isConnected ? Icons.check_circle : Icons.sync_disabled,
                size: 40,
                color: isConnected ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isConnected ? 'Connected' : 'Not Connected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isConnected ? Colors.green : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isConnected
                  ? 'Syncing with ${_healthService.connectedPlatform?.name ?? 'Health App'}'
                  : 'Connect to sync your health data',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (_healthService.lastSyncTime != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last synced: ${_formatTime(_healthService.lastSyncTime!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
            const SizedBox(height: 16),
            if (isConnected)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _syncNow,
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync Now'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _disconnect,
                    icon: const Icon(Icons.link_off),
                    label: const Text('Disconnect'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: _isConnecting ? null : _connect,
                icon: _isConnecting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.link),
                label: Text(_isConnecting ? 'Connecting...' : 'Connect'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Platforms',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        _buildPlatformCard(
          name: 'Google Fit',
          icon: Icons.fitness_center,
          color: Colors.blue,
          description: 'Sync steps, workouts, and heart rate',
          onConnect: _connect,
        ),

        _buildPlatformCard(
          name: 'Apple Health',
          icon: Icons.favorite,
          color: Colors.red,
          description: 'Sync all health metrics from iOS',
          onConnect: _connect,
        ),

        _buildPlatformCard(
          name: 'Samsung Health',
          icon: Icons.watch,
          color: Colors.purple,
          description: 'Sync data from Samsung devices',
          onConnect: _connect,
        ),

        const SizedBox(height: 24),

        // Data types to sync
        const Text(
          'Data to Sync',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        ...HealthDataType.values
            .take(10)
            .map(
              (type) => CheckboxListTile(
                value: _selectedTypes.contains(type),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedTypes.add(type);
                    } else {
                      _selectedTypes.remove(type);
                    }
                  });
                },
                title: Row(
                  children: [
                    Text(type.icon),
                    const SizedBox(width: 8),
                    Text(type.displayName),
                  ],
                ),
                secondary: Icon(
                  _selectedTypes.contains(type)
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: _selectedTypes.contains(type)
                      ? AppColors.primary
                      : Colors.grey,
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildPlatformCard({
    required String name,
    required IconData icon,
    required Color color,
    required String description,
    required VoidCallback onConnect,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(name),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onConnect,
      ),
    );
  }

  Widget _buildSyncedDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Synced Data',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: _healthService.authorizedTypes.map((type) {
            return _buildDataTypeCard(type);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDataTypeCard(HealthDataType type) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(type.icon, style: const TextStyle(fontSize: 24)),
                const Spacer(),
                Icon(Icons.sync, size: 16, color: Colors.green),
              ],
            ),
            const Spacer(),
            Text(
              type.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Syncing',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: _syncNow, child: const Text('Refresh')),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: _buildStatCard('👟', '8,432', 'Steps', 84)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('🔥', '342', 'Calories', 68)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('❤️', '72', 'Avg BPM', null)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('😴', '7.5h', 'Sleep', 94)),
          ],
        ),

        const SizedBox(height: 24),

        // Sync settings
        const Text(
          'Sync Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Card(
          child: Column(
            children: [
              SwitchListTile(
                value: true,
                onChanged: (value) {},
                title: const Text('Auto-sync'),
                subtitle: const Text('Automatically sync data in background'),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Sync frequency'),
                subtitle: const Text('Every 15 minutes'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1),
              SwitchListTile(
                value: true,
                onChanged: (value) {},
                title: const Text('Write data'),
                subtitle: const Text('Send 7K Fit workouts to Health'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String emoji,
    String value,
    String label,
    int? progress,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const Spacer(),
                if (progress != null)
                  Text(
                    '$progress%',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(
                    progress >= 100 ? Colors.green : AppColors.primary,
                  ),
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _connect() async {
    setState(() => _isConnecting = true);

    final types = _selectedTypes.isEmpty
        ? [
            HealthDataType.steps,
            HealthDataType.heartRate,
            HealthDataType.activeCalories,
            HealthDataType.sleep,
            HealthDataType.weight,
          ]
        : _selectedTypes;

    final success = await _healthService.requestAuthorization(types);

    setState(() => _isConnecting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Connected successfully!'
                : 'Failed to connect. Please try again.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _disconnect() async {
    await _healthService.disconnect();
    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disconnected from health platform')),
      );
    }
  }

  Future<void> _syncNow() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      await _healthService.syncHealthData(startDate: startOfDay, endDate: now);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sync complete!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
      }
    }

    setState(() {});
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }
}
