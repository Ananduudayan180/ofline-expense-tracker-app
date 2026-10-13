import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String categoryName;
  final int timestamp;
  final String? note;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryName,
    required this.timestamp,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'categoryName': categoryName,
      'timestamp': timestamp,
      'note': note,
    };
  }

  factory ExpenseModel.fromMap(Map<dynamic, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      categoryName: map['categoryName'] as String? ?? 'Other',
      timestamp: map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      note: map['note'] as String?,
    );
  }

  Expense toEntity() {
    return Expense(
      id: id,
      title: title,
      amount: amount,
      category: ExpenseCategory.fromString(categoryName),
      dateTime: DateTime.fromMillisecondsSinceEpoch(timestamp),
      note: note,
    );
  }

  factory ExpenseModel.fromEntity(Expense entity) {
    return ExpenseModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      categoryName: entity.category.label,
      timestamp: entity.dateTime.millisecondsSinceEpoch,
      note: entity.note,
    );
  }
}
