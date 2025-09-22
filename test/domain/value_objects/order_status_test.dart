import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/value_objects/order_status.dart';
import 'package:stacks/domain/exceptions/domain_exception.dart';

void main() {
  group('OrderStatus', () {
    group('creation', () {
      test('should create OrderStatus with pending status', () {
        // Arrange & Act
        final status = OrderStatus.pending();

        // Assert
        expect(status.value, equals('pending'));
        expect(status.displayName, equals('Pending'));
        expect(status.isPending, isTrue);
      });

      test('should create OrderStatus with confirmed status', () {
        // Arrange & Act
        final status = OrderStatus.confirmed();

        // Assert
        expect(status.value, equals('confirmed'));
        expect(status.displayName, equals('Confirmed'));
        expect(status.isConfirmed, isTrue);
      });

      test('should create OrderStatus with preparing status', () {
        // Arrange & Act
        final status = OrderStatus.preparing();

        // Assert
        expect(status.value, equals('preparing'));
        expect(status.displayName, equals('Preparing'));
        expect(status.isPreparing, isTrue);
      });

      test('should create OrderStatus with ready status', () {
        // Arrange & Act
        final status = OrderStatus.ready();

        // Assert
        expect(status.value, equals('ready'));
        expect(status.displayName, equals('Ready'));
        expect(status.isReady, isTrue);
      });

      test('should create OrderStatus with completed status', () {
        // Arrange & Act
        final status = OrderStatus.completed();

        // Assert
        expect(status.value, equals('completed'));
        expect(status.displayName, equals('Completed'));
        expect(status.isCompleted, isTrue);
      });

      test('should create OrderStatus with cancelled status', () {
        // Arrange & Act
        final status = OrderStatus.cancelled();

        // Assert
        expect(status.value, equals('cancelled'));
        expect(status.displayName, equals('Cancelled'));
        expect(status.isCancelled, isTrue);
      });

      test('should create OrderStatus from valid string value', () {
        // Arrange & Act
        final status = OrderStatus.fromString('preparing');

        // Assert
        expect(status.value, equals('preparing'));
        expect(status.isPreparing, isTrue);
      });

      test('should throw DomainException for invalid status string', () {
        // Arrange & Act & Assert
        expect(
          () => OrderStatus.fromString('invalid_status'),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw DomainException for empty status string', () {
        // Arrange & Act & Assert
        expect(
          () => OrderStatus.fromString(''),
          throwsA(isA<DomainException>()),
        );
      });
    });

    group('business rules', () {
      test('should identify active statuses', () {
        // Arrange
        final pendingStatus = OrderStatus.pending();
        final confirmedStatus = OrderStatus.confirmed();
        final preparingStatus = OrderStatus.preparing();
        final readyStatus = OrderStatus.ready();
        final completedStatus = OrderStatus.completed();
        final cancelledStatus = OrderStatus.cancelled();

        // Act & Assert
        expect(pendingStatus.isActive, isTrue);
        expect(confirmedStatus.isActive, isTrue);
        expect(preparingStatus.isActive, isTrue);
        expect(readyStatus.isActive, isTrue);
        expect(completedStatus.isActive, isFalse);
        expect(cancelledStatus.isActive, isFalse);
      });

      test('should identify final statuses', () {
        // Arrange
        final pendingStatus = OrderStatus.pending();
        final preparingStatus = OrderStatus.preparing();
        final completedStatus = OrderStatus.completed();
        final cancelledStatus = OrderStatus.cancelled();

        // Act & Assert
        expect(pendingStatus.isFinal, isFalse);
        expect(preparingStatus.isFinal, isFalse);
        expect(completedStatus.isFinal, isTrue);
        expect(cancelledStatus.isFinal, isTrue);
      });

      test('should identify kitchen statuses', () {
        // Arrange
        final pendingStatus = OrderStatus.pending();
        final confirmedStatus = OrderStatus.confirmed();
        final preparingStatus = OrderStatus.preparing();
        final readyStatus = OrderStatus.ready();
        final completedStatus = OrderStatus.completed();

        // Act & Assert
        expect(pendingStatus.isInKitchen, isFalse);
        expect(confirmedStatus.isInKitchen, isTrue);
        expect(preparingStatus.isInKitchen, isTrue);
        expect(readyStatus.isInKitchen, isTrue);
        expect(completedStatus.isInKitchen, isFalse);
      });

      test('should calculate priority multiplier based on status', () {
        // Arrange
        final pendingStatus = OrderStatus.pending();
        final confirmedStatus = OrderStatus.confirmed();
        final preparingStatus = OrderStatus.preparing();
        final readyStatus = OrderStatus.ready();

        // Act & Assert
        expect(pendingStatus.priorityMultiplier, equals(1.0));
        expect(confirmedStatus.priorityMultiplier, equals(1.2));
        expect(preparingStatus.priorityMultiplier, equals(1.5));
        expect(readyStatus.priorityMultiplier, equals(2.0));
      });

      test('should get expected time to completion based on status', () {
        // Arrange
        final pendingStatus = OrderStatus.pending();
        final confirmedStatus = OrderStatus.confirmed();
        final preparingStatus = OrderStatus.preparing();
        final readyStatus = OrderStatus.ready();

        // Act & Assert
        expect(
          pendingStatus.expectedTimeToCompletionMinutes,
          equals(25),
        ); // pending + confirmed + preparing + ready
        expect(
          confirmedStatus.expectedTimeToCompletionMinutes,
          equals(20),
        ); // confirmed + preparing + ready
        expect(
          preparingStatus.expectedTimeToCompletionMinutes,
          equals(15),
        ); // preparing + ready
        expect(
          readyStatus.expectedTimeToCompletionMinutes,
          equals(5),
        ); // ready only
      });
    });

    group('status transitions', () {
      test('should determine valid next statuses', () {
        // Arrange
        final pendingStatus = OrderStatus.pending();
        final confirmedStatus = OrderStatus.confirmed();
        final preparingStatus = OrderStatus.preparing();
        final readyStatus = OrderStatus.ready();
        final completedStatus = OrderStatus.completed();

        // Act
        final pendingNext = pendingStatus.getValidNextStatuses();
        final confirmedNext = confirmedStatus.getValidNextStatuses();
        final preparingNext = preparingStatus.getValidNextStatuses();
        final readyNext = readyStatus.getValidNextStatuses();
        final completedNext = completedStatus.getValidNextStatuses();

        // Assert
        expect(pendingNext, containsAll(['confirmed', 'cancelled']));
        expect(confirmedNext, containsAll(['preparing', 'cancelled']));
        expect(preparingNext, containsAll(['ready', 'cancelled']));
        expect(readyNext, containsAll(['completed']));
        expect(completedNext, isEmpty);
      });

      test('should validate transition to next status', () {
        // Arrange
        final pendingStatus = OrderStatus.pending();
        final confirmedStatus = OrderStatus.confirmed();

        // Act & Assert
        expect(pendingStatus.canTransitionTo(confirmedStatus), isTrue);
        expect(pendingStatus.canTransitionTo(OrderStatus.cancelled()), isTrue);
        expect(pendingStatus.canTransitionTo(OrderStatus.preparing()), isFalse);
        expect(pendingStatus.canTransitionTo(OrderStatus.completed()), isFalse);
      });

      test('should transition to next valid status', () {
        // Arrange
        final pendingStatus = OrderStatus.pending();

        // Act
        final confirmedStatus = pendingStatus.transitionTo(
          OrderStatus.confirmed(),
        );

        // Assert
        expect(confirmedStatus.isConfirmed, isTrue);
      });

      test('should throw exception for invalid transition', () {
        // Arrange
        final pendingStatus = OrderStatus.pending();
        final preparingStatus = OrderStatus.preparing();

        // Act & Assert
        expect(
          () => pendingStatus.transitionTo(preparingStatus),
          throwsA(isA<DomainException>()),
        );
      });

      test('should not allow transition from final status', () {
        // Arrange
        final completedStatus = OrderStatus.completed();
        final preparingStatus = OrderStatus.preparing();

        // Act & Assert
        expect(
          () => completedStatus.transitionTo(preparingStatus),
          throwsA(isA<DomainException>()),
        );
      });
    });

    group('time tracking', () {
      test('should require time tracking for kitchen statuses', () {
        // Arrange
        final pendingStatus = OrderStatus.pending();
        final confirmedStatus = OrderStatus.confirmed();
        final preparingStatus = OrderStatus.preparing();
        final readyStatus = OrderStatus.ready();
        final completedStatus = OrderStatus.completed();

        // Act & Assert
        expect(pendingStatus.requiresTimeTracking, isFalse);
        expect(confirmedStatus.requiresTimeTracking, isTrue);
        expect(preparingStatus.requiresTimeTracking, isTrue);
        expect(readyStatus.requiresTimeTracking, isTrue);
        expect(completedStatus.requiresTimeTracking, isFalse);
      });

      test('should require notification for specific statuses', () {
        // Arrange
        final pendingStatus = OrderStatus.pending();
        final readyStatus = OrderStatus.ready();
        final completedStatus = OrderStatus.completed();
        final cancelledStatus = OrderStatus.cancelled();

        // Act & Assert
        expect(pendingStatus.requiresNotification, isFalse);
        expect(readyStatus.requiresNotification, isTrue);
        expect(completedStatus.requiresNotification, isTrue);
        expect(cancelledStatus.requiresNotification, isTrue);
      });
    });

    group('sorting and ordering', () {
      test('should provide sort order for status priority', () {
        // Arrange
        final statuses = [
          OrderStatus.completed(),
          OrderStatus.pending(),
          OrderStatus.ready(),
          OrderStatus.preparing(),
          OrderStatus.confirmed(),
          OrderStatus.cancelled(),
        ];

        // Act
        statuses.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

        // Assert
        expect(statuses[0].isPreparing, isTrue); // Highest priority
        expect(statuses[1].isReady, isTrue);
        expect(statuses[2].isConfirmed, isTrue);
        expect(statuses[3].isPending, isTrue);
        expect(statuses[4].isCompleted, isTrue);
        expect(statuses[5].isCancelled, isTrue); // Lowest priority
      });
    });

    group('equality', () {
      test('should be equal when values are same', () {
        // Arrange
        final status1 = OrderStatus.preparing();
        final status2 = OrderStatus.preparing();

        // Act & Assert
        expect(status1, equals(status2));
        expect(status1.hashCode, equals(status2.hashCode));
      });

      test('should not be equal when values are different', () {
        // Arrange
        final status1 = OrderStatus.preparing();
        final status2 = OrderStatus.ready();

        // Act & Assert
        expect(status1, isNot(equals(status2)));
      });
    });

    group('string representation', () {
      test('should return display name as string', () {
        // Arrange
        final status = OrderStatus.preparing();

        // Act
        final string = status.toString();

        // Assert
        expect(string, equals('Preparing'));
      });
    });
  });
}
