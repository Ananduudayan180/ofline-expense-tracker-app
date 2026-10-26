import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_category.dart';
import 'package:expense_tracker/features/expenses/domain/entities/period_stats.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/expense_providers.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/hero_spend_card.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/hero_monthly_card.dart';

class MockExpenseRepo implements ExpenseRepository {
  List<Expense> expenses;
  MockExpenseRepo(this.expenses);

  @override
  Future<List<Expense>> getAllExpenses() async => List.from(expenses);

  @override
  Future<void> addExpense(Expense expense) async {
    expenses.add(expense);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final index = expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) expenses[index] = expense;
  }

  @override
  Future<void> deleteExpense(String id) async {
    expenses.removeWhere((e) => e.id == id);
  }

  @override
  Stream<List<Expense>> watchExpenses() => Stream.value(expenses);
}

class InitialPeriodNotifier extends SelectedStatsPeriodNotifier {
  final StatsPeriod initialPeriod;
  InitialPeriodNotifier(this.initialPeriod);

  @override
  StatsPeriod build() => initialPeriod;
}

void main() {
  group('PeriodStats Entity & percentageChangeLabel Tests', () {
    test('Both periods 0 spending returns No Change', () {
      const stats = PeriodStats(
        period: StatsPeriod.monthly,
        totalAmount: 0.0,
        count: 0,
        averageAmount: 0.0,
        categoryBreakdowns: [],
        previousPeriodAmount: 0.0,
        percentageChangeFromPrevious: 0.0,
        spendingTrend: SpendingTrend.noChange,
      );

      expect(stats.spendingTrend, SpendingTrend.noChange);
      expect(stats.percentageChangeLabel, 'No Change');
    });

    test('Previous period 0 and current > 0 returns New Spending', () {
      const stats = PeriodStats(
        period: StatsPeriod.monthly,
        totalAmount: 150.0,
        count: 2,
        averageAmount: 75.0,
        categoryBreakdowns: [],
        previousPeriodAmount: 0.0,
        percentageChangeFromPrevious: 0.0,
        spendingTrend: SpendingTrend.newSpending,
      );

      expect(stats.spendingTrend, SpendingTrend.newSpending);
      expect(stats.percentageChangeLabel, 'New Spending');
    });

    test('Current period 0 and previous > 0 returns -100%', () {
      const stats = PeriodStats(
        period: StatsPeriod.monthly,
        totalAmount: 0.0,
        count: 0,
        averageAmount: 0.0,
        categoryBreakdowns: [],
        previousPeriodAmount: 200.0,
        percentageChangeFromPrevious: -100.0,
        spendingTrend: SpendingTrend.decrease,
      );

      expect(stats.spendingTrend, SpendingTrend.decrease);
      expect(stats.percentageChangeLabel, '-100%');
    });

    test('Normal increase calculates percentage change correctly', () {
      const stats = PeriodStats(
        period: StatsPeriod.monthly,
        totalAmount: 150.0,
        count: 3,
        averageAmount: 50.0,
        categoryBreakdowns: [],
        previousPeriodAmount: 100.0,
        percentageChangeFromPrevious: 50.0,
        spendingTrend: SpendingTrend.increase,
      );

      expect(stats.spendingTrend, SpendingTrend.increase);
      expect(stats.percentageChangeLabel, '+50.0%');
    });

    test('Normal decrease calculates percentage change correctly', () {
      const stats = PeriodStats(
        period: StatsPeriod.monthly,
        totalAmount: 80.0,
        count: 2,
        averageAmount: 40.0,
        categoryBreakdowns: [],
        previousPeriodAmount: 100.0,
        percentageChangeFromPrevious: -20.0,
        spendingTrend: SpendingTrend.decrease,
      );

      expect(stats.spendingTrend, SpendingTrend.decrease);
      expect(stats.percentageChangeLabel, '-20.0%');
    });
  });

  group('Provider Percentage Logic & Period Calculations', () {
    test('Daily stats: compares today vs yesterday correctly', () async {
      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day, 10, 0);
      final yesterdayMidnight = DateTime(
        now.year,
        now.month,
        now.day - 1,
        14,
        0,
      );

      final expenses = [
        Expense(
          id: '1',
          title: 'Today Lunch',
          amount: 50.0,
          category: ExpenseCategory.fromType(ExpenseCategoryType.food),
          dateTime: todayMidnight,
        ),
        Expense(
          id: '2',
          title: 'Yesterday Dinner',
          amount: 25.0,
          category: ExpenseCategory.fromType(ExpenseCategoryType.food),
          dateTime: yesterdayMidnight,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(
            MockExpenseRepo(expenses),
          ),
          selectedStatsPeriodProvider.overrideWith(
            () => InitialPeriodNotifier(StatsPeriod.daily),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(expenseListProvider.future);
      final stats = container.read(periodStatsProvider);

      expect(stats.period, StatsPeriod.daily);
      expect(stats.totalAmount, 50.0);
      expect(stats.previousPeriodAmount, 25.0);
      // ((50 - 25) / 25) * 100 = +100%
      expect(stats.percentageChangeFromPrevious, 100.0);
      expect(stats.spendingTrend, SpendingTrend.increase);
    });

    test('Daily stats: New Spending when yesterday had 0 spending', () async {
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day, 12, 0);

      final expenses = [
        Expense(
          id: '1',
          title: 'Coffee',
          amount: 5.0,
          category: ExpenseCategory.fromType(ExpenseCategoryType.food),
          dateTime: todayDate,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(
            MockExpenseRepo(expenses),
          ),
          selectedStatsPeriodProvider.overrideWith(
            () => InitialPeriodNotifier(StatsPeriod.daily),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(expenseListProvider.future);
      final stats = container.read(periodStatsProvider);

      expect(stats.totalAmount, 5.0);
      expect(stats.previousPeriodAmount, 0.0);
      expect(stats.spendingTrend, SpendingTrend.newSpending);
      expect(stats.percentageChangeLabel, 'New Spending');
    });

    test('Weekly stats: 100% decrease when current week is 0 and last week had spending', () async {
      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);
      final weekStart = todayMidnight.subtract(Duration(days: now.weekday - 1));
      final lastWeekDate = weekStart.subtract(const Duration(days: 3));

      final expenses = [
        Expense(
          id: '1',
          title: 'Last Week Groceries',
          amount: 80.0,
          category: ExpenseCategory.fromType(ExpenseCategoryType.shopping),
          dateTime: lastWeekDate,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(
            MockExpenseRepo(expenses),
          ),
          selectedStatsPeriodProvider.overrideWith(
            () => InitialPeriodNotifier(StatsPeriod.weekly),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(expenseListProvider.future);
      final stats = container.read(periodStatsProvider);

      expect(stats.totalAmount, 0.0);
      expect(stats.previousPeriodAmount, 80.0);
      expect(stats.percentageChangeFromPrevious, -100.0);
      expect(stats.spendingTrend, SpendingTrend.decrease);
      expect(stats.percentageChangeLabel, '-100%');
    });

    test('Monthly stats: No Change when both months have 0 spending', () async {
      final container = ProviderContainer(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(MockExpenseRepo([])),
          selectedStatsPeriodProvider.overrideWith(
            () => InitialPeriodNotifier(StatsPeriod.monthly),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(expenseListProvider.future);
      final stats = container.read(periodStatsProvider);

      expect(stats.totalAmount, 0.0);
      expect(stats.previousPeriodAmount, 0.0);
      expect(stats.percentageChangeFromPrevious, 0.0);
      expect(stats.spendingTrend, SpendingTrend.noChange);
      expect(stats.percentageChangeLabel, 'No Change');
    });

    test(
      'Monthly stats: compares current month vs previous month correctly',
      () async {
        final now = DateTime.now();
        final thisMonthDate = DateTime(now.year, now.month, 2, 10, 0);
        final lastMonthDate = DateTime(now.year, now.month - 1, 15, 10, 0);

        final expenses = [
          Expense(
            id: '1',
            title: 'This Month Rent',
            amount: 300.0,
            category: ExpenseCategory.fromType(ExpenseCategoryType.bills),
            dateTime: thisMonthDate,
          ),
          Expense(
            id: '2',
            title: 'Last Month Rent',
            amount: 400.0,
            category: ExpenseCategory.fromType(ExpenseCategoryType.bills),
            dateTime: lastMonthDate,
          ),
        ];

        final container = ProviderContainer(
          overrides: [
            expenseRepositoryProvider.overrideWithValue(
              MockExpenseRepo(expenses),
            ),
            selectedStatsPeriodProvider.overrideWith(
              () => InitialPeriodNotifier(StatsPeriod.monthly),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container.read(expenseListProvider.future);
        final stats = container.read(periodStatsProvider);

        expect(stats.totalAmount, 300.0);
        expect(stats.previousPeriodAmount, 400.0);
        // ((300 - 400) / 400) * 100 = -25.0%
        expect(stats.percentageChangeFromPrevious, -25.0);
        expect(stats.spendingTrend, SpendingTrend.decrease);
        expect(stats.percentageChangeLabel, '-25.0%');
      },
    );
  });

  group('Widget Tests: HeroSpendCard & HeroMonthlyCard Labels', () {
    testWidgets('HeroSpendCard displays "New Spending" for new spending', (
      tester,
    ) async {
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day, 11, 0);

      final expenses = [
        Expense(
          id: '1',
          title: 'Book',
          amount: 20.0,
          category: ExpenseCategory.fromType(ExpenseCategoryType.shopping),
          dateTime: todayDate,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseRepositoryProvider.overrideWithValue(
              MockExpenseRepo(expenses),
            ),
            selectedStatsPeriodProvider.overrideWith(
              () => InitialPeriodNotifier(StatsPeriod.daily),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: HeroSpendCard())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('New Spending'), findsOneWidget);
      expect(find.text('100.0%'), findsNothing);
    });

    testWidgets(
      'HeroSpendCard displays "No Change" when both periods are zero',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              expenseRepositoryProvider.overrideWithValue(MockExpenseRepo([])),
              selectedStatsPeriodProvider.overrideWith(
                () => InitialPeriodNotifier(StatsPeriod.daily),
              ),
            ],
            child: const MaterialApp(home: Scaffold(body: HeroSpendCard())),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('No Change'), findsOneWidget);
      },
    );

    testWidgets(
      'HeroSpendCard displays "-100%" when current is 0 and previous > 0',
      (tester) async {
        final now = DateTime.now();
        final yesterdayDate = DateTime(now.year, now.month, now.day - 1, 15, 0);

        final expenses = [
          Expense(
            id: '1',
            title: 'Snack',
            amount: 15.0,
            category: ExpenseCategory.fromType(ExpenseCategoryType.food),
            dateTime: yesterdayDate,
          ),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              expenseRepositoryProvider.overrideWithValue(
                MockExpenseRepo(expenses),
              ),
              selectedStatsPeriodProvider.overrideWith(
                () => InitialPeriodNotifier(StatsPeriod.daily),
              ),
            ],
            child: const MaterialApp(home: Scaffold(body: HeroSpendCard())),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('-100%'), findsOneWidget);
      },
    );

    testWidgets(
      'HeroMonthlyCard displays "New Spending", "No Change", and "-100%"',
      (tester) async {
        // Test New Spending
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: HeroMonthlyCard(
                totalAmount: 50.0,
                previousAmount: 0.0,
                spendingTrend: SpendingTrend.newSpending,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('New Spending'), findsOneWidget);

        // Test No Change
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: HeroMonthlyCard(
                totalAmount: 0.0,
                previousAmount: 0.0,
                spendingTrend: SpendingTrend.noChange,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('No Change'), findsOneWidget);

        // Test -100%
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: HeroMonthlyCard(
                totalAmount: 0.0,
                previousAmount: 100.0,
                percentageChange: -100.0,
                spendingTrend: SpendingTrend.decrease,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('-100%'), findsOneWidget);
      },
    );
  });
}
