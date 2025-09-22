import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Failure when a resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message, {String? code})
    : super(message, code: code);
}

/// Failure when validation fails
class ValidationFailure extends Failure {
  const ValidationFailure(String message, {String? code})
    : super(message, code: code);
}

/// Failure when server returns an error
class ServerFailure extends Failure {
  const ServerFailure(String message, {String? code})
    : super(message, code: code);
}

/// Failure when there's no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure(String message, {String? code})
    : super(message, code: code);
}

/// Failure when cache operation fails
class CacheFailure extends Failure {
  const CacheFailure(String message, {String? code})
    : super(message, code: code);
}

/// Failure when permission is denied
class PermissionFailure extends Failure {
  const PermissionFailure(String message, {String? code})
    : super(message, code: code);
}

/// Failure when concurrent modification is detected
class ConcurrencyFailure extends Failure {
  const ConcurrencyFailure(String message, {String? code})
    : super(message, code: code);
}

/// Failure when business rule is violated
class BusinessRuleFailure extends Failure {
  const BusinessRuleFailure(String message, {String? code})
    : super(message, code: code);
}
