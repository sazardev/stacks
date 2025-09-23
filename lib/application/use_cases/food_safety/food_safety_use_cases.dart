import 'package:dartz/dartz.dart';
import 'package:stacks/domain/entities/food_safety.dart';
import 'package:stacks/domain/failures/failures.dart';
import 'package:stacks/domain/repositories/food_safety_repository.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';
import 'package:stacks/application/dtos/food_safety_dtos.dart';

/// Use cases for Food Safety module

// ======================== Temperature Log Use Cases ========================

/// Use case for creating a temperature log entry
class CreateTemperatureLogUseCase {
  final FoodSafetyRepository _repository;

  const CreateTemperatureLogUseCase(this._repository);

  Future<Either<Failure, TemperatureLog>> call(
    CreateTemperatureLogDto dto,
  ) async {
    try {
      final temperatureLog = TemperatureLog(
        id: UserId.generate(),
        location: _parseTemperatureLocation(dto.location),
        temperature: dto.temperature,
        unit: _parseTemperatureUnit(dto.unit),
        targetTemperature: dto.targetTemperature,
        minSafeTemperature: dto.minSafeTemperature,
        maxSafeTemperature: dto.maxSafeTemperature,
        recordedBy: UserId(dto.recordedBy),
        recordedAt: Time.now(),
        equipmentId: dto.equipmentId,
        notes: dto.notes,
        correctiveActionTaken: dto.correctiveActionTaken,
      );

      final result = await _repository.createTemperatureLog(temperatureLog);
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }
}

/// Use case for creating a food safety violation
class CreateFoodSafetyViolationUseCase {
  final FoodSafetyRepository _repository;

  const CreateFoodSafetyViolationUseCase(this._repository);

  Future<Either<Failure, FoodSafetyViolation>> call(
    CreateFoodSafetyViolationDto dto,
  ) async {
    try {
      final violation = FoodSafetyViolation(
        id: UserId.generate(),
        type: _parseViolationType(dto.type),
        severity: _parseViolationSeverity(dto.severity),
        description: dto.description,
        location: dto.location != null
            ? _parseTemperatureLocation(dto.location!)
            : null,
        reportedBy: dto.reportedBy != null ? UserId(dto.reportedBy!) : null,
        assignedTo: dto.assignedTo != null ? UserId(dto.assignedTo!) : null,
        reportedAt: Time.now(),
        correctiveActions: dto.correctiveActions,
        rootCause: dto.rootCause,
        preventiveAction: dto.preventiveAction,
        temperatureReading: dto.temperatureReading,
        orderId: dto.orderId != null ? UserId(dto.orderId!) : null,
        inventoryItemId: dto.inventoryItemId != null
            ? UserId(dto.inventoryItemId!)
            : null,
      );

      final result = await _repository.createFoodSafetyViolation(violation);
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }
}

/// Use case for creating a HACCP control point
class CreateHACCPControlPointUseCase {
  final FoodSafetyRepository _repository;

  const CreateHACCPControlPointUseCase(this._repository);

  Future<Either<Failure, HACCPControlPoint>> call(
    CreateHACCPControlPointDto dto,
  ) async {
    try {
      final controlPoint = HACCPControlPoint(
        id: UserId.generate(),
        type: _parseCCPType(dto.type),
        name: dto.name,
        monitoringProcedure: dto.monitoringProcedure,
        criticalLimit: dto.criticalLimit,
        temperatureUnit: dto.temperatureUnit != null
            ? _parseTemperatureUnit(dto.temperatureUnit!)
            : null,
        monitoringFrequency: Duration(minutes: dto.monitoringFrequencyMinutes),
        correctiveActions: dto.correctiveActions,
        responsibleUser: UserId(dto.responsibleUser),
        createdAt: Time.now(),
      );

      final result = await _repository.createHACCPControlPoint(controlPoint);
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }
}

/// Use case for creating a food safety audit
class CreateFoodSafetyAuditUseCase {
  final FoodSafetyRepository _repository;

  const CreateFoodSafetyAuditUseCase(this._repository);

  Future<Either<Failure, FoodSafetyAudit>> call(
    CreateFoodSafetyAuditDto dto,
  ) async {
    try {
      // Get referenced entities
      List<HACCPControlPoint> controlPoints = [];
      if (dto.controlPointIds != null) {
        for (final id in dto.controlPointIds!) {
          final controlPoint = await _repository.getHACCPControlPointById(
            UserId(id),
          );
          if (controlPoint != null) {
            controlPoints.add(controlPoint);
          }
        }
      }

      List<TemperatureLog> temperatureLogs = [];
      if (dto.temperatureLogIds != null) {
        for (final id in dto.temperatureLogIds!) {
          final tempLog = await _repository.getTemperatureLogById(UserId(id));
          if (tempLog != null) {
            temperatureLogs.add(tempLog);
          }
        }
      }

      List<FoodSafetyViolation> violations = [];
      if (dto.violationIds != null) {
        for (final id in dto.violationIds!) {
          final violation = await _repository.getFoodSafetyViolationById(
            UserId(id),
          );
          if (violation != null) {
            violations.add(violation);
          }
        }
      }

      final audit = FoodSafetyAudit(
        id: UserId.generate(),
        auditName: dto.auditName,
        auditDate: Time.fromDateTime(dto.auditDate),
        auditor: UserId(dto.auditor),
        controlPoints: controlPoints,
        temperatureLogs: temperatureLogs,
        violations: violations,
        overallScore: dto.overallScore,
        isPassed: dto.isPassed,
        notes: dto.notes,
        recommendations: dto.recommendations,
      );

      final result = await _repository.createFoodSafetyAudit(audit);
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }
}

/// Use case for getting unresolved violations
class GetUnresolvedViolationsUseCase {
  final FoodSafetyRepository _repository;

  const GetUnresolvedViolationsUseCase(this._repository);

  Future<Either<Failure, List<FoodSafetyViolation>>> call() async {
    try {
      final result = await _repository.getUnresolvedViolations();
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }
}

/// Use case for getting overdue violations
class GetOverdueViolationsUseCase {
  final FoodSafetyRepository _repository;

  const GetOverdueViolationsUseCase(this._repository);

  Future<Either<Failure, List<FoodSafetyViolation>>> call() async {
    try {
      final result = await _repository.getOverdueViolations();
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }
}

/// Use case for getting control points requiring monitoring
class GetControlPointsRequiringMonitoringUseCase {
  final FoodSafetyRepository _repository;

  const GetControlPointsRequiringMonitoringUseCase(this._repository);

  Future<Either<Failure, List<HACCPControlPoint>>> call() async {
    try {
      final result = await _repository.getControlPointsRequiringMonitoring();
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }
}

/// Use case for getting temperature logs requiring corrective action
class GetTemperatureLogsRequiringActionUseCase {
  final FoodSafetyRepository _repository;

  const GetTemperatureLogsRequiringActionUseCase(this._repository);

  Future<Either<Failure, List<TemperatureLog>>> call() async {
    try {
      final result = await _repository.getTemperatureLogsRequiringAction();
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }
}

/// Use case for generating HACCP compliance report
class GenerateHACCPComplianceReportUseCase {
  final FoodSafetyRepository _repository;

  const GenerateHACCPComplianceReportUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    HACCPComplianceReportDto dto,
  ) async {
    try {
      final result = await _repository.getHACCPComplianceReport(
        Time.fromDateTime(dto.startDate),
        Time.fromDateTime(dto.endDate),
      );
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }
}

/// Use case for getting food safety dashboard data
class GetFoodSafetyDashboardDataUseCase {
  final FoodSafetyRepository _repository;

  const GetFoodSafetyDashboardDataUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call() async {
    try {
      final result = await _repository.getFoodSafetyDashboardData();
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }
}

/// Use case for resolving a food safety violation
class ResolveFoodSafetyViolationUseCase {
  final FoodSafetyRepository _repository;

  const ResolveFoodSafetyViolationUseCase(this._repository);

  Future<Either<Failure, FoodSafetyViolation>> call(
    String violationId,
    List<String> correctiveActions,
    String? rootCause,
    String? preventiveAction,
  ) async {
    try {
      final result = await _repository.resolveViolation(
        UserId(violationId),
        correctiveActions,
        rootCause,
        preventiveAction,
      );
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }
}

/// Use case for updating control point monitoring
class UpdateControlPointMonitoringUseCase {
  final FoodSafetyRepository _repository;

  const UpdateControlPointMonitoringUseCase(this._repository);

  Future<Either<Failure, HACCPControlPoint>> call(String controlPointId) async {
    try {
      final result = await _repository.updateControlPointMonitoring(
        UserId(controlPointId),
        Time.now(),
      );
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }
}

/// Use case for getting temperature compliance statistics
class GetTemperatureComplianceStatsUseCase {
  final FoodSafetyRepository _repository;

  const GetTemperatureComplianceStatsUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final result = await _repository.getTemperatureComplianceStats(
        Time.fromDateTime(startDate),
        Time.fromDateTime(endDate),
      );
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }
}

/// Use case for monitoring temperature compliance
class MonitorTemperatureComplianceUseCase {
  final FoodSafetyRepository _repository;

  const MonitorTemperatureComplianceUseCase(this._repository);

  Future<Either<Failure, List<TemperatureLog>>> call(
    TemperatureMonitoringQueryDto dto,
  ) async {
    try {
      final startDate = dto.startDate != null
          ? Time.fromDateTime(dto.startDate!)
          : null;
      final endDate = dto.endDate != null
          ? Time.fromDateTime(dto.endDate!)
          : null;

      List<TemperatureLog> result;

      if (startDate != null && endDate != null) {
        result = await _repository.getTemperatureLogsByDateRange(
          startDate,
          endDate,
        );
      } else if (dto.location != null) {
        result = await _repository.getTemperatureLogsByLocation(
          _parseTemperatureLocation(dto.location!),
        );
      } else if (dto.equipmentId != null) {
        result = await _repository.getTemperatureLogsByEquipment(
          dto.equipmentId!,
        );
      } else if (dto.requiresCorrectiveAction == true) {
        result = await _repository.getTemperatureLogsRequiringAction();
      } else if (dto.isWithinSafeRange == false) {
        result = await _repository.getTemperatureLogsOutsideSafeRange();
      } else {
        result = await _repository.getTemperatureLogsOutsideSafeRange();
      }

      // Apply additional filters
      if (dto.recordedBy != null) {
        result = result
            .where((log) => log.recordedBy.value == dto.recordedBy)
            .toList();
      }

      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }
}

// ======================== Helper Methods ========================

TemperatureLocation _parseTemperatureLocation(String location) {
  switch (location.toLowerCase()) {
    case 'walkin_cooler':
    case 'walkincooler':
      return TemperatureLocation.walkInCooler;
    case 'walkin_freezer':
    case 'walkinfreezer':
      return TemperatureLocation.walkInFreezer;
    case 'prep_refrigerator':
    case 'preprefrigerator':
      return TemperatureLocation.prepRefrigerator;
    case 'display_case':
    case 'displaycase':
      return TemperatureLocation.displayCase;
    case 'grill_surface':
    case 'grillsurface':
      return TemperatureLocation.grillSurface;
    case 'fryer_oil':
    case 'fryeroil':
      return TemperatureLocation.fryerOil;
    case 'hot_holding':
    case 'hotholding':
      return TemperatureLocation.hotHolding;
    case 'cold_holding':
    case 'coldholding':
      return TemperatureLocation.coldHolding;
    case 'dishwasher_sanitizer':
    case 'dishwashersanitizer':
      return TemperatureLocation.dishwasherSanitizer;
    case 'hand_wash_sink':
    case 'handwashsink':
      return TemperatureLocation.handWashSink;
    case 'food_internal':
    case 'foodinternal':
      return TemperatureLocation.foodInternal;
    case 'ambient_room':
    case 'ambientroom':
      return TemperatureLocation.ambientRoom;
    default:
      throw ArgumentError('Invalid temperature location: $location');
  }
}

TemperatureUnit _parseTemperatureUnit(String unit) {
  switch (unit.toLowerCase()) {
    case 'celsius':
      return TemperatureUnit.celsius;
    case 'fahrenheit':
      return TemperatureUnit.fahrenheit;
    default:
      throw ArgumentError('Invalid temperature unit: $unit');
  }
}

ViolationType _parseViolationType(String type) {
  switch (type.toLowerCase()) {
    case 'temperatureviolation':
    case 'temperature_violation':
      return ViolationType.temperatureViolation;
    case 'timeviolation':
    case 'time_violation':
      return ViolationType.timeViolation;
    case 'crosscontamination':
    case 'cross_contamination':
      return ViolationType.crossContamination;
    case 'hygienebreach':
    case 'hygiene_breach':
    case 'poorhygiene':
    case 'poor_hygiene':
      return ViolationType.hygieneBreach;
    case 'equipmentfailure':
    case 'equipment_failure':
      return ViolationType.equipmentFailure;
    case 'allergencontamination':
    case 'allergen_contamination':
      return ViolationType.allergenContamination;
    case 'expiredproduct':
    case 'expired_product':
      return ViolationType.expiredProduct;
    case 'improperstorage':
    case 'improper_storage':
      return ViolationType.improperStorage;
    case 'cleaningviolation':
    case 'cleaning_violation':
      return ViolationType.cleaningViolation;
    case 'documentationmissing':
    case 'documentation_missing':
      return ViolationType.documentationMissing;
    default:
      throw ArgumentError('Invalid violation type: $type');
  }
}

ViolationSeverity _parseViolationSeverity(String severity) {
  switch (severity.toLowerCase()) {
    case 'emergency':
      return ViolationSeverity.emergency;
    case 'critical':
      return ViolationSeverity.critical;
    case 'major':
      return ViolationSeverity.major;
    case 'minor':
      return ViolationSeverity.minor;
    default:
      throw ArgumentError('Invalid violation severity: $severity');
  }
}

CCPType _parseCCPType(String type) {
  switch (type.toLowerCase()) {
    case 'receiving':
      return CCPType.receiving;
    case 'storage':
      return CCPType.storage;
    case 'cooking':
      return CCPType.cooking;
    case 'hotholding':
    case 'hot_holding':
      return CCPType.hotHolding;
    case 'coldholding':
    case 'cold_holding':
      return CCPType.coldHolding;
    case 'cooling':
      return CCPType.cooling;
    case 'reheating':
      return CCPType.reheating;
    case 'sanitizerconcentration':
    case 'sanitizer_concentration':
      return CCPType.sanitizerConcentration;
    case 'handwashing':
    case 'hand_washing':
      return CCPType.handWashing;
    case 'crosscontaminationprevention':
    case 'cross_contamination_prevention':
      return CCPType.crossContaminationPrevention;
    default:
      throw ArgumentError('Invalid CCP type: $type');
  }
}
