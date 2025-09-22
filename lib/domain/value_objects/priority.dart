import '../exceptions/domain_exception.dart';

/// Priority value object representing the urgency level of orders
class Priority {
  static const int low = 1;
  static const int medium = 2;
  static const int high = 3;
  static const int urgent = 4;
  static const int critical = 5;

  static const Map<int, String> _priorityNames = {
    low: 'Low',
    medium: 'Medium',
    high: 'High',
    urgent: 'Urgent',
    critical: 'Critical',
  };

  static const Map<int, int> _escalationTimeouts = {
    low: 60, // 60 minutes
    medium: 30, // 30 minutes
    high: 15, // 15 minutes
    urgent: 5, // 5 minutes
    critical: 2, // 2 minutes
  };

  static const Map<int, int> _maxPreparationTimes = {
    low: 45, // 45 minutes
    medium: 30, // 30 minutes
    high: 20, // 20 minutes
    urgent: 10, // 10 minutes
    critical: 5, // 5 minutes
  };

  final int _level;

  /// Creates a Priority with the specified level
  ///
  /// [level] must be between 1 (low) and 5 (critical)
  Priority(int level) : _level = _validateLevel(level);

  /// Creates a low priority (level 1)
  Priority.createLow() : _level = low;

  /// Creates a medium priority (level 2)
  Priority.createMedium() : _level = medium;

  /// Creates a high priority (level 3)
  Priority.createHigh() : _level = high;

  /// Creates an urgent priority (level 4)
  Priority.createUrgent() : _level = urgent;

  /// Creates a critical priority (level 5)
  Priority.createCritical() : _level = critical;

  /// The priority level (1-5)
  int get level => _level;

  /// The human-readable name of the priority
  String get name => _priorityNames[_level]!;

  /// Whether this priority is considered high priority (3 or above)
  bool get isHighPriority => _level >= high;

  /// Whether this priority requires immediate attention (4 or above)
  bool get requiresImmediateAttention => _level >= urgent;

  /// The escalation timeout in minutes for this priority level
  int get escalationTimeoutMinutes => _escalationTimeouts[_level]!;

  /// The maximum preparation time in minutes for this priority level
  int get maxPreparationTimeMinutes => _maxPreparationTimes[_level]!;

  /// Whether this priority can be escalated to a higher level
  bool get canEscalate => _level < critical;

  /// Validates the priority level
  static int _validateLevel(int level) {
    if (level < low || level > critical) {
      throw ValueObjectException(
        'Priority level must be between $low and $critical, got: $level',
      );
    }
    return level;
  }

  /// Checks if this priority is higher than another
  bool isHigherThan(Priority other) {
    return _level > other._level;
  }

  /// Checks if this priority is lower than another
  bool isLowerThan(Priority other) {
    return _level < other._level;
  }

  /// Checks if this priority is equal to another
  bool isEqualTo(Priority other) {
    return _level == other._level;
  }

  /// Escalates this priority to the next higher level
  /// Returns the same priority if already at maximum level
  Priority escalate() {
    if (!canEscalate) {
      return this; // Already at maximum level
    }
    return Priority(_level + 1);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Priority &&
          runtimeType == other.runtimeType &&
          _level == other._level;

  @override
  int get hashCode => _level.hashCode;

  @override
  String toString() {
    return 'Priority: $name ($_level)';
  }
}
