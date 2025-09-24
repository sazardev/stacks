// Order Repository Implementation for Clean Architecture Infrastructure Layer
// Simplified mock implementation for development foundation

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/order.dart' as domain;
import '../../domain/entities/order_item.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/failures/failures.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/order_status.dart';
import '../../domain/value_objects/priority.dart';
import '../mappers/order_mapper.dart';

@LazySingleton(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  final OrderMapper _orderMapper;

  // In-memory storage for development
  final Map<String, Map<String, dynamic>> _orders = {};
  final Map<String, List<Map<String, dynamic>>> _ordersByStation = {};
  final Map<String, List<Map<String, dynamic>>> _ordersByUser = {};

  OrderRepositoryImpl({required OrderMapper orderMapper})
    : _orderMapper = orderMapper;

  @override
  Future<Either<Failure, domain.Order>> createOrder(domain.Order order) async {
    try {
      final orderData = _orderMapper.toFirestore(order);
      _orders[order.id.value] = orderData;

      // Update station orders
      if (order.assignedStationId != null) {
        if (!_ordersByStation.containsKey(order.assignedStationId!.value)) {
          _ordersByStation[order.assignedStationId!.value] = [];
        }
        _ordersByStation[order.assignedStationId!.value]!.add(orderData);
      }

      // Update user orders
      if (!_ordersByUser.containsKey(order.customerId.value)) {
        _ordersByUser[order.customerId.value] = [];
      }
      _ordersByUser[order.customerId.value]!.add(orderData);

      return Right(order);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.Order>> getOrderById(UserId orderId) async {
    try {
      final orderData = _orders[orderId.value];
      if (orderData == null) {
        return Left(NotFoundFailure('Order not found: ${orderId.value}'));
      }

      final order = _orderMapper.fromFirestore(orderData, orderId.value, []);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<domain.Order>>> getAllOrders() async {
    try {
      final orders = _orders.values
          .map(
            (data) =>
                _orderMapper.fromFirestore(data, data['id'] as String, []),
          )
          .toList();
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<domain.Order>>> getOrdersByStatus(
    OrderStatus status,
  ) async {
    try {
      final orders = _orders.values
          .where(
            (data) => data['status'] == _orderMapper.statusToString(status),
          )
          .map(
            (data) =>
                _orderMapper.fromFirestore(data, data['id'] as String, []),
          )
          .toList();
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<domain.Order>>> getOrdersByStation(
    UserId stationId,
  ) async {
    try {
      final ordersData = _ordersByStation[stationId.value] ?? [];
      final orders = ordersData
          .map(
            (data) =>
                _orderMapper.fromFirestore(data, data['id'] as String, []),
          )
          .toList();
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<domain.Order>>> getOrdersByCustomer(
    UserId customerId,
  ) async {
    try {
      final ordersData = _ordersByUser[customerId.value] ?? [];
      final orders = ordersData
          .map(
            (data) =>
                _orderMapper.fromFirestore(data, data['id'] as String, []),
          )
          .toList();
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<domain.Order>>> getOrdersByPriority(
    Priority priority,
  ) async {
    try {
      final orders = _orders.values
          .where((data) => data['priority'] == priority.level)
          .map(
            (data) =>
                _orderMapper.fromFirestore(data, data['id'] as String, []),
          )
          .toList();
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<domain.Order>>> getPendingOrders() async {
    try {
      final orders = _orders.values
          .where((data) => data['status'] == 'pending')
          .map(
            (data) =>
                _orderMapper.fromFirestore(data, data['id'] as String, []),
          )
          .toList();
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<domain.Order>>> getActiveOrders() async {
    try {
      final activeStatuses = ['confirmed', 'preparing', 'ready'];
      final orders = _orders.values
          .where((data) => activeStatuses.contains(data['status']))
          .map(
            (data) =>
                _orderMapper.fromFirestore(data, data['id'] as String, []),
          )
          .toList();
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.Order>> updateOrder(domain.Order order) async {
    try {
      final orderData = _orderMapper.toFirestore(order);
      _orders[order.id.value] = orderData;
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.Order>> updateOrderStatus(
    UserId orderId,
    OrderStatus status,
  ) async {
    try {
      final orderData = _orders[orderId.value];
      if (orderData == null) {
        return Left(NotFoundFailure('Order not found: ${orderId.value}'));
      }

      orderData['status'] = _orderMapper.statusToString(status);
      orderData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final updatedOrder = _orderMapper.fromFirestore(
        orderData,
        orderId.value,
        [],
      );
      return Right(updatedOrder);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.Order>> updateOrderPriority(
    UserId orderId,
    Priority priority,
  ) async {
    try {
      final orderData = _orders[orderId.value];
      if (orderData == null) {
        return Left(NotFoundFailure('Order not found: ${orderId.value}'));
      }

      orderData['priority'] = priority.level;
      orderData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final updatedOrder = _orderMapper.fromFirestore(
        orderData,
        orderId.value,
        [],
      );
      return Right(updatedOrder);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.Order>> assignOrderToStation(
    UserId orderId,
    UserId stationId,
  ) async {
    try {
      final orderData = _orders[orderId.value];
      if (orderData == null) {
        return Left(NotFoundFailure('Order not found: ${orderId.value}'));
      }

      orderData['assignedStationId'] = stationId.value;
      orderData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final updatedOrder = _orderMapper.fromFirestore(
        orderData,
        orderId.value,
        [],
      );
      return Right(updatedOrder);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.Order>> addItemToOrder(
    UserId orderId,
    OrderItem item,
  ) async {
    try {
      final orderData = _orders[orderId.value];
      if (orderData == null) {
        return Left(NotFoundFailure('Order not found: ${orderId.value}'));
      }

      final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
      items.add(_orderMapper.orderItemToFirestore(item));
      orderData['items'] = items;
      orderData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final updatedOrder = _orderMapper.fromFirestore(
        orderData,
        orderId.value,
        [],
      );
      return Right(updatedOrder);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.Order>> removeItemFromOrder(
    UserId orderId,
    UserId itemId,
  ) async {
    try {
      final orderData = _orders[orderId.value];
      if (orderData == null) {
        return Left(NotFoundFailure('Order not found: ${orderId.value}'));
      }

      final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
      items.removeWhere((item) => item['id'] == itemId.value);
      orderData['items'] = items;
      orderData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final updatedOrder = _orderMapper.fromFirestore(
        orderData,
        orderId.value,
        [],
      );
      return Right(updatedOrder);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.Order>> updateOrderItem(
    UserId orderId,
    OrderItem item,
  ) async {
    try {
      final orderData = _orders[orderId.value];
      if (orderData == null) {
        return Left(NotFoundFailure('Order not found: ${orderId.value}'));
      }

      final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
      final itemIndex = items.indexWhere((i) => i['id'] == item.id.value);
      if (itemIndex == -1) {
        return Left(NotFoundFailure('Order item not found: ${item.id.value}'));
      }

      items[itemIndex] = _orderMapper.orderItemToFirestore(item);
      orderData['items'] = items;
      orderData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final updatedOrder = _orderMapper.fromFirestore(
        orderData,
        orderId.value,
        [],
      );
      return Right(updatedOrder);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.Order>> cancelOrder(
    UserId orderId,
    String reason,
  ) async {
    try {
      final orderData = _orders[orderId.value];
      if (orderData == null) {
        return Left(NotFoundFailure('Order not found: ${orderId.value}'));
      }

      orderData['status'] = 'cancelled';
      orderData['cancellationReason'] = reason;
      orderData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final updatedOrder = _orderMapper.fromFirestore(
        orderData,
        orderId.value,
        [],
      );
      return Right(updatedOrder);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteOrder(UserId orderId) async {
    try {
      if (!_orders.containsKey(orderId.value)) {
        return Left(NotFoundFailure('Order not found: ${orderId.value}'));
      }

      _orders.remove(orderId.value);

      // Remove from station and user lists
      _ordersByStation.forEach((key, value) {
        value.removeWhere((order) => order['id'] == orderId.value);
      });
      _ordersByUser.forEach((key, value) {
        value.removeWhere((order) => order['id'] == orderId.value);
      });

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<domain.Order>>> getOrdersInTimeRange(
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final startMillis = startTime.millisecondsSinceEpoch;
      final endMillis = endTime.millisecondsSinceEpoch;

      final orders = _orders.values
          .where((data) {
            final createdAt = data['createdAt'] as int;
            return createdAt >= startMillis && createdAt <= endMillis;
          })
          .map(
            (data) =>
                _orderMapper.fromFirestore(data, data['id'] as String, []),
          )
          .toList();

      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getOrderStatistics() async {
    try {
      final statusCounts = <String, int>{};
      final priorityCounts = <String, int>{};
      int totalOrders = _orders.length;

      for (final data in _orders.values) {
        final status = data['status'] as String;
        final priority = data['priority'].toString();

        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        priorityCounts[priority] = (priorityCounts[priority] ?? 0) + 1;
      }

      return Right({
        'totalOrders': totalOrders,
        'statusCounts': statusCounts,
        'priorityCounts': priorityCounts,
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<domain.Order>>> watchOrders() {
    return Stream.periodic(const Duration(seconds: 1), (_) {
      try {
        final orders = _orders.values
            .map(
              (data) =>
                  _orderMapper.fromFirestore(data, data['id'] as String, []),
            )
            .toList();
        return Right<Failure, List<domain.Order>>(orders);
      } catch (e) {
        return Left<Failure, List<domain.Order>>(ServerFailure(e.toString()));
      }
    });
  }

  @override
  Stream<Either<Failure, domain.Order>> watchOrder(UserId orderId) {
    return Stream.periodic(const Duration(seconds: 1), (_) {
      try {
        final orderData = _orders[orderId.value];
        if (orderData == null) {
          return Left<Failure, domain.Order>(
            NotFoundFailure('Order not found: ${orderId.value}'),
          );
        }

        final order = _orderMapper.fromFirestore(orderData, orderId.value, []);
        return Right<Failure, domain.Order>(order);
      } catch (e) {
        return Left<Failure, domain.Order>(ServerFailure(e.toString()));
      }
    });
  }
}
