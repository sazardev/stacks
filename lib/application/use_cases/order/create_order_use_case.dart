import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/order.dart' as domain;
import '../../../domain/entities/order_item.dart';
import '../../../domain/repositories/order_repository.dart';
import '../../../domain/repositories/recipe_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/time.dart';
import '../../../domain/services/workflow_validation_service.dart';
import '../../dtos/order_dtos.dart';

/// Use case for creating a new order with comprehensive business logic validation
@injectable
class CreateOrderUseCase {
  final OrderRepository _orderRepository;
  final RecipeRepository _recipeRepository;
  final WorkflowValidationService _workflowValidator;

  CreateOrderUseCase(
    this._orderRepository,
    this._recipeRepository,
    this._workflowValidator,
  );

  /// Execute the order creation use case
  Future<Either<Failure, domain.Order>> execute(CreateOrderDto dto) async {
    try {
      // Step 1: Validate and process order items
      final itemsValidation = await _validateAndProcessItems(dto.items);
      if (itemsValidation.isLeft()) {
        return itemsValidation.fold(
          (failure) => Left(failure),
          (_) => Left(ValidationFailure('Items validation failed')),
        );
      }

      final validatedItems = itemsValidation.fold(
        (_) => <OrderItem>[],
        (items) => items,
      );

      // Step 2: Create order entity
      final order = domain.Order(
        id: UserId.generate(),
        customerId: dto.customerId,
        tableId: dto.tableId,
        items: validatedItems,
        priority: dto.priority,
        createdAt: Time.now(),
        specialInstructions: dto.specialInstructions,
      );

      // Step 3: Kitchen capacity validation - Check if kitchen can handle new order
      final capacityCheck = _workflowValidator.validateKitchenCapacity(
        currentOrders: [], // TODO: Get actual current orders from repository
        availableStaff: [], // TODO: Get available staff from user repository
        maxConcurrentOrders: 10, // TODO: Make this configurable
      );

      if (!capacityCheck) {
        return Left(
          ValidationFailure(
            'Kitchen capacity exceeded - cannot accept new orders at this time',
          ),
        );
      }

      // Step 4: Business rule validation for order complexity
      final totalComplexity = validatedItems.fold<double>(
        0.0,
        (sum, item) => sum + item.recipe.totalTimeMinutes * item.quantity,
      );

      if (totalComplexity > 120) {
        // Max 2 hours of preparation time
        return Left(
          ValidationFailure(
            'Order too complex - total preparation time exceeds kitchen capacity',
          ),
        );
      }

      // Step 6: Persist the order
      final result = await _orderRepository.createOrder(order);

      return result.fold(
        (failure) => Left(failure),
        (createdOrder) => Right(createdOrder),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to create order: ${e.toString()}'));
    }
  }

  /// Validate order items and check recipe availability
  Future<Either<Failure, List<OrderItem>>> _validateAndProcessItems(
    List<CreateOrderItemDto> itemDtos,
  ) async {
    try {
      if (itemDtos.isEmpty) {
        return Left(ValidationFailure('Order must contain at least one item'));
      }

      final validatedItems = <OrderItem>[];

      for (final itemDto in itemDtos) {
        // Validate recipe exists
        final recipeResult = await _recipeRepository.getRecipeById(
          itemDto.recipeId,
        );

        final recipe = recipeResult.fold((failure) => null, (recipe) => recipe);

        if (recipe == null) {
          return Left(
            ValidationFailure('Recipe not found: ${itemDto.recipeId.value}'),
          );
        }

        // Validate quantity
        if (itemDto.quantity <= 0) {
          return Left(
            ValidationFailure('Item quantity must be greater than 0'),
          );
        }

        // Create order item
        final orderItem = OrderItem(
          id: UserId.generate(),
          recipe: recipe,
          quantity: itemDto.quantity,
          specialInstructions: itemDto.specialInstructions,
          createdAt: Time.now(),
        );

        validatedItems.add(orderItem);
      }

      return Right(validatedItems);
    } catch (e) {
      return Left(
        ValidationFailure('Items validation failed: ${e.toString()}'),
      );
    }
  }
}
