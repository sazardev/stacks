import '../value_objects/user_id.dart';
import '../value_objects/time.dart';
import '../exceptions/domain_exception.dart';

/// Table status in the restaurant
enum TableStatus {
  /// Table is available for seating
  available,

  /// Table has been assigned but guests haven't arrived
  reserved,

  /// Guests are seated and dining
  occupied,

  /// Table needs cleaning
  needsCleaning,

  /// Table is being cleaned
  cleaning,

  /// Table is temporarily out of service
  outOfService,

  /// Table is closed for maintenance
  maintenance,
}

/// Table section types
enum TableSection {
  /// Main dining room
  mainDining,

  /// Bar area
  bar,

  /// Patio/outdoor seating
  patio,

  /// Private dining room
  privateDining,

  /// Counter seating
  counter,

  /// Booth section
  booth,

  /// Window seating
  window,

  /// VIP section
  vip,
}

/// Special table requirements
enum TableRequirement {
  /// Wheelchair accessible
  wheelchairAccessible,

  /// High chair available
  highChair,

  /// Booster seat available
  boosterSeat,

  /// Quiet area
  quiet,

  /// View of kitchen/entertainment
  view,

  /// Near restroom
  nearRestroom,

  /// Large party accommodation
  largeParty,

  /// Private/secluded
  private,
}

/// Table entity representing a dining table
class Table {
  static const int _maxTableNumberLength = 10;
  static const int _minCapacity = 1;
  static const int _maxCapacity = 20;

  final UserId _id;
  final String _tableNumber;
  final int _capacity;
  final TableSection _section;
  final TableStatus _status;
  final List<TableRequirement> _requirements;
  final UserId? _currentServerId;
  final UserId? _currentReservationId;
  final Time? _lastOccupiedAt;
  final Time? _lastCleanedAt;
  final bool _isActive;
  final double? _xPosition;
  final double? _yPosition;
  final String? _notes;
  final Time _createdAt;

  /// Creates a Table with the specified properties
  Table({
    required UserId id,
    required String tableNumber,
    required int capacity,
    required TableSection section,
    TableStatus status = TableStatus.available,
    List<TableRequirement>? requirements,
    UserId? currentServerId,
    UserId? currentReservationId,
    Time? lastOccupiedAt,
    Time? lastCleanedAt,
    bool isActive = true,
    double? xPosition,
    double? yPosition,
    String? notes,
    required Time createdAt,
  }) : _id = id,
       _tableNumber = _validateTableNumber(tableNumber),
       _capacity = _validateCapacity(capacity),
       _section = section,
       _status = status,
       _requirements = List.unmodifiable(requirements ?? []),
       _currentServerId = currentServerId,
       _currentReservationId = currentReservationId,
       _lastOccupiedAt = lastOccupiedAt,
       _lastCleanedAt = lastCleanedAt,
       _isActive = isActive,
       _xPosition = xPosition,
       _yPosition = yPosition,
       _notes = notes,
       _createdAt = createdAt;

  /// Table ID
  UserId get id => _id;

  /// Table number/identifier
  String get tableNumber => _tableNumber;

  /// Seating capacity
  int get capacity => _capacity;

  /// Table section
  TableSection get section => _section;

  /// Current table status
  TableStatus get status => _status;

  /// Special requirements
  List<TableRequirement> get requirements => _requirements;

  /// Current server assigned
  UserId? get currentServerId => _currentServerId;

  /// Current reservation ID
  UserId? get currentReservationId => _currentReservationId;

  /// When table was last occupied
  Time? get lastOccupiedAt => _lastOccupiedAt;

  /// When table was last cleaned
  Time? get lastCleanedAt => _lastCleanedAt;

  /// Whether table is active
  bool get isActive => _isActive;

  /// X position for floor plan
  double? get xPosition => _xPosition;

  /// Y position for floor plan
  double? get yPosition => _yPosition;

  /// Additional notes
  String? get notes => _notes;

  /// When table was created
  Time get createdAt => _createdAt;

  /// Business rule: Check if table is available for seating
  bool get isAvailableForSeating =>
      _status == TableStatus.available && _isActive;

  /// Business rule: Check if table needs cleaning
  bool get needsCleaning => _status == TableStatus.needsCleaning;

  /// Business rule: Check if table is occupied
  bool get isOccupied => _status == TableStatus.occupied;

  /// Business rule: Check if table has specific requirement
  bool hasRequirement(TableRequirement requirement) =>
      _requirements.contains(requirement);

  /// Business rule: Minutes since last cleaned
  int? get minutesSinceLastCleaned {
    if (_lastCleanedAt == null) return null;
    return Time.now().minutesSince(_lastCleanedAt);
  }

  /// Business rule: Check if table cleaning is overdue
  bool get isCleaningOverdue {
    if (_lastCleanedAt == null) return true;
    final minutes = minutesSinceLastCleaned;
    // Tables should be cleaned within 15 minutes after becoming available
    return minutes != null && minutes > 15;
  }

  /// Seats guests at the table
  Table seatGuests(UserId serverId, {UserId? reservationId}) {
    if (!isAvailableForSeating) {
      throw DomainException(
        'Cannot seat guests at table with status: $_status',
      );
    }

    return Table(
      id: _id,
      tableNumber: _tableNumber,
      capacity: _capacity,
      section: _section,
      status: TableStatus.occupied,
      requirements: _requirements,
      currentServerId: serverId,
      currentReservationId: reservationId,
      lastOccupiedAt: Time.now(),
      lastCleanedAt: _lastCleanedAt,
      isActive: _isActive,
      xPosition: _xPosition,
      yPosition: _yPosition,
      notes: _notes,
      createdAt: _createdAt,
    );
  }

  /// Clears the table when guests leave
  Table clearTable() {
    if (_status != TableStatus.occupied) {
      throw DomainException('Cannot clear table with status: $_status');
    }

    return Table(
      id: _id,
      tableNumber: _tableNumber,
      capacity: _capacity,
      section: _section,
      status: TableStatus.needsCleaning,
      requirements: _requirements,
      currentServerId: null,
      currentReservationId: null,
      lastOccupiedAt: _lastOccupiedAt,
      lastCleanedAt: _lastCleanedAt,
      isActive: _isActive,
      xPosition: _xPosition,
      yPosition: _yPosition,
      notes: _notes,
      createdAt: _createdAt,
    );
  }

  /// Marks table as cleaned
  Table markCleaned() {
    if (_status != TableStatus.needsCleaning &&
        _status != TableStatus.cleaning) {
      throw DomainException(
        'Cannot mark table as cleaned with status: $_status',
      );
    }

    return Table(
      id: _id,
      tableNumber: _tableNumber,
      capacity: _capacity,
      section: _section,
      status: TableStatus.available,
      requirements: _requirements,
      currentServerId: _currentServerId,
      currentReservationId: _currentReservationId,
      lastOccupiedAt: _lastOccupiedAt,
      lastCleanedAt: Time.now(),
      isActive: _isActive,
      xPosition: _xPosition,
      yPosition: _yPosition,
      notes: _notes,
      createdAt: _createdAt,
    );
  }

  /// Reserves the table
  Table reserve(UserId reservationId) {
    if (!isAvailableForSeating) {
      throw DomainException('Cannot reserve table with status: $_status');
    }

    return Table(
      id: _id,
      tableNumber: _tableNumber,
      capacity: _capacity,
      section: _section,
      status: TableStatus.reserved,
      requirements: _requirements,
      currentServerId: _currentServerId,
      currentReservationId: reservationId,
      lastOccupiedAt: _lastOccupiedAt,
      lastCleanedAt: _lastCleanedAt,
      isActive: _isActive,
      xPosition: _xPosition,
      yPosition: _yPosition,
      notes: _notes,
      createdAt: _createdAt,
    );
  }

  /// Validates table number
  static String _validateTableNumber(String tableNumber) {
    if (tableNumber.trim().isEmpty) {
      throw const DomainException('Table number cannot be empty');
    }
    if (tableNumber.length > _maxTableNumberLength) {
      throw DomainException(
        'Table number cannot exceed $_maxTableNumberLength characters',
      );
    }
    return tableNumber.trim();
  }

  /// Validates table capacity
  static int _validateCapacity(int capacity) {
    if (capacity < _minCapacity) {
      throw DomainException('Table capacity must be at least $_minCapacity');
    }
    if (capacity > _maxCapacity) {
      throw DomainException('Table capacity cannot exceed $_maxCapacity');
    }
    return capacity;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Table && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'Table(number: $_tableNumber, capacity: $_capacity, status: $_status)';
}

/// Customer dietary restrictions
enum DietaryRestriction {
  /// Vegetarian diet
  vegetarian,

  /// Vegan diet
  vegan,

  /// Gluten-free diet
  glutenFree,

  /// Dairy-free diet
  dairyFree,

  /// Nut allergy
  nutAllergy,

  /// Shellfish allergy
  shellfishAllergy,

  /// Egg allergy
  eggAllergy,

  /// Soy allergy
  soyAllergy,

  /// Diabetic-friendly
  diabetic,

  /// Low sodium
  lowSodium,

  /// Keto diet
  keto,

  /// Paleo diet
  paleo,
}

/// Customer preference types
enum PreferenceType {
  /// Food temperature preference
  temperature,

  /// Spice level preference
  spiceLevel,

  /// Cooking method preference
  cookingMethod,

  /// Seating preference
  seating,

  /// Service preference
  service,

  /// Dietary preference
  dietary,
}

/// Customer entity representing restaurant customers
class Customer {
  static const int _maxNameLength = 100;
  static const int _maxEmailLength = 255;
  static const int _maxPhoneLength = 20;
  static const int _maxNotesLength = 1000;

  final UserId _id;
  final String _firstName;
  final String _lastName;
  final String? _email;
  final String? _phone;
  final List<DietaryRestriction> _dietaryRestrictions;
  final List<String> _allergens;
  final Map<String, String> _preferences;
  final List<UserId> _orderHistory;
  final int _visitCount;
  final Time? _lastVisit;
  final double? _averageOrderValue;
  final bool _isVip;
  final String? _notes;
  final Time _createdAt;
  final Time _updatedAt;

  /// Creates a Customer with the specified properties
  Customer({
    required UserId id,
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
    List<DietaryRestriction>? dietaryRestrictions,
    List<String>? allergens,
    Map<String, String>? preferences,
    List<UserId>? orderHistory,
    int visitCount = 0,
    Time? lastVisit,
    double? averageOrderValue,
    bool isVip = false,
    String? notes,
    required Time createdAt,
    Time? updatedAt,
  }) : _id = id,
       _firstName = _validateName(firstName, 'First name'),
       _lastName = _validateName(lastName, 'Last name'),
       _email = _validateEmail(email),
       _phone = _validatePhone(phone),
       _dietaryRestrictions = List.unmodifiable(dietaryRestrictions ?? []),
       _allergens = List.unmodifiable(allergens ?? []),
       _preferences = Map.unmodifiable(preferences ?? {}),
       _orderHistory = List.unmodifiable(orderHistory ?? []),
       _visitCount = visitCount,
       _lastVisit = lastVisit,
       _averageOrderValue = averageOrderValue,
       _isVip = isVip,
       _notes = _validateNotes(notes),
       _createdAt = createdAt,
       _updatedAt = updatedAt ?? createdAt;

  /// Customer ID
  UserId get id => _id;

  /// First name
  String get firstName => _firstName;

  /// Last name
  String get lastName => _lastName;

  /// Email address
  String? get email => _email;

  /// Phone number
  String? get phone => _phone;

  /// Dietary restrictions
  List<DietaryRestriction> get dietaryRestrictions => _dietaryRestrictions;

  /// Known allergens
  List<String> get allergens => _allergens;

  /// Customer preferences
  Map<String, String> get preferences => _preferences;

  /// Order history
  List<UserId> get orderHistory => _orderHistory;

  /// Number of visits
  int get visitCount => _visitCount;

  /// Last visit date
  Time? get lastVisit => _lastVisit;

  /// Average order value
  double? get averageOrderValue => _averageOrderValue;

  /// Whether customer is VIP
  bool get isVip => _isVip;

  /// Additional notes
  String? get notes => _notes;

  /// When customer record was created
  Time get createdAt => _createdAt;

  /// When customer record was last updated
  Time get updatedAt => _updatedAt;

  /// Business rule: Get full name
  String get fullName => '$_firstName $_lastName';

  /// Business rule: Get display name
  String get displayName {
    if (_isVip) return '⭐ $fullName';
    return fullName;
  }

  /// Business rule: Check if customer has dietary restriction
  bool hasDietaryRestriction(DietaryRestriction restriction) {
    return _dietaryRestrictions.contains(restriction);
  }

  /// Business rule: Check if customer has allergen
  bool hasAllergen(String allergen) {
    return _allergens.any((a) => a.toLowerCase() == allergen.toLowerCase());
  }

  /// Business rule: Check if customer is frequent visitor
  bool get isFrequentVisitor => _visitCount >= 10;

  /// Business rule: Check if customer is recent visitor
  bool get isRecentVisitor {
    if (_lastVisit == null) return false;
    final daysSinceLastVisit = Time.now().difference(_lastVisit).inDays;
    return daysSinceLastVisit <= 30;
  }

  /// Business rule: Get loyalty tier
  String get loyaltyTier {
    if (_isVip) return 'VIP';
    if (_visitCount >= 50) return 'Gold';
    if (_visitCount >= 20) return 'Silver';
    if (_visitCount >= 5) return 'Bronze';
    return 'New';
  }

  /// Records a new visit
  Customer recordVisit(UserId orderId, double orderValue) {
    final newOrderHistory = [..._orderHistory, orderId];
    final newVisitCount = _visitCount + 1;

    // Calculate new average order value
    double newAverageOrderValue;
    if (_averageOrderValue == null) {
      newAverageOrderValue = orderValue;
    } else {
      newAverageOrderValue =
          ((_averageOrderValue * _visitCount) + orderValue) / newVisitCount;
    }

    return Customer(
      id: _id,
      firstName: _firstName,
      lastName: _lastName,
      email: _email,
      phone: _phone,
      dietaryRestrictions: _dietaryRestrictions,
      allergens: _allergens,
      preferences: _preferences,
      orderHistory: newOrderHistory,
      visitCount: newVisitCount,
      lastVisit: Time.now(),
      averageOrderValue: newAverageOrderValue,
      isVip: _isVip,
      notes: _notes,
      createdAt: _createdAt,
      updatedAt: Time.now(),
    );
  }

  /// Updates customer preferences
  Customer updatePreferences(Map<String, String> newPreferences) {
    final updatedPreferences = {..._preferences, ...newPreferences};

    return Customer(
      id: _id,
      firstName: _firstName,
      lastName: _lastName,
      email: _email,
      phone: _phone,
      dietaryRestrictions: _dietaryRestrictions,
      allergens: _allergens,
      preferences: updatedPreferences,
      orderHistory: _orderHistory,
      visitCount: _visitCount,
      lastVisit: _lastVisit,
      averageOrderValue: _averageOrderValue,
      isVip: _isVip,
      notes: _notes,
      createdAt: _createdAt,
      updatedAt: Time.now(),
    );
  }

  /// Promotes customer to VIP
  Customer promoteToVip() {
    if (_isVip) {
      throw const DomainException('Customer is already VIP');
    }

    return Customer(
      id: _id,
      firstName: _firstName,
      lastName: _lastName,
      email: _email,
      phone: _phone,
      dietaryRestrictions: _dietaryRestrictions,
      allergens: _allergens,
      preferences: _preferences,
      orderHistory: _orderHistory,
      visitCount: _visitCount,
      lastVisit: _lastVisit,
      averageOrderValue: _averageOrderValue,
      isVip: true,
      notes: _notes,
      createdAt: _createdAt,
      updatedAt: Time.now(),
    );
  }

  /// Validates name
  static String _validateName(String name, String fieldName) {
    if (name.trim().isEmpty) {
      throw DomainException('$fieldName cannot be empty');
    }
    if (name.length > _maxNameLength) {
      throw DomainException(
        '$fieldName cannot exceed $_maxNameLength characters',
      );
    }
    return name.trim();
  }

  /// Validates email
  static String? _validateEmail(String? email) {
    if (email == null) return null;
    email = email.trim();
    if (email.isEmpty) return null;

    if (email.length > _maxEmailLength) {
      throw DomainException('Email cannot exceed $_maxEmailLength characters');
    }

    // Basic email validation
    if (!email.contains('@') || !email.contains('.')) {
      throw const DomainException('Invalid email format');
    }

    return email.toLowerCase();
  }

  /// Validates phone
  static String? _validatePhone(String? phone) {
    if (phone == null) return null;
    phone = phone.trim();
    if (phone.isEmpty) return null;

    if (phone.length > _maxPhoneLength) {
      throw DomainException('Phone cannot exceed $_maxPhoneLength characters');
    }

    return phone;
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
      other is Customer && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'Customer(name: $fullName, visits: $_visitCount, vip: $_isVip)';
}
