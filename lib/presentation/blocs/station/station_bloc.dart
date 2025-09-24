// Station BLoC - Simplified Working Version
// Basic station management for kitchen operations

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/base_bloc.dart';
import 'station_event.dart';
import 'station_state.dart';
import '../../../domain/entities/station.dart' as domain;
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/time.dart';

/// Simple StationBloc implementation with mock data for initial testing
class StationBloc extends BaseBloc<StationEvent, StationState> {
  final List<domain.Station> _stations = [];

  StationBloc() : super(StationInitialState()) {
    on<LoadStationsEvent>(_onLoadStations);
    on<UpdateStationStatusEvent>(_onUpdateStationStatus);
  }

  Future<void> _onLoadStations(
    LoadStationsEvent event,
    Emitter<StationState> emit,
  ) async {
    emit(StationLoadingState(operation: 'Loading stations'));

    // Generate mock stations for testing
    final stations = _generateMockStations();
    _stations.clear();
    _stations.addAll(stations);

    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading

    emit(StationsLoadedState(stations: _stations));
  }

  Future<void> _onUpdateStationStatus(
    UpdateStationStatusEvent event,
    Emitter<StationState> emit,
  ) async {
    emit(StationLoadingState(operation: 'Updating station status'));

    // Find and update station
    final index = _stations.indexWhere(
      (station) => station.id.value == event.stationId,
    );
    if (index == -1) {
      emit(
        StationErrorState(
          message: 'Station not found',
          operation: 'Update status',
        ),
      );
      return;
    }

    try {
      // Create updated station
      final currentStation = _stations[index];
      final updatedStation = _createUpdatedStation(currentStation, event);
      _stations[index] = updatedStation;

      emit(
        StationOperationSuccessState(
          message: 'Station status updated successfully',
          updatedStation: updatedStation,
        ),
      );

      // Emit updated stations list
      await Future.delayed(const Duration(milliseconds: 200));
      emit(StationsLoadedState(stations: List.from(_stations)));
    } catch (e) {
      emit(
        StationErrorState(
          message: 'Failed to update station status: $e',
          operation: 'Update status',
        ),
      );
    }
  }

  domain.Station _createUpdatedStation(
    domain.Station currentStation,
    UpdateStationStatusEvent event,
  ) {
    // Create a new station with updated status
    return domain.Station(
      id: currentStation.id,
      name: currentStation.name,
      capacity: currentStation.capacity,
      location: currentStation.location,
      stationType: currentStation.stationType,
      status: _mapPresentationStatusToDomain(event.status),
      isActive: event.status == StationStatus.active,
      currentWorkload: currentStation.currentWorkload,
      assignedStaff: currentStation.assignedStaff,
      currentOrders: currentStation.currentOrders,
      createdAt: currentStation.createdAt,
    );
  }

  // Helper method to map presentation status to domain status
  domain.StationStatus _mapPresentationStatusToDomain(
    StationStatus presentationStatus,
  ) {
    switch (presentationStatus) {
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

  List<domain.Station> _generateMockStations() {
    return [
      domain.Station(
        id: UserId('station-grill-001'),
        name: 'Grill Station 1',
        capacity: 6,
        location: 'Kitchen - North Wall',
        stationType: domain.StationType.grill,
        status: domain.StationStatus.available,
        isActive: true,
        currentWorkload: 3,
        assignedStaff: [UserId('staff-001'), UserId('staff-002')],
        currentOrders: ['order-001', 'order-003'],
        createdAt: Time.now(),
      ),
      domain.Station(
        id: UserId('station-fryer-001'),
        name: 'Fryer Station 1',
        capacity: 4,
        location: 'Kitchen - East Wall',
        stationType: domain.StationType.fryer,
        status: domain.StationStatus.busy,
        isActive: true,
        currentWorkload: 2,
        assignedStaff: [UserId('staff-003')],
        currentOrders: ['order-002'],
        createdAt: Time.fromDateTime(
          DateTime.now().subtract(const Duration(days: 1)),
        ),
      ),
      domain.Station(
        id: UserId('station-salad-001'),
        name: 'Salad Prep Station',
        capacity: 3,
        location: 'Kitchen - Cold Prep Area',
        stationType: domain.StationType.salad,
        status: domain.StationStatus.available,
        isActive: true,
        currentWorkload: 1,
        assignedStaff: [UserId('staff-004')],
        currentOrders: ['order-004'],
        createdAt: Time.fromDateTime(
          DateTime.now().subtract(const Duration(days: 2)),
        ),
      ),
      domain.Station(
        id: UserId('station-prep-001'),
        name: 'Prep Station 1',
        capacity: 8,
        location: 'Kitchen - Central Island',
        stationType: domain.StationType.prep,
        status: domain.StationStatus.maintenance,
        isActive: false,
        currentWorkload: 0,
        assignedStaff: [],
        currentOrders: [],
        createdAt: Time.fromDateTime(
          DateTime.now().subtract(const Duration(days: 5)),
        ),
      ),
      domain.Station(
        id: UserId('station-expedite-001'),
        name: 'Expedite Station',
        capacity: 10,
        location: 'Kitchen - Pass Window',
        stationType: domain
            .StationType
            .beverage, // Changed from expedite to beverage (domain doesn't have expedite)
        status: domain.StationStatus.busy,
        isActive: true,
        currentWorkload: 5,
        assignedStaff: [UserId('staff-005'), UserId('staff-006')],
        currentOrders: ['order-001', 'order-002', 'order-003'],
        createdAt: Time.fromDateTime(
          DateTime.now().subtract(const Duration(hours: 12)),
        ),
      ),
    ];
  }
}
