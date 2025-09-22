import '../exceptions/domain_exception.dart';

/// UserId value object representing a unique identifier for users in the system
class UserId implements Comparable<UserId> {
  static const int _maxLength = 255;
  static const List<String> _systemUserIds = ['system', 'admin', 'root'];
  static const List<String> _anonymousUserIds = ['anonymous', 'guest'];

  final String _value;

  /// Creates a UserId with the specified value
  ///
  /// [value] must be non-empty, valid format, and within length limits
  UserId(String value) : _value = _validateUserId(value);

  /// Creates a UserId from an email address
  UserId.fromEmail(String email) : _value = _validateEmail(email);

  /// Generates a new UserId with a UUID
  UserId.generate() : _value = _generateUuid();

  /// The user ID value
  String get value => _value;

  /// Validates the user ID format and constraints
  static String _validateUserId(String value) {
    if (value.isEmpty) {
      throw const ValueObjectException('User ID cannot be empty');
    }

    if (value.length > _maxLength) {
      throw ValueObjectException(
        'User ID cannot exceed $_maxLength characters',
      );
    }

    // Allow UUIDs, emails, and alphanumeric strings with common separators
    final validPattern = RegExp(r'^[a-zA-Z0-9@._+-]+$');
    if (!validPattern.hasMatch(value)) {
      throw ValueObjectException('User ID contains invalid characters: $value');
    }

    return value;
  }

  /// Validates email format
  static String _validateEmail(String email) {
    if (email.isEmpty) {
      throw const ValueObjectException('Email cannot be empty');
    }

    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailPattern.hasMatch(email)) {
      throw ValueObjectException('Invalid email format: $email');
    }

    return _validateUserId(email);
  }

  /// Generates a UUID-like string (simplified for domain layer)
  static String _generateUuid() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode.abs();

    // Create a simple UUID-like format
    final hex = random.toRadixString(16).padLeft(12, '0');
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-4${hex.substring(4, 7)}-a${hex.substring(1, 4)}-${hex.substring(0, 8)}${hex.substring(8, 12)}';
  }

  /// Checks if the user ID is in UUID format
  bool get isUuid {
    final uuidPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidPattern.hasMatch(_value);
  }

  /// Checks if the user ID is in email format
  bool get isEmail {
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailPattern.hasMatch(_value);
  }

  /// Checks if this is a system user ID
  bool get isSystemUser {
    return _systemUserIds.contains(_value.toLowerCase());
  }

  /// Checks if this is an anonymous user ID
  bool get isAnonymous {
    return _anonymousUserIds.contains(_value.toLowerCase());
  }

  /// Gets the domain part of an email user ID
  String? get emailDomain {
    if (!isEmail) return null;
    return _value.split('@')[1];
  }

  /// Gets the username part of an email user ID
  String? get emailUsername {
    if (!isEmail) return null;
    return _value.split('@')[0];
  }

  /// Gets a display-friendly name for the user
  String getDisplayName() {
    if (isEmail) {
      return emailUsername!;
    }
    return _value;
  }

  /// Obfuscates the user ID for privacy/logging purposes
  String obfuscate() {
    if (isEmail) {
      final parts = _value.split('@');
      final username = parts[0];
      final domain = parts[1];

      if (username.length <= 3) {
        return '${username[0]}*${username.length > 1 ? username[username.length - 1] : ''}@$domain';
      }

      return '${username.substring(0, 1)}***${username.substring(username.length - 3)}@$domain';
    }

    if (_value.length <= 3) {
      return _value.length == 1
          ? '*'
          : '${_value[0]}*${_value[_value.length - 1]}';
    }

    return '${_value.substring(0, 3)}***${_value.substring(_value.length - 3)}';
  }

  @override
  int compareTo(UserId other) {
    return _value.compareTo(other._value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserId &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() {
    return _value;
  }
}
