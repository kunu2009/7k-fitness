import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int? _expandedIndex;

  final List<FAQSection> _faqSections = [
    FAQSection(
      title: 'Getting Started',
      icon: Icons.play_circle,
      color: Colors.green,
      items: [
        FAQItem(
          question: 'How do I set up my profile?',
          answer:
              '''When you first open the app, you'll go through a setup wizard:

1. Enter your name, age, and gender
2. Input your height and weight (choose your preferred units)
3. Select your activity level
4. Choose your fitness goal (lose weight, maintain, or gain muscle)

Your calorie and macro targets will be automatically calculated based on this information. You can update your profile anytime in Settings.''',
        ),
        FAQItem(
          question: 'How are my calorie goals calculated?',
          answer:
              '''Your daily calorie goal is calculated using the Mifflin-St Jeor equation:

**BMR (Basal Metabolic Rate):**
• Men: (10 × weight in kg) + (6.25 × height in cm) - (5 × age) + 5
• Women: (10 × weight in kg) + (6.25 × height in cm) - (5 × age) - 161

**TDEE (Total Daily Energy Expenditure):**
BMR × Activity Multiplier

**Goal Adjustment:**
• Weight Loss: TDEE - 500 calories
• Maintain: TDEE
• Muscle Gain: TDEE + 300 calories''',
        ),
        FAQItem(
          question: 'What units can I use?',
          answer: '''The app supports multiple unit systems:

**Weight:** kg or lbs
**Height:** cm or feet/inches
**Distance:** km or miles
**Water:** ml or oz

You can change units anytime in Settings → Units. Your data is stored internally in metric and converted for display.''',
        ),
      ],
    ),
    FAQSection(
      title: 'Nutrition Tracking',
      icon: Icons.restaurant_menu,
      color: Colors.orange,
      items: [
        FAQItem(
          question: 'How do I log my meals?',
          answer: '''To log a meal:

1. Go to Nutrition from the bottom navigation
2. Tap the + button or select a meal time
3. Search for food from our database of 500+ items
4. Adjust portion size if needed
5. Tap "Add" to log

**Tips:**
• Log meals immediately after eating
• Use the barcode scanner for packaged foods
• Create custom foods for your favorites''',
        ),
        FAQItem(
          question: 'How do I track my macros?',
          answer:
              '''Macros (protein, carbs, fat) are automatically tracked when you log food:

**On the Nutrition screen:**
• See daily totals at the top
• View macro breakdown by meal
• Check the pie chart for ratio

**Macro Goals:**
• Protein: Essential for muscle repair
• Carbs: Primary energy source
• Fat: Hormones and vitamin absorption

Your macro targets are set based on your calorie goal and can be adjusted in Settings.''',
        ),
        FAQItem(
          question: 'Can I add custom foods?',
          answer: '''Yes! To add a custom food:

1. In Nutrition, tap + to add food
2. Scroll down and tap "Create Custom Food"
3. Enter the food name
4. Add nutritional info (calories, protein, carbs, fat)
5. Optionally add serving size info
6. Save

Your custom foods will appear in search results for easy logging.''',
        ),
      ],
    ),
    FAQSection(
      title: 'Workout Tracking',
      icon: Icons.fitness_center,
      color: Colors.purple,
      items: [
        FAQItem(
          question: 'How do I log a workout?',
          answer: '''There are several ways to log workouts:

**Using Templates:**
1. Go to Workout → Templates
2. Select a pre-made routine
3. Start the workout
4. Log sets and reps for each exercise
5. Complete when done

**Quick Log:**
1. Go to Workout → Quick Log
2. Add exercises manually
3. Enter sets, reps, and weight
4. Save workout

**Calories burned are estimated based on exercise type, duration, and your body weight.''',
        ),
        FAQItem(
          question: 'How do I create a workout program?',
          answer: '''To create a custom program:

1. Go to Workout → Programs
2. Tap "Create Program"
3. Name your program
4. Add workouts for each day
5. For each workout, add exercises from the database
6. Set target sets and reps
7. Save program

**Program Features:**
• Schedule which days to train
• Track progressive overload
• View program progress''',
        ),
        FAQItem(
          question: 'What exercises are available?',
          answer: '''The app includes 100+ exercises organized by:

**Muscle Groups:**
• Chest, Back, Shoulders
• Arms (Biceps, Triceps)
• Legs (Quads, Hamstrings, Glutes)
• Core, Full Body

**Equipment:**
• Barbell, Dumbbell
• Machine, Cable
• Bodyweight, Bands

**Exercise Types:**
• Compound (multi-joint)
• Isolation (single-joint)
• Cardio''',
        ),
      ],
    ),
    FAQSection(
      title: 'Health Tracking',
      icon: Icons.favorite,
      color: Colors.red,
      items: [
        FAQItem(
          question: 'How do I track my water intake?',
          answer: '''To track water:

1. From Home, find the Water card
2. Tap + to add water
3. Select preset amount or enter custom
4. View daily progress

**Tips:**
• Set water reminders in Settings
• Default goal is 8 glasses (2000ml)
• Adjust goal based on activity level
• Log water throughout the day''',
        ),
        FAQItem(
          question: 'How does sleep tracking work?',
          answer: '''To log sleep:

1. From Home, tap Sleep card
2. Enter bedtime and wake time
3. Rate sleep quality (optional)
4. Add notes (optional)
5. Save

**Sleep Goals:**
• Adults need 7-9 hours
• Consistency is key
• Quality matters as much as quantity

**Features:**
• View sleep patterns over time
• Track sleep quality trends
• Set bedtime reminders''',
        ),
        FAQItem(
          question: 'How do I track body measurements?',
          answer: '''To track body composition:

1. From Home, tap Body Composition
2. Enter measurements:
   • Weight
   • Body fat % (optional)
   • Muscle mass (optional)
   • Measurements (chest, waist, etc.)
3. Save with date

**Tips:**
• Measure same time each day
• Morning before eating is best
• Weekly measurements are enough
• Take progress photos too''',
        ),
      ],
    ),
    FAQSection(
      title: 'Goals & Progress',
      icon: Icons.flag,
      color: Colors.teal,
      items: [
        FAQItem(
          question: 'How do I set fitness goals?',
          answer: '''To create a goal:

1. Go to Progress → Goals
2. Tap "Add Goal"
3. Select goal type:
   • Weight goal
   • Workout frequency
   • Nutrition target
   • Custom goal
4. Set target value and deadline
5. Save

**Goal Types:**
• Lose/Gain X lbs/kg
• Work out X times per week
• Hit calorie goal X days
• Complete a program''',
        ),
        FAQItem(
          question: 'How do I view my progress?',
          answer: '''View progress in multiple ways:

**Progress Tab:**
• Weight trend chart
• Body measurements over time
• Goal completion %

**Statistics Tab:**
• Weekly/monthly summaries
• Workout analytics
• Nutrition averages
• Personal records

**Home Screen:**
• Daily progress rings
• Week at a glance
• Recent achievements''',
        ),
        FAQItem(
          question: 'What are achievements?',
          answer: '''Achievements reward your consistency:

**Types:**
• First workout logged
• Week streak
• Month streak
• Weight milestones
• Workout milestones

**Benefits:**
• Motivation boost
• Track milestones
• Share on social

View all achievements in Progress → Achievements''',
        ),
      ],
    ),
    FAQSection(
      title: 'Tips & Best Practices',
      icon: Icons.lightbulb,
      color: Colors.amber,
      items: [
        FAQItem(
          question: 'What\'s the best daily routine?',
          answer: '''Recommended daily workflow:

**Morning:**
☀️ Weigh yourself (optional, same time daily)
☀️ Log breakfast after eating
☀️ Check daily calorie goal

**During the Day:**
🏃 Log workouts after completion
🍽️ Log meals within 30 min of eating
💧 Track water throughout

**Evening:**
🌙 Complete dinner logging
🌙 Review daily summary
🌙 Log sleep when going to bed

**Weekly:**
📊 Review progress on Sundays
📸 Take progress photos
🎯 Adjust goals if needed''',
        ),
        FAQItem(
          question: 'How do I stay consistent?',
          answer: '''Tips for building habits:

**Start Small:**
• Don't try to be perfect day 1
• Focus on logging, not hitting targets
• Build the habit first

**Use Reminders:**
• Enable water reminders
• Set workout schedule
• Meal logging notifications

**Track Progress:**
• Check weekly stats
• Celebrate small wins
• Don't let one bad day derail you

**Be Patient:**
• Real results take 4-8 weeks
• Weight fluctuates daily
• Progress isn't always linear''',
        ),
        FAQItem(
          question: 'Why am I not seeing results?',
          answer: '''Common issues and solutions:

**Not Losing Weight:**
• Are you logging everything? (drinks, snacks)
• Measure portions accurately
• Give it more time (4+ weeks)
• Recalculate TDEE if weight changed

**Not Gaining Muscle:**
• Eating enough protein?
• Progressive overload in workouts?
• Getting enough sleep?
• Being consistent?

**General Tips:**
• Trust the process
• Focus on trends, not daily numbers
• Consider taking a diet break
• Consult a professional if stuck''',
        ),
      ],
    ),
  ];

  List<FAQSection> get _filteredSections {
    if (_searchQuery.isEmpty) return _faqSections;

    return _faqSections
        .map((section) {
          final filteredItems = section.items
              .where(
                (item) =>
                    item.question.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    item.answer.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();

          return FAQSection(
            title: section.title,
            icon: section.icon,
            color: section.color,
            items: filteredItems,
          );
        })
        .where((section) => section.items.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search help topics...',
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // FAQ sections
          Expanded(
            child: _filteredSections.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredSections.length,
                    itemBuilder: (context, sectionIndex) {
                      final section = _filteredSections[sectionIndex];
                      return _buildSection(section, sectionIndex);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(FAQSection section, int sectionIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: section.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(section.icon, color: section.color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                section.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // FAQ items
        ...section.items.asMap().entries.map((entry) {
          final itemIndex = sectionIndex * 100 + entry.key;
          final item = entry.value;
          final isExpanded = _expandedIndex == itemIndex;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _expandedIndex = isExpanded ? null : itemIndex;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.question,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.answer,
                        style: TextStyle(color: Colors.grey[700], height: 1.6),
                      ),
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

class FAQSection {
  final String title;
  final IconData icon;
  final Color color;
  final List<FAQItem> items;

  FAQSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
