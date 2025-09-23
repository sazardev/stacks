/// DTOs for Food Safety module
library;

/// DTO for creating a temperature log entry
class CreateTemperatureLogDto {
  final String location;
  final double temperature;
  final String unit;
  final double? targetTemperature;
  final double? minSafeTemperature;
  final double? maxSafeTemperature;
  final String recordedBy;
  final String? equipmentId;
  final String? notes;
  final String? correctiveActionTaken;

  const CreateTemperatureLogDto({
    required this.location,
    required this.temperature,
    required this.unit,
    this.targetTemperature,
    this.minSafeTemperature,
    this.maxSafeTemperature,
    required this.recordedBy,
    this.equipmentId,
    this.notes,
    this.correctiveActionTaken,
  });
}

/// DTO for updating a temperature log entry
class UpdateTemperatureLogDto {
  final String temperatureLogId;
  final String? location;
  final double? temperature;
  final String? unit;
  final double? targetTemperature;
  final double? minSafeTemperature;
  final double? maxSafeTemperature;
  final String? equipmentId;
  final String? notes;
  final String? correctiveActionTaken;

  const UpdateTemperatureLogDto({
    required this.temperatureLogId,
    this.location,
    this.temperature,
    this.unit,
    this.targetTemperature,
    this.minSafeTemperature,
    this.maxSafeTemperature,
    this.equipmentId,
    this.notes,
    this.correctiveActionTaken,
  });
}

/// DTO for creating a food safety violation
class CreateFoodSafetyViolationDto {
  final String type;
  final String severity;
  final String description;
  final String? location;
  final String? reportedBy;
  final String? assignedTo;
  final List<String>? correctiveActions;
  final String? rootCause;
  final String? preventiveAction;
  final double? temperatureReading;
  final String? orderId;
  final String? inventoryItemId;

  const CreateFoodSafetyViolationDto({
    required this.type,
    required this.severity,
    required this.description,
    this.location,
    this.reportedBy,
    this.assignedTo,
    this.correctiveActions,
    this.rootCause,
    this.preventiveAction,
    this.temperatureReading,
    this.orderId,
    this.inventoryItemId,
  });
}

/// DTO for updating a food safety violation
class UpdateFoodSafetyViolationDto {
  final String violationId;
  final String? type;
  final String? severity;
  final String? description;
  final String? location;
  final String? assignedTo;
  final bool? isResolved;
  final List<String>? correctiveActions;
  final String? rootCause;
  final String? preventiveAction;
  final double? temperatureReading;

  const UpdateFoodSafetyViolationDto({
    required this.violationId,
    this.type,
    this.severity,
    this.description,
    this.location,
    this.assignedTo,
    this.isResolved,
    this.correctiveActions,
    this.rootCause,
    this.preventiveAction,
    this.temperatureReading,
  });
}

/// DTO for creating a HACCP control point
class CreateHACCPControlPointDto {
  final String type;
  final String name;
  final String monitoringProcedure;
  final double? criticalLimit;
  final String? temperatureUnit;
  final int monitoringFrequencyMinutes;
  final List<String>? correctiveActions;
  final String responsibleUser;

  const CreateHACCPControlPointDto({
    required this.type,
    required this.name,
    required this.monitoringProcedure,
    this.criticalLimit,
    this.temperatureUnit,
    required this.monitoringFrequencyMinutes,
    this.correctiveActions,
    required this.responsibleUser,
  });
}

/// DTO for updating a HACCP control point
class UpdateHACCPControlPointDto {
  final String controlPointId;
  final String? type;
  final String? name;
  final String? monitoringProcedure;
  final double? criticalLimit;
  final String? temperatureUnit;
  final int? monitoringFrequencyMinutes;
  final bool? isActive;
  final List<String>? correctiveActions;
  final String? responsibleUser;

  const UpdateHACCPControlPointDto({
    required this.controlPointId,
    this.type,
    this.name,
    this.monitoringProcedure,
    this.criticalLimit,
    this.temperatureUnit,
    this.monitoringFrequencyMinutes,
    this.isActive,
    this.correctiveActions,
    this.responsibleUser,
  });
}

/// DTO for creating a food safety audit
class CreateFoodSafetyAuditDto {
  final String auditName;
  final DateTime auditDate;
  final String auditor;
  final List<String>? controlPointIds;
  final List<String>? temperatureLogIds;
  final List<String>? violationIds;
  final double overallScore;
  final bool isPassed;
  final String? notes;
  final List<String>? recommendations;

  const CreateFoodSafetyAuditDto({
    required this.auditName,
    required this.auditDate,
    required this.auditor,
    this.controlPointIds,
    this.temperatureLogIds,
    this.violationIds,
    required this.overallScore,
    required this.isPassed,
    this.notes,
    this.recommendations,
  });
}

/// DTO for updating a food safety audit
class UpdateFoodSafetyAuditDto {
  final String auditId;
  final String? auditName;
  final DateTime? auditDate;
  final List<String>? controlPointIds;
  final List<String>? temperatureLogIds;
  final List<String>? violationIds;
  final double? overallScore;
  final bool? isPassed;
  final String? notes;
  final List<String>? recommendations;

  const UpdateFoodSafetyAuditDto({
    required this.auditId,
    this.auditName,
    this.auditDate,
    this.controlPointIds,
    this.temperatureLogIds,
    this.violationIds,
    this.overallScore,
    this.isPassed,
    this.notes,
    this.recommendations,
  });
}

/// DTO for temperature monitoring queries
class TemperatureMonitoringQueryDto {
  final String? location;
  final String? equipmentId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? requiresCorrectiveAction;
  final bool? isWithinSafeRange;
  final String? recordedBy;

  const TemperatureMonitoringQueryDto({
    this.location,
    this.equipmentId,
    this.startDate,
    this.endDate,
    this.requiresCorrectiveAction,
    this.isWithinSafeRange,
    this.recordedBy,
  });
}

/// DTO for violation tracking queries
class ViolationTrackingQueryDto {
  final String? type;
  final String? severity;
  final String? location;
  final bool? isResolved;
  final bool? isOverdue;
  final String? assignedTo;
  final DateTime? startDate;
  final DateTime? endDate;

  const ViolationTrackingQueryDto({
    this.type,
    this.severity,
    this.location,
    this.isResolved,
    this.isOverdue,
    this.assignedTo,
    this.startDate,
    this.endDate,
  });
}

/// DTO for HACCP compliance report generation
class HACCPComplianceReportDto {
  final DateTime startDate;
  final DateTime endDate;
  final List<String>? controlPointIds;
  final String? location;
  final bool includeTemperatureLogs;
  final bool includeViolations;
  final bool includeCorrectiveActions;

  const HACCPComplianceReportDto({
    required this.startDate,
    required this.endDate,
    this.controlPointIds,
    this.location,
    this.includeTemperatureLogs = true,
    this.includeViolations = true,
    this.includeCorrectiveActions = true,
  });
}

/// DTO for food safety audit summary
class FoodSafetyAuditSummaryDto {
  final DateTime startDate;
  final DateTime endDate;
  final String? auditor;
  final bool? passedOnly;
  final double? minScore;
  final bool includeRecommendations;

  const FoodSafetyAuditSummaryDto({
    required this.startDate,
    required this.endDate,
    this.auditor,
    this.passedOnly,
    this.minScore,
    this.includeRecommendations = true,
  });
}
