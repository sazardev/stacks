import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/value_objects/priority.dart';
import 'package:stacks/domain/exceptions/domain_exception.dart';

void main() {
  group('Priority', () {
    group('creation', () {
      test('should create Priority with valid level', () {
        // Arrange & Act
        final priority = Priority(Priority.high);

        // Assert
        expect(priority.level, equals(Priority.high));
        expect(priority.name, equals('High'));
      });

      test('should create Priority with low level', () {
        // Arrange & Act
        final priority = Priority(Priority.low);

        // Assert
        expect(priority.level, equals(Priority.low));
        expect(priority.name, equals('Low'));
      });

      test('should create Priority with medium level', () {
        // Arrange & Act
        final priority = Priority(Priority.medium);

        // Assert
        expect(priority.level, equals(Priority.medium));
        expect(priority.name, equals('Medium'));
      });

      test('should create Priority with urgent level', () {
        // Arrange & Act
        final priority = Priority(Priority.urgent);

        // Assert
        expect(priority.level, equals(Priority.urgent));
        expect(priority.name, equals('Urgent'));
      });

      test('should create Priority with critical level', () {
        // Arrange & Act
        final priority = Priority(Priority.critical);

        // Assert
        expect(priority.level, equals(Priority.critical));
        expect(priority.name, equals('Critical'));
      });

      test('should throw DomainException for invalid level', () {
        // Arrange & Act & Assert
        expect(() => Priority(0), throwsA(isA<DomainException>()));
      });

      test('should throw DomainException for level above maximum', () {
        // Arrange & Act & Assert
        expect(() => Priority(6), throwsA(isA<DomainException>()));
      });

      test('should throw DomainException for negative level', () {
        // Arrange & Act & Assert
        expect(() => Priority(-1), throwsA(isA<DomainException>()));
      });
    });

    group('factory constructors', () {
      test('should create low priority', () {
        // Arrange & Act
        final priority = Priority.createLow();

        // Assert
        expect(priority.level, equals(Priority.low));
        expect(priority.name, equals('Low'));
      });

      test('should create medium priority', () {
        // Arrange & Act
        final priority = Priority.createMedium();

        // Assert
        expect(priority.level, equals(Priority.medium));
        expect(priority.name, equals('Medium'));
      });

      test('should create high priority', () {
        // Arrange & Act
        final priority = Priority.createHigh();

        // Assert
        expect(priority.level, equals(Priority.high));
        expect(priority.name, equals('High'));
      });

      test('should create urgent priority', () {
        // Arrange & Act
        final priority = Priority.createUrgent();

        // Assert
        expect(priority.level, equals(Priority.urgent));
        expect(priority.name, equals('Urgent'));
      });

      test('should create critical priority', () {
        // Arrange & Act
        final priority = Priority.createCritical();

        // Assert
        expect(priority.level, equals(Priority.critical));
        expect(priority.name, equals('Critical'));
      });
    });

    group('business rules', () {
      test(
        'should determine if priority is high priority (high, urgent, critical)',
        () {
          // Arrange
          final lowPriority = Priority.createLow();
          final mediumPriority = Priority.createMedium();
          final highPriority = Priority.createHigh();
          final urgentPriority = Priority.createUrgent();
          final criticalPriority = Priority.createCritical();

          // Act & Assert
          expect(lowPriority.isHighPriority, isFalse);
          expect(mediumPriority.isHighPriority, isFalse);
          expect(highPriority.isHighPriority, isTrue);
          expect(urgentPriority.isHighPriority, isTrue);
          expect(criticalPriority.isHighPriority, isTrue);
        },
      );

      test(
        'should determine if priority requires immediate attention (urgent, critical)',
        () {
          // Arrange
          final lowPriority = Priority.createLow();
          final mediumPriority = Priority.createMedium();
          final highPriority = Priority.createHigh();
          final urgentPriority = Priority.createUrgent();
          final criticalPriority = Priority.createCritical();

          // Act & Assert
          expect(lowPriority.requiresImmediateAttention, isFalse);
          expect(mediumPriority.requiresImmediateAttention, isFalse);
          expect(highPriority.requiresImmediateAttention, isFalse);
          expect(urgentPriority.requiresImmediateAttention, isTrue);
          expect(criticalPriority.requiresImmediateAttention, isTrue);
        },
      );

      test('should calculate escalation timeout based on priority level', () {
        // Arrange
        final lowPriority = Priority.createLow();
        final mediumPriority = Priority.createMedium();
        final highPriority = Priority.createHigh();
        final urgentPriority = Priority.createUrgent();
        final criticalPriority = Priority.createCritical();

        // Act & Assert
        expect(lowPriority.escalationTimeoutMinutes, equals(60));
        expect(mediumPriority.escalationTimeoutMinutes, equals(30));
        expect(highPriority.escalationTimeoutMinutes, equals(15));
        expect(urgentPriority.escalationTimeoutMinutes, equals(5));
        expect(criticalPriority.escalationTimeoutMinutes, equals(2));
      });

      test('should get max preparation time based on priority', () {
        // Arrange
        final lowPriority = Priority.createLow();
        final mediumPriority = Priority.createMedium();
        final highPriority = Priority.createHigh();
        final urgentPriority = Priority.createUrgent();
        final criticalPriority = Priority.createCritical();

        // Act & Assert
        expect(lowPriority.maxPreparationTimeMinutes, equals(45));
        expect(mediumPriority.maxPreparationTimeMinutes, equals(30));
        expect(highPriority.maxPreparationTimeMinutes, equals(20));
        expect(urgentPriority.maxPreparationTimeMinutes, equals(10));
        expect(criticalPriority.maxPreparationTimeMinutes, equals(5));
      });
    });

    group('comparison', () {
      test('should compare priorities correctly', () {
        // Arrange
        final lowPriority = Priority.createLow();
        final mediumPriority = Priority.createMedium();
        final highPriority = Priority.createHigh();
        final urgentPriority = Priority.createUrgent();
        final criticalPriority = Priority.createCritical();

        // Act & Assert
        expect(criticalPriority.isHigherThan(urgentPriority), isTrue);
        expect(urgentPriority.isHigherThan(highPriority), isTrue);
        expect(highPriority.isHigherThan(mediumPriority), isTrue);
        expect(mediumPriority.isHigherThan(lowPriority), isTrue);

        expect(lowPriority.isLowerThan(mediumPriority), isTrue);
        expect(mediumPriority.isLowerThan(highPriority), isTrue);
        expect(highPriority.isLowerThan(urgentPriority), isTrue);
        expect(urgentPriority.isLowerThan(criticalPriority), isTrue);

        expect(lowPriority.isHigherThan(mediumPriority), isFalse);
        expect(criticalPriority.isLowerThan(urgentPriority), isFalse);
      });

      test('should determine equal priorities', () {
        // Arrange
        final priority1 = Priority.createHigh();
        final priority2 = Priority.createHigh();

        // Act & Assert
        expect(priority1.isEqualTo(priority2), isTrue);
        expect(priority1.isHigherThan(priority2), isFalse);
        expect(priority1.isLowerThan(priority2), isFalse);
      });
    });

    group('escalation', () {
      test('should escalate priority to next level', () {
        // Arrange
        final lowPriority = Priority.createLow();
        final mediumPriority = Priority.createMedium();
        final highPriority = Priority.createHigh();
        final urgentPriority = Priority.createUrgent();

        // Act
        final escalatedLow = lowPriority.escalate();
        final escalatedMedium = mediumPriority.escalate();
        final escalatedHigh = highPriority.escalate();
        final escalatedUrgent = urgentPriority.escalate();

        // Assert
        expect(escalatedLow.level, equals(Priority.medium));
        expect(escalatedMedium.level, equals(Priority.high));
        expect(escalatedHigh.level, equals(Priority.urgent));
        expect(escalatedUrgent.level, equals(Priority.critical));
      });

      test('should not escalate critical priority beyond maximum', () {
        // Arrange
        final criticalPriority = Priority.createCritical();

        // Act
        final escalated = criticalPriority.escalate();

        // Assert
        expect(escalated.level, equals(Priority.critical));
      });

      test('should check if escalation is possible', () {
        // Arrange
        final lowPriority = Priority.createLow();
        final criticalPriority = Priority.createCritical();

        // Act & Assert
        expect(lowPriority.canEscalate, isTrue);
        expect(criticalPriority.canEscalate, isFalse);
      });
    });

    group('equality', () {
      test('should be equal when priority levels are same', () {
        // Arrange
        final priority1 = Priority.createHigh();
        final priority2 = Priority.createHigh();

        // Act & Assert
        expect(priority1, equals(priority2));
        expect(priority1.hashCode, equals(priority2.hashCode));
      });

      test('should not be equal when priority levels are different', () {
        // Arrange
        final priority1 = Priority.createHigh();
        final priority2 = Priority.createLow();

        // Act & Assert
        expect(priority1, isNot(equals(priority2)));
      });
    });

    group('string representation', () {
      test('should return correct string representation', () {
        // Arrange
        final lowPriority = Priority.createLow();
        final mediumPriority = Priority.createMedium();
        final highPriority = Priority.createHigh();
        final urgentPriority = Priority.createUrgent();
        final criticalPriority = Priority.createCritical();

        // Act & Assert
        expect(lowPriority.toString(), equals('Priority: Low (1)'));
        expect(mediumPriority.toString(), equals('Priority: Medium (2)'));
        expect(highPriority.toString(), equals('Priority: High (3)'));
        expect(urgentPriority.toString(), equals('Priority: Urgent (4)'));
        expect(criticalPriority.toString(), equals('Priority: Critical (5)'));
      });
    });
  });
}
