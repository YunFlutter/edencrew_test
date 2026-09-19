import 'dart:convert';

import 'package:cp949_codec/cp949_codec.dart';
import 'package:edencrew_assignment_starter/core/error/app_exception.dart';
import 'package:edencrew_assignment_starter/data/parsers/naver_text_decoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('EUC-KR과 CP949 별칭을 디코딩한다', () {
    final bytes = cp949.encode('삼성전자');

    expect(NaverTextDecoder.decode(bytes, charset: 'EUC-KR'), '삼성전자');
    expect(NaverTextDecoder.decode(bytes, charset: 'cp949'), '삼성전자');
  });

  test('UTF-8을 디코딩한다', () {
    expect(
      NaverTextDecoder.decode(utf8.encode('코스피'), charset: 'utf-8'),
      '코스피',
    );
  });

  test('지원하지 않는 문자셋은 ParsingException으로 실패한다', () {
    expect(
      () => NaverTextDecoder.decode(const [], charset: 'shift-jis'),
      throwsA(isA<ParsingException>()),
    );
  });
}
