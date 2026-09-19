import 'dart:convert';
import 'dart:io';

import 'package:cp949_codec/cp949_codec.dart';
import 'package:edencrew_assignment_starter/core/error/app_exception.dart';
import 'package:edencrew_assignment_starter/data/parsers/naver_daily_price_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('EUC-KR 실제 HTML에서 10거래일과 마지막 페이지를 파싱한다', () async {
    final bytes = await File(
      'assets/mock/daily_prices_005930_page_1_20240424.html',
    ).readAsBytes();

    final page = NaverDailyPriceParser.parseBytes(bytes);

    expect(page.items, hasLength(10));
    expect(page.lastPage, 698);
    expect(page.items.first.localDate, '20240424');
    expect(page.items.first.closePrice, 78600);
    expect(page.items.first.openPrice, 77500);
    expect(page.items.first.highPrice, 78800);
    expect(page.items.first.lowPrice, 77200);
    expect(page.items.first.accumulatedTradingVolume, 21804564);
  });

  test('UTF-8 HTML도 선언된 인코딩에 따라 파싱한다', () {
    final utf8Bytes = utf8.encode(_singleRowHtml());

    final page = NaverDailyPriceParser.parseBytes(utf8Bytes);

    expect(page.items.single.localDate, '20240919');
    expect(page.lastPage, 1);
  });

  test('잘못된 숫자는 ParsingException으로 반환한다', () {
    final html = _singleRowHtml(closePrice: '가격 없음');

    expect(
      () => NaverDailyPriceParser.parseHtml(html),
      throwsA(
        isA<ParsingException>().having(
          (error) => error.message,
          'message',
          contains('종가'),
        ),
      ),
    );
  });

  test('지원하지 않는 문자 인코딩은 명시적으로 실패한다', () {
    final bytes = '<meta charset="shift-jis">'.codeUnits;

    expect(
      () => NaverDailyPriceParser.parseBytes(bytes),
      throwsA(
        isA<ParsingException>().having(
          (error) => error.message,
          'message',
          contains('shift-jis'),
        ),
      ),
    );
  });

  test('CP949 디코딩 후 한글 문자가 보존된다', () {
    final bytes = cp949.encode(
      '<meta charset="euc-kr"><p>상승</p>${_singleRowHtml(includeMeta: false)}',
    );

    final page = NaverDailyPriceParser.parseBytes(bytes);

    expect(page.items, hasLength(1));
  });
}

String _singleRowHtml({
  String closePrice = '78,600',
  bool includeMeta = true,
}) =>
    '''
    ${includeMeta ? '<meta charset="utf-8">' : ''}
    <table>
      <tr onmouseover="mouseOver(this)">
        <td>2024.09.19</td>
        <td>$closePrice</td>
        <td>100</td>
        <td>78,000</td>
        <td>79,000</td>
        <td>77,500</td>
        <td>1,234,567</td>
      </tr>
    </table>
    <table class="Nnavi"><tr><td><a href="?page=1">1</a></td></tr></table>
    ''';
