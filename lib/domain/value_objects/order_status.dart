import '../exceptions/domain_exception.dart';

/// OrderStatus value object representing the current state of an order in the kitchen workflow
class OrderStatus {
  static const String _pending = 'pending';
  static const String _confirmed = 'confirmed';
  static const String _preparing = 'preparing';
  static const String _ready = 'ready';
  static const String _completed = 'completed';
  static const String _cancelled = 'cancelled';

  static const List<String> _validStatuses = [
    _pending,
    _confirmed,
    _preparing,
    _ready,
    _completed,
    _cancelled,
  ];

  static const Map<String, String> _displayNames = {
    _pending: 'Pending',
    _confirmed: 'Confirmed',
    _preparing: 'Preparing',
    _ready: 'Ready',
    _completed: 'Completed',
    _cancelled: 'Cancelled',
  };

  static const Map<String, List<String>> _validTransitions = {
    _pending: [_confirmed, _cancelled],
    _confirmed: [_preparing, _cancelled],
    _preparing: [_ready, _cancelled],
    _ready: [_completed],
    _completed: [],
    _cancelled: [],
  };

  static const Map<String, double> _priorityMultipliers = {
    _pending: 1.0,
    _confirmed: 1.2,
    _preparing: 1.5,
    _ready: 2.0,
    _completed: 1.0,
    _cancelled: 1.0,
  };

  static const Map<String, int> _expectedCompletionTimes = {
    _pending: 25, // 5 + 5 + 10 + 5
    _confirmed: 20, // 5 + 10 + 5
    _preparing: 15, // 10 + 5
    _ready: 5, // 5
    _completed: 0,
    _cancelled: 0,
  };

  static const Map<String, int> _sortOrders = {
    _preparing: 1, // Highest priority - actively being worked on
    _ready: 2, // Second priority - needs pickup
    _confirmed: 3, // Third priority - needs to start preparation
    _pending: 4, // Fourth priority - needs confirmation
    _completed: 5, // Fifth priority - done
    _cancelled: 6, // Lowest priority - cancelled
  };

  final String _value;

  /// Creates a pending order status
  OrderStatus.pending() : _value = _pending;

  /// Creates a confirmed order status
  OrderStatus.confirmed() : _value = _confirmed;

  /// Creates a preparing order status
  OrderStatus.preparing() : _value = _preparing;

  /// Creates a ready order status
  OrderStatus.ready() : _value = _ready;

  /// Creates a completed order status
  OrderStatus.completed() : _value = _completed;

  /// Creates a cancelled order status
  OrderStatus.cancelled() : _value = _cancelled;

  /// Creates an OrderStatus from a string value
  OrderStatus.fromString(String value) : _value = _validateStatus(value);

  /// The string value of the status
  String get value => _value;

  /// The human-readable display name
  String get displayName => _displayNames[_value]!;

  /// Validates the status value
  static String _validateStatus(String value) {
    if (value.isEmpty) {
      throw const ValueObjectException('Order status cannot be empty');
    }

    if (!_validStatuses.contains(value)) {
      throw ValueObjectException('Invalid order status: $value');
    }

    return value;
  }

  // Status checkers
  bool get isPending => _value == _pending;
  bool get isConfirmed => _value == _confirmed;
  bool get isPreparing => _value == _preparing;
  bool get isReady => _value == _ready;
  bool get isCompleted => _value == _completed;
  bool get isCancelled => _value == _cancelled;

  /// Whether the order is still active (not completed or cancelled)
  bool get isActive => !isFinal;

  /// Whether the order is in a final state (completed or cancelled)
  bool get isFinal => isCompleted || isCancelled;

  /// Whether the order is currently in the kitchen workflow
  bool get isInKitchen => isConfirmed || isPreparing || isReady;

  /// Priority multiplier for this status (higher values = higher priority)
  double get priorityMultiplier => _priorityMultipliers[_value]!;

  /// Expected time to completion in minutes from current status
  int get expectedTimeToCompletionMinutes => _expectedCompletionTimes[_value]!;

  /// Sort order for displaying orders (lower values = higher priority)
  int get sortOrder => _sortOrders[_value]!;

  /// Whether this status requires time tracking
  bool get requiresTimeTracking => isInKitchen;

  /// Whether this status requires notification
  bool get requiresNotification => isReady || isCompleted || isCancelled;

  /// Gets valid next statuses from current status
  List<String> getValidNextStatuses() {
    return List.unmodifiable(_validTransitions[_value]!);
  }

  /// Checks if transition to another status is valid
  bool canTransitionTo(OrderStatus newStatus) {
    return _validTransitions[_value]!.contains(newStatus._value);
  }

  /// Transitions to a new status if valid
  OrderStatus transitionTo(OrderStatus newStatus) {
    if (isFinal) {
      throw BusinessRuleException(
        'Cannot transition from final status: $_value',
      );
    }

    if (!canTransitionTo(newStatus)) {
      throw BusinessRuleException(
        'Invalid status transition from $_value to ${newStatus._value}',
      );
    }

    return newStatus;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderStatus &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() {
    return displayName;
  }
}
