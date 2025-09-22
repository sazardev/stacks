import '../exceptions/domain_exception.dart';

/// Time value object representing a specific moment in time with kitchen operations context
class Time {
  final DateTime _dateTime;

  /// Creates a Time from a DateTime
  Time.fromDateTime(DateTime dateTime) : _dateTime = dateTime;

  /// Creates a Time from milliseconds since epoch
  Time.fromMillisecondsSinceEpoch(int milliseconds)
    : _dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  /// Creates a Time representing the current moment
  Time.now() : _dateTime = DateTime.now();

  /// Creates a Time from an ISO 8601 string
  Time.fromIsoString(String isoString) : _dateTime = _parseIsoString(isoString);

  /// The underlying DateTime
  DateTime get dateTime => _dateTime;

  /// Milliseconds since epoch
  int get millisecondsSinceEpoch => _dateTime.millisecondsSinceEpoch;

  /// Parses ISO string with error handling
  static DateTime _parseIsoString(String isoString) {
    try {
      return DateTime.parse(isoString);
    } catch (e) {
      throw ValueObjectException('Invalid ISO date string: $isoString');
    }
  }

  /// Adds a duration to this time
  Time add(Duration duration) {
    return Time.fromDateTime(_dateTime.add(duration));
  }

  /// Subtracts a duration from this time
  Time subtract(Duration duration) {
    return Time.fromDateTime(_dateTime.subtract(duration));
  }

  /// Calculates the difference between this time and another time
  Duration difference(Time other) {
    return _dateTime.difference(other._dateTime);
  }

  /// Calculates minutes until another time (negative if in the past)
  int minutesUntil(Time other) {
    return other._dateTime.difference(_dateTime).inMinutes;
  }

  /// Calculates minutes since another time (negative if other is in the future)
  int minutesSince(Time other) {
    return _dateTime.difference(other._dateTime).inMinutes;
  }

  /// Checks if this time is after another time
  bool isAfter(Time other) {
    return _dateTime.isAfter(other._dateTime);
  }

  /// Checks if this time is before another time
  bool isBefore(Time other) {
    return _dateTime.isBefore(other._dateTime);
  }

  /// Checks if this time is at the same moment as another time
  bool isAtSameMomentAs(Time other) {
    return _dateTime.isAtSameMomentAs(other._dateTime);
  }

  /// Checks if this time is after or at the same moment as another time
  bool isAfterOrAt(Time other) {
    return isAfter(other) || isAtSameMomentAs(other);
  }

  /// Checks if this time is before or at the same moment as another time
  bool isBeforeOrAt(Time other) {
    return isBefore(other) || isAtSameMomentAs(other);
  }

  /// Checks if this time is in the past
  bool isInPast() {
    return _dateTime.isBefore(DateTime.now());
  }

  /// Checks if this time is in the future
  bool isInFuture() {
    return _dateTime.isAfter(DateTime.now());
  }

  /// Checks if this time is today
  bool isToday() {
    final now = DateTime.now();
    return _dateTime.year == now.year &&
        _dateTime.month == now.month &&
        _dateTime.day == now.day;
  }

  /// Checks if this time is within business hours (9 AM to 9 PM)
  bool isWithinBusinessHours() {
    final hour = _dateTime.hour;
    return hour >= 9 && hour < 21; // 9 AM to 9 PM
  }

  /// Checks if this time is within rush hours (11 AM-2 PM or 6-8 PM)
  bool isWithinRushHours() {
    final hour = _dateTime.hour;
    // Lunch rush: 11 AM to 2 PM
    final isLunchRush = hour >= 11 && hour < 14;
    // Dinner rush: 6 PM to 8 PM
    final isDinnerRush = hour >= 18 && hour < 20;
    return isLunchRush || isDinnerRush;
  }

  /// Checks if this time exceeds a timeout relative to a base time
  bool exceedsTimeout(Time baseTime, int timeoutMinutes) {
    final timeoutDuration = Duration(minutes: timeoutMinutes);
    final timeoutTime = baseTime.add(timeoutDuration);
    return isAfter(timeoutTime);
  }

  /// Formats time for display (e.g., "2:30 PM")
  String formatForDisplay() {
    final hour = _dateTime.hour == 0
        ? 12
        : (_dateTime.hour > 12 ? _dateTime.hour - 12 : _dateTime.hour);
    final minute = _dateTime.minute.toString().padLeft(2, '0');
    final period = _dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Formats time with seconds for display (e.g., "2:30:45 PM")
  String formatWithSeconds() {
    final hour = _dateTime.hour == 0
        ? 12
        : (_dateTime.hour > 12 ? _dateTime.hour - 12 : _dateTime.hour);
    final minute = _dateTime.minute.toString().padLeft(2, '0');
    final second = _dateTime.second.toString().padLeft(2, '0');
    final period = _dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute:$second $period';
  }

  /// Formats date for display (e.g., "Jan 15, 2024")
  String formatDateForDisplay() {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final monthName = monthNames[_dateTime.month - 1];
    return '$monthName ${_dateTime.day}, ${_dateTime.year}';
  }

  /// Formats relative time (e.g., "5 minutes ago", "2 hours ago")
  String formatRelative() {
    final now = DateTime.now();
    final difference = now.difference(_dateTime);

    if (difference.inDays > 0) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
  }

  /// Returns ISO 8601 string representation
  String toIsoString() {
    return _dateTime.toUtc().toIso8601String();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Time &&
          runtimeType == other.runtimeType &&
          _dateTime == other._dateTime;

  @override
  int get hashCode => _dateTime.hashCode;

  @override
  String toString() {
    return toIsoString();
  }
}
