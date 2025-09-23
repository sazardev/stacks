// User Use Cases for Clean Architecture Application Layer
// Consolidated all dispersed user use cases with enhanced business logic

import 'package:dartz/dartz.dart' hide Order;
import 'package:injectable/injectable.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/time.dart';
import '../../dtos/user_dtos.dart';

/// Use case for registering a new user with enhanced validation
@injectable
class RegisterUserUseCase {
  final UserRepository _repository;

  const RegisterUserUseCase({required UserRepository repository})
    : _repository = repository;

  // Simple direct call for basic usage
  Future<Either<Failure, User>> call(RegisterUserDto dto) async {
    return execute(dto);
  }

  /// Enhanced execution with comprehensive business logic validation
  Future<Either<Failure, User>> execute(RegisterUserDto dto) async {
    try {
      // Validate input
      final validationResult = _validateRegisterInput(dto);
      if (validationResult != null) {
        return Left(validationResult);
      }

      // Check if user already exists
      final existingUserResult = await _repository.getUserByEmail(dto.email);
      if (existingUserResult.isRight()) {
        return const Left(
          ValidationFailure('User with this email already exists'),
        );
      }

      // Create new user
      final newUser = User(
        id: UserId.generate(),
        email: dto.email,
        name: dto.name,
        role: dto.role,
        createdAt: Time.now(),
      );

      return await _repository.createUser(newUser);
    } catch (e) {
      return Left(ServerFailure('Failed to register user: ${e.toString()}'));
    }
  }

  ValidationFailure? _validateRegisterInput(RegisterUserDto dto) {
    if (dto.email.trim().isEmpty) {
      return const ValidationFailure('Email cannot be empty');
    }

    if (!_isValidEmail(dto.email)) {
      return const ValidationFailure('Invalid email format');
    }

    if (dto.name.trim().isEmpty) {
      return const ValidationFailure('Name cannot be empty');
    }

    if (dto.name.length < 2) {
      return const ValidationFailure('Name must be at least 2 characters');
    }

    if (dto.name.length > 100) {
      return const ValidationFailure('Name cannot exceed 100 characters');
    }

    if (dto.password.length < 6) {
      return const ValidationFailure('Password must be at least 6 characters');
    }

    return null;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

/// Use case for authenticating a user with enhanced validation
@injectable
class AuthenticateUserUseCase {
  final UserRepository _repository;

  const AuthenticateUserUseCase({required UserRepository repository})
    : _repository = repository;

  // Simple direct call for basic usage
  Future<Either<Failure, User>> call(AuthenticateUserDto dto) async {
    return execute(dto);
  }

  /// Enhanced execution with comprehensive business logic validation
  Future<Either<Failure, User>> execute(AuthenticateUserDto dto) async {
    try {
      // Validate input
      final validationResult = _validateAuthInput(dto);
      if (validationResult != null) {
        return Left(validationResult);
      }

      return await _repository.authenticateUser(dto.email, dto.password);
    } catch (e) {
      return Left(
        ServerFailure('Failed to authenticate user: ${e.toString()}'),
      );
    }
  }

  ValidationFailure? _validateAuthInput(AuthenticateUserDto dto) {
    if (dto.email.trim().isEmpty) {
      return const ValidationFailure('Email cannot be empty');
    }

    if (!_isValidEmail(dto.email)) {
      return const ValidationFailure('Invalid email format');
    }

    if (dto.password.trim().isEmpty) {
      return const ValidationFailure('Password cannot be empty');
    }

    if (dto.password.length < 6) {
      return const ValidationFailure('Password must be at least 6 characters');
    }

    return null;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

/// Use case for getting user by ID
class GetUserByIdUseCase {
  final UserRepository _repository;

  GetUserByIdUseCase(this._repository);

  Future<Either<Failure, User>> call(UserId userId) {
    return _repository.getUserById(userId);
  }
}

/// Use case for getting user by email
class GetUserByEmailUseCase {
  final UserRepository _repository;

  GetUserByEmailUseCase(this._repository);

  Future<Either<Failure, User>> call(String email) {
    return _repository.getUserByEmail(email);
  }
}

/// Use case for getting all users
class GetAllUsersUseCase {
  final UserRepository _repository;

  GetAllUsersUseCase(this._repository);

  Future<Either<Failure, List<User>>> call() {
    return _repository.getAllUsers();
  }
}

/// Use case for getting users by role
class GetUsersByRoleUseCase {
  final UserRepository _repository;

  GetUsersByRoleUseCase(this._repository);

  Future<Either<Failure, List<User>>> call(UserRole role) {
    return _repository.getUsersByRole(role);
  }
}

/// Use case for getting active users
class GetActiveUsersUseCase {
  final UserRepository _repository;

  GetActiveUsersUseCase(this._repository);

  Future<Either<Failure, List<User>>> call() {
    return _repository.getActiveUsers();
  }
}

/// Use case for updating user
class UpdateUserUseCase {
  final UserRepository _repository;

  UpdateUserUseCase(this._repository);

  Future<Either<Failure, User>> call(User user) {
    return _repository.updateUser(user);
  }
}

/// Use case for logging out user
class LogoutUserUseCase {
  final UserRepository _repository;

  LogoutUserUseCase(this._repository);

  Future<Either<Failure, User>> call(UserId userId) {
    return _repository.logoutUser(userId);
  }
}

/// Use case for updating user role
class UpdateUserRoleUseCase {
  final UserRepository _repository;

  UpdateUserRoleUseCase(this._repository);

  Future<Either<Failure, User>> call(UserId userId, UserRole role) {
    return _repository.updateUserRole(userId, role);
  }
}

/// Use case for activating user
class ActivateUserUseCase {
  final UserRepository _repository;

  ActivateUserUseCase(this._repository);

  Future<Either<Failure, User>> call(UserId userId) {
    return _repository.activateUser(userId);
  }
}

/// Use case for deactivating user
class DeactivateUserUseCase {
  final UserRepository _repository;

  DeactivateUserUseCase(this._repository);

  Future<Either<Failure, User>> call(UserId userId) {
    return _repository.deactivateUser(userId);
  }
}

/// Use case for checking user permissions
class HasPermissionUseCase {
  final UserRepository _repository;

  HasPermissionUseCase(this._repository);

  Future<Either<Failure, bool>> call(UserId userId, Permission permission) {
    return _repository.hasPermission(userId, permission);
  }
}

/// Use case for getting user permissions
class GetUserPermissionsUseCase {
  final UserRepository _repository;

  GetUserPermissionsUseCase(this._repository);

  Future<Either<Failure, List<Permission>>> call(UserId userId) {
    return _repository.getUserPermissions(userId);
  }
}

/// Use case for updating user session
class UpdateUserSessionUseCase {
  final UserRepository _repository;

  UpdateUserSessionUseCase(this._repository);

  Future<Either<Failure, User>> call(
    UserId userId,
    String sessionId,
    Time loginTime,
  ) {
    return _repository.updateUserSession(userId, sessionId, loginTime);
  }
}

/// Use case for validating user session
class IsSessionValidUseCase {
  final UserRepository _repository;

  IsSessionValidUseCase(this._repository);

  Future<Either<Failure, bool>> call(UserId userId, String sessionId) {
    return _repository.isSessionValid(userId, sessionId);
  }
}

/// Use case for deleting user
class DeleteUserUseCase {
  final UserRepository _repository;

  DeleteUserUseCase(this._repository);

  Future<Either<Failure, Unit>> call(UserId userId) {
    return _repository.deleteUser(userId);
  }
}
