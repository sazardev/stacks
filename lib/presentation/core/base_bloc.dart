// Base BLoC for all BLoCs in the presentation layer
// Provides common functionality and error handling

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/failures/failures.dart' as domain_failures;
import 'base_event.dart';
import 'base_state.dart';

/// Base class for all BLoCs in the application
///
/// Provides common functionality such as:
/// - Error handling and mapping
/// - Logging and debugging
/// - State transition validation
/// - Common event handling patterns
abstract class BaseBloc<Event extends BaseEvent, State extends BaseState>
    extends Bloc<Event, State> {
  /// Constructor that sets initial state
  BaseBloc(super.initialState);

  /// Maps domain failures to user-friendly error states
  ErrorState mapFailureToErrorState(domain_failures.Failure failure) {
    if (failure is domain_failures.NetworkFailure) {
      return const ErrorState(
        message: 'Network error. Please check your connection.',
        errorCode: 'NETWORK_ERROR',
      );
    } else if (failure is domain_failures.ServerFailure) {
      return const ErrorState(
        message: 'Server error. Please try again later.',
        errorCode: 'SERVER_ERROR',
      );
    } else if (failure is domain_failures.ValidationFailure) {
      return ErrorState(
        message: failure.message,
        errorCode: 'VALIDATION_ERROR',
      );
    } else if (failure is domain_failures.NotFoundFailure) {
      return const ErrorState(
        message: 'Requested item not found.',
        errorCode: 'NOT_FOUND_ERROR',
      );
    } else if (failure is domain_failures.BusinessRuleFailure) {
      return ErrorState(
        message: failure.message,
        errorCode: 'BUSINESS_RULE_ERROR',
      );
    } else {
      return ErrorState(message: failure.message, errorCode: 'UNKNOWN_ERROR');
    }
  }

  /// Safely executes an async operation and handles errors
  Future<void> safeExecute<T>({
    required Future<T> Function() operation,
    required void Function(T result) onSuccess,
    void Function(ErrorState error)? onError,
    void Function()? onLoading,
  }) async {
    try {
      onLoading?.call();
      final result = await operation();
      onSuccess(result);
    } catch (error, stackTrace) {
      final errorState = _handleError(error, stackTrace);
      onError?.call(errorState);
    }
  }

  /// Handles errors and creates appropriate error states
  ErrorState _handleError(dynamic error, StackTrace stackTrace) {
    if (error is domain_failures.Failure) {
      return mapFailureToErrorState(error);
    } else {
      return ErrorState(
        message: 'An unexpected error occurred: ${error.toString()}',
        errorCode: 'UNEXPECTED_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Logs state transitions for debugging
  @override
  void onTransition(Transition<Event, State> transition) {
    super.onTransition(transition);
    // In development, log state transitions
    // In production, you might want to send to analytics
    print(
      '$runtimeType: ${transition.currentState.runtimeType} -> ${transition.nextState.runtimeType}',
    );
  }

  /// Logs errors for debugging and crash reporting
  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    // Log error for debugging and crash reporting
    print('$runtimeType Error: $error');
    print('StackTrace: $stackTrace');
  }
}
