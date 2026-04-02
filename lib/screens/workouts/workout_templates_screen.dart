import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/workout_template_database.dart';
import '../../models/exercise.dart';
import '../../models/workout_template.dart';
import '../../providers/fitness_provider.dart';
import '../../theme/app_theme.dart';
import '../workout/active_workout_screen.dart';

class WorkoutTemplatesScreen extends StatefulWidget {
  const WorkoutTemplatesScreen({super.key});

  @override
  State<WorkoutTemplatesScreen> createState() => _WorkoutTemplatesScreenState();
}

class _WorkoutTemplatesScreenState extends State<WorkoutTemplatesScreen>
    with SingleTickerProviderStateMixin {
  static const String _customTemplatesStorageKey = 'custom_workout_templates';

  late TabController _tabController;
  WorkoutCategory? _selectedCategory;
  DifficultyLevel? _selectedDifficulty;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<WorkoutCategory> _categories = WorkoutCategory.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCustomTemplates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<WorkoutTemplate> _getFilteredTemplates() {
    List<WorkoutTemplate> templates = WorkoutTemplateDatabase.templates;

    if (_searchQuery.isNotEmpty) {
      templates = WorkoutTemplateDatabase.search(_searchQuery);
    }

    if (_selectedCategory != null) {
      templates = templates
          .where((t) => t.category == _selectedCategory)
          .toList();
    }

    if (_selectedDifficulty != null) {
      templates = templates
          .where((t) => t.difficulty == _selectedDifficulty)
          .toList();
    }

    return templates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 140,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Workout Templates',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.fitness_center,
                    size: 60,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search workouts...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: const Text('All'),
                            selected: _selectedCategory == null,
                            onSelected: (selected) {
                              setState(() => _selectedCategory = null);
                            },
                          ),
                        );
                      }
                      final category = _categories[index - 1];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(_getCategoryName(category)),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : null;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Difficulty Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Difficulty',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildDifficultyChip(null, 'All'),
                      const SizedBox(width: 8),
                      _buildDifficultyChip(
                        DifficultyLevel.beginner,
                        'Beginner',
                      ),
                      const SizedBox(width: 8),
                      _buildDifficultyChip(
                        DifficultyLevel.intermediate,
                        'Intermediate',
                      ),
                      const SizedBox(width: 8),
                      _buildDifficultyChip(
                        DifficultyLevel.advanced,
                        'Advanced',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Featured Section (only show when no filters)
          if (_searchQuery.isEmpty &&
              _selectedCategory == null &&
              _selectedDifficulty == null)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Featured',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: WorkoutTemplateDatabase.getFeatured().length,
                      itemBuilder: (context, index) {
                        final template =
                            WorkoutTemplateDatabase.getFeatured()[index];
                        return _FeaturedTemplateCard(
                          template: template,
                          onTap: () => _showTemplateDetails(template),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'All Workouts',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

          // Templates List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final templates = _getFilteredTemplates();
                if (index >= templates.length) return null;
                final template = templates[index];
                return _TemplateCard(
                  template: template,
                  onTap: () => _showTemplateDetails(template),
                  onManage: template.isCustom
                      ? () => _showCustomTemplateActions(template)
                      : null,
                );
              }, childCount: _getFilteredTemplates().length),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTemplateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Create'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDifficultyChip(DifficultyLevel? difficulty, String label) {
    final isSelected = _selectedDifficulty == difficulty;
    return GestureDetector(
      onTap: () => setState(() => _selectedDifficulty = difficulty),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? _getDifficultyColor(difficulty)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _getCategoryName(WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.strength:
        return 'Strength';
      case WorkoutCategory.cardio:
        return 'Cardio';
      case WorkoutCategory.hiit:
        return 'HIIT';
      case WorkoutCategory.flexibility:
        return 'Flexibility';
      case WorkoutCategory.yoga:
        return 'Yoga';
      case WorkoutCategory.pilates:
        return 'Pilates';
      case WorkoutCategory.crossfit:
        return 'CrossFit';
      case WorkoutCategory.bodyweight:
        return 'Bodyweight';
      case WorkoutCategory.endurance:
        return 'Endurance';
      case WorkoutCategory.powerlifting:
        return 'Powerlifting';
      case WorkoutCategory.olympic:
        return 'Olympic';
      case WorkoutCategory.recovery:
        return 'Recovery';
      case WorkoutCategory.custom:
        return 'Custom';
    }
  }

  Color _getDifficultyColor(DifficultyLevel? difficulty) {
    if (difficulty == null) return AppColors.primary;
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.orange;
      case DifficultyLevel.advanced:
        return Colors.red;
      case DifficultyLevel.expert:
        return Colors.purple;
    }
  }

  void _showTemplateDetails(WorkoutTemplate template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TemplateDetailsSheet(
        template: template,
        onStartWorkout: () {
          Navigator.pop(context);
          _startWorkout(template);
        },
      ),
    );
  }

  void _startWorkout(WorkoutTemplate template) {
    final provider = context.read<FitnessProvider>();
    provider.startWorkout(name: template.name);

    final sortedExercises = [...template.exercises]
      ..sort((a, b) => a.order.compareTo(b.order));

    for (var i = 0; i < sortedExercises.length; i++) {
      provider.addExerciseToWorkout(_toWorkoutExercise(sortedExercises[i], i));
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
    );
  }

  WorkoutExercise _toWorkoutExercise(
    TemplateExercise templateExercise,
    int index,
  ) {
    final exercise = ExerciseDefinition(
      id: templateExercise.exerciseId,
      name: templateExercise.exerciseName,
      description: '${templateExercise.exerciseName} from template workout.',
      primaryMuscles: const [MuscleGroup.fullBody],
      equipment: const [Equipment.none],
      difficulty: Difficulty.intermediate,
      category: ExerciseCategory.strength,
      instructions: const [
        'Perform the movement with controlled tempo.',
        'Maintain proper form throughout each set.',
      ],
    );

    return WorkoutExercise(
      id: '${templateExercise.exerciseId}_${index}_${DateTime.now().millisecondsSinceEpoch}',
      exercise: exercise,
      targetSets: templateExercise.sets,
      targetReps: templateExercise.reps ?? 10,
      targetWeight: templateExercise.weight,
      restSeconds: templateExercise.restSeconds,
      notes: templateExercise.notes,
      orderIndex: index,
    );
  }

  void _showCreateTemplateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Custom Template'),
        content: const Text(
          'Create your own workout template by selecting exercises and configuring sets, reps, and rest times.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const _TemplateBuilderScreen(),
                ),
              ).then((createdTemplate) {
                if (createdTemplate is WorkoutTemplate && mounted) {
                  _persistCustomTemplates();
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Created template: ${createdTemplate.name}',
                      ),
                    ),
                  );
                }
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadCustomTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final customTemplatesJson =
        prefs.getStringList(_customTemplatesStorageKey) ?? const [];

    if (customTemplatesJson.isEmpty) {
      return;
    }

    final existingIds = WorkoutTemplateDatabase.templates
        .map((template) => template.id)
        .toSet();

    var inserted = false;
    for (final item in customTemplatesJson) {
      try {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        final template = WorkoutTemplate.fromJson(decoded);
        if (!existingIds.contains(template.id)) {
          WorkoutTemplateDatabase.templates.insert(0, template);
          existingIds.add(template.id);
          inserted = true;
        }
      } catch (_) {
        // Ignore malformed entries and continue loading valid templates.
      }
    }

    if (inserted && mounted) {
      setState(() {});
    }
  }

  Future<void> _persistCustomTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final customTemplates = WorkoutTemplateDatabase.templates
        .where((template) => template.isCustom)
        .map((template) => jsonEncode(template.toJson()))
        .toList();
    await prefs.setStringList(_customTemplatesStorageKey, customTemplates);
  }

  void _showCustomTemplateActions(WorkoutTemplate template) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename Template'),
              onTap: () {
                Navigator.pop(sheetContext);
                _renameTemplate(template);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Duplicate Template'),
              onTap: () {
                Navigator.pop(sheetContext);
                _duplicateTemplate(template);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Template'),
              textColor: Colors.red,
              onTap: () {
                Navigator.pop(sheetContext);
                _deleteTemplate(template);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _renameTemplate(WorkoutTemplate template) async {
    final nameController = TextEditingController(text: template.name);
    final descriptionController = TextEditingController(
      text: template.description,
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Template Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              if (name.isEmpty || description.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Name and description cannot be empty.'),
                  ),
                );
                return;
              }

              final index = WorkoutTemplateDatabase.templates.indexWhere(
                (item) => item.id == template.id,
              );
              if (index != -1) {
                WorkoutTemplateDatabase.templates[index] = template.copyWith(
                  name: name,
                  description: description,
                );
              }
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    nameController.dispose();
    descriptionController.dispose();

    if (result == true && mounted) {
      await _persistCustomTemplates();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template updated.')),
      );
    }
  }

  Future<void> _deleteTemplate(WorkoutTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Delete "${template.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    WorkoutTemplateDatabase.templates.removeWhere(
      (item) => item.id == template.id,
    );
    await _persistCustomTemplates();

    if (!mounted) {
      return;
    }
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Template deleted.')));
  }

  Future<void> _duplicateTemplate(WorkoutTemplate template) async {
    final now = DateTime.now();
    final duplicate = template.copyWith(
      id: 'custom_${now.millisecondsSinceEpoch}',
      name: '${template.name} Copy',
      createdAt: now,
      isCustom: true,
    );

    WorkoutTemplateDatabase.templates.insert(0, duplicate);
    await _persistCustomTemplates();
    if (!mounted) {
      return;
    }
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Template duplicated.')));
  }
}

class _TemplateBuilderScreen extends StatefulWidget {
  const _TemplateBuilderScreen();

  @override
  State<_TemplateBuilderScreen> createState() => _TemplateBuilderScreenState();
}

class _TemplateBuilderScreenState extends State<_TemplateBuilderScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '45');
  final _caloriesController = TextEditingController(text: '300');

  WorkoutCategory _category = WorkoutCategory.custom;
  DifficultyLevel _difficulty = DifficultyLevel.intermediate;
  final List<_EditableTemplateExercise> _exercises = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Template Builder')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Template Name',
                hintText: 'e.g. Upper Body Power',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What is this workout focused on?',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<WorkoutCategory>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: WorkoutCategory.values
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DifficultyLevel>(
              value: _difficulty,
              decoration: const InputDecoration(labelText: 'Difficulty'),
              items: DifficultyLevel.values
                  .map(
                    (difficulty) => DropdownMenuItem(
                      value: difficulty,
                      child: Text(difficulty.displayName),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _difficulty = value);
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (min)',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Calories (est.)',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Exercises',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_exercises.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Add at least one exercise with set/rep/rest targets.',
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercises.length,
                onReorder: _onReorderExercises,
                itemBuilder: (context, index) {
                  final item = _exercises[index];
                  return Card(
                    key: ValueKey('${item.name}_$index'),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.drag_indicator),
                      title: Text(item.name),
                      subtitle: Text(
                        '${item.sets} sets • ${item.reps} reps • ${item.restSeconds}s rest'
                        '${item.weight != null ? ' • ${item.weight}kg' : ''}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _editExercise(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              setState(() {
                                _exercises.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveTemplate,
                icon: const Icon(Icons.save),
                label: const Text('Save Template'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addExercise() async {
    await _showExerciseEditorDialog();
  }

  Future<void> _editExercise(int index) async {
    final exercise = _exercises[index];
    await _showExerciseEditorDialog(existingIndex: index, existing: exercise);
  }

  void _onReorderExercises(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, item);
    });
  }

  Future<void> _showExerciseEditorDialog({
    int? existingIndex,
    _EditableTemplateExercise? existing,
  }) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final setsController = TextEditingController(
      text: (existing?.sets ?? 3).toString(),
    );
    final repsController = TextEditingController(
      text: (existing?.reps ?? 10).toString(),
    );
    final restController = TextEditingController(
      text: (existing?.restSeconds ?? 60).toString(),
    );
    final weightController = TextEditingController();
    if (existing?.weight != null) {
      weightController.text = existing!.weight.toString();
    }

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(existingIndex == null ? 'Add Exercise' : 'Edit Exercise'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Exercise Name'),
              ),
              TextField(
                controller: setsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sets'),
              ),
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Reps'),
              ),
              TextField(
                controller: restController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Rest (seconds)'),
              ),
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Weight (optional, kg)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final sets = int.tryParse(setsController.text.trim()) ?? 0;
              final reps = int.tryParse(repsController.text.trim()) ?? 0;
              final rest = int.tryParse(restController.text.trim()) ?? 0;
              final weight = double.tryParse(weightController.text.trim());

              if (name.isEmpty || sets <= 0 || reps <= 0 || rest <= 0) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Fill all required fields with valid values.'),
                  ),
                );
                return;
              }

              setState(() {
                final updatedExercise = _EditableTemplateExercise(
                  name: name,
                  sets: sets,
                  reps: reps,
                  restSeconds: rest,
                  weight: weight,
                );
                if (existingIndex == null) {
                  _exercises.add(updatedExercise);
                } else {
                  _exercises[existingIndex] = updatedExercise;
                }
              });
              Navigator.pop(dialogContext);
            },
            child: Text(existingIndex == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );

    nameController.dispose();
    setsController.dispose();
    repsController.dispose();
    restController.dispose();
    weightController.dispose();
  }

  void _saveTemplate() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final duration = int.tryParse(_durationController.text.trim()) ?? 0;
    final calories = int.tryParse(_caloriesController.text.trim()) ?? 0;

    if (name.isEmpty || description.isEmpty || duration <= 0 || _exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete all required fields and add exercises.'),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final template = WorkoutTemplate(
      id: 'custom_${now.millisecondsSinceEpoch}',
      name: name,
      description: description,
      category: _category,
      difficulty: _difficulty,
      estimatedDuration: Duration(minutes: duration),
      estimatedCalories: calories,
      isCustom: true,
      createdAt: now,
      exercises: _exercises.asMap().entries
          .map(
            (entry) => TemplateExercise(
              exerciseId: 'custom_ex_${entry.key}_${now.millisecondsSinceEpoch}',
              exerciseName: entry.value.name,
              sets: entry.value.sets,
              reps: entry.value.reps,
              weight: entry.value.weight,
              restSeconds: entry.value.restSeconds,
              order: entry.key + 1,
            ),
          )
          .toList(),
    );

    WorkoutTemplateDatabase.templates.insert(0, template);
    Navigator.pop(context, template);
  }
}

class _EditableTemplateExercise {
  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final double? weight;

  const _EditableTemplateExercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.weight,
  });
}

// Featured Template Card Widget
class _FeaturedTemplateCard extends StatelessWidget {
  final WorkoutTemplate template;
  final VoidCallback onTap;

  const _FeaturedTemplateCard({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getCategoryGradientStart(template.category),
              _getCategoryGradientEnd(template.category),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _getCategoryGradientStart(
                template.category,
              ).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _getCategoryIcon(template.category),
                color: Colors.white,
                size: 32,
              ),
              const Spacer(),
              Text(
                template.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${template.estimatedDuration.inMinutes} min • ${template.exercises.length} exercises',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getDifficultyName(template.difficulty),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryGradientStart(WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.strength:
        return Colors.blue[700]!;
      case WorkoutCategory.cardio:
        return Colors.red[600]!;
      case WorkoutCategory.hiit:
        return Colors.orange[700]!;
      case WorkoutCategory.flexibility:
        return Colors.purple[600]!;
      case WorkoutCategory.yoga:
        return Colors.teal[600]!;
      case WorkoutCategory.pilates:
        return Colors.pink[600]!;
      case WorkoutCategory.crossfit:
        return Colors.deepOrange[600]!;
      case WorkoutCategory.bodyweight:
        return Colors.green[600]!;
      case WorkoutCategory.endurance:
        return Colors.indigo[600]!;
      case WorkoutCategory.powerlifting:
        return Colors.grey[800]!;
      case WorkoutCategory.olympic:
        return Colors.amber[600]!;
      case WorkoutCategory.recovery:
        return Colors.cyan[600]!;
      case WorkoutCategory.custom:
        return Colors.amber[700]!;
    }
  }

  Color _getCategoryGradientEnd(WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.strength:
        return Colors.blue[900]!;
      case WorkoutCategory.cardio:
        return Colors.red[900]!;
      case WorkoutCategory.hiit:
        return Colors.orange[900]!;
      case WorkoutCategory.flexibility:
        return Colors.purple[900]!;
      case WorkoutCategory.yoga:
        return Colors.teal[900]!;
      case WorkoutCategory.pilates:
        return Colors.pink[900]!;
      case WorkoutCategory.crossfit:
        return Colors.deepOrange[900]!;
      case WorkoutCategory.bodyweight:
        return Colors.green[900]!;
      case WorkoutCategory.endurance:
        return Colors.indigo[900]!;
      case WorkoutCategory.powerlifting:
        return Colors.grey[900]!;
      case WorkoutCategory.olympic:
        return Colors.amber[900]!;
      case WorkoutCategory.recovery:
        return Colors.cyan[900]!;
      case WorkoutCategory.custom:
        return Colors.amber[900]!;
    }
  }

  IconData _getCategoryIcon(WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.strength:
        return Icons.fitness_center;
      case WorkoutCategory.cardio:
        return Icons.directions_run;
      case WorkoutCategory.hiit:
        return Icons.flash_on;
      case WorkoutCategory.flexibility:
        return Icons.self_improvement;
      case WorkoutCategory.yoga:
        return Icons.spa;
      case WorkoutCategory.pilates:
        return Icons.self_improvement;
      case WorkoutCategory.crossfit:
        return Icons.sports_mma;
      case WorkoutCategory.bodyweight:
        return Icons.accessibility_new;
      case WorkoutCategory.endurance:
        return Icons.timer;
      case WorkoutCategory.powerlifting:
        return Icons.sports_gymnastics;
      case WorkoutCategory.olympic:
        return Icons.emoji_events;
      case WorkoutCategory.recovery:
        return Icons.healing;
      case WorkoutCategory.custom:
        return Icons.edit;
    }
  }

  String _getDifficultyName(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
      case DifficultyLevel.expert:
        return 'Expert';
    }
  }
}

// Template Card Widget
class _TemplateCard extends StatelessWidget {
  final WorkoutTemplate template;
  final VoidCallback onTap;
  final VoidCallback? onManage;

  const _TemplateCard({
    required this.template,
    required this.onTap,
    this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    template.category,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(template.category),
                  color: _getCategoryColor(template.category),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.timer,
                          '${template.estimatedDuration.inMinutes} min',
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          Icons.local_fire_department,
                          '${template.estimatedCalories} cal',
                        ),
                        const SizedBox(width: 8),
                        _buildDifficultyBadge(template.difficulty),
                      ],
                    ),
                  ],
                ),
              ),
              if (onManage != null)
                IconButton(
                  onPressed: onManage,
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'Manage custom template',
                )
              else
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
      ],
    );
  }

  Widget _buildDifficultyBadge(DifficultyLevel difficulty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getDifficultyColor(difficulty).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _getDifficultyName(difficulty),
        style: TextStyle(
          color: _getDifficultyColor(difficulty),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getCategoryColor(WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.strength:
        return Colors.blue[700]!;
      case WorkoutCategory.cardio:
        return Colors.red[600]!;
      case WorkoutCategory.hiit:
        return Colors.orange[700]!;
      case WorkoutCategory.flexibility:
        return Colors.purple[600]!;
      case WorkoutCategory.yoga:
        return Colors.teal[600]!;
      case WorkoutCategory.pilates:
        return Colors.pink[600]!;
      case WorkoutCategory.crossfit:
        return Colors.deepOrange[600]!;
      case WorkoutCategory.bodyweight:
        return Colors.green[600]!;
      case WorkoutCategory.endurance:
        return Colors.indigo[600]!;
      case WorkoutCategory.powerlifting:
        return Colors.grey[800]!;
      case WorkoutCategory.olympic:
        return Colors.amber[600]!;
      case WorkoutCategory.recovery:
        return Colors.cyan[600]!;
      case WorkoutCategory.custom:
        return Colors.amber[700]!;
    }
  }

  IconData _getCategoryIcon(WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.strength:
        return Icons.fitness_center;
      case WorkoutCategory.cardio:
        return Icons.directions_run;
      case WorkoutCategory.hiit:
        return Icons.flash_on;
      case WorkoutCategory.flexibility:
        return Icons.self_improvement;
      case WorkoutCategory.yoga:
        return Icons.spa;
      case WorkoutCategory.pilates:
        return Icons.self_improvement;
      case WorkoutCategory.crossfit:
        return Icons.sports_mma;
      case WorkoutCategory.bodyweight:
        return Icons.accessibility_new;
      case WorkoutCategory.endurance:
        return Icons.timer;
      case WorkoutCategory.powerlifting:
        return Icons.sports_gymnastics;
      case WorkoutCategory.olympic:
        return Icons.emoji_events;
      case WorkoutCategory.recovery:
        return Icons.healing;
      case WorkoutCategory.custom:
        return Icons.edit;
    }
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.orange;
      case DifficultyLevel.advanced:
        return Colors.red;
      case DifficultyLevel.expert:
        return Colors.purple;
    }
  }

  String _getDifficultyName(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
      case DifficultyLevel.expert:
        return 'Expert';
    }
  }
}

// Template Details Bottom Sheet
class _TemplateDetailsSheet extends StatelessWidget {
  final WorkoutTemplate template;
  final VoidCallback onStartWorkout;

  const _TemplateDetailsSheet({
    required this.template,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getCategoryColor(template.category),
                              _getCategoryColor(
                                template.category,
                              ).withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getCategoryIcon(template.category),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              template.description,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        Icons.timer,
                        '${template.estimatedDuration.inMinutes}',
                        'Minutes',
                      ),
                      _buildStatItem(
                        Icons.local_fire_department,
                        '${template.estimatedCalories}',
                        'Calories',
                      ),
                      _buildStatItem(
                        Icons.fitness_center,
                        '${template.exercises.length}',
                        'Exercises',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Target Muscles
                  Text(
                    'Target Muscles',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: template.targetMuscles.map((muscle) {
                      return Chip(
                        label: Text(muscle),
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        labelStyle: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Equipment
                  Text(
                    'Equipment Needed',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: template.equipment.map((item) {
                      return Chip(
                        label: Text(item),
                        backgroundColor: Colors.grey[200],
                        labelStyle: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Exercises List
                  Text(
                    'Exercises',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...template.exercises.asMap().entries.map((entry) {
                    final index = entry.key;
                    final exercise = entry.value;
                    return _ExerciseListItem(
                      index: index + 1,
                      exercise: exercise,
                    );
                  }),
                  const SizedBox(height: 80),
                ],
              ),
            ),

            // Start Workout Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onStartWorkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Start Workout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Color _getCategoryColor(WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.strength:
        return Colors.blue[700]!;
      case WorkoutCategory.cardio:
        return Colors.red[600]!;
      case WorkoutCategory.hiit:
        return Colors.orange[700]!;
      case WorkoutCategory.flexibility:
        return Colors.purple[600]!;
      case WorkoutCategory.yoga:
        return Colors.teal[600]!;
      case WorkoutCategory.pilates:
        return Colors.pink[600]!;
      case WorkoutCategory.crossfit:
        return Colors.deepOrange[600]!;
      case WorkoutCategory.bodyweight:
        return Colors.green[600]!;
      case WorkoutCategory.endurance:
        return Colors.indigo[600]!;
      case WorkoutCategory.powerlifting:
        return Colors.grey[800]!;
      case WorkoutCategory.olympic:
        return Colors.amber[600]!;
      case WorkoutCategory.recovery:
        return Colors.cyan[600]!;
      case WorkoutCategory.custom:
        return Colors.amber[700]!;
    }
  }

  IconData _getCategoryIcon(WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.strength:
        return Icons.fitness_center;
      case WorkoutCategory.cardio:
        return Icons.directions_run;
      case WorkoutCategory.hiit:
        return Icons.flash_on;
      case WorkoutCategory.flexibility:
        return Icons.self_improvement;
      case WorkoutCategory.yoga:
        return Icons.spa;
      case WorkoutCategory.pilates:
        return Icons.self_improvement;
      case WorkoutCategory.crossfit:
        return Icons.sports_mma;
      case WorkoutCategory.bodyweight:
        return Icons.accessibility_new;
      case WorkoutCategory.endurance:
        return Icons.timer;
      case WorkoutCategory.powerlifting:
        return Icons.sports_gymnastics;
      case WorkoutCategory.olympic:
        return Icons.emoji_events;
      case WorkoutCategory.recovery:
        return Icons.healing;
      case WorkoutCategory.custom:
        return Icons.edit;
    }
  }
}

// Exercise List Item Widget
class _ExerciseListItem extends StatelessWidget {
  final int index;
  final TemplateExercise exercise;

  const _ExerciseListItem({required this.index, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.exerciseName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getExerciseDetails(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hourglass_empty,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${exercise.restSeconds}s',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getExerciseDetails() {
    final parts = <String>[];
    parts.add('${exercise.sets} sets');

    if (exercise.reps != null) {
      parts.add('${exercise.reps} reps');
    }

    if (exercise.durationSeconds != null) {
      parts.add('${exercise.durationSeconds}s');
    }

    if (exercise.weight != null) {
      parts.add('${exercise.weight} kg');
    }

    return parts.join(' × ');
  }
}
