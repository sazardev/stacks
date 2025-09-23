import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/entities/food_safety.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';
import 'package:stacks/domain/exceptions/domain_exception.dart';

void main() {
  group('Food Safety', () {
    late UserId tempLogId;
    late UserId violationId;
    late UserId auditId;
    late UserId ccpId;
    late UserId userId;
    late Time recordedAt;
    late Time auditTime;

    setUp(() {
      tempLogId = UserId('temp-log-001');
      violationId = UserId('violation-001');
      auditId = UserId('audit-001');
      ccpId = UserId('ccp-001');
      userId = UserId('user-001');
      recordedAt = Time.now();
      auditTime = Time.now();
    });

    group('TemperatureLog', () {
      group('creation', () {
        test('should create TemperatureLog with valid data', () {
          final tempLog = TemperatureLog(
            id: tempLogId,
            location: TemperatureLocation.walkInCooler,
            temperature: 38.5,
            unit: TemperatureUnit.celsius,
            targetTemperature: 37.0,
            minSafeTemperature: 35.0,
            maxSafeTemperature: 40.0,
            recordedBy: userId,
            recordedAt: recordedAt,
            equipmentId: 'cooler-001',
            notes: 'Temperature within safe range',
            correctiveActionTaken: null,
          );

          expect(tempLog.id, equals(tempLogId));
          expect(tempLog.location, equals(TemperatureLocation.walkInCooler));
          expect(tempLog.temperature, equals(38.5));
          expect(tempLog.unit, equals(TemperatureUnit.celsius));
          expect(tempLog.targetTemperature, equals(37.0));
          expect(tempLog.minSafeTemperature, equals(35.0));
          expect(tempLog.maxSafeTemperature, equals(40.0));
          expect(tempLog.recordedBy, equals(userId));
          expect(tempLog.isWithinSafeRange, isTrue);
          expect(tempLog.equipmentId, equals('cooler-001'));
          expect(tempLog.notes, equals('Temperature within safe range'));
        });

        test('should create TemperatureLog with minimum required fields', () {
          final tempLog = TemperatureLog(
            id: tempLogId,
            location: TemperatureLocation.prepRefrigerator,
            temperature: 4.0,
            unit: TemperatureUnit.celsius,
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          expect(tempLog.id, equals(tempLogId));
          expect(tempLog.equipmentId, isNull);
          expect(tempLog.notes, isNull);
          expect(tempLog.targetTemperature, isNull);
        });

        test('should throw DomainException for extreme temperature', () {
          expect(
            () => TemperatureLog(
              id: tempLogId,
              location: TemperatureLocation.grillSurface,
              temperature: 600.0, // Too high
              unit: TemperatureUnit.celsius,
              recordedBy: userId,
              recordedAt: recordedAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException for excessively long notes', () {
          final longNotes = 'a' * 600; // Exceeds 500 char limit

          expect(
            () => TemperatureLog(
              id: tempLogId,
              location: TemperatureLocation.coldHolding,
              temperature: 4.0,
              unit: TemperatureUnit.celsius,
              recordedBy: userId,
              recordedAt: recordedAt,
              notes: longNotes,
            ),
            throwsA(isA<DomainException>()),
          );
        });
      });

      group('business rules', () {
        test('should identify safe temperatures', () {
          final safeLog = TemperatureLog(
            id: tempLogId,
            location: TemperatureLocation.coldHolding,
            temperature: 2.5,
            unit: TemperatureUnit.celsius,
            minSafeTemperature: 0.0,
            maxSafeTemperature: 4.0,
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          expect(safeLog.isWithinSafeRange, isTrue);
          expect(safeLog.requiresCorrectiveAction, isFalse);
          expect(safeLog.violationSeverity, isNull);
        });

        test('should identify unsafe temperatures', () {
          final unsafeLog = TemperatureLog(
            id: tempLogId,
            location: TemperatureLocation.coldHolding,
            temperature: 8.0, // Above safe range
            unit: TemperatureUnit.celsius,
            minSafeTemperature: 0.0,
            maxSafeTemperature: 4.0,
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          expect(unsafeLog.isWithinSafeRange, isFalse);
          expect(unsafeLog.requiresCorrectiveAction, isTrue);
          expect(unsafeLog.violationSeverity, isNotNull);
        });

        test('should convert temperature units correctly', () {
          final celsiusLog = TemperatureLog(
            id: tempLogId,
            location: TemperatureLocation.walkInFreezer,
            temperature: 0.0, // 0°C
            unit: TemperatureUnit.celsius,
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          expect(
            celsiusLog.temperatureInFahrenheit,
            equals(32.0),
          ); // 0°C = 32°F
          expect(celsiusLog.temperatureInCelsius, equals(0.0));

          final fahrenheitLog = TemperatureLog(
            id: UserId('temp-log-002'),
            location: TemperatureLocation.walkInFreezer,
            temperature: 32.0, // 32°F
            unit: TemperatureUnit.fahrenheit,
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          expect(fahrenheitLog.temperatureInCelsius, equals(0.0)); // 32°F = 0°C
          expect(fahrenheitLog.temperatureInFahrenheit, equals(32.0));
        });

        test('should calculate deviation from target', () {
          final log = TemperatureLog(
            id: tempLogId,
            location: TemperatureLocation.hotHolding,
            temperature: 65.0,
            unit: TemperatureUnit.celsius,
            targetTemperature: 63.0,
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          expect(log.deviationFromTarget, equals(2.0)); // 65.0 - 63.0
        });

        test('should categorize violation severity', () {
          final minorViolation = TemperatureLog(
            id: tempLogId,
            location: TemperatureLocation.coldHolding,
            temperature: 5.0, // 1°C above target of 4°C
            unit: TemperatureUnit.celsius,
            targetTemperature: 4.0,
            maxSafeTemperature: 4.0,
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          final majorViolation = TemperatureLog(
            id: UserId('temp-log-002'),
            location: TemperatureLocation.coldHolding,
            temperature: 12.0, // 8°C above target
            unit: TemperatureUnit.celsius,
            targetTemperature: 4.0,
            maxSafeTemperature: 4.0,
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          final criticalViolation = TemperatureLog(
            id: UserId('temp-log-003'),
            location: TemperatureLocation.coldHolding,
            temperature: 20.0, // 16°C above target
            unit: TemperatureUnit.celsius,
            targetTemperature: 4.0,
            maxSafeTemperature: 4.0,
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          expect(
            minorViolation.violationSeverity,
            equals(ViolationSeverity.minor),
          );
          expect(
            majorViolation.violationSeverity,
            equals(ViolationSeverity.major),
          );
          expect(
            criticalViolation.violationSeverity,
            equals(ViolationSeverity.critical),
          );
        });
      });

      group('equality', () {
        test('should be equal when ids are the same', () {
          final log1 = TemperatureLog(
            id: tempLogId,
            location: TemperatureLocation.grillSurface,
            temperature: 75.0,
            unit: TemperatureUnit.celsius,
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          final log2 = TemperatureLog(
            id: tempLogId,
            location: TemperatureLocation.fryerOil,
            temperature: 180.0,
            unit: TemperatureUnit.fahrenheit,
            recordedBy: UserId('different-user'),
            recordedAt: Time.now(),
          );

          expect(log1, equals(log2));
          expect(log1.hashCode, equals(log2.hashCode));
        });

        test('should not be equal when ids are different', () {
          final log1 = TemperatureLog(
            id: tempLogId,
            location: TemperatureLocation.grillSurface,
            temperature: 75.0,
            unit: TemperatureUnit.celsius,
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          final log2 = TemperatureLog(
            id: UserId('different-temp-log'),
            location: TemperatureLocation.grillSurface,
            temperature: 75.0,
            unit: TemperatureUnit.celsius,
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          expect(log1, isNot(equals(log2)));
        });
      });

      group('string representation', () {
        test('should have meaningful toString', () {
          final log = TemperatureLog(
            id: tempLogId,
            location: TemperatureLocation.coldHolding,
            temperature: 4.0,
            unit: TemperatureUnit.celsius,
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          final stringRep = log.toString();
          expect(stringRep, contains('TemperatureLog'));
          expect(stringRep, contains('coldHolding'));
          expect(stringRep, contains('4.0'));
          expect(stringRep, contains('celsius'));
        });
      });
    });

    group('FoodSafetyViolation', () {
      group('creation', () {
        test('should create FoodSafetyViolation with valid data', () {
          final violation = FoodSafetyViolation(
            id: violationId,
            type: ViolationType.temperatureViolation,
            severity: ViolationSeverity.major,
            description: 'Refrigerator temperature exceeded safe limits',
            location: TemperatureLocation.prepRefrigerator,
            reportedBy: userId,
            reportedAt: recordedAt,
            temperatureReading: 8.5,
            correctiveActions: [
              'Adjusted thermostat',
              'Moved products to backup cooler',
            ],
          );

          expect(violation.id, equals(violationId));
          expect(violation.type, equals(ViolationType.temperatureViolation));
          expect(violation.severity, equals(ViolationSeverity.major));
          expect(
            violation.description,
            equals('Refrigerator temperature exceeded safe limits'),
          );
          expect(
            violation.location,
            equals(TemperatureLocation.prepRefrigerator),
          );
          expect(violation.reportedBy, equals(userId));
          expect(violation.isResolved, isFalse);
          expect(violation.temperatureReading, equals(8.5));
          expect(violation.correctiveActions, hasLength(2));
        });

        test(
          'should create FoodSafetyViolation with minimum required fields',
          () {
            final violation = FoodSafetyViolation(
              id: violationId,
              type: ViolationType.hygieneBreach,
              severity: ViolationSeverity.minor,
              description: 'Employee not wearing gloves during food prep',
              reportedAt: recordedAt,
            );

            expect(violation.id, equals(violationId));
            expect(violation.location, isNull);
            expect(violation.reportedBy, isNull);
            expect(violation.temperatureReading, isNull);
            expect(violation.correctiveActions, isEmpty);
          },
        );

        test('should throw DomainException for empty description', () {
          expect(
            () => FoodSafetyViolation(
              id: violationId,
              type: ViolationType.hygieneBreach,
              severity: ViolationSeverity.minor,
              description: '',
              reportedAt: recordedAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test(
          'should throw DomainException for excessively long description',
          () {
            final longDescription = 'a' * 1100; // Exceeds 1000 char limit

            expect(
              () => FoodSafetyViolation(
                id: violationId,
                type: ViolationType.hygieneBreach,
                severity: ViolationSeverity.minor,
                description: longDescription,
                reportedAt: recordedAt,
              ),
              throwsA(isA<DomainException>()),
            );
          },
        );
      });

      group('business rules', () {
        late FoodSafetyViolation violation;

        setUp(() {
          violation = FoodSafetyViolation(
            id: violationId,
            type: ViolationType.temperatureViolation,
            severity: ViolationSeverity.critical,
            description: 'Critical temperature violation',
            reportedAt: recordedAt,
          );
        });

        test('should identify overdue violations based on severity', () {
          // Create violations with past timestamps
          final emergencyViolation = FoodSafetyViolation(
            id: UserId('emergency-001'),
            type: ViolationType.crossContamination,
            severity: ViolationSeverity.emergency,
            description: 'Immediate danger',
            reportedAt: Time.now().subtract(
              Duration(minutes: 20),
            ), // 20 min ago
          );

          final criticalViolation = FoodSafetyViolation(
            id: UserId('critical-001'),
            type: ViolationType.temperatureViolation,
            severity: ViolationSeverity.critical,
            description: 'Critical temperature breach',
            reportedAt: Time.now().subtract(Duration(hours: 2)), // 2 hours ago
          );

          final majorViolation = FoodSafetyViolation(
            id: UserId('major-001'),
            type: ViolationType.hygieneBreach,
            severity: ViolationSeverity.major,
            description: 'Hygiene issue',
            reportedAt: Time.now().subtract(Duration(hours: 5)), // 5 hours ago
          );

          final minorViolation = FoodSafetyViolation(
            id: UserId('minor-001'),
            type: ViolationType.cleaningViolation,
            severity: ViolationSeverity.minor,
            description: 'Minor cleaning issue',
            reportedAt: Time.now().subtract(
              Duration(hours: 25),
            ), // 25 hours ago
          );

          expect(emergencyViolation.isOverdue, isTrue); // >15 min
          expect(criticalViolation.isOverdue, isTrue); // >1 hour
          expect(majorViolation.isOverdue, isTrue); // >4 hours
          expect(minorViolation.isOverdue, isTrue); // >24 hours
        });

        test('should calculate time since reported', () {
          final pastViolation = FoodSafetyViolation(
            id: violationId,
            type: ViolationType.temperatureViolation,
            severity: ViolationSeverity.major,
            description: 'Test violation',
            reportedAt: Time.now().subtract(Duration(hours: 2)),
          );

          final timeSince = pastViolation.timeSinceReported;
          expect(timeSince.inHours, equals(2));
        });

        test('should resolve violation with corrective actions', () {
          final resolvedViolation = violation.resolve(
            rootCause: 'Faulty thermostat',
            preventiveAction: 'Install backup temperature monitoring',
            additionalActions: [
              'Replace thermostat',
              'Train staff on monitoring',
            ],
          );

          expect(resolvedViolation.isResolved, isTrue);
          expect(resolvedViolation.rootCause, equals('Faulty thermostat'));
          expect(
            resolvedViolation.preventiveAction,
            equals('Install backup temperature monitoring'),
          );
          expect(resolvedViolation.correctiveActions, hasLength(2));
          expect(resolvedViolation.resolvedAt, isNotNull);
          expect(resolvedViolation.resolutionTime, isNotNull);
        });

        test(
          'should throw DomainException when trying to resolve already resolved violation',
          () {
            final resolvedViolation = violation.resolve(
              rootCause: 'Test cause',
              preventiveAction: 'Test action',
            );

            expect(
              () => resolvedViolation.resolve(
                rootCause: 'Another cause',
                preventiveAction: 'Another action',
              ),
              throwsA(isA<DomainException>()),
            );
          },
        );
      });

      group('equality', () {
        test('should be equal when ids are the same', () {
          final violation1 = FoodSafetyViolation(
            id: violationId,
            type: ViolationType.temperatureViolation,
            severity: ViolationSeverity.major,
            description: 'Description 1',
            reportedAt: recordedAt,
          );

          final violation2 = FoodSafetyViolation(
            id: violationId,
            type: ViolationType.hygieneBreach,
            severity: ViolationSeverity.minor,
            description: 'Different description',
            reportedAt: Time.now(),
          );

          expect(violation1, equals(violation2));
          expect(violation1.hashCode, equals(violation2.hashCode));
        });

        test('should not be equal when ids are different', () {
          final violation1 = FoodSafetyViolation(
            id: violationId,
            type: ViolationType.temperatureViolation,
            severity: ViolationSeverity.major,
            description: 'Same description',
            reportedAt: recordedAt,
          );

          final violation2 = FoodSafetyViolation(
            id: UserId('different-violation'),
            type: ViolationType.temperatureViolation,
            severity: ViolationSeverity.major,
            description: 'Same description',
            reportedAt: recordedAt,
          );

          expect(violation1, isNot(equals(violation2)));
        });
      });

      group('string representation', () {
        test('should have meaningful toString', () {
          final violation = FoodSafetyViolation(
            id: violationId,
            type: ViolationType.temperatureViolation,
            severity: ViolationSeverity.major,
            description: 'Test violation',
            reportedAt: recordedAt,
          );

          final stringRep = violation.toString();
          expect(stringRep, contains('FoodSafetyViolation'));
          expect(stringRep, contains('temperatureViolation'));
          expect(stringRep, contains('major'));
          expect(stringRep, contains('false')); // isResolved
        });
      });
    });

    group('HACCPControlPoint', () {
      group('creation', () {
        test('should create HACCPControlPoint with valid data', () {
          final ccp = HACCPControlPoint(
            id: ccpId,
            type: CCPType.storage,
            name: 'Walk-in Cooler Temperature',
            monitoringProcedure:
                'Check temperature every 2 hours using calibrated thermometer',
            criticalLimit: 4.0,
            temperatureUnit: TemperatureUnit.celsius,
            monitoringFrequency: Duration(hours: 2),
            lastMonitored: recordedAt,
            isActive: true,
            correctiveActions: [
              'Adjust thermostat',
              'Check door seals',
              'Relocate products to backup cooler',
            ],
            responsibleUser: userId,
            createdAt: recordedAt,
          );

          expect(ccp.id, equals(ccpId));
          expect(ccp.type, equals(CCPType.storage));
          expect(ccp.name, equals('Walk-in Cooler Temperature'));
          expect(ccp.criticalLimit, equals(4.0));
          expect(ccp.temperatureUnit, equals(TemperatureUnit.celsius));
          expect(ccp.monitoringFrequency, equals(Duration(hours: 2)));
          expect(ccp.isActive, isTrue);
          expect(ccp.correctiveActions, hasLength(3));
          expect(ccp.responsibleUser, equals(userId));
        });

        test(
          'should create HACCPControlPoint with minimum required fields',
          () {
            final ccp = HACCPControlPoint(
              id: ccpId,
              type: CCPType.handWashing,
              name: 'Hand Washing Compliance',
              monitoringProcedure: 'Observe hand washing every hour',
              monitoringFrequency: Duration(hours: 1),
              responsibleUser: userId,
              createdAt: recordedAt,
            );

            expect(ccp.id, equals(ccpId));
            expect(ccp.criticalLimit, isNull);
            expect(ccp.temperatureUnit, isNull);
            expect(ccp.lastMonitored, isNull);
            expect(ccp.isActive, isTrue); // Default value
            expect(ccp.correctiveActions, isEmpty);
          },
        );

        test('should throw DomainException for empty name', () {
          expect(
            () => HACCPControlPoint(
              id: ccpId,
              type: CCPType.storage,
              name: '',
              monitoringProcedure: 'Check temperature',
              monitoringFrequency: Duration(hours: 2),
              responsibleUser: userId,
              createdAt: recordedAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException for excessively long name', () {
          final longName = 'a' * 250; // Exceeds 200 char limit

          expect(
            () => HACCPControlPoint(
              id: ccpId,
              type: CCPType.storage,
              name: longName,
              monitoringProcedure: 'Check temperature',
              monitoringFrequency: Duration(hours: 2),
              responsibleUser: userId,
              createdAt: recordedAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException for empty monitoring procedure', () {
          expect(
            () => HACCPControlPoint(
              id: ccpId,
              type: CCPType.storage,
              name: 'Test CCP',
              monitoringProcedure: '',
              monitoringFrequency: Duration(hours: 2),
              responsibleUser: userId,
              createdAt: recordedAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test(
          'should throw DomainException for excessively long monitoring procedure',
          () {
            final longProcedure = 'a' * 1100; // Exceeds 1000 char limit

            expect(
              () => HACCPControlPoint(
                id: ccpId,
                type: CCPType.storage,
                name: 'Test CCP',
                monitoringProcedure: longProcedure,
                monitoringFrequency: Duration(hours: 2),
                responsibleUser: userId,
                createdAt: recordedAt,
              ),
              throwsA(isA<DomainException>()),
            );
          },
        );
      });

      group('business rules', () {
        late HACCPControlPoint ccp;

        setUp(() {
          ccp = HACCPControlPoint(
            id: ccpId,
            type: CCPType.storage,
            name: 'Test Control Point',
            monitoringProcedure: 'Test procedure',
            monitoringFrequency: Duration(hours: 2),
            lastMonitored: Time.now().subtract(
              Duration(hours: 3),
            ), // 3 hours ago
            responsibleUser: userId,
            createdAt: recordedAt,
          );
        });

        test('should identify overdue monitoring', () {
          expect(ccp.isMonitoringOverdue, isTrue); // 3 hours > 2 hour frequency
        });

        test('should calculate time until next monitoring', () {
          final recentCcp = HACCPControlPoint(
            id: ccpId,
            type: CCPType.storage,
            name: 'Recent CCP',
            monitoringProcedure: 'Test procedure',
            monitoringFrequency: Duration(hours: 4),
            lastMonitored: Time.now().subtract(
              Duration(hours: 1),
            ), // 1 hour ago
            responsibleUser: userId,
            createdAt: recordedAt,
          );

          final timeUntilNext = recentCcp.timeUntilNextMonitoring;
          expect(timeUntilNext, isNotNull);
          expect(timeUntilNext!.inHours, equals(3)); // 4 - 1 = 3 hours
        });

        test('should return zero time until next monitoring when overdue', () {
          expect(ccp.timeUntilNextMonitoring, equals(Duration.zero));
        });

        test('should record monitoring and update timestamp', () {
          final updatedCcp = ccp.recordMonitoring();

          expect(updatedCcp.id, equals(ccp.id));
          expect(updatedCcp.name, equals(ccp.name));
          expect(updatedCcp.lastMonitored, isNotNull);
          expect(updatedCcp.lastMonitored!.isAfter(ccp.lastMonitored!), isTrue);
          expect(updatedCcp.isMonitoringOverdue, isFalse);
        });

        test('should handle inactive control points', () {
          final inactiveCcp = HACCPControlPoint(
            id: ccpId,
            type: CCPType.storage,
            name: 'Inactive CCP',
            monitoringProcedure: 'Test procedure',
            monitoringFrequency: Duration(hours: 2),
            isActive: false,
            responsibleUser: userId,
            createdAt: recordedAt,
          );

          expect(
            inactiveCcp.isMonitoringOverdue,
            isTrue,
          ); // Always overdue when inactive
          expect(inactiveCcp.timeUntilNextMonitoring, equals(Duration.zero));
        });
      });

      group('equality', () {
        test('should be equal when ids are the same', () {
          final ccp1 = HACCPControlPoint(
            id: ccpId,
            type: CCPType.storage,
            name: 'CCP 1',
            monitoringProcedure: 'Procedure 1',
            monitoringFrequency: Duration(hours: 2),
            responsibleUser: userId,
            createdAt: recordedAt,
          );

          final ccp2 = HACCPControlPoint(
            id: ccpId,
            type: CCPType.cooking,
            name: 'Different CCP',
            monitoringProcedure: 'Different procedure',
            monitoringFrequency: Duration(hours: 4),
            responsibleUser: UserId('different-user'),
            createdAt: Time.now(),
          );

          expect(ccp1, equals(ccp2));
          expect(ccp1.hashCode, equals(ccp2.hashCode));
        });

        test('should not be equal when ids are different', () {
          final ccp1 = HACCPControlPoint(
            id: ccpId,
            type: CCPType.storage,
            name: 'Same CCP',
            monitoringProcedure: 'Same procedure',
            monitoringFrequency: Duration(hours: 2),
            responsibleUser: userId,
            createdAt: recordedAt,
          );

          final ccp2 = HACCPControlPoint(
            id: UserId('different-ccp'),
            type: CCPType.storage,
            name: 'Same CCP',
            monitoringProcedure: 'Same procedure',
            monitoringFrequency: Duration(hours: 2),
            responsibleUser: userId,
            createdAt: recordedAt,
          );

          expect(ccp1, isNot(equals(ccp2)));
        });
      });

      group('string representation', () {
        test('should have meaningful toString', () {
          final ccp = HACCPControlPoint(
            id: ccpId,
            type: CCPType.storage,
            name: 'Test CCP',
            monitoringProcedure: 'Test procedure',
            monitoringFrequency: Duration(hours: 2),
            isActive: true,
            responsibleUser: userId,
            createdAt: recordedAt,
          );

          final stringRep = ccp.toString();
          expect(stringRep, contains('HACCPControlPoint'));
          expect(stringRep, contains('storage'));
          expect(stringRep, contains('Test CCP'));
          expect(stringRep, contains('true'));
        });
      });
    });

    group('FoodSafetyAudit', () {
      late List<HACCPControlPoint> controlPoints;
      late List<TemperatureLog> temperatureLogs;
      late List<FoodSafetyViolation> violations;

      setUp(() {
        controlPoints = [
          HACCPControlPoint(
            id: UserId('ccp-001'),
            type: CCPType.storage,
            name: 'Storage Temperature',
            monitoringProcedure: 'Check every 2 hours',
            monitoringFrequency: Duration(hours: 2),
            responsibleUser: userId,
            createdAt: recordedAt,
          ),
          HACCPControlPoint(
            id: UserId('ccp-002'),
            type: CCPType.cooking,
            name: 'Cooking Temperature',
            monitoringProcedure: 'Check internal temperature',
            monitoringFrequency: Duration(minutes: 30),
            responsibleUser: userId,
            createdAt: recordedAt,
          ),
        ];

        temperatureLogs = [
          TemperatureLog(
            id: UserId('temp-001'),
            location: TemperatureLocation.coldHolding,
            temperature: 4.0,
            unit: TemperatureUnit.celsius,
            recordedBy: userId,
            recordedAt: recordedAt,
          ),
          TemperatureLog(
            id: UserId('temp-002'),
            location: TemperatureLocation.hotHolding,
            temperature: 65.0,
            unit: TemperatureUnit.celsius,
            recordedBy: userId,
            recordedAt: recordedAt,
          ),
        ];

        violations = [
          FoodSafetyViolation(
            id: UserId('violation-001'),
            type: ViolationType.temperatureViolation,
            severity: ViolationSeverity.critical,
            description: 'Critical temperature breach',
            reportedAt: recordedAt,
          ),
          FoodSafetyViolation(
            id: UserId('violation-002'),
            type: ViolationType.hygieneBreach,
            severity: ViolationSeverity.minor,
            description: 'Minor hygiene issue',
            reportedAt: recordedAt,
          ),
        ];
      });

      group('creation', () {
        test('should create FoodSafetyAudit with valid data', () {
          final audit = FoodSafetyAudit(
            id: auditId,
            auditName: 'Monthly Food Safety Audit',
            auditDate: auditTime,
            auditor: userId,
            controlPoints: controlPoints,
            temperatureLogs: temperatureLogs,
            violations: violations,
            overallScore: 85.5,
            isPassed: true,
            notes: 'Overall good compliance with minor issues',
            recommendations: [
              'Improve hand washing frequency',
              'Calibrate thermometers monthly',
              'Additional training on HACCP procedures',
            ],
          );

          expect(audit.id, equals(auditId));
          expect(audit.auditName, equals('Monthly Food Safety Audit'));
          expect(audit.auditDate, equals(auditTime));
          expect(audit.auditor, equals(userId));
          expect(audit.controlPoints, hasLength(2));
          expect(audit.temperatureLogs, hasLength(2));
          expect(audit.violations, hasLength(2));
          expect(audit.overallScore, equals(85.5));
          expect(audit.isPassed, isTrue);
          expect(
            audit.notes,
            equals('Overall good compliance with minor issues'),
          );
          expect(audit.recommendations, hasLength(3));
        });

        test('should create FoodSafetyAudit with minimum required fields', () {
          final audit = FoodSafetyAudit(
            id: auditId,
            auditName: 'Basic Audit',
            auditDate: auditTime,
            auditor: userId,
            overallScore: 75.0,
            isPassed: false,
          );

          expect(audit.id, equals(auditId));
          expect(audit.controlPoints, isEmpty);
          expect(audit.temperatureLogs, isEmpty);
          expect(audit.violations, isEmpty);
          expect(audit.notes, isNull);
          expect(audit.recommendations, isEmpty);
          expect(audit.overallScore, equals(75.0));
          expect(audit.isPassed, isFalse);
        });
      });

      group('business rules', () {
        late FoodSafetyAudit audit;

        setUp(() {
          audit = FoodSafetyAudit(
            id: auditId,
            auditName: 'Test Audit',
            auditDate: auditTime,
            auditor: userId,
            violations: violations,
            overallScore: 80.0,
            isPassed: true,
          );
        });

        test('should count critical violations', () {
          expect(audit.criticalViolationCount, equals(1));
        });

        test('should count temperature violations', () {
          expect(audit.temperatureViolationCount, equals(1));
        });

        test('should handle audit with no violations', () {
          final cleanAudit = FoodSafetyAudit(
            id: auditId,
            auditName: 'Clean Audit',
            auditDate: auditTime,
            auditor: userId,
            overallScore: 100.0,
            isPassed: true,
          );

          expect(cleanAudit.criticalViolationCount, equals(0));
          expect(cleanAudit.temperatureViolationCount, equals(0));
        });

        test('should handle audit with multiple violation types', () {
          final moreViolations = [
            ...violations,
            FoodSafetyViolation(
              id: UserId('violation-003'),
              type: ViolationType.temperatureViolation,
              severity: ViolationSeverity.major,
              description: 'Another temperature issue',
              reportedAt: recordedAt,
            ),
            FoodSafetyViolation(
              id: UserId('violation-004'),
              type: ViolationType.crossContamination,
              severity: ViolationSeverity.critical,
              description: 'Cross contamination risk',
              reportedAt: recordedAt,
            ),
          ];

          final complexAudit = FoodSafetyAudit(
            id: auditId,
            auditName: 'Complex Audit',
            auditDate: auditTime,
            auditor: userId,
            violations: moreViolations,
            overallScore: 65.0,
            isPassed: false,
          );

          expect(
            complexAudit.criticalViolationCount,
            equals(2),
          ); // Original + new critical
          expect(
            complexAudit.temperatureViolationCount,
            equals(2),
          ); // Original + new temp
        });
      });

      group('equality', () {
        test('should be equal when ids are the same', () {
          final audit1 = FoodSafetyAudit(
            id: auditId,
            auditName: 'Audit 1',
            auditDate: auditTime,
            auditor: userId,
            overallScore: 80.0,
            isPassed: true,
          );

          final audit2 = FoodSafetyAudit(
            id: auditId,
            auditName: 'Different Audit',
            auditDate: Time.now(),
            auditor: UserId('different-auditor'),
            overallScore: 60.0,
            isPassed: false,
          );

          expect(audit1, equals(audit2));
          expect(audit1.hashCode, equals(audit2.hashCode));
        });

        test('should not be equal when ids are different', () {
          final audit1 = FoodSafetyAudit(
            id: auditId,
            auditName: 'Same Audit',
            auditDate: auditTime,
            auditor: userId,
            overallScore: 80.0,
            isPassed: true,
          );

          final audit2 = FoodSafetyAudit(
            id: UserId('different-audit'),
            auditName: 'Same Audit',
            auditDate: auditTime,
            auditor: userId,
            overallScore: 80.0,
            isPassed: true,
          );

          expect(audit1, isNot(equals(audit2)));
        });
      });

      group('string representation', () {
        test('should have meaningful toString', () {
          final audit = FoodSafetyAudit(
            id: auditId,
            auditName: 'Test Audit',
            auditDate: auditTime,
            auditor: userId,
            overallScore: 85.5,
            isPassed: true,
          );

          final stringRep = audit.toString();
          expect(stringRep, contains('FoodSafetyAudit'));
          expect(stringRep, contains('Test Audit'));
          expect(stringRep, contains('85.5'));
          expect(stringRep, contains('true'));
        });
      });
    });
  });
}
