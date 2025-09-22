import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';

/// DTO for user authentication
class AuthenticateUserDto extends Equatable {
  final String email;
  final String password;

  const AuthenticateUserDto({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// DTO for user registration
class RegisterUserDto extends Equatable {
  final String email;
  final String name;
  final UserRole role;
  final String password;

  const RegisterUserDto({
    required this.email,
    required this.name,
    required this.role,
    required this.password,
  });

  @override
  List<Object?> get props => [email, name, role, password];
}

/// DTO for managing user roles
class ManageUserRoleDto extends Equatable {
  final UserId userId;
  final UserRole newRole;
  final String? reason;

  const ManageUserRoleDto({
    required this.userId,
    required this.newRole,
    this.reason,
  });

  @override
  List<Object?> get props => [userId, newRole, reason];
}

/// DTO for user session update
class UpdateUserSessionDto extends Equatable {
  final UserId userId;
  final String sessionId;
  final Time loginTime;

  const UpdateUserSessionDto({
    required this.userId,
    required this.sessionId,
    required this.loginTime,
  });

  @override
  List<Object?> get props => [userId, sessionId, loginTime];
}

/// DTO for user queries
class UserQueryDto extends Equatable {
  final UserRole? role;
  final bool? isActive;
  final bool? isAuthenticated;
  final String? email;
  final int? limit;
  final int? offset;

  const UserQueryDto({
    this.role,
    this.isActive,
    this.isAuthenticated,
    this.email,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [
    role,
    isActive,
    isAuthenticated,
    email,
    limit,
    offset,
  ];
}
