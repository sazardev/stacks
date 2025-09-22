import 'package:dartz/dartz.dart' show Either, Left;
import 'package:injectable/injectable.dart' hide Order;
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/failures/failures.dart';
import '../../domain/value_objects/user_id.dart';

/// Use case for completing an order
@injectable
class CompleteOrderUseCase {
  final OrderRepository _orderRepository;

  const CompleteOrderUseCase({required OrderRepository orderRepository})
    : _orderRepository = orderRepository;

  /// Executes the complete order use case
  Future<Either<Failure, Order>> execute(UserId orderId) async {
    try {
      // Get existing order
      final orderResult = await _orderRepository.getOrderById(orderId);
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

      // Complete the order (domain logic will validate status transition)
      final completedOrder = existingOrder.complete();

      // Save updated order
      return await _orderRepository.updateOrder(completedOrder);
    } catch (e) {
      // Check if it's a domain exception (invalid state transition)
      if (e.toString().contains('Cannot complete order')) {
        return Left(BusinessRuleFailure(e.toString()));
      }
      return Left(ServerFailure('Failed to complete order: ${e.toString()}'));
    }
  }
}
