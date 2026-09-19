import 'package:edencrew_assignment_starter/core/utils/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('yyyyMMdd 날짜를 MM.dd 형식으로 표시한다', () {
    expect(formatMonthDay('20260919'), '09.19');
    expect(formatMonthDay('20240229'), '02.29');
  });

  test('형식이 다르거나 실제로 존재하지 않는 날짜를 거부한다', () {
    expect(() => formatMonthDay('2026-09-19'), throwsFormatException);
    expect(() => formatMonthDay('20230229'), throwsFormatException);
    expect(() => formatMonthDay('20261301'), throwsFormatException);
  });
}
