// Food Safety BLoC States
// States for managing food safety operations in the presentation layer

import 'package:equatable/equatable.dart';
import '../../../domain/entities/food_safety.dart';

/// Base class for all food safety states
abstract class FoodSafetyState extends Equatable {
  const FoodSafetyState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FoodSafetyInitial extends FoodSafetyState {
  const FoodSafetyInitial();
}

/// Loading state
class FoodSafetyLoading extends FoodSafetyState {
  final String? operation;

  const FoodSafetyLoading({this.operation});

  @override
  List<Object?> get props => [operation];
}

/// Error state
class FoodSafetyError extends FoodSafetyState {
  final String message;
  final String? operation;

  const FoodSafetyError({required this.message, this.operation});

  @override
  List<Object?> get props => [message, operation];
}

// ======================== Temperature Log States ========================

/// State when temperature logs are loaded
class TemperatureLogsLoaded extends FoodSafetyState {
  final List<TemperatureLog> temperatureLogs;
  final String? filterType;

  const TemperatureLogsLoaded({required this.temperatureLogs, this.filterType});

  @override
  List<Object?> get props => [temperatureLogs, filterType];
}

/// State when a temperature log is created
class TemperatureLogCreated extends FoodSafetyState {
  final TemperatureLog temperatureLog;

  const TemperatureLogCreated({required this.temperatureLog});

  @override
  List<Object?> get props => [temperatureLog];
}

/// State for temperature logs requiring action
class TemperatureLogsRequiringActionLoaded extends FoodSafetyState {
  final List<TemperatureLog> temperatureLogs;

  const TemperatureLogsRequiringActionLoaded({required this.temperatureLogs});

  @override
  List<Object?> get props => [temperatureLogs];
}

/// State for temperature logs outside safe range
class TemperatureLogsOutsideSafeRangeLoaded extends FoodSafetyState {
  final List<TemperatureLog> temperatureLogs;

  const TemperatureLogsOutsideSafeRangeLoaded({required this.temperatureLogs});

  @override
  List<Object?> get props => [temperatureLogs];
}

// ======================== Food Safety Violation States ========================

/// State when violations are loaded
class ViolationsLoaded extends FoodSafetyState {
  final List<FoodSafetyViolation> violations;
  final String? filterType;

  const ViolationsLoaded({required this.violations, this.filterType});

  @override
  List<Object?> get props => [violations, filterType];
}

/// State when a violation is created
class ViolationCreated extends FoodSafetyState {
  final FoodSafetyViolation violation;

  const ViolationCreated({required this.violation});

  @override
  List<Object?> get props => [violation];
}

/// State when a violation is resolved
class ViolationResolved extends FoodSafetyState {
  final FoodSafetyViolation violation;

  const ViolationResolved({required this.violation});

  @override
  List<Object?> get props => [violation];
}

/// State for unresolved violations
class UnresolvedViolationsLoaded extends FoodSafetyState {
  final List<FoodSafetyViolation> violations;

  const UnresolvedViolationsLoaded({required this.violations});

  @override
  List<Object?> get props => [violations];
}

/// State for overdue violations
class OverdueViolationsLoaded extends FoodSafetyState {
  final List<FoodSafetyViolation> violations;

  const OverdueViolationsLoaded({required this.violations});

  @override
  List<Object?> get props => [violations];
}

// ======================== HACCP Control Point States ========================

/// State when HACCP control points are loaded
class HACCPControlPointsLoaded extends FoodSafetyState {
  final List<HACCPControlPoint> controlPoints;
  final String? filterType;

  const HACCPControlPointsLoaded({
    required this.controlPoints,
    this.filterType,
  });

  @override
  List<Object?> get props => [controlPoints, filterType];
}

/// State when a HACCP control point is created
class HACCPControlPointCreated extends FoodSafetyState {
  final HACCPControlPoint controlPoint;

  const HACCPControlPointCreated({required this.controlPoint});

  @override
  List<Object?> get props => [controlPoint];
}

/// State when control point monitoring is updated
class ControlPointMonitoringUpdated extends FoodSafetyState {
  final HACCPControlPoint controlPoint;

  const ControlPointMonitoringUpdated({required this.controlPoint});

  @override
  List<Object?> get props => [controlPoint];
}

/// State when control point is deactivated
class ControlPointDeactivated extends FoodSafetyState {
  final HACCPControlPoint controlPoint;

  const ControlPointDeactivated({required this.controlPoint});

  @override
  List<Object?> get props => [controlPoint];
}

/// State when control point is activated
class ControlPointActivated extends FoodSafetyState {
  final HACCPControlPoint controlPoint;

  const ControlPointActivated({required this.controlPoint});

  @override
  List<Object?> get props => [controlPoint];
}

/// State for control points requiring monitoring
class ControlPointsRequiringMonitoringLoaded extends FoodSafetyState {
  final List<HACCPControlPoint> controlPoints;

  const ControlPointsRequiringMonitoringLoaded({required this.controlPoints});

  @override
  List<Object?> get props => [controlPoints];
}

// ======================== Food Safety Audit States ========================

/// State when audits are loaded
class AuditsLoaded extends FoodSafetyState {
  final List<FoodSafetyAudit> audits;
  final String? filterType;

  const AuditsLoaded({required this.audits, this.filterType});

  @override
  List<Object?> get props => [audits, filterType];
}

/// State when an audit is created
class AuditCreated extends FoodSafetyState {
  final FoodSafetyAudit audit;

  const AuditCreated({required this.audit});

  @override
  List<Object?> get props => [audit];
}

/// State for passed audits
class PassedAuditsLoaded extends FoodSafetyState {
  final List<FoodSafetyAudit> audits;

  const PassedAuditsLoaded({required this.audits});

  @override
  List<Object?> get props => [audits];
}

/// State for failed audits
class FailedAuditsLoaded extends FoodSafetyState {
  final List<FoodSafetyAudit> audits;

  const FailedAuditsLoaded({required this.audits});

  @override
  List<Object?> get props => [audits];
}

// ======================== Analytics and Dashboard States ========================

/// State when temperature compliance statistics are loaded
class TemperatureComplianceStatsLoaded extends FoodSafetyState {
  final Map<String, dynamic> stats;

  const TemperatureComplianceStatsLoaded({required this.stats});

  @override
  List<Object?> get props => [stats];
}

/// State when violation trends are loaded
class ViolationTrendsLoaded extends FoodSafetyState {
  final Map<String, dynamic> trends;

  const ViolationTrendsLoaded({required this.trends});

  @override
  List<Object?> get props => [trends];
}

/// State when HACCP compliance report is loaded
class HACCPComplianceReportLoaded extends FoodSafetyState {
  final Map<String, dynamic> report;

  const HACCPComplianceReportLoaded({required this.report});

  @override
  List<Object?> get props => [report];
}

/// State when audit performance metrics are loaded
class AuditPerformanceMetricsLoaded extends FoodSafetyState {
  final Map<String, dynamic> metrics;

  const AuditPerformanceMetricsLoaded({required this.metrics});

  @override
  List<Object?> get props => [metrics];
}

/// State when control point effectiveness is loaded
class ControlPointEffectivenessLoaded extends FoodSafetyState {
  final Map<String, dynamic> effectiveness;

  const ControlPointEffectivenessLoaded({required this.effectiveness});

  @override
  List<Object?> get props => [effectiveness];
}

/// State when food safety dashboard is loaded
class FoodSafetyDashboardLoaded extends FoodSafetyState {
  final Map<String, dynamic> dashboardData;

  const FoodSafetyDashboardLoaded({required this.dashboardData});

  @override
  List<Object?> get props => [dashboardData];
}

/// State when temperature alert summary is loaded
class TemperatureAlertSummaryLoaded extends FoodSafetyState {
  final Map<String, dynamic> alertSummary;

  const TemperatureAlertSummaryLoaded({required this.alertSummary});

  @override
  List<Object?> get props => [alertSummary];
}

/// State when violation resolution metrics are loaded
class ViolationResolutionMetricsLoaded extends FoodSafetyState {
  final Map<String, dynamic> metrics;

  const ViolationResolutionMetricsLoaded({required this.metrics});

  @override
  List<Object?> get props => [metrics];
}

// ======================== Advanced Use Cases States ========================

/// State when compliance assessment is completed
class ComplianceAssessmentCompleted extends FoodSafetyState {
  final Map<String, dynamic> assessment;

  const ComplianceAssessmentCompleted({required this.assessment});

  @override
  List<Object?> get props => [assessment];
}

/// State when temperature monitoring is completed
class TemperatureMonitoringCompleted extends FoodSafetyState {
  final Map<String, dynamic> monitoring;

  const TemperatureMonitoringCompleted({required this.monitoring});

  @override
  List<Object?> get props => [monitoring];
}

// ======================== Real-time States ========================

/// State when real-time monitoring is active
class RealTimeMonitoringActive extends FoodSafetyState {
  final bool isActive;
  final Map<String, dynamic>? lastUpdate;

  const RealTimeMonitoringActive({required this.isActive, this.lastUpdate});

  @override
  List<Object?> get props => [isActive, lastUpdate];
}

/// State for real-time data updates
class RealTimeDataUpdated extends FoodSafetyState {
  final String updateType;
  final dynamic data;
  final DateTime timestamp;

  const RealTimeDataUpdated({
    required this.updateType,
    required this.data,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [updateType, data, timestamp];
}

// ======================== Combined States ========================

/// State with combined data for dashboard views
class FoodSafetyDataLoaded extends FoodSafetyState {
  final List<TemperatureLog> temperatureLogs;
  final List<FoodSafetyViolation> violations;
  final List<HACCPControlPoint> controlPoints;
  final List<FoodSafetyAudit> audits;
  final Map<String, dynamic>? analytics;

  const FoodSafetyDataLoaded({
    required this.temperatureLogs,
    required this.violations,
    required this.controlPoints,
    required this.audits,
    this.analytics,
  });

  @override
  List<Object?> get props => [
    temperatureLogs,
    violations,
    controlPoints,
    audits,
    analytics,
  ];
}

/// State for successful operations
class FoodSafetyOperationSuccess extends FoodSafetyState {
  final String operation;
  final String message;
  final dynamic result;

  const FoodSafetyOperationSuccess({
    required this.operation,
    required this.message,
    this.result,
  });

  @override
  List<Object?> get props => [operation, message, result];
}

// ======================== Utility Methods for State Checking ========================

/// Extension to check state types
extension FoodSafetyStateExtensions on FoodSafetyState {
  /// Check if state is loading
  bool get isLoading => this is FoodSafetyLoading;

  /// Check if state is error
  bool get isError => this is FoodSafetyError;

  /// Check if state is initial
  bool get isInitial => this is FoodSafetyInitial;

  /// Check if state has temperature logs
  bool get hasTemperatureLogs =>
      this is TemperatureLogsLoaded ||
      this is TemperatureLogsRequiringActionLoaded ||
      this is TemperatureLogsOutsideSafeRangeLoaded;

  /// Check if state has violations
  bool get hasViolations =>
      this is ViolationsLoaded ||
      this is UnresolvedViolationsLoaded ||
      this is OverdueViolationsLoaded;

  /// Check if state has control points
  bool get hasControlPoints =>
      this is HACCPControlPointsLoaded ||
      this is ControlPointsRequiringMonitoringLoaded;

  /// Check if state has audits
  bool get hasAudits =>
      this is AuditsLoaded ||
      this is PassedAuditsLoaded ||
      this is FailedAuditsLoaded;

  /// Check if state has analytics data
  bool get hasAnalytics =>
      this is TemperatureComplianceStatsLoaded ||
      this is ViolationTrendsLoaded ||
      this is HACCPComplianceReportLoaded ||
      this is AuditPerformanceMetricsLoaded ||
      this is ControlPointEffectivenessLoaded ||
      this is FoodSafetyDashboardLoaded ||
      this is TemperatureAlertSummaryLoaded ||
      this is ViolationResolutionMetricsLoaded ||
      this is ComplianceAssessmentCompleted ||
      this is TemperatureMonitoringCompleted;

  /// Check if real-time monitoring is active
  bool get isRealTimeActive =>
      this is RealTimeMonitoringActive &&
      (this as RealTimeMonitoringActive).isActive;
}
