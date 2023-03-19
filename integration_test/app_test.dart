import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:pma/main.dart' as app;
import 'package:pma/manager/app_storage_manager.dart';
import 'package:pma/widgets/floating_action_button_extended.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('app test', () {
    setUp(() async {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final AppStorageManager appStorageManager = AppStorageManager(
        sharedPreferences: sharedPreferences,
        flutterSecureStorage: const FlutterSecureStorage(),
      );
      appStorageManager.clearStorage();
    });

    testWidgets('UI flow test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final NavigatorState navigator = tester.state(find.byType(Navigator));

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();
      navigator.pop();
      await tester.pumpAndSettle();

      final Finder emailFormField = find.byType(TextFormField).first;
      final Finder passwordFormField = find.byType(TextFormField).last;
      final Finder loginButton = find.byType(ElevatedButton).first;
      expect(loginButton, findsOneWidget);

      await tester.enterText(emailFormField, 'testuser@gmail.com');
      await tester.enterText(passwordFormField, 'Test#user123');
      await tester.pumpAndSettle();

      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      final Finder projectListTile = find.byType(ListTile).first;
      await tester.tap(projectListTile);

      await tester.tap(find.text('Test One'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Task One'));
      await tester.pumpAndSettle();

      navigator.pop();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton).first);
      await tester.pumpAndSettle();
      navigator.pop();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Note One'));
      await tester.pumpAndSettle();
      navigator.pop();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton).first);
      await tester.pumpAndSettle();
      navigator.pop();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Document One'));
      await tester.pumpAndSettle();
      navigator.pop();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton).first);
      await tester.pumpAndSettle();
      navigator.pop();
      await tester.pumpAndSettle();

      navigator.pop();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Milestones'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      navigator.pop();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton).first);
      await tester.pumpAndSettle();
      navigator.pop();
      await tester.pumpAndSettle();

      navigator.pop();
      await tester.pumpAndSettle();

      navigator.pop();
      await tester.pumpAndSettle();

      navigator.pop();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person_outline_rounded).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      navigator.pop();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.nightlight_round).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings_suggest_rounded).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.color_lens_rounded).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButtonExtended).first);
      await tester.pumpAndSettle();
    });
  });
}
