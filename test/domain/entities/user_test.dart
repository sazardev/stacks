import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/entities/user.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';
import 'package:stacks/domain/exceptions/domain_exception.dart';

void main() {
  group('User', () {
    late UserId userId;
    late Time createdAt;

    setUp(() {
      userId = UserId('user123');
      createdAt = Time.now();
    });

    group('creation', () {
      test('should create User with valid data', () {
        // Arrange & Act
        final user = User(
          id: userId,
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
        );

        // Assert
        expect(user.id, equals(userId));
        expect(user.email, equals('test@example.com'));
        expect(user.name, equals('Test User'));
        expect(user.role, equals(UserRole.kitchenStaff));
        expect(user.createdAt, equals(createdAt));
        expect(user.isActive, isTrue);
        expect(user.isAuthenticated, isFalse);
      });

      test('should create User with manager role', () {
        // Arrange & Act
        final user = User(
          id: userId,
          email: 'manager@example.com',
          name: 'Manager User',
          role: UserRole.manager,
          createdAt: createdAt,
        );

        // Assert
        expect(user.role, equals(UserRole.manager));
        expect(user.isManager, isTrue);
      });

      test('should create User with admin role', () {
        // Arrange & Act
        final user = User(
          id: userId,
          email: 'admin@example.com',
          name: 'Admin User',
          role: UserRole.admin,
          createdAt: createdAt,
        );

        // Assert
        expect(user.role, equals(UserRole.admin));
        expect(user.isAdmin, isTrue);
      });

      test('should throw DomainException for empty email', () {
        // Arrange & Act & Assert
        expect(
          () => User(
            id: userId,
            email: '',
            name: 'Test User',
            role: UserRole.kitchenStaff,
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw DomainException for invalid email format', () {
        // Arrange & Act & Assert
        expect(
          () => User(
            id: userId,
            email: 'invalid-email',
            name: 'Test User',
            role: UserRole.kitchenStaff,
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw DomainException for empty name', () {
        // Arrange & Act & Assert
        expect(
          () => User(
            id: userId,
            email: 'test@example.com',
            name: '',
            role: UserRole.kitchenStaff,
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw DomainException for name too long', () {
        // Arrange
        final longName = 'a' * 101; // 101 characters

        // Act & Assert
        expect(
          () => User(
            id: userId,
            email: 'test@example.com',
            name: longName,
            role: UserRole.kitchenStaff,
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });
    });

    group('authentication', () {
      test('should authenticate user with session', () {
        // Arrange
        final user = User(
          id: userId,
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
        );
        final sessionId = 'session123';
        final loginTime = Time.now();

        // Act
        final authenticatedUser = user.authenticate(sessionId, loginTime);

        // Assert
        expect(authenticatedUser.isAuthenticated, isTrue);
        expect(authenticatedUser.sessionId, equals(sessionId));
        expect(authenticatedUser.lastLoginAt, equals(loginTime));
      });

      test('should logout authenticated user', () {
        // Arrange
        final user = User(
          id: userId,
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
        );
        final authenticatedUser = user.authenticate('session123', Time.now());

        // Act
        final loggedOutUser = authenticatedUser.logout();

        // Assert
        expect(loggedOutUser.isAuthenticated, isFalse);
        expect(loggedOutUser.sessionId, isNull);
      });

      test('should check if session is expired', () {
        // Arrange
        final user = User(
          id: userId,
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
        );
        final oldLoginTime = Time.fromDateTime(
          DateTime.now().subtract(const Duration(hours: 25)),
        );
        final authenticatedUser = user.authenticate('session123', oldLoginTime);

        // Act
        final isExpired = authenticatedUser.isSessionExpired();

        // Assert
        expect(isExpired, isTrue);
      });

      test('should check if session is not expired', () {
        // Arrange
        final user = User(
          id: userId,
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
        );
        final recentLoginTime = Time.fromDateTime(
          DateTime.now().subtract(const Duration(hours: 1)),
        );
        final authenticatedUser = user.authenticate(
          'session123',
          recentLoginTime,
        );

        // Act
        final isExpired = authenticatedUser.isSessionExpired();

        // Assert
        expect(isExpired, isFalse);
      });
    });

    group('permissions', () {
      test('should check kitchen staff permissions', () {
        // Arrange
        final user = User(
          id: userId,
          email: 'staff@example.com',
          name: 'Kitchen Staff',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
        );

        // Act & Assert
        expect(user.canViewOrders(), isTrue);
        expect(user.canUpdateOrderStatus(), isTrue);
        expect(user.canManageUsers(), isFalse);
        expect(user.canAccessReports(), isFalse);
        expect(user.canManageStations(), isFalse);
        expect(user.canDeleteOrders(), isFalse);
      });

      test('should check manager permissions', () {
        // Arrange
        final user = User(
          id: userId,
          email: 'manager@example.com',
          name: 'Manager',
          role: UserRole.manager,
          createdAt: createdAt,
        );

        // Act & Assert
        expect(user.canViewOrders(), isTrue);
        expect(user.canUpdateOrderStatus(), isTrue);
        expect(user.canManageUsers(), isTrue);
        expect(user.canAccessReports(), isTrue);
        expect(user.canManageStations(), isTrue);
        expect(user.canDeleteOrders(), isTrue);
      });

      test('should check admin permissions', () {
        // Arrange
        final user = User(
          id: userId,
          email: 'admin@example.com',
          name: 'Admin',
          role: UserRole.admin,
          createdAt: createdAt,
        );

        // Act & Assert
        expect(user.canViewOrders(), isTrue);
        expect(user.canUpdateOrderStatus(), isTrue);
        expect(user.canManageUsers(), isTrue);
        expect(user.canAccessReports(), isTrue);
        expect(user.canManageStations(), isTrue);
        expect(user.canDeleteOrders(), isTrue);
        expect(user.canManageSystem(), isTrue);
      });

      test('should check specific permissions for roles', () {
        // Arrange
        final staffUser = User(
          id: userId,
          email: 'staff@example.com',
          name: 'Staff',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
        );

        final managerUser = User(
          id: UserId('manager123'),
          email: 'manager@example.com',
          name: 'Manager',
          role: UserRole.manager,
          createdAt: createdAt,
        );

        // Act & Assert
        expect(staffUser.hasPermission(Permission.viewOrders), isTrue);
        expect(staffUser.hasPermission(Permission.manageUsers), isFalse);
        expect(managerUser.hasPermission(Permission.manageUsers), isTrue);
        expect(managerUser.hasPermission(Permission.manageSystem), isFalse);
      });
    });

    group('status management', () {
      test('should activate inactive user', () {
        // Arrange
        final user = User(
          id: userId,
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
          isActive: false,
        );

        // Act
        final activatedUser = user.activate();

        // Assert
        expect(activatedUser.isActive, isTrue);
      });

      test('should deactivate active user', () {
        // Arrange
        final user = User(
          id: userId,
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
          isActive: true,
        );

        // Act
        final deactivatedUser = user.deactivate();

        // Assert
        expect(deactivatedUser.isActive, isFalse);
      });

      test('should update user profile', () {
        // Arrange
        final user = User(
          id: userId,
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
        );

        // Act
        final updatedUser = user.updateProfile(
          name: 'Updated Name',
          email: 'updated@example.com',
        );

        // Assert
        expect(updatedUser.name, equals('Updated Name'));
        expect(updatedUser.email, equals('updated@example.com'));
        expect(updatedUser.id, equals(userId)); // ID should remain same
        expect(
          updatedUser.role,
          equals(UserRole.kitchenStaff),
        ); // Role should remain same
      });

      test('should change user role', () {
        // Arrange
        final user = User(
          id: userId,
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
        );

        // Act
        final promotedUser = user.changeRole(UserRole.manager);

        // Assert
        expect(promotedUser.role, equals(UserRole.manager));
        expect(promotedUser.isManager, isTrue);
      });
    });

    group('business rules', () {
      test('should validate user can perform action based on role', () {
        // Arrange
        final staffUser = User(
          id: userId,
          email: 'staff@example.com',
          name: 'Staff',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
        );

        // Act & Assert
        expect(staffUser.canPerformAction('VIEW_ORDERS'), isTrue);
        expect(staffUser.canPerformAction('UPDATE_ORDER_STATUS'), isTrue);
        expect(staffUser.canPerformAction('MANAGE_USERS'), isFalse);
      });

      test('should get user display name', () {
        // Arrange
        final user = User(
          id: userId,
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
        );

        // Act
        final displayName = user.getDisplayName();

        // Assert
        expect(displayName, equals('Test User'));
      });

      test('should get user initials', () {
        // Arrange
        final user = User(
          id: userId,
          email: 'test@example.com',
          name: 'John David Smith',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
        );

        // Act
        final initials = user.getInitials();

        // Assert
        expect(initials, equals('JDS'));
      });

      test('should handle single name for initials', () {
        // Arrange
        final user = User(
          id: userId,
          email: 'test@example.com',
          name: 'John',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
        );

        // Act
        final initials = user.getInitials();

        // Assert
        expect(initials, equals('J'));
      });
    });

    group('equality', () {
      test('should be equal when IDs are same', () {
        // Arrange
        final user1 = User(
          id: userId,
          email: 'test1@example.com',
          name: 'User 1',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
        );

        final user2 = User(
          id: userId,
          email: 'test2@example.com',
          name: 'User 2',
          role: UserRole.manager,
          createdAt: Time.now(),
        );

        // Act & Assert
        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should not be equal when IDs are different', () {
        // Arrange
        final user1 = User(
          id: UserId('user1'),
          email: 'test@example.com',
          name: 'User 1',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
        );

        final user2 = User(
          id: UserId('user2'),
          email: 'test@example.com',
          name: 'User 1',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
        );

        // Act & Assert
        expect(user1, isNot(equals(user2)));
      });
    });

    group('string representation', () {
      test('should return formatted string representation', () {
        // Arrange
        final user = User(
          id: userId,
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.kitchenStaff,
          createdAt: createdAt,
        );

        // Act
        final string = user.toString();

        // Assert
        expect(
          string,
          equals('User(id: user123, name: Test User, role: kitchenStaff)'),
        );
      });
    });
  });
}
