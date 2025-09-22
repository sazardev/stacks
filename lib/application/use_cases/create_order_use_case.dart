import 'package:dartz/dartz.dart' show Either, Left;
import 'package:injectable/injectable.dart' hide Order;
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';
import '../../domain/value_objects/order_status.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/failures/failures.dart';
import '../dtos/order_dtos.dart';

/// Use case for creating a new order
@injectable
class CreateOrderUseCase {
  final OrderRepository _orderRepository;
  final RecipeRepository _recipeRepository;

  const CreateOrderUseCase({
    required OrderRepository orderRepository,
    required RecipeRepository recipeRepository,
  }) : _orderRepository = orderRepository,
       _recipeRepository = recipeRepository;

  /// Executes the create order use case
  Future<Either<Failure, Order>> execute(CreateOrderDto dto) async {
    try {
      // Validate input
      final validationResult = _validateInput(dto);
      if (validationResult != null) {
        return Left(validationResult);
      }

      // Fetch all recipes first
      final recipes = <UserId, dynamic>{};
      for (final itemDto in dto.items) {
        final recipeResult = await _recipeRepository.getRecipeById(
          itemDto.recipeId,
        );
        if (recipeResult.isLeft()) {
          return recipeResult.fold(
            (failure) => Left(failure),
            (_) => throw StateError('This should not happen'),
          );
        }

        recipeResult.fold(
          (_) => throw StateError('This should not happen'),
          (recipe) => recipes[itemDto.recipeId] = recipe,
        );
      }

      // Create order items
      final orderItems = <OrderItem>[];
      for (final itemDto in dto.items) {
        final recipe = recipes[itemDto.recipeId];

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

      // Create the order
      final order = Order(
        id: UserId.generate(),
        customerId: dto.customerId,
        tableId: dto.tableId,
        items: orderItems,
        priority: dto.priority,
        status: OrderStatus.pending(),
        specialInstructions: dto.specialInstructions,
        createdAt: Time.now(),
      );

      // Save the order
      return await _orderRepository.createOrder(order);
    } catch (e) {
      return Left(ServerFailure('Failed to create order: ${e.toString()}'));
    }
  }

  /// Validates the input DTO
  ValidationFailure? _validateInput(CreateOrderDto dto) {
    if (dto.items.isEmpty) {
      return const ValidationFailure('Order must have at least one item');
    }

    for (final item in dto.items) {
      if (item.quantity <= 0) {
        return const ValidationFailure(
          'Invalid quantity: must be greater than 0',
        );
      }

      if (item.quantity > 50) {
        return const ValidationFailure(
          'Invalid quantity: maximum 50 items per order item',
        );
      }
    }

    if (dto.specialInstructions != null &&
        dto.specialInstructions!.length > 1000) {
      return const ValidationFailure(
        'Special instructions too long: maximum 1000 characters',
      );
    }

    return null;
  }
}
