import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String expensesBoxName = 'expenses_box';
  static const String settingsBoxName = 'settings_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(expensesBoxName);
    await Hive.openBox<dynamic>(settingsBoxName);
  }

  static Box<Map> get expensesBox => Hive.box<Map>(expensesBoxName);
  static Box<dynamic> get settingsBox => Hive.box<dynamic>(settingsBoxName);
}
