import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../application/use_cases/user/user_use_cases.dart'
    hide AuthenticateUserUseCase, RegisterUserUseCase;
import '../../../application/use_cases/user/authenticate_user_use_case.dart';
import '../../../application/dtos/user_dtos.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC handling user authentication flows
/// Simplified implementation using direct emit() calls for better control
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthenticateUserUseCase _authenticateUserUseCase;
  final RegisterUserUseCase _registerUserUseCase;
  final LogoutUserUseCase _logoutUserUseCase;
  final IsSessionValidUseCase _isSessionValidUseCase;
  final UpdateUserUseCase _updateUserUseCase;

  AuthBloc({
    required AuthenticateUserUseCase authenticateUserUseCase,
    required RegisterUserUseCase registerUserUseCase,
    required LogoutUserUseCase logoutUserUseCase,
    required IsSessionValidUseCase isSessionValidUseCase,
    required UpdateUserUseCase updateUserUseCase,
  }) : _authenticateUserUseCase = authenticateUserUseCase,
       _registerUserUseCase = registerUserUseCase,
       _logoutUserUseCase = logoutUserUseCase,
       _isSessionValidUseCase = isSessionValidUseCase,
       _updateUserUseCase = updateUserUseCase,
       super(const AuthInitialState()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<RefreshTokenEvent>(_onRefreshToken);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  /// Handle login event
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(const AuthLoadingState(message: 'Signing in...'));

      final result = await _authenticateUserUseCase.execute(
        AuthenticateUserDto(email: event.email, password: event.password),
      );

      result.fold(
        (failure) => emit(
          AuthErrorState(
            message: _getErrorMessage(failure.message),
            errorType: _getErrorType(failure),
          ),
        ),
        (user) => emit(AuthenticatedState(user: user)),
      );
    } catch (error) {
      emit(
        AuthErrorState(
          message: 'An unexpected error occurred during login',
          errorType: AuthErrorType.unknown,
        ),
      );
    }
  }

  /// Handle register event
  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    try {
      emit(const AuthLoadingState(message: 'Creating account...'));

      // Parse role string to UserRole enum
      final userRole = _parseUserRole(event.role);
      if (userRole == null) {
        emit(
          const AuthErrorState(
            message: 'Invalid user role specified',
            errorType: AuthErrorType.unknown,
          ),
        );
        return;
      }

      final result = await _registerUserUseCase.execute(
        RegisterUserDto(
          email: event.email,
          password: event.password,
          name: event.name,
          role: userRole,
        ),
      );

      result.fold(
        (failure) => emit(
          AuthErrorState(
            message: _getErrorMessage(failure.message),
            errorType: _getErrorType(failure),
          ),
        ),
        (user) => emit(
          RegistrationSuccessState(
            message: 'Account created successfully!',
            user: user,
          ),
        ),
      );
    } catch (error) {
      emit(
        AuthErrorState(
          message: 'An unexpected error occurred during registration',
          errorType: AuthErrorType.unknown,
        ),
      );
    }
  }

  /// Handle logout event
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(const AuthLoadingState(message: 'Signing out...'));

      final currentState = state;
      if (currentState is! AuthenticatedState) {
        emit(const UnauthenticatedState(message: 'Not currently signed in'));
        return;
      }

      final result = await _logoutUserUseCase.call(currentState.user.id);

      result.fold(
        (failure) => emit(
          AuthErrorState(
            message: 'Failed to sign out: ${failure.message}',
            errorType: AuthErrorType.serverError,
          ),
        ),
        (_) => emit(
          const UnauthenticatedState(message: 'Signed out successfully'),
        ),
      );
    } catch (error) {
      // Even if logout fails, we should clear the local state
      emit(const UnauthenticatedState(message: 'Signed out locally'));
    }
  }

  /// Handle check auth status event
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! AuthenticatedState) {
        emit(const UnauthenticatedState());
        return;
      }

      // Verify session is still valid
      if (currentState.user.sessionId != null) {
        final sessionValid = await _isSessionValidUseCase.call(
          currentState.user.id,
          currentState.user.sessionId!,
        );

        sessionValid.fold(
          (failure) =>
              emit(const UnauthenticatedState(message: 'Session expired')),
          (isValid) {
            if (isValid) {
              emit(currentState);
            } else {
              emit(const UnauthenticatedState(message: 'Session expired'));
            }
          },
        );
      } else {
        emit(const UnauthenticatedState(message: 'No active session'));
      }
    } catch (error) {
      emit(const UnauthenticatedState(message: 'Failed to verify session'));
    }
  }

  /// Handle refresh token event
  Future<void> _onRefreshToken(
    RefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! AuthenticatedState) {
        emit(const UnauthenticatedState(message: 'Not authenticated'));
        return;
      }

      // In a real implementation, this would refresh the token
      // For now, we'll just return the current state if session is valid
      emit(currentState);
    } catch (error) {
      emit(const UnauthenticatedState(message: 'Token refresh failed'));
    }
  }

  /// Handle update profile event
  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! AuthenticatedState) {
        emit(
          const AuthErrorState(
            message: 'You must be signed in to update your profile',
            errorType: AuthErrorType.userNotFound,
          ),
        );
        return;
      }

      emit(const AuthLoadingState(message: 'Updating profile...'));

      // Create updated user - since User doesn't have copyWith, we need to create a new instance
      final updatedUser = User(
        id: currentState.user.id,
        email: event.email ?? currentState.user.email,
        name: event.name ?? currentState.user.name,
        role: currentState.user.role,
        createdAt: currentState.user.createdAt,
        isActive: currentState.user.isActive,
        isAuthenticated: currentState.user.isAuthenticated,
        sessionId: currentState.user.sessionId,
        lastLoginAt: currentState.user.lastLoginAt,
      );

      final result = await _updateUserUseCase.call(updatedUser);

      result.fold(
        (failure) => emit(
          AuthErrorState(
            message: _getErrorMessage(failure.message),
            errorType: _getErrorType(failure),
          ),
        ),
        (user) => emit(
          ProfileUpdatedState(
            updatedUser: user,
            message: 'Profile updated successfully',
          ),
        ),
      );
    } catch (error) {
      emit(
        AuthErrorState(
          message: 'An unexpected error occurred while updating profile',
          errorType: AuthErrorType.unknown,
        ),
      );
    }
  }

  /// Helper methods

  /// Parse string role to UserRole enum
  UserRole? _parseUserRole(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'dishwasher':
        return UserRole.dishwasher;
      case 'prep_cook':
      case 'prepcook':
        return UserRole.prepCook;
      case 'line_cook':
      case 'linecook':
        return UserRole.lineCook;
      case 'cook':
        return UserRole.cook;
      case 'cook_senior':
      case 'cooksenior':
      case 'senior_cook':
        return UserRole.cookSenior;
      case 'chef_assistant':
      case 'chefassistant':
        return UserRole.chefAssistant;
      case 'sous_chef':
      case 'souschef':
        return UserRole.sousChef;
      case 'chef_head':
      case 'headchef':
      case 'head_chef':
        return UserRole.chefHead;
      case 'expediter':
        return UserRole.expediter;
      case 'kitchen_manager':
      case 'kitchenmanager':
        return UserRole.kitchenManager;
      case 'general_manager':
      case 'generalmanager':
        return UserRole.generalManager;
      case 'admin':
        return UserRole.admin;
      default:
        return null;
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(String originalMessage) {
    if (originalMessage.toLowerCase().contains('email')) {
      if (originalMessage.toLowerCase().contains('invalid')) {
        return 'Please enter a valid email address';
      } else if (originalMessage.toLowerCase().contains('exists')) {
        return 'An account with this email already exists';
      }
    }

    if (originalMessage.toLowerCase().contains('password')) {
      if (originalMessage.toLowerCase().contains('weak') ||
          originalMessage.toLowerCase().contains('short') ||
          originalMessage.toLowerCase().contains('characters')) {
        return 'Password must be at least 6 characters long';
      } else if (originalMessage.toLowerCase().contains('incorrect') ||
          originalMessage.toLowerCase().contains('invalid')) {
        return 'Incorrect email or password';
      }
    }

    if (originalMessage.toLowerCase().contains('network') ||
        originalMessage.toLowerCase().contains('connection')) {
      return 'Please check your internet connection and try again';
    }

    // Return original message if no specific mapping found
    return originalMessage;
  }

  /// Map failure to error type
  AuthErrorType _getErrorType(dynamic failure) {
    final message = failure.message.toLowerCase();

    if (message.contains('invalid') && message.contains('credentials')) {
      return AuthErrorType.invalidCredentials;
    } else if (message.contains('user') && message.contains('not found')) {
      return AuthErrorType.userNotFound;
    } else if (message.contains('disabled')) {
      return AuthErrorType.userDisabled;
    } else if (message.contains('email') && message.contains('use')) {
      return AuthErrorType.emailAlreadyInUse;
    } else if (message.contains('weak') || message.contains('password')) {
      return AuthErrorType.weakPassword;
    } else if (message.contains('network')) {
      return AuthErrorType.networkError;
    } else if (message.contains('server')) {
      return AuthErrorType.serverError;
    } else {
      return AuthErrorType.unknown;
    }
  }

  /// Convenience getters and methods

  /// Check if user is currently authenticated
  bool get isAuthenticated => state is AuthenticatedState;

  /// Get current user if authenticated
  User? get currentUser =>
      state is AuthenticatedState ? (state as AuthenticatedState).user : null;

  /// Check if current user has specific permission
  bool hasPermission(Permission permission) {
    final user = currentUser;
    return user?.hasPermission(permission) ?? false;
  }

  /// Check if current user has specific role
  bool hasRole(UserRole role) {
    final user = currentUser;
    return user?.role == role;
  }

  /// Check if current user is admin
  bool get isAdmin {
    final authenticatedState = state;
    return authenticatedState is AuthenticatedState &&
        authenticatedState.isAdmin;
  }

  /// Check if current user is kitchen manager or higher
  bool get isKitchenManager {
    final authenticatedState = state;
    return authenticatedState is AuthenticatedState &&
        authenticatedState.isKitchenManager;
  }

  /// Check if current user is chef (any level)
  bool get isChef {
    final authenticatedState = state;
    return authenticatedState is AuthenticatedState &&
        authenticatedState.isChef;
  }
}
