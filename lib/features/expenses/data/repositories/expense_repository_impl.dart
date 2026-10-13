import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_data_source.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;

  ExpenseRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Expense>> getAllExpenses() async {
    final models = await localDataSource.getExpenses();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await localDataSource.saveExpense(model);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await localDataSource.saveExpense(model);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await localDataSource.deleteExpense(id);
  }

  @override
  Stream<List<Expense>> watchExpenses() {
    return localDataSource
        .watchExpenses()
        .map((models) => models.map((m) => m.toEntity()).toList());
  }
}
