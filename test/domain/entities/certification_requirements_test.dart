import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/entities/user.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';

void main() {
  group('User - Certification Requirements', () {
    late User user;

    setUp(() {
      user = User(
        id: UserId.generate(),
        name: 'Test Chef',
        email: 'chef@test.com',
        role: UserRole.lineCook,
        createdAt: Time.now(),
        isActive: true,
      );
    });

    group('getRequiredCertifications', () {
      test('should return food safety for all roles', () {
        final roles = [
          UserRole.dishwasher,
          UserRole.prepCook,
          UserRole.lineCook,
          UserRole.sousChef,
          UserRole.chefHead,
          UserRole.expediter,
          UserRole.admin,
        ];

        for (final role in roles) {
          final user = User(
            id: UserId.generate(),
            name: 'Test User',
            email: 'test@test.com',
            role: role,
            createdAt: Time.now(),
            isActive: true,
          );

          final certs = user.getRequiredCertifications();
          expect(
            certs,
            contains(CertificationType.foodSafety),
            reason: '$role should require food safety certification',
          );
        }
      });

      test('should return management for cooking roles', () {
        final cookingRoles = [
          UserRole.cook,
          UserRole.cookSenior,
          UserRole.chefAssistant,
          UserRole.lineCook,
          UserRole.sousChef,
          UserRole.chefHead,
        ];

        for (final role in cookingRoles) {
          final user = User(
            id: UserId.generate(),
            name: 'Test Chef',
            email: 'chef@test.com',
            role: role,
            createdAt: Time.now(),
            isActive: true,
          );

          final certs = user.getRequiredCertifications();
          expect(
            certs,
            contains(CertificationType.equipmentOperation),
            reason: '$role should require equipment operation certification',
          );
        }
      });

      test('should return fire safety for hot station roles', () {
        final hotStationRoles = [
          UserRole.cook,
          UserRole.cookSenior,
          UserRole.chefAssistant,
        ];

        for (final role in hotStationRoles) {
          final user = User(
            id: UserId.generate(),
            name: 'Test Chef',
            email: 'chef@test.com',
            role: role,
            createdAt: Time.now(),
            isActive: true,
          );

          final certs = user.getRequiredCertifications();
          expect(
            certs,
            contains(CertificationType.fireSafety),
            reason: '$role should require fire safety certification',
          );
        }
      });

      test('should return allergen awareness for all cooking roles', () {
        final cookingRoles = [
          UserRole.cook,
          UserRole.cookSenior,
          UserRole.chefAssistant,
          UserRole.lineCook,
          UserRole.sousChef,
          UserRole.chefHead,
        ];

        for (final role in cookingRoles) {
          final user = User(
            id: UserId.generate(),
            name: 'Test Chef',
            email: 'chef@test.com',
            role: role,
            createdAt: Time.now(),
            isActive: true,
          );

          final certs = user.getRequiredCertifications();
          expect(
            certs,
            contains(CertificationType.allergenAwareness),
            reason: '$role should require allergen awareness',
          );
        }
      });

      test('should return equipment operation for prep roles', () {
        final prepRoles = [
          UserRole.prepCook,
          UserRole.sousChef,
          UserRole.chefHead,
        ];

        for (final role in prepRoles) {
          final user = User(
            id: UserId.generate(),
            name: 'Test Chef',
            email: 'chef@test.com',
            role: role,
            createdAt: Time.now(),
            isActive: true,
          );

          final certs = user.getRequiredCertifications();
          expect(
            certs,
            contains(CertificationType.equipmentOperation),
            reason: '$role should require equipment operation certification',
          );
        }
      });

      test('should return management training for management roles', () {
        final managementRoles = [
          UserRole.sousChef,
          UserRole.chefHead,
          UserRole.admin,
        ];

        for (final role in managementRoles) {
          final user = User(
            id: UserId.generate(),
            name: 'Test Chef',
            email: 'chef@test.com',
            role: role,
            createdAt: Time.now(),
            isActive: true,
          );

          final certs = user.getRequiredCertifications();
          expect(
            certs,
            contains(CertificationType.management),
            reason: '$role should require management training',
          );
        }
      });

      test('should return haccp for senior roles', () {
        final seniorRoles = [
          UserRole.sousChef,
          UserRole.chefHead,
          UserRole.admin,
        ];

        for (final role in seniorRoles) {
          final user = User(
            id: UserId.generate(),
            name: 'Test Chef',
            email: 'chef@test.com',
            role: role,
            createdAt: Time.now(),
            isActive: true,
          );

          final certs = user.getRequiredCertifications();
          expect(
            certs,
            contains(CertificationType.haccp),
            reason: '$role should require HACCP certification',
          );
        }
      });

      test('should return station specific for specialized roles', () {
        final specializedRoles = [
          UserRole.cook,
          UserRole.cookSenior,
          UserRole.chefAssistant,
        ];

        for (final role in specializedRoles) {
          final user = User(
            id: UserId.generate(),
            name: 'Test Chef',
            email: 'chef@test.com',
            role: role,
            createdAt: Time.now(),
            isActive: true,
          );

          final certs = user.getRequiredCertifications();
          expect(
            certs,
            contains(CertificationType.stationSpecific),
            reason: '$role should require station-specific training',
          );
        }
      });
    });

    group('canWorkStationWithCertification', () {
      test('should deny access without food safety certification', () {
        final result = user.canWorkStationWithCertification(
          KitchenStation.grill,
          [CertificationType.fireSafety],
        );

        expect(result, false);
      });

      test('should deny hot station access without fire safety', () {
        final result = user.canWorkStationWithCertification(
          KitchenStation.grill,
          [CertificationType.foodSafety],
        );

        expect(result, false);
      });

      test('should allow access with proper certifications', () {
        final user = User(
          id: UserId.generate(),
          name: 'Grill Chef',
          email: 'grill@test.com',
          role: UserRole.cook,
          createdAt: Time.now(),
          isActive: true,
        );

        final result = user
            .canWorkStationWithCertification(KitchenStation.grill, [
              CertificationType.foodSafety,
              CertificationType.fireSafety,
              CertificationType.stationSpecific,
            ]);

        expect(result, true);
      });

      test('should deny access if cannot work at station', () {
        final dishwasher = User(
          id: UserId.generate(),
          name: 'Dishwasher',
          email: 'dish@test.com',
          role: UserRole.dishwasher,
          createdAt: Time.now(),
          isActive: true,
        );

        final result = dishwasher
            .canWorkStationWithCertification(KitchenStation.grill, [
              CertificationType.foodSafety,
              CertificationType.fireSafety,
              CertificationType.stationSpecific,
            ]);

        expect(result, false);
      });

      test('should allow salad station without fire safety', () {
        final saladChef = User(
          id: UserId.generate(),
          name: 'Salad Chef',
          email: 'salad@test.com',
          role: UserRole.lineCook,
          createdAt: Time.now(),
          isActive: true,
        );

        final result = saladChef.canWorkStationWithCertification(
          KitchenStation.salad,
          [CertificationType.foodSafety, CertificationType.stationSpecific],
        );

        expect(result, true);
      });

      test(
        'should deny specialized station without station-specific training',
        () {
          final result = user.canWorkStationWithCertification(
            KitchenStation.pastry,
            [CertificationType.foodSafety],
          );

          expect(result, false);
        },
      );
    });

    group('certification business rules', () {
      test('should validate certification combinations for roles', () {
        final grilChef = User(
          id: UserId.generate(),
          name: 'Grill Chef',
          email: 'grill@test.com',
          role: UserRole.cook,
          createdAt: Time.now(),
          isActive: true,
        );

        // Grill chef should need all these certifications
        final requiredCerts = grilChef.getRequiredCertifications();
        expect(
          requiredCerts,
          containsAll([
            CertificationType.foodSafety,
            CertificationType.equipmentOperation,
            CertificationType.fireSafety,
            CertificationType.allergenAwareness,
            CertificationType.stationSpecific,
          ]),
        );
      });

      test('should validate minimal certifications for basic roles', () {
        final dishwasher = User(
          id: UserId.generate(),
          name: 'Dishwasher',
          email: 'dish@test.com',
          role: UserRole.dishwasher,
          createdAt: Time.now(),
          isActive: true,
        );

        final requiredCerts = dishwasher.getRequiredCertifications();
        expect(
          requiredCerts.length,
          2,
        ); // Only food safety and equipment operation
        expect(requiredCerts, contains(CertificationType.foodSafety));
        expect(requiredCerts, contains(CertificationType.equipmentOperation));
      });

      test('should validate comprehensive certifications for head chef', () {
        final headChef = User(
          id: UserId.generate(),
          name: 'Head Chef',
          email: 'head@test.com',
          role: UserRole.chefHead,
          createdAt: Time.now(),
          isActive: true,
        );

        final requiredCerts = headChef.getRequiredCertifications();
        expect(
          requiredCerts,
          containsAll([
            CertificationType.foodSafety,
            CertificationType.equipmentOperation,
            CertificationType.fireSafety,
            CertificationType.allergenAwareness,
            CertificationType.management,
            CertificationType.haccp,
          ]),
        );
      });
    });
  });
}
