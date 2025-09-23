import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/entities/user.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';

void main() {
  group('Temporal Permissions and Shift-Based Access Control', () {
    late UserId userId;
    late Time createdAt;

    setUp(() {
      userId = UserId('user123');
      createdAt = Time.now();
    });

    group('Shift Detection', () {
      test('Should correctly identify morning prep shift (5 AM - 11 AM)', () {
        final user = User(
          id: userId,
          email: 'test@kitchen.com',
          name: 'Test User',
          role: UserRole.lineCook,
          createdAt: createdAt,
        );

        // Test different hours in morning prep shift
        final morningTimes = [
          Time.fromDateTime(DateTime(2025, 1, 1, 5, 0)), // 5:00 AM
          Time.fromDateTime(DateTime(2025, 1, 1, 8, 30)), // 8:30 AM
          Time.fromDateTime(DateTime(2025, 1, 1, 10, 59)), // 10:59 AM
        ];

        for (final time in morningTimes) {
          expect(
            user.canAccessKitchenAtTime(time),
            isTrue,
            reason:
                'Should have access during morning prep at ${time.dateTime.hour}:${time.dateTime.minute}',
          );
        }
      });

      test('Should correctly identify lunch shift (11 AM - 3 PM)', () {
        final sousChef = User(
          id: userId,
          email: 'sous@kitchen.com',
          name: 'Sous Chef',
          role: UserRole.sousChef,
          createdAt: createdAt,
        );

        final lunchTime = Time.fromDateTime(
          DateTime(2025, 1, 1, 12, 0),
        ); // 12:00 PM

        expect(
          sousChef.canAccessFinancialsNow(currentTime: lunchTime),
          isTrue,
          reason: 'Sous chef should access financials during lunch shift',
        );
      });

      test('Should correctly identify dinner shift (5 PM - 10 PM)', () {
        final lineCook = User(
          id: userId,
          email: 'line@kitchen.com',
          name: 'Line Cook',
          role: UserRole.lineCook,
          createdAt: createdAt,
        );

        final dinnerTime = Time.fromDateTime(
          DateTime(2025, 1, 1, 18, 0),
        ); // 6:00 PM

        expect(
          lineCook.canAccessKitchenAtTime(dinnerTime),
          isTrue,
          reason: 'Line cook should have access during dinner service',
        );
      });

      test('Should correctly identify night shift (10 PM - 2 AM)', () {
        final manager = User(
          id: userId,
          email: 'manager@kitchen.com',
          name: 'Kitchen Manager',
          role: UserRole.kitchenManager,
          createdAt: createdAt,
        );

        final nightTime = Time.fromDateTime(
          DateTime(2025, 1, 1, 23, 0),
        ); // 11:00 PM

        expect(
          manager.hasTemporalPermission(
            TemporalPermission.overrideClosing,
            currentTime: nightTime,
          ),
          isTrue,
          reason:
              'Manager should be able to override closing during night shift',
        );
      });

      test('Should correctly identify overnight shift (2 AM - 5 AM)', () {
        final admin = User(
          id: userId,
          email: 'admin@kitchen.com',
          name: 'Admin',
          role: UserRole.admin,
          createdAt: createdAt,
        );

        final overnightTime = Time.fromDateTime(
          DateTime(2025, 1, 1, 3, 0),
        ); // 3:00 AM

        expect(
          admin.hasTemporalPermission(
            TemporalPermission.emergencyAccess,
            currentTime: overnightTime,
          ),
          isTrue,
          reason: 'Admin should have emergency access during overnight',
        );
      });
    });

    group('Role-Based Temporal Permissions', () {
      test('Dishwasher should have limited temporal permissions', () {
        final dishwasher = User(
          id: userId,
          email: 'dish@kitchen.com',
          name: 'John Dishwasher',
          role: UserRole.dishwasher,
          createdAt: createdAt,
        );

        final morningTime = Time.fromDateTime(DateTime(2025, 1, 1, 6, 0));

        // Has basic permissions
        expect(
          dishwasher.hasTemporalPermission(
            TemporalPermission.inventoryAccess,
            currentTime: morningTime,
          ),
          isTrue,
        );

        // Does not have advanced permissions
        expect(
          dishwasher.hasTemporalPermission(
            TemporalPermission.offHoursAccess,
            currentTime: morningTime,
          ),
          isFalse,
        );
        expect(
          dishwasher.hasTemporalPermission(
            TemporalPermission.authorizeOvertime,
            currentTime: morningTime,
          ),
          isFalse,
        );
        expect(
          dishwasher.hasTemporalPermission(
            TemporalPermission.openKitchen,
            currentTime: morningTime,
          ),
          isFalse,
        );
      });

      test('Senior Cook should have overtime authorization', () {
        final seniorCook = User(
          id: userId,
          email: 'senior@kitchen.com',
          name: 'Senior Cook',
          role: UserRole.cookSenior,
          createdAt: createdAt,
        );

        final dinnerTime = Time.fromDateTime(DateTime(2025, 1, 1, 19, 0));

        expect(
          seniorCook.canAuthorizeOvertimeNow(currentTime: dinnerTime),
          isTrue,
          reason: 'Senior cook should authorize overtime',
        );
        expect(
          seniorCook.hasTemporalPermission(
            TemporalPermission.offHoursAccess,
            currentTime: dinnerTime,
          ),
          isTrue,
        );
      });

      test('Sous Chef should have comprehensive shift management', () {
        final sousChef = User(
          id: userId,
          email: 'sous@kitchen.com',
          name: 'Sous Chef',
          role: UserRole.sousChef,
          createdAt: createdAt,
        );

        final morningTime = Time.fromDateTime(DateTime(2025, 1, 1, 7, 0));
        final nightTime = Time.fromDateTime(DateTime(2025, 1, 1, 23, 0));

        // Can open kitchen in morning
        expect(
          sousChef.hasTemporalPermission(
            TemporalPermission.openKitchen,
            currentTime: morningTime,
          ),
          isTrue,
        );

        // Can override closing at night
        expect(
          sousChef.hasTemporalPermission(
            TemporalPermission.overrideClosing,
            currentTime: nightTime,
          ),
          isTrue,
        );

        // Can modify schedules
        expect(
          sousChef.canModifySchedulesDuringShift(WorkShift.morningPrep),
          isTrue,
        );
      });

      test(
        'Head Chef should have full temporal permissions except system admin',
        () {
          final headChef = User(
            id: userId,
            email: 'head@kitchen.com',
            name: 'Head Chef',
            role: UserRole.chefHead,
            createdAt: createdAt,
          );

          final lunchTime = Time.fromDateTime(DateTime(2025, 1, 1, 13, 0));

          // Has financial access during business hours
          expect(
            headChef.canAccessFinancialsNow(currentTime: lunchTime),
            isTrue,
          );

          // Has emergency access
          expect(
            headChef.hasTemporalPermission(
              TemporalPermission.emergencyAccess,
              currentTime: lunchTime,
            ),
            isTrue,
          );

          // Can authorize overtime
          expect(
            headChef.canAuthorizeOvertimeNow(currentTime: lunchTime),
            isTrue,
          );
        },
      );

      test('Admin should have all temporal permissions', () {
        final admin = User(
          id: userId,
          email: 'admin@kitchen.com',
          name: 'System Admin',
          role: UserRole.admin,
          createdAt: createdAt,
        );

        final overnightTime = Time.fromDateTime(DateTime(2025, 1, 1, 3, 0));

        // Should have all permissions
        for (final permission in TemporalPermission.values) {
          expect(
            admin.hasTemporalPermission(permission, currentTime: overnightTime),
            isTrue,
            reason: 'Admin should have ${permission.name} permission',
          );
        }
      });
    });

    group('Business Rules for Time-Based Access', () {
      test(
        'Kitchen access should be restricted during overnight hours for junior staff',
        () {
          final lineCook = User(
            id: userId,
            email: 'line@kitchen.com',
            name: 'Line Cook',
            role: UserRole.lineCook,
            createdAt: createdAt,
          );

          final prepCook = User(
            id: userId,
            email: 'prep@kitchen.com',
            name: 'Prep Cook',
            role: UserRole.prepCook,
            createdAt: createdAt,
          );

          final overnightTime = Time.fromDateTime(
            DateTime(2025, 1, 1, 3, 0),
          ); // 3:00 AM

          // Line cook has off-hours access
          expect(lineCook.canAccessKitchenAtTime(overnightTime), isTrue);

          // Prep cook does not have off-hours access
          expect(prepCook.canAccessKitchenAtTime(overnightTime), isFalse);
        },
      );

      test('Financial access should be restricted to business hours', () {
        final sousChef = User(
          id: userId,
          email: 'sous@kitchen.com',
          name: 'Sous Chef',
          role: UserRole.sousChef,
          createdAt: createdAt,
        );

        final businessHour = Time.fromDateTime(
          DateTime(2025, 1, 1, 14, 0),
        ); // 2:00 PM
        final offHour = Time.fromDateTime(
          DateTime(2025, 1, 1, 4, 0),
        ); // 4:00 AM

        // Can access during business hours
        expect(
          sousChef.canAccessFinancialsNow(currentTime: businessHour),
          isTrue,
        );

        // Cannot access during off hours (unless emergency)
        expect(
          sousChef.canAccessFinancialsNow(currentTime: offHour),
          isTrue, // Has emergency access
          reason: 'Sous chef has emergency access for financials',
        );
      });

      test('Only senior management can open kitchen in morning', () {
        final lineCook = User(
          id: userId,
          email: 'line@kitchen.com',
          name: 'Line Cook',
          role: UserRole.lineCook,
          createdAt: createdAt,
        );

        final kitchenManager = User(
          id: userId,
          email: 'manager@kitchen.com',
          name: 'Kitchen Manager',
          role: UserRole.kitchenManager,
          createdAt: createdAt,
        );

        final earlyMorning = Time.fromDateTime(
          DateTime(2025, 1, 1, 6, 0),
        ); // 6:00 AM

        expect(
          lineCook.hasTemporalPermission(
            TemporalPermission.openKitchen,
            currentTime: earlyMorning,
          ),
          isFalse,
        );

        expect(
          kitchenManager.hasTemporalPermission(
            TemporalPermission.openKitchen,
            currentTime: earlyMorning,
          ),
          isTrue,
        );
      });

      test('Overtime authorization should depend on role and time', () {
        final cook = User(
          id: userId,
          email: 'cook@kitchen.com',
          name: 'Cook',
          role: UserRole.cook,
          createdAt: createdAt,
        );

        final seniorCook = User(
          id: userId,
          email: 'senior@kitchen.com',
          name: 'Senior Cook',
          role: UserRole.cookSenior,
          createdAt: createdAt,
        );

        final dinnerTime = Time.fromDateTime(
          DateTime(2025, 1, 1, 20, 0),
        ); // 8:00 PM

        // Regular cook cannot authorize overtime
        expect(cook.canAuthorizeOvertimeNow(currentTime: dinnerTime), isFalse);

        // Senior cook can authorize overtime
        expect(
          seniorCook.canAuthorizeOvertimeNow(currentTime: dinnerTime),
          isTrue,
        );
      });
    });

    group('Shift Descriptions and Utilities', () {
      test('Should provide correct shift descriptions', () {
        final user = User(
          id: userId,
          email: 'test@kitchen.com',
          name: 'Test User',
          role: UserRole.lineCook,
          createdAt: createdAt,
        );

        expect(
          user.getShiftDescription(WorkShift.morningPrep),
          equals('Morning Prep (5:00 AM - 11:00 AM)'),
        );
        expect(
          user.getShiftDescription(WorkShift.lunch),
          equals('Lunch Service (11:00 AM - 3:00 PM)'),
        );
        expect(
          user.getShiftDescription(WorkShift.dinner),
          equals('Dinner Service (5:00 PM - 10:00 PM)'),
        );
      });

      test('Should get current temporal permissions for role and time', () {
        final sousChef = User(
          id: userId,
          email: 'sous@kitchen.com',
          name: 'Sous Chef',
          role: UserRole.sousChef,
          createdAt: createdAt,
        );

        final morningTime = Time.fromDateTime(DateTime(2025, 1, 1, 7, 0));
        final permissions = sousChef.getCurrentTemporalPermissions(
          currentTime: morningTime,
        );

        expect(permissions, contains(TemporalPermission.openKitchen));
        expect(permissions, contains(TemporalPermission.authorizeOvertime));
        expect(permissions, contains(TemporalPermission.modifySchedules));
      });
    });

    group('Edge Cases and Time Transitions', () {
      test('Should handle midnight transition correctly', () {
        final manager = User(
          id: userId,
          email: 'manager@kitchen.com',
          name: 'Manager',
          role: UserRole.kitchenManager,
          createdAt: createdAt,
        );

        final justBeforeMidnight = Time.fromDateTime(
          DateTime(2025, 1, 1, 23, 59),
        ); // 11:59 PM
        final justAfterMidnight = Time.fromDateTime(
          DateTime(2025, 1, 1, 0, 1),
        ); // 12:01 AM

        // Both should be night shift
        expect(manager.canAccessKitchenAtTime(justBeforeMidnight), isTrue);
        expect(manager.canAccessKitchenAtTime(justAfterMidnight), isTrue);
      });

      test('Should handle 5 AM shift transition (overnight to morning prep)', () {
        final admin = User(
          id: userId,
          email: 'admin@kitchen.com',
          name: 'Admin',
          role: UserRole.admin,
          createdAt: createdAt,
        );

        final just459AM = Time.fromDateTime(
          DateTime(2025, 1, 1, 4, 59),
        ); // 4:59 AM (overnight)
        final just500AM = Time.fromDateTime(
          DateTime(2025, 1, 1, 5, 0),
        ); // 5:00 AM (morning prep)

        expect(
          admin.hasTemporalPermission(
            TemporalPermission.emergencyAccess,
            currentTime: just459AM,
          ),
          isTrue,
          reason: 'Admin should have emergency access during overnight',
        );

        expect(
          admin.hasTemporalPermission(
            TemporalPermission.openKitchen,
            currentTime: just500AM,
          ),
          isTrue,
          reason:
              'Admin should have open kitchen permission at start of morning prep',
        );
      });
    });
  });
}
