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
  const NotFoundFailure(super.message, {super.code});
}

/// Failure when validation fails
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

/// Failure when server returns an error
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Failure when there's no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Failure when cache operation fails
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Failure when permission is denied
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});
}

/// Failure when concurrent modification is detected
class ConcurrencyFailure extends Failure {
  const ConcurrencyFailure(super.message, {super.code});
}

/// Failure when business rule is violated
class BusinessRuleFailure extends Failure {
  const BusinessRuleFailure(super.message, {super.code});
}
