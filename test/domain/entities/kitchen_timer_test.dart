import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/entities/kitchen_timer.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';
import 'package:stacks/domain/exceptions/domain_exception.dart';

void main() {
  group('Kitchen Timer Management', () {
    late UserId timerId;
    late UserId scheduleId;
    late UserId itemId;
    late UserId userId;
    late UserId orderId;
    late UserId stationId;
    late Time createdAt;

    setUp(() {
      timerId = UserId.generate();
      scheduleId = UserId.generate();
      itemId = UserId.generate();
      userId = UserId.generate();
      orderId = UserId.generate();
      stationId = UserId.generate();
      createdAt = Time.now();
    });

    group('KitchenTimer', () {
      group('creation', () {
        test('should create KitchenTimer with valid data', () {
          final timer = KitchenTimer(
            id: timerId,
            label: 'Grill Chicken Breast',
            type: TimerType.cooking,
            duration: const Duration(minutes: 15),
            remainingDuration: const Duration(minutes: 15),
            status: TimerStatus.created,
            priority: TimerPriority.high,
            orderId: orderId,
            stationId: stationId,
            createdBy: userId,
            createdAt: createdAt,
            notes: 'Internal temp 165°F',
            isRepeating: false,
            repeatCount: 0,
            soundAlert: true,
            visualAlert: true,
          );

          expect(timer.id, equals(timerId));
          expect(timer.label, equals('Grill Chicken Breast'));
          expect(timer.type, equals(TimerType.cooking));
          expect(timer.originalDuration, equals(const Duration(minutes: 15)));
          expect(timer.remainingDuration, equals(const Duration(minutes: 15)));
          expect(timer.status, equals(TimerStatus.created));
          expect(timer.priority, equals(TimerPriority.high));
          expect(timer.orderId, equals(orderId));
          expect(timer.stationId, equals(stationId));
          expect(timer.createdBy, equals(userId));
          expect(timer.createdAt, equals(createdAt));
          expect(timer.notes, equals('Internal temp 165°F'));
          expect(timer.isRepeating, isFalse);
          expect(timer.repeatCount, equals(0));
          expect(timer.soundAlert, isTrue);
          expect(timer.visualAlert, isTrue);
        });

        test('should create KitchenTimer with minimum required fields', () {
          final timer = KitchenTimer(
            id: timerId,
            label: 'Simple Timer',
            type: TimerType.prep,
            duration: const Duration(minutes: 5),
            remainingDuration: const Duration(minutes: 5),
            status: TimerStatus.created,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
          );

          expect(timer.id, equals(timerId));
          expect(timer.label, equals('Simple Timer'));
          expect(timer.orderId, isNull);
          expect(timer.stationId, isNull);
          expect(timer.notes, isNull);
          expect(timer.isRepeating, isFalse);
          expect(timer.repeatCount, equals(0));
          expect(timer.soundAlert, isTrue); // Default
          expect(timer.visualAlert, isTrue); // Default
        });

        test('should throw DomainException for empty label', () {
          expect(
            () => KitchenTimer(
              id: timerId,
              label: '',
              type: TimerType.cooking,
              duration: const Duration(minutes: 5),
              remainingDuration: const Duration(minutes: 5),
              status: TimerStatus.created,
              priority: TimerPriority.normal,
              createdBy: userId,
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException for label too long', () {
          final longLabel = 'A' * 101; // Exceeds 100 character limit

          expect(
            () => KitchenTimer(
              id: timerId,
              label: longLabel,
              type: TimerType.cooking,
              duration: const Duration(minutes: 5),
              remainingDuration: const Duration(minutes: 5),
              status: TimerStatus.created,
              priority: TimerPriority.normal,
              createdBy: userId,
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException for duration too short', () {
          expect(
            () => KitchenTimer(
              id: timerId,
              label: 'Quick Timer',
              type: TimerType.cooking,
              duration: Duration.zero,
              remainingDuration: Duration.zero,
              status: TimerStatus.created,
              priority: TimerPriority.normal,
              createdBy: userId,
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException for duration too long', () {
          expect(
            () => KitchenTimer(
              id: timerId,
              label: 'Long Timer',
              type: TimerType.cooking,
              duration: const Duration(hours: 11), // Exceeds 10 hour limit
              remainingDuration: const Duration(hours: 11),
              status: TimerStatus.created,
              priority: TimerPriority.normal,
              createdBy: userId,
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should trim whitespace from label', () {
          final timer = KitchenTimer(
            id: timerId,
            label: '  Cooking Timer  ',
            type: TimerType.cooking,
            duration: const Duration(minutes: 5),
            remainingDuration: const Duration(minutes: 5),
            status: TimerStatus.created,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
          );

          expect(timer.label, equals('Cooking Timer'));
        });
      });

      group('business rules', () {
        test('should identify active timer correctly', () {
          final runningTimer = KitchenTimer(
            id: timerId,
            label: 'Running Timer',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: const Duration(minutes: 8),
            status: TimerStatus.running,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
          );

          final pausedTimer = KitchenTimer(
            id: timerId,
            label: 'Paused Timer',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: const Duration(minutes: 8),
            status: TimerStatus.paused,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
          );

          expect(runningTimer.isActive, isTrue);
          expect(pausedTimer.isActive, isFalse);
        });

        test('should identify completed timer correctly', () {
          final completedTimer = KitchenTimer(
            id: timerId,
            label: 'Completed Timer',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: Duration.zero,
            status: TimerStatus.completed,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
          );

          expect(completedTimer.isCompleted, isTrue);
          expect(completedTimer.isActive, isFalse);
        });

        test('should identify startable timer correctly', () {
          final createdTimer = KitchenTimer(
            id: timerId,
            label: 'Created Timer',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: const Duration(minutes: 10),
            status: TimerStatus.created,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
          );

          final pausedTimer = KitchenTimer(
            id: timerId,
            label: 'Paused Timer',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: const Duration(minutes: 5),
            status: TimerStatus.paused,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
          );

          final completedTimer = KitchenTimer(
            id: timerId,
            label: 'Completed Timer',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: Duration.zero,
            status: TimerStatus.completed,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
          );

          expect(createdTimer.canStart, isTrue);
          expect(pausedTimer.canStart, isTrue);
          expect(completedTimer.canStart, isFalse);
        });

        test('should calculate percentage complete correctly', () {
          // Mock elapsed time calculation by using a timer that started 4 minutes ago
          final fourMinutesAgo = Time.fromDateTime(
            createdAt.dateTime.subtract(const Duration(minutes: 4)),
          );
          final timerWithElapsed = KitchenTimer(
            id: timerId,
            label: 'Progress Timer',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: const Duration(minutes: 6),
            status: TimerStatus.running,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
            startedAt: fourMinutesAgo,
          );

          // Should be approximately 40% complete (4 minutes out of 10)
          expect(timerWithElapsed.percentComplete, greaterThan(30.0));
        });

        test('should handle timer with zero duration', () {
          final timer = KitchenTimer(
            id: timerId,
            label: 'Instant Timer',
            type: TimerType.foodSafety,
            duration: const Duration(seconds: 1), // Minimum duration
            remainingDuration: const Duration(seconds: 1),
            status: TimerStatus.created,
            priority: TimerPriority.critical,
            createdBy: userId,
            createdAt: createdAt,
          );

          expect(timer.percentComplete, equals(0.0));
        });

        test('should validate timer type priorities', () {
          final criticalTimer = KitchenTimer(
            id: timerId,
            label: 'Food Safety Check',
            type: TimerType.foodSafety,
            duration: const Duration(minutes: 2),
            remainingDuration: const Duration(minutes: 2),
            status: TimerStatus.created,
            priority: TimerPriority.critical,
            createdBy: userId,
            createdAt: createdAt,
          );

          final cookingTimer = KitchenTimer(
            id: timerId,
            label: 'Cooking Item',
            type: TimerType.cooking,
            duration: const Duration(minutes: 15),
            remainingDuration: const Duration(minutes: 15),
            status: TimerStatus.created,
            priority: TimerPriority.high,
            createdBy: userId,
            createdAt: createdAt,
          );

          expect(criticalTimer.priority, equals(TimerPriority.critical));
          expect(cookingTimer.priority, equals(TimerPriority.high));
        });
      });

      group('timer operations', () {
        test('should start timer successfully', () {
          final timer = KitchenTimer(
            id: timerId,
            label: 'Cooking Timer',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: const Duration(minutes: 10),
            status: TimerStatus.created,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
          );

          final startedTimer = timer.start();

          expect(startedTimer.status, equals(TimerStatus.running));
          expect(startedTimer.startedAt, isNotNull);
          expect(startedTimer.pausedAt, isNull);
        });

        test('should throw exception when starting non-startable timer', () {
          final runningTimer = KitchenTimer(
            id: timerId,
            label: 'Running Timer',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: const Duration(minutes: 8),
            status: TimerStatus.running,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
          );

          expect(() => runningTimer.start(), throwsA(isA<DomainException>()));
        });

        test('should pause timer successfully', () {
          final runningTimer = KitchenTimer(
            id: timerId,
            label: 'Running Timer',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: const Duration(minutes: 8),
            status: TimerStatus.running,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
            startedAt: createdAt,
          );

          final pausedTimer = runningTimer.pause();

          expect(pausedTimer.status, equals(TimerStatus.paused));
          expect(pausedTimer.pausedAt, isNotNull);
        });

        test('should throw exception when pausing non-running timer', () {
          final createdTimer = KitchenTimer(
            id: timerId,
            label: 'Created Timer',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: const Duration(minutes: 10),
            status: TimerStatus.created,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
          );

          expect(() => createdTimer.pause(), throwsA(isA<DomainException>()));
        });

        test('should complete timer successfully', () {
          final runningTimer = KitchenTimer(
            id: timerId,
            label: 'Running Timer',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: const Duration(minutes: 2),
            status: TimerStatus.running,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
          );

          final completedTimer = runningTimer.complete();

          expect(completedTimer.status, equals(TimerStatus.completed));
          expect(completedTimer.remainingDuration, equals(Duration.zero));
          expect(completedTimer.completedAt, isNotNull);
        });

        test('should cancel timer successfully', () {
          final runningTimer = KitchenTimer(
            id: timerId,
            label: 'Running Timer',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: const Duration(minutes: 8),
            status: TimerStatus.running,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
          );

          final cancelledTimer = runningTimer.cancel();

          expect(cancelledTimer.status, equals(TimerStatus.cancelled));
          expect(cancelledTimer.completedAt, isNotNull);
        });

        test('should extend timer duration', () {
          final timer = KitchenTimer(
            id: timerId,
            label: 'Cooking Timer',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: const Duration(minutes: 5),
            status: TimerStatus.running,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
          );

          final extendedTimer = timer.extend(const Duration(minutes: 3));

          expect(
            extendedTimer.originalDuration,
            equals(const Duration(minutes: 13)),
          );
          expect(
            extendedTimer.remainingDuration,
            equals(const Duration(minutes: 8)),
          );
        });

        test(
          'should throw exception when extending with negative duration',
          () {
            final timer = KitchenTimer(
              id: timerId,
              label: 'Cooking Timer',
              type: TimerType.cooking,
              duration: const Duration(minutes: 10),
              remainingDuration: const Duration(minutes: 5),
              status: TimerStatus.running,
              priority: TimerPriority.normal,
              createdBy: userId,
              createdAt: createdAt,
            );

            expect(
              () => timer.extend(const Duration(minutes: -1)),
              throwsA(isA<DomainException>()),
            );
          },
        );

        test('should mark timer as expired', () {
          final timer = KitchenTimer(
            id: timerId,
            label: 'Overdue Timer',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: const Duration(minutes: 1),
            status: TimerStatus.running,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
          );

          final expiredTimer = timer.markExpired();

          expect(expiredTimer.status, equals(TimerStatus.expired));
          expect(expiredTimer.remainingDuration, equals(Duration.zero));
          expect(expiredTimer.completedAt, isNotNull);
        });

        test('should create repeating timer', () {
          final originalTimerId = UserId('original-timer-id');
          final repeatingTimer = KitchenTimer(
            id: originalTimerId,
            label: 'Repeating Check',
            type: TimerType.temperatureCheck,
            duration: const Duration(minutes: 30),
            remainingDuration: Duration.zero,
            status: TimerStatus.completed,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
            isRepeating: true,
            repeatCount: 1,
          );

          final newTimer = repeatingTimer.repeat();

          expect(
            newTimer.id,
            isNot(equals(originalTimerId)),
          ); // New ID generated
          expect(newTimer.status, equals(TimerStatus.created));
          expect(
            newTimer.remainingDuration,
            equals(const Duration(minutes: 30)),
          );
          expect(newTimer.repeatCount, equals(2));
          expect(newTimer.startedAt, isNull);
        });

        test('should throw exception when repeating non-repeating timer', () {
          final nonRepeatingTimer = KitchenTimer(
            id: timerId,
            label: 'One-time Timer',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: Duration.zero,
            status: TimerStatus.completed,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
            isRepeating: false,
          );

          expect(
            () => nonRepeatingTimer.repeat(),
            throwsA(isA<DomainException>()),
          );
        });
      });

      group('equality', () {
        test('should be equal when ids are the same', () {
          final timer1 = KitchenTimer(
            id: timerId,
            label: 'Timer 1',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: const Duration(minutes: 10),
            status: TimerStatus.created,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
          );

          final timer2 = KitchenTimer(
            id: timerId,
            label: 'Timer 2',
            type: TimerType.prep,
            duration: const Duration(minutes: 5),
            remainingDuration: const Duration(minutes: 5),
            status: TimerStatus.running,
            priority: TimerPriority.high,
            createdBy: userId,
            createdAt: createdAt,
          );

          expect(timer1, equals(timer2));
          expect(timer1.hashCode, equals(timer2.hashCode));
        });

        test('should not be equal when ids are different', () {
          final timer1 = KitchenTimer(
            id: timerId,
            label: 'Timer 1',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: const Duration(minutes: 10),
            status: TimerStatus.created,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
          );

          final differentTimerId = UserId('different-timer-id');
          final timer2 = KitchenTimer(
            id: differentTimerId,
            label: 'Timer 1',
            type: TimerType.cooking,
            duration: const Duration(minutes: 10),
            remainingDuration: const Duration(minutes: 10),
            status: TimerStatus.created,
            priority: TimerPriority.normal,
            createdBy: userId,
            createdAt: createdAt,
          );

          expect(timer1, isNot(equals(timer2)));
        });
      });

      group('string representation', () {
        test('should have meaningful toString', () {
          final timer = KitchenTimer(
            id: timerId,
            label: 'Grill Steak',
            type: TimerType.cooking,
            duration: const Duration(minutes: 8),
            remainingDuration: const Duration(minutes: 5),
            status: TimerStatus.running,
            priority: TimerPriority.high,
            createdBy: userId,
            createdAt: createdAt,
          );

          final stringRep = timer.toString();

          expect(stringRep, contains('KitchenTimer'));
          expect(stringRep, contains(timerId.value));
          expect(stringRep, contains('Grill Steak'));
          expect(stringRep, contains('running'));
        });
      });
    });

    group('ProductionScheduleItem', () {
      group('creation', () {
        test('should create ProductionScheduleItem with valid data', () {
          final item = ProductionScheduleItem(
            id: itemId,
            type: ProductionItemType.recipe,
            description: 'Prepare Caesar Salad',
            recipeId: UserId.generate(),
            quantity: 10,
            estimatedDuration: const Duration(minutes: 30),
            assignedStationId: stationId,
            assignedUserId: userId,
            scheduledStartTime: createdAt,
            status: ProductionStatus.planned,
            priority: 1,
            dependencies: ['prep-lettuce', 'make-dressing'],
          );

          expect(item.id, equals(itemId));
          expect(item.type, equals(ProductionItemType.recipe));
          expect(item.description, equals('Prepare Caesar Salad'));
          expect(item.recipeId, isNotNull);
          expect(item.quantity, equals(10));
          expect(item.estimatedDuration, equals(const Duration(minutes: 30)));
          expect(item.assignedStationId, equals(stationId));
          expect(item.assignedUserId, equals(userId));
          expect(item.scheduledStartTime, equals(createdAt));
          expect(item.status, equals(ProductionStatus.planned));
          expect(item.priority, equals(1));
          expect(item.dependencies.length, equals(2));
        });

        test(
          'should create ProductionScheduleItem with minimum required fields',
          () {
            final item = ProductionScheduleItem(
              id: itemId,
              type: ProductionItemType.cleaning,
              description: 'Clean prep area',
              quantity: 1,
              estimatedDuration: const Duration(minutes: 15),
              scheduledStartTime: createdAt,
            );

            expect(item.id, equals(itemId));
            expect(item.type, equals(ProductionItemType.cleaning));
            expect(item.recipeId, isNull);
            expect(item.inventoryItemId, isNull);
            expect(item.assignedStationId, isNull);
            expect(item.assignedUserId, isNull);
            expect(item.status, equals(ProductionStatus.planned));
            expect(item.priority, equals(0));
            expect(item.dependencies, isEmpty);
          },
        );
      });

      group('business rules', () {
        test('should identify overdue items correctly', () {
          final pastTime = Time.fromDateTime(
            createdAt.dateTime.subtract(const Duration(hours: 1)),
          );

          final overdueItem = ProductionScheduleItem(
            id: itemId,
            type: ProductionItemType.recipe,
            description: 'Overdue Task',
            quantity: 5,
            estimatedDuration: const Duration(minutes: 30),
            scheduledStartTime: pastTime,
            status: ProductionStatus.inProgress,
          );

          final onTimeItem = ProductionScheduleItem(
            id: itemId,
            type: ProductionItemType.recipe,
            description: 'On Time Task',
            quantity: 5,
            estimatedDuration: const Duration(minutes: 30),
            scheduledStartTime: createdAt.add(const Duration(hours: 1)),
            status: ProductionStatus.planned,
          );

          expect(overdueItem.isOverdue, isTrue);
          expect(onTimeItem.isOverdue, isFalse);
        });

        test('should identify ready to start items correctly', () {
          final futureTime = Time.fromDateTime(
            createdAt.dateTime.add(const Duration(hours: 1)),
          );

          final readyItem = ProductionScheduleItem(
            id: itemId,
            type: ProductionItemType.recipe,
            description: 'Ready Task',
            quantity: 5,
            estimatedDuration: const Duration(minutes: 30),
            scheduledStartTime: createdAt,
            status: ProductionStatus.planned,
          );

          final notReadyItem = ProductionScheduleItem(
            id: itemId,
            type: ProductionItemType.recipe,
            description: 'Future Task',
            quantity: 5,
            estimatedDuration: const Duration(minutes: 30),
            scheduledStartTime: futureTime,
            status: ProductionStatus.planned,
          );

          expect(readyItem.isReadyToStart, isTrue);
          expect(notReadyItem.isReadyToStart, isFalse);
        });

        test('should calculate completion percentage correctly', () {
          final completedItem = ProductionScheduleItem(
            id: itemId,
            type: ProductionItemType.recipe,
            description: 'Completed Task',
            quantity: 5,
            estimatedDuration: const Duration(minutes: 30),
            scheduledStartTime: createdAt,
            status: ProductionStatus.completed,
          );

          final notStartedItem = ProductionScheduleItem(
            id: itemId,
            type: ProductionItemType.recipe,
            description: 'Not Started',
            quantity: 5,
            estimatedDuration: const Duration(minutes: 30),
            scheduledStartTime: createdAt,
            status: ProductionStatus.planned,
          );

          expect(completedItem.completionPercentage, equals(100.0));
          expect(notStartedItem.completionPercentage, equals(0.0));
        });

        test('should handle different production item types', () {
          final recipeItem = ProductionScheduleItem(
            id: itemId,
            type: ProductionItemType.recipe,
            description: 'Make Soup',
            recipeId: UserId.generate(),
            quantity: 20,
            estimatedDuration: const Duration(hours: 1),
            scheduledStartTime: createdAt,
          );

          final maintenanceItem = ProductionScheduleItem(
            id: itemId,
            type: ProductionItemType.maintenance,
            description: 'Clean Grill',
            quantity: 1,
            estimatedDuration: const Duration(minutes: 45),
            scheduledStartTime: createdAt,
          );

          expect(recipeItem.type, equals(ProductionItemType.recipe));
          expect(recipeItem.recipeId, isNotNull);
          expect(maintenanceItem.type, equals(ProductionItemType.maintenance));
          expect(maintenanceItem.recipeId, isNull);
        });

        test('should validate priority ordering', () {
          final highPriorityItem = ProductionScheduleItem(
            id: itemId,
            type: ProductionItemType.recipe,
            description: 'Urgent Order',
            quantity: 1,
            estimatedDuration: const Duration(minutes: 15),
            scheduledStartTime: createdAt,
            priority: 1, // High priority (lower number)
          );

          final lowPriorityItem = ProductionScheduleItem(
            id: itemId,
            type: ProductionItemType.cleaning,
            description: 'Regular Cleaning',
            quantity: 1,
            estimatedDuration: const Duration(minutes: 30),
            scheduledStartTime: createdAt,
            priority: 10, // Low priority (higher number)
          );

          expect(highPriorityItem.priority, lessThan(lowPriorityItem.priority));
        });
      });

      group('equality', () {
        test('should be equal when ids are the same', () {
          final item1 = ProductionScheduleItem(
            id: itemId,
            type: ProductionItemType.recipe,
            description: 'Task 1',
            quantity: 5,
            estimatedDuration: const Duration(minutes: 30),
            scheduledStartTime: createdAt,
          );

          final item2 = ProductionScheduleItem(
            id: itemId,
            type: ProductionItemType.cleaning,
            description: 'Task 2',
            quantity: 10,
            estimatedDuration: const Duration(minutes: 45),
            scheduledStartTime: createdAt,
          );

          expect(item1, equals(item2));
          expect(item1.hashCode, equals(item2.hashCode));
        });

        test('should not be equal when ids are different', () {
          final item1 = ProductionScheduleItem(
            id: itemId,
            type: ProductionItemType.recipe,
            description: 'Task 1',
            quantity: 5,
            estimatedDuration: const Duration(minutes: 30),
            scheduledStartTime: createdAt,
          );

          final differentItemId = UserId('different-item-id');
          final item2 = ProductionScheduleItem(
            id: differentItemId,
            type: ProductionItemType.recipe,
            description: 'Task 1',
            quantity: 5,
            estimatedDuration: const Duration(minutes: 30),
            scheduledStartTime: createdAt,
          );

          expect(item1, isNot(equals(item2)));
        });
      });

      group('string representation', () {
        test('should have meaningful toString', () {
          final item = ProductionScheduleItem(
            id: itemId,
            type: ProductionItemType.recipe,
            description: 'Prepare Pasta',
            quantity: 15,
            estimatedDuration: const Duration(minutes: 45),
            scheduledStartTime: createdAt,
            status: ProductionStatus.inProgress,
          );

          final stringRep = item.toString();

          expect(stringRep, contains('ProductionScheduleItem'));
          expect(stringRep, contains(itemId.value));
          expect(stringRep, contains('Prepare Pasta'));
          expect(stringRep, contains('inProgress'));
        });
      });
    });

    group('ProductionSchedule', () {
      group('creation', () {
        test('should create ProductionSchedule with valid data', () {
          final items = [
            ProductionScheduleItem(
              id: UserId.generate(),
              type: ProductionItemType.recipe,
              description: 'Prep Salads',
              quantity: 20,
              estimatedDuration: const Duration(minutes: 30),
              scheduledStartTime: createdAt,
            ),
            ProductionScheduleItem(
              id: UserId.generate(),
              type: ProductionItemType.cleaning,
              description: 'Clean Station',
              quantity: 1,
              estimatedDuration: const Duration(minutes: 15),
              scheduledStartTime: createdAt.add(const Duration(minutes: 30)),
            ),
          ];

          final schedule = ProductionSchedule(
            id: scheduleId,
            name: 'Lunch Prep Schedule',
            scheduleDate: createdAt,
            startTime: createdAt,
            endTime: createdAt.add(const Duration(hours: 4)),
            items: items,
            overallStatus: ProductionStatus.planned,
            createdBy: userId,
            createdAt: createdAt,
          );

          expect(schedule.id, equals(scheduleId));
          expect(schedule.name, equals('Lunch Prep Schedule'));
          expect(schedule.scheduleDate, equals(createdAt));
          expect(schedule.startTime, equals(createdAt));
          expect(
            schedule.endTime,
            equals(createdAt.add(const Duration(hours: 4))),
          );
          expect(schedule.items.length, equals(2));
          expect(schedule.overallStatus, equals(ProductionStatus.planned));
          expect(schedule.createdBy, equals(userId));
          expect(schedule.createdAt, equals(createdAt));
          expect(schedule.updatedAt, equals(createdAt));
        });

        test(
          'should create ProductionSchedule with minimum required fields',
          () {
            final schedule = ProductionSchedule(
              id: scheduleId,
              name: 'Simple Schedule',
              scheduleDate: createdAt,
              startTime: createdAt,
              endTime: createdAt.add(const Duration(hours: 2)),
              createdBy: userId,
              createdAt: createdAt,
            );

            expect(schedule.id, equals(scheduleId));
            expect(schedule.name, equals('Simple Schedule'));
            expect(schedule.items, isEmpty);
            expect(schedule.overallStatus, equals(ProductionStatus.planned));
            expect(schedule.updatedAt, equals(createdAt));
          },
        );
      });

      group('business rules', () {
        test('should calculate total estimated duration correctly', () {
          final items = [
            ProductionScheduleItem(
              id: UserId.generate(),
              type: ProductionItemType.recipe,
              description: 'Task 1',
              quantity: 10,
              estimatedDuration: const Duration(minutes: 30),
              scheduledStartTime: createdAt,
            ),
            ProductionScheduleItem(
              id: UserId.generate(),
              type: ProductionItemType.recipe,
              description: 'Task 2',
              quantity: 5,
              estimatedDuration: const Duration(minutes: 45),
              scheduledStartTime: createdAt,
            ),
            ProductionScheduleItem(
              id: UserId.generate(),
              type: ProductionItemType.cleaning,
              description: 'Task 3',
              quantity: 1,
              estimatedDuration: const Duration(minutes: 15),
              scheduledStartTime: createdAt,
            ),
          ];

          final schedule = ProductionSchedule(
            id: scheduleId,
            name: 'Test Schedule',
            scheduleDate: createdAt,
            startTime: createdAt,
            endTime: createdAt.add(const Duration(hours: 2)),
            items: items,
            createdBy: userId,
            createdAt: createdAt,
          );

          expect(
            schedule.totalEstimatedDuration,
            equals(const Duration(minutes: 90)),
          );
        });

        test('should calculate completion percentage correctly', () {
          final items = [
            ProductionScheduleItem(
              id: UserId.generate(),
              type: ProductionItemType.recipe,
              description: 'Completed Task',
              quantity: 10,
              estimatedDuration: const Duration(minutes: 30),
              scheduledStartTime: createdAt,
              status: ProductionStatus.completed,
            ),
            ProductionScheduleItem(
              id: UserId.generate(),
              type: ProductionItemType.recipe,
              description: 'In Progress Task',
              quantity: 5,
              estimatedDuration: const Duration(minutes: 45),
              scheduledStartTime: createdAt,
              status: ProductionStatus.inProgress,
            ),
            ProductionScheduleItem(
              id: UserId.generate(),
              type: ProductionItemType.cleaning,
              description: 'Planned Task',
              quantity: 1,
              estimatedDuration: const Duration(minutes: 15),
              scheduledStartTime: createdAt,
              status: ProductionStatus.planned,
            ),
          ];

          final schedule = ProductionSchedule(
            id: scheduleId,
            name: 'Test Schedule',
            scheduleDate: createdAt,
            startTime: createdAt,
            endTime: createdAt.add(const Duration(hours: 2)),
            items: items,
            createdBy: userId,
            createdAt: createdAt,
          );

          expect(
            schedule.completionPercentage,
            closeTo(33.33, 0.1),
          ); // 1 out of 3 completed
        });

        test('should handle empty schedule completion percentage', () {
          final schedule = ProductionSchedule(
            id: scheduleId,
            name: 'Empty Schedule',
            scheduleDate: createdAt,
            startTime: createdAt,
            endTime: createdAt.add(const Duration(hours: 2)),
            createdBy: userId,
            createdAt: createdAt,
          );

          expect(schedule.completionPercentage, equals(100.0));
        });

        test('should identify schedule on time status', () {
          final onTimeItems = [
            ProductionScheduleItem(
              id: UserId.generate(),
              type: ProductionItemType.recipe,
              description: 'On Time Task',
              quantity: 10,
              estimatedDuration: const Duration(minutes: 30),
              scheduledStartTime: createdAt.add(const Duration(hours: 1)),
              status: ProductionStatus.planned,
            ),
          ];

          final overdueItems = [
            ProductionScheduleItem(
              id: UserId.generate(),
              type: ProductionItemType.recipe,
              description: 'Overdue Task',
              quantity: 10,
              estimatedDuration: const Duration(minutes: 30),
              scheduledStartTime: createdAt.subtract(const Duration(hours: 1)),
              status: ProductionStatus.inProgress,
            ),
          ];

          final onTimeSchedule = ProductionSchedule(
            id: scheduleId,
            name: 'On Time Schedule',
            scheduleDate: createdAt,
            startTime: createdAt,
            endTime: createdAt.add(const Duration(hours: 4)),
            items: onTimeItems,
            createdBy: userId,
            createdAt: createdAt,
          );

          final overdueSchedule = ProductionSchedule(
            id: scheduleId,
            name: 'Overdue Schedule',
            scheduleDate: createdAt,
            startTime: createdAt,
            endTime: createdAt.add(const Duration(hours: 4)),
            items: overdueItems,
            createdBy: userId,
            createdAt: createdAt,
          );

          expect(onTimeSchedule.isOnTime, isTrue);
          expect(overdueSchedule.isOnTime, isFalse);
        });

        test('should filter items by status', () {
          final items = [
            ProductionScheduleItem(
              id: UserId.generate(),
              type: ProductionItemType.recipe,
              description: 'Completed Task',
              quantity: 10,
              estimatedDuration: const Duration(minutes: 30),
              scheduledStartTime: createdAt,
              status: ProductionStatus.completed,
            ),
            ProductionScheduleItem(
              id: UserId.generate(),
              type: ProductionItemType.recipe,
              description: 'In Progress Task',
              quantity: 5,
              estimatedDuration: const Duration(minutes: 45),
              scheduledStartTime: createdAt,
              status: ProductionStatus.inProgress,
            ),
            ProductionScheduleItem(
              id: UserId.generate(),
              type: ProductionItemType.cleaning,
              description: 'Planned Task',
              quantity: 1,
              estimatedDuration: const Duration(minutes: 15),
              scheduledStartTime: createdAt,
              status: ProductionStatus.planned,
            ),
          ];

          final schedule = ProductionSchedule(
            id: scheduleId,
            name: 'Test Schedule',
            scheduleDate: createdAt,
            startTime: createdAt,
            endTime: createdAt.add(const Duration(hours: 2)),
            items: items,
            createdBy: userId,
            createdAt: createdAt,
          );

          final completedItems = schedule.getItemsByStatus(
            ProductionStatus.completed,
          );
          final inProgressItems = schedule.getItemsByStatus(
            ProductionStatus.inProgress,
          );
          final plannedItems = schedule.getItemsByStatus(
            ProductionStatus.planned,
          );

          expect(completedItems.length, equals(1));
          expect(inProgressItems.length, equals(1));
          expect(plannedItems.length, equals(1));
        });

        test('should identify overdue items', () {
          final pastTime = Time.fromDateTime(
            createdAt.dateTime.subtract(const Duration(hours: 1)),
          );

          final items = [
            ProductionScheduleItem(
              id: UserId.generate(),
              type: ProductionItemType.recipe,
              description: 'On Time Task',
              quantity: 10,
              estimatedDuration: const Duration(minutes: 30),
              scheduledStartTime: createdAt.add(const Duration(hours: 1)),
              status: ProductionStatus.planned,
            ),
            ProductionScheduleItem(
              id: UserId.generate(),
              type: ProductionItemType.recipe,
              description: 'Overdue Task',
              quantity: 5,
              estimatedDuration: const Duration(minutes: 30),
              scheduledStartTime: pastTime,
              status: ProductionStatus.inProgress,
            ),
          ];

          final schedule = ProductionSchedule(
            id: scheduleId,
            name: 'Mixed Schedule',
            scheduleDate: createdAt,
            startTime: createdAt,
            endTime: createdAt.add(const Duration(hours: 4)),
            items: items,
            createdBy: userId,
            createdAt: createdAt,
          );

          final overdueItems = schedule.overdueItems;

          expect(overdueItems.length, equals(1));
          expect(overdueItems.first.description, equals('Overdue Task'));
        });
      });

      group('equality', () {
        test('should be equal when ids are the same', () {
          final schedule1 = ProductionSchedule(
            id: scheduleId,
            name: 'Schedule 1',
            scheduleDate: createdAt,
            startTime: createdAt,
            endTime: createdAt.add(const Duration(hours: 2)),
            createdBy: userId,
            createdAt: createdAt,
          );

          final schedule2 = ProductionSchedule(
            id: scheduleId,
            name: 'Schedule 2',
            scheduleDate: createdAt.add(const Duration(days: 1)),
            startTime: createdAt,
            endTime: createdAt.add(const Duration(hours: 4)),
            createdBy: userId,
            createdAt: createdAt,
          );

          expect(schedule1, equals(schedule2));
          expect(schedule1.hashCode, equals(schedule2.hashCode));
        });

        test('should not be equal when ids are different', () {
          final schedule1 = ProductionSchedule(
            id: scheduleId,
            name: 'Schedule 1',
            scheduleDate: createdAt,
            startTime: createdAt,
            endTime: createdAt.add(const Duration(hours: 2)),
            createdBy: userId,
            createdAt: createdAt,
          );

          final differentScheduleId = UserId('different-schedule-id');
          final schedule2 = ProductionSchedule(
            id: differentScheduleId,
            name: 'Schedule 1',
            scheduleDate: createdAt,
            startTime: createdAt,
            endTime: createdAt.add(const Duration(hours: 2)),
            createdBy: userId,
            createdAt: createdAt,
          );

          expect(schedule1, isNot(equals(schedule2)));
        });
      });

      group('string representation', () {
        test('should have meaningful toString', () {
          final items = [
            ProductionScheduleItem(
              id: UserId.generate(),
              type: ProductionItemType.recipe,
              description: 'Prep Task',
              quantity: 10,
              estimatedDuration: const Duration(minutes: 30),
              scheduledStartTime: createdAt,
            ),
          ];

          final schedule = ProductionSchedule(
            id: scheduleId,
            name: 'Morning Prep',
            scheduleDate: createdAt,
            startTime: createdAt,
            endTime: createdAt.add(const Duration(hours: 3)),
            items: items,
            createdBy: userId,
            createdAt: createdAt,
          );

          final stringRep = schedule.toString();

          expect(stringRep, contains('ProductionSchedule'));
          expect(stringRep, contains(scheduleId.value));
          expect(stringRep, contains('Morning Prep'));
          expect(stringRep, contains('1')); // Number of items
        });
      });
    });
  });
}
