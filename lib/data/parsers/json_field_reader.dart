import '../../core/error/app_exception.dart';

abstract final class JsonFieldReader {
  static Map<String, Object?> map(Object? value, String path) {
    if (value is! Map) {
      throw ParsingException('$path 값이 객체가 아닙니다.');
    }
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  static List<Object?> list(Object? value, String path) {
    if (value is! List) {
      throw ParsingException('$path 값이 배열이 아닙니다.');
    }
    return value.cast<Object?>();
  }

  static String string(Map<String, Object?> json, String key, String path) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw ParsingException('$path.$key 값이 비어 있거나 문자열이 아닙니다.');
    }
    return value.trim();
  }

  static int integer(Map<String, Object?> json, String key, String path) {
    final value = json[key];
    if (value is int) return value;
    if (value is num && value.isFinite && value == value.roundToDouble()) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = int.tryParse(value.replaceAll(',', '').trim());
      if (parsed != null) return parsed;
    }
    throw ParsingException('$path.$key 값이 정수가 아닙니다.');
  }
}
