// Order BLoC States
// States for order management, status updates, and kitchen workflow

import '../../core/base_state.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/failures/failures.dart';

/// Base order state
abstract class OrderState extends BaseState {}

/// Initial state when OrderBloc is first created
class OrderInitialState extends OrderState {
  @override
  List<Object> get props => [];
}

/// Loading state during order operations
class OrderLoadingState extends OrderState {
  final String? operation;

  OrderLoadingState({this.operation});

  @override
  List<Object?> get props => [operation];
}

/// State when orders are successfully loaded
class OrdersLoadedState extends OrderState {
  final List<Order> orders;
  final List<Order> filteredOrders;
  final bool isRealTimeActive;

  OrdersLoadedState({
    required this.orders,
    List<Order>? filteredOrders,
    this.isRealTimeActive = false,
  }) : filteredOrders = filteredOrders ?? orders;

  @override
  List<Object> get props => [orders, filteredOrders, isRealTimeActive];

  /// Helper methods for UI
  List<Order> get pendingOrders =>
      filteredOrders.where((order) => order.status.isPending).toList();

  List<Order> get inProgressOrders =>
      filteredOrders.where((order) => order.status.isPreparing).toList();

  List<Order> get readyOrders =>
      filteredOrders.where((order) => order.status.isReady).toList();

  int get totalOrders => filteredOrders.length;
  int get completedToday => filteredOrders
      .where(
        (order) =>
            order.status.isCompleted &&
            _isSameDay(order.completedAt?.dateTime, DateTime.now()),
      )
      .toList()
      .length;

  bool _isSameDay(DateTime? date1, DateTime date2) {
    if (date1 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

/// State when a single order is loaded with details
class OrderDetailsLoadedState extends OrderState {
  final Order order;

  OrderDetailsLoadedState({required this.order});

  @override
  List<Object> get props => [order];
}

/// State when an order operation is successful
class OrderOperationSuccessState extends OrderState {
  final String message;
  final Order? updatedOrder;

  OrderOperationSuccessState({required this.message, this.updatedOrder});

  @override
  List<Object?> get props => [message, updatedOrder];
}

/// Error state for order operations
class OrderErrorState extends OrderState {
  final String message;
  final Failure? failure;
  final String? operation;

  OrderErrorState({required this.message, this.failure, this.operation});

  @override
  List<Object?> get props => [message, failure, operation];

  /// Create error state from failure
  factory OrderErrorState.fromFailure(Failure failure, {String? operation}) {
    String message;

    if (failure is ValidationFailure) {
      message = 'Invalid order data: ${failure.message}';
    } else if (failure is NetworkFailure) {
      message = 'Network error. Please check your connection.';
    } else if (failure is PermissionFailure) {
      message = 'You don\'t have permission for this operation.';
    } else if (failure is ServerFailure) {
      message = 'Server error. Please try again later.';
    } else {
      message = failure.message.isNotEmpty
          ? failure.message
          : 'An error occurred';
    }

    return OrderErrorState(
      message: message,
      failure: failure,
      operation: operation,
    );
  }
}

/// State for real-time order updates
class OrderRealTimeUpdateState extends OrderState {
  final Order updatedOrder;
  final String updateType; // 'created', 'updated', 'deleted'

  OrderRealTimeUpdateState({
    required this.updatedOrder,
    required this.updateType,
  });

  @override
  List<Object> get props => [updatedOrder, updateType];
}

/// State when orders are being filtered or sorted
class OrdersFilteredState extends OrderState {
  final List<Order> allOrders;
  final List<Order> filteredOrders;
  final Map<String, dynamic> activeFilters;

  OrdersFilteredState({
    required this.allOrders,
    required this.filteredOrders,
    required this.activeFilters,
  });

  @override
  List<Object> get props => [allOrders, filteredOrders, activeFilters];

  bool get hasActiveFilters => activeFilters.isNotEmpty;
  int get filterResultCount => filteredOrders.length;
}

/// State for order assignment operations
class OrderAssignmentState extends OrderState {
  final Order order;
  final String stationName;
  final bool isAssigning;

  OrderAssignmentState({
    required this.order,
    required this.stationName,
    this.isAssigning = false,
  });

  @override
  List<Object> get props => [order, stationName, isAssigning];
}

/// State when no orders are available
class OrdersEmptyState extends OrderState {
  final String message;

  OrdersEmptyState({this.message = 'No orders available'});

  @override
  List<Object> get props => [message];
}

/// State for order status transitions
class OrderStatusTransitionState extends OrderState {
  final Order order;
  final String fromStatus;
  final String toStatus;
  final bool isTransitioning;

  OrderStatusTransitionState({
    required this.order,
    required this.fromStatus,
    required this.toStatus,
    this.isTransitioning = false,
  });

  @override
  List<Object> get props => [order, fromStatus, toStatus, isTransitioning];
}
