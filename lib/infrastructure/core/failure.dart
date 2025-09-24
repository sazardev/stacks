// Core Failure class for Clean Architecture error handling
// Represents application failures with descriptive messages

import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;

  const Failure(this.message, {this.code, this.details});

  @override
  List<Object?> get props => [message, code, details];

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

// Specific failure types for better error handling
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.details});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.details});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.details});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.details});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code, super.details});
}
