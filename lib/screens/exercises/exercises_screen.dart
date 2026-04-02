import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/exercise.dart';
import '../../data/exercise_database.dart';
import '../../widgets/exercise_widgets.dart';
import 'exercise_detail_screen.dart';

class ExercisesScreen extends StatefulWidget {
  final bool isSelectionMode;
  final Function(ExerciseDefinition)? onExerciseSelected;

  const ExercisesScreen({
    super.key,
    this.isSelectionMode = false,
    this.onExerciseSelected,
  });

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<MuscleGroup> _selectedMuscleGroups = [];
  final List<Equipment> _selectedEquipment = [];
  Difficulty? _selectedDifficulty;
  ExerciseCategory? _selectedCategory;
  bool _showFilters = false;

  List<ExerciseDefinition> get _filteredExercises {
    var exercises = ExerciseDatabase.allExercises;

    // Search filter
    if (_searchController.text.isNotEmpty) {
      exercises = ExerciseDatabase.search(_searchController.text);
    }

    // Muscle group filter
    if (_selectedMuscleGroups.isNotEmpty) {
      exercises = exercises
          .where(
            (e) =>
                _selectedMuscleGroups.any((m) => e.primaryMuscles.contains(m)),
          )
          .toList();
    }

    // Equipment filter
    if (_selectedEquipment.isNotEmpty) {
      exercises = exercises
          .where(
            (e) => _selectedEquipment.any((eq) => e.equipment.contains(eq)),
          )
          .toList();
    }

    // Difficulty filter
    if (_selectedDifficulty != null) {
      exercises = exercises
          .where((e) => e.difficulty == _selectedDifficulty)
          .toList();
    }

    // Category filter
    if (_selectedCategory != null) {
      exercises = exercises
          .where((e) => e.category == _selectedCategory)
          .toList();
    }

    return exercises;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedMuscleGroups.clear();
      _selectedEquipment.clear();
      _selectedDifficulty = null;
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSelectionMode ? 'Select Exercise' : 'Exercise Library',
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: _hasActiveFilters ? AppColors.primary : null,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filters
          if (_showFilters) _buildFilters(),

          // Quick filter chips
          if (!_showFilters)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildQuickFilterChip(
                    'Bodyweight',
                    Equipment.none,
                    _selectedEquipment.contains(Equipment.none),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickFilterChip(
                    'Dumbbells',
                    Equipment.dumbbells,
                    _selectedEquipment.contains(Equipment.dumbbells),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickFilterChip(
                    'Barbell',
                    Equipment.barbell,
                    _selectedEquipment.contains(Equipment.barbell),
                  ),
                  const SizedBox(width: 8),
                  if (_hasActiveFilters)
                    ActionChip(
                      label: const Text('Clear All'),
                      onPressed: _clearFilters,
                      backgroundColor: AppColors.error.withValues(alpha: 0.1),
                      labelStyle: const TextStyle(color: AppColors.error),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_filteredExercises.length} exercises',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Exercise list
          Expanded(
            child: _filteredExercises.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredExercises.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      return ExerciseCard(
                        exercise: exercise,
                        onTap: () {
                          if (widget.isSelectionMode) {
                            widget.onExerciseSelected?.call(exercise);
                            Navigator.pop(context);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ExerciseDetailScreen(exercise: exercise),
                              ),
                            );
                          }
                        },
                        onAdd: widget.isSelectionMode
                            ? () {
                                widget.onExerciseSelected?.call(exercise);
                                Navigator.pop(context);
                              }
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters =>
      _selectedMuscleGroups.isNotEmpty ||
      _selectedEquipment.isNotEmpty ||
      _selectedDifficulty != null ||
      _selectedCategory != null;

  Widget _buildQuickFilterChip(
    String label,
    Equipment equipment,
    bool isSelected,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          if (isSelected) {
            _selectedEquipment.remove(equipment);
          } else {
            _selectedEquipment.add(equipment);
          }
        });
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category filter
          const Text(
            'Category',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ExerciseCategory.values.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category.name),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = isSelected ? null : category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Difficulty filter
          const Text(
            'Difficulty',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: Difficulty.values.map((difficulty) {
                final isSelected = _selectedDifficulty == difficulty;
                Color color;
                switch (difficulty) {
                  case Difficulty.beginner:
                    color = Colors.green;
                    break;
                  case Difficulty.intermediate:
                    color = Colors.orange;
                    break;
                  case Difficulty.advanced:
                    color = Colors.red;
                    break;
                  case Difficulty.expert:
                    color = Colors.purple;
                    break;
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(difficulty.name),
                    selected: isSelected,
                    selectedColor: color.withValues(alpha: 0.2),
                    onSelected: (_) {
                      setState(() {
                        _selectedDifficulty = isSelected ? null : difficulty;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Muscle groups
          const Text(
            'Muscle Groups',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          MuscleGroupFilter(
            selectedGroups: _selectedMuscleGroups,
            onToggle: (group) {
              setState(() {
                if (_selectedMuscleGroups.contains(group)) {
                  _selectedMuscleGroups.remove(group);
                } else {
                  _selectedMuscleGroups.add(group);
                }
              });
            },
          ),
          const SizedBox(height: 16),

          // Clear filters button
          if (_hasActiveFilters)
            Center(
              child: TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Clear All Filters'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No exercises found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
