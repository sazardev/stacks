import '../value_objects/user_id.dart';
import '../value_objects/time.dart';
import '../value_objects/money.dart';
import '../exceptions/domain_exception.dart';

/// Inventory item categories for organization
enum InventoryCategory {
  /// Fresh produce and vegetables
  produce,

  /// Meat, poultry, seafood
  protein,

  /// Dairy products and eggs
  dairy,

  /// Dry goods, grains, flour
  dryGoods,

  /// Frozen items
  frozen,

  /// Beverages and liquids
  beverages,

  /// Cleaning supplies and chemicals
  cleaning,

  /// Kitchen equipment and tools
  equipment,

  /// Disposables and packaging
  disposables,

  /// Spices, seasonings, condiments
  seasonings,
}

/// Storage location types
enum StorageLocation {
  /// Walk-in cooler
  walkInCooler,

  /// Walk-in freezer
  walkInFreezer,

  /// Dry storage
  dryStorage,

  /// Prep area refrigerator
  prepRefrigerator,

  /// Bar area
  bar,

  /// Chemical storage
  chemicalStorage,

  /// Equipment storage
  equipmentStorage,

  /// Receiving area
  receiving,
}

/// Unit of measurement for inventory
enum InventoryUnit {
  /// Individual pieces/items
  pieces,

  /// Pounds
  pounds,

  /// Kilograms
  kilograms,

  /// Gallons
  gallons,

  /// Liters
  liters,

  /// Cases
  cases,

  /// Boxes
  boxes,

  /// Bags
  bags,

  /// Cans
  cans,

  /// Bottles
  bottles,
}

/// Inventory tracking status
enum InventoryStatus {
  /// In stock and available
  inStock,

  /// Low stock warning level
  lowStock,

  /// Out of stock
  outOfStock,

  /// On order from supplier
  onOrder,

  /// Expired or spoiled
  expired,

  /// Reserved for specific orders
  reserved,

  /// Being counted/audited
  audit,
}

/// Supplier information for inventory items
class Supplier {
  static const int _maxNameLength = 200;
  static const int _maxContactLength = 100;

  final UserId _id;
  final String _name;
  final String _contactPerson;
  final String _phone;
  final String _email;
  final String? _address;
  final List<String> _categories;
  final bool _isActive;
  final Time _createdAt;

  /// Creates a Supplier with the specified properties
  Supplier({
    required UserId id,
    required String name,
    required String contactPerson,
    required String phone,
    required String email,
    String? address,
    List<String>? categories,
    bool isActive = true,
    required Time createdAt,
  }) : _id = id,
       _name = _validateName(name),
       _contactPerson = _validateContact(contactPerson),
       _phone = _validatePhone(phone),
       _email = _validateEmail(email),
       _address = address,
       _categories = List.unmodifiable(categories ?? []),
       _isActive = isActive,
       _createdAt = createdAt;

  /// Supplier ID
  UserId get id => _id;

  /// Supplier name
  String get name => _name;

  /// Contact person name
  String get contactPerson => _contactPerson;

  /// Phone number
  String get phone => _phone;

  /// Email address
  String get email => _email;

  /// Physical address
  String? get address => _address;

  /// Categories supplied
  List<String> get categories => _categories;

  /// Whether supplier is active
  bool get isActive => _isActive;

  /// When supplier was added
  Time get createdAt => _createdAt;

  /// Validates supplier name
  static String _validateName(String name) {
    if (name.trim().isEmpty) {
      throw const DomainException('Supplier name cannot be empty');
    }
    if (name.length > _maxNameLength) {
      throw DomainException(
        'Supplier name cannot exceed $_maxNameLength characters',
      );
    }
    return name.trim();
  }

  /// Validates contact person
  static String _validateContact(String contact) {
    if (contact.trim().isEmpty) {
      throw const DomainException('Contact person cannot be empty');
    }
    if (contact.length > _maxContactLength) {
      throw DomainException(
        'Contact person cannot exceed $_maxContactLength characters',
      );
    }
    return contact.trim();
  }

  /// Validates phone number
  static String _validatePhone(String phone) {
    if (phone.trim().isEmpty) {
      throw const DomainException('Phone number cannot be empty');
    }
    // Basic phone validation - could be enhanced
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length < 10) {
      throw const DomainException('Phone number must be at least 10 digits');
    }
    return phone.trim();
  }

  /// Validates email address
  static String _validateEmail(String email) {
    if (email.trim().isEmpty) {
      throw const DomainException('Email cannot be empty');
    }
    // Basic email validation
    if (!email.contains('@') || !email.contains('.')) {
      throw const DomainException('Invalid email format');
    }
    return email.trim().toLowerCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Supplier && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() => 'Supplier(id: $_id, name: $_name, active: $_isActive)';
}

/// Inventory item entity for stock management
class InventoryItem {
  static const int _maxNameLength = 200;
  static const int _maxDescriptionLength = 500;
  static const double _minQuantity = 0.0;
  static const double _maxQuantity = 999999.0;

  final UserId _id;
  final String _name;
  final String? _description;
  final String _sku;
  final InventoryCategory _category;
  final double _currentQuantity;
  final double _reorderLevel;
  final double _maxStockLevel;
  final InventoryUnit _unit;
  final Money _unitCost;
  final StorageLocation _storageLocation;
  final InventoryStatus _status;
  final UserId? _supplierId;
  final Time? _expirationDate;
  final Time? _receivedDate;
  final Time? _lastCountDate;
  final String? _batchNumber;
  final String? _lotNumber;
  final List<String> _allergens;
  final bool _isPerishable;
  final bool _requiresTemperatureControl;
  final double? _minimumTemperature;
  final double? _maximumTemperature;
  final Time _createdAt;
  final Time _updatedAt;

  /// Creates an InventoryItem with the specified properties
  InventoryItem({
    required UserId id,
    required String name,
    String? description,
    required String sku,
    required InventoryCategory category,
    required double currentQuantity,
    required double reorderLevel,
    required double maxStockLevel,
    required InventoryUnit unit,
    required Money unitCost,
    required StorageLocation storageLocation,
    InventoryStatus status = InventoryStatus.inStock,
    UserId? supplierId,
    Time? expirationDate,
    Time? receivedDate,
    Time? lastCountDate,
    String? batchNumber,
    String? lotNumber,
    List<String>? allergens,
    bool isPerishable = false,
    bool requiresTemperatureControl = false,
    double? minimumTemperature,
    double? maximumTemperature,
    required Time createdAt,
    Time? updatedAt,
  }) : _id = id,
       _name = _validateName(name),
       _description = _validateDescription(description),
       _sku = _validateSku(sku),
       _category = category,
       _currentQuantity = _validateQuantity(currentQuantity),
       _reorderLevel = _validateQuantity(reorderLevel),
       _maxStockLevel = _validateQuantity(maxStockLevel),
       _unit = unit,
       _unitCost = unitCost,
       _storageLocation = storageLocation,
       _status = status,
       _supplierId = supplierId,
       _expirationDate = expirationDate,
       _receivedDate = receivedDate,
       _lastCountDate = lastCountDate,
       _batchNumber = batchNumber,
       _lotNumber = lotNumber,
       _allergens = List.unmodifiable(allergens ?? []),
       _isPerishable = isPerishable,
       _requiresTemperatureControl = requiresTemperatureControl,
       _minimumTemperature = minimumTemperature,
       _maximumTemperature = maximumTemperature,
       _createdAt = createdAt,
       _updatedAt = updatedAt ?? createdAt;

  /// Inventory item ID
  UserId get id => _id;

  /// Item name
  String get name => _name;

  /// Item description
  String? get description => _description;

  /// Stock keeping unit (SKU)
  String get sku => _sku;

  /// Item category
  InventoryCategory get category => _category;

  /// Current quantity in stock
  double get currentQuantity => _currentQuantity;

  /// Reorder level threshold
  double get reorderLevel => _reorderLevel;

  /// Maximum stock level
  double get maxStockLevel => _maxStockLevel;

  /// Unit of measurement
  InventoryUnit get unit => _unit;

  /// Cost per unit
  Money get unitCost => _unitCost;

  /// Storage location
  StorageLocation get storageLocation => _storageLocation;

  /// Current status
  InventoryStatus get status => _status;

  /// Supplier ID
  UserId? get supplierId => _supplierId;

  /// Expiration date (if perishable)
  Time? get expirationDate => _expirationDate;

  /// Date received
  Time? get receivedDate => _receivedDate;

  /// Last count date
  Time? get lastCountDate => _lastCountDate;

  /// Batch number
  String? get batchNumber => _batchNumber;

  /// Lot number
  String? get lotNumber => _lotNumber;

  /// Known allergens
  List<String> get allergens => _allergens;

  /// Whether item is perishable
  bool get isPerishable => _isPerishable;

  /// Whether requires temperature control
  bool get requiresTemperatureControl => _requiresTemperatureControl;

  /// Minimum storage temperature
  double? get minimumTemperature => _minimumTemperature;

  /// Maximum storage temperature
  double? get maximumTemperature => _maximumTemperature;

  /// When item was created
  Time get createdAt => _createdAt;

  /// When item was last updated
  Time get updatedAt => _updatedAt;

  /// Business rule: Check if item needs reordering
  bool get needsReordering => _currentQuantity <= _reorderLevel;

  /// Business rule: Check if item is low stock
  bool get isLowStock => _currentQuantity <= _reorderLevel * 1.5;

  /// Business rule: Check if item is out of stock
  bool get isOutOfStock => _currentQuantity <= 0;

  /// Business rule: Check if item is overstocked
  bool get isOverstocked => _currentQuantity > _maxStockLevel;

  /// Business rule: Check if item is expired
  bool get isExpired {
    if (!_isPerishable || _expirationDate == null) return false;
    return Time.now().isAfter(_expirationDate);
  }

  /// Business rule: Days until expiration
  int? get daysUntilExpiration {
    if (!_isPerishable || _expirationDate == null) return null;
    final now = Time.now();
    if (now.isAfter(_expirationDate)) return 0;
    final difference = _expirationDate.difference(now);
    return difference.inDays;
  }

  /// Business rule: Check if item expires soon (within 3 days)
  bool get expiresSoon {
    final days = daysUntilExpiration;
    return days != null && days <= 3;
  }

  /// Business rule: Calculate total value of current stock
  Money get totalValue => Money(_unitCost.amount * _currentQuantity);

  /// Business rule: Get suggested order quantity
  double get suggestedOrderQuantity {
    if (!needsReordering) return 0.0;
    return _maxStockLevel - _currentQuantity;
  }

  /// Business rule: Check if quantity is available for use
  bool isQuantityAvailable(double requestedQuantity) {
    return _currentQuantity >= requestedQuantity &&
        _status == InventoryStatus.inStock;
  }

  /// Business rule: Check if temperature is within safe range
  bool isTemperatureInRange(double temperature) {
    if (!_requiresTemperatureControl) return true;
    if (_minimumTemperature != null && temperature < _minimumTemperature) {
      return false;
    }
    if (_maximumTemperature != null && temperature > _maximumTemperature) {
      return false;
    }
    return true;
  }

  /// Updates quantity after usage
  InventoryItem useQuantity(double usedQuantity, String reason) {
    if (usedQuantity <= 0) {
      throw const DomainException('Used quantity must be positive');
    }
    if (usedQuantity > _currentQuantity) {
      throw const DomainException('Cannot use more than available quantity');
    }

    final newQuantity = _currentQuantity - usedQuantity;
    InventoryStatus newStatus = _status;

    if (newQuantity <= 0) {
      newStatus = InventoryStatus.outOfStock;
    } else if (newQuantity <= _reorderLevel) {
      newStatus = InventoryStatus.lowStock;
    }

    return InventoryItem(
      id: _id,
      name: _name,
      description: _description,
      sku: _sku,
      category: _category,
      currentQuantity: newQuantity,
      reorderLevel: _reorderLevel,
      maxStockLevel: _maxStockLevel,
      unit: _unit,
      unitCost: _unitCost,
      storageLocation: _storageLocation,
      status: newStatus,
      supplierId: _supplierId,
      expirationDate: _expirationDate,
      receivedDate: _receivedDate,
      lastCountDate: _lastCountDate,
      batchNumber: _batchNumber,
      lotNumber: _lotNumber,
      allergens: _allergens,
      isPerishable: _isPerishable,
      requiresTemperatureControl: _requiresTemperatureControl,
      minimumTemperature: _minimumTemperature,
      maximumTemperature: _maximumTemperature,
      createdAt: _createdAt,
      updatedAt: Time.now(),
    );
  }

  /// Adds quantity to stock (receiving)
  InventoryItem receiveQuantity({
    required double receivedQuantity,
    required Money unitCost,
    Time? expirationDate,
    String? batchNumber,
    String? lotNumber,
  }) {
    if (receivedQuantity <= 0) {
      throw const DomainException('Received quantity must be positive');
    }

    final newQuantity = _currentQuantity + receivedQuantity;
    if (newQuantity > _maxQuantity) {
      throw const DomainException('Received quantity exceeds maximum allowed');
    }

    InventoryStatus newStatus = InventoryStatus.inStock;
    if (newQuantity > _maxStockLevel) {
      // Still in stock but overstocked
      newStatus = InventoryStatus.inStock;
    }

    return InventoryItem(
      id: _id,
      name: _name,
      description: _description,
      sku: _sku,
      category: _category,
      currentQuantity: newQuantity,
      reorderLevel: _reorderLevel,
      maxStockLevel: _maxStockLevel,
      unit: _unit,
      unitCost: unitCost,
      storageLocation: _storageLocation,
      status: newStatus,
      supplierId: _supplierId,
      expirationDate: expirationDate ?? _expirationDate,
      receivedDate: Time.now(),
      lastCountDate: _lastCountDate,
      batchNumber: batchNumber ?? _batchNumber,
      lotNumber: lotNumber ?? _lotNumber,
      allergens: _allergens,
      isPerishable: _isPerishable,
      requiresTemperatureControl: _requiresTemperatureControl,
      minimumTemperature: _minimumTemperature,
      maximumTemperature: _maximumTemperature,
      createdAt: _createdAt,
      updatedAt: Time.now(),
    );
  }

  /// Updates stock count (physical inventory)
  InventoryItem updateStockCount(double countedQuantity, String reason) {
    if (countedQuantity < 0) {
      throw const DomainException('Counted quantity cannot be negative');
    }

    InventoryStatus newStatus = InventoryStatus.inStock;
    if (countedQuantity <= 0) {
      newStatus = InventoryStatus.outOfStock;
    } else if (countedQuantity <= _reorderLevel) {
      newStatus = InventoryStatus.lowStock;
    }

    return InventoryItem(
      id: _id,
      name: _name,
      description: _description,
      sku: _sku,
      category: _category,
      currentQuantity: countedQuantity,
      reorderLevel: _reorderLevel,
      maxStockLevel: _maxStockLevel,
      unit: _unit,
      unitCost: _unitCost,
      storageLocation: _storageLocation,
      status: newStatus,
      supplierId: _supplierId,
      expirationDate: _expirationDate,
      receivedDate: _receivedDate,
      lastCountDate: Time.now(),
      batchNumber: _batchNumber,
      lotNumber: _lotNumber,
      allergens: _allergens,
      isPerishable: _isPerishable,
      requiresTemperatureControl: _requiresTemperatureControl,
      minimumTemperature: _minimumTemperature,
      maximumTemperature: _maximumTemperature,
      createdAt: _createdAt,
      updatedAt: Time.now(),
    );
  }

  /// Marks item as expired
  InventoryItem markExpired() {
    if (!_isPerishable) {
      throw const DomainException('Cannot mark non-perishable item as expired');
    }

    return InventoryItem(
      id: _id,
      name: _name,
      description: _description,
      sku: _sku,
      category: _category,
      currentQuantity: _currentQuantity,
      reorderLevel: _reorderLevel,
      maxStockLevel: _maxStockLevel,
      unit: _unit,
      unitCost: _unitCost,
      storageLocation: _storageLocation,
      status: InventoryStatus.expired,
      supplierId: _supplierId,
      expirationDate: _expirationDate,
      receivedDate: _receivedDate,
      lastCountDate: _lastCountDate,
      batchNumber: _batchNumber,
      lotNumber: _lotNumber,
      allergens: _allergens,
      isPerishable: _isPerishable,
      requiresTemperatureControl: _requiresTemperatureControl,
      minimumTemperature: _minimumTemperature,
      maximumTemperature: _maximumTemperature,
      createdAt: _createdAt,
      updatedAt: Time.now(),
    );
  }

  /// Validates item name
  static String _validateName(String name) {
    if (name.trim().isEmpty) {
      throw const DomainException('Item name cannot be empty');
    }
    if (name.length > _maxNameLength) {
      throw DomainException(
        'Item name cannot exceed $_maxNameLength characters',
      );
    }
    return name.trim();
  }

  /// Validates item description
  static String? _validateDescription(String? description) {
    if (description == null) return null;
    if (description.length > _maxDescriptionLength) {
      throw DomainException(
        'Description cannot exceed $_maxDescriptionLength characters',
      );
    }
    return description.trim();
  }

  /// Validates SKU
  static String _validateSku(String sku) {
    if (sku.trim().isEmpty) {
      throw const DomainException('SKU cannot be empty');
    }
    return sku.trim().toUpperCase();
  }

  /// Validates quantity
  static double _validateQuantity(double quantity) {
    if (quantity < _minQuantity) {
      throw DomainException('Quantity cannot be less than $_minQuantity');
    }
    if (quantity > _maxQuantity) {
      throw DomainException('Quantity cannot exceed $_maxQuantity');
    }
    return quantity;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryItem &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'InventoryItem(id: $_id, name: $_name, quantity: $_currentQuantity $_unit, status: $_status)';
}
