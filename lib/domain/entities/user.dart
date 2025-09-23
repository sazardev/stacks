import '../value_objects/user_id.dart';
import '../value_objects/time.dart';
import '../exceptions/domain_exception.dart';

/// Kitchen stations in the restaurant
enum KitchenStation {
  /// Grill station - handles grilled meats and vegetables
  grill,

  /// Sauté station - handles pan-fried dishes and sauces
  saute,

  /// Fryer station - handles fried foods
  fryer,

  /// Salad/Cold station - handles cold appetizers and salads
  salad,

  /// Pastry station - handles desserts and baked goods
  pastry,

  /// Prep station - handles food preparation and mise en place
  prep,

  /// Dish pit - handles cleaning and sanitation
  dish,

  /// Expediting station - coordinates order flow
  expo,
}

/// Work shifts in the restaurant
enum WorkShift {
  /// Morning prep shift (5:00 AM - 11:00 AM)
  morningPrep,

  /// Lunch service (11:00 AM - 3:00 PM)
  lunch,

  /// Afternoon prep (3:00 PM - 5:00 PM)
  afternoonPrep,

  /// Dinner service (5:00 PM - 10:00 PM)
  dinner,

  /// Night closing (10:00 PM - 2:00 AM)
  night,

  /// Overnight cleaning (2:00 AM - 5:00 AM)
  overnight,
}

/// Temporal permissions based on shift and time
enum TemporalPermission {
  /// Can access kitchen during off-hours
  offHoursAccess,

  /// Can override closing procedures
  overrideClosing,

  /// Can open kitchen in morning
  openKitchen,

  /// Can authorize overtime
  authorizeOvertime,

  /// Can change shift schedules
  modifySchedules,

  /// Can access financial systems during business hours only
  businessHoursFinancials,

  /// Can perform inventory during specific hours
  inventoryAccess,

  /// Emergency access during any shift
  emergencyAccess,
}

/// Authority levels for command hierarchy
enum AuthorityLevel {
  /// Entry level - follows orders, no override capability
  entry(1),

  /// Basic staff - can guide entry level
  basic(2),

  /// Experienced staff - can override basic decisions
  experienced(3),

  /// Senior staff - supervisory authority over line staff
  senior(4),

  /// Management level - can override senior staff decisions
  management(5),

  /// Executive level - highest kitchen authority
  executive(6),

  /// System administration - technical override capability
  system(7);

  const AuthorityLevel(this.level);
  final int level;
}

/// Types of commands/decisions that can be overridden
enum CommandType {
  /// Order preparation instructions
  orderPreparation,

  /// Station assignments and changes
  stationAssignment,

  /// Food safety protocols
  foodSafety,

  /// Inventory management decisions
  inventoryManagement,

  /// Schedule modifications
  scheduleChange,

  /// Quality control standards
  qualityControl,

  /// Emergency procedures
  emergencyProcedure,

  /// System configuration changes
  systemConfiguration,
}

/// Food safety and operational certifications
enum CertificationType {
  /// Basic food safety certification
  foodSafety,

  /// Allergen awareness certification
  allergenAwareness,

  /// HACCP (Hazard Analysis Critical Control Points)
  haccp,

  /// Fire safety and emergency procedures
  fireSafety,

  /// Alcohol service certification
  alcoholService,

  /// Management and leadership training
  management,

  /// Station-specific training (grill, sauté, etc.)
  stationSpecific,

  /// Equipment operation certification
  equipmentOperation,
}

/// Emergency protocol types
enum EmergencyType {
  /// Fire emergency requiring immediate evacuation
  fire,

  /// Food safety emergency (contamination, allergen exposure)
  foodSafety,

  /// Medical emergency (injury, allergic reaction)
  medical,

  /// Equipment failure that affects safety
  equipmentFailure,

  /// Security emergency (threatening behavior, theft)
  security,

  /// Chemical spill or exposure
  chemical,

  /// Power outage affecting refrigeration/safety
  powerOutage,

  /// Gas leak or ventilation failure
  gasLeak,
}

/// User roles in the kitchen system with hierarchical structure
enum UserRole {
  /// Entry-level kitchen staff
  dishwasher,

  /// Prep cook - handles basic food preparation
  prepCook,

  /// Line cook - works specific station during service
  lineCook,

  /// Experienced cook with cross-station capabilities
  cook,

  /// Senior cook with leadership responsibilities
  cookSenior,

  /// Assistant chef with station management duties
  chefAssistant,

  /// Sous chef - second in command, can manage kitchen operations
  sousChef,

  /// Head chef - full kitchen authority and responsibility
  chefHead,

  /// Expediter - coordinates order flow and quality control
  expediter,

  /// Kitchen manager - administrative and operational oversight
  kitchenManager,

  /// General manager - restaurant-wide authority
  generalManager,

  /// System administrator - technical and system access
  admin,
}

/// Comprehensive kitchen permissions system
enum Permission {
  // Basic Order Operations
  viewOrders,
  updateOrderStatus,
  prioritizeOrders,
  cancelOrders,

  // Kitchen Station Operations
  workStation,
  manageStationEquipment,
  assignOrdersToStation,
  changeStationStatus,

  // Food and Inventory Management
  viewInventory,
  updateInventory,
  manageInventory,
  orderSupplies,
  receiveDeliveries,
  manageWaste,

  // Recipe and Menu Management
  viewRecipes,
  modifyRecipes,
  createRecipes,
  manageMenu,
  setPricing,

  // Staff Management
  viewStaffSchedule,
  manageStaffSchedule,
  superviseStaff,
  trainStaff,
  evaluatePerformance,
  managePayroll,

  // Food Safety and Quality
  manageFoodSafety,
  conductQualityControl,
  manageTemperatureControl,
  handleAllergenProtocols,
  manageHACCP,

  // Reporting and Analytics
  viewBasicReports,
  viewAdvancedReports,
  viewFinancialReports,
  exportReports,

  // User and System Management
  manageUsers,
  manageUserRoles,
  configureSystem,
  manageIntegrations,
  viewAuditLogs,

  // Customer and Service
  handleCustomerComplaints,
  manageReservations,
  processPOS,

  // Emergency and Safety
  handleEmergencyProcedures,
  accessEmergencyOverride,

  // System Administration
  manageSystem,
  backupData,
  restoreData,
}

/// User entity representing a user in the kitchen display system
class User {
  static const int _maxNameLength = 100;
  static const int _sessionTimeoutHours = 24;

  final UserId _id;
  final String _email;
  final String _name;
  final UserRole _role;
  final Time _createdAt;
  final bool _isActive;
  final bool _isAuthenticated;
  final String? _sessionId;
  final Time? _lastLoginAt;

  /// Creates a User with the specified properties
  User({
    required UserId id,
    required String email,
    required String name,
    required UserRole role,
    required Time createdAt,
    bool isActive = true,
    bool isAuthenticated = false,
    String? sessionId,
    Time? lastLoginAt,
  }) : _id = id,
       _email = _validateEmail(email),
       _name = _validateName(name),
       _role = role,
       _createdAt = createdAt,
       _isActive = isActive,
       _isAuthenticated = isAuthenticated,
       _sessionId = sessionId,
       _lastLoginAt = lastLoginAt;

  /// User ID
  UserId get id => _id;

  /// User email address
  String get email => _email;

  /// User full name
  String get name => _name;

  /// User role
  UserRole get role => _role;

  /// When the user was created
  Time get createdAt => _createdAt;

  /// Whether the user is active
  bool get isActive => _isActive;

  /// Whether the user is authenticated
  bool get isAuthenticated => _isAuthenticated;

  /// Current session ID (if authenticated)
  String? get sessionId => _sessionId;

  /// Last login time
  Time? get lastLoginAt => _lastLoginAt;

  /// Validates email format
  static String _validateEmail(String email) {
    if (email.isEmpty) {
      throw const EntityInvariantException('User email cannot be empty');
    }

    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailPattern.hasMatch(email)) {
      throw EntityInvariantException('Invalid email format: $email');
    }

    return email;
  }

  /// Validates name
  static String _validateName(String name) {
    if (name.isEmpty) {
      throw const EntityInvariantException('User name cannot be empty');
    }

    if (name.length > _maxNameLength) {
      throw EntityInvariantException(
        'User name cannot exceed $_maxNameLength characters',
      );
    }

    return name.trim();
  }

  // Role checkers
  /// Whether the user is kitchen staff (any kitchen role)
  bool get isKitchenStaff => [
    UserRole.dishwasher,
    UserRole.prepCook,
    UserRole.lineCook,
    UserRole.cook,
    UserRole.cookSenior,
    UserRole.chefAssistant,
    UserRole.sousChef,
    UserRole.chefHead,
    UserRole.expediter,
  ].contains(_role);

  /// Whether the user is in management
  bool get isManager => [
    UserRole.sousChef,
    UserRole.chefHead,
    UserRole.kitchenManager,
    UserRole.generalManager,
  ].contains(_role);

  /// Whether the user is admin
  bool get isAdmin => _role == UserRole.admin;

  /// Whether the user is senior staff (can supervise others)
  bool get isSeniorStaff => [
    UserRole.cookSenior,
    UserRole.chefAssistant,
    UserRole.sousChef,
    UserRole.chefHead,
    UserRole.expediter,
    UserRole.kitchenManager,
    UserRole.generalManager,
    UserRole.admin,
  ].contains(_role);

  /// Authenticates the user with a session
  User authenticate(String sessionId, Time loginTime) {
    return User(
      id: _id,
      email: _email,
      name: _name,
      role: _role,
      createdAt: _createdAt,
      isActive: _isActive,
      isAuthenticated: true,
      sessionId: sessionId,
      lastLoginAt: loginTime,
    );
  }

  /// Logs out the user
  User logout() {
    return User(
      id: _id,
      email: _email,
      name: _name,
      role: _role,
      createdAt: _createdAt,
      isActive: _isActive,
      isAuthenticated: false,
      sessionId: null,
      lastLoginAt: _lastLoginAt,
    );
  }

  /// Checks if the user's session is expired
  bool isSessionExpired() {
    if (!_isAuthenticated || _lastLoginAt == null) {
      return true;
    }

    final now = Time.now();
    final sessionDuration = now.difference(_lastLoginAt);
    return sessionDuration.inHours >= _sessionTimeoutHours;
  }

  /// Activates the user
  User activate() {
    return User(
      id: _id,
      email: _email,
      name: _name,
      role: _role,
      createdAt: _createdAt,
      isActive: true,
      isAuthenticated: _isAuthenticated,
      sessionId: _sessionId,
      lastLoginAt: _lastLoginAt,
    );
  }

  /// Deactivates the user
  User deactivate() {
    return User(
      id: _id,
      email: _email,
      name: _name,
      role: _role,
      createdAt: _createdAt,
      isActive: false,
      isAuthenticated: false, // Deactivation logs out user
      sessionId: null,
      lastLoginAt: _lastLoginAt,
    );
  }

  /// Updates user profile information
  User updateProfile({String? name, String? email}) {
    return User(
      id: _id,
      email: email ?? _email,
      name: name ?? _name,
      role: _role,
      createdAt: _createdAt,
      isActive: _isActive,
      isAuthenticated: _isAuthenticated,
      sessionId: _sessionId,
      lastLoginAt: _lastLoginAt,
    );
  }

  /// Changes user role
  User changeRole(UserRole newRole) {
    return User(
      id: _id,
      email: _email,
      name: _name,
      role: newRole,
      createdAt: _createdAt,
      isActive: _isActive,
      isAuthenticated: _isAuthenticated,
      sessionId: _sessionId,
      lastLoginAt: _lastLoginAt,
    );
  }

  /// Permission checking methods - Basic Order Operations
  bool canViewOrders() => hasPermission(Permission.viewOrders);
  bool canUpdateOrderStatus() => hasPermission(Permission.updateOrderStatus);
  bool canPrioritizeOrders() => hasPermission(Permission.prioritizeOrders);
  bool canCancelOrders() => hasPermission(Permission.cancelOrders);

  /// Station Operations
  bool canWorkStation() => hasPermission(Permission.workStation);
  bool canManageStationEquipment() =>
      hasPermission(Permission.manageStationEquipment);
  bool canAssignOrdersToStation() =>
      hasPermission(Permission.assignOrdersToStation);
  bool canChangeStationStatus() =>
      hasPermission(Permission.changeStationStatus);

  /// Inventory Management
  bool canViewInventory() => hasPermission(Permission.viewInventory);
  bool canUpdateInventory() => hasPermission(Permission.updateInventory);
  bool canManageInventory() => hasPermission(Permission.manageInventory);
  bool canOrderSupplies() => hasPermission(Permission.orderSupplies);

  /// Recipe Management
  bool canViewRecipes() => hasPermission(Permission.viewRecipes);
  bool canModifyRecipes() => hasPermission(Permission.modifyRecipes);
  bool canCreateRecipes() => hasPermission(Permission.createRecipes);
  bool canManageMenu() => hasPermission(Permission.manageMenu);

  /// Staff Management
  bool canSuperviseStaff() => hasPermission(Permission.superviseStaff);
  bool canManageStaffSchedule() =>
      hasPermission(Permission.manageStaffSchedule);
  bool canTrainStaff() => hasPermission(Permission.trainStaff);

  /// Food Safety
  bool canManageFoodSafety() => hasPermission(Permission.manageFoodSafety);
  bool canConductQualityControl() =>
      hasPermission(Permission.conductQualityControl);
  bool canManageHACCP() => hasPermission(Permission.manageHACCP);

  /// Reports and Analytics
  bool canViewBasicReports() => hasPermission(Permission.viewBasicReports);
  bool canViewAdvancedReports() =>
      hasPermission(Permission.viewAdvancedReports);
  bool canViewFinancialReports() =>
      hasPermission(Permission.viewFinancialReports);

  /// System Management
  bool canManageUsers() => hasPermission(Permission.manageUsers);
  bool canManageSystem() => hasPermission(Permission.manageSystem);

  /// Checks if user has specific permission based on kitchen hierarchy
  bool hasPermission(Permission permission) {
    final permissions = _getRolePermissions(_role);
    return permissions.contains(permission);
  }

  /// Gets permissions based on role hierarchy
  List<Permission> _getRolePermissions(UserRole role) {
    switch (role) {
      case UserRole.dishwasher:
        return _getDishwasherPermissions();
      case UserRole.prepCook:
        return _getPrepCookPermissions();
      case UserRole.lineCook:
        return _getLineCookPermissions();
      case UserRole.cook:
        return _getCookPermissions();
      case UserRole.cookSenior:
        return _getSeniorCookPermissions();
      case UserRole.chefAssistant:
        return _getChefAssistantPermissions();
      case UserRole.sousChef:
        return _getSousChefPermissions();
      case UserRole.chefHead:
        return _getHeadChefPermissions();
      case UserRole.expediter:
        return _getExpediterPermissions();
      case UserRole.kitchenManager:
        return _getKitchenManagerPermissions();
      case UserRole.generalManager:
        return _getGeneralManagerPermissions();
      case UserRole.admin:
        return _getAdminPermissions();
    }
  }

  /// Dishwasher permissions - basic sanitation and support
  List<Permission> _getDishwasherPermissions() {
    return [
      Permission.viewOrders,
      Permission.manageWaste,
      Permission.manageFoodSafety,
    ];
  }

  /// Prep cook permissions - food preparation
  List<Permission> _getPrepCookPermissions() {
    return [
      ..._getDishwasherPermissions(),
      Permission.viewRecipes,
      Permission.viewInventory,
      Permission.updateInventory,
      Permission.receiveDeliveries,
      Permission.handleAllergenProtocols,
    ];
  }

  /// Line cook permissions - station work
  List<Permission> _getLineCookPermissions() {
    return [
      ..._getPrepCookPermissions(),
      Permission.updateOrderStatus,
      Permission.workStation,
      Permission.manageTemperatureControl,
      Permission.conductQualityControl,
    ];
  }

  /// Cook permissions - cross-station capabilities
  List<Permission> _getCookPermissions() {
    return [
      ..._getLineCookPermissions(),
      Permission.prioritizeOrders,
      Permission.assignOrdersToStation,
      Permission.modifyRecipes,
      Permission.manageStationEquipment,
    ];
  }

  /// Senior cook permissions - leadership responsibilities
  List<Permission> _getSeniorCookPermissions() {
    return [
      ..._getCookPermissions(),
      Permission.superviseStaff,
      Permission.trainStaff,
      Permission.manageInventory,
      Permission.changeStationStatus,
      Permission.viewStaffSchedule,
      Permission.orderSupplies,
    ];
  }

  /// Chef assistant permissions - station management
  List<Permission> _getChefAssistantPermissions() {
    return [
      ..._getSeniorCookPermissions(),
      Permission.createRecipes,
      Permission.manageMenu,
      Permission.manageStaffSchedule,
      Permission.evaluatePerformance,
      Permission.manageHACCP,
      Permission.viewBasicReports,
    ];
  }

  /// Sous chef permissions - second in command
  List<Permission> _getSousChefPermissions() {
    return [
      ..._getChefAssistantPermissions(),
      Permission.cancelOrders,
      Permission.setPricing,
      Permission.manageUsers,
      Permission.viewAdvancedReports,
      Permission.handleCustomerComplaints,
      Permission.handleEmergencyProcedures,
    ];
  }

  /// Head chef permissions - full kitchen authority
  List<Permission> _getHeadChefPermissions() {
    return [
      ..._getSousChefPermissions(),
      Permission.managePayroll,
      Permission.viewFinancialReports,
      Permission.exportReports,
      Permission.manageUserRoles,
      Permission.accessEmergencyOverride,
      Permission.manageReservations,
    ];
  }

  /// Expediter permissions - quality control and coordination
  List<Permission> _getExpediterPermissions() {
    return [
      Permission.viewOrders,
      Permission.updateOrderStatus,
      Permission.prioritizeOrders,
      Permission.assignOrdersToStation,
      Permission.conductQualityControl,
      Permission.superviseStaff,
      Permission.handleCustomerComplaints,
      Permission.viewStaffSchedule,
      Permission.viewBasicReports,
    ];
  }

  /// Kitchen manager permissions - operational oversight
  List<Permission> _getKitchenManagerPermissions() {
    return [
      ..._getHeadChefPermissions(),
      Permission.configureSystem,
      Permission.manageIntegrations,
      Permission.viewAuditLogs,
      Permission.processPOS,
    ];
  }

  /// General manager permissions - restaurant-wide authority
  List<Permission> _getGeneralManagerPermissions() {
    return [
      ..._getKitchenManagerPermissions(),
      Permission.backupData,
      Permission.restoreData,
    ];
  }

  /// Admin permissions - full system access
  List<Permission> _getAdminPermissions() {
    return Permission.values; // All permissions
  }

  /// Checks if user can perform a specific action
  bool canPerformAction(String action) {
    switch (action) {
      case 'VIEW_ORDERS':
        return canViewOrders();
      case 'UPDATE_ORDER_STATUS':
        return canUpdateOrderStatus();
      case 'PRIORITIZE_ORDERS':
        return canPrioritizeOrders();
      case 'CANCEL_ORDERS':
        return canCancelOrders();
      case 'WORK_STATION':
        return canWorkStation();
      case 'MANAGE_STATION_EQUIPMENT':
        return canManageStationEquipment();
      case 'MANAGE_INVENTORY':
        return canManageInventory();
      case 'SUPERVISE_STAFF':
        return canSuperviseStaff();
      case 'MANAGE_FOOD_SAFETY':
        return canManageFoodSafety();
      case 'VIEW_BASIC_REPORTS':
        return canViewBasicReports();
      case 'VIEW_ADVANCED_REPORTS':
        return canViewAdvancedReports();
      case 'MANAGE_USERS':
        return canManageUsers();
      case 'MANAGE_SYSTEM':
        return canManageSystem();
      default:
        return false;
    }
  }

  /// Station Assignment Business Rules

  /// Checks if user can work at a specific kitchen station
  bool canWorkAtStation(KitchenStation station) {
    final compatibleStations = _getCompatibleStations(_role);
    return compatibleStations.contains(station);
  }

  /// Gets all stations this user role is qualified to work
  List<KitchenStation> getCompatibleStations() {
    return _getCompatibleStations(_role);
  }

  /// Validates if user can be assigned to station (business rule enforcement)
  bool validateStationAssignment(KitchenStation station) {
    // Basic qualification check
    if (!canWorkAtStation(station)) {
      return false;
    }

    // Role-specific business rules
    switch (_role) {
      case UserRole.dishwasher:
        // Dishwashers can only work dish pit and prep
        return [KitchenStation.dish, KitchenStation.prep].contains(station);

      case UserRole.prepCook:
        // Prep cooks work prep station and assist in others
        return [
          KitchenStation.prep,
          KitchenStation.salad,
          KitchenStation.dish,
        ].contains(station);

      case UserRole.lineCook:
        // Line cooks work hot stations but not pastry (requires specialization)
        return ![KitchenStation.pastry].contains(station);

      case UserRole.cook:
        // Full cooks can work any station except pastry
        return station != KitchenStation.pastry;

      case UserRole.cookSenior:
      case UserRole.chefAssistant:
      case UserRole.sousChef:
      case UserRole.chefHead:
        // Senior roles can work any station
        return true;

      case UserRole.expediter:
        // Expediter primarily works expo but can oversee others
        return [
          KitchenStation.expo,
          KitchenStation.grill,
          KitchenStation.saute,
        ].contains(station);

      case UserRole.kitchenManager:
      case UserRole.generalManager:
      case UserRole.admin:
        // Management can oversee any station but typically don't work them
        return true;
    }
  }

  /// Gets compatible stations based on role
  List<KitchenStation> _getCompatibleStations(UserRole role) {
    switch (role) {
      case UserRole.dishwasher:
        return [KitchenStation.dish, KitchenStation.prep];

      case UserRole.prepCook:
        return [KitchenStation.prep, KitchenStation.salad, KitchenStation.dish];

      case UserRole.lineCook:
        return [
          KitchenStation.grill,
          KitchenStation.saute,
          KitchenStation.fryer,
          KitchenStation.prep,
          KitchenStation.salad,
        ];

      case UserRole.cook:
        return [
          KitchenStation.grill,
          KitchenStation.saute,
          KitchenStation.fryer,
          KitchenStation.salad,
          KitchenStation.prep,
          KitchenStation.expo,
        ];

      case UserRole.cookSenior:
      case UserRole.chefAssistant:
        return [
          KitchenStation.grill,
          KitchenStation.saute,
          KitchenStation.fryer,
          KitchenStation.salad,
          KitchenStation.prep,
          KitchenStation.dish,
          KitchenStation.expo,
          KitchenStation.pastry, // Senior roles can handle pastry
        ];

      case UserRole.sousChef:
      case UserRole.chefHead:
      case UserRole.kitchenManager:
      case UserRole.generalManager:
      case UserRole.admin:
        return KitchenStation.values; // Can work any station

      case UserRole.expediter:
        return [
          KitchenStation.expo,
          KitchenStation.grill,
          KitchenStation.saute,
        ];
    }
  }

  /// Business rule: Specialized stations require experience
  bool requiresSpecializedTraining(KitchenStation station) {
    switch (station) {
      case KitchenStation.pastry:
        return true; // Pastry requires specialized skills
      case KitchenStation.grill:
        return _role == UserRole.dishwasher ||
            _role == UserRole.prepCook; // Hot station requires experience
      case KitchenStation.saute:
        return _role == UserRole.dishwasher ||
            _role == UserRole.prepCook; // Sauce work requires skill
      default:
        return false;
    }
  }

  /// Checks station hierarchy (senior staff can work junior stations)
  bool canSuperviseStation(KitchenStation station) {
    if (!isSeniorStaff) return false;

    // Senior staff can supervise any station they can work
    return canWorkAtStation(station);
  }

  /// Temporal Permissions and Shift-Based Access Control

  /// Checks if user has permission during specific shift
  bool hasTemporalPermission(
    TemporalPermission permission, {
    WorkShift? currentShift,
    Time? currentTime,
  }) {
    final currentShiftCalculated =
        currentShift ?? _getCurrentShift(currentTime ?? Time.now());
    final permissions = _getTemporalPermissions(_role, currentShiftCalculated);
    return permissions.contains(permission);
  }

  /// Gets current shift based on time
  WorkShift _getCurrentShift(Time time) {
    final hour = time.dateTime.hour;

    if (hour >= 5 && hour < 11) {
      return WorkShift.morningPrep;
    } else if (hour >= 11 && hour < 15) {
      return WorkShift.lunch;
    } else if (hour >= 15 && hour < 17) {
      return WorkShift.afternoonPrep;
    } else if (hour >= 17 && hour < 22) {
      return WorkShift.dinner;
    } else if (hour >= 22 || hour < 2) {
      return WorkShift.night;
    } else {
      return WorkShift.overnight;
    }
  }

  /// Gets temporal permissions based on role and shift
  List<TemporalPermission> _getTemporalPermissions(
    UserRole role,
    WorkShift shift,
  ) {
    final basePermissions = _getBaseTemporalPermissions(role);
    final shiftSpecificPermissions = _getShiftSpecificPermissions(role, shift);

    return [...basePermissions, ...shiftSpecificPermissions];
  }

  /// Base temporal permissions regardless of shift
  List<TemporalPermission> _getBaseTemporalPermissions(UserRole role) {
    switch (role) {
      case UserRole.dishwasher:
      case UserRole.prepCook:
        return [TemporalPermission.inventoryAccess];

      case UserRole.lineCook:
      case UserRole.cook:
        return [
          TemporalPermission.inventoryAccess,
          TemporalPermission.offHoursAccess,
        ];

      case UserRole.cookSenior:
      case UserRole.chefAssistant:
        return [
          TemporalPermission.inventoryAccess,
          TemporalPermission.offHoursAccess,
          TemporalPermission.authorizeOvertime,
        ];

      case UserRole.sousChef:
        return [
          TemporalPermission.inventoryAccess,
          TemporalPermission.offHoursAccess,
          TemporalPermission.authorizeOvertime,
          TemporalPermission.overrideClosing,
          TemporalPermission.openKitchen,
          TemporalPermission.modifySchedules,
          TemporalPermission.emergencyAccess,
        ];

      case UserRole.chefHead:
      case UserRole.kitchenManager:
        return [
          TemporalPermission.inventoryAccess,
          TemporalPermission.offHoursAccess,
          TemporalPermission.authorizeOvertime,
          TemporalPermission.overrideClosing,
          TemporalPermission.openKitchen,
          TemporalPermission.modifySchedules,
          TemporalPermission.businessHoursFinancials,
          TemporalPermission.emergencyAccess,
        ];

      case UserRole.generalManager:
      case UserRole.admin:
        return TemporalPermission.values; // All temporal permissions

      case UserRole.expediter:
        return [
          TemporalPermission.inventoryAccess,
          TemporalPermission.offHoursAccess,
        ];
    }
  }

  /// Shift-specific permissions
  List<TemporalPermission> _getShiftSpecificPermissions(
    UserRole role,
    WorkShift shift,
  ) {
    switch (shift) {
      case WorkShift.morningPrep:
        return _getMorningShiftPermissions(role);
      case WorkShift.lunch:
        return _getLunchShiftPermissions(role);
      case WorkShift.afternoonPrep:
        return _getAfternoonShiftPermissions(role);
      case WorkShift.dinner:
        return _getDinnerShiftPermissions(role);
      case WorkShift.night:
        return _getNightShiftPermissions(role);
      case WorkShift.overnight:
        return _getOvernightShiftPermissions(role);
    }
  }

  /// Morning prep shift permissions (5:00 AM - 11:00 AM)
  List<TemporalPermission> _getMorningShiftPermissions(UserRole role) {
    if (_isManagerOrAbove(role)) {
      return [TemporalPermission.openKitchen];
    }
    return [];
  }

  /// Lunch shift permissions (11:00 AM - 3:00 PM)
  List<TemporalPermission> _getLunchShiftPermissions(UserRole role) {
    if (_isManagerOrAbove(role)) {
      return [TemporalPermission.businessHoursFinancials];
    }
    return [];
  }

  /// Afternoon prep permissions (3:00 PM - 5:00 PM)
  List<TemporalPermission> _getAfternoonShiftPermissions(UserRole role) {
    // Standard permissions for afternoon prep
    return [];
  }

  /// Dinner shift permissions (5:00 PM - 10:00 PM)
  List<TemporalPermission> _getDinnerShiftPermissions(UserRole role) {
    if (_isManagerOrAbove(role)) {
      return [TemporalPermission.businessHoursFinancials];
    }
    return [];
  }

  /// Night shift permissions (10:00 PM - 2:00 AM)
  List<TemporalPermission> _getNightShiftPermissions(UserRole role) {
    if (_isManagerOrAbove(role)) {
      return [TemporalPermission.overrideClosing];
    }
    return [];
  }

  /// Overnight shift permissions (2:00 AM - 5:00 AM)
  List<TemporalPermission> _getOvernightShiftPermissions(UserRole role) {
    // Only senior management and cleaning crew should be here
    if (_role == UserRole.admin ||
        _role == UserRole.generalManager ||
        _role == UserRole.kitchenManager) {
      return [TemporalPermission.emergencyAccess];
    }
    return [];
  }

  /// Helper to check if role is manager level or above
  bool _isManagerOrAbove(UserRole role) {
    return [
      UserRole.sousChef,
      UserRole.chefHead,
      UserRole.kitchenManager,
      UserRole.generalManager,
      UserRole.admin,
    ].contains(role);
  }

  /// Business rule: Can user access kitchen during specific time?
  bool canAccessKitchenAtTime(Time time) {
    final shift = _getCurrentShift(time);

    // Basic kitchen access during operating hours (5 AM - 2 AM)
    final hour = time.dateTime.hour;
    final isOperatingHours = hour >= 5 || hour < 2;

    if (isOperatingHours) {
      return true; // Kitchen staff can access during operating hours
    }

    // Overnight access requires special permission
    return hasTemporalPermission(
      TemporalPermission.offHoursAccess,
      currentShift: shift,
    );
  }

  /// Business rule: Can user modify schedules during this shift?
  bool canModifySchedulesDuringShift(WorkShift shift) {
    return hasTemporalPermission(
      TemporalPermission.modifySchedules,
      currentShift: shift,
    );
  }

  /// Business rule: Can user access financial reports now?
  bool canAccessFinancialsNow({Time? currentTime}) {
    final time = currentTime ?? Time.now();
    final shift = _getCurrentShift(time);

    // Financial access typically restricted to business hours for security
    if (shift == WorkShift.lunch || shift == WorkShift.dinner) {
      return hasTemporalPermission(
        TemporalPermission.businessHoursFinancials,
        currentShift: shift,
      );
    }

    // Emergency access for senior management
    return hasTemporalPermission(
      TemporalPermission.emergencyAccess,
      currentShift: shift,
    );
  }

  /// Business rule: Can authorize overtime for staff?
  bool canAuthorizeOvertimeNow({Time? currentTime}) {
    final time = currentTime ?? Time.now();
    final shift = _getCurrentShift(time);
    return hasTemporalPermission(
      TemporalPermission.authorizeOvertime,
      currentShift: shift,
    );
  }

  /// Gets shift description for user role
  String getShiftDescription(WorkShift shift) {
    switch (shift) {
      case WorkShift.morningPrep:
        return 'Morning Prep (5:00 AM - 11:00 AM)';
      case WorkShift.lunch:
        return 'Lunch Service (11:00 AM - 3:00 PM)';
      case WorkShift.afternoonPrep:
        return 'Afternoon Prep (3:00 PM - 5:00 PM)';
      case WorkShift.dinner:
        return 'Dinner Service (5:00 PM - 10:00 PM)';
      case WorkShift.night:
        return 'Night Closing (10:00 PM - 2:00 AM)';
      case WorkShift.overnight:
        return 'Overnight Cleaning (2:00 AM - 5:00 AM)';
    }
  }

  /// Gets all temporal permissions for current role and shift
  List<TemporalPermission> getCurrentTemporalPermissions({Time? currentTime}) {
    final time = currentTime ?? Time.now();
    final shift = _getCurrentShift(time);
    return _getTemporalPermissions(_role, shift);
  }

  /// Command Hierarchy and Authority Level Management

  /// Gets the authority level for this user's role
  AuthorityLevel getAuthorityLevel() {
    switch (_role) {
      case UserRole.dishwasher:
      case UserRole.prepCook:
        return AuthorityLevel.entry;

      case UserRole.lineCook:
        return AuthorityLevel.basic;

      case UserRole.cook:
        return AuthorityLevel.experienced;

      case UserRole.cookSenior:
      case UserRole.chefAssistant:
      case UserRole.expediter:
        return AuthorityLevel.senior;

      case UserRole.sousChef:
      case UserRole.chefHead:
      case UserRole.kitchenManager:
        return AuthorityLevel.management;

      case UserRole.generalManager:
        return AuthorityLevel.executive;

      case UserRole.admin:
        return AuthorityLevel.system;
    }
  }

  /// Checks if this user can override another user's decision
  bool canOverrideUser(User otherUser) {
    final myAuthority = getAuthorityLevel();
    final theirAuthority = otherUser.getAuthorityLevel();

    return myAuthority.level > theirAuthority.level;
  }

  /// Checks if this user can override a specific command type
  bool canOverrideCommand(CommandType commandType, {User? originalCommander}) {
    final myAuthority = getAuthorityLevel();

    // If there's an original commander, check if we outrank them
    if (originalCommander != null) {
      if (!canOverrideUser(originalCommander)) {
        return false;
      }
    }

    // Check minimum authority required for each command type
    final requiredAuthority = _getRequiredAuthorityForCommand(commandType);
    return myAuthority.level >= requiredAuthority.level;
  }

  /// Gets minimum authority level required to override a command type
  AuthorityLevel _getRequiredAuthorityForCommand(CommandType commandType) {
    switch (commandType) {
      case CommandType.orderPreparation:
        return AuthorityLevel.basic; // Line cook can override prep instructions

      case CommandType.stationAssignment:
        return AuthorityLevel.senior; // Senior staff can reassign stations

      case CommandType.foodSafety:
        return AuthorityLevel
            .experienced; // Cook level can override safety calls

      case CommandType.inventoryManagement:
        return AuthorityLevel.senior; // Senior staff manage inventory

      case CommandType.scheduleChange:
        return AuthorityLevel.management; // Management changes schedules

      case CommandType.qualityControl:
        return AuthorityLevel.experienced; // Experienced staff control quality

      case CommandType.emergencyProcedure:
        return AuthorityLevel.senior; // Senior staff handle emergencies

      case CommandType.systemConfiguration:
        return AuthorityLevel.system; // Only admin can change system settings
    }
  }

  /// Validates a command override attempt
  bool validateCommandOverride({
    required CommandType commandType,
    required User originalCommander,
    required String reason,
  }) {
    // Basic authority check
    if (!canOverrideCommand(
      commandType,
      originalCommander: originalCommander,
    )) {
      return false;
    }

    // Business rules for specific command types
    switch (commandType) {
      case CommandType.foodSafety:
        // Food safety can always be escalated for safety
        return true;

      case CommandType.emergencyProcedure:
        // Emergency procedures can be escalated by senior staff
        return getAuthorityLevel().level >= AuthorityLevel.senior.level;

      case CommandType.orderPreparation:
        // Order changes require at least basic authority over original commander
        return canOverrideUser(originalCommander);

      case CommandType.stationAssignment:
        // Station assignments require senior authority
        return getAuthorityLevel().level >= AuthorityLevel.senior.level;

      case CommandType.scheduleChange:
        // Schedule changes require management authority
        return getAuthorityLevel().level >= AuthorityLevel.management.level;

      case CommandType.inventoryManagement:
      case CommandType.qualityControl:
        // These require appropriate authority level
        return getAuthorityLevel().level >=
            _getRequiredAuthorityForCommand(commandType).level;

      case CommandType.systemConfiguration:
        // System changes require admin authority
        return getAuthorityLevel() == AuthorityLevel.system;
    }
  }

  /// Gets list of command types this user can override
  List<CommandType> getOverridableCommands() {
    final myAuthority = getAuthorityLevel();
    return CommandType.values
        .where(
          (command) =>
              myAuthority.level >=
              _getRequiredAuthorityForCommand(command).level,
        )
        .toList();
  }

  /// Checks chain of command - who this user reports to
  List<UserRole> getChainOfCommand() {
    switch (_role) {
      case UserRole.dishwasher:
      case UserRole.prepCook:
        return [UserRole.cookSenior, UserRole.sousChef, UserRole.chefHead];

      case UserRole.lineCook:
        return [
          UserRole.cook,
          UserRole.cookSenior,
          UserRole.sousChef,
          UserRole.chefHead,
        ];

      case UserRole.cook:
        return [UserRole.cookSenior, UserRole.sousChef, UserRole.chefHead];

      case UserRole.cookSenior:
      case UserRole.chefAssistant:
        return [UserRole.sousChef, UserRole.chefHead];

      case UserRole.sousChef:
        return [UserRole.chefHead];

      case UserRole.chefHead:
        return [UserRole.kitchenManager, UserRole.generalManager];

      case UserRole.expediter:
        return [
          UserRole.sousChef,
          UserRole.chefHead,
        ]; // Expediter reports to kitchen management

      case UserRole.kitchenManager:
        return [UserRole.generalManager];

      case UserRole.generalManager:
        return []; // Top of chain

      case UserRole.admin:
        return []; // Separate authority structure
    }
  }

  /// Checks if this user is in the direct chain of command above another user
  bool isInChainOfCommandAbove(User subordinate) {
    final subordinateChain = subordinate.getChainOfCommand();
    return subordinateChain.contains(_role);
  }

  /// Gets immediate supervisor role
  UserRole? getImmediateSupervisor() {
    final chain = getChainOfCommand();
    return chain.isNotEmpty ? chain.first : null;
  }

  /// Business rule: Can this user delegate authority to another user?
  bool canDelegateAuthority(User delegateToUser, CommandType commandType) {
    // Can only delegate to someone in your chain of command (below you)
    if (!isInChainOfCommandAbove(delegateToUser)) {
      return false;
    }

    // Can only delegate commands you can execute yourself
    if (!canOverrideCommand(commandType)) {
      return false;
    }

    // Cannot delegate system configuration (admin only)
    if (commandType == CommandType.systemConfiguration) {
      return false;
    }

    // Special rule: Cannot delegate station assignments to expediter (different role)
    if (commandType == CommandType.stationAssignment &&
        delegateToUser._role == UserRole.expediter) {
      return false;
    }

    return true;
  }

  /// Emergency escalation - bypass normal hierarchy in emergencies
  bool canEmergencyEscalate(CommandType commandType) {
    // Food safety can always be escalated by anyone
    if (commandType == CommandType.foodSafety) {
      return true;
    }

    // Emergency procedures require senior authority (not everyone should escalate)
    if (commandType == CommandType.emergencyProcedure) {
      return getAuthorityLevel().level >= AuthorityLevel.senior.level;
    }

    // Senior staff can escalate most decisions
    return getAuthorityLevel().level >= AuthorityLevel.senior.level;
  }

  /// Food Safety Certification and Training Requirements

  /// Gets required certifications for this user's role
  List<CertificationType> getRequiredCertifications() {
    switch (_role) {
      case UserRole.dishwasher:
        return [
          CertificationType.foodSafety,
          CertificationType.equipmentOperation,
        ];

      case UserRole.prepCook:
        return [
          CertificationType.foodSafety,
          CertificationType.allergenAwareness,
          CertificationType.equipmentOperation,
        ];

      case UserRole.lineCook:
        return [
          CertificationType.foodSafety,
          CertificationType.allergenAwareness,
          CertificationType.stationSpecific,
          CertificationType.equipmentOperation,
          CertificationType.fireSafety,
        ];

      case UserRole.cook:
      case UserRole.cookSenior:
        return [
          CertificationType.foodSafety,
          CertificationType.allergenAwareness,
          CertificationType.stationSpecific,
          CertificationType.equipmentOperation,
          CertificationType.fireSafety,
          CertificationType.haccp,
        ];

      case UserRole.chefAssistant:
      case UserRole.sousChef:
        return [
          CertificationType.foodSafety,
          CertificationType.allergenAwareness,
          CertificationType.stationSpecific,
          CertificationType.equipmentOperation,
          CertificationType.fireSafety,
          CertificationType.haccp,
          CertificationType.management,
        ];

      case UserRole.chefHead:
      case UserRole.kitchenManager:
        return [
          CertificationType.foodSafety,
          CertificationType.allergenAwareness,
          CertificationType.stationSpecific,
          CertificationType.equipmentOperation,
          CertificationType.fireSafety,
          CertificationType.haccp,
          CertificationType.management,
          CertificationType.alcoholService,
        ];

      case UserRole.expediter:
        return [
          CertificationType.foodSafety,
          CertificationType.allergenAwareness,
          CertificationType.fireSafety,
        ];

      case UserRole.generalManager:
        return [
          CertificationType.foodSafety,
          CertificationType.management,
          CertificationType.alcoholService,
          CertificationType.fireSafety,
        ];

      case UserRole.admin:
        return [
          CertificationType.foodSafety, // Basic food safety for kitchen access
          CertificationType.management,
          CertificationType.haccp,
        ]; // Admin needs basic certifications to oversee kitchen operations
    }
  }

  /// Checks if user role requires specific certification
  bool requiresCertification(CertificationType certification) {
    return getRequiredCertifications().contains(certification);
  }

  /// Business rule: Can work station only with proper certification
  bool canWorkStationWithCertification(
    KitchenStation station,
    List<CertificationType> currentCertifications,
  ) {
    // Basic station access check
    if (!canWorkAtStation(station)) {
      return false;
    }

    // Must have food safety for any station
    if (!currentCertifications.contains(CertificationType.foodSafety)) {
      return false;
    }

    // Hot stations require fire safety
    if (_isHotStation(station) &&
        !currentCertifications.contains(CertificationType.fireSafety)) {
      return false;
    }

    // Specialized stations require station-specific training
    if (_requiresStationSpecificTraining(station) &&
        !currentCertifications.contains(CertificationType.stationSpecific)) {
      return false;
    }

    return true;
  }

  /// Checks if station is a hot station requiring fire safety
  bool _isHotStation(KitchenStation station) {
    return [
      KitchenStation.grill,
      KitchenStation.saute,
      KitchenStation.fryer,
    ].contains(station);
  }

  /// Checks if station requires specialized training
  bool _requiresStationSpecificTraining(KitchenStation station) {
    return [
      KitchenStation.grill,
      KitchenStation.saute,
      KitchenStation.pastry,
    ].contains(station);
  }

  /// Gets certification expiry rules for role
  Duration getCertificationValidityPeriod(CertificationType certification) {
    switch (certification) {
      case CertificationType.foodSafety:
        return const Duration(days: 365 * 2); // 2 years

      case CertificationType.allergenAwareness:
        return const Duration(days: 365); // 1 year

      case CertificationType.haccp:
        return const Duration(days: 365 * 3); // 3 years

      case CertificationType.fireSafety:
        return const Duration(days: 365); // 1 year

      case CertificationType.alcoholService:
        return const Duration(days: 365 * 2); // 2 years

      case CertificationType.management:
        return const Duration(days: 365 * 3); // 3 years

      case CertificationType.stationSpecific:
        return const Duration(days: 365); // 1 year (skills refresh)

      case CertificationType.equipmentOperation:
        return const Duration(days: 365 * 2); // 2 years
    }
  }

  /// Business rule: Validates if user can supervise with proper certifications
  bool canSuperviseWithCertifications(
    List<CertificationType> currentCertifications,
  ) {
    if (!isSeniorStaff) return false;

    // Must have management certification for supervisory roles
    if (_isManagerOrAbove(_role) &&
        !currentCertifications.contains(CertificationType.management)) {
      return false;
    }

    // Must have HACCP for senior food safety oversight
    if (canManageHACCP() &&
        !currentCertifications.contains(CertificationType.haccp)) {
      return false;
    }

    return true;
  }

  /// Gets training progression path for role advancement
  List<CertificationType> getTrainingProgression(UserRole targetRole) {
    final currentRequired = getRequiredCertifications();
    final targetRequired = _getRequiredCertificationsForRole(targetRole);

    // Return additional certifications needed for target role
    return targetRequired
        .where((cert) => !currentRequired.contains(cert))
        .toList();
  }

  /// Helper to get required certifications for any role
  List<CertificationType> _getRequiredCertificationsForRole(UserRole role) {
    // Create temporary user to get certifications
    final tempUser = User(
      id: UserId('temp'),
      email: 'temp@temp.com',
      name: 'Temp',
      role: role,
      createdAt: Time.now(),
    );
    return tempUser.getRequiredCertifications();
  }

  /// Gets display name for the user
  String getDisplayName() {
    return _name;
  }

  /// Gets user initials
  String getInitials() {
    final nameParts = _name.split(' ');
    if (nameParts.isEmpty) return '';

    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }

    return nameParts
        .take(3) // Take first 3 parts maximum
        .map((part) => part.isNotEmpty ? part[0].toUpperCase() : '')
        .where((initial) => initial.isNotEmpty)
        .join('');
  }

  /// Emergency Protocols and Safety Procedures

  /// Can this user initiate emergency protocols?
  bool canInitiateEmergencyProtocol(EmergencyType emergencyType) {
    switch (emergencyType) {
      case EmergencyType.fire:
        // Any kitchen staff can initiate fire emergency
        return _isKitchenStaff();

      case EmergencyType.foodSafety:
        // Food handlers and above can initiate food safety protocols
        return _hasFoodHandlingResponsibility();

      case EmergencyType.medical:
        // Any staff member can initiate medical emergency
        return true;

      case EmergencyType.equipmentFailure:
        // Staff working with equipment can initiate
        return _worksWithEquipment();

      case EmergencyType.security:
        // Management and supervisory roles can initiate
        return _hasManagementAuthority();

      case EmergencyType.chemical:
        // Kitchen staff and management can initiate
        return _isKitchenStaff();

      case EmergencyType.powerOutage:
        // Management roles can initiate
        return _hasManagementAuthority();

      case EmergencyType.gasLeak:
        // Kitchen staff can initiate
        return _isKitchenStaff();
    }
  }

  /// Can this user override normal operations during emergency?
  bool canOverrideDuringEmergency(EmergencyType emergencyType) {
    switch (emergencyType) {
      case EmergencyType.fire:
      case EmergencyType.gasLeak:
      case EmergencyType.medical:
        // Senior staff can override for life-safety emergencies
        return _role.index >= UserRole.chefAssistant.index;

      case EmergencyType.foodSafety:
        // Food safety certified staff can override
        return _hasFoodSafetyAuthority();

      case EmergencyType.equipmentFailure:
      case EmergencyType.powerOutage:
        // Management can override for operational emergencies
        return _hasManagementAuthority();

      case EmergencyType.security:
        // Senior management can override for security
        return _role.index >= UserRole.kitchenManager.index;

      case EmergencyType.chemical:
        // Trained staff can override for chemical emergencies
        return _hasHazardTraining();
    }
  }

  /// Can this user authorize emergency evacuation?
  bool canAuthorizeEvacuation() {
    // Assistant chef level and above can authorize evacuation
    return _role.index >= UserRole.chefAssistant.index;
  }

  /// Can this user coordinate emergency response?
  bool canCoordinateEmergencyResponse(EmergencyType emergencyType) {
    switch (emergencyType) {
      case EmergencyType.fire:
      case EmergencyType.gasLeak:
      case EmergencyType.medical:
        // Sous chef and above can coordinate life-safety emergencies
        return _role.index >= UserRole.sousChef.index;

      case EmergencyType.foodSafety:
        // Food safety authority can coordinate
        return _hasFoodSafetyAuthority();

      case EmergencyType.equipmentFailure:
      case EmergencyType.powerOutage:
        // Kitchen manager and above can coordinate operational emergencies
        return _role.index >= UserRole.kitchenManager.index;

      case EmergencyType.security:
        // General manager and above can coordinate security emergencies
        return _role.index >= UserRole.generalManager.index;

      case EmergencyType.chemical:
        // Head chef and above with hazard training can coordinate
        return _role.index >= UserRole.chefHead.index && _hasHazardTraining();
    }
  }

  /// Emergency escalation chain - who to notify for emergencies
  List<UserRole> getEmergencyEscalationChain(EmergencyType emergencyType) {
    switch (emergencyType) {
      case EmergencyType.fire:
      case EmergencyType.gasLeak:
      case EmergencyType.medical:
        // Life-safety: escalate through kitchen hierarchy
        return [
          UserRole.chefAssistant,
          UserRole.sousChef,
          UserRole.chefHead,
          UserRole.kitchenManager,
          UserRole.generalManager,
        ];

      case EmergencyType.foodSafety:
        // Food safety: escalate through food safety authority
        return [
          UserRole.sousChef,
          UserRole.chefHead,
          UserRole.kitchenManager,
          UserRole.generalManager,
        ];

      case EmergencyType.equipmentFailure:
        // Equipment: escalate through operational hierarchy
        return [
          UserRole.chefAssistant,
          UserRole.sousChef,
          UserRole.kitchenManager,
          UserRole.generalManager,
        ];

      case EmergencyType.security:
        // Security: escalate directly to management
        return [UserRole.kitchenManager, UserRole.generalManager];

      case EmergencyType.chemical:
        // Chemical: escalate through trained hierarchy
        return [
          UserRole.chefHead,
          UserRole.kitchenManager,
          UserRole.generalManager,
        ];

      case EmergencyType.powerOutage:
        // Power: escalate through management
        return [UserRole.kitchenManager, UserRole.generalManager];
    }
  }

  /// Helper methods for emergency protocol authorization

  bool _isKitchenStaff() {
    return _role != UserRole.admin && _role != UserRole.generalManager;
  }

  bool _hasFoodHandlingResponsibility() {
    return [
      UserRole.prepCook,
      UserRole.lineCook,
      UserRole.cook,
      UserRole.cookSenior,
      UserRole.chefAssistant,
      UserRole.sousChef,
      UserRole.chefHead,
      UserRole.kitchenManager,
    ].contains(_role);
  }

  bool _worksWithEquipment() {
    return _role != UserRole.admin && _role != UserRole.generalManager;
  }

  bool _hasFoodSafetyAuthority() {
    return [
      UserRole.sousChef,
      UserRole.chefHead,
      UserRole.kitchenManager,
      UserRole.generalManager,
      UserRole.admin,
    ].contains(_role);
  }

  bool _hasHazardTraining() {
    // Assume senior roles have hazard training
    return _role.index >= UserRole.chefHead.index;
  }

  bool _hasManagementAuthority() {
    return [
      UserRole.chefAssistant,
      UserRole.sousChef,
      UserRole.chefHead,
      UserRole.kitchenManager,
      UserRole.generalManager,
      UserRole.admin,
    ].contains(_role);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() {
    return 'User(id: $_id, name: $_name, role: ${_role.name})';
  }
}
