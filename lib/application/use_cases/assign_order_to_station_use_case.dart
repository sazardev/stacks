import 'package:dartz/dartz.dart' show Either, Left;
import 'package:injectable/injectable.dart' hide Order;
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/station_repository.dart';
import '../../domain/failures/failures.dart';
import '../dtos/station_dtos.dart';

/// Use case for assigning an order to a station
@injectable
class AssignOrderToStationUseCase {
  final OrderRepository _orderRepository;
  final StationRepository _stationRepository;

  const AssignOrderToStationUseCase({
    required OrderRepository orderRepository,
    required StationRepository stationRepository,
  }) : _orderRepository = orderRepository,
       _stationRepository = stationRepository;

  /// Executes the assign order to station use case
  Future<Either<Failure, Order>> execute(AssignOrderToStationDto dto) async {
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

      // Get the station
      final stationResult = await _stationRepository.getStationById(
        dto.stationId,
      );
      if (stationResult.isLeft()) {
        return stationResult.fold(
          (failure) => Left(failure),
          (_) => throw StateError('This should not happen'),
        );
      }

      final station = stationResult.fold(
        (_) => throw StateError('This should not happen'),
        (station) => station,
      );

      // Validate assignment
      final validationResult = _validateAssignment(order, station);
      if (validationResult != null) {
        return Left(validationResult);
      }

      // Assign order to station
      final assignedOrder = order.assignToStation(dto.stationId);

      // Update both order and station
      final updateOrderResult = await _orderRepository.updateOrder(
        assignedOrder,
      );
      if (updateOrderResult.isLeft()) {
        return updateOrderResult;
      }

      // Add order to station's workload
      await _stationRepository.addOrderToStation(
        dto.stationId,
        dto.orderId.value,
      );

      return updateOrderResult;
    } catch (e) {
      return Left(
        ServerFailure('Failed to assign order to station: ${e.toString()}'),
      );
    }
  }

  /// Validates if the order can be assigned to the station
  BusinessRuleFailure? _validateAssignment(Order order, station) {
    // Check if order is in a valid state for assignment
    if (order.status.isCompleted || order.status.isCancelled) {
      return BusinessRuleFailure(
        'Cannot assign ${order.status.value} order to station',
      );
    }

    // Check if station is available
    if (!station.isActive || station.status == 'offline') {
      return const BusinessRuleFailure(
        'Station is not available for assignment',
      );
    }

    // Check station capacity
    if (station.isAtCapacity) {
      return const BusinessRuleFailure('Station is at full capacity');
    }

    return null;
  }
}
