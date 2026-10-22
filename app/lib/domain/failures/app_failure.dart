/// Every error the data layer may throw. Screens handle only these.
sealed class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NotSignedIn extends AppFailure {
  const NotSignedIn() : super('You are not signed in.');
}

final class PermissionDenied extends AppFailure {
  const PermissionDenied() : super('You do not have permission to do this.');
}

final class NotFound extends AppFailure {
  const NotFound(super.message);
}

final class AlreadyExists extends AppFailure {
  const AlreadyExists(super.message);
}

final class InvalidData extends AppFailure {
  const InvalidData(super.message);
}

final class Offline extends AppFailure {
  const Offline() : super('No internet connection.');
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'Something went wrong.']);
}
