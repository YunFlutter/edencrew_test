import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../../core/error/app_exception.dart';
import '../dto/daily_price_dto.dart';
import 'naver_text_decoder.dart';

abstract final class NaverDailyPriceParser {
  static DailyPricePageDto parseBytes(List<int> bytes) {
    if (bytes.isEmpty) {
      throw const ParsingException('일별 시세 응답이 비어 있습니다.');
    }

    try {
      return parseHtml(_decodeHtml(bytes));
    } on ParsingException {
      rethrow;
    } on Object catch (error) {
      throw ParsingException('일별 시세 응답을 파싱하지 못했습니다.', cause: error);
    }
  }

  static DailyPricePageDto parseHtml(String html) {
    final document = html_parser.parse(html);
    final items = <DailyPriceDto>[];

    for (final row in document.querySelectorAll('tr[onmouseover]')) {
      final cells = row.querySelectorAll('td');
      if (cells.length != 7) continue;
      items.add(_parseRow(cells, items.length));
    }

    if (items.isEmpty) {
      throw const ParsingException('일별 시세 응답에 유효한 거래일 행이 없습니다.');
    }

    return DailyPricePageDto(
      items: List.unmodifiable(items),
      lastPage: _parseLastPage(document),
    );
  }

  static String _decodeHtml(List<int> bytes) {
    final headerLength = bytes.length < 1024 ? bytes.length : 1024;
    final asciiHeader = latin1.decode(bytes.sublist(0, headerLength));
    final charsetMatch = RegExp(
      r'''charset\s*=\s*["']?([^\s"'>;]+)''',
      caseSensitive: false,
    ).firstMatch(asciiHeader);
    final charset = charsetMatch?.group(1)?.toLowerCase();

    return NaverTextDecoder.decode(bytes, charset: charset ?? 'utf-8');
  }

  static DailyPriceDto _parseRow(List<Element> cells, int index) {
    final rawDate = cells[0].text.trim();
    final dateMatch = RegExp(
      r'^(\d{4})\.(\d{2})\.(\d{2})$',
    ).firstMatch(rawDate);
    if (dateMatch == null) {
      throw ParsingException('일별 시세 $index번째 행의 날짜 형식이 올바르지 않습니다.');
    }
    final year = int.parse(dateMatch.group(1)!);
    final month = int.parse(dateMatch.group(2)!);
    final day = int.parse(dateMatch.group(3)!);
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      throw ParsingException('일별 시세 $index번째 행의 날짜가 유효하지 않습니다.');
    }

    return DailyPriceDto(
      localDate: '$year${_twoDigits(month)}${_twoDigits(day)}',
      closePrice: _parseNumber(cells[1].text, index, '종가'),
      openPrice: _parseNumber(cells[3].text, index, '시가'),
      highPrice: _parseNumber(cells[4].text, index, '고가'),
      lowPrice: _parseNumber(cells[5].text, index, '저가'),
      accumulatedTradingVolume: _parseNumber(cells[6].text, index, '거래량'),
    );
  }

  static int _parseNumber(String raw, int rowIndex, String field) {
    final normalized = raw.replaceAll(',', '').replaceAll(RegExp(r'\s'), '');
    final value = int.tryParse(normalized);
    if (value == null || value < 0) {
      throw ParsingException('일별 시세 $rowIndex번째 행의 $field 값이 올바른 정수가 아닙니다.');
    }
    return value;
  }

  static int _parseLastPage(Document document) {
    final lastPageLink = document.querySelector('td.pgRR a');
    final lastPage = _pageFromLink(lastPageLink);
    if (lastPage != null) return lastPage;

    final pages = document
        .querySelectorAll('table.Nnavi a')
        .map(_pageFromLink)
        .whereType<int>()
        .toList();
    if (pages.isEmpty) {
      throw const ParsingException('일별 시세 응답에서 마지막 페이지를 찾지 못했습니다.');
    }
    return pages.reduce((left, right) => left > right ? left : right);
  }

  static int? _pageFromLink(Element? link) {
    final href = link?.attributes['href'];
    if (href == null) return null;
    final uri = Uri.tryParse(href.replaceAll('&amp;', '&'));
    final page = int.tryParse(uri?.queryParameters['page'] ?? '');
    return page != null && page > 0 ? page : null;
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
