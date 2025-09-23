import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/entities/table.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';
import 'package:stacks/domain/exceptions/domain_exception.dart';

void main() {
  group('Table Management', () {
    late UserId tableId;
    late UserId customerId;
    late UserId serverId;
    late UserId reservationId;
    late UserId orderId;
    late Time createdAt;

    setUp(() {
      tableId = UserId('table-001');
      customerId = UserId('customer-001');
      serverId = UserId('server-001');
      reservationId = UserId('reservation-001');
      orderId = UserId('order-001');
      createdAt = Time.now();
    });

    group('Table', () {
      group('creation', () {
        test('should create Table with valid data', () {
          final table = Table(
            id: tableId,
            tableNumber: 'T-15',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [
              TableRequirement.wheelchairAccessible,
              TableRequirement.highChair,
            ],
            currentServerId: serverId,
            currentReservationId: reservationId,
            lastOccupiedAt: createdAt.subtract(const Duration(hours: 1)),
            lastCleanedAt: createdAt.subtract(const Duration(minutes: 30)),
            isActive: true,
            xPosition: 150.0,
            yPosition: 200.0,
            notes: 'Near window with city view',
            createdAt: createdAt,
          );

          expect(table.id, equals(tableId));
          expect(table.tableNumber, equals('T-15'));
          expect(table.capacity, equals(4));
          expect(table.section, equals(TableSection.mainDining));
          expect(table.status, equals(TableStatus.available));
          expect(table.requirements.length, equals(2));
          expect(table.requirements,
              contains(TableRequirement.wheelchairAccessible));
          expect(table.requirements, contains(TableRequirement.highChair));
          expect(table.currentServerId, equals(serverId));
          expect(table.currentReservationId, equals(reservationId));
          expect(table.lastOccupiedAt, isNotNull);
          expect(table.lastCleanedAt, isNotNull);
          expect(table.isActive, isTrue);
          expect(table.xPosition, equals(150.0));
          expect(table.yPosition, equals(200.0));
          expect(table.notes, equals('Near window with city view'));
          expect(table.createdAt, equals(createdAt));
        });

        test('should create Table with minimum required fields', () {
          final table = Table(
            id: tableId,
            tableNumber: '5',
            capacity: 2,
            section: TableSection.bar,
            status: TableStatus.available,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          expect(table.id, equals(tableId));
          expect(table.tableNumber, equals('5'));
          expect(table.capacity, equals(2));
          expect(table.section, equals(TableSection.bar));
          expect(table.status, equals(TableStatus.available));
          expect(table.requirements, isEmpty);
          expect(table.currentServerId, isNull);
          expect(table.currentReservationId, isNull);
          expect(table.lastOccupiedAt, isNull);
          expect(table.lastCleanedAt, isNull);
          expect(table.isActive, isTrue);
          expect(table.xPosition, isNull);
          expect(table.yPosition, isNull);
          expect(table.notes, isNull);
        });

        test('should throw DomainException for empty table number', () {
          expect(
            () => Table(
              id: tableId,
              tableNumber: '',
              capacity: 4,
              section: TableSection.mainDining,
              status: TableStatus.available,
              requirements: [],
              isActive: true,
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException for table number too long', () {
          expect(
            () => Table(
              id: tableId,
              tableNumber: 'A' * 11, // Exceeds 10 character limit
              capacity: 4,
              section: TableSection.mainDining,
              status: TableStatus.available,
              requirements: [],
              isActive: true,
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException for capacity too low', () {
          expect(
            () => Table(
              id: tableId,
              tableNumber: 'T1',
              capacity: 0, // Below minimum of 1
              section: TableSection.mainDining,
              status: TableStatus.available,
              requirements: [],
              isActive: true,
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException for capacity too high', () {
          expect(
            () => Table(
              id: tableId,
              tableNumber: 'T1',
              capacity: 25, // Exceeds maximum of 20
              section: TableSection.mainDining,
              status: TableStatus.available,
              requirements: [],
              isActive: true,
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should trim whitespace from table number', () {
          final table = Table(
            id: tableId,
            tableNumber: '  T-10  ',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          expect(table.tableNumber, equals('T-10'));
        });
      });

      group('business rules', () {
        test('should identify available tables correctly', () {
          final availableTable = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          final occupiedTable = Table(
            id: tableId,
            tableNumber: 'T2',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.occupied,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          final inactiveTable = Table(
            id: tableId,
            tableNumber: 'T3',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [],
            isActive: false,
            createdAt: createdAt,
          );

          expect(availableTable.isAvailableForSeating, isTrue);
          expect(occupiedTable.isAvailableForSeating, isFalse);
          expect(inactiveTable.isAvailableForSeating, isFalse);
        });

        test('should identify occupied tables correctly', () {
          final occupiedTable = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.occupied,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          final availableTable = Table(
            id: tableId,
            tableNumber: 'T2',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          expect(occupiedTable.isOccupied, isTrue);
          expect(availableTable.isOccupied, isFalse);
        });

        test('should identify tables needing cleaning correctly', () {
          final needsCleaningTable = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.needsCleaning,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          final cleanTable = Table(
            id: tableId,
            tableNumber: 'T2',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          expect(needsCleaningTable.needsCleaning, isTrue);
          expect(cleanTable.needsCleaning, isFalse);
        });

        test('should check for specific requirements', () {
          final table = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [
              TableRequirement.wheelchairAccessible,
              TableRequirement.highChair,
            ],
            isActive: true,
            createdAt: createdAt,
          );

          expect(table.hasRequirement(TableRequirement.wheelchairAccessible),
              isTrue);
          expect(table.hasRequirement(TableRequirement.highChair), isTrue);
          expect(table.hasRequirement(TableRequirement.quiet), isFalse);
        });

        test('should calculate minutes since last cleaned', () {
          final thirtyMinutesAgo = createdAt.subtract(const Duration(minutes: 30));
          final table = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [],
            isActive: true,
            lastCleanedAt: thirtyMinutesAgo,
            createdAt: createdAt,
          );

          final minutes = table.minutesSinceLastCleaned;
          expect(minutes, isNotNull);
          expect(minutes, greaterThanOrEqualTo(30));
        });

        test('should return null for minutes since last cleaned when never cleaned', () {
          final table = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          expect(table.minutesSinceLastCleaned, isNull);
        });

        test('should identify cleaning overdue status', () {
          final twentyMinutesAgo = createdAt.subtract(const Duration(minutes: 20));
          final fiveMinutesAgo = createdAt.subtract(const Duration(minutes: 5));
          
          final overdueTable = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [],
            isActive: true,
            lastCleanedAt: twentyMinutesAgo,
            createdAt: createdAt,
          );

          final recentlyCleanedTable = Table(
            id: tableId,
            tableNumber: 'T2',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [],
            isActive: true,
            lastCleanedAt: fiveMinutesAgo,
            createdAt: createdAt,
          );

          final neverCleanedTable = Table(
            id: tableId,
            tableNumber: 'T3',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          expect(overdueTable.isCleaningOverdue, isTrue);
          expect(recentlyCleanedTable.isCleaningOverdue, isFalse);
          expect(neverCleanedTable.isCleaningOverdue, isTrue);
        });

        test('should validate different table sections', () {
          final sections = [
            TableSection.mainDining,
            TableSection.bar,
            TableSection.patio,
            TableSection.privateDining,
            TableSection.counter,
            TableSection.booth,
            TableSection.window,
            TableSection.vip,
          ];

          for (final section in sections) {
            final table = Table(
              id: tableId,
              tableNumber: 'T${section.index}',
              capacity: 4,
              section: section,
              status: TableStatus.available,
              requirements: [],
              isActive: true,
              createdAt: createdAt,
            );

            expect(table.section, equals(section));
          }
        });

        test('should handle various table statuses', () {
          final statuses = [
            TableStatus.available,
            TableStatus.reserved,
            TableStatus.occupied,
            TableStatus.needsCleaning,
            TableStatus.cleaning,
            TableStatus.outOfService,
            TableStatus.maintenance,
          ];

          for (final status in statuses) {
            final table = Table(
              id: tableId,
              tableNumber: 'T${status.index}',
              capacity: 4,
              section: TableSection.mainDining,
              status: status,
              requirements: [],
              isActive: true,
              createdAt: createdAt,
            );

            expect(table.status, equals(status));
          }
        });
      });

      group('table operations', () {
        test('should seat guests successfully', () {
          final availableTable = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          final seatedTable = availableTable.seatGuests(
            serverId,
            reservationId: reservationId,
          );

          expect(seatedTable.status, equals(TableStatus.occupied));
          expect(seatedTable.currentServerId, equals(serverId));
          expect(seatedTable.currentReservationId, equals(reservationId));
          expect(seatedTable.lastOccupiedAt, isNotNull);
        });

        test('should seat guests without reservation', () {
          final availableTable = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          final seatedTable = availableTable.seatGuests(serverId);

          expect(seatedTable.status, equals(TableStatus.occupied));
          expect(seatedTable.currentServerId, equals(serverId));
          expect(seatedTable.currentReservationId, isNull);
          expect(seatedTable.lastOccupiedAt, isNotNull);
        });

        test('should throw exception when seating guests at unavailable table', () {
          final occupiedTable = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.occupied,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          expect(
            () => occupiedTable.seatGuests(serverId),
            throwsA(isA<DomainException>()),
          );
        });

        test('should clear table successfully', () {
          final occupiedTable = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.occupied,
            requirements: [],
            isActive: true,
            currentServerId: serverId,
            currentReservationId: reservationId,
            lastOccupiedAt: createdAt,
            createdAt: createdAt,
          );

          final clearedTable = occupiedTable.clearTable();

          expect(clearedTable.status, equals(TableStatus.needsCleaning));
          expect(clearedTable.currentServerId, isNull);
          expect(clearedTable.currentReservationId, isNull);
          expect(clearedTable.lastOccupiedAt, equals(createdAt));
        });

        test('should throw exception when clearing non-occupied table', () {
          final availableTable = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          expect(
            () => availableTable.clearTable(),
            throwsA(isA<DomainException>()),
          );
        });

        test('should mark table as cleaned successfully', () {
          final dirtyTable = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.needsCleaning,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          final cleanedTable = dirtyTable.markCleaned();

          expect(cleanedTable.status, equals(TableStatus.available));
          expect(cleanedTable.lastCleanedAt, isNotNull);
        });

        test('should mark cleaning table as cleaned successfully', () {
          final cleaningTable = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.cleaning,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          final cleanedTable = cleaningTable.markCleaned();

          expect(cleanedTable.status, equals(TableStatus.available));
          expect(cleanedTable.lastCleanedAt, isNotNull);
        });

        test('should throw exception when marking non-cleanable table as cleaned', () {
          final availableTable = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          expect(
            () => availableTable.markCleaned(),
            throwsA(isA<DomainException>()),
          );
        });

        test('should reserve table successfully', () {
          final availableTable = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          final reservedTable = availableTable.reserve(reservationId);

          expect(reservedTable.status, equals(TableStatus.reserved));
          expect(reservedTable.currentReservationId, equals(reservationId));
        });

        test('should throw exception when reserving unavailable table', () {
          final occupiedTable = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.occupied,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          expect(
            () => occupiedTable.reserve(reservationId),
            throwsA(isA<DomainException>()),
          );
        });
      });

      group('equality', () {
        test('should be equal when ids are the same', () {
          final table1 = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          final table2 = Table(
            id: tableId,
            tableNumber: 'T2',
            capacity: 6,
            section: TableSection.bar,
            status: TableStatus.occupied,
            requirements: [TableRequirement.quiet],
            isActive: false,
            createdAt: createdAt,
          );

          expect(table1, equals(table2));
          expect(table1.hashCode, equals(table2.hashCode));
        });

        test('should not be equal when ids are different', () {
          final table1 = Table(
            id: tableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          final differentTableId = UserId('different-table-id');
          final table2 = Table(
            id: differentTableId,
            tableNumber: 'T1',
            capacity: 4,
            section: TableSection.mainDining,
            status: TableStatus.available,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          expect(table1, isNot(equals(table2)));
        });
      });

      group('string representation', () {
        test('should have meaningful toString', () {
          final table = Table(
            id: tableId,
            tableNumber: 'T-12',
            capacity: 6,
            section: TableSection.patio,
            status: TableStatus.occupied,
            requirements: [],
            isActive: true,
            createdAt: createdAt,
          );

          final stringRep = table.toString();

          expect(stringRep, contains('Table'));
          expect(stringRep, contains('T-12'));
          expect(stringRep, contains('6'));
          expect(stringRep, contains('occupied'));
        });
      });
    });

    group('Customer', () {
      group('creation', () {
        test('should create Customer with valid data', () {
          final customer = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            email: 'john.doe@example.com',
            phone: '+1-555-0123',
            dietaryRestrictions: [
              DietaryRestriction.vegetarian,
              DietaryRestriction.glutenFree,
            ],
            allergens: ['nuts', 'dairy'],
            preferences: {
              'spice_level': 'medium',
              'seating': 'window',
            },
            orderHistory: [orderId],
            visitCount: 5,
            lastVisit: createdAt.subtract(const Duration(days: 7)),
            averageOrderValue: 45.50,
            isVip: false,
            notes: 'Prefers quiet seating',
            createdAt: createdAt,
          );

          expect(customer.id, equals(customerId));
          expect(customer.firstName, equals('John'));
          expect(customer.lastName, equals('Doe'));
          expect(customer.email, equals('john.doe@example.com'));
          expect(customer.phone, equals('+1-555-0123'));
          expect(customer.dietaryRestrictions.length, equals(2));
          expect(customer.allergens.length, equals(2));
          expect(customer.preferences.length, equals(2));
          expect(customer.orderHistory.length, equals(1));
          expect(customer.visitCount, equals(5));
          expect(customer.lastVisit, isNotNull);
          expect(customer.averageOrderValue, equals(45.50));
          expect(customer.isVip, isFalse);
          expect(customer.notes, equals('Prefers quiet seating'));
          expect(customer.createdAt, equals(createdAt));
          expect(customer.updatedAt, equals(createdAt));
        });

        test('should create Customer with minimum required fields', () {
          final customer = Customer(
            id: customerId,
            firstName: 'Jane',
            lastName: 'Smith',
            createdAt: createdAt,
          );

          expect(customer.id, equals(customerId));
          expect(customer.firstName, equals('Jane'));
          expect(customer.lastName, equals('Smith'));
          expect(customer.email, isNull);
          expect(customer.phone, isNull);
          expect(customer.dietaryRestrictions, isEmpty);
          expect(customer.allergens, isEmpty);
          expect(customer.preferences, isEmpty);
          expect(customer.orderHistory, isEmpty);
          expect(customer.visitCount, equals(0));
          expect(customer.lastVisit, isNull);
          expect(customer.averageOrderValue, isNull);
          expect(customer.isVip, isFalse);
          expect(customer.notes, isNull);
        });

        test('should throw DomainException for empty first name', () {
          expect(
            () => Customer(
              id: customerId,
              firstName: '',
              lastName: 'Doe',
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException for empty last name', () {
          expect(
            () => Customer(
              id: customerId,
              firstName: 'John',
              lastName: '',
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException for name too long', () {
          final longName = 'A' * 101; // Exceeds 100 character limit

          expect(
            () => Customer(
              id: customerId,
              firstName: longName,
              lastName: 'Doe',
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException for invalid email', () {
          expect(
            () => Customer(
              id: customerId,
              firstName: 'John',
              lastName: 'Doe',
              email: 'invalid-email',
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should normalize email to lowercase', () {
          final customer = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            email: 'John.DOE@EXAMPLE.COM',
            createdAt: createdAt,
          );

          expect(customer.email, equals('john.doe@example.com'));
        });

        test('should trim whitespace from names', () {
          final customer = Customer(
            id: customerId,
            firstName: '  John  ',
            lastName: '  Doe  ',
            createdAt: createdAt,
          );

          expect(customer.firstName, equals('John'));
          expect(customer.lastName, equals('Doe'));
        });

        test('should handle null email and phone gracefully', () {
          final customer = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            email: null,
            phone: null,
            createdAt: createdAt,
          );

          expect(customer.email, isNull);
          expect(customer.phone, isNull);
        });

        test('should handle empty email and phone strings', () {
          final customer = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            email: '',
            phone: '',
            createdAt: createdAt,
          );

          expect(customer.email, isNull);
          expect(customer.phone, isNull);
        });
      });

      group('business rules', () {
        test('should generate correct full name', () {
          final customer = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            createdAt: createdAt,
          );

          expect(customer.fullName, equals('John Doe'));
        });

        test('should generate correct display name for regular customer', () {
          final customer = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            isVip: false,
            createdAt: createdAt,
          );

          expect(customer.displayName, equals('John Doe'));
        });

        test('should generate correct display name for VIP customer', () {
          final customer = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            isVip: true,
            createdAt: createdAt,
          );

          expect(customer.displayName, equals('⭐ John Doe'));
        });

        test('should check for dietary restrictions correctly', () {
          final customer = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            dietaryRestrictions: [
              DietaryRestriction.vegetarian,
              DietaryRestriction.glutenFree,
            ],
            createdAt: createdAt,
          );

          expect(customer.hasDietaryRestriction(DietaryRestriction.vegetarian),
              isTrue);
          expect(customer.hasDietaryRestriction(DietaryRestriction.glutenFree),
              isTrue);
          expect(customer.hasDietaryRestriction(DietaryRestriction.vegan),
              isFalse);
        });

        test('should check for allergens correctly', () {
          final customer = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            allergens: ['nuts', 'dairy', 'SHELLFISH'],
            createdAt: createdAt,
          );

          expect(customer.hasAllergen('nuts'), isTrue);
          expect(customer.hasAllergen('NUTS'), isTrue); // Case insensitive
          expect(customer.hasAllergen('dairy'), isTrue);
          expect(customer.hasAllergen('shellfish'), isTrue); // Case insensitive
          expect(customer.hasAllergen('eggs'), isFalse);
        });

        test('should identify frequent visitors correctly', () {
          final frequentCustomer = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            visitCount: 15,
            createdAt: createdAt,
          );

          final occasionalCustomer = Customer(
            id: customerId,
            firstName: 'Jane',
            lastName: 'Smith',
            visitCount: 5,
            createdAt: createdAt,
          );

          expect(frequentCustomer.isFrequentVisitor, isTrue);
          expect(occasionalCustomer.isFrequentVisitor, isFalse);
        });

        test('should identify recent visitors correctly', () {
          final recentCustomer = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            lastVisit: createdAt.subtract(const Duration(days: 10)),
            createdAt: createdAt,
          );

          final oldCustomer = Customer(
            id: customerId,
            firstName: 'Jane',
            lastName: 'Smith',
            lastVisit: createdAt.subtract(const Duration(days: 40)),
            createdAt: createdAt,
          );

          final neverVisitedCustomer = Customer(
            id: customerId,
            firstName: 'Bob',
            lastName: 'Wilson',
            createdAt: createdAt,
          );

          expect(recentCustomer.isRecentVisitor, isTrue);
          expect(oldCustomer.isRecentVisitor, isFalse);
          expect(neverVisitedCustomer.isRecentVisitor, isFalse);
        });

        test('should calculate loyalty tiers correctly', () {
          final vipCustomer = Customer(
            id: customerId,
            firstName: 'VIP',
            lastName: 'Customer',
            visitCount: 25,
            isVip: true,
            createdAt: createdAt,
          );

          final goldCustomer = Customer(
            id: customerId,
            firstName: 'Gold',
            lastName: 'Customer',
            visitCount: 50,
            createdAt: createdAt,
          );

          final silverCustomer = Customer(
            id: customerId,
            firstName: 'Silver',
            lastName: 'Customer',
            visitCount: 25,
            createdAt: createdAt,
          );

          final bronzeCustomer = Customer(
            id: customerId,
            firstName: 'Bronze',
            lastName: 'Customer',
            visitCount: 8,
            createdAt: createdAt,
          );

          final newCustomer = Customer(
            id: customerId,
            firstName: 'New',
            lastName: 'Customer',
            visitCount: 2,
            createdAt: createdAt,
          );

          expect(vipCustomer.loyaltyTier, equals('VIP'));
          expect(goldCustomer.loyaltyTier, equals('Gold'));
          expect(silverCustomer.loyaltyTier, equals('Silver'));
          expect(bronzeCustomer.loyaltyTier, equals('Bronze'));
          expect(newCustomer.loyaltyTier, equals('New'));
        });
      });

      group('customer operations', () {
        test('should record visit successfully for first-time customer', () {
          final customer = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            visitCount: 0,
            createdAt: createdAt,
          );

          final updatedCustomer = customer.recordVisit(orderId, 35.75);

          expect(updatedCustomer.visitCount, equals(1));
          expect(updatedCustomer.orderHistory.length, equals(1));
          expect(updatedCustomer.orderHistory, contains(orderId));
          expect(updatedCustomer.averageOrderValue, equals(35.75));
          expect(updatedCustomer.lastVisit, isNotNull);
          expect(updatedCustomer.updatedAt, isNotNull);
        });

        test('should record visit successfully for existing customer', () {
          final customer = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            visitCount: 3,
            averageOrderValue: 40.0,
            orderHistory: [
              UserId('order1'),
              UserId('order2'),
              UserId('order3'),
            ],
            createdAt: createdAt,
          );

          final updatedCustomer = customer.recordVisit(orderId, 50.0);

          expect(updatedCustomer.visitCount, equals(4));
          expect(updatedCustomer.orderHistory.length, equals(4));
          expect(updatedCustomer.orderHistory, contains(orderId));
          // New average: (40.0 * 3 + 50.0) / 4 = 42.5
          expect(updatedCustomer.averageOrderValue, equals(42.5));
          expect(updatedCustomer.lastVisit, isNotNull);
        });

        test('should update preferences successfully', () {
          final customer = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            preferences: {
              'spice_level': 'mild',
              'seating': 'booth',
            },
            createdAt: createdAt,
          );

          final updatedCustomer = customer.updatePreferences({
            'spice_level': 'hot',
            'drink': 'wine',
          });

          expect(updatedCustomer.preferences.length, equals(3));
          expect(updatedCustomer.preferences['spice_level'], equals('hot'));
          expect(updatedCustomer.preferences['seating'], equals('booth'));
          expect(updatedCustomer.preferences['drink'], equals('wine'));
          expect(updatedCustomer.updatedAt, isNotNull);
        });

        test('should promote customer to VIP successfully', () {
          final customer = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            isVip: false,
            createdAt: createdAt,
          );

          final vipCustomer = customer.promoteToVip();

          expect(vipCustomer.isVip, isTrue);
          expect(vipCustomer.displayName, contains('⭐'));
          expect(vipCustomer.loyaltyTier, equals('VIP'));
          expect(vipCustomer.updatedAt, isNotNull);
        });

        test('should throw exception when promoting already VIP customer', () {
          final vipCustomer = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            isVip: true,
            createdAt: createdAt,
          );

          expect(
            () => vipCustomer.promoteToVip(),
            throwsA(isA<DomainException>()),
          );
        });
      });

      group('equality', () {
        test('should be equal when ids are the same', () {
          final customer1 = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            createdAt: createdAt,
          );

          final customer2 = Customer(
            id: customerId,
            firstName: 'Jane',
            lastName: 'Smith',
            visitCount: 10,
            isVip: true,
            createdAt: createdAt,
          );

          expect(customer1, equals(customer2));
          expect(customer1.hashCode, equals(customer2.hashCode));
        });

        test('should not be equal when ids are different', () {
          final customer1 = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            createdAt: createdAt,
          );

          final differentCustomerId = UserId('different-customer-id');
          final customer2 = Customer(
            id: differentCustomerId,
            firstName: 'John',
            lastName: 'Doe',
            createdAt: createdAt,
          );

          expect(customer1, isNot(equals(customer2)));
        });
      });

      group('string representation', () {
        test('should have meaningful toString for regular customer', () {
          final customer = Customer(
            id: customerId,
            firstName: 'John',
            lastName: 'Doe',
            visitCount: 5,
            isVip: false,
            createdAt: createdAt,
          );

          final stringRep = customer.toString();

          expect(stringRep, contains('Customer'));
          expect(stringRep, contains('John Doe'));
          expect(stringRep, contains('5'));
          expect(stringRep, contains('false'));
        });

        test('should have meaningful toString for VIP customer', () {
          final customer = Customer(
            id: customerId,
            firstName: 'Jane',
            lastName: 'Smith',
            visitCount: 15,
            isVip: true,
            createdAt: createdAt,
          );

          final stringRep = customer.toString();

          expect(stringRep, contains('Customer'));
          expect(stringRep, contains('Jane Smith'));
          expect(stringRep, contains('15'));
          expect(stringRep, contains('true'));
        });
      });
    });
  });
}