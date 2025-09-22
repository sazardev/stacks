import '../exceptions/domain_exception.dart';

/// Money value object representing monetary amounts with currency
class Money {
  static const List<String> _supportedCurrencies = ['USD', 'EUR', 'GBP', 'CAD'];
  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'CAD': 'C\$',
  };

  final double _amount;
  final String _currency;

  /// Creates a Money instance with the specified amount and currency
  ///
  /// [amount] must be non-negative
  /// [currency] must be a supported currency (USD, EUR, GBP, CAD)
  Money(double amount, {String? currency})
    : _amount = _validateAndRoundAmount(amount),
      _currency = _validateCurrency(currency ?? 'USD');

  /// Creates a Money instance from cents (integer value)
  Money.fromCents(int cents, {String? currency})
    : _amount = _validateAndRoundAmount(cents / 100.0),
      _currency = _validateCurrency(currency ?? 'USD');

  /// The monetary amount
  double get amount => _amount;

  /// The currency code
  String get currency => _currency;

  /// Converts the amount to cents
  int toCents() => (_amount * 100).round();

  /// Validates and rounds amount to 2 decimal places
  static double _validateAndRoundAmount(double amount) {
    if (amount < 0) {
      throw const ValueObjectException('Money amount cannot be negative');
    }

    // Round to 2 decimal places to handle floating point precision
    return double.parse(amount.toStringAsFixed(2));
  }

  /// Validates currency code
  static String _validateCurrency(String? currency) {
    if (currency == null || currency.isEmpty) {
      throw const ValueObjectException('Currency cannot be null or empty');
    }

    if (!_supportedCurrencies.contains(currency)) {
      throw ValueObjectException('Unsupported currency: $currency');
    }

    return currency;
  }

  /// Adds another Money amount (must be same currency)
  Money add(Money other) {
    _validateSameCurrency(other);
    return Money(_amount + other._amount, currency: _currency);
  }

  /// Subtracts another Money amount (must be same currency)
  Money subtract(Money other) {
    _validateSameCurrency(other);

    final result = _amount - other._amount;
    if (result < 0) {
      throw const BusinessRuleException(
        'Subtraction cannot result in negative amount',
      );
    }

    return Money(result, currency: _currency);
  }

  /// Multiplies the Money amount by a factor
  Money multiply(num factor) {
    if (factor < 0) {
      throw const BusinessRuleException(
        'Cannot multiply money by negative factor',
      );
    }

    return Money(_amount * factor, currency: _currency);
  }

  /// Validates that two Money instances have the same currency
  void _validateSameCurrency(Money other) {
    if (_currency != other._currency) {
      throw BusinessRuleException(
        'Cannot perform operation on different currencies: $_currency vs ${other._currency}',
      );
    }
  }

  /// Checks if this Money amount is greater than another
  bool isGreaterThan(Money other) {
    _validateSameCurrency(other);
    return _amount > other._amount;
  }

  /// Checks if this Money amount is less than another
  bool isLessThan(Money other) {
    _validateSameCurrency(other);
    return _amount < other._amount;
  }

  /// Checks if this Money amount is equal to another
  bool isEqualTo(Money other) {
    _validateSameCurrency(other);
    return _amount == other._amount;
  }

  /// Checks if this Money amount is greater than or equal to another
  bool isGreaterThanOrEqual(Money other) {
    _validateSameCurrency(other);
    return _amount >= other._amount;
  }

  /// Checks if this Money amount is less than or equal to another
  bool isLessThanOrEqual(Money other) {
    _validateSameCurrency(other);
    return _amount <= other._amount;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          runtimeType == other.runtimeType &&
          _amount == other._amount &&
          _currency == other._currency;

  @override
  int get hashCode => Object.hash(_amount, _currency);

  @override
  String toString() {
    final symbol = _currencySymbols[_currency] ?? _currency;
    return '$symbol${_amount.toStringAsFixed(2)}';
  }
}
