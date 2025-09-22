import 'package:dartz/dartz.dart' show Either, Left;
import 'package:injectable/injectable.dart' hide Order;
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/failures/failures.dart';
import '../dtos/order_dtos.dart';

/// Use case for updating order status
@injectable
class UpdateOrderStatusUseCase {
  final OrderRepository _orderRepository;

  const UpdateOrderStatusUseCase({required OrderRepository orderRepository})
    : _orderRepository = orderRepository;

  /// Executes the update order status use case
  Future<Either<Failure, Order>> execute(UpdateOrderStatusDto dto) async {
    try {
      // Validate status
      final validationResult = _validateStatus(dto.status);
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

      // Apply status change
      final updatedOrder = _applyStatusChange(existingOrder, dto);

      if (updatedOrder == null) {
        return Left(
          BusinessRuleFailure(
            'Invalid status transition from ${existingOrder.status.value} to ${dto.status}',
          ),
        );
      }

      // Save updated order
      return await _orderRepository.updateOrder(updatedOrder);
    } catch (e) {
      return Left(
        ServerFailure('Failed to update order status: ${e.toString()}'),
      );
    }
  }

  /// Validates the status value
  ValidationFailure? _validateStatus(String status) {
    const validStatuses = [
      'pending',
      'confirmed',
      'preparing',
      'ready',
      'completed',
      'cancelled',
    ];

    if (!validStatuses.contains(status)) {
      return ValidationFailure(
        'Invalid status: $status. Valid statuses are: ${validStatuses.join(', ')}',
      );
    }

    return null;
  }

  /// Applies the status change to the order
  Order? _applyStatusChange(Order order, UpdateOrderStatusDto dto) {
    try {
      switch (dto.status) {
        case 'pending':
          // Usually can't go back to pending, but this would need a special method
          // For now, return null to indicate invalid transition
          return null;

        case 'confirmed':
          return order.confirm();

        case 'preparing':
          return order.startPreparation();

        case 'ready':
          return order.markReady();

        case 'completed':
          return order.complete();

        case 'cancelled':
          final reason = dto.reason ?? 'Order cancelled';
          return order.cancel(reason);

        default:
          return null;
      }
    } catch (e) {
      // If any domain rule is violated, return null
      return null;
    }
  }
}
