// Base Event for all BLoC events in the presentation layer
// Provides common structure and behavior for all events

import 'package:equatable/equatable.dart';

/// Base class for all BLoC events
///
/// All events should extend this class to ensure consistency
/// and proper equality comparison for testing and debugging
abstract class BaseEvent extends Equatable {
  const BaseEvent();

  @override
  List<Object?> get props => [];

  /// Optional timestamp for event tracking
  DateTime get timestamp => DateTime.now();

  /// Event name for debugging and logging
  String get eventName => runtimeType.toString();

  @override
  String toString() => '$eventName(timestamp: $timestamp)';
}

/// Common events that can be used across different BLoCs

/// Event to trigger data loading
class LoadDataEvent extends BaseEvent {
  const LoadDataEvent();

  @override
  List<Object?> get props => [];
}

/// Event to refresh data
class RefreshDataEvent extends BaseEvent {
  const RefreshDataEvent();

  @override
  List<Object?> get props => [];
}

/// Event to clear data/state
class ClearDataEvent extends BaseEvent {
  const ClearDataEvent();

  @override
  List<Object?> get props => [];
}

/// Event to retry a failed operation
class RetryEvent extends BaseEvent {
  final String? operationId;

  const RetryEvent({this.operationId});

  @override
  List<Object?> get props => [operationId];
}

/// Event for handling user actions
class UserActionEvent extends BaseEvent {
  final String action;
  final Map<String, dynamic>? data;

  const UserActionEvent({required this.action, this.data});

  @override
  List<Object?> get props => [action, data];
}
