import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/entities/user.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';

void main() {
  group('Enhanced Kitchen User System', () {
    late UserId userId;
    late Time createdAt;

    setUp(() {
      userId = UserId('user123');
      createdAt = Time.now();
    });

    group('Kitchen Role Hierarchy', () {
      test('Dishwasher should have basic permissions only', () {
        final user = User(
          id: userId,
          email: 'dishwasher@kitchen.com',
          name: 'John Dishwasher',
          role: UserRole.dishwasher,
          createdAt: createdAt,
        );

        // Basic permissions
        expect(user.canViewOrders(), isTrue);
        expect(user.canManageFoodSafety(), isTrue);

        // Should NOT have advanced permissions
        expect(user.canUpdateOrderStatus(), isFalse);
        expect(user.canSuperviseStaff(), isFalse);
        expect(user.canManageInventory(), isFalse);
        expect(user.canCreateRecipes(), isFalse);

        // Role checks
        expect(user.isKitchenStaff, isTrue);
        expect(user.isManager, isFalse);
        expect(user.isSeniorStaff, isFalse);
      });

      test('Line Cook should work stations and update orders', () {
        final user = User(
          id: userId,
          email: 'linecook@kitchen.com',
          name: 'Maria LineCook',
          role: UserRole.lineCook,
          createdAt: createdAt,
        );

        // Line cook permissions
        expect(user.canViewOrders(), isTrue);
        expect(user.canUpdateOrderStatus(), isTrue);
        expect(user.canWorkStation(), isTrue);
        expect(user.canViewRecipes(), isTrue);
        expect(user.canViewInventory(), isTrue);

        // Should NOT have management permissions
        expect(user.canSuperviseStaff(), isFalse);
        expect(user.canManageInventory(), isFalse);
        expect(user.canCreateRecipes(), isFalse);
        expect(user.canManageUsers(), isFalse);
      });

      test('Senior Cook should supervise and manage inventory', () {
        final user = User(
          id: userId,
          email: 'seniorcook@kitchen.com',
          name: 'Carlos Senior',
          role: UserRole.cookSenior,
          createdAt: createdAt,
        );

        // Senior cook permissions
        expect(user.canSuperviseStaff(), isTrue);
        expect(user.canManageInventory(), isTrue);
        expect(user.canTrainStaff(), isTrue);
        expect(user.canModifyRecipes(), isTrue);
        expect(user.canChangeStationStatus(), isTrue);

        // Should NOT have user management
        expect(user.canManageUsers(), isFalse);
        expect(user.canViewAdvancedReports(), isFalse);

        // Role checks
        expect(user.isSeniorStaff, isTrue);
        expect(user.isManager, isFalse);
      });

      test('Sous Chef should have management permissions', () {
        final user = User(
          id: userId,
          email: 'souschef@kitchen.com',
          name: 'Anna SousChef',
          role: UserRole.sousChef,
          createdAt: createdAt,
        );

        // Management permissions
        expect(user.canManageUsers(), isTrue);
        expect(user.canCancelOrders(), isTrue);
        expect(user.canViewAdvancedReports(), isTrue);
        expect(user.canManageStaffSchedule(), isTrue);
        expect(user.canManageMenu(), isTrue);

        // Role checks
        expect(user.isManager, isTrue);
        expect(user.isSeniorStaff, isTrue);
        expect(user.isKitchenStaff, isTrue);
      });

      test('Head Chef should have full kitchen authority', () {
        final user = User(
          id: userId,
          email: 'headchef@kitchen.com',
          name: 'Gordon HeadChef',
          role: UserRole.chefHead,
          createdAt: createdAt,
        );

        // Full kitchen permissions
        expect(user.canViewFinancialReports(), isTrue);
        expect(user.canManageUsers(), isTrue);
        expect(user.canCreateRecipes(), isTrue);
        expect(user.canManageMenu(), isTrue);
        expect(user.canSuperviseStaff(), isTrue);
        expect(user.canManageInventory(), isTrue);

        // Should NOT have system administration
        expect(user.canManageSystem(), isFalse);
      });

      test('Admin should have all permissions', () {
        final user = User(
          id: userId,
          email: 'admin@kitchen.com',
          name: 'System Admin',
          role: UserRole.admin,
          createdAt: createdAt,
        );

        // Should have ALL permissions
        expect(user.canManageSystem(), isTrue);
        expect(user.canViewFinancialReports(), isTrue);
        expect(user.canManageUsers(), isTrue);
        expect(user.canCreateRecipes(), isTrue);
        expect(user.canSuperviseStaff(), isTrue);

        expect(user.isAdmin, isTrue);
      });
    });

    group('Business Rules Examples', () {
      test('Only senior staff can supervise others', () {
        final dishwasher = User(
          id: userId,
          email: 'dish@kitchen.com',
          name: 'Dishwasher',
          role: UserRole.dishwasher,
          createdAt: createdAt,
        );

        final seniorCook = User(
          id: userId,
          email: 'senior@kitchen.com',
          name: 'Senior Cook',
          role: UserRole.cookSenior,
          createdAt: createdAt,
        );

        expect(dishwasher.canSuperviseStaff(), isFalse);
        expect(seniorCook.canSuperviseStaff(), isTrue);
      });

      test('Only management can access advanced reports', () {
        final lineCook = User(
          id: userId,
          email: 'line@kitchen.com',
          name: 'Line Cook',
          role: UserRole.lineCook,
          createdAt: createdAt,
        );

        final sousChef = User(
          id: userId,
          email: 'sous@kitchen.com',
          name: 'Sous Chef',
          role: UserRole.sousChef,
          createdAt: createdAt,
        );

        expect(lineCook.canViewAdvancedReports(), isFalse);
        expect(sousChef.canViewAdvancedReports(), isTrue);
      });

      test('Food safety is accessible to all kitchen roles', () {
        final dishwasher = User(
          id: userId,
          email: 'a@b.com',
          name: 'A',
          role: UserRole.dishwasher,
          createdAt: createdAt,
        );
        final lineCook = User(
          id: userId,
          email: 'a@b.com',
          name: 'A',
          role: UserRole.lineCook,
          createdAt: createdAt,
        );
        final headChef = User(
          id: userId,
          email: 'a@b.com',
          name: 'A',
          role: UserRole.chefHead,
          createdAt: createdAt,
        );

        expect(dishwasher.canManageFoodSafety(), isTrue);
        expect(lineCook.canManageFoodSafety(), isTrue);
        expect(headChef.canManageFoodSafety(), isTrue);
      });
    });
  });
}
