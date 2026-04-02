import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:fitness_tracker/main.dart';
import 'package:fitness_tracker/providers/fitness_provider.dart';
import 'package:fitness_tracker/services/settings_service.dart';

void main() {
  testWidgets('App builds with required providers', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FitnessProvider()),
          ChangeNotifierProvider(create: (_) => SettingsService()),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.byType(MyApp), findsOneWidget);
  });
}
