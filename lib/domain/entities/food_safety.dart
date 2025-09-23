import '../value_objects/user_id.dart';
import '../value_objects/time.dart';
import '../exceptions/domain_exception.dart';

/// Temperature measurement locations
enum TemperatureLocation {
  /// Walk-in cooler
  walkInCooler,

  /// Walk-in freezer
  walkInFreezer,

  /// Prep area refrigerator
  prepRefrigerator,

  /// Display case
  displayCase,

  /// Grill surface
  grillSurface,

  /// Fryer oil
  fryerOil,

  /// Hot holding unit
  hotHolding,

  /// Cold holding unit
  coldHolding,

  /// Dishwasher sanitizer
  dishwasherSanitizer,

  /// Hand wash sink
  handWashSink,

  /// Food internal temperature
  foodInternal,

  /// Ambient room temperature
  ambientRoom,
}

/// Temperature measurement units
enum TemperatureUnit {
  /// Fahrenheit
  fahrenheit,

  /// Celsius
  celsius,
}

/// Food safety violation severity levels
enum ViolationSeverity {
  /// Minor violation that needs attention
  minor,

  /// Major violation requiring immediate action
  major,

  /// Critical violation requiring immediate correction
  critical,

  /// Emergency situation requiring immediate closure
  emergency,
}

/// Food safety violation types
enum ViolationType {
  /// Temperature out of safe range
  temperatureViolation,

  /// Time limit exceeded
  timeViolation,

  /// Cross-contamination risk
  crossContamination,

  /// Poor hygiene practices
  hygieneBreach,

  /// Equipment malfunction
  equipmentFailure,

  /// Allergen contamination
  allergenContamination,

  /// Expired product usage
  expiredProduct,

  /// Improper storage
  improperStorage,

  /// Cleaning violation
  cleaningViolation,

  /// Documentation missing
  documentationMissing,
}

/// HACCP critical control point types
enum CCPType {
  /// Receiving temperature check
  receiving,

  /// Storage temperature monitoring
  storage,

  /// Cooking temperature verification
  cooking,

  /// Hot holding temperature
  hotHolding,

  /// Cold holding temperature
  coldHolding,

  /// Cooling process monitoring
  cooling,

  /// Reheating temperature check
  reheating,

  /// Sanitizer concentration
  sanitizerConcentration,

  /// Hand washing compliance
  handWashing,

  /// Cross-contamination prevention
  crossContaminationPrevention,
}

/// Corrective action status
enum CorrectiveActionStatus {
  /// Action is pending
  pending,

  /// Action is in progress
  inProgress,

  /// Action is completed
  completed,

  /// Action was not effective
  ineffective,

  /// Action requires escalation
  escalated,
}

/// Temperature log entry for HACCP compliance
class TemperatureLog {
  static const double _minTemperatureF = -20.0; // -20°F
  static const double _maxTemperatureF = 500.0; // 500°F
  static const int _maxNotesLength = 500;

  final UserId _id;
  final TemperatureLocation _location;
  final double _temperature;
  final TemperatureUnit _unit;
  final double? _targetTemperature;
  final double? _minSafeTemperature;
  final double? _maxSafeTemperature;
  final bool _isWithinSafeRange;
  final UserId _recordedBy;
  final Time _recordedAt;
  final String? _equipmentId;
  final String? _notes;
  final bool _requiresCorrectiveAction;
  final String? _correctiveActionTaken;

  /// Creates a TemperatureLog entry
  TemperatureLog({
    required UserId id,
    required TemperatureLocation location,
    required double temperature,
    required TemperatureUnit unit,
    double? targetTemperature,
    double? minSafeTemperature,
    double? maxSafeTemperature,
    required UserId recordedBy,
    required Time recordedAt,
    String? equipmentId,
    String? notes,
    String? correctiveActionTaken,
  }) : _id = id,
       _location = location,
       _temperature = _validateTemperature(temperature, unit),
       _unit = unit,
       _targetTemperature = targetTemperature,
       _minSafeTemperature = minSafeTemperature,
       _maxSafeTemperature = maxSafeTemperature,
       _isWithinSafeRange = _checkSafeRange(
         temperature,
         minSafeTemperature,
         maxSafeTemperature,
       ),
       _recordedBy = recordedBy,
       _recordedAt = recordedAt,
       _equipmentId = equipmentId,
       _notes = _validateNotes(notes),
       _requiresCorrectiveAction = !_checkSafeRange(
         temperature,
         minSafeTemperature,
         maxSafeTemperature,
       ),
       _correctiveActionTaken = correctiveActionTaken;

  /// Log entry ID
  UserId get id => _id;

  /// Temperature location
  TemperatureLocation get location => _location;

  /// Recorded temperature
  double get temperature => _temperature;

  /// Temperature unit
  TemperatureUnit get unit => _unit;

  /// Target temperature
  double? get targetTemperature => _targetTemperature;

  /// Minimum safe temperature
  double? get minSafeTemperature => _minSafeTemperature;

  /// Maximum safe temperature
  double? get maxSafeTemperature => _maxSafeTemperature;

  /// Whether temperature is within safe range
  bool get isWithinSafeRange => _isWithinSafeRange;

  /// User who recorded the temperature
  UserId get recordedBy => _recordedBy;

  /// When temperature was recorded
  Time get recordedAt => _recordedAt;

  /// Equipment identifier
  String? get equipmentId => _equipmentId;

  /// Additional notes
  String? get notes => _notes;

  /// Whether corrective action is required
  bool get requiresCorrectiveAction => _requiresCorrectiveAction;

  /// Corrective action taken
  String? get correctiveActionTaken => _correctiveActionTaken;

  /// Business rule: Get temperature in Fahrenheit
  double get temperatureInFahrenheit {
    if (_unit == TemperatureUnit.fahrenheit) return _temperature;
    return (_temperature * 9 / 5) + 32;
  }

  /// Business rule: Get temperature in Celsius
  double get temperatureInCelsius {
    if (_unit == TemperatureUnit.celsius) return _temperature;
    return (_temperature - 32) * 5 / 9;
  }

  /// Business rule: Calculate deviation from target
  double? get deviationFromTarget {
    if (_targetTemperature == null) return null;
    return _temperature - _targetTemperature;
  }

  /// Business rule: Get violation severity
  ViolationSeverity? get violationSeverity {
    if (_isWithinSafeRange) return null;

    final deviation = deviationFromTarget?.abs();
    if (deviation == null) return ViolationSeverity.major;

    if (deviation > 10) return ViolationSeverity.critical;
    if (deviation > 5) return ViolationSeverity.major;
    return ViolationSeverity.minor;
  }

  /// Validates temperature value
  static double _validateTemperature(double temperature, TemperatureUnit unit) {
    // Convert to Fahrenheit for validation
    final tempF = unit == TemperatureUnit.fahrenheit
        ? temperature
        : (temperature * 9 / 5) + 32;

    if (tempF < _minTemperatureF || tempF > _maxTemperatureF) {
      throw DomainException(
        'Temperature must be between $_minTemperatureF°F and $_maxTemperatureF°F',
      );
    }
    return temperature;
  }

  /// Checks if temperature is within safe range
  static bool _checkSafeRange(
    double temperature,
    double? minSafe,
    double? maxSafe,
  ) {
    if (minSafe != null && temperature < minSafe) return false;
    if (maxSafe != null && temperature > maxSafe) return false;
    return true;
  }

  /// Validates notes
  static String? _validateNotes(String? notes) {
    if (notes == null) return null;
    if (notes.length > _maxNotesLength) {
      throw DomainException('Notes cannot exceed $_maxNotesLength characters');
    }
    return notes.trim();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemperatureLog &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'TemperatureLog(location: $_location, temp: $_temperature°${_unit.name}, safe: $_isWithinSafeRange)';
}

/// Food safety violation tracking
class FoodSafetyViolation {
  static const int _maxDescriptionLength = 1000;

  final UserId _id;
  final ViolationType _type;
  final ViolationSeverity _severity;
  final String _description;
  final TemperatureLocation? _location;
  final UserId? _reportedBy;
  final UserId? _assignedTo;
  final Time _reportedAt;
  final Time? _resolvedAt;
  final bool _isResolved;
  final List<String> _correctiveActions;
  final String? _rootCause;
  final String? _preventiveAction;
  final double? _temperatureReading;
  final UserId? _orderId;
  final UserId? _inventoryItemId;

  /// Creates a FoodSafetyViolation
  FoodSafetyViolation({
    required UserId id,
    required ViolationType type,
    required ViolationSeverity severity,
    required String description,
    TemperatureLocation? location,
    UserId? reportedBy,
    UserId? assignedTo,
    required Time reportedAt,
    Time? resolvedAt,
    bool isResolved = false,
    List<String>? correctiveActions,
    String? rootCause,
    String? preventiveAction,
    double? temperatureReading,
    UserId? orderId,
    UserId? inventoryItemId,
  }) : _id = id,
       _type = type,
       _severity = severity,
       _description = _validateDescription(description),
       _location = location,
       _reportedBy = reportedBy,
       _assignedTo = assignedTo,
       _reportedAt = reportedAt,
       _resolvedAt = resolvedAt,
       _isResolved = isResolved,
       _correctiveActions = List.unmodifiable(correctiveActions ?? []),
       _rootCause = rootCause,
       _preventiveAction = preventiveAction,
       _temperatureReading = temperatureReading,
       _orderId = orderId,
       _inventoryItemId = inventoryItemId;

  /// Violation ID
  UserId get id => _id;

  /// Violation type
  ViolationType get type => _type;

  /// Violation severity
  ViolationSeverity get severity => _severity;

  /// Violation description
  String get description => _description;

  /// Location of violation
  TemperatureLocation? get location => _location;

  /// User who reported the violation
  UserId? get reportedBy => _reportedBy;

  /// User assigned to resolve the violation
  UserId? get assignedTo => _assignedTo;

  /// When violation was reported
  Time get reportedAt => _reportedAt;

  /// When violation was resolved
  Time? get resolvedAt => _resolvedAt;

  /// Whether violation is resolved
  bool get isResolved => _isResolved;

  /// Corrective actions taken
  List<String> get correctiveActions => _correctiveActions;

  /// Root cause analysis
  String? get rootCause => _rootCause;

  /// Preventive action to avoid recurrence
  String? get preventiveAction => _preventiveAction;

  /// Temperature reading (if applicable)
  double? get temperatureReading => _temperatureReading;

  /// Associated order ID
  UserId? get orderId => _orderId;

  /// Associated inventory item ID
  UserId? get inventoryItemId => _inventoryItemId;

  /// Business rule: Check if violation is overdue
  bool get isOverdue {
    if (_isResolved) return false;

    final maxResolutionTime = switch (_severity) {
      ViolationSeverity.emergency => Duration(minutes: 15),
      ViolationSeverity.critical => Duration(hours: 1),
      ViolationSeverity.major => Duration(hours: 4),
      ViolationSeverity.minor => Duration(hours: 24),
    };

    final deadline = _reportedAt.add(maxResolutionTime);
    return Time.now().isAfter(deadline);
  }

  /// Business rule: Get time since reported
  Duration get timeSinceReported => Time.now().difference(_reportedAt);

  /// Business rule: Get resolution time (if resolved)
  Duration? get resolutionTime {
    if (!_isResolved || _resolvedAt == null) return null;
    return _resolvedAt.difference(_reportedAt);
  }

  /// Resolves the violation
  FoodSafetyViolation resolve({
    required String rootCause,
    required String preventiveAction,
    List<String>? additionalActions,
  }) {
    if (_isResolved) {
      throw const DomainException('Violation is already resolved');
    }

    final allActions = List<String>.from([
      ..._correctiveActions,
      ...additionalActions ?? [],
    ]);

    return FoodSafetyViolation(
      id: _id,
      type: _type,
      severity: _severity,
      description: _description,
      location: _location,
      reportedBy: _reportedBy,
      assignedTo: _assignedTo,
      reportedAt: _reportedAt,
      resolvedAt: Time.now(),
      isResolved: true,
      correctiveActions: allActions,
      rootCause: rootCause,
      preventiveAction: preventiveAction,
      temperatureReading: _temperatureReading,
      orderId: _orderId,
      inventoryItemId: _inventoryItemId,
    );
  }

  /// Validates description
  static String _validateDescription(String description) {
    if (description.trim().isEmpty) {
      throw const DomainException('Violation description cannot be empty');
    }
    if (description.length > _maxDescriptionLength) {
      throw DomainException(
        'Description cannot exceed $_maxDescriptionLength characters',
      );
    }
    return description.trim();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodSafetyViolation &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'FoodSafetyViolation(type: $_type, severity: $_severity, resolved: $_isResolved)';
}

/// HACCP critical control point monitoring
class HACCPControlPoint {
  static const int _maxNameLength = 200;
  static const int _maxProcedureLength = 1000;

  final UserId _id;
  final CCPType _type;
  final String _name;
  final String _monitoringProcedure;
  final double? _criticalLimit;
  final TemperatureUnit? _temperatureUnit;
  final Duration _monitoringFrequency;
  final Time? _lastMonitored;
  final bool _isActive;
  final List<String> _correctiveActions;
  final UserId _responsibleUser;
  final Time _createdAt;

  /// Creates a HACCPControlPoint
  HACCPControlPoint({
    required UserId id,
    required CCPType type,
    required String name,
    required String monitoringProcedure,
    double? criticalLimit,
    TemperatureUnit? temperatureUnit,
    required Duration monitoringFrequency,
    Time? lastMonitored,
    bool isActive = true,
    List<String>? correctiveActions,
    required UserId responsibleUser,
    required Time createdAt,
  }) : _id = id,
       _type = type,
       _name = _validateName(name),
       _monitoringProcedure = _validateProcedure(monitoringProcedure),
       _criticalLimit = criticalLimit,
       _temperatureUnit = temperatureUnit,
       _monitoringFrequency = monitoringFrequency,
       _lastMonitored = lastMonitored,
       _isActive = isActive,
       _correctiveActions = List.unmodifiable(correctiveActions ?? []),
       _responsibleUser = responsibleUser,
       _createdAt = createdAt;

  /// Control point ID
  UserId get id => _id;

  /// Control point type
  CCPType get type => _type;

  /// Control point name
  String get name => _name;

  /// Monitoring procedure
  String get monitoringProcedure => _monitoringProcedure;

  /// Critical limit value
  double? get criticalLimit => _criticalLimit;

  /// Temperature unit for critical limit
  TemperatureUnit? get temperatureUnit => _temperatureUnit;

  /// How often monitoring should occur
  Duration get monitoringFrequency => _monitoringFrequency;

  /// When last monitored
  Time? get lastMonitored => _lastMonitored;

  /// Whether control point is active
  bool get isActive => _isActive;

  /// Standard corrective actions
  List<String> get correctiveActions => _correctiveActions;

  /// User responsible for monitoring
  UserId get responsibleUser => _responsibleUser;

  /// When control point was created
  Time get createdAt => _createdAt;

  /// Business rule: Check if monitoring is overdue
  bool get isMonitoringOverdue {
    if (!_isActive || _lastMonitored == null) return true;
    final nextMonitoring = _lastMonitored.add(_monitoringFrequency);
    return Time.now().isAfter(nextMonitoring);
  }

  /// Business rule: Get time until next monitoring
  Duration? get timeUntilNextMonitoring {
    if (!_isActive || _lastMonitored == null) return Duration.zero;
    final nextMonitoring = _lastMonitored.add(_monitoringFrequency);
    final remaining = nextMonitoring.difference(Time.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Updates last monitored time
  HACCPControlPoint recordMonitoring() {
    return HACCPControlPoint(
      id: _id,
      type: _type,
      name: _name,
      monitoringProcedure: _monitoringProcedure,
      criticalLimit: _criticalLimit,
      temperatureUnit: _temperatureUnit,
      monitoringFrequency: _monitoringFrequency,
      lastMonitored: Time.now(),
      isActive: _isActive,
      correctiveActions: _correctiveActions,
      responsibleUser: _responsibleUser,
      createdAt: _createdAt,
    );
  }

  /// Validates name
  static String _validateName(String name) {
    if (name.trim().isEmpty) {
      throw const DomainException('Control point name cannot be empty');
    }
    if (name.length > _maxNameLength) {
      throw DomainException('Name cannot exceed $_maxNameLength characters');
    }
    return name.trim();
  }

  /// Validates procedure
  static String _validateProcedure(String procedure) {
    if (procedure.trim().isEmpty) {
      throw const DomainException('Monitoring procedure cannot be empty');
    }
    if (procedure.length > _maxProcedureLength) {
      throw DomainException(
        'Procedure cannot exceed $_maxProcedureLength characters',
      );
    }
    return procedure.trim();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HACCPControlPoint &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'HACCPControlPoint(type: $_type, name: $_name, active: $_isActive)';
}

/// Food safety audit entry
class FoodSafetyAudit {
  final UserId _id;
  final String _auditName;
  final Time _auditDate;
  final UserId _auditor;
  final List<HACCPControlPoint> _controlPoints;
  final List<TemperatureLog> _temperatureLogs;
  final List<FoodSafetyViolation> _violations;
  final double _overallScore;
  final bool _isPassed;
  final String? _notes;
  final List<String> _recommendations;

  /// Creates a FoodSafetyAudit
  FoodSafetyAudit({
    required UserId id,
    required String auditName,
    required Time auditDate,
    required UserId auditor,
    List<HACCPControlPoint>? controlPoints,
    List<TemperatureLog>? temperatureLogs,
    List<FoodSafetyViolation>? violations,
    required double overallScore,
    required bool isPassed,
    String? notes,
    List<String>? recommendations,
  }) : _id = id,
       _auditName = auditName,
       _auditDate = auditDate,
       _auditor = auditor,
       _controlPoints = List.unmodifiable(controlPoints ?? []),
       _temperatureLogs = List.unmodifiable(temperatureLogs ?? []),
       _violations = List.unmodifiable(violations ?? []),
       _overallScore = overallScore,
       _isPassed = isPassed,
       _notes = notes,
       _recommendations = List.unmodifiable(recommendations ?? []);

  /// Audit ID
  UserId get id => _id;

  /// Audit name
  String get auditName => _auditName;

  /// Audit date
  Time get auditDate => _auditDate;

  /// Auditor
  UserId get auditor => _auditor;

  /// Control points checked
  List<HACCPControlPoint> get controlPoints => _controlPoints;

  /// Temperature logs reviewed
  List<TemperatureLog> get temperatureLogs => _temperatureLogs;

  /// Violations found
  List<FoodSafetyViolation> get violations => _violations;

  /// Overall audit score (0-100)
  double get overallScore => _overallScore;

  /// Whether audit passed
  bool get isPassed => _isPassed;

  /// Audit notes
  String? get notes => _notes;

  /// Recommendations for improvement
  List<String> get recommendations => _recommendations;

  /// Business rule: Get critical violations count
  int get criticalViolationCount {
    return _violations
        .where((v) => v.severity == ViolationSeverity.critical)
        .length;
  }

  /// Business rule: Get temperature violations count
  int get temperatureViolationCount {
    return _violations
        .where((v) => v.type == ViolationType.temperatureViolation)
        .length;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodSafetyAudit &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'FoodSafetyAudit(name: $_auditName, score: $_overallScore, passed: $_isPassed)';
}
