// Base State for all BLoC states in the presentation layer
// Provides common structure and behavior for all states

import 'package:equatable/equatable.dart';

/// Base class for all BLoC states
///
/// All states should extend this class to ensure consistency
/// and proper equality comparison for BLoC rebuilds
abstract class BaseState extends Equatable {
  const BaseState();

  @override
  List<Object?> get props => [];

  /// Timestamp when the state was created
  DateTime get timestamp => DateTime.now();

  /// State name for debugging and logging
  String get stateName => runtimeType.toString();

  /// Whether this state represents a loading condition
  bool get isLoading => false;

  /// Whether this state represents an error condition
  bool get hasError => false;

  /// Whether this state represents a success condition
  bool get isSuccess => false;

  /// Whether this state represents an initial/empty condition
  bool get isInitial => false;

  @override
  String toString() => '$stateName(timestamp: $timestamp)';
}

/// Common states that can be used across different BLoCs

/// Initial state when BLoC is first created
class InitialState extends BaseState {
  const InitialState();

  @override
  bool get isInitial => true;

  @override
  List<Object?> get props => [];
}

/// Loading state for async operations
class LoadingState extends BaseState {
  final String? message;

  const LoadingState({this.message});

  @override
  bool get isLoading => true;

  @override
  List<Object?> get props => [message];
}

/// Success state for completed operations
class SuccessState<T> extends BaseState {
  final T? data;
  final String? message;

  const SuccessState({this.data, this.message});

  @override
  bool get isSuccess => true;

  @override
  List<Object?> get props => [data, message];
}

/// Error state for failed operations
class ErrorState extends BaseState {
  final String message;
  final String? errorCode;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const ErrorState({
    required this.message,
    this.errorCode,
    this.originalError,
    this.stackTrace,
  });

  @override
  bool get hasError => true;

  @override
  List<Object?> get props => [message, errorCode, originalError];
}

/// Empty state when no data is available
class EmptyState extends BaseState {
  final String? message;

  const EmptyState({this.message});

  @override
  List<Object?> get props => [message];
}

/// State for partial data updates (useful for real-time features)
class PartialUpdateState<T> extends BaseState {
  final T updatedData;
  final String updateType;

  const PartialUpdateState({
    required this.updatedData,
    required this.updateType,
  });

  @override
  List<Object?> get props => [updatedData, updateType];
}
