import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/order.dart' as domain;
import '../../../domain/entities/order_item.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/order_repository.dart';
import '../../../domain/repositories/recipe_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/time.dart';
import '../../../domain/services/workflow_validation_service.dart';
import '../../dtos/order_dtos.dart';
import '../../config/kitchen_config.dart';

/// Use case for creating a new order with comprehensive business logic validation
@injectable
class CreateOrderUseCase {
  final OrderRepository _orderRepository;
  final RecipeRepository _recipeRepository;
  final UserRepository _userRepository;
  final WorkflowValidationService _workflowValidator;
  final KitchenConfig _kitchenConfig;

  CreateOrderUseCase(
    this._orderRepository,
    this._recipeRepository,
    this._userRepository,
    this._workflowValidator,
    this._kitchenConfig,
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
      final currentOrdersResult = await _orderRepository.getActiveOrders();
      final currentOrders = currentOrdersResult.fold(
        (failure) => <domain.Order>[],
        (orders) => orders,
      );

      final availableStaffResult = await _userRepository.getActiveUsers();
      final availableStaff = availableStaffResult.fold(
        (failure) => <User>[],
        (users) => users.where((user) => _isKitchenStaff(user.role)).toList(),
      );

      final maxConcurrentOrders = _kitchenConfig.maxConcurrentOrdersLimit;

      // Check if kitchen is at critical capacity before validation
      if (_kitchenConfig.isAtCriticalCapacity(currentOrders.length)) {
        return Left(
          ValidationFailure(
            'Kitchen at critical capacity (${currentOrders.length}/$maxConcurrentOrders). ${_kitchenConfig.getCapacityRecommendation(currentOrders.length, availableStaff.length)}',
          ),
        );
      }

      final capacityCheck = _workflowValidator.validateKitchenCapacity(
        currentOrders: currentOrders,
        availableStaff: availableStaff,
        maxConcurrentOrders: maxConcurrentOrders,
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

      if (totalComplexity > _kitchenConfig.maxPreparationTime) {
        return Left(
          ValidationFailure(
            'Order too complex - total preparation time ${totalComplexity.toInt()} minutes exceeds limit of ${_kitchenConfig.maxPreparationTime} minutes',
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

  /// Helper method to determine if a user can work in the kitchen
  bool _isKitchenStaff(UserRole role) {
    switch (role) {
      case UserRole.dishwasher:
      case UserRole.prepCook:
      case UserRole.lineCook:
      case UserRole.cook:
      case UserRole.cookSenior:
      case UserRole.chefAssistant:
      case UserRole.sousChef:
      case UserRole.chefHead:
      case UserRole.expediter:
        return true;
      case UserRole.kitchenManager:
      case UserRole.generalManager:
      case UserRole.admin:
        return false; // Management roles, not directly cooking
    }
  }
}
