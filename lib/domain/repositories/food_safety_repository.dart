import 'package:stacks/domain/entities/food_safety.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';

/// Repository interface for Food Safety operations
abstract class FoodSafetyRepository {
  // ======================== Temperature Log Operations ========================

  /// Create a new temperature log entry
  Future<TemperatureLog> createTemperatureLog(TemperatureLog temperatureLog);

  /// Update an existing temperature log entry
  Future<TemperatureLog> updateTemperatureLog(TemperatureLog temperatureLog);

  /// Get temperature log by ID
  Future<TemperatureLog?> getTemperatureLogById(UserId id);

  /// Get temperature logs by location
  Future<List<TemperatureLog>> getTemperatureLogsByLocation(
    TemperatureLocation location,
  );

  /// Get temperature logs by equipment
  Future<List<TemperatureLog>> getTemperatureLogsByEquipment(
    String equipmentId,
  );

  /// Get temperature logs by date range
  Future<List<TemperatureLog>> getTemperatureLogsByDateRange(
    Time startDate,
    Time endDate,
  );

  /// Get temperature logs requiring corrective action
  Future<List<TemperatureLog>> getTemperatureLogsRequiringAction();

  /// Get temperature logs outside safe range
  Future<List<TemperatureLog>> getTemperatureLogsOutsideSafeRange();

  /// Get temperature logs by recorded user
  Future<List<TemperatureLog>> getTemperatureLogsByUser(UserId recordedBy);

  /// Delete temperature log
  Future<void> deleteTemperatureLog(UserId id);

  // ======================== Food Safety Violation Operations ========================

  /// Create a new food safety violation
  Future<FoodSafetyViolation> createFoodSafetyViolation(
    FoodSafetyViolation violation,
  );

  /// Update an existing food safety violation
  Future<FoodSafetyViolation> updateFoodSafetyViolation(
    FoodSafetyViolation violation,
  );

  /// Get food safety violation by ID
  Future<FoodSafetyViolation?> getFoodSafetyViolationById(UserId id);

  /// Get violations by type
  Future<List<FoodSafetyViolation>> getViolationsByType(ViolationType type);

  /// Get violations by severity
  Future<List<FoodSafetyViolation>> getViolationsBySeverity(
    ViolationSeverity severity,
  );

  /// Get violations by location
  Future<List<FoodSafetyViolation>> getViolationsByLocation(
    TemperatureLocation location,
  );

  /// Get unresolved violations
  Future<List<FoodSafetyViolation>> getUnresolvedViolations();

  /// Get overdue violations
  Future<List<FoodSafetyViolation>> getOverdueViolations();

  /// Get violations assigned to user
  Future<List<FoodSafetyViolation>> getViolationsAssignedToUser(UserId userId);

  /// Get violations by date range
  Future<List<FoodSafetyViolation>> getViolationsByDateRange(
    Time startDate,
    Time endDate,
  );

  /// Resolve violation
  Future<FoodSafetyViolation> resolveViolation(
    UserId violationId,
    List<String> correctiveActions,
    String? rootCause,
    String? preventiveAction,
  );

  /// Delete food safety violation
  Future<void> deleteFoodSafetyViolation(UserId id);

  // ======================== HACCP Control Point Operations ========================

  /// Create a new HACCP control point
  Future<HACCPControlPoint> createHACCPControlPoint(
    HACCPControlPoint controlPoint,
  );

  /// Update an existing HACCP control point
  Future<HACCPControlPoint> updateHACCPControlPoint(
    HACCPControlPoint controlPoint,
  );

  /// Get HACCP control point by ID
  Future<HACCPControlPoint?> getHACCPControlPointById(UserId id);

  /// Get control points by type
  Future<List<HACCPControlPoint>> getControlPointsByType(CCPType type);

  /// Get active control points
  Future<List<HACCPControlPoint>> getActiveControlPoints();

  /// Get control points requiring monitoring
  Future<List<HACCPControlPoint>> getControlPointsRequiringMonitoring();

  /// Get control points by responsible user
  Future<List<HACCPControlPoint>> getControlPointsByResponsibleUser(
    UserId userId,
  );

  /// Update control point monitoring timestamp
  Future<HACCPControlPoint> updateControlPointMonitoring(
    UserId controlPointId,
    Time monitoredAt,
  );

  /// Deactivate control point
  Future<HACCPControlPoint> deactivateControlPoint(UserId controlPointId);

  /// Activate control point
  Future<HACCPControlPoint> activateControlPoint(UserId controlPointId);

  /// Delete HACCP control point
  Future<void> deleteHACCPControlPoint(UserId id);

  // ======================== Food Safety Audit Operations ========================

  /// Create a new food safety audit
  Future<FoodSafetyAudit> createFoodSafetyAudit(FoodSafetyAudit audit);

  /// Update an existing food safety audit
  Future<FoodSafetyAudit> updateFoodSafetyAudit(FoodSafetyAudit audit);

  /// Get food safety audit by ID
  Future<FoodSafetyAudit?> getFoodSafetyAuditById(UserId id);

  /// Get audits by auditor
  Future<List<FoodSafetyAudit>> getAuditsByAuditor(UserId auditor);

  /// Get audits by date range
  Future<List<FoodSafetyAudit>> getAuditsByDateRange(
    Time startDate,
    Time endDate,
  );

  /// Get passed audits
  Future<List<FoodSafetyAudit>> getPassedAudits();

  /// Get failed audits
  Future<List<FoodSafetyAudit>> getFailedAudits();

  /// Get audits by minimum score
  Future<List<FoodSafetyAudit>> getAuditsByMinScore(double minScore);

  /// Delete food safety audit
  Future<void> deleteFoodSafetyAudit(UserId id);

  // ======================== Analytics and Reporting ========================

  /// Get temperature compliance statistics
  Future<Map<String, dynamic>> getTemperatureComplianceStats(
    Time startDate,
    Time endDate,
  );

  /// Get violation trends
  Future<Map<String, dynamic>> getViolationTrends(Time startDate, Time endDate);

  /// Get HACCP compliance report
  Future<Map<String, dynamic>> getHACCPComplianceReport(
    Time startDate,
    Time endDate,
  );

  /// Get audit performance metrics
  Future<Map<String, dynamic>> getAuditPerformanceMetrics(
    Time startDate,
    Time endDate,
  );

  /// Get critical control point effectiveness
  Future<Map<String, dynamic>> getControlPointEffectiveness(
    Time startDate,
    Time endDate,
  );

  /// Get food safety dashboard data
  Future<Map<String, dynamic>> getFoodSafetyDashboardData();

  /// Get temperature alert summary
  Future<Map<String, dynamic>> getTemperatureAlertSummary();

  /// Get violation resolution metrics
  Future<Map<String, dynamic>> getViolationResolutionMetrics(
    Time startDate,
    Time endDate,
  );
}
