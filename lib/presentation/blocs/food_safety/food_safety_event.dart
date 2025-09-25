// Food Safety BLoC Events
// Events for managing food safety operations in the presentation layer

import 'package:equatable/equatable.dart';
import '../../../domain/entities/food_safety.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/time.dart';

/// Base class for all food safety events
abstract class FoodSafetyEvent extends Equatable {
  const FoodSafetyEvent();

  @override
  List<Object?> get props => [];
}

// ======================== Temperature Log Events ========================

/// Event to load temperature logs by date range
class LoadTemperatureLogsEvent extends FoodSafetyEvent {
  final Time startDate;
  final Time endDate;
  final TemperatureLocation? location;

  const LoadTemperatureLogsEvent({
    required this.startDate,
    required this.endDate,
    this.location,
  });

  @override
  List<Object?> get props => [startDate, endDate, location];
}

/// Event to create a new temperature log
class CreateTemperatureLogEvent extends FoodSafetyEvent {
  final TemperatureLog temperatureLog;

  const CreateTemperatureLogEvent({required this.temperatureLog});

  @override
  List<Object?> get props => [temperatureLog];
}

/// Event to get temperature logs requiring action
class LoadTemperatureLogsRequiringActionEvent extends FoodSafetyEvent {
  const LoadTemperatureLogsRequiringActionEvent();
}

/// Event to get temperature logs outside safe range
class LoadTemperatureLogsOutsideSafeRangeEvent extends FoodSafetyEvent {
  const LoadTemperatureLogsOutsideSafeRangeEvent();
}

/// Event to get temperature logs by location
class LoadTemperatureLogsByLocationEvent extends FoodSafetyEvent {
  final TemperatureLocation location;

  const LoadTemperatureLogsByLocationEvent({required this.location});

  @override
  List<Object?> get props => [location];
}

/// Event to get temperature logs by user
class LoadTemperatureLogsByUserEvent extends FoodSafetyEvent {
  final UserId userId;

  const LoadTemperatureLogsByUserEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// ======================== Food Safety Violation Events ========================

/// Event to load violations by date range
class LoadViolationsEvent extends FoodSafetyEvent {
  final Time startDate;
  final Time endDate;
  final ViolationType? type;
  final ViolationSeverity? severity;

  const LoadViolationsEvent({
    required this.startDate,
    required this.endDate,
    this.type,
    this.severity,
  });

  @override
  List<Object?> get props => [startDate, endDate, type, severity];
}

/// Event to create a new violation
class CreateViolationEvent extends FoodSafetyEvent {
  final FoodSafetyViolation violation;

  const CreateViolationEvent({required this.violation});

  @override
  List<Object?> get props => [violation];
}

/// Event to resolve a violation
class ResolveViolationEvent extends FoodSafetyEvent {
  final UserId violationId;
  final List<String> correctiveActions;
  final String? rootCause;
  final String? preventiveAction;

  const ResolveViolationEvent({
    required this.violationId,
    required this.correctiveActions,
    this.rootCause,
    this.preventiveAction,
  });

  @override
  List<Object?> get props => [
    violationId,
    correctiveActions,
    rootCause,
    preventiveAction,
  ];
}

/// Event to load unresolved violations
class LoadUnresolvedViolationsEvent extends FoodSafetyEvent {
  const LoadUnresolvedViolationsEvent();
}

/// Event to load overdue violations
class LoadOverdueViolationsEvent extends FoodSafetyEvent {
  const LoadOverdueViolationsEvent();
}

/// Event to load violations by type
class LoadViolationsByTypeEvent extends FoodSafetyEvent {
  final ViolationType type;

  const LoadViolationsByTypeEvent({required this.type});

  @override
  List<Object?> get props => [type];
}

/// Event to load violations by severity
class LoadViolationsBySeverityEvent extends FoodSafetyEvent {
  final ViolationSeverity severity;

  const LoadViolationsBySeverityEvent({required this.severity});

  @override
  List<Object?> get props => [severity];
}

/// Event to load violations assigned to user
class LoadViolationsAssignedToUserEvent extends FoodSafetyEvent {
  final UserId userId;

  const LoadViolationsAssignedToUserEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// ======================== HACCP Control Point Events ========================

/// Event to load HACCP control points
class LoadHACCPControlPointsEvent extends FoodSafetyEvent {
  final CCPType? type;
  final bool activeOnly;

  const LoadHACCPControlPointsEvent({this.type, this.activeOnly = true});

  @override
  List<Object?> get props => [type, activeOnly];
}

/// Event to create a new HACCP control point
class CreateHACCPControlPointEvent extends FoodSafetyEvent {
  final HACCPControlPoint controlPoint;

  const CreateHACCPControlPointEvent({required this.controlPoint});

  @override
  List<Object?> get props => [controlPoint];
}

/// Event to update control point monitoring
class UpdateControlPointMonitoringEvent extends FoodSafetyEvent {
  final UserId controlPointId;
  final Time monitoredAt;

  const UpdateControlPointMonitoringEvent({
    required this.controlPointId,
    required this.monitoredAt,
  });

  @override
  List<Object?> get props => [controlPointId, monitoredAt];
}

/// Event to deactivate control point
class DeactivateControlPointEvent extends FoodSafetyEvent {
  final UserId controlPointId;

  const DeactivateControlPointEvent({required this.controlPointId});

  @override
  List<Object?> get props => [controlPointId];
}

/// Event to activate control point
class ActivateControlPointEvent extends FoodSafetyEvent {
  final UserId controlPointId;

  const ActivateControlPointEvent({required this.controlPointId});

  @override
  List<Object?> get props => [controlPointId];
}

/// Event to load control points requiring monitoring
class LoadControlPointsRequiringMonitoringEvent extends FoodSafetyEvent {
  const LoadControlPointsRequiringMonitoringEvent();
}

/// Event to load control points by responsible user
class LoadControlPointsByResponsibleUserEvent extends FoodSafetyEvent {
  final UserId userId;

  const LoadControlPointsByResponsibleUserEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// ======================== Food Safety Audit Events ========================

/// Event to load audits by date range
class LoadAuditsEvent extends FoodSafetyEvent {
  final Time startDate;
  final Time endDate;
  final UserId? auditorId;

  const LoadAuditsEvent({
    required this.startDate,
    required this.endDate,
    this.auditorId,
  });

  @override
  List<Object?> get props => [startDate, endDate, auditorId];
}

/// Event to create a new audit
class CreateAuditEvent extends FoodSafetyEvent {
  final FoodSafetyAudit audit;

  const CreateAuditEvent({required this.audit});

  @override
  List<Object?> get props => [audit];
}

/// Event to load passed audits
class LoadPassedAuditsEvent extends FoodSafetyEvent {
  const LoadPassedAuditsEvent();
}

/// Event to load failed audits
class LoadFailedAuditsEvent extends FoodSafetyEvent {
  const LoadFailedAuditsEvent();
}

/// Event to load audits by auditor
class LoadAuditsByAuditorEvent extends FoodSafetyEvent {
  final UserId auditorId;

  const LoadAuditsByAuditorEvent({required this.auditorId});

  @override
  List<Object?> get props => [auditorId];
}

/// Event to load audits by minimum score
class LoadAuditsByMinScoreEvent extends FoodSafetyEvent {
  final double minScore;

  const LoadAuditsByMinScoreEvent({required this.minScore});

  @override
  List<Object?> get props => [minScore];
}

// ======================== Analytics and Dashboard Events ========================

/// Event to load temperature compliance statistics
class LoadTemperatureComplianceStatsEvent extends FoodSafetyEvent {
  final Time startDate;
  final Time endDate;

  const LoadTemperatureComplianceStatsEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Event to load violation trends
class LoadViolationTrendsEvent extends FoodSafetyEvent {
  final Time startDate;
  final Time endDate;

  const LoadViolationTrendsEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Event to load HACCP compliance report
class LoadHACCPComplianceReportEvent extends FoodSafetyEvent {
  final Time startDate;
  final Time endDate;

  const LoadHACCPComplianceReportEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Event to load audit performance metrics
class LoadAuditPerformanceMetricsEvent extends FoodSafetyEvent {
  final Time startDate;
  final Time endDate;

  const LoadAuditPerformanceMetricsEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Event to load control point effectiveness
class LoadControlPointEffectivenessEvent extends FoodSafetyEvent {
  final Time startDate;
  final Time endDate;

  const LoadControlPointEffectivenessEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Event to load food safety dashboard data
class LoadFoodSafetyDashboardEvent extends FoodSafetyEvent {
  const LoadFoodSafetyDashboardEvent();
}

/// Event to load temperature alert summary
class LoadTemperatureAlertSummaryEvent extends FoodSafetyEvent {
  const LoadTemperatureAlertSummaryEvent();
}

/// Event to load violation resolution metrics
class LoadViolationResolutionMetricsEvent extends FoodSafetyEvent {
  final Time startDate;
  final Time endDate;

  const LoadViolationResolutionMetricsEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

// ======================== Advanced Use Cases Events ========================

/// Event to execute compliance assessment
class ExecuteComplianceAssessmentEvent extends FoodSafetyEvent {
  final Time assessmentPeriodStart;
  final Time assessmentPeriodEnd;
  final List<CCPType>? focusAreas;
  final bool generateCorrectiveActions;

  const ExecuteComplianceAssessmentEvent({
    required this.assessmentPeriodStart,
    required this.assessmentPeriodEnd,
    this.focusAreas,
    this.generateCorrectiveActions = true,
  });

  @override
  List<Object?> get props => [
    assessmentPeriodStart,
    assessmentPeriodEnd,
    focusAreas,
    generateCorrectiveActions,
  ];
}

/// Event to execute temperature monitoring
class ExecuteTemperatureMonitoringEvent extends FoodSafetyEvent {
  final Time monitoringPeriodStart;
  final Time monitoringPeriodEnd;
  final List<TemperatureLocation>? specificLocations;

  const ExecuteTemperatureMonitoringEvent({
    required this.monitoringPeriodStart,
    required this.monitoringPeriodEnd,
    this.specificLocations,
  });

  @override
  List<Object?> get props => [
    monitoringPeriodStart,
    monitoringPeriodEnd,
    specificLocations,
  ];
}

// ======================== Real-time Events ========================

/// Event to start real-time monitoring
class StartRealTimeMonitoringEvent extends FoodSafetyEvent {
  const StartRealTimeMonitoringEvent();
}

/// Event to stop real-time monitoring
class StopRealTimeMonitoringEvent extends FoodSafetyEvent {
  const StopRealTimeMonitoringEvent();
}

/// Event triggered when real-time data updates
class RealTimeDataUpdateEvent extends FoodSafetyEvent {
  final String updateType;
  final dynamic data;

  const RealTimeDataUpdateEvent({required this.updateType, required this.data});

  @override
  List<Object?> get props => [updateType, data];
}

// ======================== Error Handling Events ========================

/// Event to clear errors
class ClearFoodSafetyErrorsEvent extends FoodSafetyEvent {
  const ClearFoodSafetyErrorsEvent();
}

/// Event to retry failed operation
class RetryFoodSafetyOperationEvent extends FoodSafetyEvent {
  final FoodSafetyEvent originalEvent;

  const RetryFoodSafetyOperationEvent({required this.originalEvent});

  @override
  List<Object?> get props => [originalEvent];
}
