import 'package:dartz/dartz.dart' show Either, Left, Right;
import '../../domain/entities/order.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/station.dart';
import '../../domain/value_objects/order_status.dart';
import '../../domain/value_objects/priority.dart';
import '../../domain/failures/failures.dart';

/// Service for centralized validation of complex business rules
class ValidationService {
  /// Validates if an order can be assigned to a specific station
  Either<ValidationFailure, bool> validateOrderAssignment({
    required Order order,
    required Station station,
    required List<Order> currentStationOrders,
  }) {
    try {
      // Check if station is available
      if (station.status != StationStatus.available) {
        return Left(
          ValidationFailure(
            'Station ${station.name} is not available (status: ${station.status})',
          ),
        );
      }

      // Check station capacity
      if (currentStationOrders.length >= station.capacity) {
        return Left(
          ValidationFailure(
            'Station ${station.name} is at full capacity (${station.capacity} orders)',
          ),
        );
      }

      // Check if station type matches order requirements
      final stationSupportsOrder = _validateStationTypeForOrder(order, station);
      if (stationSupportsOrder.isLeft()) {
        return stationSupportsOrder;
      }

      // Check if order is in a valid state for assignment
      if (!order.status.isPending && !order.status.isConfirmed) {
        return Left(
          ValidationFailure(
            'Order ${order.id.value} cannot be assigned (status: ${order.status.value})',
          ),
        );
      }

      return const Right(true);
    } catch (e) {
      return Left(ValidationFailure('Validation error: ${e.toString()}'));
    }
  }

  /// Validates if an order status transition is allowed
  Either<ValidationFailure, bool> validateStatusTransition({
    required OrderStatus currentStatus,
    required OrderStatus newStatus,
    required Order order,
  }) {
    try {
      // Check if transition is valid according to domain rules
      if (!currentStatus.canTransitionTo(newStatus)) {
        return Left(
          ValidationFailure(
            'Invalid status transition from ${currentStatus.value} to ${newStatus.value}',
          ),
        );
      }

      // Additional business rule validations
      if (newStatus.isPreparing && order.assignedStationId == null) {
        return Left(
          ValidationFailure(
            'Cannot start preparing order without assigning to a station',
          ),
        );
      }

      if (newStatus.isReady && !currentStatus.isPreparing) {
        return Left(
          ValidationFailure(
            'Order must be in preparing status before marking as ready',
          ),
        );
      }

      if (newStatus.isCompleted && !currentStatus.isReady) {
        return Left(ValidationFailure('Order must be ready before completing'));
      }

      return const Right(true);
    } catch (e) {
      return Left(
        ValidationFailure('Status validation error: ${e.toString()}'),
      );
    }
  }

  /// Validates if a priority change is allowed
  Either<ValidationFailure, bool> validatePriorityChange({
    required Priority currentPriority,
    required Priority newPriority,
    required Order order,
    required User requestingUser,
  }) {
    try {
      // Only managers and admins can change priority to critical
      if (newPriority.level == Priority.critical &&
          requestingUser.role != UserRole.manager &&
          requestingUser.role != UserRole.admin) {
        return Left(
          ValidationFailure(
            'Only managers and admins can set critical priority',
          ),
        );
      }

      // Cannot downgrade priority for orders already in preparation
      if (order.status.isPreparing &&
          newPriority.level < currentPriority.level) {
        return Left(
          ValidationFailure(
            'Cannot decrease priority for orders in preparation',
          ),
        );
      }

      // Cannot change priority for completed or cancelled orders
      if (order.status.isCompleted || order.status.isCancelled) {
        return Left(
          ValidationFailure(
            'Cannot change priority for completed or cancelled orders',
          ),
        );
      }

      return const Right(true);
    } catch (e) {
      return Left(
        ValidationFailure('Priority validation error: ${e.toString()}'),
      );
    }
  }

  /// Validates user permissions for specific actions
  Either<ValidationFailure, bool> validateUserPermission({
    required User user,
    required String action,
    required Map<String, dynamic> context,
  }) {
    try {
      switch (action) {
        case 'update_order_status':
          if (!user.canUpdateOrderStatus()) {
            return Left(
              ValidationFailure('User lacks permission to update order status'),
            );
          }
          break;
        case 'manage_users':
          if (!user.canManageUsers()) {
            return Left(
              ValidationFailure('User lacks permission to manage users'),
            );
          }
          break;
        case 'delete_orders':
          if (!user.canDeleteOrders()) {
            return Left(
              ValidationFailure('User lacks permission to delete orders'),
            );
          }
          break;
        case 'manage_stations':
          if (!user.canManageStations()) {
            return Left(
              ValidationFailure('User lacks permission to manage stations'),
            );
          }
          break;
        case 'access_reports':
          if (!user.canAccessReports()) {
            return Left(
              ValidationFailure('User lacks permission to access reports'),
            );
          }
          break;
        default:
          return Left(ValidationFailure('Unknown action: $action'));
      }

      return const Right(true);
    } catch (e) {
      return Left(
        ValidationFailure('Permission validation error: ${e.toString()}'),
      );
    }
  }

  /// Validates business hours and time-based rules
  Either<ValidationFailure, bool> validateBusinessRules({
    required String ruleType,
    required Map<String, dynamic> context,
  }) {
    try {
      switch (ruleType) {
        case 'order_time_limit':
          final orderCreatedAt = context['createdAt'] as DateTime?;
          if (orderCreatedAt != null) {
            final hoursSinceCreation = DateTime.now()
                .difference(orderCreatedAt)
                .inHours;
            if (hoursSinceCreation > 4) {
              return Left(
                ValidationFailure(
                  'Order is too old to process (${hoursSinceCreation}h)',
                ),
              );
            }
          }
          break;
        case 'station_workload':
          final currentOrders = context['currentOrders'] as int? ?? 0;
          final maxCapacity = context['maxCapacity'] as int? ?? 10;
          if (currentOrders >= maxCapacity) {
            return Left(ValidationFailure('Station workload exceeds capacity'));
          }
          break;
        default:
          return Left(ValidationFailure('Unknown business rule: $ruleType'));
      }

      return const Right(true);
    } catch (e) {
      return Left(
        ValidationFailure('Business rule validation error: ${e.toString()}'),
      );
    }
  }

  /// Helper method to validate station type compatibility with order
  Either<ValidationFailure, bool> _validateStationTypeForOrder(
    Order order,
    Station station,
  ) {
    // This would contain logic to match order items with station capabilities
    // For now, we'll assume basic validation

    // Example: Check if station type can handle the order items
    final hasGrillItems = order.items.any(
      (item) =>
          item.recipe.name.toLowerCase().contains('burger') ||
          item.recipe.name.toLowerCase().contains('steak') ||
          item.recipe.name.toLowerCase().contains('chicken'),
    );

    if (hasGrillItems && station.stationType != StationType.grill) {
      return Left(
        ValidationFailure('Station ${station.name} cannot handle grill items'),
      );
    }

    final hasSaladItems = order.items.any(
      (item) =>
          item.recipe.name.toLowerCase().contains('salad') ||
          item.recipe.name.toLowerCase().contains('wrap'),
    );

    if (hasSaladItems && station.stationType != StationType.salad) {
      return Left(
        ValidationFailure('Station ${station.name} cannot handle salad items'),
      );
    }

    return const Right(true);
  }
}
