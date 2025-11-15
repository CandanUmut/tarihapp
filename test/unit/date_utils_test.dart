import 'package:dinhistory/core/utils/date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('encode and decode date round trips', () {
    final now = DateTime(2024, 5, 1);
    final encoded = AppDateUtils.encodeDate(now);
    expect(encoded, 20240501);
    final decoded = AppDateUtils.decodeDate(encoded);
    expect(decoded.year, now.year);
    expect(decoded.month, now.month);
    expect(decoded.day, now.day);
  });
}
