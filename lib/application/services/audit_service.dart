import 'package:dartz/dartz.dart' show Either, Unit;
import '../../domain/entities/order.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/station.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';
import '../../domain/failures/failures.dart';

/// Service interface for auditing and tracking user actions in the kitchen system
abstract class AuditService {
  /// Records user login event
  Future<Either<Failure, Unit>> recordUserLogin({
    required User user,
    required String ipAddress,
    required String userAgent,
    required Time loginTime,
  });

  /// Records user logout event
  Future<Either<Failure, Unit>> recordUserLogout({
    required UserId userId,
    required Time logoutTime,
    required String logoutReason, // manual, timeout, forced
  });

  /// Records order creation event
  Future<Either<Failure, Unit>> recordOrderCreation({
    required Order order,
    required UserId createdByUserId,
    required Time creationTime,
    required Map<String, dynamic> orderDetails,
  });

  /// Records order status change event
  Future<Either<Failure, Unit>> recordOrderStatusChange({
    required Order order,
    required String previousStatus,
    required String newStatus,
    required UserId changedByUserId,
    required Time changeTime,
    required String? changeReason,
  });

  /// Records order assignment event
  Future<Either<Failure, Unit>> recordOrderAssignment({
    required Order order,
    required UserId stationId,
    required UserId assignedByUserId,
    required Time assignmentTime,
  });

  /// Records order priority change event
  Future<Either<Failure, Unit>> recordOrderPriorityChange({
    required Order order,
    required int previousPriority,
    required int newPriority,
    required UserId changedByUserId,
    required Time changeTime,
    required String changeReason,
  });

  /// Records order completion event
  Future<Either<Failure, Unit>> recordOrderCompletion({
    required Order order,
    required UserId completedByUserId,
    required Time completionTime,
    required int totalPreparationTimeMinutes,
  });

  /// Records order cancellation event
  Future<Either<Failure, Unit>> recordOrderCancellation({
    required Order order,
    required UserId cancelledByUserId,
    required Time cancellationTime,
    required String cancellationReason,
  });

  /// Records user management actions (create, update, delete, role change)
  Future<Either<Failure, Unit>> recordUserManagementAction({
    required UserId targetUserId,
    required UserId performedByUserId,
    required String
    action, // create, update, delete, role_change, activate, deactivate
    required Time actionTime,
    required Map<String, dynamic> actionDetails,
  });

  /// Records station management actions
  Future<Either<Failure, Unit>> recordStationManagementAction({
    required Station station,
    required UserId performedByUserId,
    required String action, // create, update, delete, status_change
    required Time actionTime,
    required Map<String, dynamic> actionDetails,
  });

  /// Records system configuration changes
  Future<Either<Failure, Unit>> recordSystemConfigurationChange({
    required String configurationKey,
    required String previousValue,
    required String newValue,
    required UserId changedByUserId,
    required Time changeTime,
    required String changeReason,
  });

  /// Records security events (failed logins, permission denials, etc.)
  Future<Either<Failure, Unit>> recordSecurityEvent({
    required String
    eventType, // failed_login, permission_denied, suspicious_activity
    required UserId? userId,
    required String ipAddress,
    required String userAgent,
    required Time eventTime,
    required String eventDescription,
    required String severity, // low, medium, high, critical
  });

  /// Records data access events for sensitive information
  Future<Either<Failure, Unit>> recordDataAccessEvent({
    required UserId userId,
    required String resourceType, // order, user, report, system_config
    required String resourceId,
    required String accessType, // read, write, delete
    required Time accessTime,
    required bool accessGranted,
    required String? denialReason,
  });

  /// Records performance events and system metrics
  Future<Either<Failure, Unit>> recordPerformanceEvent({
    required String metricName,
    required double metricValue,
    required String metricUnit,
    required Time measurementTime,
    required Map<String, dynamic> additionalData,
  });

  /// Records error events and exceptions
  Future<Either<Failure, Unit>> recordErrorEvent({
    required String errorType,
    required String errorMessage,
    required String? stackTrace,
    required UserId? userId,
    required Time errorTime,
    required String severity,
    required Map<String, dynamic> errorContext,
  });

  /// Records business rule violations
  Future<Either<Failure, Unit>> recordBusinessRuleViolation({
    required String ruleName,
    required String violationDescription,
    required UserId? userId,
    required Time violationTime,
    required Map<String, dynamic> violationContext,
  });

  /// Retrieves audit trail for a specific entity
  Future<Either<Failure, List<Map<String, dynamic>>>> getAuditTrail({
    required String entityType, // order, user, station
    required String entityId,
    required Time? fromDate,
    required Time? toDate,
    required int? limit,
  });

  /// Retrieves audit trail for a specific user's actions
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserAuditTrail({
    required UserId userId,
    required Time? fromDate,
    required Time? toDate,
    required int? limit,
  });

  /// Retrieves security events within a time period
  Future<Either<Failure, List<Map<String, dynamic>>>> getSecurityEvents({
    required Time? fromDate,
    required Time? toDate,
    required String? severity,
    required int? limit,
  });

  /// Generates compliance report for auditing purposes
  Future<Either<Failure, Map<String, dynamic>>> generateComplianceReport({
    required Time fromDate,
    required Time toDate,
    required List<String> includeEventTypes,
  });
}
