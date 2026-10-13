import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/database/hive_service.dart';
import '../models/expense_model.dart';

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses();
  Future<void> saveExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Stream<List<ExpenseModel>> watchExpenses();
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  final Box<Map> _box;

  ExpenseLocalDataSourceImpl({Box<Map>? box})
      : _box = box ?? HiveService.expensesBox {
    _seedInitialDataIfNeeded();
  }

  void _seedInitialDataIfNeeded() {
    if (_box.isEmpty) {
      final now = DateTime.now();
      final sampleExpenses = [
        ExpenseModel(
          id: 'seed_1',
          title: 'Artisan Bakery & Cafe',
          amount: 14.50,
          categoryName: 'Food',
          timestamp: now.subtract(const Duration(hours: 3)).millisecondsSinceEpoch,
          note: 'Croissant and espresso',
        ),
        ExpenseModel(
          id: 'seed_2',
          title: 'Metro Transit Card',
          amount: 24.00,
          categoryName: 'Travel',
          timestamp: now.subtract(const Duration(hours: 7)).millisecondsSinceEpoch,
          note: 'Weekly pass refill',
        ),
        ExpenseModel(
          id: 'seed_3',
          title: 'Hardware & Housewares',
          amount: 82.10,
          categoryName: 'Shopping',
          timestamp: now.subtract(const Duration(days: 1, hours: 2)).millisecondsSinceEpoch,
          note: 'Kitchen storage containers',
        ),
        ExpenseModel(
          id: 'seed_4',
          title: 'City Electric Utility',
          amount: 64.30,
          categoryName: 'Bills',
          timestamp: now.subtract(const Duration(days: 4)).millisecondsSinceEpoch,
          note: 'Monthly power bill',
        ),
        ExpenseModel(
          id: 'seed_5',
          title: 'Farmer\'s Market Groceries',
          amount: 135.50,
          categoryName: 'Food',
          timestamp: now.subtract(const Duration(days: 7)).millisecondsSinceEpoch,
          note: 'Fresh produce & organic dairy',
        ),
        ExpenseModel(
          id: 'seed_6',
          title: 'High-speed Fiber Internet',
          amount: 45.00,
          categoryName: 'Bills',
          timestamp: now.subtract(const Duration(days: 12)).millisecondsSinceEpoch,
          note: 'Home wifi subscription',
        ),
      ];

      for (final expense in sampleExpenses) {
        _box.put(expense.id, expense.toMap());
      }
    }
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final list = <ExpenseModel>[];
    for (final value in _box.values) {
      list.add(ExpenseModel.fromMap(value));
    }
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  @override
  Future<void> saveExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense.toMap());
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
  }

  @override
  Stream<List<ExpenseModel>> watchExpenses() {
    return _box.watch().map((_) {
      final list = <ExpenseModel>[];
      for (final value in _box.values) {
        list.add(ExpenseModel.fromMap(value));
      }
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    }).asBroadcastStream();
  }
}
