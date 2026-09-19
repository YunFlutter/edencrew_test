import 'package:edencrew_assignment_starter/core/utils/number_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('숫자와 가격', () {
    test('천 단위 쉼표와 음수 부호를 표시한다', () {
      expect(formatNumber(0), '0');
      expect(formatNumber(999), '999');
      expect(formatNumber(1000), '1,000');
      expect(formatPrice(-1234567), '-1,234,567');
    });
  });

  group('등락', () {
    test('상승에만 더하기 부호를 붙이고 보합은 0으로 표시한다', () {
      expect(formatPriceChange(7500), '+7,500');
      expect(formatPriceChange(-400), '-400');
      expect(formatPriceChange(0), '0');

      expect(formatChangeRate(2.970297), '+2.97%');
      expect(formatChangeRate(-0.22), '-0.22%');
      expect(formatChangeRate(-0.0), '0.00%');
    });

    test('유한하지 않은 등락률과 잘못된 소수 자릿수를 거부한다', () {
      expect(() => formatChangeRate(double.nan), throwsArgumentError);
      expect(() => formatChangeRate(1, fractionDigits: -1), throwsRangeError);
    });
  });

  group('축약 단위', () {
    test('거래량은 천 단위로 절삭한다', () {
      expect(formatVolume(29113999), '29,113천');
      expect(formatVolume(999), '0천');
      expect(formatVolume(-1234567), '-1,234천');
    });

    test('시가총액은 크기에 따라 조, 억, 원 단위로 절삭한다', () {
      expect(formatMarketCapitalization(1063999999999999), '1,063조');
      expect(formatMarketCapitalization(999999999999), '9,999억');
      expect(formatMarketCapitalization(99999999), '99,999,999원');
      expect(formatMarketCapitalization(0), '0원');
      expect(formatMarketCapitalization(-123456789), '-1억');
    });
  });
}
