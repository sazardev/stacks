import 'package:dartz/dartz.dart' show Either, Unit;
import '../entities/user.dart';
import '../value_objects/user_id.dart';
import '../value_objects/time.dart';
import '../failures/failures.dart';

/// Repository interface for User operations
abstract class UserRepository {
  /// Creates a new user
  Future<Either<Failure, User>> createUser(User user);

  /// Gets a user by their ID
  Future<Either<Failure, User>> getUserById(UserId userId);

  /// Gets a user by email
  Future<Either<Failure, User>> getUserByEmail(String email);

  /// Gets all users
  Future<Either<Failure, List<User>>> getAllUsers();

  /// Gets users by role
  Future<Either<Failure, List<User>>> getUsersByRole(UserRole role);

  /// Gets active users
  Future<Either<Failure, List<User>>> getActiveUsers();

  /// Updates a user
  Future<Either<Failure, User>> updateUser(User user);

  /// Authenticates a user
  Future<Either<Failure, User>> authenticateUser(String email, String password);

  /// Logs out a user
  Future<Either<Failure, User>> logoutUser(UserId userId);

  /// Updates user role
  Future<Either<Failure, User>> updateUserRole(UserId userId, UserRole role);

  /// Activates a user
  Future<Either<Failure, User>> activateUser(UserId userId);

  /// Deactivates a user
  Future<Either<Failure, User>> deactivateUser(UserId userId);

  /// Checks if user has permission
  Future<Either<Failure, bool>> hasPermission(
    UserId userId,
    Permission permission,
  );

  /// Gets user permissions
  Future<Either<Failure, List<Permission>>> getUserPermissions(UserId userId);

  /// Updates user session
  Future<Either<Failure, User>> updateUserSession(
    UserId userId,
    String sessionId,
    Time loginTime,
  );

  /// Checks if user session is valid
  Future<Either<Failure, bool>> isSessionValid(UserId userId, String sessionId);

  /// Deletes a user
  Future<Either<Failure, Unit>> deleteUser(UserId userId);

  /// Watches real-time user updates
  Stream<Either<Failure, List<User>>> watchUsers();

  /// Watches specific user updates
  Stream<Either<Failure, User>> watchUser(UserId userId);
}
