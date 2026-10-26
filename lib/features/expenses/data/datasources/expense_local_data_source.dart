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
    : _box = box ?? HiveService.expensesBox;

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
