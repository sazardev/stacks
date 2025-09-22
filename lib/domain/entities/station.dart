import '../value_objects/user_id.dart';
import '../value_objects/time.dart';
import '../exceptions/domain_exception.dart';

/// Station types available in the kitchen
enum StationType { grill, prep, fryer, salad, dessert, beverage }

/// Station status in the kitchen workflow
enum StationStatus { available, busy, maintenance, offline }

/// Station entity representing a kitchen workstation
class Station {
  static const int _maxNameLength = 100;

  final UserId _id;
  final String _name;
  final int _capacity;
  final String? _location;
  final StationType _stationType;
  final StationStatus _status;
  final bool _isActive;
  final int _currentWorkload;
  final List<UserId> _assignedStaff;
  final List<String> _currentOrders;
  final Time _createdAt;

  /// Creates a Station with the specified properties
  Station({
    required UserId id,
    required String name,
    required int capacity,
    String? location,
    required StationType stationType,
    StationStatus status = StationStatus.available,
    bool isActive = true,
    int currentWorkload = 0,
    List<UserId>? assignedStaff,
    List<String>? currentOrders,
    required Time createdAt,
  }) : _id = id,
       _name = _validateName(name),
       _capacity = _validateCapacity(capacity),
       _location = location,
       _stationType = stationType,
       _status = status,
       _isActive = isActive,
       _currentWorkload = _validateWorkload(currentWorkload, capacity),
       _assignedStaff = List.unmodifiable(assignedStaff ?? []),
       _currentOrders = List.unmodifiable(currentOrders ?? []),
       _createdAt = createdAt;

  /// Station ID
  UserId get id => _id;

  /// Station name
  String get name => _name;

  /// Maximum capacity of orders the station can handle
  int get capacity => _capacity;

  /// Physical location of the station
  String? get location => _location;

  /// Type of station (grill, prep, etc.)
  StationType get stationType => _stationType;

  /// Current status of the station
  StationStatus get status => _status;

  /// Whether the station is active
  bool get isActive => _isActive;

  /// Current workload (number of orders being processed)
  int get currentWorkload => _currentWorkload;

  /// Staff members assigned to this station
  List<UserId> get assignedStaff => _assignedStaff;

  /// Current orders being processed at this station
  List<String> get currentOrders => _currentOrders;

  /// When the station was created
  Time get createdAt => _createdAt;

  /// Validates station name
  static String _validateName(String name) {
    if (name.trim().isEmpty) {
      throw const DomainException('Station name cannot be empty');
    }

    if (name.length > _maxNameLength) {
      throw DomainException(
        'Station name cannot exceed $_maxNameLength characters',
      );
    }

    return name.trim();
  }

  /// Validates station capacity
  static int _validateCapacity(int capacity) {
    if (capacity <= 0) {
      throw const DomainException('Station capacity must be greater than zero');
    }

    return capacity;
  }

  /// Validates workload against capacity
  static int _validateWorkload(int workload, int capacity) {
    if (workload < 0) {
      throw const DomainException('Station workload cannot be negative');
    }

    if (workload > capacity) {
      throw const DomainException('Station workload cannot exceed capacity');
    }

    return workload;
  }

  // Station type checkers
  bool get isGrillStation => _stationType == StationType.grill;
  bool get isPrepStation => _stationType == StationType.prep;
  bool get isFryerStation => _stationType == StationType.fryer;
  bool get isSaladStation => _stationType == StationType.salad;
  bool get isDessertStation => _stationType == StationType.dessert;
  bool get isBeverageStation => _stationType == StationType.beverage;

  // Status checkers
  bool get isAvailable => _status == StationStatus.available;
  bool get isBusy => _status == StationStatus.busy;
  bool get isInMaintenance => _status == StationStatus.maintenance;
  bool get isOffline => _status == StationStatus.offline;

  /// Whether the station is at maximum capacity
  bool get isAtCapacity => _currentWorkload >= _capacity;

  /// Whether the station has available capacity
  bool get hasAvailableCapacity => _currentWorkload < _capacity;

  /// Available capacity remaining
  int get availableCapacity => _capacity - _currentWorkload;

  /// Workload as a percentage of capacity
  double get workloadPercentage => (_currentWorkload / _capacity) * 100;

  /// Whether the station can accept new orders
  bool get canAcceptOrder =>
      _isActive &&
      (_status == StationStatus.available || _status == StationStatus.busy) &&
      hasAvailableCapacity;

  /// Activates the station
  Station activate() {
    return Station(
      id: _id,
      name: _name,
      capacity: _capacity,
      location: _location,
      stationType: _stationType,
      status: StationStatus.available,
      isActive: true,
      currentWorkload: _currentWorkload,
      assignedStaff: _assignedStaff,
      currentOrders: _currentOrders,
      createdAt: _createdAt,
    );
  }

  /// Deactivates the station
  Station deactivate() {
    return Station(
      id: _id,
      name: _name,
      capacity: _capacity,
      location: _location,
      stationType: _stationType,
      status: StationStatus.offline,
      isActive: false,
      currentWorkload: _currentWorkload,
      assignedStaff: _assignedStaff,
      currentOrders: _currentOrders,
      createdAt: _createdAt,
    );
  }

  /// Sets the station to maintenance mode
  Station setMaintenance() {
    return Station(
      id: _id,
      name: _name,
      capacity: _capacity,
      location: _location,
      stationType: _stationType,
      status: StationStatus.maintenance,
      isActive: _isActive,
      currentWorkload: _currentWorkload,
      assignedStaff: _assignedStaff,
      currentOrders: _currentOrders,
      createdAt: _createdAt,
    );
  }

  /// Sets the station to busy status
  Station setBusy() {
    return Station(
      id: _id,
      name: _name,
      capacity: _capacity,
      location: _location,
      stationType: _stationType,
      status: StationStatus.busy,
      isActive: _isActive,
      currentWorkload: _currentWorkload,
      assignedStaff: _assignedStaff,
      currentOrders: _currentOrders,
      createdAt: _createdAt,
    );
  }

  /// Sets the station to available status
  Station setAvailable() {
    return Station(
      id: _id,
      name: _name,
      capacity: _capacity,
      location: _location,
      stationType: _stationType,
      status: StationStatus.available,
      isActive: _isActive,
      currentWorkload: _currentWorkload,
      assignedStaff: _assignedStaff,
      currentOrders: _currentOrders,
      createdAt: _createdAt,
    );
  }

  /// Assigns staff to the station
  Station assignStaff(UserId staffId) {
    if (_assignedStaff.contains(staffId)) {
      throw DomainException(
        'Staff ${staffId.value} is already assigned to this station',
      );
    }

    final newAssignedStaff = List<UserId>.from(_assignedStaff)..add(staffId);

    return Station(
      id: _id,
      name: _name,
      capacity: _capacity,
      location: _location,
      stationType: _stationType,
      status: _status,
      isActive: _isActive,
      currentWorkload: _currentWorkload,
      assignedStaff: newAssignedStaff,
      currentOrders: _currentOrders,
      createdAt: _createdAt,
    );
  }

  /// Unassigns staff from the station
  Station unassignStaff(UserId staffId) {
    if (!_assignedStaff.contains(staffId)) {
      throw DomainException(
        'Staff ${staffId.value} is not assigned to this station',
      );
    }

    final newAssignedStaff = List<UserId>.from(_assignedStaff)..remove(staffId);

    return Station(
      id: _id,
      name: _name,
      capacity: _capacity,
      location: _location,
      stationType: _stationType,
      status: _status,
      isActive: _isActive,
      currentWorkload: _currentWorkload,
      assignedStaff: newAssignedStaff,
      currentOrders: _currentOrders,
      createdAt: _createdAt,
    );
  }

  /// Updates the current workload
  Station updateWorkload(int newWorkload) {
    _validateWorkload(newWorkload, _capacity);

    return Station(
      id: _id,
      name: _name,
      capacity: _capacity,
      location: _location,
      stationType: _stationType,
      status: _status,
      isActive: _isActive,
      currentWorkload: newWorkload,
      assignedStaff: _assignedStaff,
      currentOrders: _currentOrders,
      createdAt: _createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Station && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() {
    return 'Station(id: ${_id.value}, name: $_name, type: ${_stationType.name}, '
        'status: ${_status.name}, capacity: $_capacity, workload: $_currentWorkload)';
  }
}
