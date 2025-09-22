import 'package:dartz/dartz.dart' show Either, Left;
import 'package:injectable/injectable.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/failures/failures.dart';
import '../dtos/user_dtos.dart';

/// Use case for registering a new user
@injectable
class RegisterUserUseCase {
  final UserRepository _userRepository;

  const RegisterUserUseCase({required UserRepository userRepository})
    : _userRepository = userRepository;

  /// Executes the register user use case
  Future<Either<Failure, User>> execute(RegisterUserDto dto) async {
    try {
      // Validate input
      final validationResult = _validateInput(dto);
      if (validationResult != null) {
        return Left(validationResult);
      }

      // Check if user already exists
      final existingUserResult = await _userRepository.getUserByEmail(
        dto.email,
      );
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

      // Save user (password handling would be done in infrastructure layer)
      return await _userRepository.createUser(newUser);
    } catch (e) {
      return Left(ServerFailure('Failed to register user: ${e.toString()}'));
    }
  }

  /// Validates the input DTO
  ValidationFailure? _validateInput(RegisterUserDto dto) {
    if (dto.email.trim().isEmpty) {
      return const ValidationFailure('Email cannot be empty');
    }

    if (!_isValidEmail(dto.email)) {
      return const ValidationFailure('Invalid email format');
    }

    if (dto.name.trim().isEmpty) {
      return const ValidationFailure('Name cannot be empty');
    }

    if (dto.name.length > 100) {
      return const ValidationFailure('Name cannot exceed 100 characters');
    }

    if (dto.password.trim().isEmpty) {
      return const ValidationFailure('Password cannot be empty');
    }

    if (dto.password.length < 6) {
      return const ValidationFailure('Password must be at least 6 characters');
    }

    if (dto.password.length > 128) {
      return const ValidationFailure('Password cannot exceed 128 characters');
    }

    return null;
  }

  /// Simple email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}
