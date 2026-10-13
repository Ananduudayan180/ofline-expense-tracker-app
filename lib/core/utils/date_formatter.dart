import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDisplayDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (targetDate == today) {
      return 'Today, ${DateFormat('h:mm a').format(dateTime)}';
    } else if (targetDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat('h:mm a').format(dateTime)}';
    } else if (dateTime.year == now.year) {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }

  static String formatFullDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final formatted = DateFormat('MMM d, yyyy').format(dateTime);
    if (targetDate == today) {
      return 'Today, $formatted';
    }
    return formatted;
  }

  static String formatMonthYear(DateTime dateTime) {
    return DateFormat('MMMM yyyy').format(dateTime);
  }
}
