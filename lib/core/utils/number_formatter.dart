String formatNumber(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();

  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[index]);
  }

  return value < 0 ? '-$buffer' : buffer.toString();
}

String formatPrice(int value) => formatNumber(value);

String formatPriceChange(int value) {
  if (value > 0) return '+${formatNumber(value)}';
  return formatNumber(value);
}

String formatChangeRate(double value, {int fractionDigits = 2}) {
  if (!value.isFinite) {
    throw ArgumentError.value(value, 'value', '유한한 숫자여야 합니다.');
  }
  if (fractionDigits < 0) {
    throw RangeError.range(fractionDigits, 0, null, 'fractionDigits');
  }

  final normalizedValue = value == 0 ? 0.0 : value;
  final sign = normalizedValue > 0 ? '+' : '';
  return '$sign${normalizedValue.toStringAsFixed(fractionDigits)}%';
}

String formatVolume(int value) => '${formatNumber(value ~/ 1000)}천';

String formatMarketCapitalization(int value) {
  const trillion = 1000000000000;
  const hundredMillion = 100000000;
  final absoluteValue = value.abs();

  if (absoluteValue >= trillion) {
    return '${formatNumber(value ~/ trillion)}조';
  }
  if (absoluteValue >= hundredMillion) {
    return '${formatNumber(value ~/ hundredMillion)}억';
  }
  return '${formatNumber(value)}원';
}
