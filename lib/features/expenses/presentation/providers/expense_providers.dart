import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/expense_local_data_source.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';
import '../../domain/entities/period_stats.dart';
import '../../domain/repositories/expense_repository.dart';

// Data Source Provider
final expenseLocalDataSourceProvider = Provider<ExpenseLocalDataSource>((ref) {
  return ExpenseLocalDataSourceImpl();
});

// Repository Provider
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final dataSource = ref.watch(expenseLocalDataSourceProvider);
  return ExpenseRepositoryImpl(localDataSource: dataSource);
});

// Expense List Notifier
class ExpenseListNotifier extends AsyncNotifier<List<Expense>> {
  @override
  Future<List<Expense>> build() async {
    final repository = ref.watch(expenseRepositoryProvider);
    return repository.getAllExpenses();
  }

  Future<void> addExpense(Expense expense) async {
    final previousState = state;
    try {
      final repository = ref.read(expenseRepositoryProvider);
      await repository.addExpense(expense);
      final updated = await repository.getAllExpenses();
      state = AsyncData(updated);
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    final previousState = state;
    try {
      final repository = ref.read(expenseRepositoryProvider);
      await repository.deleteExpense(id);
      final updated = await repository.getAllExpenses();
      state = AsyncData(updated);
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }
}

final expenseListProvider =
    AsyncNotifierProvider<ExpenseListNotifier, List<Expense>>(ExpenseListNotifier.new);

// Selected Stats Period Notifier (Daily, Weekly, Monthly)
class SelectedStatsPeriodNotifier extends Notifier<StatsPeriod> {
  @override
  StatsPeriod build() => StatsPeriod.monthly;

  void setPeriod(StatsPeriod period) {
    state = period;
  }
}

final selectedStatsPeriodProvider =
    NotifierProvider<SelectedStatsPeriodNotifier, StatsPeriod>(
        SelectedStatsPeriodNotifier.new);

// Monthly Total Provider
final currentMonthStatsProvider = Provider<PeriodStats>((ref) {
  final expensesAsync = ref.watch(expenseListProvider);
  final expenses = expensesAsync.value ?? [];
  return _calculateStats(expenses, StatsPeriod.monthly);
});

// Today Spending Provider
final todayStatsProvider = Provider<({double total, int count})>((ref) {
  final expensesAsync = ref.watch(expenseListProvider);
  final expenses = expensesAsync.value ?? [];
  final now = DateTime.now();

  final todayExpenses = expenses.where((e) {
    return e.dateTime.year == now.year &&
        e.dateTime.month == now.month &&
        e.dateTime.day == now.day;
  }).toList();

  final total = todayExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);
  return (total: total, count: todayExpenses.length);
});

// Filtered Period Stats Provider for the Statistics Screen
final periodStatsProvider = Provider<PeriodStats>((ref) {
  final period = ref.watch(selectedStatsPeriodProvider);
  final expensesAsync = ref.watch(expenseListProvider);
  final expenses = expensesAsync.value ?? [];
  return _calculateStats(expenses, period);
});

PeriodStats _calculateStats(List<Expense> expenses, StatsPeriod period) {
  final now = DateTime.now();
  List<Expense> filtered = [];
  List<Expense> previousFiltered = [];

  switch (period) {
    case StatsPeriod.daily:
      final todayStart = DateTime(now.year, now.month, now.day);
      final yesterdayStart = todayStart.subtract(const Duration(days: 1));

      filtered = expenses.where((e) => e.dateTime.isAfter(todayStart)).toList();
      previousFiltered = expenses.where((e) {
        return e.dateTime.isAfter(yesterdayStart) &&
            e.dateTime.isBefore(todayStart);
      }).toList();
      break;

    case StatsPeriod.weekly:
      final weekStart = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      final prevWeekStart = weekStart.subtract(const Duration(days: 7));

      filtered = expenses.where((e) => e.dateTime.isAfter(weekStart)).toList();
      previousFiltered = expenses.where((e) {
        return e.dateTime.isAfter(prevWeekStart) &&
            e.dateTime.isBefore(weekStart);
      }).toList();
      break;

    case StatsPeriod.monthly:
      // Use explicit local-time boundaries so they align with timestamps
      // restored via DateTime.fromMillisecondsSinceEpoch (which is UTC-based
      // unless the device timezone is accounted for).
      final monthStart = DateTime(now.year, now.month, 1);

      // Safe previous-month calculation: go to the 1st of current month,
      // then subtract one day to land in the previous month, then snap to
      // the 1st of that month.
      final prevMonthEnd = DateTime(now.year, now.month, 1);
      final prevMonthStart = DateTime(
        prevMonthEnd.year,
        prevMonthEnd.month - 1,
        1,
      );

      filtered = expenses
          .where((e) => !e.dateTime.toLocal().isBefore(monthStart))
          .toList();
      previousFiltered = expenses.where((e) {
        final dt = e.dateTime.toLocal();
        return !dt.isBefore(prevMonthStart) && dt.isBefore(prevMonthEnd);
      }).toList();
      break;
  }

  final total = filtered.fold<double>(0.0, (sum, e) => sum + e.amount);
  final previousTotal =
      previousFiltered.fold<double>(0.0, (sum, e) => sum + e.amount);

  // Group by category
  final Map<ExpenseCategoryType, ({double amount, int count})> categoryMap = {};
  for (final cat in ExpenseCategory.all) {
    categoryMap[cat.type] = (amount: 0.0, count: 0);
  }

  for (final e in filtered) {
    final current = categoryMap[e.category.type]!;
    categoryMap[e.category.type] = (
      amount: current.amount + e.amount,
      count: current.count + 1,
    );
  }

  final breakdowns = <CategoryBreakdown>[];
  for (final cat in ExpenseCategory.all) {
    final data = categoryMap[cat.type]!;
    final percentage = total > 0 ? (data.amount / total) * 100 : 0.0;
    breakdowns.add(CategoryBreakdown(
      category: cat,
      amount: data.amount,
      count: data.count,
      percentage: percentage,
    ));
  }

  // Sort descending by amount
  breakdowns.sort((a, b) => b.amount.compareTo(a.amount));

  final topCategory = breakdowns.isNotEmpty && breakdowns.first.amount > 0
      ? breakdowns.first
      : null;

  // Calculate percentage change:
  // - If both are 0 → 0.0%
  // - If previous is 0 but current > 0 → treat as +100% (new spending baseline)
  // - Otherwise → standard % change formula
  final double percentageChange;
  if (previousTotal == 0.0 && total == 0.0) {
    percentageChange = 0.0;
  } else if (previousTotal == 0.0) {
    percentageChange = 100.0; // went from nothing to some spending
  } else {
    percentageChange = ((total - previousTotal) / previousTotal) * 100;
  }

  final count = filtered.length;
  final avg = count > 0 ? total / count : 0.0;

  return PeriodStats(
    period: period,
    totalAmount: total,
    count: count,
    averageAmount: avg,
    categoryBreakdowns: breakdowns,
    topCategory: topCategory,
    previousPeriodAmount: previousTotal,
    percentageChangeFromPrevious: percentageChange,
  );
}
