import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/home_screen.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ExpenseTrackerApp(),
      ),
    );

    // Verify HomeScreen renders
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
