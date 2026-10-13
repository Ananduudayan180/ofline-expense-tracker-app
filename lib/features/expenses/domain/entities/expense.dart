import 'expense_category.dart';

class Expense {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime dateTime;
  final String? note;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.dateTime,
    this.note,
  });

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? dateTime,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          amount == other.amount &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ amount.hashCode;
}
