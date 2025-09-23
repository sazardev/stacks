// Order Use Cases for Clean Architecture Application Layer
// Consolidated all dispersed order use cases with enhanced business logic

import 'package:dartz/dartz.dart' hide Order;
import 'package:injectable/injectable.dart' hide Order;
import '../../../domain/entities/order.dart';
import '../../../domain/entities/order_item.dart';
import '../../../domain/entities/recipe.dart';
import '../../../domain/repositories/order_repository.dart';
import '../../../domain/repositories/recipe_repository.dart';
import '../../../domain/repositories/station_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/order_status.dart';
import '../../../domain/value_objects/priority.dart';
import '../../../domain/value_objects/time.dart';
import '../../dtos/order_dtos.dart';
import '../../dtos/station_dtos.dart' as StationDtos;

/// Use case for creating an order with enhanced business logic validation
@injectable
class CreateOrderUseCase {
  final OrderRepository _orderRepository;
  final RecipeRepository _recipeRepository;

  const CreateOrderUseCase({
    required OrderRepository orderRepository,
    required RecipeRepository recipeRepository,
  }) : _orderRepository = orderRepository,
       _recipeRepository = recipeRepository;

  // Simple direct call for basic usage
  Future<Either<Failure, Order>> call(Order order) {
    return _orderRepository.createOrder(order);
  }

  /// Enhanced execution with business logic validation using DTOs
  Future<Either<Failure, Order>> execute(CreateOrderDto dto) async {
    try {
      // Validate input
      final validationResult = _validateInput(dto);
      if (validationResult != null) {
        return Left(validationResult);
      }

      // Validate recipes exist and are available
      final recipes = <Recipe>[];
      for (final item in dto.items) {
        final recipeResult = await _recipeRepository.getRecipeById(
          item.recipeId,
        );
        if (recipeResult.isLeft()) {
          return Left(
            BusinessRuleFailure('Recipe not found: ${item.recipeId.value}'),
          );
        }
        recipes.add(
          recipeResult.fold(
            (_) => throw StateError('This should not happen'),
            (recipe) => recipe,
          ),
        );
      }

      // Build OrderItems
      final orderItems = <OrderItem>[];
      for (int i = 0; i < dto.items.length; i++) {
        final itemDto = dto.items[i];
        final recipe = recipes[i];
        final orderItem = OrderItem(
          id: UserId.generate(),
          recipe: recipe,
          quantity: itemDto.quantity,
          specialInstructions: itemDto.specialInstructions,
          status: OrderItemStatus.pending,
          createdAt: Time.now(),
        );
        orderItems.add(orderItem);
      }

      // Create Order entity
      final order = Order(
        id: UserId.generate(),
        customerId: dto.customerId,
        tableId: dto.tableId,
        items: orderItems,
        status: OrderStatus.pending(),
        priority: dto.priority,
        specialInstructions: dto.specialInstructions,
        createdAt: Time.now(),
      );

      // Create order in repository
      return await _orderRepository.createOrder(order);
    } catch (e) {
      return Left(ServerFailure('Error creating order: $e'));
    }
  }

  ValidationFailure? _validateInput(CreateOrderDto dto) {
    if (dto.items.isEmpty) {
      return const ValidationFailure('Order must have at least one item');
    }

    for (final item in dto.items) {
      if (item.quantity <= 0) {
        return const ValidationFailure('Item quantity must be positive');
      }
    }

    return null;
  }
}

/// Use case for getting order by ID
@injectable
class GetOrderByIdUseCase {
  final OrderRepository _repository;

  const GetOrderByIdUseCase({required OrderRepository repository})
    : _repository = repository;

  Future<Either<Failure, Order>> call(UserId orderId) {
    return _repository.getOrderById(orderId);
  }
}

/// Use case for getting all orders
class GetAllOrdersUseCase {
  final OrderRepository _repository;

  GetAllOrdersUseCase(this._repository);

  Future<Either<Failure, List<Order>>> call() {
    return _repository.getAllOrders();
  }
}

/// Use case for getting orders by status
class GetOrdersByStatusUseCase {
  final OrderRepository _repository;

  GetOrdersByStatusUseCase(this._repository);

  Future<Either<Failure, List<Order>>> call(OrderStatus status) {
    return _repository.getOrdersByStatus(status);
  }
}

/// Use case for getting orders by station
class GetOrdersByStationUseCase {
  final OrderRepository _repository;

  GetOrdersByStationUseCase(this._repository);

  Future<Either<Failure, List<Order>>> call(UserId stationId) {
    return _repository.getOrdersByStation(stationId);
  }
}

/// Use case for getting orders by customer
class GetOrdersByCustomerUseCase {
  final OrderRepository _repository;

  GetOrdersByCustomerUseCase(this._repository);

  Future<Either<Failure, List<Order>>> call(UserId customerId) {
    return _repository.getOrdersByCustomer(customerId);
  }
}

/// Use case for getting orders by priority
class GetOrdersByPriorityUseCase {
  final OrderRepository _repository;

  GetOrdersByPriorityUseCase(this._repository);

  Future<Either<Failure, List<Order>>> call(Priority priority) {
    return _repository.getOrdersByPriority(priority);
  }
}

/// Use case for updating order status with enhanced validation
@injectable
class UpdateOrderStatusUseCase {
  final OrderRepository _repository;

  const UpdateOrderStatusUseCase({required OrderRepository repository})
    : _repository = repository;

  // Simple direct call for basic usage
  Future<Either<Failure, Order>> call(UserId orderId, OrderStatus newStatus) {
    return _repository.updateOrderStatus(orderId, newStatus);
  }

  /// Enhanced execution with business logic validation using DTOs
  Future<Either<Failure, Order>> execute(UpdateOrderStatusDto dto) async {
    try {
      // Validate status
      final validationResult = _validateStatus(dto.status);
      if (validationResult != null) {
        return Left(validationResult);
      }

      // Get existing order
      final orderResult = await _repository.getOrderById(dto.orderId);
      if (orderResult.isLeft()) {
        return orderResult.fold(
          (failure) => Left(failure),
          (_) => throw StateError('This should not happen'),
        );
      }

      final existingOrder = orderResult.fold(
        (_) => throw StateError('This should not happen'),
        (order) => order,
      );

      // Validate status transition
      final transitionResult = _validateStatusTransition(
        existingOrder.status,
        OrderStatus.fromString(dto.status),
      );
      if (transitionResult != null) {
        return Left(transitionResult);
      }

      // Update order status
      final updatedStatus = OrderStatus.fromString(dto.status);
      return await _repository.updateOrderStatus(dto.orderId, updatedStatus);
    } catch (e) {
      return Left(ServerFailure('Error updating order status: $e'));
    }
  }

  ValidationFailure? _validateStatus(String status) {
    final validStatuses = [
      'pending',
      'confirmed',
      'preparing',
      'ready',
      'completed',
      'cancelled',
    ];

    if (!validStatuses.contains(status.toLowerCase())) {
      return ValidationFailure('Invalid order status: $status');
    }

    return null;
  }

  BusinessRuleFailure? _validateStatusTransition(
    OrderStatus currentStatus,
    OrderStatus newStatus,
  ) {
    // Define valid transitions
    final validTransitions = {
      'pending': ['confirmed', 'cancelled'],
      'confirmed': ['preparing', 'cancelled'],
      'preparing': ['ready', 'cancelled'],
      'ready': ['completed', 'cancelled'],
      'completed': <String>[], // No transitions from completed
      'cancelled': <String>[], // No transitions from cancelled
    };

    final currentStatusStr = currentStatus.value.toLowerCase();
    final newStatusStr = newStatus.value.toLowerCase();

    final allowedTransitions = validTransitions[currentStatusStr] ?? [];
    if (!allowedTransitions.contains(newStatusStr)) {
      return BusinessRuleFailure(
        'Invalid status transition from $currentStatusStr to $newStatusStr',
      );
    }

    return null;
  }
}

/// Use case for updating order priority with enhanced validation
@injectable
class PrioritizeOrderUseCase {
  final OrderRepository _repository;

  const PrioritizeOrderUseCase({required OrderRepository repository})
    : _repository = repository;

  // Simple direct call for basic usage
  Future<Either<Failure, Order>> call(UserId orderId, Priority newPriority) {
    return _repository.updateOrderPriority(orderId, newPriority);
  }

  /// Enhanced execution with business logic validation using DTOs
  Future<Either<Failure, Order>> execute(UpdateOrderPriorityDto dto) async {
    try {
      // Validate priority level
      final validationResult = _validatePriorityLevel(dto.priorityLevel);
      if (validationResult != null) {
        return Left(validationResult);
      }

      // Get existing order
      final orderResult = await _repository.getOrderById(dto.orderId);
      if (orderResult.isLeft()) {
        return orderResult.fold(
          (failure) => Left(failure),
          (_) => throw StateError('This should not happen'),
        );
      }

      final existingOrder = orderResult.fold(
        (_) => throw StateError('This should not happen'),
        (order) => order,
      );

      // Validate that order can be prioritized
      final canPrioritize = _canOrderBePrioritized(existingOrder);
      if (!canPrioritize) {
        return Left(
          BusinessRuleFailure(
            'Order cannot be prioritized in current status: ${existingOrder.status.value}',
          ),
        );
      }

      // Create new priority
      final newPriority = Priority(dto.priorityLevel);

      // Update order priority
      return await _repository.updateOrderPriority(dto.orderId, newPriority);
    } catch (e) {
      return Left(ServerFailure('Error updating order priority: $e'));
    }
  }

  ValidationFailure? _validatePriorityLevel(int priorityLevel) {
    if (priorityLevel < 1 || priorityLevel > 5) {
      return const ValidationFailure('Priority level must be between 1 and 5');
    }
    return null;
  }

  bool _canOrderBePrioritized(Order order) {
    // Orders can only be prioritized if they are not completed or cancelled
    final status = order.status.value.toLowerCase();
    return status != 'completed' && status != 'cancelled';
  }
}

/// Use case for assigning order to station with enhanced validation
@injectable
class AssignOrderToStationUseCase {
  final OrderRepository _orderRepository;
  final StationRepository _stationRepository;

  const AssignOrderToStationUseCase({
    required OrderRepository orderRepository,
    required StationRepository stationRepository,
  }) : _orderRepository = orderRepository,
       _stationRepository = stationRepository;

  // Simple direct call for basic usage
  Future<Either<Failure, Order>> call(UserId orderId, UserId stationId) {
    return _orderRepository.assignOrderToStation(orderId, stationId);
  }

  /// Enhanced execution with business logic validation using DTOs
  Future<Either<Failure, Order>> execute(
    StationDtos.AssignOrderToStationDto dto,
  ) async {
    try {
      // Get the order
      final orderResult = await _orderRepository.getOrderById(dto.orderId);
      if (orderResult.isLeft()) {
        return orderResult.fold(
          (failure) => Left(failure),
          (_) => throw StateError('This should not happen'),
        );
      }

      final order = orderResult.fold(
        (_) => throw StateError('This should not happen'),
        (order) => order,
      );

      // Validate order can be assigned
      if (!_canOrderBeAssigned(order)) {
        return Left(
          BusinessRuleFailure(
            'Order cannot be assigned in current status: ${order.status.value}',
          ),
        );
      }

      // Get the station to validate it exists and is available
      final stationResult = await _stationRepository.getStationById(
        dto.stationId,
      );
      if (stationResult.isLeft()) {
        return Left(
          NotFoundFailure('Station not found: ${dto.stationId.value}'),
        );
      }

      final station = stationResult.fold(
        (_) => throw StateError('This should not happen'),
        (station) => station,
      );

      // Validate station is available and can handle the order
      if (!_canStationHandleOrder(station, order)) {
        return Left(
          BusinessRuleFailure(
            'Station ${station.name} cannot handle this order type',
          ),
        );
      }

      // Assign order to station
      return await _orderRepository.assignOrderToStation(
        dto.orderId,
        dto.stationId,
      );
    } catch (e) {
      return Left(ServerFailure('Error assigning order to station: $e'));
    }
  }

  bool _canOrderBeAssigned(Order order) {
    // Orders can only be assigned if they are confirmed or pending
    final status = order.status.value.toLowerCase();
    return status == 'confirmed' || status == 'pending';
  }

  bool _canStationHandleOrder(dynamic station, Order order) {
    // Basic validation - in a real app, this would check station capabilities
    // against order requirements (recipe types, equipment needed, etc.)
    return true; // Simplified for now
  }
}

/// Use case for completing an order with enhanced validation
@injectable
class CompleteOrderUseCase {
  final OrderRepository _repository;

  const CompleteOrderUseCase({required OrderRepository repository})
    : _repository = repository;

  // Simple direct call for basic usage
  Future<Either<Failure, Order>> call(UserId orderId) {
    return _repository.updateOrderStatus(orderId, OrderStatus.completed());
  }

  /// Enhanced execution with business logic validation
  Future<Either<Failure, Order>> execute(UserId orderId) async {
    try {
      // Get existing order
      final orderResult = await _repository.getOrderById(orderId);
      if (orderResult.isLeft()) {
        return orderResult.fold(
          (failure) => Left(failure),
          (_) => throw StateError('This should not happen'),
        );
      }

      final existingOrder = orderResult.fold(
        (_) => throw StateError('This should not happen'),
        (order) => order,
      );

      // Validate order can be completed
      if (!_canOrderBeCompleted(existingOrder)) {
        return Left(
          BusinessRuleFailure(
            'Order cannot be completed in current status: ${existingOrder.status.value}',
          ),
        );
      }

      // Validate all items are ready
      if (!_areAllItemsReady(existingOrder)) {
        return Left(
          BusinessRuleFailure('Cannot complete order: not all items are ready'),
        );
      }

      // Complete the order
      return await _repository.updateOrderStatus(
        orderId,
        OrderStatus.completed(),
      );
    } catch (e) {
      return Left(ServerFailure('Error completing order: $e'));
    }
  }

  bool _canOrderBeCompleted(Order order) {
    // Orders can only be completed if they are ready
    final status = order.status.value.toLowerCase();
    return status == 'ready' || status == 'preparing';
  }

  bool _areAllItemsReady(Order order) {
    // Check that all order items are ready or delivered
    return order.items.every(
      (item) =>
          item.status == OrderItemStatus.ready ||
          item.status == OrderItemStatus.delivered,
    );
  }
}

/// Use case for canceling an order
class CancelOrderUseCase {
  final OrderRepository _repository;

  CancelOrderUseCase(this._repository);

  Future<Either<Failure, Order>> call(UserId orderId, String reason) {
    return _repository.cancelOrder(orderId, reason);
  }
}

/// Use case for updating order
class UpdateOrderUseCase {
  final OrderRepository _repository;

  UpdateOrderUseCase(this._repository);

  Future<Either<Failure, Order>> call(Order order) {
    return _repository.updateOrder(order);
  }
}

/// Use case for adding item to order
class AddItemToOrderUseCase {
  final OrderRepository _repository;

  AddItemToOrderUseCase(this._repository);

  Future<Either<Failure, Order>> call(UserId orderId, OrderItem item) {
    return _repository.addItemToOrder(orderId, item);
  }
}

/// Use case for removing item from order
class RemoveItemFromOrderUseCase {
  final OrderRepository _repository;

  RemoveItemFromOrderUseCase(this._repository);

  Future<Either<Failure, Order>> call(UserId orderId, UserId itemId) {
    return _repository.removeItemFromOrder(orderId, itemId);
  }
}

/// Use case for updating order item
class UpdateOrderItemUseCase {
  final OrderRepository _repository;

  UpdateOrderItemUseCase(this._repository);

  Future<Either<Failure, Order>> call(UserId orderId, OrderItem updatedItem) {
    return _repository.updateOrderItem(orderId, updatedItem);
  }
}

/// Use case for getting pending orders
class GetPendingOrdersUseCase {
  final OrderRepository _repository;

  GetPendingOrdersUseCase(this._repository);

  Future<Either<Failure, List<Order>>> call() {
    return _repository.getPendingOrders();
  }
}

/// Use case for getting active orders
class GetActiveOrdersUseCase {
  final OrderRepository _repository;

  GetActiveOrdersUseCase(this._repository);

  Future<Either<Failure, List<Order>>> call() {
    return _repository.getActiveOrders();
  }
}

/// Use case for getting order history
class GetOrderHistoryUseCase {
  final OrderRepository _repository;

  GetOrderHistoryUseCase(this._repository);

  Future<Either<Failure, List<Order>>> call(Time startDate, Time endDate) {
    return _repository.getOrdersInTimeRange(
      startDate.dateTime,
      endDate.dateTime,
    );
  }
}

/// Use case for deleting order
class DeleteOrderUseCase {
  final OrderRepository _repository;

  DeleteOrderUseCase(this._repository);

  Future<Either<Failure, Unit>> call(UserId orderId) {
    return _repository.deleteOrder(orderId);
  }
}
