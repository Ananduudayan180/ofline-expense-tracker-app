import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/core/theme/theme_provider.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/theme_toggle_button.dart';

void main() {
  group('Theme Mode Notifier Tests', () {
    test('Initial theme mode defaults to light', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final themeMode = container.read(themeModeProvider);
      expect(themeMode, ThemeMode.light);
    });

    test('Toggle theme switches between light and dark', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeModeProvider), ThemeMode.light);

      await container.read(themeModeProvider.notifier).toggleTheme();
      expect(container.read(themeModeProvider), ThemeMode.dark);

      await container.read(themeModeProvider.notifier).toggleTheme();
      expect(container.read(themeModeProvider), ThemeMode.light);
    });
  });

  group('Theme Toggle Button Widget Tests', () {
    testWidgets('Renders ThemeToggleButton on Home Screen and toggles theme on tap', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: ExpenseTrackerApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify ThemeToggleButton is rendered on the home screen
      final toggleButtonFinder = find.byType(ThemeToggleButton);
      expect(toggleButtonFinder, findsOneWidget);

      // Verify light mode initially shows dark_mode icon (prompting to switch to dark)
      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);

      // Tap the toggle button
      await tester.tap(toggleButtonFinder);
      await tester.pumpAndSettle();

      // Verify it switches to dark mode icon (prompting to switch to light)
      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

      // Tap again to switch back to light mode
      await tester.tap(toggleButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    });
  });
}
