/// Base exception for domain layer business rule violations
class DomainException implements Exception {
  final String message;

  const DomainException(this.message);

  @override
  String toString() => 'DomainException: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DomainException &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Exception thrown when a value object validation fails
class ValueObjectException extends DomainException {
  const ValueObjectException(super.message);

  @override
  String toString() => 'ValueObjectException: $message';
}

/// Exception thrown when business rule validation fails
class BusinessRuleException extends DomainException {
  const BusinessRuleException(super.message);

  @override
  String toString() => 'BusinessRuleException: $message';
}

/// Exception thrown when entity invariant is violated
class EntityInvariantException extends DomainException {
  const EntityInvariantException(super.message);

  @override
  String toString() => 'EntityInvariantException: $message';
}
