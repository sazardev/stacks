// Data Mappers for Firebase Document to Domain Entity conversion
// JSON serialization/deserialization for clean architecture

import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/order_status.dart';
import '../../domain/value_objects/priority.dart';
import '../../domain/value_objects/time.dart';
import '../../domain/value_objects/money.dart';

/// Mapper for converting Order entities to/from Firestore documents
class OrderMapper {
  /// Convert Order entity to Firestore document
  Map<String, dynamic> toFirestore(Order order) {
    return {
      'id': order.id.value,
      'tableId': order.tableId?.value,
      'customerId': order.customerId.value,
      'assignedStationId': order.assignedStationId?.value,
      'status': order.status.value,
      'priority': order.priority.level,
      'createdAt': order.createdAt.dateTime.millisecondsSinceEpoch,
      'confirmedAt': order.confirmedAt?.dateTime.millisecondsSinceEpoch,
      'startedAt': order.startedAt?.dateTime.millisecondsSinceEpoch,
      'readyAt': order.readyAt?.dateTime.millisecondsSinceEpoch,
      'completedAt': order.completedAt?.dateTime.millisecondsSinceEpoch,
      'specialInstructions': order.specialInstructions,
      'cancellationReason': order.cancellationReason,
      // Items will be stored in subcollection
    };
  }

  /// Convert OrderItem entity to Firestore document
  Map<String, dynamic> orderItemToFirestore(OrderItem item) {
    return {
      'id': item.id.value,
      'recipeId': item.recipe.id.value,
      'recipeName': item.recipe.name,
      'quantity': item.quantity,
      'unitPrice': item.recipe.price.amount,
      'status': _orderItemStatusToString(item.status),
      'isModified': item.isModified,
      'createdAt': item.createdAt.dateTime.millisecondsSinceEpoch,
      'startedAt': item.startedAt?.dateTime.millisecondsSinceEpoch,
      'completedAt': item.completedAt?.dateTime.millisecondsSinceEpoch,
      'deliveredAt': item.deliveredAt?.dateTime.millisecondsSinceEpoch,
      'specialInstructions': item.specialInstructions,
      'cancellationReason': item.cancellationReason,
    };
  }

  /// Convert Firestore document to Order entity
  Order fromFirestore(
    Map<String, dynamic> data,
    String documentId,
    List<OrderItem> items,
  ) {
    return Order(
      id: UserId(data['id'] as String),
      tableId: data['tableId'] != null
          ? UserId(data['tableId'] as String)
          : null,
      customerId: UserId(data['customerId'] as String),
      assignedStationId: data['assignedStationId'] != null
          ? UserId(data['assignedStationId'] as String)
          : null,
      items: items,
      status: OrderStatus.fromString(data['status'] as String),
      priority: Priority(data['priority'] as int),
      createdAt: Time.fromMillisecondsSinceEpoch(data['createdAt'] as int),
      confirmedAt: data['confirmedAt'] != null
          ? Time.fromMillisecondsSinceEpoch(data['confirmedAt'] as int)
          : null,
      startedAt: data['startedAt'] != null
          ? Time.fromMillisecondsSinceEpoch(data['startedAt'] as int)
          : null,
      readyAt: data['readyAt'] != null
          ? Time.fromMillisecondsSinceEpoch(data['readyAt'] as int)
          : null,
      completedAt: data['completedAt'] != null
          ? Time.fromMillisecondsSinceEpoch(data['completedAt'] as int)
          : null,
      specialInstructions: data['specialInstructions'] as String?,
      cancellationReason: data['cancellationReason'] as String?,
    );
  }

  /// Convert Firestore document to OrderItem entity
  /// Note: This creates a simplified OrderItem without full Recipe entity
  /// In a real implementation, you would fetch the Recipe separately
  OrderItem orderItemFromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    // Create a simple recipe for the OrderItem
    // In production, this should fetch the full recipe entity
    final recipe = Recipe(
      id: UserId(data['recipeId'] as String),
      name: data['recipeName'] as String,
      category: RecipeCategory.main, // Default category
      difficulty: RecipeDifficulty.medium, // Default difficulty
      preparationTimeMinutes: 15, // Default prep time
      cookingTimeMinutes: 15, // Default cook time
      ingredients: [], // Empty ingredients list
      instructions: [], // Empty instructions list
      price: Money(data['unitPrice'] as double),
      createdAt: Time.now(),
    );

    return OrderItem(
      id: UserId(data['id'] as String),
      recipe: recipe,
      quantity: data['quantity'] as int,
      status: _stringToOrderItemStatus(data['status'] as String),
      isModified: data['isModified'] as bool? ?? false,
      createdAt: Time.fromMillisecondsSinceEpoch(data['createdAt'] as int),
      startedAt: data['startedAt'] != null
          ? Time.fromMillisecondsSinceEpoch(data['startedAt'] as int)
          : null,
      completedAt: data['completedAt'] != null
          ? Time.fromMillisecondsSinceEpoch(data['completedAt'] as int)
          : null,
      deliveredAt: data['deliveredAt'] != null
          ? Time.fromMillisecondsSinceEpoch(data['deliveredAt'] as int)
          : null,
      specialInstructions: data['specialInstructions'] as String?,
      cancellationReason: data['cancellationReason'] as String?,
    );
  }

  // Helper methods for OrderItemStatus enum conversions
  String _orderItemStatusToString(OrderItemStatus status) {
    switch (status) {
      case OrderItemStatus.pending:
        return 'pending';
      case OrderItemStatus.preparing:
        return 'preparing';
      case OrderItemStatus.ready:
        return 'ready';
      case OrderItemStatus.delivered:
        return 'delivered';
      case OrderItemStatus.cancelled:
        return 'cancelled';
    }
  }

  OrderItemStatus _stringToOrderItemStatus(String status) {
    switch (status) {
      case 'pending':
        return OrderItemStatus.pending;
      case 'preparing':
        return OrderItemStatus.preparing;
      case 'ready':
        return OrderItemStatus.ready;
      case 'delivered':
        return OrderItemStatus.delivered;
      case 'cancelled':
        return OrderItemStatus.cancelled;
      default:
        throw ArgumentError('Unknown order item status: $status');
    }
  }

  // Helper method for OrderStatus string conversion
  String statusToString(OrderStatus status) {
    return status.value;
  }
}
