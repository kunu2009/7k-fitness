import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';

class PersonalRecordsScreen extends StatefulWidget {
  const PersonalRecordsScreen({super.key});

  @override
  State<PersonalRecordsScreen> createState() => _PersonalRecordsScreenState();
}

class _PersonalRecordsScreenState extends State<PersonalRecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<PersonalRecord> _records = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Strength',
    'Cardio',
    'Bodyweight',
    'Olympic',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getStringList('personal_records') ?? [];
      _records = recordsJson
          .map((json) => PersonalRecord.fromJson(jsonDecode(json)))
          .toList();

      // If empty, add some sample data
      if (_records.isEmpty) {
        _records = _getSampleRecords();
        _saveRecords();
      }
    } catch (e) {
      debugPrint('Error loading records: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = _records.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList('personal_records', recordsJson);
    } catch (e) {
      debugPrint('Error saving records: $e');
    }
  }

  List<PersonalRecord> _getSampleRecords() {
    return [
      PersonalRecord(
        id: '1',
        exerciseName: 'Bench Press',
        category: 'Strength',
        recordType: RecordType.weight,
        value: 100,
        unit: 'kg',
        date: DateTime.now().subtract(const Duration(days: 7)),
        history: [
          RecordEntry(
            value: 80,
            date: DateTime.now().subtract(const Duration(days: 60)),
          ),
          RecordEntry(
            value: 90,
            date: DateTime.now().subtract(const Duration(days: 30)),
          ),
          RecordEntry(
            value: 100,
            date: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ],
      ),
      PersonalRecord(
        id: '2',
        exerciseName: 'Deadlift',
        category: 'Strength',
        recordType: RecordType.weight,
        value: 140,
        unit: 'kg',
        date: DateTime.now().subtract(const Duration(days: 14)),
        history: [
          RecordEntry(
            value: 100,
            date: DateTime.now().subtract(const Duration(days: 90)),
          ),
          RecordEntry(
            value: 120,
            date: DateTime.now().subtract(const Duration(days: 45)),
          ),
          RecordEntry(
            value: 140,
            date: DateTime.now().subtract(const Duration(days: 14)),
          ),
        ],
      ),
      PersonalRecord(
        id: '3',
        exerciseName: 'Squat',
        category: 'Strength',
        recordType: RecordType.weight,
        value: 120,
        unit: 'kg',
        date: DateTime.now().subtract(const Duration(days: 3)),
        history: [
          RecordEntry(
            value: 80,
            date: DateTime.now().subtract(const Duration(days: 90)),
          ),
          RecordEntry(
            value: 100,
            date: DateTime.now().subtract(const Duration(days: 45)),
          ),
          RecordEntry(
            value: 120,
            date: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
      ),
      PersonalRecord(
        id: '4',
        exerciseName: 'Push-ups',
        category: 'Bodyweight',
        recordType: RecordType.reps,
        value: 50,
        unit: 'reps',
        date: DateTime.now().subtract(const Duration(days: 5)),
        history: [
          RecordEntry(
            value: 30,
            date: DateTime.now().subtract(const Duration(days: 60)),
          ),
          RecordEntry(
            value: 40,
            date: DateTime.now().subtract(const Duration(days: 30)),
          ),
          RecordEntry(
            value: 50,
            date: DateTime.now().subtract(const Duration(days: 5)),
          ),
        ],
      ),
      PersonalRecord(
        id: '5',
        exerciseName: '5K Run',
        category: 'Cardio',
        recordType: RecordType.time,
        value: 1380, // seconds
        unit: 'sec',
        date: DateTime.now().subtract(const Duration(days: 10)),
        history: [
          RecordEntry(
            value: 1620,
            date: DateTime.now().subtract(const Duration(days: 60)),
          ),
          RecordEntry(
            value: 1500,
            date: DateTime.now().subtract(const Duration(days: 30)),
          ),
          RecordEntry(
            value: 1380,
            date: DateTime.now().subtract(const Duration(days: 10)),
          ),
        ],
      ),
      PersonalRecord(
        id: '6',
        exerciseName: 'Pull-ups',
        category: 'Bodyweight',
        recordType: RecordType.reps,
        value: 15,
        unit: 'reps',
        date: DateTime.now().subtract(const Duration(days: 2)),
        history: [
          RecordEntry(
            value: 8,
            date: DateTime.now().subtract(const Duration(days: 60)),
          ),
          RecordEntry(
            value: 12,
            date: DateTime.now().subtract(const Duration(days: 30)),
          ),
          RecordEntry(
            value: 15,
            date: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
      ),
    ];
  }

  List<PersonalRecord> get _filteredRecords {
    if (_selectedCategory == 'All') return _records;
    return _records.where((r) => r.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildCategoryFilter()),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredRecords.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildSummaryCards(),
                    const SizedBox(height: 16),
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppColors.primary,
                      tabs: const [
                        Tab(text: 'Records'),
                        Tab(text: 'Recent PRs'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: TabBarView(
                        controller: _tabController,
                        children: [_buildRecordsList(), _buildRecentPRs()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRecord,
        icon: const Icon(Icons.add),
        label: const Text('New PR'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Personal Records',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.amber[700]!, Colors.orange[600]!],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Icon(
                  Icons.emoji_events,
                  size: 150,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          final count = category == 'All'
              ? _records.length
              : _records.where((r) => r.category == category).length;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('$category ($count)'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.amber.withValues(alpha: 0.2),
              checkmarkColor: Colors.amber[700],
              labelStyle: TextStyle(
                color: isSelected ? Colors.amber[700] : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalPRs = _records.length;
    final thisMonthPRs = _records.where((r) {
      final now = DateTime.now();
      return r.date.year == now.year && r.date.month == now.month;
    }).length;

    final recentPR = _records.isNotEmpty
        ? _records.reduce((a, b) => a.date.isAfter(b.date) ? a : b)
        : null;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.emoji_events,
            title: 'Total PRs',
            value: '$totalPRs',
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.calendar_month,
            title: 'This Month',
            value: '$thisMonthPRs',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.bolt,
            title: 'Latest PR',
            value: recentPR != null
                ? '${_formatDaysAgo(recentPR.date)} ago'
                : 'N/A',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Personal Records Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your personal bests to see your progress over time.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addRecord,
              icon: const Icon(Icons.add),
              label: const Text('Add Your First PR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredRecords.length,
      itemBuilder: (context, index) {
        final record = _filteredRecords[index];
        return _buildRecordCard(record);
      },
    );
  }

  Widget _buildRecordCard(PersonalRecord record) {
    final improvement = record.history.length >= 2
        ? record.value - record.history[record.history.length - 2].value
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showRecordDetail(record),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildRecordIcon(record),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            record.exerciseName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildCategoryBadge(record.category),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, yyyy').format(record.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatRecordValue(record),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                  if (improvement != 0)
                    Row(
                      children: [
                        Icon(
                          improvement > 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 12,
                          color: record.recordType == RecordType.time
                              ? (improvement < 0 ? Colors.green : Colors.red)
                              : (improvement > 0 ? Colors.green : Colors.red),
                        ),
                        Text(
                          _formatImprovement(improvement, record),
                          style: TextStyle(
                            fontSize: 11,
                            color: record.recordType == RecordType.time
                                ? (improvement < 0 ? Colors.green : Colors.red)
                                : (improvement > 0 ? Colors.green : Colors.red),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordIcon(PersonalRecord record) {
    IconData icon;
    Color color;

    switch (record.category) {
      case 'Strength':
        icon = Icons.fitness_center;
        color = Colors.red;
        break;
      case 'Cardio':
        icon = Icons.directions_run;
        color = Colors.blue;
        break;
      case 'Bodyweight':
        icon = Icons.accessibility_new;
        color = Colors.green;
        break;
      case 'Olympic':
        icon = Icons.sports_gymnastics;
        color = Colors.purple;
        break;
      default:
        icon = Icons.emoji_events;
        color = Colors.orange;
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getCategoryColor(category).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _getCategoryColor(category),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Strength':
        return Colors.red;
      case 'Cardio':
        return Colors.blue;
      case 'Bodyweight':
        return Colors.green;
      case 'Olympic':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  Widget _buildRecentPRs() {
    final sortedRecords = List<PersonalRecord>.from(_filteredRecords)
      ..sort((a, b) => b.date.compareTo(a.date));

    if (sortedRecords.isEmpty) {
      return const Center(child: Text('No recent PRs'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedRecords.length,
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        return _buildRecentPRCard(record, index);
      },
    );
  }

  Widget _buildRecentPRCard(PersonalRecord record, int index) {
    final isNew = record.date.isAfter(
      DateTime.now().subtract(const Duration(days: 7)),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNew ? Colors.amber.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNew
              ? Colors.amber.withValues(alpha: 0.3)
              : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      record.exerciseName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (isNew) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'NEW!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  _formatDaysAgo(record.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Text(
            _formatRecordValue(record),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatRecordValue(PersonalRecord record) {
    switch (record.recordType) {
      case RecordType.weight:
        return '${record.value.toStringAsFixed(1)} ${record.unit}';
      case RecordType.reps:
        return '${record.value.toInt()} ${record.unit}';
      case RecordType.time:
        final minutes = (record.value / 60).floor();
        final seconds = (record.value % 60).toInt();
        return '$minutes:${seconds.toString().padLeft(2, '0')}';
      case RecordType.distance:
        return '${record.value.toStringAsFixed(2)} ${record.unit}';
    }
  }

  String _formatImprovement(double improvement, PersonalRecord record) {
    switch (record.recordType) {
      case RecordType.weight:
        return '${improvement.abs().toStringAsFixed(1)} kg';
      case RecordType.reps:
        return '${improvement.abs().toInt()} reps';
      case RecordType.time:
        final absSec = improvement.abs().toInt();
        if (absSec >= 60) {
          final min = absSec ~/ 60;
          final sec = absSec % 60;
          return '${min}m ${sec}s';
        }
        return '${absSec}s';
      case RecordType.distance:
        return '${improvement.abs().toStringAsFixed(2)} ${record.unit}';
    }
  }

  String _formatDaysAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return '${(diff.inDays / 30).floor()} months ago';
  }

  void _addRecord() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddRecordSheet(
        categories: _categories.where((c) => c != 'All').toList(),
        onRecordAdded: (record) {
          setState(() {
            _records.add(record);
          });
          _saveRecords();
        },
      ),
    );
  }

  void _showRecordDetail(PersonalRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordDetailScreen(
          record: record,
          onUpdate: (updatedRecord) {
            final index = _records.indexWhere((r) => r.id == record.id);
            if (index != -1) {
              setState(() {
                _records[index] = updatedRecord;
              });
              _saveRecords();
            }
          },
          onDelete: () {
            setState(() {
              _records.removeWhere((r) => r.id == record.id);
            });
            _saveRecords();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

// Data Models
enum RecordType { weight, reps, time, distance }

class RecordEntry {
  final double value;
  final DateTime date;

  RecordEntry({required this.value, required this.date});

  Map<String, dynamic> toJson() => {
    'value': value,
    'date': date.toIso8601String(),
  };

  factory RecordEntry.fromJson(Map<String, dynamic> json) => RecordEntry(
    value: json['value'].toDouble(),
    date: DateTime.parse(json['date']),
  );
}

class PersonalRecord {
  final String id;
  final String exerciseName;
  final String category;
  final RecordType recordType;
  final double value;
  final String unit;
  final DateTime date;
  final List<RecordEntry> history;
  final String? notes;

  PersonalRecord({
    required this.id,
    required this.exerciseName,
    required this.category,
    required this.recordType,
    required this.value,
    required this.unit,
    required this.date,
    required this.history,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseName': exerciseName,
    'category': category,
    'recordType': recordType.index,
    'value': value,
    'unit': unit,
    'date': date.toIso8601String(),
    'history': history.map((e) => e.toJson()).toList(),
    'notes': notes,
  };

  factory PersonalRecord.fromJson(Map<String, dynamic> json) => PersonalRecord(
    id: json['id'],
    exerciseName: json['exerciseName'],
    category: json['category'],
    recordType: RecordType.values[json['recordType']],
    value: json['value'].toDouble(),
    unit: json['unit'],
    date: DateTime.parse(json['date']),
    history: (json['history'] as List)
        .map((e) => RecordEntry.fromJson(e))
        .toList(),
    notes: json['notes'],
  );
}

// Add Record Sheet
class AddRecordSheet extends StatefulWidget {
  final List<String> categories;
  final Function(PersonalRecord) onRecordAdded;

  const AddRecordSheet({
    super.key,
    required this.categories,
    required this.onRecordAdded,
  });

  @override
  State<AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<AddRecordSheet> {
  final _exerciseController = TextEditingController();
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Strength';
  RecordType _selectedType = RecordType.weight;
  DateTime _selectedDate = DateTime.now();

  final Map<RecordType, String> _typeUnits = {
    RecordType.weight: 'kg',
    RecordType.reps: 'reps',
    RecordType.time: 'seconds',
    RecordType.distance: 'km',
  };

  @override
  void dispose() {
    _exerciseController.dispose();
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New PR',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Exercise Name
            TextField(
              controller: _exerciseController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
                prefixIcon: Icon(Icons.fitness_center),
                hintText: 'e.g., Bench Press, Squat',
              ),
            ),
            const SizedBox(height: 16),

            // Category Selection
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.categories.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = category);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Record Type
            const Text(
              'Record Type',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: RecordType.values.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(_getTypeName(type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Value Input
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Value',
                prefixIcon: const Icon(Icons.emoji_events),
                suffixText: _typeUnits[_selectedType],
                hintText: _getValueHint(),
              ),
            ),
            const SizedBox(height: 16),

            // Date Selection
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(DateFormat('MMMM d, yyyy').format(_selectedDate)),
              onTap: _selectDate,
            ),

            // Notes
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.note),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save PR'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getTypeName(RecordType type) {
    switch (type) {
      case RecordType.weight:
        return 'Weight';
      case RecordType.reps:
        return 'Reps';
      case RecordType.time:
        return 'Time';
      case RecordType.distance:
        return 'Distance';
    }
  }

  String _getValueHint() {
    switch (_selectedType) {
      case RecordType.weight:
        return 'e.g., 100';
      case RecordType.reps:
        return 'e.g., 50';
      case RecordType.time:
        return 'e.g., 1380 (seconds)';
      case RecordType.distance:
        return 'e.g., 5.0';
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveRecord() {
    if (_exerciseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter exercise name')),
      );
      return;
    }

    final value = double.tryParse(_valueController.text);
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid value')),
      );
      return;
    }

    final record = PersonalRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      exerciseName: _exerciseController.text,
      category: _selectedCategory,
      recordType: _selectedType,
      value: value,
      unit: _typeUnits[_selectedType]!,
      date: _selectedDate,
      history: [RecordEntry(value: value, date: _selectedDate)],
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    widget.onRecordAdded(record);
    Navigator.pop(context);
  }
}

// Record Detail Screen
class RecordDetailScreen extends StatelessWidget {
  final PersonalRecord record;
  final Function(PersonalRecord) onUpdate;
  final VoidCallback onDelete;

  const RecordDetailScreen({
    super.key,
    required this.record,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(record.exerciseName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentRecord(),
            const SizedBox(height: 24),
            _buildHistorySection(),
            const SizedBox(height: 24),
            if (record.notes != null) _buildNotesSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _updateRecord(context),
        icon: const Icon(Icons.update),
        label: const Text('Update PR'),
        backgroundColor: Colors.amber[700],
      ),
    );
  }

  Widget _buildCurrentRecord() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[600]!, Colors.orange[500]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            _formatRecordValue(),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Current Personal Record',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMMM d, yyyy').format(record.date),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PR History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...record.history.reversed.map((entry) => _buildHistoryEntry(entry)),
      ],
    );
  }

  Widget _buildHistoryEntry(RecordEntry entry) {
    final isCurrentPR = entry.value == record.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentPR
            ? Colors.amber.withValues(alpha: 0.1)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentPR ? Colors.amber : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCurrentPR ? Icons.star : Icons.circle,
            size: isCurrentPR ? 20 : 8,
            color: isCurrentPR ? Colors.amber : Colors.grey[400],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              DateFormat('MMM d, yyyy').format(entry.date),
              style: TextStyle(
                fontWeight: isCurrentPR ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            _formatValue(entry.value),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCurrentPR ? Colors.amber[700] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(record.notes!),
        ),
      ],
    );
  }

  String _formatRecordValue() {
    switch (record.recordType) {
      case RecordType.weight:
        return '${record.value.toStringAsFixed(1)} ${record.unit}';
      case RecordType.reps:
        return '${record.value.toInt()} ${record.unit}';
      case RecordType.time:
        final minutes = (record.value / 60).floor();
        final seconds = (record.value % 60).toInt();
        return '$minutes:${seconds.toString().padLeft(2, '0')}';
      case RecordType.distance:
        return '${record.value.toStringAsFixed(2)} ${record.unit}';
    }
  }

  String _formatValue(double value) {
    switch (record.recordType) {
      case RecordType.weight:
        return '${value.toStringAsFixed(1)} ${record.unit}';
      case RecordType.reps:
        return '${value.toInt()} ${record.unit}';
      case RecordType.time:
        final minutes = (value / 60).floor();
        final seconds = (value % 60).toInt();
        return '$minutes:${seconds.toString().padLeft(2, '0')}';
      case RecordType.distance:
        return '${value.toStringAsFixed(2)} ${record.unit}';
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record?'),
        content: const Text(
          'This will permanently delete this personal record.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _updateRecord(BuildContext context) {
    final valueController = TextEditingController(text: record.value.toString());
    final notesController = TextEditingController(text: record.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Personal Record',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              record.exerciseName,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'New Value',
                suffixText: record.unit,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final parsed = double.tryParse(valueController.text.trim());
                  if (parsed == null) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid value')),
                    );
                    return;
                  }

                  final updatedRecord = PersonalRecord(
                    id: record.id,
                    exerciseName: record.exerciseName,
                    category: record.category,
                    recordType: record.recordType,
                    value: parsed,
                    unit: record.unit,
                    date: DateTime.now(),
                    history: [
                      ...record.history,
                      RecordEntry(value: parsed, date: DateTime.now()),
                    ],
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );

                  onUpdate(updatedRecord);
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Personal record updated.')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
                child: const Text('Save Update'),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      valueController.dispose();
      notesController.dispose();
    });
  }
}
