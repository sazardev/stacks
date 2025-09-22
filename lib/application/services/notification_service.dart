import 'package:dartz/dartz.dart' show Either, Unit;
import '../../domain/entities/order.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/failures/failures.dart';

/// Service interface for sending notifications in the kitchen system
abstract class NotificationService {
  /// Sends notification when order status changes
  Future<Either<Failure, Unit>> notifyOrderStatusChange({
    required Order order,
    required String previousStatus,
    required String newStatus,
    required List<UserId> recipientIds,
  });

  /// Sends notification when order priority changes
  Future<Either<Failure, Unit>> notifyOrderPriorityChange({
    required Order order,
    required int previousPriority,
    required int newPriority,
    required List<UserId> recipientIds,
  });

  /// Sends notification when order is assigned to station
  Future<Either<Failure, Unit>> notifyOrderAssigned({
    required Order order,
    required UserId stationId,
    required List<UserId> stationStaffIds,
  });

  /// Sends notification when order is ready for pickup
  Future<Either<Failure, Unit>> notifyOrderReady({
    required Order order,
    required UserId customerId,
    required List<UserId> serviceStaffIds,
  });

  /// Sends notification when order is completed
  Future<Either<Failure, Unit>> notifyOrderCompleted({
    required Order order,
    required UserId customerId,
  });

  /// Sends notification when order is cancelled
  Future<Either<Failure, Unit>> notifyOrderCancelled({
    required Order order,
    required String cancellationReason,
    required List<UserId> affectedUserIds,
  });

  /// Sends notification for urgent orders that need immediate attention
  Future<Either<Failure, Unit>> notifyUrgentOrder({
    required Order order,
    required List<UserId> kitchenManagerIds,
  });

  /// Sends notification when a station goes offline or becomes unavailable
  Future<Either<Failure, Unit>> notifyStationStatusChange({
    required UserId stationId,
    required String stationName,
    required String previousStatus,
    required String newStatus,
    required List<UserId> managerIds,
  });

  /// Sends notification for system alerts and maintenance
  Future<Either<Failure, Unit>> notifySystemAlert({
    required String alertMessage,
    required String alertLevel, // info, warning, error, critical
    required List<UserId> adminIds,
  });

  /// Sends notification to users about their authentication events
  Future<Either<Failure, Unit>> notifyUserAuthentication({
    required User user,
    required String action, // login, logout, password_change
  });
}
