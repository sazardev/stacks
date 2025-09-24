// Station BLoC
// Business logic for kitchen station management, workload distribution, and operational status

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

import '../../core/base_bloc.dart';
import 'station_event.dart';
import 'station_state.dart';
import '../../../application/use_cases/station/station_use_cases.dart';
import '../../../application/dtos/station_dtos.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/entities/station.dart' as domain;

/// BLoC for managing kitchen station operations
/// Handles station lifecycle, assignments, and workload management
class StationBloc extends BaseBloc<StationEvent, StationState> {
  final GetAllStationsUseCase _getAllStationsUseCase;
  final GetStationByIdUseCase _getStationByIdUseCase;
  final CreateStationUseCase _createStationUseCase;
  final UpdateStationUseCase _updateStationUseCase;
  final AssignStaffToStationUseCase _assignStaffToStationUseCase;
  final RemoveStaffFromStationUseCase _removeStaffFromStationUseCase;

  // Internal state management
  List<Station> _allStations = <Station>[];
  List<Station> _filteredStations = <Station>[];
  Map<String, dynamic> _activeFilters = <String, dynamic>{};

  StationBloc({
    required GetAllStationsUseCase getAllStationsUseCase,
    required GetStationByIdUseCase getStationByIdUseCase,
    required CreateStationUseCase createStationUseCase,
    required UpdateStationUseCase updateStationUseCase,
    required AssignStaffToStationUseCase assignStaffToStationUseCase,
    required RemoveStaffFromStationUseCase removeStaffFromStationUseCase,
  }) : _getAllStationsUseCase = getAllStationsUseCase,
       _getStationByIdUseCase = getStationByIdUseCase,
       _createStationUseCase = createStationUseCase,
       _updateStationUseCase = updateStationUseCase,
       _assignStaffToStationUseCase = assignStaffToStationUseCase,
       _removeStaffFromStationUseCase = removeStaffFromStationUseCase,
       super(StationInitialState()) {
    // Register event handlers
    on<LoadStationsEvent>(_onLoadStations);
    on<CreateStationEvent>(_onCreateStation);
    on<UpdateStationEvent>(_onUpdateStation);
    on<AssignChefToStationEvent>(_onAssignChefToStation);
    on<UnassignChefFromStationEvent>(_onUnassignChefFromStation);
    on<UpdateStationStatusEvent>(_onUpdateStationStatus);
    on<GetStationDetailsEvent>(_onGetStationDetails);
    on<GetStationsByTypeEvent>(_onGetStationsByType);
    on<GetAvailableStationsEvent>(_onGetAvailableStations);
    on<UpdateStationCapacityEvent>(_onUpdateStationCapacity);
    on<RefreshStationsEvent>(_onRefreshStations);
    on<FilterStationsEvent>(_onFilterStations);
    on<GetStationWorkloadEvent>(_onGetStationWorkload);
    on<OptimizeStationAssignmentsEvent>(_onOptimizeStationAssignments);
  }

  /// Load stations from repository
  Future<void> _onLoadStations(
    LoadStationsEvent event,
    Emitter<StationState> emit,
  ) async {
    emit(StationLoadingState(operation: 'Loading stations'));

    final result = await _getAllStationsUseCase();

    result.fold(
      (failure) => emit(
        StationErrorState.fromFailure(failure, operation: 'Load stations'),
      ),
      (stations) {
        _allStations = stations;

        // Filter out inactive stations if requested
        if (!event.includeInactive) {
          _allStations = _allStations
              .where((station) => station.isActive)
              .toList();
        }

        _filteredStations = _allStations;

        if (_filteredStations.isEmpty) {
          emit(StationsEmptyState(message: 'No stations found'));
        } else {
          emit(
            StationsLoadedState(
              stations: _allStations,
              filteredStations: _filteredStations,
            ),
          );
        }
      },
    );
  }

  /// Create a new station
  Future<void> _onCreateStation(
    CreateStationEvent event,
    Emitter<StationState> emit,
  ) async {
    emit(StationLoadingState(operation: 'Creating station'));

    final result = await _createStationUseCase(event.stationDto);

    result.fold(
      (failure) => emit(
        StationErrorState.fromFailure(failure, operation: 'Create station'),
      ),
      (station) {
        _allStations = [station, ..._allStations];
        _filteredStations = _applyCurrentFilters(_allStations);

        emit(
          StationOperationSuccessState(
            message: 'Station "${station.name}" created successfully',
            updatedStation: station,
          ),
        );

        // Update stations list state
        emit(
          StationsLoadedState(
            stations: _allStations,
            filteredStations: _filteredStations,
          ),
        );
      },
    );
  }

  /// Update station information
  Future<void> _onUpdateStation(
    UpdateStationEvent event,
    Emitter<StationState> emit,
  ) async {
    emit(StationLoadingState(operation: 'Updating station'));

    final result = await _updateStationUseCase(
      event.stationId,
      event.updateDto,
    );

    result.fold(
      (failure) => emit(
        StationErrorState.fromFailure(failure, operation: 'Update station'),
      ),
      (updatedStation) {
        _updateStationInList(updatedStation);

        emit(
          StationOperationSuccessState(
            message: 'Station updated successfully',
            updatedStation: updatedStation,
          ),
        );

        // Update stations list state
        emit(
          StationsLoadedState(
            stations: _allStations,
            filteredStations: _filteredStations,
          ),
        );
      },
    );
  }

  /// Assign chef to station
  Future<void> _onAssignChefToStation(
    AssignChefToStationEvent event,
    Emitter<StationState> emit,
  ) async {
    emit(StationLoadingState(operation: 'Assigning chef to station'));

    final result = await _assignStaffToStationUseCase(
      event.stationId,
      event.chefId,
    );

    result.fold(
      (failure) => emit(
        StationErrorState.fromFailure(failure, operation: 'Assign chef'),
      ),
      (updatedStation) {
        _updateStationInList(updatedStation);

        emit(
          StationOperationSuccessState(
            message: 'Chef assigned to station successfully',
            updatedStation: updatedStation,
          ),
        );

        // Update stations list state
        emit(
          StationsLoadedState(
            stations: _allStations,
            filteredStations: _filteredStations,
          ),
        );
      },
    );
  }

  /// Unassign chef from station
  Future<void> _onUnassignChefFromStation(
    UnassignChefFromStationEvent event,
    Emitter<StationState> emit,
  ) async {
    emit(StationLoadingState(operation: 'Unassigning chef from station'));

    final result = await _removeStaffFromStationUseCase(
      event.stationId,
      event.chefId,
    );

    result.fold(
      (failure) => emit(
        StationErrorState.fromFailure(failure, operation: 'Unassign chef'),
      ),
      (updatedStation) {
        _updateStationInList(updatedStation);

        emit(
          StationOperationSuccessState(
            message: 'Chef unassigned from station successfully',
            updatedStation: updatedStation,
          ),
        );

        // Update stations list state
        emit(
          StationsLoadedState(
            stations: _allStations,
            filteredStations: _filteredStations,
          ),
        );
      },
    );
  }

  /// Update station status
  Future<void> _onUpdateStationStatus(
    UpdateStationStatusEvent event,
    Emitter<StationState> emit,
  ) async {
    emit(StationLoadingState(operation: 'Updating station status'));

    // Convert event status to domain status
    final updateDto = UpdateStationDto(
      stationId: event.stationId,
      status: _convertToDomainStatus(event.status),
      reason: event.reason,
    );

    final result = await _updateStationUseCase(event.stationId, updateDto);

    result.fold(
      (failure) => emit(
        StationErrorState.fromFailure(failure, operation: 'Update status'),
      ),
      (updatedStation) {
        _updateStationInList(updatedStation);

        emit(
          StationOperationSuccessState(
            message: 'Station status updated to ${event.status.name}',
            updatedStation: updatedStation,
          ),
        );

        // Update stations list state
        emit(
          StationsLoadedState(
            stations: _allStations,
            filteredStations: _filteredStations,
          ),
        );
      },
    );
  }

  /// Get station details
  Future<void> _onGetStationDetails(
    GetStationDetailsEvent event,
    Emitter<StationState> emit,
  ) async {
    emit(StationLoadingState(operation: 'Loading station details'));

    final result = await _getStationByIdUseCase(event.stationId);

    result.fold(
      (failure) => emit(
        StationErrorState.fromFailure(
          failure,
          operation: 'Load station details',
        ),
      ),
      (station) => emit(StationDetailsLoadedState(station: station)),
    );
  }

  /// Get stations by type
  Future<void> _onGetStationsByType(
    GetStationsByTypeEvent event,
    Emitter<StationState> emit,
  ) async {
    final filteredByType = _allStations
        .where(
          (station) =>
              _convertToDomainType(event.stationType) == station.stationType,
        )
        .toList();

    emit(
      StationsLoadedState(
        stations: _allStations,
        filteredStations: filteredByType,
      ),
    );
  }

  /// Get available stations
  Future<void> _onGetAvailableStations(
    GetAvailableStationsEvent event,
    Emitter<StationState> emit,
  ) async {
    final availableStations = _allStations
        .where((station) => station.hasAvailableCapacity && station.isActive)
        .toList();

    emit(
      StationsLoadedState(
        stations: _allStations,
        filteredStations: availableStations,
      ),
    );
  }

  /// Update station capacity
  Future<void> _onUpdateStationCapacity(
    UpdateStationCapacityEvent event,
    Emitter<StationState> emit,
  ) async {
    emit(StationLoadingState(operation: 'Updating station capacity'));

    final updateDto = UpdateStationDto(
      stationId: event.stationId,
      capacity: event.newCapacity,
    );

    final result = await _updateStationUseCase(event.stationId, updateDto);

    result.fold(
      (failure) => emit(
        StationErrorState.fromFailure(failure, operation: 'Update capacity'),
      ),
      (updatedStation) {
        _updateStationInList(updatedStation);

        emit(
          StationOperationSuccessState(
            message: 'Station capacity updated to ${event.newCapacity}',
            updatedStation: updatedStation,
          ),
        );

        // Update stations list state
        emit(
          StationsLoadedState(
            stations: _allStations,
            filteredStations: _filteredStations,
          ),
        );
      },
    );
  }

  /// Refresh stations
  Future<void> _onRefreshStations(
    RefreshStationsEvent event,
    Emitter<StationState> emit,
  ) async {
    add(LoadStationsEvent());
  }

  /// Filter stations
  Future<void> _onFilterStations(
    FilterStationsEvent event,
    Emitter<StationState> emit,
  ) async {
    _activeFilters = <String, dynamic>{
      if (event.type != null) 'type': event.type,
      if (event.status != null) 'status': event.status,
      if (event.hasAvailableCapacity != null)
        'hasAvailableCapacity': event.hasAvailableCapacity,
      if (event.searchQuery != null && event.searchQuery!.isNotEmpty)
        'searchQuery': event.searchQuery,
    };

    _filteredStations = _applyCurrentFilters(_allStations);

    emit(
      StationsFilteredState(
        allStations: _allStations,
        filteredStations: _filteredStations,
        activeFilters: Map<String, dynamic>.from(_activeFilters),
      ),
    );
  }

  /// Get station workload
  Future<void> _onGetStationWorkload(
    GetStationWorkloadEvent event,
    Emitter<StationState> emit,
  ) async {
    emit(StationLoadingState(operation: 'Loading station workload'));

    final result = await _getStationByIdUseCase(event.stationId);

    result.fold(
      (failure) => emit(
        StationErrorState.fromFailure(failure, operation: 'Load workload'),
      ),
      (station) {
        // Calculate workload metrics
        final currentOrders = station.currentOrders.length;
        final pendingOrders = 0; // This would come from order repository
        final utilizationPercentage = station.workloadPercentage;
        final averageOrderTime = const Duration(minutes: 15); // Mock data

        emit(
          StationWorkloadState(
            station: station,
            currentOrders: currentOrders,
            pendingOrders: pendingOrders,
            utilizationPercentage: utilizationPercentage,
            averageOrderTime: averageOrderTime,
          ),
        );
      },
    );
  }

  /// Optimize station assignments
  Future<void> _onOptimizeStationAssignments(
    OptimizeStationAssignmentsEvent event,
    Emitter<StationState> emit,
  ) async {
    emit(StationLoadingState(operation: 'Optimizing station assignments'));

    // Mock optimization logic - in real implementation this would be more complex
    final optimizedAssignments = _allStations.map((station) {
      return StationAssignment(
        station: station,
        chefName: 'Chef ${station.assignedStaff.length + 1}',
        expectedOrders: station.capacity - station.currentWorkload,
        expectedDuration: Duration(
          minutes: (station.workloadPercentage / 10).round(),
        ),
      );
    }).toList();

    final improvementPercentage = 15.0; // Mock improvement
    const optimizationSummary =
        'Assignments optimized for better workload distribution';

    emit(
      StationAssignmentsOptimizedState(
        optimizedAssignments: optimizedAssignments,
        improvementPercentage: improvementPercentage,
        optimizationSummary: optimizationSummary,
      ),
    );
  }

  // Helper methods

  /// Apply current active filters
  List<Station> _applyCurrentFilters(List<Station> stations) {
    var filtered = stations;

    if (_activeFilters.containsKey('type')) {
      final type = _activeFilters['type'] as StationType;
      final domainType = _convertToDomainType(type);
      filtered = filtered
          .where((station) => station.stationType == domainType)
          .toList();
    }

    if (_activeFilters.containsKey('status')) {
      final status = _activeFilters['status'] as StationStatus;
      final domainStatus = _convertToDomainStatus(status);
      filtered = filtered
          .where((station) => station.status == domainStatus)
          .toList();
    }

    if (_activeFilters.containsKey('hasAvailableCapacity')) {
      final hasCapacity = _activeFilters['hasAvailableCapacity'] as bool;
      filtered = filtered
          .where((station) => station.hasAvailableCapacity == hasCapacity)
          .toList();
    }

    if (_activeFilters.containsKey('searchQuery')) {
      final query = _activeFilters['searchQuery'] as String;
      filtered = filtered
          .where(
            (station) =>
                station.name.toLowerCase().contains(query.toLowerCase()) ||
                (station.location?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }

    return filtered;
  }

  /// Update station in the local list
  void _updateStationInList(Station updatedStation) {
    final index = _allStations.indexWhere(
      (station) => station.id == updatedStation.id,
    );
    if (index != -1) {
      _allStations[index] = updatedStation;
      _filteredStations = _applyCurrentFilters(_allStations);
    }
  }

  /// Convert presentation layer StationType to domain StationType
  domain.StationType _convertToDomainType(StationType type) {
    switch (type) {
      case StationType.grill:
        return domain.StationType.grill;
      case StationType.fryer:
        return domain.StationType.fryer;
      case StationType.salad:
        return domain.StationType.salad;
      case StationType.dessert:
        return domain.StationType.dessert;
      case StationType.beverage:
        return domain.StationType.beverage;
      case StationType.prep:
        return domain.StationType.prep;
      case StationType.expedite:
        return domain
            .StationType
            .grill; // Fallback - would need to add expedite to domain
    }
  }

  /// Convert presentation layer StationStatus to domain StationStatus
  domain.StationStatus _convertToDomainStatus(StationStatus status) {
    switch (status) {
      case StationStatus.active:
        return domain.StationStatus.available;
      case StationStatus.inactive:
        return domain.StationStatus.offline;
      case StationStatus.maintenance:
        return domain.StationStatus.maintenance;
      case StationStatus.outOfOrder:
        return domain.StationStatus.offline;
    }
  }

  // Public helper methods for UI

  /// Get stations by status
  List<Station> getStationsByStatus(StationStatus status) {
    final domainStatus = _convertToDomainStatus(status);
    return _filteredStations
        .where((station) => station.status == domainStatus)
        .toList();
  }

  /// Check if user can perform operation on station
  bool canPerformOperation(
    Station station,
    String operation, {
    required bool isManager,
  }) {
    switch (operation) {
      case 'assign':
        return isManager && station.hasAvailableCapacity;
      case 'unassign':
        return isManager && station.assignedStaff.isNotEmpty;
      case 'update_capacity':
        return isManager;
      case 'change_status':
        return isManager;
      case 'delete':
        return isManager && !station.isActive;
      default:
        return false;
    }
  }
}
