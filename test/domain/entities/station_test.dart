import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/entities/station.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';
import 'package:stacks/domain/exceptions/domain_exception.dart';

void main() {
  group('Station', () {
    late UserId stationId;
    late Time createdAt;

    setUp(() {
      stationId = UserId.generate();
      createdAt = Time.now();
    });

    group('creation', () {
      test('should create Station with valid data', () {
        final station = Station(
          id: stationId,
          name: 'Grill Station',
          capacity: 5,
          location: 'Kitchen Zone A',
          stationType: StationType.grill,
          createdAt: createdAt,
        );

        expect(station.id, equals(stationId));
        expect(station.name, equals('Grill Station'));
        expect(station.capacity, equals(5));
        expect(station.location, equals('Kitchen Zone A'));
        expect(station.stationType, equals(StationType.grill));
        expect(station.status, equals(StationStatus.available));
        expect(station.isActive, isTrue);
        expect(station.currentWorkload, equals(0));
        expect(station.assignedStaff, isEmpty);
        expect(station.currentOrders, isEmpty);
      });

      test('should create Station with minimum required fields', () {
        final station = Station(
          id: stationId,
          name: 'Simple Station',
          capacity: 1,
          stationType: StationType.prep,
          createdAt: createdAt,
        );

        expect(station.location, isNull);
        expect(station.status, equals(StationStatus.available));
        expect(station.isActive, isTrue);
      });

      test('should throw DomainException for empty name', () {
        expect(
          () => Station(
            id: stationId,
            name: '',
            capacity: 5,
            stationType: StationType.grill,
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw DomainException for name too long', () {
        final longName = 'A' * 101; // Exceeds max length
        expect(
          () => Station(
            id: stationId,
            name: longName,
            capacity: 5,
            stationType: StationType.grill,
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw DomainException for zero capacity', () {
        expect(
          () => Station(
            id: stationId,
            name: 'Test Station',
            capacity: 0,
            stationType: StationType.grill,
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw DomainException for negative capacity', () {
        expect(
          () => Station(
            id: stationId,
            name: 'Test Station',
            capacity: -1,
            stationType: StationType.grill,
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });
    });

    group('status management', () {
      test('should activate inactive station', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          createdAt: createdAt,
          isActive: false,
        );

        final activatedStation = station.activate();

        expect(activatedStation.isActive, isTrue);
        expect(activatedStation.status, equals(StationStatus.available));
      });

      test('should deactivate active station', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          createdAt: createdAt,
        );

        final deactivatedStation = station.deactivate();

        expect(deactivatedStation.isActive, isFalse);
        expect(deactivatedStation.status, equals(StationStatus.offline));
      });

      test('should set station to maintenance mode', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          createdAt: createdAt,
        );

        final maintenanceStation = station.setMaintenance();

        expect(maintenanceStation.status, equals(StationStatus.maintenance));
        expect(maintenanceStation.isActive, isTrue);
      });

      test('should set station to busy status', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          createdAt: createdAt,
        );

        final busyStation = station.setBusy();

        expect(busyStation.status, equals(StationStatus.busy));
      });

      test('should set station to available status', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          status: StationStatus.busy,
          createdAt: createdAt,
        );

        final availableStation = station.setAvailable();

        expect(availableStation.status, equals(StationStatus.available));
      });
    });

    group('staff management', () {
      test('should assign staff to station', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          createdAt: createdAt,
        );

        final staffId = UserId('staff123');
        final updatedStation = station.assignStaff(staffId);

        expect(updatedStation.assignedStaff, contains(staffId));
        expect(updatedStation.assignedStaff.length, equals(1));
      });

      test('should not assign same staff twice', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          createdAt: createdAt,
        );

        final staffId = UserId('staff123');
        final stationWithStaff = station.assignStaff(staffId);

        expect(
          () => stationWithStaff.assignStaff(staffId),
          throwsA(isA<DomainException>()),
        );
      });

      test('should unassign staff from station', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          createdAt: createdAt,
          assignedStaff: [UserId('staff123')],
        );

        final staffId = UserId('staff123');
        final updatedStation = station.unassignStaff(staffId);

        expect(updatedStation.assignedStaff, isEmpty);
      });

      test('should throw exception when unassigning non-assigned staff', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          createdAt: createdAt,
        );

        final staffId = UserId('staff123');

        expect(
          () => station.unassignStaff(staffId),
          throwsA(isA<DomainException>()),
        );
      });
    });

    group('workload management', () {
      test('should calculate workload percentage correctly', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 10,
          stationType: StationType.grill,
          createdAt: createdAt,
          currentWorkload: 3,
        );

        expect(station.workloadPercentage, equals(30.0));
      });

      test('should identify if station is at capacity', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          createdAt: createdAt,
          currentWorkload: 5,
        );

        expect(station.isAtCapacity, isTrue);
      });

      test('should identify if station has available capacity', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          createdAt: createdAt,
          currentWorkload: 3,
        );

        expect(station.hasAvailableCapacity, isTrue);
        expect(station.availableCapacity, equals(2));
      });

      test('should update workload', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          createdAt: createdAt,
        );

        final updatedStation = station.updateWorkload(3);

        expect(updatedStation.currentWorkload, equals(3));
      });

      test('should throw exception for workload exceeding capacity', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          createdAt: createdAt,
        );

        expect(
          () => station.updateWorkload(6),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw exception for negative workload', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          createdAt: createdAt,
        );

        expect(
          () => station.updateWorkload(-1),
          throwsA(isA<DomainException>()),
        );
      });
    });

    group('station types', () {
      test('should check station type properties', () {
        final grillStation = Station(
          id: stationId,
          name: 'Grill Station',
          capacity: 5,
          stationType: StationType.grill,
          createdAt: createdAt,
        );

        final prepStation = Station(
          id: stationId,
          name: 'Prep Station',
          capacity: 3,
          stationType: StationType.prep,
          createdAt: createdAt,
        );

        expect(grillStation.isGrillStation, isTrue);
        expect(grillStation.isPrepStation, isFalse);
        expect(prepStation.isPrepStation, isTrue);
        expect(prepStation.isGrillStation, isFalse);
      });
    });

    group('business rules', () {
      test('should determine if station can accept order', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          status: StationStatus.available,
          createdAt: createdAt,
          currentWorkload: 3,
        );

        expect(station.canAcceptOrder, isTrue);
      });

      test('should not accept order when at capacity', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          status: StationStatus.available,
          createdAt: createdAt,
          currentWorkload: 5,
        );

        expect(station.canAcceptOrder, isFalse);
      });

      test('should not accept order when in maintenance', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          status: StationStatus.maintenance,
          createdAt: createdAt,
          currentWorkload: 2,
        );

        expect(station.canAcceptOrder, isFalse);
      });

      test('should not accept order when offline', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          status: StationStatus.offline,
          createdAt: createdAt,
          currentWorkload: 2,
        );

        expect(station.canAcceptOrder, isFalse);
      });
    });

    group('equality', () {
      test('should be equal when ids are the same', () {
        final station1 = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          createdAt: createdAt,
        );

        final station2 = Station(
          id: stationId,
          name: 'Different Name',
          capacity: 3,
          stationType: StationType.prep,
          createdAt: Time.now(),
        );

        expect(station1, equals(station2));
        expect(station1.hashCode, equals(station2.hashCode));
      });

      test('should not be equal when ids are different', () {
        final station1 = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          createdAt: createdAt,
        );

        final differentId = UserId('different-station-id');
        final station2 = Station(
          id: differentId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          createdAt: createdAt,
        );

        expect(station1, isNot(equals(station2)));
      });
    });

    group('string representation', () {
      test('should return string representation', () {
        final station = Station(
          id: stationId,
          name: 'Test Station',
          capacity: 5,
          stationType: StationType.grill,
          createdAt: createdAt,
        );

        final string = station.toString();
        expect(string, contains('Station'));
        expect(string, contains('Test Station'));
        expect(string, contains('grill'));
      });
    });
  });
}
