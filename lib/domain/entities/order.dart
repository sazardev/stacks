import '../value_objects/user_id.dart';
import '../value_objects/time.dart';
import '../value_objects/money.dart';
import '../value_objects/priority.dart';
import '../value_objects/order_status.dart';
import '../exceptions/domain_exception.dart';
import 'order_item.dart';

/// Order entity representing a complete order in the kitchen system
class Order {
  static const int _maxItemsCount = 100;
  static const int _maxSpecialInstructionsLength = 1000;

  final UserId _id;
  final UserId _customerId;
  final UserId? _tableId;
  final List<OrderItem> _items;
  final Priority _priority;
  final OrderStatus _status;
  final String? _specialInstructions;
  final String? _cancellationReason;
  final UserId? _assignedStationId;
  final Time _createdAt;
  final Time? _confirmedAt;
  final Time? _startedAt;
  final Time? _readyAt;
  final Time? _completedAt;

  /// Creates an Order with the specified properties
  Order({
    required UserId id,
    required UserId customerId,
    UserId? tableId,
    required List<OrderItem> items,
    Priority? priority,
    OrderStatus? status,
    String? specialInstructions,
    String? cancellationReason,
    UserId? assignedStationId,
    required Time createdAt,
    Time? confirmedAt,
    Time? startedAt,
    Time? readyAt,
    Time? completedAt,
  }) : _id = id,
       _customerId = customerId,
       _tableId = tableId,
       _items = _validateItems(items),
       _priority = priority ?? Priority.createMedium(),
       _status = status ?? OrderStatus.pending(),
       _specialInstructions = _validateSpecialInstructions(specialInstructions),
       _cancellationReason = cancellationReason,
       _assignedStationId = assignedStationId,
       _createdAt = createdAt,
       _confirmedAt = confirmedAt,
       _startedAt = startedAt,
       _readyAt = readyAt,
       _completedAt = completedAt;

  /// Order ID
  UserId get id => _id;

  /// Customer ID
  UserId get customerId => _customerId;

  /// Table ID (if dine-in)
  UserId? get tableId => _tableId;

  /// List of order items
  List<OrderItem> get items => _items;

  /// Order priority
  Priority get priority => _priority;

  /// Order status
  OrderStatus get status => _status;

  /// Special instructions for the order
  String? get specialInstructions => _specialInstructions;

  /// Reason for cancellation (if cancelled)
  String? get cancellationReason => _cancellationReason;

  /// Assigned station ID
  UserId? get assignedStationId => _assignedStationId;

  /// When the order was created
  Time get createdAt => _createdAt;

  /// When the order was confirmed
  Time? get confirmedAt => _confirmedAt;

  /// When preparation started
  Time? get startedAt => _startedAt;

  /// When the order was ready
  Time? get readyAt => _readyAt;

  /// When the order was completed
  Time? get completedAt => _completedAt;

  /// Validates order items
  static List<OrderItem> _validateItems(List<OrderItem> items) {
    if (items.isEmpty) {
      throw const DomainException('Order must contain at least one item');
    }

    if (items.length > _maxItemsCount) {
      throw DomainException(
        'Order cannot contain more than $_maxItemsCount items',
      );
    }

    return List.unmodifiable(items);
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

  /// Total amount for the order
  Money get totalAmount {
    var total = Money(0.0);
    for (final item in _items) {
      total = total.add(item.totalPrice);
    }
    return total;
  }

  /// Total number of items (considering quantities)
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Estimated preparation time in minutes (maximum of all items)
  int get estimatedTimeMinutes {
    if (_items.isEmpty) return 0;
    return _items
        .map((item) => item.estimatedTimeMinutes)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Whether the order is active (not completed or cancelled)
  bool get isActive => _status.isActive;

  /// Whether the order is completed
  bool get isCompleted => _status.isCompleted;

  /// Whether the order can be modified (only when pending or confirmed)
  bool get canBeModified => _status.isPending || _status.isConfirmed;

  /// Whether the order can be cancelled (not completed)
  bool get canBeCancelled => !_status.isCompleted;

  /// Whether the order requires immediate attention
  bool get requiresImmediateAttention => _priority.requiresImmediateAttention;

  /// Whether the order is overdue
  bool get isOverdue {
    if (_startedAt == null) return false;
    final elapsedMinutes = Time.now().minutesSince(_startedAt);
    return elapsedMinutes > estimatedTimeMinutes;
  }

  /// Confirms the order
  Order confirm() {
    if (!_status.isPending) {
      throw DomainException(
        'Cannot confirm order with status: ${_status.value}',
      );
    }

    return Order(
      id: _id,
      customerId: _customerId,
      tableId: _tableId,
      items: _items,
      priority: _priority,
      status: OrderStatus.confirmed(),
      specialInstructions: _specialInstructions,
      cancellationReason: _cancellationReason,
      assignedStationId: _assignedStationId,
      createdAt: _createdAt,
      confirmedAt: Time.now(),
      startedAt: _startedAt,
      readyAt: _readyAt,
      completedAt: _completedAt,
    );
  }

  /// Starts preparation of the order
  Order startPreparation() {
    if (!_status.isConfirmed) {
      throw DomainException(
        'Cannot start preparation for order with status: ${_status.value}',
      );
    }

    return Order(
      id: _id,
      customerId: _customerId,
      tableId: _tableId,
      items: _items,
      priority: _priority,
      status: OrderStatus.preparing(),
      specialInstructions: _specialInstructions,
      cancellationReason: _cancellationReason,
      assignedStationId: _assignedStationId,
      createdAt: _createdAt,
      confirmedAt: _confirmedAt,
      startedAt: Time.now(),
      readyAt: _readyAt,
      completedAt: _completedAt,
    );
  }

  /// Marks the order as ready
  Order markReady() {
    if (!_status.isPreparing) {
      throw DomainException(
        'Cannot mark order ready with status: ${_status.value}',
      );
    }

    return Order(
      id: _id,
      customerId: _customerId,
      tableId: _tableId,
      items: _items,
      priority: _priority,
      status: OrderStatus.ready(),
      specialInstructions: _specialInstructions,
      cancellationReason: _cancellationReason,
      assignedStationId: _assignedStationId,
      createdAt: _createdAt,
      confirmedAt: _confirmedAt,
      startedAt: _startedAt,
      readyAt: Time.now(),
      completedAt: _completedAt,
    );
  }

  /// Completes the order
  Order complete() {
    if (!_status.isReady) {
      throw DomainException(
        'Cannot complete order with status: ${_status.value}',
      );
    }

    return Order(
      id: _id,
      customerId: _customerId,
      tableId: _tableId,
      items: _items,
      priority: _priority,
      status: OrderStatus.completed(),
      specialInstructions: _specialInstructions,
      cancellationReason: _cancellationReason,
      assignedStationId: _assignedStationId,
      createdAt: _createdAt,
      confirmedAt: _confirmedAt,
      startedAt: _startedAt,
      readyAt: _readyAt,
      completedAt: Time.now(),
    );
  }

  /// Cancels the order
  Order cancel(String reason) {
    if (!canBeCancelled) {
      throw DomainException(
        'Cannot cancel order with status: ${_status.value}',
      );
    }

    if (reason.trim().isEmpty) {
      throw const DomainException('Cancellation reason cannot be empty');
    }

    return Order(
      id: _id,
      customerId: _customerId,
      tableId: _tableId,
      items: _items,
      priority: _priority,
      status: OrderStatus.cancelled(),
      specialInstructions: _specialInstructions,
      cancellationReason: reason.trim(),
      assignedStationId: _assignedStationId,
      createdAt: _createdAt,
      confirmedAt: _confirmedAt,
      startedAt: _startedAt,
      readyAt: _readyAt,
      completedAt: _completedAt,
    );
  }

  /// Adds an item to the order
  Order addItem(OrderItem item) {
    if (!canBeModified) {
      throw DomainException(
        'Cannot modify order with status: ${_status.value}',
      );
    }

    final newItems = List<OrderItem>.from(_items)..add(item);
    _validateItems(newItems);

    return Order(
      id: _id,
      customerId: _customerId,
      tableId: _tableId,
      items: newItems,
      priority: _priority,
      status: _status,
      specialInstructions: _specialInstructions,
      cancellationReason: _cancellationReason,
      assignedStationId: _assignedStationId,
      createdAt: _createdAt,
      confirmedAt: _confirmedAt,
      startedAt: _startedAt,
      readyAt: _readyAt,
      completedAt: _completedAt,
    );
  }

  /// Removes an item from the order
  Order removeItem(UserId itemId) {
    if (!canBeModified) {
      throw DomainException(
        'Cannot modify order with status: ${_status.value}',
      );
    }

    final itemExists = _items.any((item) => item.id == itemId);
    if (!itemExists) {
      throw DomainException('Item with id ${itemId.value} not found in order');
    }

    final newItems = _items.where((item) => item.id != itemId).toList();
    _validateItems(newItems);

    return Order(
      id: _id,
      customerId: _customerId,
      tableId: _tableId,
      items: newItems,
      priority: _priority,
      status: _status,
      specialInstructions: _specialInstructions,
      cancellationReason: _cancellationReason,
      assignedStationId: _assignedStationId,
      createdAt: _createdAt,
      confirmedAt: _confirmedAt,
      startedAt: _startedAt,
      readyAt: _readyAt,
      completedAt: _completedAt,
    );
  }

  /// Updates an item in the order
  Order updateItem(OrderItem updatedItem) {
    if (!canBeModified) {
      throw DomainException(
        'Cannot modify order with status: ${_status.value}',
      );
    }

    final itemIndex = _items.indexWhere((item) => item.id == updatedItem.id);
    if (itemIndex == -1) {
      throw DomainException(
        'Item with id ${updatedItem.id.value} not found in order',
      );
    }

    final newItems = List<OrderItem>.from(_items);
    newItems[itemIndex] = updatedItem;

    return Order(
      id: _id,
      customerId: _customerId,
      tableId: _tableId,
      items: newItems,
      priority: _priority,
      status: _status,
      specialInstructions: _specialInstructions,
      cancellationReason: _cancellationReason,
      assignedStationId: _assignedStationId,
      createdAt: _createdAt,
      confirmedAt: _confirmedAt,
      startedAt: _startedAt,
      readyAt: _readyAt,
      completedAt: _completedAt,
    );
  }

  /// Escalates the order priority
  Order escalatePriority() {
    return Order(
      id: _id,
      customerId: _customerId,
      tableId: _tableId,
      items: _items,
      priority: _priority.escalate(),
      status: _status,
      specialInstructions: _specialInstructions,
      cancellationReason: _cancellationReason,
      assignedStationId: _assignedStationId,
      createdAt: _createdAt,
      confirmedAt: _confirmedAt,
      startedAt: _startedAt,
      readyAt: _readyAt,
      completedAt: _completedAt,
    );
  }

  /// Updates the order priority
  Order updatePriority(Priority newPriority) {
    return Order(
      id: _id,
      customerId: _customerId,
      tableId: _tableId,
      items: _items,
      priority: newPriority,
      status: _status,
      specialInstructions: _specialInstructions,
      cancellationReason: _cancellationReason,
      assignedStationId: _assignedStationId,
      createdAt: _createdAt,
      confirmedAt: _confirmedAt,
      startedAt: _startedAt,
      readyAt: _readyAt,
      completedAt: _completedAt,
    );
  }

  /// Assigns the order to a station
  Order assignToStation(UserId stationId) {
    return Order(
      id: _id,
      customerId: _customerId,
      tableId: _tableId,
      items: _items,
      priority: _priority,
      status: _status,
      specialInstructions: _specialInstructions,
      cancellationReason: _cancellationReason,
      assignedStationId: stationId,
      createdAt: _createdAt,
      confirmedAt: _confirmedAt,
      startedAt: _startedAt,
      readyAt: _readyAt,
      completedAt: _completedAt,
    );
  }

  /// Unassigns the order from its current station
  Order unassignFromStation() {
    return Order(
      id: _id,
      customerId: _customerId,
      tableId: _tableId,
      items: _items,
      priority: _priority,
      status: _status,
      specialInstructions: _specialInstructions,
      cancellationReason: _cancellationReason,
      assignedStationId: null,
      createdAt: _createdAt,
      confirmedAt: _confirmedAt,
      startedAt: _startedAt,
      readyAt: _readyAt,
      completedAt: _completedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() {
    return 'Order(id: ${_id.value}, status: ${_status.value}, '
        'priority: ${_priority.name.toLowerCase()}, items: ${_items.length}, '
        'total: ${totalAmount.toString()})';
  }
}
