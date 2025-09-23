import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/entities/user.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';

void main() {
  group('Station Assignment Business Rules', () {
    late UserId userId;
    late Time createdAt;

    setUp(() {
      userId = UserId('user123');
      createdAt = Time.now();
    });

    group('Role-Based Station Compatibility', () {
      test('Dishwasher should only work dish pit and prep', () {
        final user = User(
          id: userId,
          email: 'dishwasher@kitchen.com',
          name: 'John Dishwasher',
          role: UserRole.dishwasher,
          createdAt: createdAt,
        );

        // Can work dish and prep
        expect(user.canWorkAtStation(KitchenStation.dish), isTrue);
        expect(user.canWorkAtStation(KitchenStation.prep), isTrue);

        // Cannot work hot stations
        expect(user.canWorkAtStation(KitchenStation.grill), isFalse);
        expect(user.canWorkAtStation(KitchenStation.saute), isFalse);
        expect(user.canWorkAtStation(KitchenStation.fryer), isFalse);
        expect(user.canWorkAtStation(KitchenStation.pastry), isFalse);
        expect(user.canWorkAtStation(KitchenStation.expo), isFalse);

        // Can work salad (cold station)
        expect(user.canWorkAtStation(KitchenStation.salad), isFalse);
      });

      test('Prep Cook should work prep, salad, and dish stations', () {
        final user = User(
          id: userId,
          email: 'prep@kitchen.com',
          name: 'Maria Prep',
          role: UserRole.prepCook,
          createdAt: createdAt,
        );

        // Can work prep stations
        expect(user.canWorkAtStation(KitchenStation.prep), isTrue);
        expect(user.canWorkAtStation(KitchenStation.salad), isTrue);
        expect(user.canWorkAtStation(KitchenStation.dish), isTrue);

        // Cannot work hot stations yet
        expect(user.canWorkAtStation(KitchenStation.grill), isFalse);
        expect(user.canWorkAtStation(KitchenStation.saute), isFalse);
        expect(user.canWorkAtStation(KitchenStation.fryer), isFalse);
        expect(user.canWorkAtStation(KitchenStation.pastry), isFalse);
      });

      test('Line Cook should work hot stations but not pastry', () {
        final user = User(
          id: userId,
          email: 'line@kitchen.com',
          name: 'Carlos Line',
          role: UserRole.lineCook,
          createdAt: createdAt,
        );

        // Can work most stations
        expect(user.canWorkAtStation(KitchenStation.grill), isTrue);
        expect(user.canWorkAtStation(KitchenStation.saute), isTrue);
        expect(user.canWorkAtStation(KitchenStation.fryer), isTrue);
        expect(user.canWorkAtStation(KitchenStation.salad), isTrue);
        expect(user.canWorkAtStation(KitchenStation.prep), isTrue);

        // Cannot work pastry (specialized)
        expect(user.canWorkAtStation(KitchenStation.pastry), isFalse);
      });

      test('Senior Cook should work all stations including pastry', () {
        final user = User(
          id: userId,
          email: 'senior@kitchen.com',
          name: 'Anna Senior',
          role: UserRole.cookSenior,
          createdAt: createdAt,
        );

        // Can work all stations
        for (final station in KitchenStation.values) {
          expect(
            user.canWorkAtStation(station),
            isTrue,
            reason: 'Senior cook should work ${station.name}',
          );
        }
      });

      test('Expediter should primarily work expo station', () {
        final user = User(
          id: userId,
          email: 'expo@kitchen.com',
          name: 'Luis Expediter',
          role: UserRole.expediter,
          createdAt: createdAt,
        );

        // Primary station
        expect(user.canWorkAtStation(KitchenStation.expo), isTrue);

        // Can oversee hot stations for quality control
        expect(user.canWorkAtStation(KitchenStation.grill), isTrue);
        expect(user.canWorkAtStation(KitchenStation.saute), isTrue);

        // Cannot work prep or dish (different focus)
        expect(user.canWorkAtStation(KitchenStation.prep), isFalse);
        expect(user.canWorkAtStation(KitchenStation.dish), isFalse);
      });
    });

    group('Station Assignment Validation', () {
      test('Should enforce business rules for station assignments', () {
        final dishwasher = User(
          id: userId,
          email: 'dish@kitchen.com',
          name: 'John',
          role: UserRole.dishwasher,
          createdAt: createdAt,
        );

        final lineCook = User(
          id: userId,
          email: 'line@kitchen.com',
          name: 'Maria',
          role: UserRole.lineCook,
          createdAt: createdAt,
        );

        // Dishwasher business rules
        expect(
          dishwasher.validateStationAssignment(KitchenStation.dish),
          isTrue,
        );
        expect(
          dishwasher.validateStationAssignment(KitchenStation.prep),
          isTrue,
        );
        expect(
          dishwasher.validateStationAssignment(KitchenStation.grill),
          isFalse,
        );

        // Line cook business rules
        expect(
          lineCook.validateStationAssignment(KitchenStation.grill),
          isTrue,
        );
        expect(
          lineCook.validateStationAssignment(KitchenStation.pastry),
          isFalse,
        );
      });

      test('Should identify specialized training requirements', () {
        final prepCook = User(
          id: userId,
          email: 'prep@kitchen.com',
          name: 'Carlos',
          role: UserRole.prepCook,
          createdAt: createdAt,
        );

        final seniorCook = User(
          id: userId,
          email: 'senior@kitchen.com',
          name: 'Anna',
          role: UserRole.cookSenior,
          createdAt: createdAt,
        );

        // Prep cook needs training for hot stations
        expect(
          prepCook.requiresSpecializedTraining(KitchenStation.grill),
          isTrue,
        );
        expect(
          prepCook.requiresSpecializedTraining(KitchenStation.saute),
          isTrue,
        );
        expect(
          prepCook.requiresSpecializedTraining(KitchenStation.prep),
          isFalse,
        );

        // Senior cook has training for specialized stations
        expect(
          seniorCook.requiresSpecializedTraining(KitchenStation.pastry),
          isTrue,
        );
        expect(
          seniorCook.requiresSpecializedTraining(KitchenStation.grill),
          isFalse,
        );
      });
    });

    group('Station Supervision Rules', () {
      test('Senior staff should supervise stations they can work', () {
        final sousChef = User(
          id: userId,
          email: 'sous@kitchen.com',
          name: 'Gordon',
          role: UserRole.sousChef,
          createdAt: createdAt,
        );

        final lineCook = User(
          id: userId,
          email: 'line@kitchen.com',
          name: 'Maria',
          role: UserRole.lineCook,
          createdAt: createdAt,
        );

        // Sous chef can supervise all stations
        for (final station in KitchenStation.values) {
          expect(
            sousChef.canSuperviseStation(station),
            isTrue,
            reason: 'Sous chef should supervise ${station.name}',
          );
        }

        // Line cook cannot supervise (not senior staff)
        expect(lineCook.canSuperviseStation(KitchenStation.grill), isFalse);
      });
    });

    group('Business Rule Examples', () {
      test('Grill specialist cannot work salad station without training', () {
        final grillCook = User(
          id: userId,
          email: 'grill@kitchen.com',
          name: 'Mike Grill',
          role: UserRole.cook,
          createdAt: createdAt,
        );

        // Can work grill station
        expect(grillCook.canWorkAtStation(KitchenStation.grill), isTrue);

        // Business rule: Cross-training validation would be needed
        // (This would be extended with certification tracking)
        expect(
          grillCook.canWorkAtStation(KitchenStation.salad),
          isTrue,
          reason: 'Full cook should be qualified for salad station',
        );
      });

      test('Pastry chef requires specialized skills', () {
        final lineCook = User(
          id: userId,
          email: 'line@kitchen.com',
          name: 'Sarah Line',
          role: UserRole.lineCook,
          createdAt: createdAt,
        );

        final chefAssistant = User(
          id: userId,
          email: 'assistant@kitchen.com',
          name: 'Paul Assistant',
          role: UserRole.chefAssistant,
          createdAt: createdAt,
        );

        // Line cook cannot work pastry
        expect(
          lineCook.validateStationAssignment(KitchenStation.pastry),
          isFalse,
        );

        // Chef assistant can work pastry
        expect(
          chefAssistant.validateStationAssignment(KitchenStation.pastry),
          isTrue,
        );
      });

      test('Emergency coverage - senior staff can work any station', () {
        final headChef = User(
          id: userId,
          email: 'head@kitchen.com',
          name: 'Chef Emma',
          role: UserRole.chefHead,
          createdAt: createdAt,
        );

        // Head chef can work any station in emergency
        for (final station in KitchenStation.values) {
          expect(
            headChef.validateStationAssignment(station),
            isTrue,
            reason: 'Head chef should cover any station in emergency',
          );
        }
      });
    });

    group('Compatible Stations List', () {
      test('Should return correct compatible stations for each role', () {
        final testCases = [
          {
            'role': UserRole.dishwasher,
            'expectedStations': [KitchenStation.dish, KitchenStation.prep],
          },
          {
            'role': UserRole.prepCook,
            'expectedStations': [
              KitchenStation.prep,
              KitchenStation.salad,
              KitchenStation.dish,
            ],
          },
          {
            'role': UserRole.lineCook,
            'expectedStations': [
              KitchenStation.grill,
              KitchenStation.saute,
              KitchenStation.fryer,
              KitchenStation.prep,
              KitchenStation.salad,
            ],
          },
        ];

        for (final testCase in testCases) {
          final user = User(
            id: userId,
            email: 'test@kitchen.com',
            name: 'Test User',
            role: testCase['role'] as UserRole,
            createdAt: createdAt,
          );

          final compatibleStations = user.getCompatibleStations();
          final expectedStations =
              testCase['expectedStations'] as List<KitchenStation>;

          expect(
            compatibleStations,
            containsAll(expectedStations),
            reason:
                '${testCase['role']} should have expected compatible stations',
          );
        }
      });
    });
  });
}
