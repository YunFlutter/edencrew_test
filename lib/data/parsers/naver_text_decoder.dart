import 'dart:convert';

import 'package:cp949_codec/cp949_codec.dart';

import '../../core/error/app_exception.dart';

abstract final class NaverTextDecoder {
  static String decode(List<int> bytes, {required String charset}) {
    final normalized = charset
        .trim()
        .toLowerCase()
        .replaceAll('_', '-')
        .replaceAll(' ', '');

    try {
      return switch (normalized) {
        'euc-kr' ||
        'cp949' ||
        'ks-c-5601-1987' => cp949.decode(bytes, allowInvalid: true),
        'utf-8' || 'utf8' => utf8.decode(bytes, allowMalformed: false),
        _ => throw ParsingException('지원하지 않는 문자 인코딩입니다: $charset'),
      };
    } on ParsingException {
      rethrow;
    } on Object catch (error) {
      throw ParsingException('$charset 응답을 디코딩하지 못했습니다.', cause: error);
    }
  }
}
