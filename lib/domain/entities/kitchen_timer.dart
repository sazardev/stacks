import '../value_objects/user_id.dart';
import '../value_objects/time.dart';
import '../exceptions/domain_exception.dart';

/// Timer types for kitchen operations
enum TimerType {
  /// Cooking timer for active preparation
  cooking,

  /// Hold timer for finished items waiting to be served
  hold,

  /// Prep timer for preparation tasks
  prep,

  /// Temperature check timer
  temperatureCheck,

  /// Equipment maintenance timer
  maintenance,

  /// Food safety timer (like hand washing)
  foodSafety,

  /// Break timer for staff
  staffBreak,

  /// Cleaning timer
  cleaning,
}

/// Timer status during operation
enum TimerStatus {
  /// Timer is created but not started
  created,

  /// Timer is actively running
  running,

  /// Timer is paused
  paused,

  /// Timer has completed (reached zero)
  completed,

  /// Timer was cancelled before completion
  cancelled,

  /// Timer has expired (past completion time)
  expired,
}

/// Priority level for timers
enum TimerPriority {
  /// Low priority timer
  low,

  /// Normal priority timer
  normal,

  /// High priority timer
  high,

  /// Critical priority timer (food safety, etc.)
  critical,
}

/// Kitchen timer entity for managing cooking and operation times
class KitchenTimer {
  static const int _maxLabelLength = 100;
  static const int _maxDurationMinutes = 600; // 10 hours max
  static const int _minDurationSeconds = 1;

  final UserId _id;
  final String _label;
  final TimerType _type;
  final Duration _originalDuration;
  final Duration _remainingDuration;
  final TimerStatus _status;
  final TimerPriority _priority;
  final UserId? _orderId;
  final UserId? _stationId;
  final UserId _createdBy;
  final Time _createdAt;
  final Time? _startedAt;
  final Time? _pausedAt;
  final Time? _completedAt;
  final String? _notes;
  final bool _isRepeating;
  final int _repeatCount;
  final bool _soundAlert;
  final bool _visualAlert;

  /// Creates a KitchenTimer with the specified properties
  KitchenTimer({
    required UserId id,
    required String label,
    required TimerType type,
    required Duration duration,
    Duration? remainingDuration,
    TimerStatus status = TimerStatus.created,
    TimerPriority priority = TimerPriority.normal,
    UserId? orderId,
    UserId? stationId,
    required UserId createdBy,
    required Time createdAt,
    Time? startedAt,
    Time? pausedAt,
    Time? completedAt,
    String? notes,
    bool isRepeating = false,
    int repeatCount = 0,
    bool soundAlert = true,
    bool visualAlert = true,
  }) : _id = id,
       _label = _validateLabel(label),
       _type = type,
       _originalDuration = _validateDuration(duration),
       _remainingDuration = remainingDuration ?? duration,
       _status = status,
       _priority = priority,
       _orderId = orderId,
       _stationId = stationId,
       _createdBy = createdBy,
       _createdAt = createdAt,
       _startedAt = startedAt,
       _pausedAt = pausedAt,
       _completedAt = completedAt,
       _notes = notes,
       _isRepeating = isRepeating,
       _repeatCount = repeatCount,
       _soundAlert = soundAlert,
       _visualAlert = visualAlert;

  /// Timer ID
  UserId get id => _id;

  /// Timer label/description
  String get label => _label;

  /// Timer type
  TimerType get type => _type;

  /// Original duration when timer was created
  Duration get originalDuration => _originalDuration;

  /// Remaining duration on timer
  Duration get remainingDuration => _remainingDuration;

  /// Current timer status
  TimerStatus get status => _status;

  /// Timer priority
  TimerPriority get priority => _priority;

  /// Associated order ID (if applicable)
  UserId? get orderId => _orderId;

  /// Associated station ID (if applicable)
  UserId? get stationId => _stationId;

  /// User who created the timer
  UserId get createdBy => _createdBy;

  /// When timer was created
  Time get createdAt => _createdAt;

  /// When timer was started
  Time? get startedAt => _startedAt;

  /// When timer was paused
  Time? get pausedAt => _pausedAt;

  /// When timer was completed
  Time? get completedAt => _completedAt;

  /// Additional notes
  String? get notes => _notes;

  /// Whether timer repeats
  bool get isRepeating => _isRepeating;

  /// Number of times repeated
  int get repeatCount => _repeatCount;

  /// Whether sound alert is enabled
  bool get soundAlert => _soundAlert;

  /// Whether visual alert is enabled
  bool get visualAlert => _visualAlert;

  /// Business rule: Check if timer is active
  bool get isActive => _status == TimerStatus.running;

  /// Business rule: Check if timer is paused
  bool get isPaused => _status == TimerStatus.paused;

  /// Business rule: Check if timer is completed
  bool get isCompleted => _status == TimerStatus.completed;

  /// Business rule: Check if timer has expired
  bool get isExpired => _status == TimerStatus.expired;

  /// Business rule: Check if timer can be started
  bool get canStart =>
      _status == TimerStatus.created || _status == TimerStatus.paused;

  /// Business rule: Check if timer can be paused
  bool get canPause => _status == TimerStatus.running;

  /// Business rule: Check if timer can be cancelled
  bool get canCancel =>
      _status == TimerStatus.running || _status == TimerStatus.paused;

  /// Business rule: Get elapsed time since start
  Duration get elapsedTime {
    if (_startedAt == null) return Duration.zero;

    if (_status == TimerStatus.running) {
      return Time.now().difference(_startedAt);
    } else if (_completedAt != null) {
      return _completedAt.difference(_startedAt);
    } else if (_pausedAt != null) {
      return _pausedAt.difference(_startedAt);
    }

    return Duration.zero;
  }

  /// Business rule: Calculate actual remaining time
  Duration get actualRemainingTime {
    if (_status != TimerStatus.running) return _remainingDuration;

    final elapsed = elapsedTime;
    final remaining = _remainingDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Business rule: Check if timer is overdue
  bool get isOverdue {
    if (_status != TimerStatus.running) return false;
    return actualRemainingTime <= Duration.zero;
  }

  /// Business rule: Get percentage complete
  double get percentComplete {
    if (_originalDuration == Duration.zero) return 100.0;
    final elapsed = elapsedTime;
    final percentage =
        (elapsed.inMilliseconds / _originalDuration.inMilliseconds) * 100;
    return percentage > 100.0 ? 100.0 : percentage;
  }

  /// Starts the timer
  KitchenTimer start() {
    if (!canStart) {
      throw DomainException('Cannot start timer with status: $_status');
    }

    return KitchenTimer(
      id: _id,
      label: _label,
      type: _type,
      duration: _originalDuration,
      remainingDuration: _remainingDuration,
      status: TimerStatus.running,
      priority: _priority,
      orderId: _orderId,
      stationId: _stationId,
      createdBy: _createdBy,
      createdAt: _createdAt,
      startedAt: _startedAt ?? Time.now(),
      pausedAt: null,
      completedAt: _completedAt,
      notes: _notes,
      isRepeating: _isRepeating,
      repeatCount: _repeatCount,
      soundAlert: _soundAlert,
      visualAlert: _visualAlert,
    );
  }

  /// Pauses the timer
  KitchenTimer pause() {
    if (!canPause) {
      throw DomainException('Cannot pause timer with status: $_status');
    }
    if (_startedAt == null) {
      throw const DomainException('Cannot pause timer that was never started');
    }

    final now = Time.now();
    final elapsed = now.difference(_startedAt);
    final newRemaining = _remainingDuration - elapsed;

    return KitchenTimer(
      id: _id,
      label: _label,
      type: _type,
      duration: _originalDuration,
      remainingDuration: newRemaining.isNegative ? Duration.zero : newRemaining,
      status: TimerStatus.paused,
      priority: _priority,
      orderId: _orderId,
      stationId: _stationId,
      createdBy: _createdBy,
      createdAt: _createdAt,
      startedAt: _startedAt,
      pausedAt: now,
      completedAt: _completedAt,
      notes: _notes,
      isRepeating: _isRepeating,
      repeatCount: _repeatCount,
      soundAlert: _soundAlert,
      visualAlert: _visualAlert,
    );
  }

  /// Completes the timer
  KitchenTimer complete() {
    if (_status == TimerStatus.completed) {
      throw const DomainException('Timer is already completed');
    }

    return KitchenTimer(
      id: _id,
      label: _label,
      type: _type,
      duration: _originalDuration,
      remainingDuration: Duration.zero,
      status: TimerStatus.completed,
      priority: _priority,
      orderId: _orderId,
      stationId: _stationId,
      createdBy: _createdBy,
      createdAt: _createdAt,
      startedAt: _startedAt,
      pausedAt: _pausedAt,
      completedAt: Time.now(),
      notes: _notes,
      isRepeating: _isRepeating,
      repeatCount: _repeatCount,
      soundAlert: _soundAlert,
      visualAlert: _visualAlert,
    );
  }

  /// Cancels the timer
  KitchenTimer cancel() {
    if (!canCancel) {
      throw DomainException('Cannot cancel timer with status: $_status');
    }

    return KitchenTimer(
      id: _id,
      label: _label,
      type: _type,
      duration: _originalDuration,
      remainingDuration: _remainingDuration,
      status: TimerStatus.cancelled,
      priority: _priority,
      orderId: _orderId,
      stationId: _stationId,
      createdBy: _createdBy,
      createdAt: _createdAt,
      startedAt: _startedAt,
      pausedAt: _pausedAt,
      completedAt: Time.now(),
      notes: _notes,
      isRepeating: _isRepeating,
      repeatCount: _repeatCount,
      soundAlert: _soundAlert,
      visualAlert: _visualAlert,
    );
  }

  /// Extends the timer by additional duration
  KitchenTimer extend(Duration additionalTime) {
    if (additionalTime.isNegative) {
      throw const DomainException('Additional time cannot be negative');
    }

    return KitchenTimer(
      id: _id,
      label: _label,
      type: _type,
      duration: _originalDuration + additionalTime,
      remainingDuration: _remainingDuration + additionalTime,
      status: _status,
      priority: _priority,
      orderId: _orderId,
      stationId: _stationId,
      createdBy: _createdBy,
      createdAt: _createdAt,
      startedAt: _startedAt,
      pausedAt: _pausedAt,
      completedAt: _completedAt,
      notes: _notes,
      isRepeating: _isRepeating,
      repeatCount: _repeatCount,
      soundAlert: _soundAlert,
      visualAlert: _visualAlert,
    );
  }

  /// Marks timer as expired
  KitchenTimer markExpired() {
    return KitchenTimer(
      id: _id,
      label: _label,
      type: _type,
      duration: _originalDuration,
      remainingDuration: Duration.zero,
      status: TimerStatus.expired,
      priority: _priority,
      orderId: _orderId,
      stationId: _stationId,
      createdBy: _createdBy,
      createdAt: _createdAt,
      startedAt: _startedAt,
      pausedAt: _pausedAt,
      completedAt: Time.now(),
      notes: _notes,
      isRepeating: _isRepeating,
      repeatCount: _repeatCount,
      soundAlert: _soundAlert,
      visualAlert: _visualAlert,
    );
  }

  /// Repeats the timer (if repeating is enabled)
  KitchenTimer repeat() {
    if (!_isRepeating) {
      throw const DomainException('Timer is not set to repeat');
    }

    return KitchenTimer(
      id: UserId.generate(), // New ID for repeated timer
      label: _label,
      type: _type,
      duration: _originalDuration,
      remainingDuration: _originalDuration,
      status: TimerStatus.created,
      priority: _priority,
      orderId: _orderId,
      stationId: _stationId,
      createdBy: _createdBy,
      createdAt: Time.now(),
      startedAt: null,
      pausedAt: null,
      completedAt: null,
      notes: _notes,
      isRepeating: _isRepeating,
      repeatCount: _repeatCount + 1,
      soundAlert: _soundAlert,
      visualAlert: _visualAlert,
    );
  }

  /// Validates timer label
  static String _validateLabel(String label) {
    if (label.trim().isEmpty) {
      throw const DomainException('Timer label cannot be empty');
    }
    if (label.length > _maxLabelLength) {
      throw DomainException(
        'Timer label cannot exceed $_maxLabelLength characters',
      );
    }
    return label.trim();
  }

  /// Validates timer duration
  static Duration _validateDuration(Duration duration) {
    if (duration.inSeconds < _minDurationSeconds) {
      throw DomainException(
        'Timer duration must be at least $_minDurationSeconds second',
      );
    }
    if (duration.inMinutes > _maxDurationMinutes) {
      throw DomainException(
        'Timer duration cannot exceed $_maxDurationMinutes minutes',
      );
    }
    return duration;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KitchenTimer &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'KitchenTimer(id: $_id, label: $_label, status: $_status, remaining: $actualRemainingTime)';
}

/// Production schedule statuses
enum ProductionStatus {
  /// Schedule is planned but not started
  planned,

  /// Production is in progress
  inProgress,

  /// Production is paused
  paused,

  /// Production is completed
  completed,

  /// Production was cancelled
  cancelled,

  /// Production is behind schedule
  behindSchedule,

  /// Production is ahead of schedule
  aheadOfSchedule,
}

/// Production item types
enum ProductionItemType {
  /// Recipe preparation
  recipe,

  /// Inventory preparation
  inventoryPrep,

  /// Cleaning task
  cleaning,

  /// Equipment maintenance
  maintenance,

  /// Stock receiving
  receiving,

  /// Catering preparation
  catering,
}

/// Production schedule item
class ProductionScheduleItem {
  final UserId _id;
  final ProductionItemType _type;
  final String _description;
  final UserId? _recipeId;
  final UserId? _inventoryItemId;
  final int _quantity;
  final Duration _estimatedDuration;
  final Duration? _actualDuration;
  final UserId? _assignedStationId;
  final UserId? _assignedUserId;
  final Time _scheduledStartTime;
  final Time? _actualStartTime;
  final Time? _completedTime;
  final ProductionStatus _status;
  final int _priority;
  final List<String> _dependencies;

  /// Creates a ProductionScheduleItem
  ProductionScheduleItem({
    required UserId id,
    required ProductionItemType type,
    required String description,
    UserId? recipeId,
    UserId? inventoryItemId,
    required int quantity,
    required Duration estimatedDuration,
    Duration? actualDuration,
    UserId? assignedStationId,
    UserId? assignedUserId,
    required Time scheduledStartTime,
    Time? actualStartTime,
    Time? completedTime,
    ProductionStatus status = ProductionStatus.planned,
    int priority = 0,
    List<String>? dependencies,
  }) : _id = id,
       _type = type,
       _description = description,
       _recipeId = recipeId,
       _inventoryItemId = inventoryItemId,
       _quantity = quantity,
       _estimatedDuration = estimatedDuration,
       _actualDuration = actualDuration,
       _assignedStationId = assignedStationId,
       _assignedUserId = assignedUserId,
       _scheduledStartTime = scheduledStartTime,
       _actualStartTime = actualStartTime,
       _completedTime = completedTime,
       _status = status,
       _priority = priority,
       _dependencies = List.unmodifiable(dependencies ?? []);

  /// Item ID
  UserId get id => _id;

  /// Production item type
  ProductionItemType get type => _type;

  /// Description of the production task
  String get description => _description;

  /// Associated recipe ID
  UserId? get recipeId => _recipeId;

  /// Associated inventory item ID
  UserId? get inventoryItemId => _inventoryItemId;

  /// Quantity to produce
  int get quantity => _quantity;

  /// Estimated duration for completion
  Duration get estimatedDuration => _estimatedDuration;

  /// Actual duration taken
  Duration? get actualDuration => _actualDuration;

  /// Assigned station ID
  UserId? get assignedStationId => _assignedStationId;

  /// Assigned user ID
  UserId? get assignedUserId => _assignedUserId;

  /// Scheduled start time
  Time get scheduledStartTime => _scheduledStartTime;

  /// Actual start time
  Time? get actualStartTime => _actualStartTime;

  /// Completion time
  Time? get completedTime => _completedTime;

  /// Current status
  ProductionStatus get status => _status;

  /// Priority (lower number = higher priority)
  int get priority => _priority;

  /// Task dependencies
  List<String> get dependencies => _dependencies;

  /// Business rule: Check if item is overdue
  bool get isOverdue {
    if (_status == ProductionStatus.completed) return false;
    final expectedEnd = _scheduledStartTime.add(_estimatedDuration);
    return Time.now().isAfter(expectedEnd);
  }

  /// Business rule: Check if item is ready to start
  bool get isReadyToStart {
    return _status == ProductionStatus.planned &&
        Time.now().isAfterOrAt(_scheduledStartTime);
  }

  /// Business rule: Calculate completion percentage
  double get completionPercentage {
    if (_status == ProductionStatus.completed) return 100.0;
    if (_actualStartTime == null) return 0.0;

    final elapsed = Time.now().difference(_actualStartTime);
    final percentage =
        (elapsed.inMilliseconds / _estimatedDuration.inMilliseconds) * 100;
    return percentage > 100.0 ? 100.0 : percentage;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionScheduleItem &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'ProductionScheduleItem(id: $_id, description: $_description, status: $_status)';
}

/// Production schedule entity for managing kitchen production planning
class ProductionSchedule {
  final UserId _id;
  final String _name;
  final Time _scheduleDate;
  final Time _startTime;
  final Time _endTime;
  final List<ProductionScheduleItem> _items;
  final ProductionStatus _overallStatus;
  final UserId _createdBy;
  final Time _createdAt;
  final Time _updatedAt;

  /// Creates a ProductionSchedule
  ProductionSchedule({
    required UserId id,
    required String name,
    required Time scheduleDate,
    required Time startTime,
    required Time endTime,
    List<ProductionScheduleItem>? items,
    ProductionStatus overallStatus = ProductionStatus.planned,
    required UserId createdBy,
    required Time createdAt,
    Time? updatedAt,
  }) : _id = id,
       _name = name,
       _scheduleDate = scheduleDate,
       _startTime = startTime,
       _endTime = endTime,
       _items = List.unmodifiable(items ?? []),
       _overallStatus = overallStatus,
       _createdBy = createdBy,
       _createdAt = createdAt,
       _updatedAt = updatedAt ?? createdAt;

  /// Schedule ID
  UserId get id => _id;

  /// Schedule name
  String get name => _name;

  /// Schedule date
  Time get scheduleDate => _scheduleDate;

  /// Schedule start time
  Time get startTime => _startTime;

  /// Schedule end time
  Time get endTime => _endTime;

  /// Production items
  List<ProductionScheduleItem> get items => _items;

  /// Overall schedule status
  ProductionStatus get overallStatus => _overallStatus;

  /// User who created the schedule
  UserId get createdBy => _createdBy;

  /// When schedule was created
  Time get createdAt => _createdAt;

  /// When schedule was last updated
  Time get updatedAt => _updatedAt;

  /// Business rule: Get total estimated duration
  Duration get totalEstimatedDuration {
    return _items.fold(
      Duration.zero,
      (total, item) => total + item.estimatedDuration,
    );
  }

  /// Business rule: Get completion percentage
  double get completionPercentage {
    if (_items.isEmpty) return 100.0;
    final completedItems = _items
        .where((item) => item.status == ProductionStatus.completed)
        .length;
    return (completedItems / _items.length) * 100;
  }

  /// Business rule: Check if schedule is on time
  bool get isOnTime {
    final overdueItems = _items.where((item) => item.isOverdue).length;
    return overdueItems == 0;
  }

  /// Business rule: Get items by status
  List<ProductionScheduleItem> getItemsByStatus(ProductionStatus status) {
    return _items.where((item) => item.status == status).toList();
  }

  /// Business rule: Get overdue items
  List<ProductionScheduleItem> get overdueItems {
    return _items.where((item) => item.isOverdue).toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionSchedule &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'ProductionSchedule(id: $_id, name: $_name, items: ${_items.length})';
}
