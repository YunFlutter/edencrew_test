sealed class Failure {
  const Failure(this.message, {this.cause});

  final String message;
  final Object? cause;
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.cause});
}

final class ParsingFailure extends Failure {
  const ParsingFailure(super.message, {super.cause});
}
