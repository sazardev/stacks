import 'package:equatable/equatable.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/priority.dart';

/// DTO for creating a new order
class CreateOrderDto extends Equatable {
  final UserId customerId;
  final UserId? tableId;
  final List<CreateOrderItemDto> items;
  final Priority priority;
  final String? specialInstructions;

  const CreateOrderDto({
    required this.customerId,
    this.tableId,
    required this.items,
    required this.priority,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [
    customerId,
    tableId,
    items,
    priority,
    specialInstructions,
  ];
}

/// DTO for creating an order item
class CreateOrderItemDto extends Equatable {
  final UserId recipeId;
  final int quantity;
  final String? specialInstructions;

  const CreateOrderItemDto({
    required this.recipeId,
    required this.quantity,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [recipeId, quantity, specialInstructions];
}

/// DTO for updating order status
class UpdateOrderStatusDto extends Equatable {
  final UserId orderId;
  final String status;
  final String? reason;

  const UpdateOrderStatusDto({
    required this.orderId,
    required this.status,
    this.reason,
  });

  @override
  List<Object?> get props => [orderId, status, reason];
}

/// DTO for updating order priority
class UpdateOrderPriorityDto extends Equatable {
  final UserId orderId;
  final int priorityLevel;
  final String? reason;

  const UpdateOrderPriorityDto({
    required this.orderId,
    required this.priorityLevel,
    this.reason,
  });

  @override
  List<Object?> get props => [orderId, priorityLevel, reason];
}

/// DTO for assigning order to station
class AssignOrderToStationDto extends Equatable {
  final UserId orderId;
  final UserId stationId;

  const AssignOrderToStationDto({
    required this.orderId,
    required this.stationId,
  });

  @override
  List<Object?> get props => [orderId, stationId];
}

/// DTO for order queries
class OrderQueryDto extends Equatable {
  final UserId? stationId;
  final String? status;
  final int? priorityLevel;
  final UserId? customerId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;
  final int? offset;

  const OrderQueryDto({
    this.stationId,
    this.status,
    this.priorityLevel,
    this.customerId,
    this.startDate,
    this.endDate,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [
    stationId,
    status,
    priorityLevel,
    customerId,
    startDate,
    endDate,
    limit,
    offset,
  ];
}
