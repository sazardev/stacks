// User Repository Implementation for Clean Architecture Infrastructure Layer
// Simplified mock implementation with authentication support

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/failures/failures.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';
import '../mappers/user_mapper.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final UserMapper _userMapper;

  // In-memory storage for development
  final Map<String, Map<String, dynamic>> _users = {};
  final Map<String, String> _emailToUserId = {}; // email -> userId mapping
  final Map<String, Set<Permission>> _userPermissions =
      {}; // userId -> permissions
  final Map<String, String> _userSessions = {}; // userId -> sessionId

  UserRepositoryImpl({required UserMapper userMapper})
    : _userMapper = userMapper;

  @override
  Future<Either<Failure, User>> createUser(User user) async {
    try {
      // Check if email already exists
      if (_emailToUserId.containsKey(user.email)) {
        return Left(ValidationFailure('Email already exists: ${user.email}'));
      }

      final userData = _userMapper.toFirestore(user);
      _users[user.id.value] = userData;
      _emailToUserId[user.email] = user.id.value;

      // Set default permissions based on role
      _userPermissions[user.id.value] = _getDefaultPermissionsForRole(
        user.role,
      );

      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserById(UserId userId) async {
    try {
      final userData = _users[userId.value];
      if (userData == null) {
        return Left(NotFoundFailure('User not found: ${userId.value}'));
      }

      final user = _userMapper.fromFirestore(userData, userId.value);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserByEmail(String email) async {
    try {
      final userId = _emailToUserId[email];
      if (userId == null) {
        return Left(NotFoundFailure('User not found with email: $email'));
      }

      final userData = _users[userId];
      if (userData == null) {
        return Left(NotFoundFailure('User data not found for email: $email'));
      }

      final user = _userMapper.fromFirestore(userData, userId);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getAllUsers() async {
    try {
      final users = _users.entries
          .map((entry) => _userMapper.fromFirestore(entry.value, entry.key))
          .toList();
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getUsersByRole(UserRole role) async {
    try {
      final roleString = _getRoleString(role);
      final users = _users.values
          .where((userData) => userData['role'] == roleString)
          .map(
            (userData) =>
                _userMapper.fromFirestore(userData, userData['id'] as String),
          )
          .toList();
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getActiveUsers() async {
    try {
      final users = _users.values
          .where((userData) => userData['isActive'] as bool? ?? true)
          .map(
            (userData) =>
                _userMapper.fromFirestore(userData, userData['id'] as String),
          )
          .toList();
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUser(User user) async {
    try {
      if (!_users.containsKey(user.id.value)) {
        return Left(NotFoundFailure('User not found: ${user.id.value}'));
      }

      final userData = _userMapper.toFirestore(user);
      _users[user.id.value] = userData;

      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> authenticateUser(
    String email,
    String password,
  ) async {
    try {
      // In a real implementation, this would verify the password hash
      final userResult = await getUserByEmail(email);
      return userResult.fold((failure) => Left(failure), (user) {
        // For this mock implementation, we'll assume authentication succeeds
        // if the user exists and is active
        if (!user.isActive) {
          return Left(ValidationFailure('User account is inactive'));
        }

        // Update session and login time
        final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
        _userSessions[user.id.value] = sessionId;

        final userData = _users[user.id.value]!;
        userData['isAuthenticated'] = true;
        userData['sessionId'] = sessionId;
        userData['lastLoginAt'] = DateTime.now().millisecondsSinceEpoch;

        final authenticatedUser = _userMapper.fromFirestore(
          userData,
          user.id.value,
        );
        return Right(authenticatedUser);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> logoutUser(UserId userId) async {
    try {
      final userData = _users[userId.value];
      if (userData == null) {
        return Left(NotFoundFailure('User not found: ${userId.value}'));
      }

      // Clear session
      _userSessions.remove(userId.value);
      userData['isAuthenticated'] = false;
      userData['sessionId'] = null;

      final user = _userMapper.fromFirestore(userData, userId.value);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserRole(
    UserId userId,
    UserRole role,
  ) async {
    try {
      final userData = _users[userId.value];
      if (userData == null) {
        return Left(NotFoundFailure('User not found: ${userId.value}'));
      }

      userData['role'] = _getRoleString(role);

      // Update permissions based on new role
      _userPermissions[userId.value] = _getDefaultPermissionsForRole(role);

      final user = _userMapper.fromFirestore(userData, userId.value);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> activateUser(UserId userId) async {
    try {
      final userData = _users[userId.value];
      if (userData == null) {
        return Left(NotFoundFailure('User not found: ${userId.value}'));
      }

      userData['isActive'] = true;
      userData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final user = _userMapper.fromFirestore(userData, userId.value);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> deactivateUser(UserId userId) async {
    try {
      final userData = _users[userId.value];
      if (userData == null) {
        return Left(NotFoundFailure('User not found: ${userId.value}'));
      }

      userData['isActive'] = false;
      userData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final user = _userMapper.fromFirestore(userData, userId.value);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasPermission(
    UserId userId,
    Permission permission,
  ) async {
    try {
      final permissions = _userPermissions[userId.value] ?? <Permission>{};
      return Right(permissions.contains(permission));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Permission>>> getUserPermissions(
    UserId userId,
  ) async {
    try {
      final permissions = _userPermissions[userId.value] ?? <Permission>{};
      return Right(permissions.toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserSession(
    UserId userId,
    String sessionId,
    Time loginTime,
  ) async {
    try {
      final userData = _users[userId.value];
      if (userData == null) {
        return Left(NotFoundFailure('User not found: ${userId.value}'));
      }

      _userSessions[userId.value] = sessionId;
      userData['sessionId'] = sessionId;
      userData['lastLoginAt'] = loginTime.millisecondsSinceEpoch;
      userData['isAuthenticated'] = true;

      final user = _userMapper.fromFirestore(userData, userId.value);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isSessionValid(
    UserId userId,
    String sessionId,
  ) async {
    try {
      final storedSessionId = _userSessions[userId.value];
      return Right(storedSessionId == sessionId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(UserId userId) async {
    try {
      final userData = _users[userId.value];
      if (userData == null) {
        return Left(NotFoundFailure('User not found: ${userId.value}'));
      }

      final email = userData['email'] as String;
      _users.remove(userId.value);
      _emailToUserId.remove(email);
      _userPermissions.remove(userId.value);
      _userSessions.remove(userId.value);

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<User>>> watchUsers() {
    return Stream.periodic(const Duration(seconds: 1), (_) {
      try {
        final users = _users.values
            .map(
              (userData) =>
                  _userMapper.fromFirestore(userData, userData['id'] as String),
            )
            .toList();
        return Right<Failure, List<User>>(users);
      } catch (e) {
        return Left<Failure, List<User>>(ServerFailure(e.toString()));
      }
    });
  }

  @override
  Stream<Either<Failure, User>> watchUser(UserId userId) {
    return Stream.periodic(const Duration(seconds: 1), (_) {
      try {
        final userData = _users[userId.value];
        if (userData == null) {
          return Left<Failure, User>(
            NotFoundFailure('User not found: ${userId.value}'),
          );
        }

        final user = _userMapper.fromFirestore(userData, userId.value);
        return Right<Failure, User>(user);
      } catch (e) {
        return Left<Failure, User>(ServerFailure(e.toString()));
      }
    });
  }

  // Helper method to convert UserRole to string for filtering
  String _getRoleString(UserRole role) {
    switch (role) {
      case UserRole.dishwasher:
        return 'dishwasher';
      case UserRole.prepCook:
        return 'prep_cook';
      case UserRole.lineCook:
        return 'line_cook';
      case UserRole.cook:
        return 'cook';
      case UserRole.cookSenior:
        return 'cook_senior';
      case UserRole.chefAssistant:
        return 'chef_assistant';
      case UserRole.sousChef:
        return 'sous_chef';
      case UserRole.chefHead:
        return 'chef_head';
      case UserRole.expediter:
        return 'expediter';
      case UserRole.kitchenManager:
        return 'kitchen_manager';
      case UserRole.generalManager:
        return 'general_manager';
      case UserRole.admin:
        return 'admin';
    }
  }

  // Helper method to get default permissions for a role
  Set<Permission> _getDefaultPermissionsForRole(UserRole role) {
    switch (role) {
      case UserRole.dishwasher:
        return {Permission.viewOrders, Permission.workStation};
      case UserRole.prepCook:
        return {
          Permission.viewOrders,
          Permission.workStation,
          Permission.viewRecipes,
          Permission.viewInventory,
        };
      case UserRole.lineCook:
        return {
          Permission.viewOrders,
          Permission.updateOrderStatus,
          Permission.workStation,
          Permission.viewRecipes,
          Permission.viewInventory,
          Permission.manageStationEquipment,
        };
      case UserRole.cook:
        return {
          Permission.viewOrders,
          Permission.updateOrderStatus,
          Permission.prioritizeOrders,
          Permission.workStation,
          Permission.manageStationEquipment,
          Permission.assignOrdersToStation,
          Permission.viewRecipes,
          Permission.viewInventory,
          Permission.updateInventory,
        };
      case UserRole.cookSenior:
        return {
          Permission.viewOrders,
          Permission.updateOrderStatus,
          Permission.prioritizeOrders,
          Permission.workStation,
          Permission.manageStationEquipment,
          Permission.assignOrdersToStation,
          Permission.viewRecipes,
          Permission.modifyRecipes,
          Permission.viewInventory,
          Permission.updateInventory,
          Permission.manageFoodSafety,
          Permission.superviseStaff,
        };
      case UserRole.chefAssistant:
        return {
          Permission.viewOrders,
          Permission.updateOrderStatus,
          Permission.prioritizeOrders,
          Permission.workStation,
          Permission.manageStationEquipment,
          Permission.assignOrdersToStation,
          Permission.changeStationStatus,
          Permission.viewRecipes,
          Permission.modifyRecipes,
          Permission.viewInventory,
          Permission.updateInventory,
          Permission.manageInventory,
          Permission.manageFoodSafety,
          Permission.superviseStaff,
          Permission.trainStaff,
        };
      case UserRole.sousChef:
        return {
          Permission.viewOrders,
          Permission.updateOrderStatus,
          Permission.prioritizeOrders,
          Permission.cancelOrders,
          Permission.workStation,
          Permission.manageStationEquipment,
          Permission.assignOrdersToStation,
          Permission.changeStationStatus,
          Permission.viewRecipes,
          Permission.modifyRecipes,
          Permission.createRecipes,
          Permission.viewInventory,
          Permission.updateInventory,
          Permission.manageInventory,
          Permission.orderSupplies,
          Permission.manageFoodSafety,
          Permission.conductQualityControl,
          Permission.superviseStaff,
          Permission.trainStaff,
          Permission.evaluatePerformance,
          Permission.viewBasicReports,
        };
      case UserRole.chefHead:
        return {
          Permission.viewOrders,
          Permission.updateOrderStatus,
          Permission.prioritizeOrders,
          Permission.cancelOrders,
          Permission.workStation,
          Permission.manageStationEquipment,
          Permission.assignOrdersToStation,
          Permission.changeStationStatus,
          Permission.viewRecipes,
          Permission.modifyRecipes,
          Permission.createRecipes,
          Permission.manageMenu,
          Permission.setPricing,
          Permission.viewInventory,
          Permission.updateInventory,
          Permission.manageInventory,
          Permission.orderSupplies,
          Permission.receiveDeliveries,
          Permission.manageFoodSafety,
          Permission.conductQualityControl,
          Permission.manageTemperatureControl,
          Permission.handleAllergenProtocols,
          Permission.manageHACCP,
          Permission.viewStaffSchedule,
          Permission.manageStaffSchedule,
          Permission.superviseStaff,
          Permission.trainStaff,
          Permission.evaluatePerformance,
          Permission.viewBasicReports,
          Permission.viewAdvancedReports,
          Permission.handleEmergencyProcedures,
        };
      case UserRole.expediter:
        return {
          Permission.viewOrders,
          Permission.updateOrderStatus,
          Permission.prioritizeOrders,
          Permission.assignOrdersToStation,
          Permission.viewRecipes,
          Permission.conductQualityControl,
        };
      case UserRole.kitchenManager:
        return {
          Permission.viewOrders,
          Permission.updateOrderStatus,
          Permission.prioritizeOrders,
          Permission.cancelOrders,
          Permission.workStation,
          Permission.manageStationEquipment,
          Permission.assignOrdersToStation,
          Permission.changeStationStatus,
          Permission.viewRecipes,
          Permission.modifyRecipes,
          Permission.createRecipes,
          Permission.manageMenu,
          Permission.viewInventory,
          Permission.updateInventory,
          Permission.manageInventory,
          Permission.orderSupplies,
          Permission.receiveDeliveries,
          Permission.manageWaste,
          Permission.manageFoodSafety,
          Permission.conductQualityControl,
          Permission.manageTemperatureControl,
          Permission.handleAllergenProtocols,
          Permission.manageHACCP,
          Permission.viewStaffSchedule,
          Permission.manageStaffSchedule,
          Permission.superviseStaff,
          Permission.trainStaff,
          Permission.evaluatePerformance,
          Permission.managePayroll,
          Permission.viewBasicReports,
          Permission.viewAdvancedReports,
          Permission.handleCustomerComplaints,
          Permission.handleEmergencyProcedures,
          Permission.accessEmergencyOverride,
        };
      case UserRole.generalManager:
        return Permission.values.toSet(); // All permissions
      case UserRole.admin:
        return Permission.values.toSet(); // All permissions
    }
  }
}
