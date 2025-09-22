import '../value_objects/user_id.dart';
import '../value_objects/time.dart';
import '../value_objects/money.dart';
import '../exceptions/domain_exception.dart';
import 'recipe.dart';

/// OrderItem status in the kitchen workflow
enum OrderItemStatus { pending, preparing, ready, delivered, cancelled }

/// OrderItem entity representing a single item in an order
class OrderItem {
  static const int _maxQuantity = 50;
  static const int _maxSpecialInstructionsLength = 500;

  final UserId _id;
  final Recipe _recipe;
  final int _quantity;
  final String? _specialInstructions;
  final OrderItemStatus _status;
  final bool _isModified;
  final Time _createdAt;
  final Time? _startedAt;
  final Time? _completedAt;
  final Time? _deliveredAt;
  final String? _cancellationReason;

  /// Creates an OrderItem with the specified properties
  OrderItem({
    required UserId id,
    required Recipe recipe,
    required int quantity,
    String? specialInstructions,
    OrderItemStatus status = OrderItemStatus.pending,
    bool isModified = false,
    required Time createdAt,
    Time? startedAt,
    Time? completedAt,
    Time? deliveredAt,
    String? cancellationReason,
  }) : _id = id,
       _recipe = recipe,
       _quantity = _validateQuantity(quantity),
       _specialInstructions = _validateSpecialInstructions(specialInstructions),
       _status = status,
       _isModified = isModified,
       _createdAt = createdAt,
       _startedAt = startedAt,
       _completedAt = completedAt,
       _deliveredAt = deliveredAt,
       _cancellationReason = cancellationReason;

  /// OrderItem ID
  UserId get id => _id;

  /// Associated recipe
  Recipe get recipe => _recipe;

  /// Quantity of this item
  int get quantity => _quantity;

  /// Special instructions for preparation
  String? get specialInstructions => _specialInstructions;

  /// Current status of the order item
  OrderItemStatus get status => _status;

  /// Whether the item has been modified
  bool get isModified => _isModified;

  /// When the order item was created
  Time get createdAt => _createdAt;

  /// When preparation started
  Time? get startedAt => _startedAt;

  /// When preparation was completed
  Time? get completedAt => _completedAt;

  /// When the item was delivered
  Time? get deliveredAt => _deliveredAt;

  /// Reason for cancellation (if cancelled)
  String? get cancellationReason => _cancellationReason;

  /// Validates quantity
  static int _validateQuantity(int quantity) {
    if (quantity <= 0) {
      throw const DomainException(
        'Order item quantity must be greater than zero',
      );
    }

    if (quantity > _maxQuantity) {
      throw DomainException('Order item quantity cannot exceed $_maxQuantity');
    }

    return quantity;
  }

  /// Validates special instructions
  static String? _validateSpecialInstructions(String? instructions) {
    if (instructions == null) return null;

    if (instructions.length > _maxSpecialInstructionsLength) {
      throw DomainException(
        'Special instructions cannot exceed $_maxSpecialInstructionsLength characters',
      );
    }

    return instructions.trim().isEmpty ? null : instructions.trim();
  }

  // Status checkers
  bool get isPending => _status == OrderItemStatus.pending;
  bool get isPreparing => _status == OrderItemStatus.preparing;
  bool get isReady => _status == OrderItemStatus.ready;
  bool get isDelivered => _status == OrderItemStatus.delivered;
  bool get isCancelled => _status == OrderItemStatus.cancelled;

  /// Whether the order item is completed (delivered)
  bool get isCompleted => isDelivered;

  /// Total price for this order item (recipe price * quantity)
  Money get totalPrice => _recipe.price.multiply(_quantity);

  /// Estimated preparation time in minutes
  int get estimatedTimeMinutes => _recipe.totalTimeMinutes;

  /// Preparation time from recipe
  int get preparationTimeMinutes => _recipe.preparationTimeMinutes;

  /// Cooking time from recipe
  int get cookingTimeMinutes => _recipe.cookingTimeMinutes;

  /// Whether the item can be modified (only when pending)
  bool get canBeModified => isPending;

  /// Whether the item can be cancelled (not delivered or cancelled)
  bool get canBeCancelled => !isDelivered && !isCancelled;

  /// Whether the item requires special handling
  bool get requiresSpecialHandling => _specialInstructions != null;

  /// Actual preparation duration (if completed)
  Duration? get actualPreparationDuration {
    if (_startedAt == null || _completedAt == null) return null;
    return _completedAt.difference(_startedAt);
  }

  /// Whether the item is overdue (taking longer than estimated time)
  bool get isOverdue {
    if (_startedAt == null) return false;
    final elapsedMinutes = Time.now().minutesSince(_startedAt);
    return elapsedMinutes > estimatedTimeMinutes;
  }

  /// Starts preparation of the order item
  OrderItem startPreparation() {
    if (!isPending) {
      throw DomainException(
        'Cannot start preparation for order item with status: ${_status.name}',
      );
    }

    return OrderItem(
      id: _id,
      recipe: _recipe,
      quantity: _quantity,
      specialInstructions: _specialInstructions,
      status: OrderItemStatus.preparing,
      isModified: _isModified,
      createdAt: _createdAt,
      startedAt: Time.now(),
      completedAt: _completedAt,
      deliveredAt: _deliveredAt,
      cancellationReason: _cancellationReason,
    );
  }

  /// Completes preparation of the order item
  OrderItem completePreparation() {
    if (!isPreparing) {
      throw DomainException(
        'Cannot complete preparation for order item with status: ${_status.name}',
      );
    }

    return OrderItem(
      id: _id,
      recipe: _recipe,
      quantity: _quantity,
      specialInstructions: _specialInstructions,
      status: OrderItemStatus.ready,
      isModified: _isModified,
      createdAt: _createdAt,
      startedAt: _startedAt,
      completedAt: Time.now(),
      deliveredAt: _deliveredAt,
      cancellationReason: _cancellationReason,
    );
  }

  /// Delivers the order item
  OrderItem deliver() {
    if (!isReady) {
      throw DomainException(
        'Cannot deliver order item with status: ${_status.name}',
      );
    }

    return OrderItem(
      id: _id,
      recipe: _recipe,
      quantity: _quantity,
      specialInstructions: _specialInstructions,
      status: OrderItemStatus.delivered,
      isModified: _isModified,
      createdAt: _createdAt,
      startedAt: _startedAt,
      completedAt: _completedAt,
      deliveredAt: Time.now(),
      cancellationReason: _cancellationReason,
    );
  }

  /// Cancels the order item
  OrderItem cancel(String reason) {
    if (!canBeCancelled) {
      throw DomainException(
        'Cannot cancel order item with status: ${_status.name}',
      );
    }

    if (reason.trim().isEmpty) {
      throw const DomainException('Cancellation reason cannot be empty');
    }

    return OrderItem(
      id: _id,
      recipe: _recipe,
      quantity: _quantity,
      specialInstructions: _specialInstructions,
      status: OrderItemStatus.cancelled,
      isModified: _isModified,
      createdAt: _createdAt,
      startedAt: _startedAt,
      completedAt: _completedAt,
      deliveredAt: _deliveredAt,
      cancellationReason: reason.trim(),
    );
  }

  /// Updates the quantity of the order item
  OrderItem updateQuantity(int newQuantity) {
    if (!canBeModified) {
      throw DomainException(
        'Cannot modify order item with status: ${_status.name}',
      );
    }

    _validateQuantity(newQuantity);

    return OrderItem(
      id: _id,
      recipe: _recipe,
      quantity: newQuantity,
      specialInstructions: _specialInstructions,
      status: _status,
      isModified: true,
      createdAt: _createdAt,
      startedAt: _startedAt,
      completedAt: _completedAt,
      deliveredAt: _deliveredAt,
      cancellationReason: _cancellationReason,
    );
  }

  /// Updates the special instructions
  OrderItem updateSpecialInstructions(String? newInstructions) {
    if (!canBeModified) {
      throw DomainException(
        'Cannot modify order item with status: ${_status.name}',
      );
    }

    final validatedInstructions = _validateSpecialInstructions(newInstructions);

    return OrderItem(
      id: _id,
      recipe: _recipe,
      quantity: _quantity,
      specialInstructions: validatedInstructions,
      status: _status,
      isModified: true,
      createdAt: _createdAt,
      startedAt: _startedAt,
      completedAt: _completedAt,
      deliveredAt: _deliveredAt,
      cancellationReason: _cancellationReason,
    );
  }

  /// Creates a copy of this OrderItem with optional field updates
  OrderItem copyWith({
    UserId? id,
    Recipe? recipe,
    int? quantity,
    String? specialInstructions,
    OrderItemStatus? status,
    bool? isModified,
    Time? createdAt,
    Time? startedAt,
    Time? completedAt,
    Time? deliveredAt,
    String? cancellationReason,
  }) {
    return OrderItem(
      id: id ?? _id,
      recipe: recipe ?? _recipe,
      quantity: quantity ?? _quantity,
      specialInstructions: specialInstructions ?? _specialInstructions,
      status: status ?? _status,
      isModified: isModified ?? _isModified,
      createdAt: createdAt ?? _createdAt,
      startedAt: startedAt ?? _startedAt,
      completedAt: completedAt ?? _completedAt,
      deliveredAt: deliveredAt ?? _deliveredAt,
      cancellationReason: cancellationReason ?? _cancellationReason,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItem &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() {
    return 'OrderItem(id: ${_id.value}, recipe: ${_recipe.name}, '
        'quantity: $_quantity, status: ${_status.name}, '
        'price: ${totalPrice.toString()})';
  }
}
