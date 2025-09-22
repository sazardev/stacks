import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/value_objects/money.dart';
import 'package:stacks/domain/exceptions/domain_exception.dart';

void main() {
  group('Money', () {
    group('creation', () {
      test('should create Money with valid amount', () {
        // Arrange & Act
        final money = Money(10.50);

        // Assert
        expect(money.amount, equals(10.50));
        expect(money.currency, equals('USD'));
      });

      test('should create Money with custom currency', () {
        // Arrange & Act
        final money = Money(25.75, currency: 'EUR');

        // Assert
        expect(money.amount, equals(25.75));
        expect(money.currency, equals('EUR'));
      });

      test('should create Money with zero amount', () {
        // Arrange & Act
        final money = Money(0.0);

        // Assert
        expect(money.amount, equals(0.0));
        expect(money.currency, equals('USD'));
      });

      test('should throw DomainException for negative amount', () {
        // Arrange & Act & Assert
        expect(() => Money(-5.0), throwsA(isA<DomainException>()));
      });

      test('should throw DomainException for invalid currency', () {
        // Arrange & Act & Assert
        expect(
          () => Money(10.0, currency: ''),
          throwsA(isA<DomainException>()),
        );
      });

      test('should handle default currency when none provided', () {
        // Arrange & Act
        final money = Money(10.0);

        // Assert
        expect(money.currency, equals('USD'));
      });
    });

    group('business rules', () {
      test('should validate amount precision to 2 decimal places', () {
        // Arrange & Act
        final money = Money(10.999);

        // Assert
        expect(money.amount, equals(11.00)); // Should round to 2 decimals
      });

      test('should convert amount to cents correctly', () {
        // Arrange
        final money = Money(10.75);

        // Act
        final cents = money.toCents();

        // Assert
        expect(cents, equals(1075));
      });

      test('should create from cents correctly', () {
        // Arrange & Act
        final money = Money.fromCents(1575);

        // Assert
        expect(money.amount, equals(15.75));
      });

      test('should support supported currencies', () {
        // Arrange & Act & Assert
        expect(() => Money(10.0, currency: 'USD'), returnsNormally);
        expect(() => Money(10.0, currency: 'EUR'), returnsNormally);
        expect(() => Money(10.0, currency: 'GBP'), returnsNormally);
        expect(() => Money(10.0, currency: 'CAD'), returnsNormally);
      });

      test('should reject unsupported currencies', () {
        // Arrange & Act & Assert
        expect(
          () => Money(10.0, currency: 'XYZ'),
          throwsA(isA<DomainException>()),
        );
      });
    });

    group('operations', () {
      test('should add money with same currency', () {
        // Arrange
        final money1 = Money(10.50);
        final money2 = Money(5.25);

        // Act
        final result = money1.add(money2);

        // Assert
        expect(result.amount, equals(15.75));
        expect(result.currency, equals('USD'));
      });

      test('should subtract money with same currency', () {
        // Arrange
        final money1 = Money(10.50);
        final money2 = Money(3.25);

        // Act
        final result = money1.subtract(money2);

        // Assert
        expect(result.amount, equals(7.25));
        expect(result.currency, equals('USD'));
      });

      test('should multiply money by factor', () {
        // Arrange
        final money = Money(10.50);

        // Act
        final result = money.multiply(2);

        // Assert
        expect(result.amount, equals(21.00));
        expect(result.currency, equals('USD'));
      });

      test('should throw exception when adding different currencies', () {
        // Arrange
        final money1 = Money(10.50, currency: 'USD');
        final money2 = Money(5.25, currency: 'EUR');

        // Act & Assert
        expect(() => money1.add(money2), throwsA(isA<DomainException>()));
      });

      test('should throw exception when subtracting different currencies', () {
        // Arrange
        final money1 = Money(10.50, currency: 'USD');
        final money2 = Money(5.25, currency: 'EUR');

        // Act & Assert
        expect(() => money1.subtract(money2), throwsA(isA<DomainException>()));
      });

      test('should throw exception when subtraction results in negative', () {
        // Arrange
        final money1 = Money(5.00);
        final money2 = Money(10.00);

        // Act & Assert
        expect(() => money1.subtract(money2), throwsA(isA<DomainException>()));
      });
    });

    group('comparison', () {
      test('should compare money amounts correctly', () {
        // Arrange
        final money1 = Money(10.50);
        final money2 = Money(5.25);
        final money3 = Money(10.50);

        // Act & Assert
        expect(money1.isGreaterThan(money2), isTrue);
        expect(money2.isLessThan(money1), isTrue);
        expect(money1.isEqualTo(money3), isTrue);
        expect(money1.isGreaterThanOrEqual(money3), isTrue);
        expect(money2.isLessThanOrEqual(money1), isTrue);
      });

      test('should throw exception when comparing different currencies', () {
        // Arrange
        final money1 = Money(10.50, currency: 'USD');
        final money2 = Money(5.25, currency: 'EUR');

        // Act & Assert
        expect(
          () => money1.isGreaterThan(money2),
          throwsA(isA<DomainException>()),
        );
      });
    });

    group('equality', () {
      test('should be equal when amount and currency are same', () {
        // Arrange
        final money1 = Money(10.50, currency: 'USD');
        final money2 = Money(10.50, currency: 'USD');

        // Act & Assert
        expect(money1, equals(money2));
        expect(money1.hashCode, equals(money2.hashCode));
      });

      test('should not be equal when amount is different', () {
        // Arrange
        final money1 = Money(10.50);
        final money2 = Money(10.75);

        // Act & Assert
        expect(money1, isNot(equals(money2)));
      });

      test('should not be equal when currency is different', () {
        // Arrange
        final money1 = Money(10.50, currency: 'USD');
        final money2 = Money(10.50, currency: 'EUR');

        // Act & Assert
        expect(money1, isNot(equals(money2)));
      });
    });

    group('string representation', () {
      test('should format currency correctly', () {
        // Arrange
        final money = Money(10.50);

        // Act
        final formatted = money.toString();

        // Assert
        expect(formatted, equals('\$10.50'));
      });

      test('should format EUR currency correctly', () {
        // Arrange
        final money = Money(15.75, currency: 'EUR');

        // Act
        final formatted = money.toString();

        // Assert
        expect(formatted, equals('€15.75'));
      });

      test('should format GBP currency correctly', () {
        // Arrange
        final money = Money(8.25, currency: 'GBP');

        // Act
        final formatted = money.toString();

        // Assert
        expect(formatted, equals('£8.25'));
      });
    });
  });
}
