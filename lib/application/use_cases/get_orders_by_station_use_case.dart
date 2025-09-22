import 'package:dartz/dartz.dart' show Either, Left;
import 'package:injectable/injectable.dart' hide Order;
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/failures/failures.dart';
import '../dtos/order_dtos.dart';

/// Use case for getting orders by station
@injectable
class GetOrdersByStationUseCase {
  final OrderRepository _orderRepository;

  const GetOrdersByStationUseCase({required OrderRepository orderRepository})
    : _orderRepository = orderRepository;

  /// Executes the get orders by station use case
  Future<Either<Failure, List<Order>>> execute(OrderQueryDto dto) async {
    try {
      if (dto.stationId == null) {
        return const Left(ValidationFailure('Station ID is required'));
      }

      return await _orderRepository.getOrdersByStation(dto.stationId!);
    } catch (e) {
      return Left(
        ServerFailure('Failed to get orders by station: ${e.toString()}'),
      );
    }
  }
}
