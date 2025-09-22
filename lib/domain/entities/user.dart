import '../value_objects/user_id.dart';
import '../value_objects/time.dart';
import '../exceptions/domain_exception.dart';

/// User roles in the kitchen system
enum UserRole { kitchenStaff, manager, admin }

/// User permissions in the system
enum Permission {
  viewOrders,
  updateOrderStatus,
  manageUsers,
  accessReports,
  manageStations,
  deleteOrders,
  manageSystem,
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
  bool get isKitchenStaff => _role == UserRole.kitchenStaff;
  bool get isManager => _role == UserRole.manager;
  bool get isAdmin => _role == UserRole.admin;

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
    final sessionDuration = now.difference(_lastLoginAt!);
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

  /// Permission checking methods
  bool canViewOrders() => hasPermission(Permission.viewOrders);
  bool canUpdateOrderStatus() => hasPermission(Permission.updateOrderStatus);
  bool canManageUsers() => hasPermission(Permission.manageUsers);
  bool canAccessReports() => hasPermission(Permission.accessReports);
  bool canManageStations() => hasPermission(Permission.manageStations);
  bool canDeleteOrders() => hasPermission(Permission.deleteOrders);
  bool canManageSystem() => hasPermission(Permission.manageSystem);

  /// Checks if user has specific permission
  bool hasPermission(Permission permission) {
    switch (_role) {
      case UserRole.kitchenStaff:
        return _getKitchenStaffPermissions().contains(permission);
      case UserRole.manager:
        return _getManagerPermissions().contains(permission);
      case UserRole.admin:
        return _getAdminPermissions().contains(permission);
    }
  }

  /// Gets permissions for kitchen staff
  List<Permission> _getKitchenStaffPermissions() {
    return [Permission.viewOrders, Permission.updateOrderStatus];
  }

  /// Gets permissions for manager
  List<Permission> _getManagerPermissions() {
    return [
      Permission.viewOrders,
      Permission.updateOrderStatus,
      Permission.manageUsers,
      Permission.accessReports,
      Permission.manageStations,
      Permission.deleteOrders,
    ];
  }

  /// Gets permissions for admin
  List<Permission> _getAdminPermissions() {
    return [
      Permission.viewOrders,
      Permission.updateOrderStatus,
      Permission.manageUsers,
      Permission.accessReports,
      Permission.manageStations,
      Permission.deleteOrders,
      Permission.manageSystem,
    ];
  }

  /// Checks if user can perform a specific action
  bool canPerformAction(String action) {
    switch (action) {
      case 'VIEW_ORDERS':
        return canViewOrders();
      case 'UPDATE_ORDER_STATUS':
        return canUpdateOrderStatus();
      case 'MANAGE_USERS':
        return canManageUsers();
      case 'ACCESS_REPORTS':
        return canAccessReports();
      case 'MANAGE_STATIONS':
        return canManageStations();
      case 'DELETE_ORDERS':
        return canDeleteOrders();
      case 'MANAGE_SYSTEM':
        return canManageSystem();
      default:
        return false;
    }
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
