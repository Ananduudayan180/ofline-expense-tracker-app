import 'expense_category.dart';

enum StatsPeriod { daily, weekly, monthly }

enum SpendingTrend { noChange, newSpending, increase, decrease }

class CategoryBreakdown {
  final ExpenseCategory category;
  final double amount;
  final int count;
  final double percentage; // 0.0 to 100.0

  const CategoryBreakdown({
    required this.category,
    required this.amount,
    required this.count,
    required this.percentage,
  });
}

class PeriodStats {
  final StatsPeriod period;
  final double totalAmount;
  final int count;
  final double averageAmount;
  final List<CategoryBreakdown> categoryBreakdowns;
  final CategoryBreakdown? topCategory;
  final double previousPeriodAmount;
  final double percentageChangeFromPrevious; // e.g. -4.2%
  final SpendingTrend spendingTrend;

  const PeriodStats({
    required this.period,
    required this.totalAmount,
    required this.count,
    required this.averageAmount,
    required this.categoryBreakdowns,
    this.topCategory,
    this.previousPeriodAmount = 0.0,
    this.percentageChangeFromPrevious = 0.0,
    this.spendingTrend = SpendingTrend.noChange,
  });

  String get percentageChangeLabel {
    switch (spendingTrend) {
      case SpendingTrend.newSpending:
        return 'New Spending';
      case SpendingTrend.noChange:
        return 'No Change';
      case SpendingTrend.decrease:
        if (totalAmount == 0.0 && previousPeriodAmount > 0.0) {
          return '-100%';
        }
        return '-${percentageChangeFromPrevious.abs().toStringAsFixed(1)}%';
      case SpendingTrend.increase:
        return '+${percentageChangeFromPrevious.toStringAsFixed(1)}%';
    }
  }
}
