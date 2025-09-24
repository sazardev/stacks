import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/time.dart';
import '../../dtos/user_dtos.dart';

/// Use case for user authentication with business logic validation
@injectable
class AuthenticateUserUseCase {
  final UserRepository _userRepository;

  AuthenticateUserUseCase(this._userRepository);

  /// Execute the user authentication use case
  Future<Either<Failure, User>> execute(AuthenticateUserDto dto) async {
    try {
      // Step 1: Validate credentials
      if (dto.email.isEmpty || dto.password.isEmpty) {
        return Left(ValidationFailure('Email and password are required'));
      }

      // Step 2: Attempt authentication
      final result = await _userRepository.authenticateUser(
        dto.email,
        dto.password,
      );

      return result.fold((failure) => Left(failure), (user) => Right(user));
    } catch (e) {
      return Left(ServerFailure('Authentication failed: ${e.toString()}'));
    }
  }
}

/// Use case for user registration with comprehensive validation
@injectable
class RegisterUserUseCase {
  final UserRepository _userRepository;

  RegisterUserUseCase(this._userRepository);

  /// Execute the user registration use case
  Future<Either<Failure, User>> execute(RegisterUserDto dto) async {
    try {
      // Step 1: Validate input data
      final validation = _validateRegistrationData(dto);
      if (validation != null) {
        return Left(ValidationFailure(validation));
      }

      // Step 2: Check if user already exists
      final existingUserResult = await _userRepository.getUserByEmail(
        dto.email,
      );
      if (existingUserResult.isRight()) {
        return Left(ValidationFailure('User with this email already exists'));
      }

      // Step 3: Create new user
      final user = User(
        id: UserId.generate(),
        email: dto.email,
        name: dto.name,
        role: dto.role,
        isActive: true,
        createdAt: Time.now(),
      );

      // Step 4: Register user
      final result = await _userRepository.createUser(user);

      return result.fold(
        (failure) => Left(failure),
        (createdUser) => Right(createdUser),
      );
    } catch (e) {
      return Left(ServerFailure('Registration failed: ${e.toString()}'));
    }
  }

  /// Validate registration data
  String? _validateRegistrationData(RegisterUserDto dto) {
    if (dto.email.isEmpty) {
      return 'Email is required';
    }

    if (!_isValidEmail(dto.email)) {
      return 'Invalid email format';
    }

    if (dto.password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (dto.name.isEmpty) {
      return 'Name is required';
    }

    return null;
  }

  /// Basic email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}
