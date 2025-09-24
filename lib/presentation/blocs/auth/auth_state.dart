// Authentication BLoC States
// States for user authentication, registration, and session management

import '../../../domain/entities/user.dart';
import '../../core/base_state.dart';

/// Base authentication state
abstract class AuthState extends BaseState {
  const AuthState();
}

/// Initial state when BLoC is first created
class AuthInitialState extends AuthState {
  const AuthInitialState();

  @override
  bool get isInitial => true;

  @override
  List<Object?> get props => [];
}

/// Loading state during authentication operations
class AuthLoadingState extends AuthState {
  final String? message;

  const AuthLoadingState({this.message});

  @override
  bool get isLoading => true;

  @override
  List<Object?> get props => [message];
}

/// State when user is authenticated
class AuthenticatedState extends AuthState {
  final User user;
  final String? token;

  const AuthenticatedState({required this.user, this.token});

  @override
  bool get isSuccess => true;

  @override
  List<Object?> get props => [user, token];

  /// Helper getters for common role checks
  bool get isAdmin => user.role == UserRole.admin;
  bool get isKitchenManager => user.role == UserRole.kitchenManager;
  bool get isChef => [
    UserRole.chefHead,
    UserRole.sousChef,
    UserRole.cook,
    UserRole.cookSenior,
  ].contains(user.role);
  bool get isKitchenStaff => [
    UserRole.dishwasher,
    UserRole.prepCook,
    UserRole.lineCook,
    UserRole.cook,
    UserRole.cookSenior,
    UserRole.chefAssistant,
    UserRole.sousChef,
    UserRole.chefHead,
    UserRole.expediter,
    UserRole.kitchenManager,
  ].contains(user.role);

  /// Check if user has specific permission
  bool hasPermission(Permission permission) => user.hasPermission(permission);

  /// Get user authority level
  AuthorityLevel get authorityLevel => user.getAuthorityLevel();
}

/// State when user is not authenticated
class UnauthenticatedState extends AuthState {
  final String? message;

  const UnauthenticatedState({this.message});

  @override
  List<Object?> get props => [message];
}

/// State when authentication fails
class AuthErrorState extends AuthState {
  final String message;
  final String? errorCode;
  final AuthErrorType errorType;

  const AuthErrorState({
    required this.message,
    this.errorCode,
    this.errorType = AuthErrorType.unknown,
  });

  @override
  bool get hasError => true;

  @override
  List<Object?> get props => [message, errorCode, errorType];
}

/// State when user registration is successful
class RegistrationSuccessState extends AuthState {
  final String message;
  final User? user;

  const RegistrationSuccessState({required this.message, this.user});

  @override
  bool get isSuccess => true;

  @override
  List<Object?> get props => [message, user];
}

/// State when password reset email is sent
class PasswordResetSentState extends AuthState {
  final String email;
  final String message;

  const PasswordResetSentState({required this.email, required this.message});

  @override
  bool get isSuccess => true;

  @override
  List<Object?> get props => [email, message];
}

/// State when profile is updated successfully
class ProfileUpdatedState extends AuthState {
  final User updatedUser;
  final String message;

  const ProfileUpdatedState({required this.updatedUser, required this.message});

  @override
  bool get isSuccess => true;

  @override
  List<Object?> get props => [updatedUser, message];
}

/// Types of authentication errors for better error handling
enum AuthErrorType {
  invalidCredentials,
  userNotFound,
  userDisabled,
  emailAlreadyInUse,
  weakPassword,
  networkError,
  serverError,
  unknown,
}
