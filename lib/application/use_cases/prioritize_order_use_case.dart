import 'package:dartz/dartz.dart' show Either, Left;
import 'package:injectable/injectable.dart' hide Order;
import '../../domain/entities/order.dart';
import '../../domain/value_objects/priority.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/failures/failures.dart';
import '../dtos/order_dtos.dart';

/// Use case for updating order priority
@injectable
class PrioritizeOrderUseCase {
  final OrderRepository _orderRepository;

  const PrioritizeOrderUseCase({required OrderRepository orderRepository})
    : _orderRepository = orderRepository;

  /// Executes the prioritize order use case
  Future<Either<Failure, Order>> execute(UpdateOrderPriorityDto dto) async {
    try {
      // Validate priority level
      final validationResult = _validatePriorityLevel(dto.priorityLevel);
      if (validationResult != null) {
        return Left(validationResult);
      }

      // Get existing order
      final orderResult = await _orderRepository.getOrderById(dto.orderId);
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

      // Check if order can be prioritized (business rule: completed/cancelled orders can't be prioritized)
      if (existingOrder.status.isCompleted ||
          existingOrder.status.isCancelled) {
        return Left(
          BusinessRuleFailure(
            'Order with status ${existingOrder.status.value} cannot be prioritized',
          ),
        );
      }

      // Create new priority and update order
      final newPriority = Priority(dto.priorityLevel);
      final updatedOrder = existingOrder.updatePriority(newPriority);

      // Save updated order
      return await _orderRepository.updateOrder(updatedOrder);
    } catch (e) {
      return Left(ServerFailure('Failed to prioritize order: ${e.toString()}'));
    }
  }

  /// Validates the priority level
  ValidationFailure? _validatePriorityLevel(int level) {
    if (level < 1 || level > 5) {
      return const ValidationFailure('Priority level must be between 1 and 5');
    }
    return null;
  }
}
