// Order BLoC - Simplified Working Version
// Basic order management for kitchen dashboard integration

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/base_bloc.dart';
import 'order_event.dart';
import 'order_state.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/order_item.dart';
import '../../../domain/value_objects/order_status.dart';
import '../../../domain/value_objects/priority.dart';
import '../../../domain/value_objects/time.dart';
import '../../../domain/value_objects/money.dart';
import '../../../domain/value_objects/user_id.dart';

/// Simple OrderBloc implementation with mock data for initial testing
class OrderBloc extends BaseBloc<OrderEvent, OrderState> {
  final List<Order> _orders = [];

  OrderBloc() : super(OrderInitialState()) {
    on<LoadOrdersEvent>(_onLoadOrders);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
  }

  Future<void> _onLoadOrders(
    LoadOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState(operation: 'Loading orders'));

    // Generate mock orders for testing
    final orders = _generateMockOrders();
    _orders.clear();
    _orders.addAll(orders);

    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading

    emit(OrdersLoadedState(orders: _orders));
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState(operation: 'Updating order status'));

    // Find and update order
    final index = _orders.indexWhere((order) => order.id == event.orderId);
    if (index == -1) {
      emit(
        OrderErrorState(message: 'Order not found', operation: 'Update status'),
      );
      return;
    }

    try {
      // Create updated order with new status
      final currentOrder = _orders[index];
      final updatedOrder = _createUpdatedOrder(currentOrder, event.newStatus);
      _orders[index] = updatedOrder;

      emit(
        OrderOperationSuccessState(
          message: 'Order status updated to ${event.newStatus.displayName}',
          updatedOrder: updatedOrder,
        ),
      );

      // Emit updated orders list
      await Future.delayed(const Duration(milliseconds: 200));
      emit(OrdersLoadedState(orders: List.from(_orders)));
    } catch (e) {
      emit(
        OrderErrorState(
          message: 'Failed to update order status: $e',
          operation: 'Update status',
        ),
      );
    }
  }

  Order _createUpdatedOrder(Order currentOrder, OrderStatus newStatus) {
    final now = Time.now();

    return Order(
      id: currentOrder.id,
      customerId: currentOrder.customerId,
      tableId: currentOrder.tableId,
      items: currentOrder.items,
      priority: currentOrder.priority,
      status: newStatus,
      specialInstructions: currentOrder.specialInstructions,
      createdAt: currentOrder.createdAt,
      confirmedAt: newStatus.isConfirmed
          ? (currentOrder.confirmedAt ?? now)
          : currentOrder.confirmedAt,
      startedAt: newStatus.isPreparing
          ? (currentOrder.startedAt ?? now)
          : currentOrder.startedAt,
      readyAt: newStatus.isReady
          ? (currentOrder.readyAt ?? now)
          : currentOrder.readyAt,
      completedAt: newStatus.isCompleted
          ? (currentOrder.completedAt ?? now)
          : currentOrder.completedAt,
    );
  }

  List<Order> _generateMockOrders() {
    return [
      Order(
        id: UserId.fromString('order-001'),
        customerId: UserId.fromString('customer-001'),
        tableId: UserId.fromString('table-01'),
        items: [
          OrderItem(
            recipeId: UserId.fromString('recipe-001'),
            quantity: 2,
            specialInstructions: 'Medium rare',
          ),
        ],
        priority: Priority.createMedium(),
        status: OrderStatus.pending(),
        specialInstructions: 'Extra sauce on the side',
        createdAt: Time.now(),
      ),
      Order(
        id: UserId.fromString('order-002'),
        customerId: UserId.fromString('customer-002'),
        tableId: UserId.fromString('table-02'),
        items: [
          OrderItem(recipeId: UserId.fromString('recipe-002'), quantity: 1),
          OrderItem(recipeId: UserId.fromString('recipe-003'), quantity: 1),
        ],
        priority: Priority.createHigh(),
        status: OrderStatus.preparing(),
        specialInstructions: 'No onions',
        createdAt: Time.fromDateTime(
          DateTime.now().subtract(const Duration(minutes: 10)),
        ),
        confirmedAt: Time.fromDateTime(
          DateTime.now().subtract(const Duration(minutes: 9)),
        ),
        startedAt: Time.fromDateTime(
          DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ),
      Order(
        id: UserId.fromString('order-003'),
        customerId: UserId.fromString('customer-003'),
        tableId: UserId.fromString('table-03'),
        items: [
          OrderItem(recipeId: UserId.fromString('recipe-004'), quantity: 3),
        ],
        priority: Priority.createLow(),
        status: OrderStatus.ready(),
        createdAt: Time.fromDateTime(
          DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        confirmedAt: Time.fromDateTime(
          DateTime.now().subtract(const Duration(minutes: 14)),
        ),
        startedAt: Time.fromDateTime(
          DateTime.now().subtract(const Duration(minutes: 10)),
        ),
        readyAt: Time.fromDateTime(
          DateTime.now().subtract(const Duration(minutes: 2)),
        ),
      ),
      Order(
        id: UserId.fromString('order-004'),
        customerId: UserId.fromString('customer-004'),
        tableId: UserId.fromString('table-04'),
        items: [
          OrderItem(recipeId: UserId.fromString('recipe-005'), quantity: 1),
        ],
        priority: Priority.createMedium(),
        status: OrderStatus.pending(),
        specialInstructions: 'Gluten-free bread',
        createdAt: Time.fromDateTime(
          DateTime.now().subtract(const Duration(minutes: 3)),
        ),
      ),
      Order(
        id: UserId.fromString('order-005'),
        customerId: UserId.fromString('customer-005'),
        items: [
          OrderItem(recipeId: UserId.fromString('recipe-006'), quantity: 2),
        ],
        priority: Priority.createHigh(),
        status: OrderStatus.preparing(),
        createdAt: Time.fromDateTime(
          DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        confirmedAt: Time.fromDateTime(
          DateTime.now().subtract(const Duration(minutes: 7)),
        ),
        startedAt: Time.fromDateTime(
          DateTime.now().subtract(const Duration(minutes: 3)),
        ),
      ),
    ];
  }
}
