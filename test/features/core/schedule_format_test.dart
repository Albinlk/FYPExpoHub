import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/utils/schedule_format.dart';

void main() {
  test('withMytDate moves the day and keeps the Malaysia wall-clock time', () {
    // 09:00 MYT on 6 Aug 2026 is 01:00 UTC.
    final start = DateTime.utc(2026, 8, 6, 1);
    final moved = withMytDate(start, DateTime(2027, 3, 10));
    expect(moved, DateTime.utc(2027, 3, 10, 1));
    expect(mytDate(moved), DateTime(2027, 3, 10));
  });

  test('withMytDate handles a time that is on the previous UTC day', () {
    // 07:00 MYT on 6 Aug 2026 is 23:00 UTC on 5 Aug.
    final start = DateTime.utc(2026, 8, 5, 23);
    expect(withMytDate(start, DateTime(2026, 9, 1)), DateTime.utc(2026, 8, 31, 23));
  });
}
