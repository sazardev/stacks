import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/entities/user.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';

void main() {
  group('Command Hierarchy and Authority Level Management', () {
    late UserId userId;
    late Time createdAt;

    setUp(() {
      userId = UserId('user123');
      createdAt = Time.now();
    });

    group('Authority Levels', () {
      test('Should assign correct authority levels to each role', () {
        final testCases = [
          {'role': UserRole.dishwasher, 'expectedLevel': AuthorityLevel.entry},
          {'role': UserRole.prepCook, 'expectedLevel': AuthorityLevel.entry},
          {'role': UserRole.lineCook, 'expectedLevel': AuthorityLevel.basic},
          {'role': UserRole.cook, 'expectedLevel': AuthorityLevel.experienced},
          {'role': UserRole.cookSenior, 'expectedLevel': AuthorityLevel.senior},
          {
            'role': UserRole.chefAssistant,
            'expectedLevel': AuthorityLevel.senior,
          },
          {
            'role': UserRole.sousChef,
            'expectedLevel': AuthorityLevel.management,
          },
          {
            'role': UserRole.chefHead,
            'expectedLevel': AuthorityLevel.management,
          },
          {
            'role': UserRole.kitchenManager,
            'expectedLevel': AuthorityLevel.management,
          },
          {
            'role': UserRole.generalManager,
            'expectedLevel': AuthorityLevel.executive,
          },
          {'role': UserRole.admin, 'expectedLevel': AuthorityLevel.system},
          {'role': UserRole.expediter, 'expectedLevel': AuthorityLevel.senior},
        ];

        for (final testCase in testCases) {
          final user = User(
            id: UserId('test${testCase['role'].toString()}'),
            email: 'test@kitchen.com',
            name: 'Test User',
            role: testCase['role'] as UserRole,
            createdAt: createdAt,
          );

          expect(
            user.getAuthorityLevel(),
            equals(testCase['expectedLevel']),
            reason:
                '${testCase['role']} should have ${testCase['expectedLevel']} authority level',
          );
        }
      });
    });

    group('User Override Capabilities', () {
      test('Sous chef should be able to override line cook decisions', () {
        final sousChef = User(
          id: UserId('sous1'),
          email: 'sous@kitchen.com',
          name: 'Sous Chef',
          role: UserRole.sousChef,
          createdAt: createdAt,
        );

        final lineCook = User(
          id: UserId('line1'),
          email: 'line@kitchen.com',
          name: 'Line Cook',
          role: UserRole.lineCook,
          createdAt: createdAt,
        );

        expect(
          sousChef.canOverrideUser(lineCook),
          isTrue,
          reason: 'Sous chef (management) should override line cook (basic)',
        );
        expect(
          lineCook.canOverrideUser(sousChef),
          isFalse,
          reason: 'Line cook should not override sous chef',
        );
      });

      test('Senior cook should override regular cook but not sous chef', () {
        final seniorCook = User(
          id: userId,
          email: 'senior@kitchen.com',
          name: 'Senior Cook',
          role: UserRole.cookSenior,
          createdAt: createdAt,
        );

        final cook = User(
          id: UserId('cook1'),
          email: 'cook@kitchen.com',
          name: 'Cook',
          role: UserRole.cook,
          createdAt: createdAt,
        );

        final sousChef = User(
          id: UserId('sous1'),
          email: 'sous@kitchen.com',
          name: 'Sous Chef',
          role: UserRole.sousChef,
          createdAt: createdAt,
        );

        expect(
          seniorCook.canOverrideUser(cook),
          isTrue,
          reason: 'Senior cook should override regular cook',
        );
        expect(
          seniorCook.canOverrideUser(sousChef),
          isFalse,
          reason: 'Senior cook should not override sous chef',
        );
      });

      test('Admin should have system-level authority', () {
        final admin = User(
          id: userId,
          email: 'admin@kitchen.com',
          name: 'Admin',
          role: UserRole.admin,
          createdAt: createdAt,
        );

        final headChef = User(
          id: UserId('head1'),
          email: 'head@kitchen.com',
          name: 'Head Chef',
          role: UserRole.chefHead,
          createdAt: createdAt,
        );

        expect(admin.getAuthorityLevel(), equals(AuthorityLevel.system));
        expect(
          admin.canOverrideUser(headChef),
          isTrue,
          reason: 'Admin (system) should override head chef (management)',
        );
      });
    });

    group('Command Type Override Rules', () {
      test('Line cook should override order preparation', () {
        final lineCook = User(
          id: userId,
          email: 'line@kitchen.com',
          name: 'Line Cook',
          role: UserRole.lineCook,
          createdAt: createdAt,
        );

        final prepCook = User(
          id: UserId('prep1'),
          email: 'prep@kitchen.com',
          name: 'Prep Cook',
          role: UserRole.prepCook,
          createdAt: createdAt,
        );

        expect(
          lineCook.canOverrideCommand(
            CommandType.orderPreparation,
            originalCommander: prepCook,
          ),
          isTrue,
          reason: 'Line cook should override prep cook on order preparation',
        );
      });

      test('Senior staff should manage station assignments', () {
        final seniorCook = User(
          id: userId,
          email: 'senior@kitchen.com',
          name: 'Senior Cook',
          role: UserRole.cookSenior,
          createdAt: createdAt,
        );

        final cook = User(
          id: UserId('cook1'),
          email: 'cook@kitchen.com',
          name: 'Cook',
          role: UserRole.cook,
          createdAt: createdAt,
        );

        expect(
          seniorCook.canOverrideCommand(
            CommandType.stationAssignment,
            originalCommander: cook,
          ),
          isTrue,
          reason: 'Senior cook should manage station assignments',
        );

        expect(
          cook.canOverrideCommand(CommandType.stationAssignment),
          isFalse,
          reason: 'Regular cook should not manage station assignments',
        );
      });

      test('Food safety can be escalated by experienced staff', () {
        final cook = User(
          id: userId,
          email: 'cook@kitchen.com',
          name: 'Cook',
          role: UserRole.cook,
          createdAt: createdAt,
        );

        final lineCook = User(
          id: UserId('line1'),
          email: 'line@kitchen.com',
          name: 'Line Cook',
          role: UserRole.lineCook,
          createdAt: createdAt,
        );

        expect(
          cook.canOverrideCommand(
            CommandType.foodSafety,
            originalCommander: lineCook,
          ),
          isTrue,
          reason: 'Cook should override food safety decisions',
        );

        expect(
          lineCook.canOverrideCommand(CommandType.foodSafety),
          isFalse,
          reason: 'Line cook should not have food safety override authority',
        );
      });

      test('Only management should change schedules', () {
        final sousChef = User(
          id: userId,
          email: 'sous@kitchen.com',
          name: 'Sous Chef',
          role: UserRole.sousChef,
          createdAt: createdAt,
        );

        final seniorCook = User(
          id: UserId('senior1'),
          email: 'senior@kitchen.com',
          name: 'Senior Cook',
          role: UserRole.cookSenior,
          createdAt: createdAt,
        );

        expect(
          sousChef.canOverrideCommand(CommandType.scheduleChange),
          isTrue,
          reason: 'Sous chef (management) should change schedules',
        );

        expect(
          seniorCook.canOverrideCommand(CommandType.scheduleChange),
          isFalse,
          reason: 'Senior cook should not change schedules',
        );
      });

      test('Only admin should change system configuration', () {
        final admin = User(
          id: userId,
          email: 'admin@kitchen.com',
          name: 'Admin',
          role: UserRole.admin,
          createdAt: createdAt,
        );

        final headChef = User(
          id: UserId('head1'),
          email: 'head@kitchen.com',
          name: 'Head Chef',
          role: UserRole.chefHead,
          createdAt: createdAt,
        );

        expect(
          admin.canOverrideCommand(CommandType.systemConfiguration),
          isTrue,
          reason: 'Admin should change system configuration',
        );

        expect(
          headChef.canOverrideCommand(CommandType.systemConfiguration),
          isFalse,
          reason: 'Head chef should not change system configuration',
        );
      });
    });

    group('Command Override Validation', () {
      test('Should validate legitimate override attempts', () {
        final sousChef = User(
          id: userId,
          email: 'sous@kitchen.com',
          name: 'Sous Chef',
          role: UserRole.sousChef,
          createdAt: createdAt,
        );

        final cook = User(
          id: UserId('cook1'),
          email: 'cook@kitchen.com',
          name: 'Cook',
          role: UserRole.cook,
          createdAt: createdAt,
        );

        expect(
          sousChef.validateCommandOverride(
            commandType: CommandType.stationAssignment,
            originalCommander: cook,
            reason: 'Better allocation for dinner rush',
          ),
          isTrue,
          reason:
              'Sous chef should be able to override cook on station assignment',
        );
      });

      test('Should reject invalid override attempts', () {
        final lineCook = User(
          id: userId,
          email: 'line@kitchen.com',
          name: 'Line Cook',
          role: UserRole.lineCook,
          createdAt: createdAt,
        );

        final seniorCook = User(
          id: UserId('senior1'),
          email: 'senior@kitchen.com',
          name: 'Senior Cook',
          role: UserRole.cookSenior,
          createdAt: createdAt,
        );

        expect(
          lineCook.validateCommandOverride(
            commandType: CommandType.scheduleChange,
            originalCommander: seniorCook,
            reason: 'Want different schedule',
          ),
          isFalse,
          reason: 'Line cook should not override senior cook on schedules',
        );
      });

      test('Food safety overrides should always be allowed for safety', () {
        final cook = User(
          id: userId,
          email: 'cook@kitchen.com',
          name: 'Cook',
          role: UserRole.cook,
          createdAt: createdAt,
        );

        final lineCook = User(
          id: UserId('line1'),
          email: 'line@kitchen.com',
          name: 'Line Cook',
          role: UserRole.lineCook,
          createdAt: createdAt,
        );

        expect(
          cook.validateCommandOverride(
            commandType: CommandType.foodSafety,
            originalCommander: lineCook,
            reason: 'Temperature violation observed',
          ),
          isTrue,
          reason: 'Food safety should always be escalatable',
        );
      });
    });

    group('Chain of Command', () {
      test('Dishwasher should have correct chain of command', () {
        final dishwasher = User(
          id: userId,
          email: 'dish@kitchen.com',
          name: 'Dishwasher',
          role: UserRole.dishwasher,
          createdAt: createdAt,
        );

        final chain = dishwasher.getChainOfCommand();
        final expectedChain = [
          UserRole.cookSenior,
          UserRole.sousChef,
          UserRole.chefHead,
        ];

        expect(
          chain,
          equals(expectedChain),
          reason: 'Dishwasher should report through senior cook to management',
        );
      });

      test('Line cook should have appropriate reporting structure', () {
        final lineCook = User(
          id: userId,
          email: 'line@kitchen.com',
          name: 'Line Cook',
          role: UserRole.lineCook,
          createdAt: createdAt,
        );

        final chain = lineCook.getChainOfCommand();
        final expectedChain = [
          UserRole.cook,
          UserRole.cookSenior,
          UserRole.sousChef,
          UserRole.chefHead,
        ];

        expect(
          chain,
          equals(expectedChain),
          reason: 'Line cook should report through cook hierarchy',
        );
      });

      test('Sous chef should report directly to head chef', () {
        final sousChef = User(
          id: userId,
          email: 'sous@kitchen.com',
          name: 'Sous Chef',
          role: UserRole.sousChef,
          createdAt: createdAt,
        );

        final chain = sousChef.getChainOfCommand();
        expect(
          chain,
          equals([UserRole.chefHead]),
          reason: 'Sous chef should report directly to head chef',
        );
      });

      test('Should identify direct supervisory relationships', () {
        final seniorCook = User(
          id: userId,
          email: 'senior@kitchen.com',
          name: 'Senior Cook',
          role: UserRole.cookSenior,
          createdAt: createdAt,
        );

        final cook = User(
          id: UserId('cook1'),
          email: 'cook@kitchen.com',
          name: 'Cook',
          role: UserRole.cook,
          createdAt: createdAt,
        );

        expect(
          seniorCook.isInChainOfCommandAbove(cook),
          isTrue,
          reason: 'Senior cook should be in chain above cook',
        );

        expect(
          seniorCook.getImmediateSupervisor(),
          equals(UserRole.sousChef),
          reason: 'Senior cook should report to sous chef',
        );
      });
    });

    group('Authority Delegation', () {
      test('Manager should delegate appropriate authority', () {
        final sousChef = User(
          id: userId,
          email: 'sous@kitchen.com',
          name: 'Sous Chef',
          role: UserRole.sousChef,
          createdAt: createdAt,
        );

        final seniorCook = User(
          id: UserId('senior1'),
          email: 'senior@kitchen.com',
          name: 'Senior Cook',
          role: UserRole.cookSenior,
          createdAt: createdAt,
        );

        expect(
          sousChef.canDelegateAuthority(
            seniorCook,
            CommandType.stationAssignment,
          ),
          isTrue,
          reason: 'Sous chef should delegate station assignment to senior cook',
        );
      });

      test('Should not delegate outside chain of command', () {
        final sousChef = User(
          id: userId,
          email: 'sous@kitchen.com',
          name: 'Sous Chef',
          role: UserRole.sousChef,
          createdAt: createdAt,
        );

        final expediter = User(
          id: UserId('expo1'),
          email: 'expo@kitchen.com',
          name: 'Expediter',
          role: UserRole.expediter,
          createdAt: createdAt,
        );

        expect(
          sousChef.canDelegateAuthority(
            expediter,
            CommandType.stationAssignment,
          ),
          isFalse,
          reason: 'Should not delegate outside direct chain of command',
        );
      });

      test('Should not delegate system configuration', () {
        final admin = User(
          id: userId,
          email: 'admin@kitchen.com',
          name: 'Admin',
          role: UserRole.admin,
          createdAt: createdAt,
        );

        final generalManager = User(
          id: UserId('gm1'),
          email: 'gm@kitchen.com',
          name: 'General Manager',
          role: UserRole.generalManager,
          createdAt: createdAt,
        );

        expect(
          admin.canDelegateAuthority(
            generalManager,
            CommandType.systemConfiguration,
          ),
          isFalse,
          reason: 'System configuration should never be delegated',
        );
      });
    });

    group('Emergency Escalation', () {
      test('Food safety should always be escalatable', () {
        final dishwasher = User(
          id: userId,
          email: 'dish@kitchen.com',
          name: 'Dishwasher',
          role: UserRole.dishwasher,
          createdAt: createdAt,
        );

        expect(
          dishwasher.canEmergencyEscalate(CommandType.foodSafety),
          isTrue,
          reason: 'Food safety should be escalatable by anyone',
        );
      });

      test('Emergency procedures should be escalatable by senior staff', () {
        final seniorCook = User(
          id: userId,
          email: 'senior@kitchen.com',
          name: 'Senior Cook',
          role: UserRole.cookSenior,
          createdAt: createdAt,
        );

        final lineCook = User(
          id: UserId('line1'),
          email: 'line@kitchen.com',
          name: 'Line Cook',
          role: UserRole.lineCook,
          createdAt: createdAt,
        );

        expect(
          seniorCook.canEmergencyEscalate(CommandType.emergencyProcedure),
          isTrue,
          reason: 'Senior staff should escalate emergency procedures',
        );

        expect(
          lineCook.canEmergencyEscalate(CommandType.emergencyProcedure),
          isFalse,
          reason: 'Junior staff should not escalate emergency procedures',
        );
      });
    });

    group('Overridable Commands List', () {
      test(
        'Should return correct overridable commands for each authority level',
        () {
          final lineCook = User(
            id: userId,
            email: 'line@kitchen.com',
            name: 'Line Cook',
            role: UserRole.lineCook,
            createdAt: createdAt,
          );

          final overridableCommands = lineCook.getOverridableCommands();

          expect(
            overridableCommands,
            contains(CommandType.orderPreparation),
            reason: 'Line cook should override order preparation',
          );
          expect(
            overridableCommands,
            isNot(contains(CommandType.stationAssignment)),
            reason: 'Line cook should not override station assignment',
          );
          expect(
            overridableCommands,
            isNot(contains(CommandType.systemConfiguration)),
            reason: 'Line cook should not override system configuration',
          );
        },
      );

      test('Management should have comprehensive override capabilities', () {
        final sousChef = User(
          id: userId,
          email: 'sous@kitchen.com',
          name: 'Sous Chef',
          role: UserRole.sousChef,
          createdAt: createdAt,
        );

        final overridableCommands = sousChef.getOverridableCommands();

        expect(
          overridableCommands,
          contains(CommandType.scheduleChange),
          reason: 'Management should override schedule changes',
        );
        expect(
          overridableCommands,
          contains(CommandType.stationAssignment),
          reason: 'Management should override station assignments',
        );
        expect(
          overridableCommands,
          isNot(contains(CommandType.systemConfiguration)),
          reason: 'Management should not override system configuration',
        );
      });
    });
  });
}
