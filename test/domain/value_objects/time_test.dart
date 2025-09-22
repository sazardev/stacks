import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/value_objects/time.dart';
import 'package:stacks/domain/exceptions/domain_exception.dart';

void main() {
  group('Time', () {
    group('creation', () {
      test('should create Time from DateTime', () {
        // Arrange
        final dateTime = DateTime(2024, 1, 15, 14, 30, 0);

        // Act
        final time = Time.fromDateTime(dateTime);

        // Assert
        expect(time.dateTime, equals(dateTime));
        expect(
          time.millisecondsSinceEpoch,
          equals(dateTime.millisecondsSinceEpoch),
        );
      });

      test('should create Time from milliseconds since epoch', () {
        // Arrange
        final milliseconds = DateTime(
          2024,
          1,
          15,
          14,
          30,
          0,
        ).millisecondsSinceEpoch;

        // Act
        final time = Time.fromMillisecondsSinceEpoch(milliseconds);

        // Assert
        expect(time.millisecondsSinceEpoch, equals(milliseconds));
        expect(
          time.dateTime,
          equals(DateTime.fromMillisecondsSinceEpoch(milliseconds)),
        );
      });

      test('should create current time', () {
        // Arrange
        final beforeCreation = DateTime.now();

        // Act
        final time = Time.now();
        final afterCreation = DateTime.now();

        // Assert
        expect(
          time.dateTime.isAfter(
            beforeCreation.subtract(const Duration(seconds: 1)),
          ),
          isTrue,
        );
        expect(
          time.dateTime.isBefore(afterCreation.add(const Duration(seconds: 1))),
          isTrue,
        );
      });

      test('should create Time from ISO string', () {
        // Arrange
        const isoString = '2024-01-15T14:30:00.000Z';

        // Act
        final time = Time.fromIsoString(isoString);

        // Assert
        expect(time.toIsoString(), equals(isoString));
      });

      test('should throw DomainException for invalid ISO string', () {
        // Arrange
        const invalidIsoString = 'invalid-date';

        // Act & Assert
        expect(
          () => Time.fromIsoString(invalidIsoString),
          throwsA(isA<DomainException>()),
        );
      });
    });

    group('business operations', () {
      test('should add duration to time', () {
        // Arrange
        final time = Time.fromDateTime(DateTime(2024, 1, 15, 14, 30, 0));
        const duration = Duration(minutes: 30);

        // Act
        final result = time.add(duration);

        // Assert
        expect(result.dateTime, equals(DateTime(2024, 1, 15, 15, 0, 0)));
      });

      test('should subtract duration from time', () {
        // Arrange
        final time = Time.fromDateTime(DateTime(2024, 1, 15, 14, 30, 0));
        const duration = Duration(minutes: 15);

        // Act
        final result = time.subtract(duration);

        // Assert
        expect(result.dateTime, equals(DateTime(2024, 1, 15, 14, 15, 0)));
      });

      test('should calculate difference between times', () {
        // Arrange
        final time1 = Time.fromDateTime(DateTime(2024, 1, 15, 14, 30, 0));
        final time2 = Time.fromDateTime(DateTime(2024, 1, 15, 15, 0, 0));

        // Act
        final difference = time2.difference(time1);

        // Assert
        expect(difference, equals(const Duration(minutes: 30)));
      });

      test('should calculate minutes until another time', () {
        // Arrange
        final time1 = Time.fromDateTime(DateTime(2024, 1, 15, 14, 30, 0));
        final time2 = Time.fromDateTime(DateTime(2024, 1, 15, 15, 15, 0));

        // Act
        final minutes = time1.minutesUntil(time2);

        // Assert
        expect(minutes, equals(45));
      });

      test('should calculate minutes since another time', () {
        // Arrange
        final time1 = Time.fromDateTime(DateTime(2024, 1, 15, 14, 30, 0));
        final time2 = Time.fromDateTime(DateTime(2024, 1, 15, 15, 15, 0));

        // Act
        final minutes = time2.minutesSince(time1);

        // Assert
        expect(minutes, equals(45));
      });

      test('should handle negative minutes for past times', () {
        // Arrange
        final time1 = Time.fromDateTime(DateTime(2024, 1, 15, 15, 0, 0));
        final time2 = Time.fromDateTime(DateTime(2024, 1, 15, 14, 30, 0));

        // Act
        final minutes = time1.minutesUntil(time2);

        // Assert
        expect(minutes, equals(-30));
      });
    });

    group('comparison', () {
      test('should compare times correctly', () {
        // Arrange
        final time1 = Time.fromDateTime(DateTime(2024, 1, 15, 14, 30, 0));
        final time2 = Time.fromDateTime(DateTime(2024, 1, 15, 15, 0, 0));
        final time3 = Time.fromDateTime(DateTime(2024, 1, 15, 14, 30, 0));

        // Act & Assert
        expect(time2.isAfter(time1), isTrue);
        expect(time1.isBefore(time2), isTrue);
        expect(time1.isAtSameMomentAs(time3), isTrue);
        expect(time1.isAfterOrAt(time3), isTrue);
        expect(time1.isBeforeOrAt(time3), isTrue);
        expect(time1.isBeforeOrAt(time2), isTrue);
        expect(time2.isAfterOrAt(time1), isTrue);
      });
    });

    group('business time checks', () {
      test('should check if time is in the past', () {
        // Arrange
        final pastTime = Time.fromDateTime(
          DateTime.now().subtract(const Duration(hours: 1)),
        );
        final futureTime = Time.fromDateTime(
          DateTime.now().add(const Duration(hours: 1)),
        );

        // Act & Assert
        expect(pastTime.isInPast(), isTrue);
        expect(futureTime.isInPast(), isFalse);
      });

      test('should check if time is in the future', () {
        // Arrange
        final pastTime = Time.fromDateTime(
          DateTime.now().subtract(const Duration(hours: 1)),
        );
        final futureTime = Time.fromDateTime(
          DateTime.now().add(const Duration(hours: 1)),
        );

        // Act & Assert
        expect(pastTime.isInFuture(), isFalse);
        expect(futureTime.isInFuture(), isTrue);
      });

      test('should check if time is today', () {
        // Arrange
        final today = Time.now();
        final yesterday = Time.fromDateTime(
          DateTime.now().subtract(const Duration(days: 1)),
        );
        final tomorrow = Time.fromDateTime(
          DateTime.now().add(const Duration(days: 1)),
        );

        // Act & Assert
        expect(today.isToday(), isTrue);
        expect(yesterday.isToday(), isFalse);
        expect(tomorrow.isToday(), isFalse);
      });

      test('should check if time is within business hours', () {
        // Arrange
        final morningTime = Time.fromDateTime(
          DateTime(2024, 1, 15, 10, 30, 0),
        ); // 10:30 AM
        final eveningTime = Time.fromDateTime(
          DateTime(2024, 1, 15, 22, 30, 0),
        ); // 10:30 PM
        final nightTime = Time.fromDateTime(
          DateTime(2024, 1, 15, 2, 30, 0),
        ); // 2:30 AM

        // Act & Assert
        expect(morningTime.isWithinBusinessHours(), isTrue);
        expect(eveningTime.isWithinBusinessHours(), isFalse);
        expect(nightTime.isWithinBusinessHours(), isFalse);
      });

      test('should check if time is within rush hours', () {
        // Arrange
        final lunchRushTime = Time.fromDateTime(
          DateTime(2024, 1, 15, 12, 30, 0),
        ); // 12:30 PM
        final dinnerRushTime = Time.fromDateTime(
          DateTime(2024, 1, 15, 19, 0, 0),
        ); // 7:00 PM
        final quietTime = Time.fromDateTime(
          DateTime(2024, 1, 15, 15, 0, 0),
        ); // 3:00 PM

        // Act & Assert
        expect(lunchRushTime.isWithinRushHours(), isTrue);
        expect(dinnerRushTime.isWithinRushHours(), isTrue);
        expect(quietTime.isWithinRushHours(), isFalse);
      });

      test('should check if time exceeds timeout', () {
        // Arrange
        final baseTime = Time.fromDateTime(DateTime(2024, 1, 15, 14, 0, 0));
        final timeWithinTimeout = Time.fromDateTime(
          DateTime(2024, 1, 15, 14, 10, 0),
        );
        final timeExceedingTimeout = Time.fromDateTime(
          DateTime(2024, 1, 15, 14, 25, 0),
        );

        // Act & Assert
        expect(timeWithinTimeout.exceedsTimeout(baseTime, 15), isFalse);
        expect(timeExceedingTimeout.exceedsTimeout(baseTime, 15), isTrue);
      });
    });

    group('formatting', () {
      test('should format time for display', () {
        // Arrange
        final time = Time.fromDateTime(DateTime(2024, 1, 15, 14, 30, 45));

        // Act
        final formatted = time.formatForDisplay();

        // Assert
        expect(formatted, equals('2:30 PM'));
      });

      test('should format time with seconds', () {
        // Arrange
        final time = Time.fromDateTime(DateTime(2024, 1, 15, 14, 30, 45));

        // Act
        final formatted = time.formatWithSeconds();

        // Assert
        expect(formatted, equals('2:30:45 PM'));
      });

      test('should format date for display', () {
        // Arrange
        final time = Time.fromDateTime(DateTime(2024, 1, 15, 14, 30, 0));

        // Act
        final formatted = time.formatDateForDisplay();

        // Assert
        expect(formatted, equals('Jan 15, 2024'));
      });

      test('should format relative time', () {
        // Arrange
        final now = DateTime.now();
        final fiveMinutesAgo = Time.fromDateTime(
          now.subtract(const Duration(minutes: 5)),
        );
        final oneHourAgo = Time.fromDateTime(
          now.subtract(const Duration(hours: 1)),
        );
        final yesterday = Time.fromDateTime(
          now.subtract(const Duration(days: 1)),
        );

        // Act & Assert
        expect(fiveMinutesAgo.formatRelative(), equals('5 minutes ago'));
        expect(oneHourAgo.formatRelative(), equals('1 hour ago'));
        expect(yesterday.formatRelative(), equals('1 day ago'));
      });
    });

    group('equality', () {
      test('should be equal when DateTime values are same', () {
        // Arrange
        final dateTime = DateTime(2024, 1, 15, 14, 30, 0);
        final time1 = Time.fromDateTime(dateTime);
        final time2 = Time.fromDateTime(dateTime);

        // Act & Assert
        expect(time1, equals(time2));
        expect(time1.hashCode, equals(time2.hashCode));
      });

      test('should not be equal when DateTime values are different', () {
        // Arrange
        final time1 = Time.fromDateTime(DateTime(2024, 1, 15, 14, 30, 0));
        final time2 = Time.fromDateTime(DateTime(2024, 1, 15, 14, 31, 0));

        // Act & Assert
        expect(time1, isNot(equals(time2)));
      });
    });

    group('string representation', () {
      test('should return ISO string representation', () {
        // Arrange
        final time = Time.fromDateTime(DateTime.utc(2024, 1, 15, 14, 30, 0));

        // Act
        final string = time.toString();

        // Assert
        expect(string, equals('2024-01-15T14:30:00.000Z'));
      });
    });
  });
}
