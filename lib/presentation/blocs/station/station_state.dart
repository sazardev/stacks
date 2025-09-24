// Station BLoC States
// States for kitchen station management, workload distribution, and operational status

import '../../core/base_state.dart';
import '../../../domain/entities/station.dart';
import '../../../domain/failures/failures.dart';

/// Base station state
abstract class StationState extends BaseState {}

/// Initial state when StationBloc is first created
class StationInitialState extends StationState {
  @override
  List<Object> get props => [];
}

/// Loading state during station operations
class StationLoadingState extends StationState {
  final String? operation;

  StationLoadingState({this.operation});

  @override
  List<Object?> get props => [operation];
}

/// State when stations are successfully loaded
class StationsLoadedState extends StationState {
  final List<Station> stations;
  final List<Station> filteredStations;

  StationsLoadedState({required this.stations, List<Station>? filteredStations})
    : filteredStations = filteredStations ?? stations;

  @override
  List<Object> get props => [stations, filteredStations];

  /// Helper methods for UI
  List<Station> get activeStations =>
      filteredStations.where((station) => station.isActive).toList();

  List<Station> get availableStations => filteredStations
      .where((station) => station.hasAvailableCapacity)
      .toList();

  List<Station> get busyStations =>
      filteredStations.where((station) => station.isAtCapacity).toList();

  int get totalStations => filteredStations.length;
  int get activeStationCount => activeStations.length;
  double get averageCapacityUtilization => filteredStations.isEmpty
      ? 0.0
      : filteredStations
                .map((s) => s.workloadPercentage)
                .reduce((a, b) => a + b) /
            filteredStations.length;
}

/// State when a single station is loaded with details
class StationDetailsLoadedState extends StationState {
  final Station station;

  StationDetailsLoadedState({required this.station});

  @override
  List<Object> get props => [station];
}

/// State when a station operation is successful
class StationOperationSuccessState extends StationState {
  final String message;
  final Station? updatedStation;

  StationOperationSuccessState({required this.message, this.updatedStation});

  @override
  List<Object?> get props => [message, updatedStation];
}

/// Error state for station operations
class StationErrorState extends StationState {
  final String message;
  final Failure? failure;
  final String? operation;

  StationErrorState({required this.message, this.failure, this.operation});

  @override
  List<Object?> get props => [message, failure, operation];

  /// Create error state from failure
  factory StationErrorState.fromFailure(Failure failure, {String? operation}) {
    String message;

    if (failure is ValidationFailure) {
      message = 'Invalid station data: ${failure.message}';
    } else if (failure is NetworkFailure) {
      message = 'Network error. Please check your connection.';
    } else if (failure is PermissionFailure) {
      message = 'You don\'t have permission for this operation.';
    } else if (failure is ServerFailure) {
      message = 'Server error. Please try again later.';
    } else {
      message = failure.message.isNotEmpty
          ? failure.message
          : 'An error occurred';
    }

    return StationErrorState(
      message: message,
      failure: failure,
      operation: operation,
    );
  }
}

/// State when stations are being filtered
class StationsFilteredState extends StationState {
  final List<Station> allStations;
  final List<Station> filteredStations;
  final Map<String, dynamic> activeFilters;

  StationsFilteredState({
    required this.allStations,
    required this.filteredStations,
    required this.activeFilters,
  });

  @override
  List<Object> get props => [allStations, filteredStations, activeFilters];

  bool get hasActiveFilters => activeFilters.isNotEmpty;
  int get filterResultCount => filteredStations.length;
}

/// State for station assignment operations
class StationAssignmentState extends StationState {
  final Station station;
  final String chefName;
  final bool isAssigning;

  StationAssignmentState({
    required this.station,
    required this.chefName,
    this.isAssigning = false,
  });

  @override
  List<Object> get props => [station, chefName, isAssigning];
}

/// State when no stations are available
class StationsEmptyState extends StationState {
  final String message;

  StationsEmptyState({this.message = 'No stations available'});

  @override
  List<Object> get props => [message];
}

/// State for station workload information
class StationWorkloadState extends StationState {
  final Station station;
  final int currentOrders;
  final int pendingOrders;
  final double utilizationPercentage;
  final Duration averageOrderTime;

  StationWorkloadState({
    required this.station,
    required this.currentOrders,
    required this.pendingOrders,
    required this.utilizationPercentage,
    required this.averageOrderTime,
  });

  @override
  List<Object> get props => [
    station,
    currentOrders,
    pendingOrders,
    utilizationPercentage,
    averageOrderTime,
  ];

  /// Helper getters for UI
  bool get isOverloaded => utilizationPercentage > 90.0;
  bool get isUnderUtilized => utilizationPercentage < 30.0;
  bool get isOptimal =>
      utilizationPercentage >= 30.0 && utilizationPercentage <= 90.0;
}

/// State for optimized station assignments
class StationAssignmentsOptimizedState extends StationState {
  final List<StationAssignment> optimizedAssignments;
  final double improvementPercentage;
  final String optimizationSummary;

  StationAssignmentsOptimizedState({
    required this.optimizedAssignments,
    required this.improvementPercentage,
    required this.optimizationSummary,
  });

  @override
  List<Object> get props => [
    optimizedAssignments,
    improvementPercentage,
    optimizationSummary,
  ];
}

/// Helper class for station assignments
class StationAssignment {
  final Station station;
  final String chefName;
  final int expectedOrders;
  final Duration expectedDuration;

  StationAssignment({
    required this.station,
    required this.chefName,
    required this.expectedOrders,
    required this.expectedDuration,
  });
}
