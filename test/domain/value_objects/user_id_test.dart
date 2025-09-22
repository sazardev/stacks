import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/exceptions/domain_exception.dart';

void main() {
  group('UserId', () {
    group('creation', () {
      test('should create UserId with valid UUID string', () {
        // Arrange
        const validUuid = '550e8400-e29b-41d4-a716-446655440000';

        // Act
        final userId = UserId(validUuid);

        // Assert
        expect(userId.value, equals(validUuid));
      });

      test('should create UserId with valid email format', () {
        // Arrange
        const validEmail = 'user@example.com';

        // Act
        final userId = UserId.fromEmail(validEmail);

        // Assert
        expect(userId.value, equals(validEmail));
        expect(userId.isEmail, isTrue);
        expect(userId.isUuid, isFalse);
      });

      test('should generate new UserId with UUID', () {
        // Arrange & Act
        final userId = UserId.generate();

        // Assert
        expect(userId.value, isNotEmpty);
        expect(userId.isUuid, isTrue);
        expect(userId.value.length, equals(36)); // UUID length
        expect(userId.value.contains('-'), isTrue);
      });

      test('should throw DomainException for empty string', () {
        // Arrange & Act & Assert
        expect(() => UserId(''), throwsA(isA<DomainException>()));
      });

      test('should throw DomainException for null value', () {
        // Arrange & Act & Assert
        expect(() => UserId.fromEmail(''), throwsA(isA<DomainException>()));
      });

      test('should throw DomainException for invalid email format', () {
        // Arrange & Act & Assert
        expect(
          () => UserId.fromEmail('invalid-email'),
          throwsA(isA<DomainException>()),
        );
      });

      test('should handle special characters in UUID', () {
        // Arrange
        const validUuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';

        // Act
        final userId = UserId(validUuid);

        // Assert
        expect(userId.value, equals(validUuid));
        expect(userId.isUuid, isTrue);
      });
    });

    group('validation', () {
      test('should validate UUID format correctly', () {
        // Arrange
        const validUuid = '550e8400-e29b-41d4-a716-446655440000';

        // Act
        final validUserId = UserId(validUuid);

        // Assert
        expect(validUserId.isUuid, isTrue);
        // Test shorter ID - this should still be accepted as alphanumeric ID
        const shortId = '550e8400-e29b-41d4-a716';
        final shortUserId = UserId(shortId);
        expect(
          shortUserId.isUuid,
          isFalse,
        ); // Not a valid UUID format but valid user ID
      });

      test('should validate email format correctly', () {
        // Arrange
        const validEmail = 'test.user+tag@example.com';
        const invalidEmail = '@example.com';

        // Act
        final validUserId = UserId.fromEmail(validEmail);

        // Assert
        expect(validUserId.isEmail, isTrue);
        expect(
          () => UserId.fromEmail(invalidEmail),
          throwsA(isA<DomainException>()),
        );
      });

      test('should accept alphanumeric strings as valid IDs', () {
        // Arrange
        const alphanumericId = 'user123456';

        // Act
        final userId = UserId(alphanumericId);

        // Assert
        expect(userId.value, equals(alphanumericId));
        expect(userId.isUuid, isFalse);
        expect(userId.isEmail, isFalse);
      });

      test('should reject strings with only special characters', () {
        // Arrange
        const invalidId = '!!!@@@###';

        // Act & Assert
        expect(() => UserId(invalidId), throwsA(isA<DomainException>()));
      });

      test('should reject very long strings', () {
        // Arrange
        final longId = 'a' * 256; // 256 characters

        // Act & Assert
        expect(() => UserId(longId), throwsA(isA<DomainException>()));
      });

      test('should accept maximum length string', () {
        // Arrange
        final maxLengthId = 'a' * 255; // 255 characters (max allowed)

        // Act
        final userId = UserId(maxLengthId);

        // Assert
        expect(userId.value, equals(maxLengthId));
      });
    });

    group('business rules', () {
      test('should identify system user IDs', () {
        // Arrange
        const systemId = 'system';
        const regularId = 'user123';

        // Act
        final systemUserId = UserId(systemId);
        final regularUserId = UserId(regularId);

        // Assert
        expect(systemUserId.isSystemUser, isTrue);
        expect(regularUserId.isSystemUser, isFalse);
      });

      test('should identify anonymous user IDs', () {
        // Arrange
        const anonymousId = 'anonymous';
        const guestId = 'guest';
        const regularId = 'user123';

        // Act
        final anonymousUserId = UserId(anonymousId);
        final guestUserId = UserId(guestId);
        final regularUserId = UserId(regularId);

        // Assert
        expect(anonymousUserId.isAnonymous, isTrue);
        expect(guestUserId.isAnonymous, isTrue);
        expect(regularUserId.isAnonymous, isFalse);
      });

      test('should extract domain from email user IDs', () {
        // Arrange
        const email = 'user@example.com';

        // Act
        final userId = UserId.fromEmail(email);

        // Assert
        expect(userId.emailDomain, equals('example.com'));
      });

      test('should return null domain for non-email user IDs', () {
        // Arrange
        const nonEmailId = 'user123';

        // Act
        final userId = UserId(nonEmailId);

        // Assert
        expect(userId.emailDomain, isNull);
      });

      test('should extract username from email user IDs', () {
        // Arrange
        const email = 'test.user@example.com';

        // Act
        final userId = UserId.fromEmail(email);

        // Assert
        expect(userId.emailUsername, equals('test.user'));
      });

      test('should return null username for non-email user IDs', () {
        // Arrange
        const nonEmailId = 'user123';

        // Act
        final userId = UserId(nonEmailId);

        // Assert
        expect(userId.emailUsername, isNull);
      });
    });

    group('utility methods', () {
      test('should get display name for email user IDs', () {
        // Arrange
        const email = 'john.doe@example.com';

        // Act
        final userId = UserId.fromEmail(email);

        // Assert
        expect(userId.getDisplayName(), equals('john.doe'));
      });

      test('should get display name for non-email user IDs', () {
        // Arrange
        const regularId = 'user123';

        // Act
        final userId = UserId(regularId);

        // Assert
        expect(userId.getDisplayName(), equals('user123'));
      });

      test('should obfuscate email for privacy', () {
        // Arrange
        const email = 'john.doe@example.com';

        // Act
        final userId = UserId.fromEmail(email);

        // Assert
        expect(userId.obfuscate(), equals('j***doe@example.com'));
      });

      test('should obfuscate regular IDs for privacy', () {
        // Arrange
        const regularId = 'user123456';

        // Act
        final userId = UserId(regularId);

        // Assert
        expect(userId.obfuscate(), equals('use***456'));
      });

      test('should handle short IDs in obfuscation', () {
        // Arrange
        const shortId = 'abc';

        // Act
        final userId = UserId(shortId);

        // Assert
        expect(userId.obfuscate(), equals('a*c'));
      });
    });

    group('equality', () {
      test('should be equal when values are same', () {
        // Arrange
        const id = 'user123';
        final userId1 = UserId(id);
        final userId2 = UserId(id);

        // Act & Assert
        expect(userId1, equals(userId2));
        expect(userId1.hashCode, equals(userId2.hashCode));
      });

      test('should not be equal when values are different', () {
        // Arrange
        final userId1 = UserId('user123');
        final userId2 = UserId('user456');

        // Act & Assert
        expect(userId1, isNot(equals(userId2)));
      });

      test('should be case sensitive', () {
        // Arrange
        final userId1 = UserId('User123');
        final userId2 = UserId('user123');

        // Act & Assert
        expect(userId1, isNot(equals(userId2)));
      });
    });

    group('string representation', () {
      test('should return the ID value as string', () {
        // Arrange
        const id = 'user123';
        final userId = UserId(id);

        // Act
        final string = userId.toString();

        // Assert
        expect(string, equals(id));
      });
    });

    group('comparison', () {
      test('should compare user IDs lexicographically', () {
        // Arrange
        final userId1 = UserId('user1');
        final userId2 = UserId('user2');
        final userId3 = UserId('user1');

        // Act & Assert
        expect(userId1.compareTo(userId2), lessThan(0));
        expect(userId2.compareTo(userId1), greaterThan(0));
        expect(userId1.compareTo(userId3), equals(0));
      });

      test('should sort user IDs correctly', () {
        // Arrange
        final userIds = [UserId('user3'), UserId('user1'), UserId('user2')];

        // Act
        userIds.sort();

        // Assert
        expect(userIds[0].value, equals('user1'));
        expect(userIds[1].value, equals('user2'));
        expect(userIds[2].value, equals('user3'));
      });
    });
  });
}
