import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/entities/order.dart';
import 'package:stacks/domain/entities/order_item.dart';
import 'package:stacks/domain/entities/recipe.dart';
import 'package:stacks/domain/entities/station.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';
import 'package:stacks/domain/value_objects/money.dart';
import 'package:stacks/domain/value_objects/priority.dart';
import 'package:stacks/domain/value_objects/order_status.dart';
import 'package:stacks/domain/exceptions/domain_exception.dart';

void main() {
  group('Order', () {
    late UserId orderId;
    late UserId customerId;
    late UserId tableId;
    late Time createdAt;
    late Recipe recipe1;
    late Recipe recipe2;
    late OrderItem orderItem1;
    late OrderItem orderItem2;

    setUp(() {
      orderId = UserId.generate();
      customerId = UserId('customer123');
      tableId = UserId('table5');
      createdAt = Time.now();

      recipe1 = Recipe(
        id: UserId.generate(),
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

      recipe2 = Recipe(
        id: UserId.generate(),
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

      orderItem1 = OrderItem(
        id: UserId('order-item-1'),
        recipe: recipe1,
        quantity: 2,
        createdAt: createdAt,
      );

      orderItem2 = OrderItem(
        id: UserId('order-item-2'),
        recipe: recipe2,
        quantity: 1,
        createdAt: createdAt,
      );
    });

    group('creation', () {
      test('should create Order with valid data', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          tableId: tableId,
          items: [orderItem1, orderItem2],
          priority: Priority.createMedium(),
          status: OrderStatus.pending(),
          specialInstructions: 'Extra napkins',
          createdAt: createdAt,
        );

        expect(order.id, equals(orderId));
        expect(order.customerId, equals(customerId));
        expect(order.tableId, equals(tableId));
        expect(order.items, hasLength(2));
        expect(order.priority.level, equals(2));
        expect(order.status.isPending, isTrue);
        expect(order.specialInstructions, equals('Extra napkins'));
        expect(order.totalAmount.amount, equals(30.97)); // (12.99 * 2) + 4.99
        expect(order.estimatedTimeMinutes, equals(25)); // Max of item times
        expect(order.itemCount, equals(3)); // 2 + 1
        expect(order.createdAt, equals(createdAt));
        expect(order.isActive, isTrue);
        expect(order.isCompleted, isFalse);
      });

      test('should create Order with minimum required fields', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          createdAt: createdAt,
        );

        expect(order.tableId, isNull);
        expect(order.specialInstructions, isNull);
        expect(order.priority.level, equals(Priority.medium)); // Default
        expect(order.status.isPending, isTrue); // Default
        expect(order.totalAmount.amount, equals(25.98)); // 12.99 * 2
      });

      test('should throw DomainException for empty items', () {
        expect(
          () => Order(
            id: orderId,
            customerId: customerId,
            items: [],
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw DomainException for too many items', () {
        final manyItems = List.generate(101, (i) => orderItem1); // Exceeds max
        expect(
          () => Order(
            id: orderId,
            customerId: customerId,
            items: manyItems,
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });

      test(
        'should throw DomainException for special instructions too long',
        () {
          final longInstructions = 'A' * 1001; // Exceeds max length
          expect(
            () => Order(
              id: orderId,
              customerId: customerId,
              items: [orderItem1],
              specialInstructions: longInstructions,
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        },
      );
    });

    group('status management', () {
      test('should confirm pending order', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          createdAt: createdAt,
        );

        final confirmedOrder = order.confirm();

        expect(confirmedOrder.status.isConfirmed, isTrue);
        expect(confirmedOrder.confirmedAt, isNotNull);
      });

      test('should start preparation', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          status: OrderStatus.confirmed(),
          createdAt: createdAt,
        );

        final preparingOrder = order.startPreparation();

        expect(preparingOrder.status.isPreparing, isTrue);
        expect(preparingOrder.startedAt, isNotNull);
      });

      test('should mark as ready', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          status: OrderStatus.preparing(),
          createdAt: createdAt,
        );

        final readyOrder = order.markReady();

        expect(readyOrder.status.isReady, isTrue);
        expect(readyOrder.readyAt, isNotNull);
      });

      test('should complete order', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          status: OrderStatus.ready(),
          createdAt: createdAt,
        );

        final completedOrder = order.complete();

        expect(completedOrder.status.isCompleted, isTrue);
        expect(completedOrder.completedAt, isNotNull);
        expect(completedOrder.isCompleted, isTrue);
      });

      test('should cancel order', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          createdAt: createdAt,
        );

        final cancelledOrder = order.cancel('Customer request');

        expect(cancelledOrder.status.isCancelled, isTrue);
        expect(cancelledOrder.cancellationReason, equals('Customer request'));
        expect(cancelledOrder.isActive, isFalse);
      });

      test('should throw exception for invalid status transition', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          status: OrderStatus.completed(),
          createdAt: createdAt,
        );

        expect(() => order.confirm(), throwsA(isA<DomainException>()));
      });
    });

    group('item management', () {
      test('should add item to order', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          createdAt: createdAt,
        );

        final updatedOrder = order.addItem(orderItem2);

        expect(updatedOrder.items, hasLength(2));
        expect(updatedOrder.totalAmount.amount, equals(30.97));
        expect(updatedOrder.itemCount, equals(3));
      });

      test('should remove item from order', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1, orderItem2],
          createdAt: createdAt,
        );

        final updatedOrder = order.removeItem(orderItem2.id);

        expect(updatedOrder.items, hasLength(1));
        expect(updatedOrder.totalAmount.amount, equals(25.98));
        expect(updatedOrder.items.first.id, equals(orderItem1.id));
      });

      test('should throw exception when removing last item', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          createdAt: createdAt,
        );

        expect(
          () => order.removeItem(orderItem1.id),
          throwsA(isA<DomainException>()),
        );
      });

      test('should update item in order', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          createdAt: createdAt,
        );

        final updatedItem = orderItem1.updateQuantity(3);
        final updatedOrder = order.updateItem(updatedItem);

        expect(updatedOrder.items.first.quantity, equals(3));
        expect(updatedOrder.totalAmount.amount, equals(38.97)); // 12.99 * 3
      });

      test('should throw exception when removing non-existent item', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          createdAt: createdAt,
        );

        expect(
          () => order.removeItem(UserId('non-existent')),
          throwsA(isA<DomainException>()),
        );
      });

      test(
        'should throw exception when adding item after preparation started',
        () {
          final order = Order(
            id: orderId,
            customerId: customerId,
            items: [orderItem1],
            status: OrderStatus.preparing(),
            createdAt: createdAt,
          );

          expect(
            () => order.addItem(orderItem2),
            throwsA(isA<DomainException>()),
          );
        },
      );
    });

    group('priority management', () {
      test('should escalate order priority', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          priority: Priority.createMedium(),
          createdAt: createdAt,
        );

        final escalatedOrder = order.escalatePriority();

        expect(escalatedOrder.priority.level, equals(3)); // High priority
      });

      test('should not escalate if already at maximum priority', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          priority: Priority.createCritical(),
          createdAt: createdAt,
        );

        final escalatedOrder = order.escalatePriority();

        expect(escalatedOrder.priority.level, equals(5)); // Still critical
      });

      test('should update priority directly', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          createdAt: createdAt,
        );

        final updatedOrder = order.updatePriority(Priority.createUrgent());

        expect(updatedOrder.priority.level, equals(4)); // Urgent
      });
    });

    group('business rules', () {
      test('should calculate total amount correctly', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1, orderItem2],
          createdAt: createdAt,
        );

        expect(order.totalAmount.amount, equals(30.97)); // (12.99 * 2) + 4.99
      });

      test('should calculate estimated time correctly', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1, orderItem2],
          createdAt: createdAt,
        );

        // Should be max of item times: max(25, 13) = 25
        expect(order.estimatedTimeMinutes, equals(25));
      });

      test('should count total items correctly', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1, orderItem2],
          createdAt: createdAt,
        );

        expect(order.itemCount, equals(3)); // 2 + 1
      });

      test('should determine if order can be modified', () {
        final pendingOrder = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          status: OrderStatus.pending(),
          createdAt: createdAt,
        );

        final preparingOrder = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          status: OrderStatus.preparing(),
          createdAt: createdAt,
        );

        expect(pendingOrder.canBeModified, isTrue);
        expect(preparingOrder.canBeModified, isFalse);
      });

      test('should determine if order can be cancelled', () {
        final pendingOrder = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          status: OrderStatus.pending(),
          createdAt: createdAt,
        );

        final completedOrder = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          status: OrderStatus.completed(),
          createdAt: createdAt,
        );

        expect(pendingOrder.canBeCancelled, isTrue);
        expect(completedOrder.canBeCancelled, isFalse);
      });

      test('should check if order requires immediate attention', () {
        final urgentOrder = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          priority: Priority.createUrgent(),
          createdAt: createdAt,
        );

        final normalOrder = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          priority: Priority.createMedium(),
          createdAt: createdAt,
        );

        expect(urgentOrder.requiresImmediateAttention, isTrue);
        expect(normalOrder.requiresImmediateAttention, isFalse);
      });

      test('should check if order is overdue', () {
        final oldTime = Time.now().subtract(const Duration(minutes: 40));
        final overdueOrder = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          status: OrderStatus.preparing(),
          startedAt: oldTime,
          createdAt: oldTime,
        );

        expect(overdueOrder.isOverdue, isTrue);
      });
    });

    group('station assignment', () {
      test('should assign order to station', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          createdAt: createdAt,
        );

        final stationId = UserId('station1');
        final assignedOrder = order.assignToStation(stationId);

        expect(assignedOrder.assignedStationId, equals(stationId));
      });

      test('should unassign order from station', () {
        final stationId = UserId('station1');
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          assignedStationId: stationId,
          createdAt: createdAt,
        );

        final unassignedOrder = order.unassignFromStation();

        expect(unassignedOrder.assignedStationId, isNull);
      });
    });

    group('equality', () {
      test('should be equal when ids are the same', () {
        final order1 = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          createdAt: createdAt,
        );

        final order2 = Order(
          id: orderId,
          customerId: UserId('different'),
          items: [orderItem2],
          priority: Priority.createHigh(),
          createdAt: Time.now(),
        );

        expect(order1, equals(order2));
        expect(order1.hashCode, equals(order2.hashCode));
      });

      test('should not be equal when ids are different', () {
        final order1 = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1],
          createdAt: createdAt,
        );

        final differentId = UserId('different-order-id');
        final order2 = Order(
          id: differentId,
          customerId: customerId,
          items: [orderItem1],
          createdAt: createdAt,
        );

        expect(order1, isNot(equals(order2)));
      });
    });

    group('string representation', () {
      test('should return string representation', () {
        final order = Order(
          id: orderId,
          customerId: customerId,
          items: [orderItem1, orderItem2],
          priority: Priority.createHigh(),
          createdAt: createdAt,
        );

        final string = order.toString();
        expect(string, contains('Order'));
        expect(string, contains('pending'));
        expect(string, contains('high'));
        expect(string, contains('30.97'));
      });
    });
  });
}
