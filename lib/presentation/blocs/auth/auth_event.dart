// Authentication BLoC Events
// Events for user authentication, registration, and session management

import '../../core/base_event.dart';

/// Base authentication event
abstract class AuthEvent extends BaseEvent {
  const AuthEvent();
}

/// Event to login with email and password
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Event to register a new user
class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String role;

  const RegisterEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, name, role];
}

/// Event to logout current user
class LogoutEvent extends AuthEvent {
  const LogoutEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check authentication status
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();

  @override
  List<Object?> get props => [];
}

/// Event to refresh authentication token
class RefreshTokenEvent extends AuthEvent {
  const RefreshTokenEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request password reset
class RequestPasswordResetEvent extends AuthEvent {
  final String email;

  const RequestPasswordResetEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Event to update user profile
class UpdateProfileEvent extends AuthEvent {
  final String? name;
  final String? email;
  final Map<String, dynamic>? additionalData;

  const UpdateProfileEvent({this.name, this.email, this.additionalData});

  @override
  List<Object?> get props => [name, email, additionalData];
}

/// Event to change user role (admin only)
class ChangeUserRoleEvent extends AuthEvent {
  final String userId;
  final String newRole;

  const ChangeUserRoleEvent({required this.userId, required this.newRole});

  @override
  List<Object?> get props => [userId, newRole];
}
