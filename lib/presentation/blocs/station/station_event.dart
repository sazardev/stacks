// Station BLoC Events
// Events for kitchen station management, workload distribution, and operational status

import '../../core/base_event.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../application/dtos/station_dtos.dart';

/// Base station event
abstract class StationEvent extends BaseEvent {}

/// Event to load all stations
class LoadStationsEvent extends StationEvent {
  final bool includeInactive;

  LoadStationsEvent({this.includeInactive = false});

  @override
  List<Object> get props => [includeInactive];
}

/// Event to create a new station
class CreateStationEvent extends StationEvent {
  final CreateStationDto stationDto;

  CreateStationEvent({required this.stationDto});

  @override
  List<Object> get props => [stationDto];
}

/// Event to update station information
class UpdateStationEvent extends StationEvent {
  final UserId stationId;
  final UpdateStationDto updateDto;

  UpdateStationEvent({required this.stationId, required this.updateDto});

  @override
  List<Object> get props => [stationId, updateDto];
}

/// Event to assign chef to station
class AssignChefToStationEvent extends StationEvent {
  final UserId stationId;
  final UserId chefId;
  final UserId assignedByUserId;

  AssignChefToStationEvent({
    required this.stationId,
    required this.chefId,
    required this.assignedByUserId,
  });

  @override
  List<Object> get props => [stationId, chefId, assignedByUserId];
}

/// Event to unassign chef from station
class UnassignChefFromStationEvent extends StationEvent {
  final UserId stationId;
  final UserId chefId;
  final UserId unassignedByUserId;

  UnassignChefFromStationEvent({
    required this.stationId,
    required this.chefId,
    required this.unassignedByUserId,
  });

  @override
  List<Object> get props => [stationId, chefId, unassignedByUserId];
}

/// Event to update station status
class UpdateStationStatusEvent extends StationEvent {
  final UserId stationId;
  final StationStatus status;
  final String? reason;

  UpdateStationStatusEvent({
    required this.stationId,
    required this.status,
    this.reason,
  });

  @override
  List<Object?> get props => [stationId, status, reason];
}

/// Event to get station details by ID
class GetStationDetailsEvent extends StationEvent {
  final UserId stationId;

  GetStationDetailsEvent({required this.stationId});

  @override
  List<Object> get props => [stationId];
}

/// Event to get stations by type
class GetStationsByTypeEvent extends StationEvent {
  final StationType stationType;

  GetStationsByTypeEvent({required this.stationType});

  @override
  List<Object> get props => [stationType];
}

/// Event to get available stations (not at capacity)
class GetAvailableStationsEvent extends StationEvent {
  @override
  List<Object> get props => [];
}

/// Event to update station capacity
class UpdateStationCapacityEvent extends StationEvent {
  final UserId stationId;
  final int newCapacity;
  final UserId updatedByUserId;

  UpdateStationCapacityEvent({
    required this.stationId,
    required this.newCapacity,
    required this.updatedByUserId,
  });

  @override
  List<Object> get props => [stationId, newCapacity, updatedByUserId];
}

/// Event to refresh station data
class RefreshStationsEvent extends StationEvent {
  @override
  List<Object> get props => [];
}

/// Event to filter stations by criteria
class FilterStationsEvent extends StationEvent {
  final StationType? type;
  final StationStatus? status;
  final bool? hasAvailableCapacity;
  final String? searchQuery;

  FilterStationsEvent({
    this.type,
    this.status,
    this.hasAvailableCapacity,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [type, status, hasAvailableCapacity, searchQuery];
}

/// Event to get station workload
class GetStationWorkloadEvent extends StationEvent {
  final UserId stationId;

  GetStationWorkloadEvent({required this.stationId});

  @override
  List<Object> get props => [stationId];
}

/// Event to optimize station assignments
class OptimizeStationAssignmentsEvent extends StationEvent {
  final UserId optimizedByUserId;

  OptimizeStationAssignmentsEvent({required this.optimizedByUserId});

  @override
  List<Object> get props => [optimizedByUserId];
}

/// Station status enum for status updates
enum StationStatus { active, inactive, maintenance, outOfOrder }

/// Station type enum for filtering
enum StationType { grill, fryer, salad, dessert, beverage, prep, expedite }
