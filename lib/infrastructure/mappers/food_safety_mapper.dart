// Food Safety Mapper for Clean Architecture Infrastructure Layer
// Handles conversion between Food Safety entities and Firestore documents

import 'package:injectable/injectable.dart';
import '../../domain/entities/food_safety.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';

@LazySingleton()
class FoodSafetyMapper {
  /// Converts TemperatureLog entity to Firestore document map
  Map<String, dynamic> temperatureLogToFirestore(TemperatureLog log) {
    return {
      'id': log.id.value,
      'location': _temperatureLocationToString(log.location),
      'temperature': log.temperature,
      'unit': _temperatureUnitToString(log.unit),
      'targetTemperature': log.targetTemperature,
      'minSafeTemperature': log.minSafeTemperature,
      'maxSafeTemperature': log.maxSafeTemperature,
      'isWithinSafeRange': log.isWithinSafeRange,
      'recordedBy': log.recordedBy.value,
      'recordedAt': log.recordedAt.millisecondsSinceEpoch,
      'equipmentId': log.equipmentId,
      'notes': log.notes,
      'requiresCorrectiveAction': log.requiresCorrectiveAction,
      'correctiveActionTaken': log.correctiveActionTaken,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Converts Firestore document to TemperatureLog entity
  TemperatureLog temperatureLogFromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return TemperatureLog(
      id: UserId(id),
      location: _temperatureLocationFromString(data['location'] as String),
      temperature: (data['temperature'] as num).toDouble(),
      unit: _temperatureUnitFromString(data['unit'] as String),
      targetTemperature: data['targetTemperature'] != null
          ? (data['targetTemperature'] as num).toDouble()
          : null,
      minSafeTemperature: data['minSafeTemperature'] != null
          ? (data['minSafeTemperature'] as num).toDouble()
          : null,
      maxSafeTemperature: data['maxSafeTemperature'] != null
          ? (data['maxSafeTemperature'] as num).toDouble()
          : null,
      recordedBy: UserId(data['recordedBy'] as String),
      recordedAt: Time.fromMillisecondsSinceEpoch(data['recordedAt'] as int),
      equipmentId: data['equipmentId'] as String?,
      notes: data['notes'] as String?,
      correctiveActionTaken: data['correctiveActionTaken'] as String?,
    );
  }

  /// Converts FoodSafetyViolation entity to Firestore document map
  Map<String, dynamic> violationToFirestore(FoodSafetyViolation violation) {
    return {
      'id': violation.id.value,
      'type': _violationTypeToString(violation.type),
      'severity': _violationSeverityToString(violation.severity),
      'description': violation.description,
      'location': violation.location != null
          ? _temperatureLocationToString(violation.location!)
          : null,
      'reportedBy': violation.reportedBy?.value,
      'assignedTo': violation.assignedTo?.value,
      'reportedAt': violation.reportedAt.millisecondsSinceEpoch,
      'resolvedAt': violation.resolvedAt?.millisecondsSinceEpoch,
      'isResolved': violation.isResolved,
      'correctiveActions': violation.correctiveActions,
      'rootCause': violation.rootCause,
      'preventiveAction': violation.preventiveAction,
      'temperatureReading': violation.temperatureReading,
      'orderId': violation.orderId?.value,
      'inventoryItemId': violation.inventoryItemId?.value,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Converts Firestore document to FoodSafetyViolation entity
  FoodSafetyViolation violationFromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return FoodSafetyViolation(
      id: UserId(id),
      type: _violationTypeFromString(data['type'] as String),
      severity: _violationSeverityFromString(data['severity'] as String),
      description: data['description'] as String,
      location: data['location'] != null
          ? _temperatureLocationFromString(data['location'] as String)
          : null,
      reportedBy: data['reportedBy'] != null
          ? UserId(data['reportedBy'] as String)
          : null,
      assignedTo: data['assignedTo'] != null
          ? UserId(data['assignedTo'] as String)
          : null,
      reportedAt: Time.fromMillisecondsSinceEpoch(data['reportedAt'] as int),
      resolvedAt: data['resolvedAt'] != null
          ? Time.fromMillisecondsSinceEpoch(data['resolvedAt'] as int)
          : null,
      isResolved: data['isResolved'] as bool? ?? false,
      correctiveActions: List<String>.from(
        data['correctiveActions'] as List? ?? [],
      ),
      rootCause: data['rootCause'] as String?,
      preventiveAction: data['preventiveAction'] as String?,
      temperatureReading: data['temperatureReading'] != null
          ? (data['temperatureReading'] as num).toDouble()
          : null,
      orderId: data['orderId'] != null
          ? UserId(data['orderId'] as String)
          : null,
      inventoryItemId: data['inventoryItemId'] != null
          ? UserId(data['inventoryItemId'] as String)
          : null,
    );
  }

  /// Converts HACCPControlPoint entity to Firestore document map
  Map<String, dynamic> haccpControlPointToFirestore(
    HACCPControlPoint controlPoint,
  ) {
    return {
      'id': controlPoint.id.value,
      'type': _ccpTypeToString(controlPoint.type),
      'name': controlPoint.name,
      'monitoringProcedure': controlPoint.monitoringProcedure,
      'criticalLimit': controlPoint.criticalLimit,
      'temperatureUnit': controlPoint.temperatureUnit != null
          ? _temperatureUnitToString(controlPoint.temperatureUnit!)
          : null,
      'monitoringFrequency': controlPoint.monitoringFrequency.inMinutes,
      'lastMonitored': controlPoint.lastMonitored?.millisecondsSinceEpoch,
      'isActive': controlPoint.isActive,
      'correctiveActions': controlPoint.correctiveActions,
      'responsibleUser': controlPoint.responsibleUser.value,
      'createdAt': controlPoint.createdAt.millisecondsSinceEpoch,
    };
  }

  /// Converts Firestore document to HACCPControlPoint entity
  HACCPControlPoint haccpControlPointFromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return HACCPControlPoint(
      id: UserId(id),
      type: _ccpTypeFromString(data['type'] as String),
      name: data['name'] as String,
      monitoringProcedure: data['monitoringProcedure'] as String,
      criticalLimit: data['criticalLimit'] != null
          ? (data['criticalLimit'] as num).toDouble()
          : null,
      temperatureUnit: data['temperatureUnit'] != null
          ? _temperatureUnitFromString(data['temperatureUnit'] as String)
          : null,
      monitoringFrequency: Duration(
        minutes: data['monitoringFrequency'] as int,
      ),
      lastMonitored: data['lastMonitored'] != null
          ? Time.fromMillisecondsSinceEpoch(data['lastMonitored'] as int)
          : null,
      isActive: data['isActive'] as bool? ?? true,
      correctiveActions: List<String>.from(
        data['correctiveActions'] as List? ?? [],
      ),
      responsibleUser: UserId(data['responsibleUser'] as String),
      createdAt: Time.fromMillisecondsSinceEpoch(data['createdAt'] as int),
    );
  }

  /// Converts FoodSafetyAudit entity to Firestore document map
  Map<String, dynamic> auditToFirestore(FoodSafetyAudit audit) {
    return {
      'id': audit.id.value,
      'auditName': audit.auditName,
      'auditDate': audit.auditDate.millisecondsSinceEpoch,
      'auditor': audit.auditor.value,
      'controlPoints': audit.controlPoints
          .map((cp) => haccpControlPointToFirestore(cp))
          .toList(),
      'temperatureLogs': audit.temperatureLogs
          .map((log) => temperatureLogToFirestore(log))
          .toList(),
      'violations': audit.violations
          .map((v) => violationToFirestore(v))
          .toList(),
      'overallScore': audit.overallScore,
      'isPassed': audit.isPassed,
      'notes': audit.notes,
      'recommendations': audit.recommendations,
    };
  }

  /// Converts Firestore document to FoodSafetyAudit entity
  FoodSafetyAudit auditFromFirestore(Map<String, dynamic> data, String id) {
    return FoodSafetyAudit(
      id: UserId(id),
      auditName: data['auditName'] as String,
      auditDate: Time.fromMillisecondsSinceEpoch(data['auditDate'] as int),
      auditor: UserId(data['auditor'] as String),
      controlPoints: (data['controlPoints'] as List? ?? [])
          .map(
            (cp) => haccpControlPointFromFirestore(
              cp as Map<String, dynamic>,
              cp['id'] as String,
            ),
          )
          .toList(),
      temperatureLogs: (data['temperatureLogs'] as List? ?? [])
          .map(
            (log) => temperatureLogFromFirestore(
              log as Map<String, dynamic>,
              log['id'] as String,
            ),
          )
          .toList(),
      violations: (data['violations'] as List? ?? [])
          .map(
            (v) => violationFromFirestore(
              v as Map<String, dynamic>,
              v['id'] as String,
            ),
          )
          .toList(),
      overallScore: (data['overallScore'] as num).toDouble(),
      isPassed: data['isPassed'] as bool,
      notes: data['notes'] as String?,
      recommendations: List<String>.from(
        data['recommendations'] as List? ?? [],
      ),
    );
  }

  // Public methods for repository use
  String temperatureLocationToString(TemperatureLocation location) =>
      _temperatureLocationToString(location);

  String violationTypeToString(ViolationType type) =>
      _violationTypeToString(type);

  String violationSeverityToString(ViolationSeverity severity) =>
      _violationSeverityToString(severity);

  String ccpTypeToString(CCPType type) => _ccpTypeToString(type);

  // Enum conversion methods
  String _temperatureLocationToString(TemperatureLocation location) {
    switch (location) {
      case TemperatureLocation.walkInCooler:
        return 'walk_in_cooler';
      case TemperatureLocation.walkInFreezer:
        return 'walk_in_freezer';
      case TemperatureLocation.prepRefrigerator:
        return 'prep_refrigerator';
      case TemperatureLocation.displayCase:
        return 'display_case';
      case TemperatureLocation.grillSurface:
        return 'grill_surface';
      case TemperatureLocation.fryerOil:
        return 'fryer_oil';
      case TemperatureLocation.hotHolding:
        return 'hot_holding';
      case TemperatureLocation.coldHolding:
        return 'cold_holding';
      case TemperatureLocation.dishwasherSanitizer:
        return 'dishwasher_sanitizer';
      case TemperatureLocation.handWashSink:
        return 'hand_wash_sink';
      case TemperatureLocation.foodInternal:
        return 'food_internal';
      case TemperatureLocation.ambientRoom:
        return 'ambient_room';
    }
  }

  TemperatureLocation _temperatureLocationFromString(String location) {
    switch (location) {
      case 'walk_in_cooler':
        return TemperatureLocation.walkInCooler;
      case 'walk_in_freezer':
        return TemperatureLocation.walkInFreezer;
      case 'prep_refrigerator':
        return TemperatureLocation.prepRefrigerator;
      case 'display_case':
        return TemperatureLocation.displayCase;
      case 'grill_surface':
        return TemperatureLocation.grillSurface;
      case 'fryer_oil':
        return TemperatureLocation.fryerOil;
      case 'hot_holding':
        return TemperatureLocation.hotHolding;
      case 'cold_holding':
        return TemperatureLocation.coldHolding;
      case 'dishwasher_sanitizer':
        return TemperatureLocation.dishwasherSanitizer;
      case 'hand_wash_sink':
        return TemperatureLocation.handWashSink;
      case 'food_internal':
        return TemperatureLocation.foodInternal;
      case 'ambient_room':
        return TemperatureLocation.ambientRoom;
      default:
        return TemperatureLocation.ambientRoom;
    }
  }

  String _temperatureUnitToString(TemperatureUnit unit) {
    switch (unit) {
      case TemperatureUnit.fahrenheit:
        return 'fahrenheit';
      case TemperatureUnit.celsius:
        return 'celsius';
    }
  }

  TemperatureUnit _temperatureUnitFromString(String unit) {
    switch (unit) {
      case 'fahrenheit':
        return TemperatureUnit.fahrenheit;
      case 'celsius':
        return TemperatureUnit.celsius;
      default:
        return TemperatureUnit.fahrenheit;
    }
  }

  String _violationTypeToString(ViolationType type) {
    switch (type) {
      case ViolationType.temperatureViolation:
        return 'temperature_violation';
      case ViolationType.timeViolation:
        return 'time_violation';
      case ViolationType.crossContamination:
        return 'cross_contamination';
      case ViolationType.hygieneBreach:
        return 'hygiene_breach';
      case ViolationType.equipmentFailure:
        return 'equipment_failure';
      case ViolationType.allergenContamination:
        return 'allergen_contamination';
      case ViolationType.expiredProduct:
        return 'expired_product';
      case ViolationType.improperStorage:
        return 'improper_storage';
      case ViolationType.cleaningViolation:
        return 'cleaning_violation';
      case ViolationType.documentationMissing:
        return 'documentation_missing';
    }
  }

  ViolationType _violationTypeFromString(String type) {
    switch (type) {
      case 'temperature_violation':
        return ViolationType.temperatureViolation;
      case 'time_violation':
        return ViolationType.timeViolation;
      case 'cross_contamination':
        return ViolationType.crossContamination;
      case 'hygiene_breach':
        return ViolationType.hygieneBreach;
      case 'equipment_failure':
        return ViolationType.equipmentFailure;
      case 'allergen_contamination':
        return ViolationType.allergenContamination;
      case 'expired_product':
        return ViolationType.expiredProduct;
      case 'improper_storage':
        return ViolationType.improperStorage;
      case 'cleaning_violation':
        return ViolationType.cleaningViolation;
      case 'documentation_missing':
        return ViolationType.documentationMissing;
      default:
        return ViolationType.hygieneBreach;
    }
  }

  String _violationSeverityToString(ViolationSeverity severity) {
    switch (severity) {
      case ViolationSeverity.minor:
        return 'minor';
      case ViolationSeverity.major:
        return 'major';
      case ViolationSeverity.critical:
        return 'critical';
      case ViolationSeverity.emergency:
        return 'emergency';
    }
  }

  ViolationSeverity _violationSeverityFromString(String severity) {
    switch (severity) {
      case 'minor':
        return ViolationSeverity.minor;
      case 'major':
        return ViolationSeverity.major;
      case 'critical':
        return ViolationSeverity.critical;
      case 'emergency':
        return ViolationSeverity.emergency;
      default:
        return ViolationSeverity.minor;
    }
  }

  // Note: CorrectiveActionStatus mapping methods removed as they're not currently used
  // They can be added back when needed for entities that include corrective action tracking

  String _ccpTypeToString(CCPType type) {
    switch (type) {
      case CCPType.receiving:
        return 'receiving';
      case CCPType.storage:
        return 'storage';
      case CCPType.preparation:
        return 'preparation';
      case CCPType.cooking:
        return 'cooking';
      case CCPType.hotHolding:
        return 'hot_holding';
      case CCPType.coldHolding:
        return 'cold_holding';
      case CCPType.holding:
        return 'holding';
      case CCPType.cooling:
        return 'cooling';
      case CCPType.reheating:
        return 'reheating';
      case CCPType.service:
        return 'service';
      case CCPType.sanitizerConcentration:
        return 'sanitizer_concentration';
      case CCPType.handWashing:
        return 'hand_washing';
      case CCPType.crossContaminationPrevention:
        return 'cross_contamination_prevention';
    }
  }

  CCPType _ccpTypeFromString(String type) {
    switch (type) {
      case 'receiving':
        return CCPType.receiving;
      case 'storage':
        return CCPType.storage;
      case 'preparation':
        return CCPType.preparation;
      case 'cooking':
        return CCPType.cooking;
      case 'hot_holding':
        return CCPType.hotHolding;
      case 'cold_holding':
        return CCPType.coldHolding;
      case 'holding':
        return CCPType.holding;
      case 'cooling':
        return CCPType.cooling;
      case 'reheating':
        return CCPType.reheating;
      case 'service':
        return CCPType.service;
      case 'sanitizer_concentration':
        return CCPType.sanitizerConcentration;
      case 'hand_washing':
        return CCPType.handWashing;
      case 'cross_contamination_prevention':
        return CCPType.crossContaminationPrevention;
      default:
        return CCPType.storage;
    }
  }
}
