import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static const String defaultSymbol = '₹';

  static String format(double amount, {String symbol = defaultSymbol, bool includeSign = false}) {
    final formatter = NumberFormat('#,##0.00');
    final formatted = formatter.format(amount.abs());
    final sign = includeSign ? (amount < 0 ? '-' : '+') : '';
    return '$sign$symbol$formatted';
  }

  static String formatCompact(double amount, {String symbol = defaultSymbol}) {
    final formatter = NumberFormat('#,##0');
    return '$symbol${formatter.format(amount.abs())}';
  }
}
