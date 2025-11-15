import 'package:intl/intl.dart';

typedef DateInt = int;

class AppDateUtils {
  const AppDateUtils._();

  static DateInt encodeDate(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }

  static DateTime decodeDate(DateInt value) {
    final year = value ~/ 10000;
    final month = (value % 10000) ~/ 100;
    final day = value % 100;
    return DateTime(year, month, day);
  }

  static String humanize(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    return DateFormat.yMMMd().format(date);
  }
}
