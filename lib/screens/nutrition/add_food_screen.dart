import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/nutrition.dart';
import '../../data/food_database.dart';

class AddFoodScreen extends StatefulWidget {
  final MealType defaultMealType;

  const AddFoodScreen({super.key, required this.defaultMealType});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _searchResults = [];
  FoodCategory? _selectedCategory;
  late MealType _selectedMealType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedMealType = widget.defaultMealType;
    _searchResults = FoodDatabase.popularFoods;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = _selectedCategory != null
            ? FoodDatabase.byCategory(_selectedCategory!)
            : FoodDatabase.popularFoods;
      } else {
        _searchResults = FoodDatabase.search(query);
        if (_selectedCategory != null) {
          _searchResults = _searchResults
              .where((f) => f.category == _selectedCategory)
              .toList();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Food'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Search'),
            Tab(text: 'Recent'),
            Tab(text: 'Custom'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Meal type selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Meal: ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: MealType.values.map((meal) {
                        final isSelected = meal == _selectedMealType;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text('${meal.icon} ${meal.displayName}'),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedMealType = meal;
                                });
                              }
                            },
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSearchTab(),
                _buildRecentTab(),
                _buildCustomTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            onChanged: _search,
            decoration: InputDecoration(
              hintText: 'Search foods...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _search('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Category filters
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryChip(null, 'All'),
              ...FoodCategory.values
                  .take(8)
                  .map((cat) => _buildCategoryChip(cat, cat.icon)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Results
        Expanded(
          child: _searchResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: AppColors.textSecondary.withAlpha(128),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No foods found',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          _tabController.animateTo(2);
                        },
                        child: const Text('Create custom food'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final food = _searchResults[index];
                    return _buildFoodTile(food);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(FoodCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
            _search(_searchController.text);
          });
        },
        selectedColor: AppColors.primary.withAlpha(51),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildFoodTile(FoodItem food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              food.category.icon,
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        title: Text(
          food.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${food.servingSize.toInt()} ${food.servingUnit}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${food.nutrition.calories.toInt()} cal',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              'P:${food.nutrition.protein.toInt()}g C:${food.nutrition.carbs.toInt()}g F:${food.nutrition.fat.toInt()}g',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        onTap: () => _showServingsDialog(food),
      ),
    );
  }

  Widget _buildRecentTab() {
    // For now, show popular foods as "recent"
    final recentFoods = FoodDatabase.popularFoods;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Popular Foods',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...recentFoods.map((food) => _buildFoodTile(food)),
        const SizedBox(height: 24),
        const Text(
          'Quick Add',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildQuickAddButton('🍳 Eggs', 78, 2)),
            const SizedBox(width: 8),
            Expanded(child: _buildQuickAddButton('🍞 Toast', 80, 1)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildQuickAddButton('🥤 Protein Shake', 120, 1)),
            const SizedBox(width: 8),
            Expanded(child: _buildQuickAddButton('🍌 Banana', 105, 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAddButton(String label, int calories, int servings) {
    return OutlinedButton(
      onPressed: () {
        // Quick add logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $label'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: AppColors.primary.withAlpha(128)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        children: [
          Text(label),
          Text(
            '$calories cal',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Custom Food',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTextField('Food Name', 'e.g., Homemade Pasta'),
          const SizedBox(height: 12),
          _buildTextField('Brand (optional)', 'e.g., Trader Joe\'s'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField('Serving Size', 'e.g., 100')),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField('Unit', 'e.g., g, oz, cup')),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Nutrition Facts',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildTextField('Calories', '0', keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Protein (g)',
                  '0',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  'Carbs (g)',
                  '0',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  'Fat (g)',
                  '0',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Save custom food
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Custom food created!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Create Food',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  void _showServingsDialog(FoodItem food) {
    double servings = 1.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final scaledNutrition = food.nutrition.scale(servings);

          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Food info
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          food.category.icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${food.servingSize.toInt()} ${food.servingUnit}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Servings selector
                const Text(
                  'Number of Servings',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      onPressed: servings > 0.5
                          ? () => setModalState(() => servings -= 0.5)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.primary,
                    ),
                    Expanded(
                      child: Slider(
                        value: servings,
                        min: 0.5,
                        max: 5,
                        divisions: 9,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setModalState(() => servings = value);
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: servings < 5
                          ? () => setModalState(() => servings += 0.5)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        servings.toStringAsFixed(1),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Nutrition preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNutrientPreview(
                        'Calories',
                        scaledNutrition.calories.toInt().toString(),
                        'kcal',
                      ),
                      _buildNutrientPreview(
                        'Protein',
                        scaledNutrition.protein.toInt().toString(),
                        'g',
                      ),
                      _buildNutrientPreview(
                        'Carbs',
                        scaledNutrition.carbs.toInt().toString(),
                        'g',
                      ),
                      _buildNutrientPreview(
                        'Fat',
                        scaledNutrition.fat.toInt().toString(),
                        'g',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Add button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final entry = FoodEntry(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        food: food,
                        servings: servings,
                        mealType: _selectedMealType,
                        loggedAt: DateTime.now(),
                      );
                      Navigator.pop(context);
                      Navigator.pop(context, entry);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Add to ${_selectedMealType.displayName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNutrientPreview(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
