// Order BLoC - Simplified Version
// Business logic for order management, status updates, and kitchen workflow

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart' hide Order;

import '../../core/base_bloc.dart';
import 'order_event.dart';
import 'order_state.dart';
import '../../../application/use_cases/order/order_use_cases.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/order_status.dart';

/// BLoC for managing order operations in the kitchen display system
/// Simplified version focusing on core functionality
class OrderBloc extends BaseBloc<OrderEvent, OrderState> {
  final GetAllOrdersUseCase _getAllOrdersUseCase;
  final GetOrderByIdUseCase _getOrderByIdUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  final AssignOrderToStationUseCase _assignOrderToStationUseCase;
  final CancelOrderUseCase _cancelOrderUseCase;

  // Internal state management
  List<Order> _allOrders = <Order>[];
  List<Order> _filteredOrders = <Order>[];
  Map<String, dynamic> _activeFilters = <String, dynamic>{};
  StreamSubscription? _ordersSubscription;

  OrderBloc({
    required GetAllOrdersUseCase getAllOrdersUseCase,
    required GetOrderByIdUseCase getOrderByIdUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
    required AssignOrderToStationUseCase assignOrderToStationUseCase,
    required CancelOrderUseCase cancelOrderUseCase,
  }) : _getAllOrdersUseCase = getAllOrdersUseCase,
       _getOrderByIdUseCase = getOrderByIdUseCase,
       _updateOrderStatusUseCase = updateOrderStatusUseCase,
       _assignOrderToStationUseCase = assignOrderToStationUseCase,
       _cancelOrderUseCase = cancelOrderUseCase,
       super(OrderInitialState()) {
    // Register event handlers
    on<LoadOrdersEvent>(_onLoadOrders);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<AssignOrderToStationEvent>(_onAssignOrderToStation);
    on<StartOrderPreparationEvent>(_onStartOrderPreparation);
    on<MarkOrderReadyEvent>(_onMarkOrderReady);
    on<CompleteOrderEvent>(_onCompleteOrder);
    on<CancelOrderEvent>(_onCancelOrder);
    on<GetOrderDetailsEvent>(_onGetOrderDetails);
    on<RefreshOrdersEvent>(_onRefreshOrders);
    on<FilterOrdersEvent>(_onFilterOrders);
    on<SortOrdersEvent>(_onSortOrders);
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }

  /// Load orders from repository
  Future<void> _onLoadOrders(
    LoadOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState(operation: 'Loading orders'));

    final result = await _getAllOrdersUseCase();

    result.fold(
      (failure) =>
          emit(OrderErrorState.fromFailure(failure, operation: 'Load orders')),
      (orders) {
        _allOrders = orders;
        _filteredOrders = _applyFilters(orders, event);

        if (_filteredOrders.isEmpty) {
          emit(OrdersEmptyState(message: 'No orders found'));
        } else {
          emit(
            OrdersLoadedState(
              orders: _allOrders,
              filteredOrders: _filteredOrders,
              isRealTimeActive: false,
            ),
          );
        }
      },
    );
  }

  /// Update order status
  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState(operation: 'Updating order status'));

    // Use the simple call method for UpdateOrderStatusUseCase
    final result = await _updateOrderStatusUseCase(
      event.orderId,
      event.newStatus,
    );

    result.fold(
      (failure) => emit(
        OrderErrorState.fromFailure(failure, operation: 'Update status'),
      ),
      (updatedOrder) {
        _updateOrderInList(updatedOrder);

        emit(
          OrderOperationSuccessState(
            message: 'Order status updated to ${event.newStatus.displayName}',
            updatedOrder: updatedOrder,
          ),
        );

        // Update orders list state
        emit(
          OrdersLoadedState(
            orders: _allOrders,
            filteredOrders: _filteredOrders,
          ),
        );
      },
    );
  }

  /// Assign order to station
  Future<void> _onAssignOrderToStation(
    AssignOrderToStationEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState(operation: 'Assigning order to station'));

    // Use the simple call method for AssignOrderToStationUseCase
    final result = await _assignOrderToStationUseCase(
      event.orderId,
      event.stationId,
    );

    result.fold(
      (failure) => emit(
        OrderErrorState.fromFailure(failure, operation: 'Assign to station'),
      ),
      (updatedOrder) {
        _updateOrderInList(updatedOrder);

        emit(
          OrderOperationSuccessState(
            message: 'Order assigned to station successfully',
            updatedOrder: updatedOrder,
          ),
        );

        // Update orders list state
        emit(
          OrdersLoadedState(
            orders: _allOrders,
            filteredOrders: _filteredOrders,
          ),
        );
      },
    );
  }

  /// Start order preparation
  Future<void> _onStartOrderPreparation(
    StartOrderPreparationEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState(operation: 'Starting order preparation'));

    // Update order status to preparing
    final result = await _updateOrderStatusUseCase(
      event.orderId,
      OrderStatus.preparing(),
    );

    result.fold(
      (failure) => emit(
        OrderErrorState.fromFailure(failure, operation: 'Start preparation'),
      ),
      (updatedOrder) {
        _updateOrderInList(updatedOrder);

        emit(
          OrderOperationSuccessState(
            message: 'Order preparation started',
            updatedOrder: updatedOrder,
          ),
        );

        // Update orders list state
        emit(
          OrdersLoadedState(
            orders: _allOrders,
            filteredOrders: _filteredOrders,
          ),
        );
      },
    );
  }

  /// Mark order as ready
  Future<void> _onMarkOrderReady(
    MarkOrderReadyEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState(operation: 'Marking order as ready'));

    // Update order status to ready
    final result = await _updateOrderStatusUseCase(
      event.orderId,
      OrderStatus.ready(),
    );

    result.fold(
      (failure) =>
          emit(OrderErrorState.fromFailure(failure, operation: 'Mark ready')),
      (updatedOrder) {
        _updateOrderInList(updatedOrder);

        emit(
          OrderOperationSuccessState(
            message: 'Order marked as ready',
            updatedOrder: updatedOrder,
          ),
        );

        // Update orders list state
        emit(
          OrdersLoadedState(
            orders: _allOrders,
            filteredOrders: _filteredOrders,
          ),
        );
      },
    );
  }

  /// Complete order
  Future<void> _onCompleteOrder(
    CompleteOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState(operation: 'Completing order'));

    // Update order status to completed
    final result = await _updateOrderStatusUseCase(
      event.orderId,
      OrderStatus.completed(),
    );

    result.fold(
      (failure) => emit(
        OrderErrorState.fromFailure(failure, operation: 'Complete order'),
      ),
      (updatedOrder) {
        _updateOrderInList(updatedOrder);

        emit(
          OrderOperationSuccessState(
            message: 'Order completed successfully',
            updatedOrder: updatedOrder,
          ),
        );

        // Update orders list state
        emit(
          OrdersLoadedState(
            orders: _allOrders,
            filteredOrders: _filteredOrders,
          ),
        );
      },
    );
  }

  /// Cancel order
  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState(operation: 'Cancelling order'));

    // Use the simple call method for CancelOrderUseCase
    final result = await _cancelOrderUseCase(event.orderId, event.reason);

    result.fold(
      (failure) =>
          emit(OrderErrorState.fromFailure(failure, operation: 'Cancel order')),
      (updatedOrder) {
        _updateOrderInList(updatedOrder);

        emit(
          OrderOperationSuccessState(
            message: 'Order cancelled: ${event.reason}',
            updatedOrder: updatedOrder,
          ),
        );

        // Update orders list state
        emit(
          OrdersLoadedState(
            orders: _allOrders,
            filteredOrders: _filteredOrders,
          ),
        );
      },
    );
  }

  /// Get order details
  Future<void> _onGetOrderDetails(
    GetOrderDetailsEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState(operation: 'Loading order details'));

    final result = await _getOrderByIdUseCase(event.orderId);

    result.fold(
      (failure) => emit(
        OrderErrorState.fromFailure(failure, operation: 'Load order details'),
      ),
      (order) => emit(OrderDetailsLoadedState(order: order)),
    );
  }

  /// Refresh orders
  Future<void> _onRefreshOrders(
    RefreshOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    add(LoadOrdersEvent());
  }

  /// Filter orders
  Future<void> _onFilterOrders(
    FilterOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    _activeFilters = <String, dynamic>{
      if (event.status != null) 'status': event.status,
      if (event.stationId != null) 'stationId': event.stationId,
      if (event.dateFrom != null) 'dateFrom': event.dateFrom,
      if (event.dateTo != null) 'dateTo': event.dateTo,
      if (event.searchQuery != null && event.searchQuery!.isNotEmpty)
        'searchQuery': event.searchQuery,
    };

    _filteredOrders = _applyCurrentFilters(_allOrders);

    emit(
      OrdersFilteredState(
        allOrders: _allOrders,
        filteredOrders: _filteredOrders,
        activeFilters: Map<String, dynamic>.from(_activeFilters),
      ),
    );
  }

  /// Sort orders
  Future<void> _onSortOrders(
    SortOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    _filteredOrders = _sortOrders(
      _filteredOrders,
      event.sortBy,
      event.ascending,
    );

    emit(
      OrdersLoadedState(orders: _allOrders, filteredOrders: _filteredOrders),
    );
  }

  // Helper methods

  /// Apply filters based on event criteria
  List<Order> _applyFilters(List<Order> orders, LoadOrdersEvent event) {
    var filtered = orders;

    if (event.filterStatus != null) {
      filtered = filtered
          .where((order) => order.status == event.filterStatus)
          .toList();
    }

    if (event.stationId != null) {
      filtered = filtered
          .where((order) => order.assignedStationId == event.stationId)
          .toList();
    }

    if (!event.includeCompleted) {
      filtered = filtered.where((order) => !order.status.isCompleted).toList();
    }

    return filtered;
  }

  /// Apply current active filters
  List<Order> _applyCurrentFilters(List<Order> orders) {
    var filtered = orders;

    if (_activeFilters.containsKey('status')) {
      final status = _activeFilters['status'] as OrderStatus;
      filtered = filtered.where((order) => order.status == status).toList();
    }

    if (_activeFilters.containsKey('stationId')) {
      final stationId = _activeFilters['stationId'];
      filtered = filtered
          .where((order) => order.assignedStationId == stationId)
          .toList();
    }

    if (_activeFilters.containsKey('searchQuery')) {
      final query = _activeFilters['searchQuery'] as String;
      filtered = filtered
          .where(
            (order) =>
                order.id.toString().contains(query.toLowerCase()) ||
                (order.specialInstructions?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }

    return filtered;
  }

  /// Sort orders by criteria
  List<Order> _sortOrders(
    List<Order> orders,
    OrderSortBy sortBy,
    bool ascending,
  ) {
    final sorted = List<Order>.from(orders);

    switch (sortBy) {
      case OrderSortBy.createdTime:
        sorted.sort(
          (a, b) => ascending
              ? a.createdAt.dateTime.compareTo(b.createdAt.dateTime)
              : b.createdAt.dateTime.compareTo(a.createdAt.dateTime),
        );
        break;
      case OrderSortBy.priority:
        sorted.sort(
          (a, b) => ascending
              ? a.priority.level.compareTo(b.priority.level)
              : b.priority.level.compareTo(a.priority.level),
        );
        break;
      case OrderSortBy.estimatedTime:
        sorted.sort(
          (a, b) => ascending
              ? a.estimatedTimeMinutes.compareTo(b.estimatedTimeMinutes)
              : b.estimatedTimeMinutes.compareTo(a.estimatedTimeMinutes),
        );
        break;
      case OrderSortBy.status:
        sorted.sort(
          (a, b) => ascending
              ? a.status.sortOrder.compareTo(b.status.sortOrder)
              : b.status.sortOrder.compareTo(a.status.sortOrder),
        );
        break;
      case OrderSortBy.tableNumber:
        sorted.sort((a, b) {
          final aTable = a.tableId?.toString() ?? '';
          final bTable = b.tableId?.toString() ?? '';
          return ascending
              ? aTable.compareTo(bTable)
              : bTable.compareTo(aTable);
        });
        break;
    }

    return sorted;
  }

  /// Update order in the local list
  void _updateOrderInList(Order updatedOrder) {
    final index = _allOrders.indexWhere((order) => order.id == updatedOrder.id);
    if (index != -1) {
      _allOrders[index] = updatedOrder;
      _filteredOrders = _applyCurrentFilters(_allOrders);
    }
  }

  // Public helper methods for UI

  /// Get orders by status
  List<Order> getOrdersByStatus(OrderStatus status) {
    return _filteredOrders.where((order) => order.status == status).toList();
  }

  /// Check if user can perform operation on order
  bool canPerformOperation(
    Order order,
    String operation, {
    required bool isManager,
  }) {
    switch (operation) {
      case 'start':
        return order.status.isConfirmed;
      case 'ready':
        return order.status.isPreparing;
      case 'complete':
        return order.status.isReady;
      case 'cancel':
        return order.canBeCancelled && isManager;
      case 'assign':
        return isManager && !order.status.isCompleted;
      default:
        return false;
    }
  }
}
