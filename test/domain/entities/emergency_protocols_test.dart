import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/entities/user.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';

void main() {
  group('User - Emergency Protocols', () {
    late User dishwasher;
    late User lineCook;
    late User sousChef;
    late User headChef;
    late User kitchenManager;

    setUp(() {
      dishwasher = User(
        id: UserId.generate(),
        name: 'Test Dishwasher',
        email: 'dishwasher@test.com',
        role: UserRole.dishwasher,
        createdAt: Time.now(),
        isActive: true,
      );

      lineCook = User(
        id: UserId.generate(),
        name: 'Test Line Cook',
        email: 'linecook@test.com',
        role: UserRole.lineCook,
        createdAt: Time.now(),
        isActive: true,
      );

      sousChef = User(
        id: UserId.generate(),
        name: 'Test Sous Chef',
        email: 'sous@test.com',
        role: UserRole.sousChef,
        createdAt: Time.now(),
        isActive: true,
      );

      headChef = User(
        id: UserId.generate(),
        name: 'Test Head Chef',
        email: 'head@test.com',
        role: UserRole.chefHead,
        createdAt: Time.now(),
        isActive: true,
      );

      kitchenManager = User(
        id: UserId.generate(),
        name: 'Test Kitchen Manager',
        email: 'manager@test.com',
        role: UserRole.kitchenManager,
        createdAt: Time.now(),
        isActive: true,
      );
    });

    group('canInitiateEmergencyProtocol', () {
      test('should allow all kitchen staff to initiate fire emergency', () {
        expect(
          dishwasher.canInitiateEmergencyProtocol(EmergencyType.fire),
          true,
        );
        expect(lineCook.canInitiateEmergencyProtocol(EmergencyType.fire), true);
        expect(sousChef.canInitiateEmergencyProtocol(EmergencyType.fire), true);
        expect(headChef.canInitiateEmergencyProtocol(EmergencyType.fire), true);
      });

      test('should allow any staff to initiate medical emergency', () {
        expect(
          dishwasher.canInitiateEmergencyProtocol(EmergencyType.medical),
          true,
        );
        expect(
          lineCook.canInitiateEmergencyProtocol(EmergencyType.medical),
          true,
        );
        expect(
          sousChef.canInitiateEmergencyProtocol(EmergencyType.medical),
          true,
        );
      });

      test('should allow food handlers to initiate food safety emergency', () {
        expect(
          dishwasher.canInitiateEmergencyProtocol(EmergencyType.foodSafety),
          false,
        );
        expect(
          lineCook.canInitiateEmergencyProtocol(EmergencyType.foodSafety),
          true,
        );
        expect(
          sousChef.canInitiateEmergencyProtocol(EmergencyType.foodSafety),
          true,
        );
      });

      test('should allow management to initiate security emergency', () {
        expect(
          dishwasher.canInitiateEmergencyProtocol(EmergencyType.security),
          false,
        );
        expect(
          lineCook.canInitiateEmergencyProtocol(EmergencyType.security),
          false,
        );
        expect(
          sousChef.canInitiateEmergencyProtocol(EmergencyType.security),
          true,
        );
        expect(
          kitchenManager.canInitiateEmergencyProtocol(EmergencyType.security),
          true,
        );
      });

      test('should allow management to initiate power outage emergency', () {
        expect(
          dishwasher.canInitiateEmergencyProtocol(EmergencyType.powerOutage),
          false,
        );
        expect(
          lineCook.canInitiateEmergencyProtocol(EmergencyType.powerOutage),
          false,
        );
        expect(
          sousChef.canInitiateEmergencyProtocol(EmergencyType.powerOutage),
          true,
        );
        expect(
          kitchenManager.canInitiateEmergencyProtocol(
            EmergencyType.powerOutage,
          ),
          true,
        );
      });
    });

    group('canOverrideDuringEmergency', () {
      test(
        'should allow senior staff to override during life-safety emergencies',
        () {
          // Fire emergency - assistant chef and above can override
          expect(
            dishwasher.canOverrideDuringEmergency(EmergencyType.fire),
            false,
          );
          expect(
            lineCook.canOverrideDuringEmergency(EmergencyType.fire),
            false,
          );
          expect(sousChef.canOverrideDuringEmergency(EmergencyType.fire), true);
          expect(headChef.canOverrideDuringEmergency(EmergencyType.fire), true);
        },
      );

      test(
        'should allow food safety authority to override during food safety emergency',
        () {
          expect(
            dishwasher.canOverrideDuringEmergency(EmergencyType.foodSafety),
            false,
          );
          expect(
            lineCook.canOverrideDuringEmergency(EmergencyType.foodSafety),
            false,
          );
          expect(
            sousChef.canOverrideDuringEmergency(EmergencyType.foodSafety),
            true,
          );
          expect(
            headChef.canOverrideDuringEmergency(EmergencyType.foodSafety),
            true,
          );
        },
      );

      test(
        'should allow management to override during operational emergencies',
        () {
          expect(
            dishwasher.canOverrideDuringEmergency(
              EmergencyType.equipmentFailure,
            ),
            false,
          );
          expect(
            lineCook.canOverrideDuringEmergency(EmergencyType.equipmentFailure),
            false,
          );
          expect(
            sousChef.canOverrideDuringEmergency(EmergencyType.equipmentFailure),
            true,
          );
          expect(
            kitchenManager.canOverrideDuringEmergency(
              EmergencyType.equipmentFailure,
            ),
            true,
          );
        },
      );

      test('should require senior management for security override', () {
        expect(
          dishwasher.canOverrideDuringEmergency(EmergencyType.security),
          false,
        );
        expect(
          sousChef.canOverrideDuringEmergency(EmergencyType.security),
          false,
        );
        expect(
          kitchenManager.canOverrideDuringEmergency(EmergencyType.security),
          true,
        );
      });
    });

    group('canAuthorizeEvacuation', () {
      test('should allow assistant chef and above to authorize evacuation', () {
        expect(dishwasher.canAuthorizeEvacuation(), false);
        expect(lineCook.canAuthorizeEvacuation(), false);
        expect(sousChef.canAuthorizeEvacuation(), true);
        expect(headChef.canAuthorizeEvacuation(), true);
        expect(kitchenManager.canAuthorizeEvacuation(), true);
      });
    });

    group('canCoordinateEmergencyResponse', () {
      test(
        'should allow sous chef and above to coordinate life-safety emergencies',
        () {
          expect(
            dishwasher.canCoordinateEmergencyResponse(EmergencyType.fire),
            false,
          );
          expect(
            lineCook.canCoordinateEmergencyResponse(EmergencyType.fire),
            false,
          );
          expect(
            sousChef.canCoordinateEmergencyResponse(EmergencyType.fire),
            true,
          );
          expect(
            headChef.canCoordinateEmergencyResponse(EmergencyType.fire),
            true,
          );
        },
      );

      test(
        'should allow food safety authority to coordinate food safety emergencies',
        () {
          expect(
            dishwasher.canCoordinateEmergencyResponse(EmergencyType.foodSafety),
            false,
          );
          expect(
            lineCook.canCoordinateEmergencyResponse(EmergencyType.foodSafety),
            false,
          );
          expect(
            sousChef.canCoordinateEmergencyResponse(EmergencyType.foodSafety),
            true,
          );
          expect(
            headChef.canCoordinateEmergencyResponse(EmergencyType.foodSafety),
            true,
          );
        },
      );

      test(
        'should allow kitchen manager and above to coordinate operational emergencies',
        () {
          expect(
            sousChef.canCoordinateEmergencyResponse(
              EmergencyType.equipmentFailure,
            ),
            false,
          );
          expect(
            headChef.canCoordinateEmergencyResponse(
              EmergencyType.equipmentFailure,
            ),
            false,
          );
          expect(
            kitchenManager.canCoordinateEmergencyResponse(
              EmergencyType.equipmentFailure,
            ),
            true,
          );
        },
      );

      test(
        'should require head chef with hazard training for chemical emergencies',
        () {
          expect(
            sousChef.canCoordinateEmergencyResponse(EmergencyType.chemical),
            false,
          );
          expect(
            headChef.canCoordinateEmergencyResponse(EmergencyType.chemical),
            true,
          );
          expect(
            kitchenManager.canCoordinateEmergencyResponse(
              EmergencyType.chemical,
            ),
            true,
          );
        },
      );
    });

    group('getEmergencyEscalationChain', () {
      test(
        'should provide correct escalation chain for life-safety emergencies',
        () {
          final escalationChain = dishwasher.getEmergencyEscalationChain(
            EmergencyType.fire,
          );

          expect(escalationChain, [
            UserRole.chefAssistant,
            UserRole.sousChef,
            UserRole.chefHead,
            UserRole.kitchenManager,
            UserRole.generalManager,
          ]);
        },
      );

      test(
        'should provide correct escalation chain for food safety emergencies',
        () {
          final escalationChain = lineCook.getEmergencyEscalationChain(
            EmergencyType.foodSafety,
          );

          expect(escalationChain, [
            UserRole.sousChef,
            UserRole.chefHead,
            UserRole.kitchenManager,
            UserRole.generalManager,
          ]);
        },
      );

      test(
        'should provide correct escalation chain for security emergencies',
        () {
          final escalationChain = sousChef.getEmergencyEscalationChain(
            EmergencyType.security,
          );

          expect(escalationChain, [
            UserRole.kitchenManager,
            UserRole.generalManager,
          ]);
        },
      );

      test(
        'should provide correct escalation chain for chemical emergencies',
        () {
          final escalationChain = headChef.getEmergencyEscalationChain(
            EmergencyType.chemical,
          );

          expect(escalationChain, [
            UserRole.chefHead,
            UserRole.kitchenManager,
            UserRole.generalManager,
          ]);
        },
      );

      test(
        'should provide correct escalation chain for equipment failures',
        () {
          final escalationChain = lineCook.getEmergencyEscalationChain(
            EmergencyType.equipmentFailure,
          );

          expect(escalationChain, [
            UserRole.chefAssistant,
            UserRole.sousChef,
            UserRole.kitchenManager,
            UserRole.generalManager,
          ]);
        },
      );

      test('should provide correct escalation chain for power outages', () {
        final escalationChain = sousChef.getEmergencyEscalationChain(
          EmergencyType.powerOutage,
        );

        expect(escalationChain, [
          UserRole.kitchenManager,
          UserRole.generalManager,
        ]);
      });
    });

    group('emergency protocol business rules', () {
      test('should validate fire emergency protocols', () {
        // Any kitchen staff can initiate
        expect(
          dishwasher.canInitiateEmergencyProtocol(EmergencyType.fire),
          true,
        );

        // Senior staff can override
        expect(sousChef.canOverrideDuringEmergency(EmergencyType.fire), true);

        // Assistant chef can authorize evacuation
        expect(sousChef.canAuthorizeEvacuation(), true);

        // Sous chef can coordinate response
        expect(
          sousChef.canCoordinateEmergencyResponse(EmergencyType.fire),
          true,
        );
      });

      test('should validate food safety emergency protocols', () {
        // Only food handlers can initiate
        expect(
          dishwasher.canInitiateEmergencyProtocol(EmergencyType.foodSafety),
          false,
        );
        expect(
          lineCook.canInitiateEmergencyProtocol(EmergencyType.foodSafety),
          true,
        );

        // Food safety authority can override
        expect(
          sousChef.canOverrideDuringEmergency(EmergencyType.foodSafety),
          true,
        );

        // Food safety authority can coordinate
        expect(
          sousChef.canCoordinateEmergencyResponse(EmergencyType.foodSafety),
          true,
        );
      });

      test('should validate security emergency protocols', () {
        // Only management can initiate
        expect(
          lineCook.canInitiateEmergencyProtocol(EmergencyType.security),
          false,
        );
        expect(
          sousChef.canInitiateEmergencyProtocol(EmergencyType.security),
          true,
        );

        // Senior management can override
        expect(
          sousChef.canOverrideDuringEmergency(EmergencyType.security),
          false,
        );
        expect(
          kitchenManager.canOverrideDuringEmergency(EmergencyType.security),
          true,
        );
      });

      test(
        'should validate comprehensive emergency authority for kitchen manager',
        () {
          // Can initiate all relevant emergencies
          expect(
            kitchenManager.canInitiateEmergencyProtocol(EmergencyType.fire),
            true,
          );
          expect(
            kitchenManager.canInitiateEmergencyProtocol(
              EmergencyType.foodSafety,
            ),
            true,
          );
          expect(
            kitchenManager.canInitiateEmergencyProtocol(EmergencyType.security),
            true,
          );
          expect(
            kitchenManager.canInitiateEmergencyProtocol(
              EmergencyType.equipmentFailure,
            ),
            true,
          );

          // Can override during emergencies
          expect(
            kitchenManager.canOverrideDuringEmergency(EmergencyType.fire),
            true,
          );
          expect(
            kitchenManager.canOverrideDuringEmergency(EmergencyType.foodSafety),
            true,
          );
          expect(
            kitchenManager.canOverrideDuringEmergency(EmergencyType.security),
            true,
          );

          // Can authorize evacuation
          expect(kitchenManager.canAuthorizeEvacuation(), true);

          // Can coordinate most emergency responses
          expect(
            kitchenManager.canCoordinateEmergencyResponse(EmergencyType.fire),
            true,
          );
          expect(
            kitchenManager.canCoordinateEmergencyResponse(
              EmergencyType.foodSafety,
            ),
            true,
          );
          expect(
            kitchenManager.canCoordinateEmergencyResponse(
              EmergencyType.equipmentFailure,
            ),
            true,
          );
        },
      );
    });
  });
}
