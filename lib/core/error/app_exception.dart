sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

final class ParsingException extends AppException {
  const ParsingException(super.message, {super.cause});
}
