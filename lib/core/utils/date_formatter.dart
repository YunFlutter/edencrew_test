String formatMonthDay(String localDate) {
  if (!RegExp(r'^\d{8}$').hasMatch(localDate)) {
    throw FormatException('날짜는 yyyyMMdd 형식이어야 합니다.', localDate);
  }

  final year = int.parse(localDate.substring(0, 4));
  final month = int.parse(localDate.substring(4, 6));
  final day = int.parse(localDate.substring(6, 8));
  final parsed = DateTime.utc(year, month, day);
  final isValid =
      parsed.year == year && parsed.month == month && parsed.day == day;
  if (!isValid) {
    throw FormatException('유효한 날짜가 아닙니다.', localDate);
  }

  return '${localDate.substring(4, 6)}.${localDate.substring(6, 8)}';
}
