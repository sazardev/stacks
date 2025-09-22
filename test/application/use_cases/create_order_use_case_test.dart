import 'package:dartz/dartz.dart' show Right, Left;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stacks/application/dtos/order_dtos.dart';
import 'package:stacks/application/use_cases/create_order_use_case.dart';
import 'package:stacks/domain/entities/order.dart' as domain;
import 'package:stacks/domain/entities/recipe.dart';
import 'package:stacks/domain/failures/failures.dart';
import 'package:stacks/domain/repositories/order_repository.dart';
import 'package:stacks/domain/repositories/recipe_repository.dart';
import 'package:stacks/domain/value_objects/money.dart';
import 'package:stacks/domain/value_objects/priority.dart';
import 'package:stacks/domain/value_objects/time.dart';
import 'package:stacks/domain/value_objects/user_id.dart';

@GenerateMocks([OrderRepository, RecipeRepository])
import 'create_order_use_case_test.mocks.dart';

void main() {
  group('CreateOrderUseCase', () {
    late CreateOrderUseCase useCase;
    late MockOrderRepository mockOrderRepository;
    late MockRecipeRepository mockRecipeRepository;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      mockRecipeRepository = MockRecipeRepository();
      useCase = CreateOrderUseCase(
        orderRepository: mockOrderRepository,
        recipeRepository: mockRecipeRepository,
      );
    });

    group('execute', () {
      test('should create order successfully with valid data', () async {
        // Arrange
        final customerId = UserId('customer123');
        final tableId = UserId('table5');
        final recipeId1 = UserId('recipe1');
        final recipeId2 = UserId('recipe2');
        final createdAt = Time.now();

        final recipe1 = Recipe(
          id: recipeId1,
          name: 'Classic Burger',
          category: RecipeCategory.main,
          difficulty: RecipeDifficulty.medium,
          preparationTimeMinutes: 10,
          cookingTimeMinutes: 15,
          ingredients: [Ingredient(name: 'Beef Patty', quantity: '1 piece')],
          instructions: ['Grill the patty'],
          price: Money(12.99),
          createdAt: createdAt,
        );

        final recipe2 = Recipe(
          id: recipeId2,
          name: 'French Fries',
          category: RecipeCategory.side,
          difficulty: RecipeDifficulty.easy,
          preparationTimeMinutes: 5,
          cookingTimeMinutes: 8,
          ingredients: [Ingredient(name: 'Potatoes', quantity: '200g')],
          instructions: ['Fry potatoes'],
          price: Money(4.99),
          createdAt: createdAt,
        );

        final createOrderDto = CreateOrderDto(
          customerId: customerId,
          tableId: tableId,
          items: [
            CreateOrderItemDto(
              recipeId: recipeId1,
              quantity: 2,
              specialInstructions: 'No onions',
            ),
            CreateOrderItemDto(recipeId: recipeId2, quantity: 1),
          ],
          priority: Priority.createMedium(),
          specialInstructions: 'Deliver to table 5',
        );

        // Mock repository responses
        when(
          mockRecipeRepository.getRecipeById(recipeId1),
        ).thenAnswer((_) async => Right(recipe1));
        when(
          mockRecipeRepository.getRecipeById(recipeId2),
        ).thenAnswer((_) async => Right(recipe2));
        when(mockOrderRepository.createOrder(any)).thenAnswer((
          invocation,
        ) async {
          final domain.Order order =
              invocation.positionalArguments[0] as domain.Order;
          return Right(order);
        });

        // Act
        final result = await useCase.execute(createOrderDto);

        // Assert
        expect(result.isRight(), isTrue);

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (order) {
            expect(order.customerId, equals(customerId));
            expect(order.tableId, equals(tableId));
            expect(order.items.length, equals(2));
            expect(order.priority.level, equals(2)); // Medium priority
            expect(order.specialInstructions, equals('Deliver to table 5'));
            expect(order.status.isPending, isTrue);

            // Check first item
            final firstItem = order.items.first;
            expect(firstItem.recipe, equals(recipe1));
            expect(firstItem.quantity, equals(2));
            expect(firstItem.specialInstructions, equals('No onions'));

            // Check second item
            final secondItem = order.items.last;
            expect(secondItem.recipe, equals(recipe2));
            expect(secondItem.quantity, equals(1));
            expect(secondItem.specialInstructions, isNull);

            // Check total amount
            expect(
              order.totalAmount.amount,
              equals(30.97),
            ); // (12.99 * 2) + 4.99
          },
        );

        // Verify interactions
        verify(mockRecipeRepository.getRecipeById(recipeId1)).called(1);
        verify(mockRecipeRepository.getRecipeById(recipeId2)).called(1);
        verify(mockOrderRepository.createOrder(any)).called(1);
      });

      test('should return failure when recipe not found', () async {
        // Arrange
        final customerId = UserId('customer123');
        final invalidRecipeId = UserId('invalid-recipe');

        final createOrderDto = CreateOrderDto(
          customerId: customerId,
          items: [CreateOrderItemDto(recipeId: invalidRecipeId, quantity: 1)],
          priority: Priority.createMedium(),
        );

        when(mockRecipeRepository.getRecipeById(invalidRecipeId)).thenAnswer(
          (_) async => const Left(NotFoundFailure('Recipe not found')),
        );

        // Act
        final result = await useCase.execute(createOrderDto);

        // Assert
        expect(result.isLeft(), isTrue);

        result.fold((failure) {
          expect(failure, isA<NotFoundFailure>());
          expect(failure.message, equals('Recipe not found'));
        }, (order) => fail('Expected failure but got success'));

        verify(mockRecipeRepository.getRecipeById(invalidRecipeId)).called(1);
        verifyNever(mockOrderRepository.createOrder(any));
      });

      test('should return failure when order creation fails', () async {
        // Arrange
        final customerId = UserId('customer123');
        final recipeId = UserId('recipe1');
        final createdAt = Time.now();

        final recipe = Recipe(
          id: recipeId,
          name: 'Test Recipe',
          category: RecipeCategory.main,
          difficulty: RecipeDifficulty.easy,
          preparationTimeMinutes: 5,
          cookingTimeMinutes: 10,
          ingredients: [Ingredient(name: 'Test', quantity: '1')],
          instructions: ['Test'],
          price: Money(10.0),
          createdAt: createdAt,
        );

        final createOrderDto = CreateOrderDto(
          customerId: customerId,
          items: [CreateOrderItemDto(recipeId: recipeId, quantity: 1)],
          priority: Priority.createMedium(),
        );

        when(
          mockRecipeRepository.getRecipeById(recipeId),
        ).thenAnswer((_) async => Right(recipe));
        when(
          mockOrderRepository.createOrder(any),
        ).thenAnswer((_) async => const Left(ServerFailure('Database error')));

        // Act
        final result = await useCase.execute(createOrderDto);

        // Assert
        expect(result.isLeft(), isTrue);

        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, equals('Database error'));
        }, (order) => fail('Expected failure but got success'));

        verify(mockRecipeRepository.getRecipeById(recipeId)).called(1);
        verify(mockOrderRepository.createOrder(any)).called(1);
      });

      test('should return validation failure for empty items', () async {
        // Arrange
        final customerId = UserId('customer123');

        final createOrderDto = CreateOrderDto(
          customerId: customerId,
          items: [], // Empty items
          priority: Priority.createMedium(),
        );

        // Act
        final result = await useCase.execute(createOrderDto);

        // Assert
        expect(result.isLeft(), isTrue);

        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            contains('Order must have at least one item'),
          );
        }, (order) => fail('Expected failure but got success'));

        verifyNever(mockRecipeRepository.getRecipeById(any));
        verifyNever(mockOrderRepository.createOrder(any));
      });

      test('should return validation failure for invalid quantity', () async {
        // Arrange
        final customerId = UserId('customer123');
        final recipeId = UserId('recipe1');

        final createOrderDto = CreateOrderDto(
          customerId: customerId,
          items: [
            CreateOrderItemDto(
              recipeId: recipeId,
              quantity: 0, // Invalid quantity
            ),
          ],
          priority: Priority.createMedium(),
        );

        // Act
        final result = await useCase.execute(createOrderDto);

        // Assert
        expect(result.isLeft(), isTrue);

        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Invalid quantity'));
        }, (order) => fail('Expected failure but got success'));

        verifyNever(mockRecipeRepository.getRecipeById(any));
        verifyNever(mockOrderRepository.createOrder(any));
      });
    });
  });
}
