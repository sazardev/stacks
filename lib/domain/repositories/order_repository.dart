import 'package:dartz/dartz.dart' show Either, Unit;
import '../entities/order.dart';
import '../entities/order_item.dart';
import '../value_objects/user_id.dart';
import '../value_objects/order_status.dart';
import '../value_objects/priority.dart';
import '../failures/failures.dart';

/// Repository interface for Order operations
abstract class OrderRepository {
  /// Creates a new order
  Future<Either<Failure, Order>> createOrder(Order order);

  /// Gets an order by its ID
  Future<Either<Failure, Order>> getOrderById(UserId orderId);

  /// Gets all orders
  Future<Either<Failure, List<Order>>> getAllOrders();

  /// Gets orders by status
  Future<Either<Failure, List<Order>>> getOrdersByStatus(OrderStatus status);

  /// Gets orders by station
  Future<Either<Failure, List<Order>>> getOrdersByStation(UserId stationId);

  /// Gets orders by customer
  Future<Either<Failure, List<Order>>> getOrdersByCustomer(UserId customerId);

  /// Gets orders by priority
  Future<Either<Failure, List<Order>>> getOrdersByPriority(Priority priority);

  /// Gets pending orders
  Future<Either<Failure, List<Order>>> getPendingOrders();

  /// Gets active orders (confirmed, preparing, ready)
  Future<Either<Failure, List<Order>>> getActiveOrders();

  /// Updates an order
  Future<Either<Failure, Order>> updateOrder(Order order);

  /// Updates order status
  Future<Either<Failure, Order>> updateOrderStatus(
    UserId orderId,
    OrderStatus status,
  );

  /// Updates order priority
  Future<Either<Failure, Order>> updateOrderPriority(
    UserId orderId,
    Priority priority,
  );

  /// Assigns order to station
  Future<Either<Failure, Order>> assignOrderToStation(
    UserId orderId,
    UserId stationId,
  );

  /// Adds item to order
  Future<Either<Failure, Order>> addItemToOrder(UserId orderId, OrderItem item);

  /// Removes item from order
  Future<Either<Failure, Order>> removeItemFromOrder(
    UserId orderId,
    UserId itemId,
  );

  /// Updates order item
  Future<Either<Failure, Order>> updateOrderItem(
    UserId orderId,
    OrderItem item,
  );

  /// Cancels an order
  Future<Either<Failure, Order>> cancelOrder(UserId orderId, String reason);

  /// Deletes an order
  Future<Either<Failure, Unit>> deleteOrder(UserId orderId);

  /// Gets orders within a time range
  Future<Either<Failure, List<Order>>> getOrdersInTimeRange(
    DateTime startTime,
    DateTime endTime,
  );

  /// Gets order statistics
  Future<Either<Failure, Map<String, dynamic>>> getOrderStatistics();

  /// Watches real-time order updates
  Stream<Either<Failure, List<Order>>> watchOrders();

  /// Watches specific order updates
  Stream<Either<Failure, Order>> watchOrder(UserId orderId);
}
