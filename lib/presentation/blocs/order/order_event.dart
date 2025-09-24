// Order BLoC Events
// Events for order management, status updates, and kitchen workflow

import '../../core/base_event.dart';
import '../../../domain/value_objects/order_status.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../application/dtos/order_dtos.dart';

/// Base order event
abstract class OrderEvent extends BaseEvent {}

/// Event to load all orders for kitchen display
class LoadOrdersEvent extends OrderEvent {
  final OrderStatus? filterStatus;
  final UserId? stationId;
  final bool includeCompleted;

  LoadOrdersEvent({
    this.filterStatus,
    this.stationId,
    this.includeCompleted = false,
  });

  @override
  List<Object?> get props => [filterStatus, stationId, includeCompleted];
}

/// Event to create a new order
class CreateOrderEvent extends OrderEvent {
  final CreateOrderDto orderDto;

  CreateOrderEvent({required this.orderDto});

  @override
  List<Object> get props => [orderDto];
}

/// Event to update order status
class UpdateOrderStatusEvent extends OrderEvent {
  final UserId orderId;
  final OrderStatus newStatus;
  final String? notes;
  final UserId? assignedStationId;

  UpdateOrderStatusEvent({
    required this.orderId,
    required this.newStatus,
    this.notes,
    this.assignedStationId,
  });

  @override
  List<Object?> get props => [orderId, newStatus, notes, assignedStationId];
}

/// Event to assign order to station
class AssignOrderToStationEvent extends OrderEvent {
  final UserId orderId;
  final UserId stationId;
  final UserId assignedByUserId;

  AssignOrderToStationEvent({
    required this.orderId,
    required this.stationId,
    required this.assignedByUserId,
  });

  @override
  List<Object> get props => [orderId, stationId, assignedByUserId];
}

/// Event to start order preparation
class StartOrderPreparationEvent extends OrderEvent {
  final UserId orderId;
  final UserId chefId;

  StartOrderPreparationEvent({required this.orderId, required this.chefId});

  @override
  List<Object> get props => [orderId, chefId];
}

/// Event to mark order as ready for serving
class MarkOrderReadyEvent extends OrderEvent {
  final UserId orderId;
  final UserId chefId;

  MarkOrderReadyEvent({required this.orderId, required this.chefId});

  @override
  List<Object> get props => [orderId, chefId];
}

/// Event to complete order (served to customer)
class CompleteOrderEvent extends OrderEvent {
  final UserId orderId;
  final UserId completedByUserId;

  CompleteOrderEvent({required this.orderId, required this.completedByUserId});

  @override
  List<Object> get props => [orderId, completedByUserId];
}

/// Event to cancel an order
class CancelOrderEvent extends OrderEvent {
  final UserId orderId;
  final String reason;
  final UserId cancelledByUserId;

  CancelOrderEvent({
    required this.orderId,
    required this.reason,
    required this.cancelledByUserId,
  });

  @override
  List<Object> get props => [orderId, reason, cancelledByUserId];
}

/// Event to get order details by ID
class GetOrderDetailsEvent extends OrderEvent {
  final UserId orderId;

  GetOrderDetailsEvent({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

/// Event to refresh orders in real-time
class RefreshOrdersEvent extends OrderEvent {
  @override
  List<Object> get props => [];
}

/// Event to filter orders by criteria
class FilterOrdersEvent extends OrderEvent {
  final OrderStatus? status;
  final UserId? stationId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? searchQuery;

  FilterOrdersEvent({
    this.status,
    this.stationId,
    this.dateFrom,
    this.dateTo,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [status, stationId, dateFrom, dateTo, searchQuery];
}

/// Event to sort orders by priority or time
class SortOrdersEvent extends OrderEvent {
  final OrderSortBy sortBy;
  final bool ascending;

  SortOrdersEvent({required this.sortBy, this.ascending = true});

  @override
  List<Object> get props => [sortBy, ascending];
}

/// Enum for order sorting options
enum OrderSortBy { createdTime, priority, estimatedTime, status, tableNumber }

/// Event to subscribe to real-time order updates
class SubscribeToOrderUpdatesEvent extends OrderEvent {
  @override
  List<Object> get props => [];
}

/// Event to unsubscribe from real-time updates
class UnsubscribeFromOrderUpdatesEvent extends OrderEvent {
  @override
  List<Object> get props => [];
}
