import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/entities/order_item.dart';
import 'package:stacks/domain/entities/recipe.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';
import 'package:stacks/domain/value_objects/money.dart';
import 'package:stacks/domain/value_objects/order_status.dart';
import 'package:stacks/domain/exceptions/domain_exception.dart';

void main() {
  group('OrderItem', () {
    late UserId orderItemId;
    late UserId recipeId;
    late Recipe recipe;
    late Time createdAt;

    setUp(() {
      orderItemId = UserId.generate();
      recipeId = UserId.generate();
      createdAt = Time.now();

      recipe = Recipe(
        id: recipeId,
        name: 'Classic Burger',
        category: RecipeCategory.main,
        difficulty: RecipeDifficulty.medium,
        preparationTimeMinutes: 10,
        cookingTimeMinutes: 15,
        ingredients: [
          Ingredient(name: 'Beef Patty', quantity: '1 piece'),
          Ingredient(name: 'Lettuce', quantity: '2 leaves'),
        ],
        instructions: ['Grill the patty', 'Assemble burger'],
        price: Money(12.99),
        createdAt: createdAt,
      );
    });

    group('creation', () {
      test('should create OrderItem with valid data', () {
        final orderItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 2,
          specialInstructions: 'No onions, extra cheese',
          status: OrderItemStatus.pending,
          createdAt: createdAt,
        );

        expect(orderItem.id, equals(orderItemId));
        expect(orderItem.recipe, equals(recipe));
        expect(orderItem.quantity, equals(2));
        expect(
          orderItem.specialInstructions,
          equals('No onions, extra cheese'),
        );
        expect(orderItem.status, equals(OrderItemStatus.pending));
        expect(orderItem.totalPrice.amount, equals(25.98)); // 12.99 * 2
        expect(orderItem.estimatedTimeMinutes, equals(25)); // prep + cooking
        expect(orderItem.createdAt, equals(createdAt));
        expect(orderItem.isModified, isFalse);
        expect(orderItem.isCompleted, isFalse);
        expect(orderItem.isCancelled, isFalse);
      });

      test('should create OrderItem with minimum required fields', () {
        final orderItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          createdAt: createdAt,
        );

        expect(orderItem.specialInstructions, isNull);
        expect(orderItem.status, equals(OrderItemStatus.pending));
        expect(orderItem.totalPrice.amount, equals(12.99));
        expect(orderItem.isModified, isFalse);
      });

      test('should throw DomainException for zero quantity', () {
        expect(
          () => OrderItem(
            id: orderItemId,
            recipe: recipe,
            quantity: 0,
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw DomainException for negative quantity', () {
        expect(
          () => OrderItem(
            id: orderItemId,
            recipe: recipe,
            quantity: -1,
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw DomainException for quantity exceeding maximum', () {
        expect(
          () => OrderItem(
            id: orderItemId,
            recipe: recipe,
            quantity: 100, // Exceeds max allowed quantity
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });

      test(
        'should throw DomainException for special instructions too long',
        () {
          final longInstructions = 'A' * 501; // Exceeds max length
          expect(
            () => OrderItem(
              id: orderItemId,
              recipe: recipe,
              quantity: 1,
              specialInstructions: longInstructions,
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        },
      );
    });

    group('status management', () {
      test('should start preparation', () {
        final orderItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          createdAt: createdAt,
        );

        final preparingItem = orderItem.startPreparation();

        expect(preparingItem.status, equals(OrderItemStatus.preparing));
        expect(preparingItem.startedAt, isNotNull);
      });

      test('should complete preparation', () {
        final orderItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          status: OrderItemStatus.preparing,
          createdAt: createdAt,
        );

        final completedItem = orderItem.completePreparation();

        expect(completedItem.status, equals(OrderItemStatus.ready));
        expect(completedItem.completedAt, isNotNull);
      });

      test('should deliver order item', () {
        final orderItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          status: OrderItemStatus.ready,
          createdAt: createdAt,
        );

        final deliveredItem = orderItem.deliver();

        expect(deliveredItem.status, equals(OrderItemStatus.delivered));
        expect(deliveredItem.deliveredAt, isNotNull);
        expect(deliveredItem.isCompleted, isTrue);
      });

      test('should cancel order item', () {
        final orderItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          createdAt: createdAt,
        );

        final cancelledItem = orderItem.cancel('Customer request');

        expect(cancelledItem.status, equals(OrderItemStatus.cancelled));
        expect(cancelledItem.cancellationReason, equals('Customer request'));
        expect(cancelledItem.isCancelled, isTrue);
      });

      test(
        'should throw exception when starting preparation if not pending',
        () {
          final orderItem = OrderItem(
            id: orderItemId,
            recipe: recipe,
            quantity: 1,
            status: OrderItemStatus.preparing,
            createdAt: createdAt,
          );

          expect(
            () => orderItem.startPreparation(),
            throwsA(isA<DomainException>()),
          );
        },
      );

      test('should throw exception when completing if not preparing', () {
        final orderItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          status: OrderItemStatus.pending,
          createdAt: createdAt,
        );

        expect(
          () => orderItem.completePreparation(),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw exception when delivering if not ready', () {
        final orderItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          status: OrderItemStatus.pending,
          createdAt: createdAt,
        );

        expect(() => orderItem.deliver(), throwsA(isA<DomainException>()));
      });
    });

    group('modifications', () {
      test('should update quantity', () {
        final orderItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          createdAt: createdAt,
        );

        final updatedItem = orderItem.updateQuantity(3);

        expect(updatedItem.quantity, equals(3));
        expect(updatedItem.totalPrice.amount, equals(38.97)); // 12.99 * 3
        expect(updatedItem.isModified, isTrue);
      });

      test('should update special instructions', () {
        final orderItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          createdAt: createdAt,
        );

        final updatedItem = orderItem.updateSpecialInstructions('Extra spicy');

        expect(updatedItem.specialInstructions, equals('Extra spicy'));
        expect(updatedItem.isModified, isTrue);
      });

      test('should remove special instructions', () {
        final orderItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          specialInstructions: 'No cheese',
          createdAt: createdAt,
        );

        final updatedItem = orderItem.updateSpecialInstructions(null);

        expect(updatedItem.specialInstructions, isNull);
        expect(updatedItem.isModified, isTrue);
      });

      test(
        'should throw exception when modifying after preparation started',
        () {
          final orderItem = OrderItem(
            id: orderItemId,
            recipe: recipe,
            quantity: 1,
            status: OrderItemStatus.preparing,
            createdAt: createdAt,
          );

          expect(
            () => orderItem.updateQuantity(2),
            throwsA(isA<DomainException>()),
          );

          expect(
            () => orderItem.updateSpecialInstructions('Extra cheese'),
            throwsA(isA<DomainException>()),
          );
        },
      );
    });

    group('business rules', () {
      test('should calculate total price correctly', () {
        final orderItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 3,
          createdAt: createdAt,
        );

        expect(orderItem.totalPrice.amount, equals(38.97)); // 12.99 * 3
      });

      test('should calculate estimated time correctly', () {
        final orderItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 2,
          createdAt: createdAt,
        );

        expect(
          orderItem.estimatedTimeMinutes,
          equals(25),
        ); // prep + cooking time
      });

      test('should determine if item can be modified', () {
        final pendingItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          status: OrderItemStatus.pending,
          createdAt: createdAt,
        );

        final preparingItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          status: OrderItemStatus.preparing,
          createdAt: createdAt,
        );

        expect(pendingItem.canBeModified, isTrue);
        expect(preparingItem.canBeModified, isFalse);
      });

      test('should determine if item can be cancelled', () {
        final pendingItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          status: OrderItemStatus.pending,
          createdAt: createdAt,
        );

        final deliveredItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          status: OrderItemStatus.delivered,
          createdAt: createdAt,
        );

        expect(pendingItem.canBeCancelled, isTrue);
        expect(deliveredItem.canBeCancelled, isFalse);
      });

      test('should check if item requires special handling', () {
        final regularItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          createdAt: createdAt,
        );

        final specialItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          specialInstructions: 'No cheese, extra sauce',
          createdAt: createdAt,
        );

        expect(regularItem.requiresSpecialHandling, isFalse);
        expect(specialItem.requiresSpecialHandling, isTrue);
      });

      test('should get preparation time based on recipe', () {
        final orderItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          createdAt: createdAt,
        );

        expect(orderItem.preparationTimeMinutes, equals(10));
        expect(orderItem.cookingTimeMinutes, equals(15));
      });
    });

    group('time tracking', () {
      test('should calculate preparation duration', () {
        final startTime = Time.now();
        final orderItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          status: OrderItemStatus.preparing,
          startedAt: startTime,
          createdAt: createdAt,
        );

        final endTime = startTime.add(const Duration(minutes: 12));
        final completedItem = orderItem.copyWith(
          status: OrderItemStatus.ready,
          completedAt: endTime,
        );

        expect(completedItem.actualPreparationDuration?.inMinutes, equals(12));
      });

      test('should check if item is overdue', () {
        final oldTime = Time.now().subtract(const Duration(minutes: 30));
        final orderItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          status: OrderItemStatus.preparing,
          startedAt: oldTime,
          createdAt: oldTime,
        );

        expect(orderItem.isOverdue, isTrue);
      });

      test('should not be overdue if within expected time', () {
        final recentTime = Time.now().subtract(const Duration(minutes: 10));
        final orderItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          status: OrderItemStatus.preparing,
          startedAt: recentTime,
          createdAt: recentTime,
        );

        expect(orderItem.isOverdue, isFalse);
      });
    });

    group('equality', () {
      test('should be equal when ids are the same', () {
        final orderItem1 = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          createdAt: createdAt,
        );

        final orderItem2 = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 2,
          specialInstructions: 'Different',
          createdAt: Time.now(),
        );

        expect(orderItem1, equals(orderItem2));
        expect(orderItem1.hashCode, equals(orderItem2.hashCode));
      });

      test('should not be equal when ids are different', () {
        final orderItem1 = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 1,
          createdAt: createdAt,
        );

        final differentId = UserId('different-order-item-id');
        final orderItem2 = OrderItem(
          id: differentId,
          recipe: recipe,
          quantity: 1,
          createdAt: createdAt,
        );

        expect(orderItem1, isNot(equals(orderItem2)));
      });
    });

    group('string representation', () {
      test('should return string representation', () {
        final orderItem = OrderItem(
          id: orderItemId,
          recipe: recipe,
          quantity: 2,
          specialInstructions: 'No onions',
          createdAt: createdAt,
        );

        final string = orderItem.toString();
        expect(string, contains('OrderItem'));
        expect(string, contains('Classic Burger'));
        expect(string, contains('2'));
        expect(string, contains('pending'));
      });
    });
  });
}
