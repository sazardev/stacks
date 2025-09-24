import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/order.dart' as domain;
import '../../../domain/repositories/order_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/order_status.dart';
import '../../dtos/order_dtos.dart';

/// Use case for updating order status with business logic validation
@injectable
class UpdateOrderStatusUseCase {
  final OrderRepository _orderRepository;

  UpdateOrderStatusUseCase(this._orderRepository);

  /// Execute the order status update use case
  Future<Either<Failure, domain.Order>> execute(
    UpdateOrderStatusDto dto,
  ) async {
    try {
      // Step 1: Get existing order
      final orderResult = await _orderRepository.getOrderById(dto.orderId);

      final order = orderResult.fold((failure) => null, (order) => order);

      if (order == null) {
        return Left(NotFoundFailure('Order not found: ${dto.orderId.value}'));
      }

      // Step 2: Validate status transition
      final newStatus = _parseOrderStatus(dto.status);
      if (newStatus == null) {
        return Left(ValidationFailure('Invalid order status: ${dto.status}'));
      }

      // Step 3: Update order status
      final result = await _orderRepository.updateOrderStatus(
        dto.orderId,
        newStatus,
      );

      return result.fold(
        (failure) => Left(failure),
        (updatedOrder) => Right(updatedOrder),
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to update order status: ${e.toString()}'),
      );
    }
  }

  /// Parse string status to OrderStatus value object
  OrderStatus? _parseOrderStatus(String statusString) {
    switch (statusString.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending();
      case 'confirmed':
        return OrderStatus.confirmed();
      case 'preparing':
        return OrderStatus.preparing();
      case 'ready':
        return OrderStatus.ready();
      case 'completed':
        return OrderStatus.completed();
      case 'cancelled':
        return OrderStatus.cancelled();
      default:
        return null;
    }
  }
}
