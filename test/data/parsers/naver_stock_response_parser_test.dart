import 'dart:convert';
import 'dart:io';

import 'package:edencrew_assignment_starter/core/error/app_exception.dart';
import 'package:edencrew_assignment_starter/data/parsers/naver_stock_response_parser.dart';
import 'package:edencrew_assignment_starter/data/parsers/naver_text_decoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('검색 응답', () {
    test('mock의 검색 항목을 DTO로 파싱한다', () async {
      final json = await _readJson(
        'assets/mock/search_autocomplete_samsung.json',
      );

      final items = NaverStockResponseParser.parseSearch(json);

      expect(items, hasLength(10));
      expect(items.first.symbol, '005930');
      expect(items.first.name, '삼성전자');
      expect(items.first.market, '코스피');
      expect(items.first.nationCode, 'KOR');
      expect(items.first.category, 'stock');
    });

    test('필수 필드가 누락되면 경로가 포함된 ParsingException을 던진다', () {
      final response = {
        'items': [
          {
            'code': '005930',
            'name': '삼성전자',
            'typeName': '코스피',
            'nationCode': 'KOR',
          },
        ],
      };

      expect(
        () => NaverStockResponseParser.parseSearch(response),
        throwsA(
          isA<ParsingException>().having(
            (error) => error.message,
            'message',
            contains(r'$.items[0].category'),
          ),
        ),
      );
    });
  });

  group('실시간 시세 응답', () {
    test('배치 시세를 DTO 목록으로 파싱한다', () async {
      final json = await _readJson(
        'assets/mock/realtime_quotes_005930_000660.json',
        charset: 'euc-kr',
      );

      final quotes = NaverStockResponseParser.parseQuotes(json);

      expect(quotes, hasLength(2));
      expect(quotes.first.symbol, '005930');
      expect(quotes.first.currentPrice, 260000);
      expect(quotes.first.previousClose, 252500);
      expect(quotes.first.accumulatedTradingVolume, 15042569);
      expect(quotes.first.countOfListedStock, 5846278608);
    });

    test('숫자가 잘못되면 해당 필드 경로로 실패한다', () {
      final response = {
        'resultCode': 'success',
        'result': {
          'areas': [
            {
              'name': 'SERVICE_ITEM',
              'datas': [
                {
                  'cd': '005930',
                  'nv': '잘못된 숫자',
                  'pcv': 1,
                  'ov': 1,
                  'hv': 1,
                  'lv': 1,
                  'aq': 1,
                  'countOfListedStock': 1,
                },
              ],
            },
          ],
        },
      };

      expect(
        () => NaverStockResponseParser.parseQuotes(response),
        throwsA(
          isA<ParsingException>().having(
            (error) => error.message,
            'message',
            contains('.nv'),
          ),
        ),
      );
    });
  });

  test('메타데이터 응답을 DTO로 파싱한다', () async {
    final json = await _readJson('assets/mock/stock_metadata_005930.json');

    final metadata = NaverStockResponseParser.parseMetadata(json);

    expect(metadata.symbol, '005930');
    expect(metadata.name, '삼성전자');
    expect(metadata.market, '코스피');
  });
}

Future<Object?> _readJson(String path, {String charset = 'utf-8'}) async {
  final bytes = await File(path).readAsBytes();
  final source = NaverTextDecoder.decode(bytes, charset: charset);
  return jsonDecode(source);
}
