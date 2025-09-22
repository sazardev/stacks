import 'package:dartz/dartz.dart' show Either, Left;
import 'package:injectable/injectable.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/failures/failures.dart';
import '../dtos/user_dtos.dart';

/// Use case for authenticating a user
@injectable
class AuthenticateUserUseCase {
  final UserRepository _userRepository;

  const AuthenticateUserUseCase({required UserRepository userRepository})
    : _userRepository = userRepository;

  /// Executes the authenticate user use case
  Future<Either<Failure, User>> execute(AuthenticateUserDto dto) async {
    try {
      // Validate input
      final validationResult = _validateInput(dto);
      if (validationResult != null) {
        return Left(validationResult);
      }

      // Authenticate user
      return await _userRepository.authenticateUser(dto.email, dto.password);
    } catch (e) {
      return Left(
        ServerFailure('Failed to authenticate user: ${e.toString()}'),
      );
    }
  }

  /// Validates the input DTO
  ValidationFailure? _validateInput(AuthenticateUserDto dto) {
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

  /// Simple email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}
