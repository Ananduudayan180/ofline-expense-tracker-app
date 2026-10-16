import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_category.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/expense_providers.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/edit_expense_bottom_sheet.dart';

class MockExpenseRepository implements ExpenseRepository {
  List<Expense> expenses = [];
  bool updateCalled = false;

  MockExpenseRepository(this.expenses);

  @override
  Future<List<Expense>> getAllExpenses() async => List.from(expenses);

  @override
  Future<void> addExpense(Expense expense) async {
    expenses.add(expense);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    updateCalled = true;
    final index = expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      expenses[index] = expense;
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    expenses.removeWhere((e) => e.id == id);
  }

  @override
  Stream<List<Expense>> watchExpenses() => Stream.value(expenses);
}

void main() {
  group('Edit Expense Provider Tests', () {
    test('updateExpense updates the expense and refreshes stats', () async {
      final now = DateTime.now();
      final initialExpense = Expense(
        id: 'test_1',
        title: 'Lunch',
        amount: 25.0,
        category: ExpenseCategory.fromType(ExpenseCategoryType.food),
        dateTime: now,
        note: 'Quick burger',
      );

      final repo = MockExpenseRepository([initialExpense]);

      final container = ProviderContainer(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      // Initial state
      final list = await container.read(expenseListProvider.future);
      expect(list.length, 1);
      expect(list.first.title, 'Lunch');
      expect(list.first.amount, 25.0);

      final initialMonthStats = container.read(currentMonthStatsProvider);
      expect(initialMonthStats.totalAmount, 25.0);

      // Update the expense
      final updatedExpense = initialExpense.copyWith(
        title: 'Fancy Dinner',
        amount: 80.0,
        category: ExpenseCategory.fromType(ExpenseCategoryType.food),
      );

      await container
          .read(expenseListProvider.notifier)
          .updateExpense(updatedExpense);

      // Verify list updated
      final updatedList = await container.read(expenseListProvider.future);
      expect(updatedList.length, 1);
      expect(updatedList.first.id, 'test_1');
      expect(updatedList.first.title, 'Fancy Dinner');
      expect(updatedList.first.amount, 80.0);

      // Verify stats updated automatically
      final updatedMonthStats = container.read(currentMonthStatsProvider);
      expect(updatedMonthStats.totalAmount, 80.0);

      final todayStats = container.read(todayStatsProvider);
      expect(todayStats.total, 80.0);
    });
  });

  group('Edit Expense Bottom Sheet Widget Tests', () {
    testWidgets('Does not have a Title field, shows warning when unedited', (tester) async {
      final now = DateTime.now();
      final initialExpense = Expense(
        id: 'test_1',
        title: 'Food & Dining',
        amount: 25.0,
        category: ExpenseCategory.fromType(ExpenseCategoryType.food),
        dateTime: now,
      );

      final repo = MockExpenseRepository([initialExpense]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: EditExpenseBottomSheet(expense: initialExpense),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify NO "Title" label or field exists
      expect(find.text('Title'), findsNothing);
      expect(find.text('Expense title'), findsNothing);

      // Verify "Note" field exists with hint
      expect(find.text('Note'), findsOneWidget);
      expect(find.text('Add a note (optional)'), findsOneWidget);

      // Verify "Update" button is displayed initially
      expect(find.text('Update'), findsOneWidget);

      // Ensure Update button is visible in scrollview and tap
      await tester.ensureVisible(find.text('Update'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      // It should NOT call updateExpense and instead show warning "No Changes Made"
      expect(repo.updateCalled, isFalse);
      expect(find.text('No Changes Made'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

      // Now enter a note in the note field
      await tester.ensureVisible(find.byType(TextField).last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Delicious Burrito');
      await tester.pumpAndSettle();

      // Warning disappears, "Update" button reappears
      expect(find.text('Update'), findsOneWidget);
      expect(find.text('No Changes Made'), findsNothing);

      // Now tap "Update"
      await tester.ensureVisible(find.text('Update'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      // Update was called and title took the value of note
      expect(repo.updateCalled, isTrue);
      expect(repo.expenses.first.title, 'Delicious Burrito');
      expect(repo.expenses.first.note, 'Delicious Burrito');
    });
  });
}
