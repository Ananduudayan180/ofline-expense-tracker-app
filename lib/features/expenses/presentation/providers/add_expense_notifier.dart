import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';

class AddExpenseState {
  final double amount;
  final String rawAmountInput;
  final ExpenseCategory category;
  final DateTime date;
  final String note;
  final String? customTitle;

  const AddExpenseState({
    required this.amount,
    required this.rawAmountInput,
    required this.category,
    required this.date,
    required this.note,
    this.customTitle,
  });

  factory AddExpenseState.initial() {
    return AddExpenseState(
      amount: 24.50,
      rawAmountInput: '24.50',
      category: ExpenseCategory.fromType(ExpenseCategoryType.food),
      date: DateTime.now(),
      note: '',
    );
  }

  AddExpenseState copyWith({
    double? amount,
    String? rawAmountInput,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
    String? customTitle,
  }) {
    return AddExpenseState(
      amount: amount ?? this.amount,
      rawAmountInput: rawAmountInput ?? this.rawAmountInput,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      customTitle: customTitle ?? this.customTitle,
    );
  }
}

class AddExpenseNotifier extends Notifier<AddExpenseState> {
  static const _uuid = Uuid();

  @override
  AddExpenseState build() => AddExpenseState.initial();

  void setAmountFromInput(String input) {
    final parsed = double.tryParse(input) ?? 0.0;
    state = state.copyWith(amount: parsed, rawAmountInput: input);
  }

  void adjustAmount(double delta) {
    final newAmount = (state.amount + delta).clamp(0.0, 999999.0);
    state = state.copyWith(
      amount: newAmount,
      rawAmountInput: newAmount.toStringAsFixed(2),
    );
  }

  void clearAmount() {
    state = state.copyWith(amount: 0.0, rawAmountInput: '');
  }

  void selectCategory(ExpenseCategory category) {
    state = state.copyWith(category: category);
  }

  void selectDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void setNote(String note) {
    state = state.copyWith(note: note);
  }

  void reset() {
    state = AddExpenseState.initial();
  }

  Expense buildExpense() {
    final effectiveTitle = state.note.trim().isNotEmpty
        ? state.note.trim()
        : state.category.fullName;

    return Expense(
      id: _uuid.v4(),
      title: effectiveTitle,
      amount: state.amount,
      category: state.category,
      dateTime: state.date,
      note: state.note.trim().isNotEmpty ? state.note.trim() : null,
    );
  }
}

final addExpenseNotifierProvider =
    NotifierProvider<AddExpenseNotifier, AddExpenseState>(AddExpenseNotifier.new);
