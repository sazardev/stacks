import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart' show Either, Right, Left;
import 'package:stacks/domain/entities/order.dart' as domain;
import 'package:stacks/domain/entities/order_item.dart';
import 'package:stacks/domain/entities/recipe.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';
import 'package:stacks/domain/value_objects/money.dart';
import 'package:stacks/domain/value_objects/priority.dart';
import 'package:stacks/domain/value_objects/order_status.dart';
import 'package:stacks/domain/failures/failures.dart';
import 'package:stacks/application/dtos/order_dtos.dart';
import 'package:stacks/application/use_cases/update_order_status_use_case.dart';

// Import mocks from create_order_use_case_test
import 'create_order_use_case_test.mocks.dart';

void main() {
  group('UpdateOrderStatusUseCase', () {
    late UpdateOrderStatusUseCase useCase;
    late MockOrderRepository mockOrderRepository;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      useCase = UpdateOrderStatusUseCase(orderRepository: mockOrderRepository);
    });

    group('execute', () {
      test('should update order status successfully', () async {
        // Arrange
        final orderId = UserId('order123');
        final createdAt = Time.now();

        final recipe = Recipe(
          id: UserId('recipe1'),
          name: 'Test Recipe',
          category: RecipeCategory.main,
          difficulty: RecipeDifficulty.easy,
          preparationTimeMinutes: 10,
          cookingTimeMinutes: 15,
          ingredients: [Ingredient(name: 'Test', quantity: '1')],
          instructions: ['Test'],
          price: Money(10.0),
          createdAt: createdAt,
        );

        final orderItem = OrderItem(
          id: UserId('item1'),
          recipe: recipe,
          quantity: 1,
          status: OrderItemStatus.pending,
          createdAt: createdAt,
        );

        final existingOrder = domain.Order(
          id: orderId,
          customerId: UserId('customer123'),
          items: [orderItem],
          priority: Priority.createMedium(),
          status: OrderStatus.pending(),
          createdAt: createdAt,
        );

        final updatedOrder = existingOrder.confirm();

        final updateDto = UpdateOrderStatusDto(
          orderId: orderId,
          status: 'confirmed',
        );

        when(
          mockOrderRepository.getOrderById(orderId),
        ).thenAnswer((_) async => Right(existingOrder));
        when(
          mockOrderRepository.updateOrder(any),
        ).thenAnswer((_) async => Right(updatedOrder));

        // Act
        final result = await useCase.execute(updateDto);

        // Assert
        expect(result.isRight(), isTrue);

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (order) {
            expect(order.status.isConfirmed, isTrue);
            expect(order.confirmedAt, isNotNull);
          },
        );

        verify(mockOrderRepository.getOrderById(orderId)).called(1);
        verify(mockOrderRepository.updateOrder(any)).called(1);
      });

      test('should return failure when order not found', () async {
        // Arrange
        final orderId = UserId('nonexistent');
        final updateDto = UpdateOrderStatusDto(
          orderId: orderId,
          status: 'confirmed',
        );

        when(mockOrderRepository.getOrderById(orderId)).thenAnswer(
          (_) async => const Left(NotFoundFailure('Order not found')),
        );

        // Act
        final result = await useCase.execute(updateDto);

        // Assert
        expect(result.isLeft(), isTrue);

        result.fold((failure) {
          expect(failure, isA<NotFoundFailure>());
          expect(failure.message, equals('Order not found'));
        }, (order) => fail('Expected failure but got success'));

        verify(mockOrderRepository.getOrderById(orderId)).called(1);
        verifyNever(mockOrderRepository.updateOrder(any));
      });

      test('should return validation failure for invalid status', () async {
        // Arrange
        final orderId = UserId('order123');
        final updateDto = UpdateOrderStatusDto(
          orderId: orderId,
          status: 'invalid_status',
        );

        // Act
        final result = await useCase.execute(updateDto);

        // Assert
        expect(result.isLeft(), isTrue);

        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Invalid status'));
        }, (order) => fail('Expected failure but got success'));

        verifyNever(mockOrderRepository.getOrderById(any));
        verifyNever(mockOrderRepository.updateOrder(any));
      });

      test(
        'should return business rule failure for invalid transition',
        () async {
          // Arrange
          final orderId = UserId('order123');
          final createdAt = Time.now();

          final recipe = Recipe(
            id: UserId('recipe1'),
            name: 'Test Recipe',
            category: RecipeCategory.main,
            difficulty: RecipeDifficulty.easy,
            preparationTimeMinutes: 10,
            cookingTimeMinutes: 15,
            ingredients: [Ingredient(name: 'Test', quantity: '1')],
            instructions: ['Test'],
            price: Money(10.0),
            createdAt: createdAt,
          );

          final orderItem = OrderItem(
            id: UserId('item1'),
            recipe: recipe,
            quantity: 1,
            status: OrderItemStatus.pending,
            createdAt: createdAt,
          );

          // Order is already completed
          final completedOrder = domain.Order(
            id: orderId,
            customerId: UserId('customer123'),
            items: [orderItem],
            priority: Priority.createMedium(),
            status: OrderStatus.completed(),
            createdAt: createdAt,
            completedAt: createdAt,
          );

          final updateDto = UpdateOrderStatusDto(
            orderId: orderId,
            status: 'pending', // Invalid transition
          );

          when(
            mockOrderRepository.getOrderById(orderId),
          ).thenAnswer((_) async => Right(completedOrder));

          // Act
          final result = await useCase.execute(updateDto);

          // Assert
          expect(result.isLeft(), isTrue);

          result.fold((failure) {
            expect(failure, isA<BusinessRuleFailure>());
            expect(failure.message, contains('Invalid status transition'));
          }, (order) => fail('Expected failure but got success'));

          verify(mockOrderRepository.getOrderById(orderId)).called(1);
          verifyNever(mockOrderRepository.updateOrder(any));
        },
      );

      test('should update status with cancellation reason', () async {
        // Arrange
        final orderId = UserId('order123');
        final createdAt = Time.now();

        final recipe = Recipe(
          id: UserId('recipe1'),
          name: 'Test Recipe',
          category: RecipeCategory.main,
          difficulty: RecipeDifficulty.easy,
          preparationTimeMinutes: 10,
          cookingTimeMinutes: 15,
          ingredients: [Ingredient(name: 'Test', quantity: '1')],
          instructions: ['Test'],
          price: Money(10.0),
          createdAt: createdAt,
        );

        final orderItem = OrderItem(
          id: UserId('item1'),
          recipe: recipe,
          quantity: 1,
          status: OrderItemStatus.pending,
          createdAt: createdAt,
        );

        final existingOrder = domain.Order(
          id: orderId,
          customerId: UserId('customer123'),
          items: [orderItem],
          priority: Priority.createMedium(),
          status: OrderStatus.pending(),
          createdAt: createdAt,
        );

        final cancelReason = 'Customer requested cancellation';
        final cancelledOrder = existingOrder.cancel(cancelReason);

        final updateDto = UpdateOrderStatusDto(
          orderId: orderId,
          status: 'cancelled',
          reason: cancelReason,
        );

        when(
          mockOrderRepository.getOrderById(orderId),
        ).thenAnswer((_) async => Right(existingOrder));
        when(
          mockOrderRepository.updateOrder(any),
        ).thenAnswer((_) async => Right(cancelledOrder));

        // Act
        final result = await useCase.execute(updateDto);

        // Assert
        expect(result.isRight(), isTrue);

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (order) {
            expect(order.status.isCancelled, isTrue);
            expect(order.cancellationReason, equals(cancelReason));
          },
        );

        verify(mockOrderRepository.getOrderById(orderId)).called(1);
        verify(mockOrderRepository.updateOrder(any)).called(1);
      });
    });
  });
}
