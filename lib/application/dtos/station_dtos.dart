import 'package:equatable/equatable.dart';
import '../../domain/entities/station.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';

/// DTO for creating a station
class CreateStationDto extends Equatable {
  final String name;
  final int capacity;
  final String? location;
  final String stationType;
  final List<String>? assignedStaff;
  final List<String>? currentOrders;

  const CreateStationDto({
    required this.name,
    required this.capacity,
    this.location,
    required this.stationType,
    this.assignedStaff,
    this.currentOrders,
  });

  /// Convert DTO to Station entity
  Station toEntity() {
    return Station(
      id: UserId.generate(),
      name: name,
      capacity: capacity,
      location: location,
      stationType: _parseStationType(stationType),
      assignedStaff: assignedStaff?.map((id) => UserId(id)).toList(),
      currentOrders: currentOrders,
      createdAt: Time.now(),
    );
  }

  StationType _parseStationType(String type) {
    switch (type.toLowerCase()) {
      case 'grill':
        return StationType.grill;
      case 'prep':
        return StationType.prep;
      case 'fryer':
        return StationType.fryer;
      case 'salad':
        return StationType.salad;
      case 'dessert':
        return StationType.dessert;
      case 'beverage':
        return StationType.beverage;
      default:
        return StationType.prep;
    }
  }

  @override
  List<Object?> get props => [
    name,
    capacity,
    location,
    stationType,
    assignedStaff,
    currentOrders,
  ];
}

/// DTO for updating a station
class UpdateStationDto extends Equatable {
  final String id;
  final String? name;
  final int? capacity;
  final String? location;
  final String? stationType;
  final String? status;
  final bool? isActive;
  final int? currentWorkload;
  final List<String>? assignedStaff;
  final List<String>? currentOrders;

  const UpdateStationDto({
    required this.id,
    this.name,
    this.capacity,
    this.location,
    this.stationType,
    this.status,
    this.isActive,
    this.currentWorkload,
    this.assignedStaff,
    this.currentOrders,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    capacity,
    location,
    stationType,
    status,
    isActive,
    currentWorkload,
    assignedStaff,
    currentOrders,
  ];
}

/// DTO for station status changes
class StationStatusDto extends Equatable {
  final String stationId;
  final String status;

  const StationStatusDto({required this.stationId, required this.status});

  @override
  List<Object?> get props => [stationId, status];
}

/// DTO for assigning order to station
class AssignOrderToStationDto extends Equatable {
  final UserId orderId;
  final UserId stationId;

  const AssignOrderToStationDto({
    required this.orderId,
    required this.stationId,
  });

  @override
  List<Object?> get props => [orderId, stationId];
}

/// DTO for managing station workload
class ManageStationWorkloadDto extends Equatable {
  final UserId stationId;
  final int workload;

  const ManageStationWorkloadDto({
    required this.stationId,
    required this.workload,
  });

  @override
  List<Object?> get props => [stationId, workload];
}

/// DTO for tracking preparation time
class TrackPreparationTimeDto extends Equatable {
  final UserId orderId;
  final UserId stationId;
  final int actualTimeMinutes;
  final int estimatedTimeMinutes;

  const TrackPreparationTimeDto({
    required this.orderId,
    required this.stationId,
    required this.actualTimeMinutes,
    required this.estimatedTimeMinutes,
  });

  @override
  List<Object?> get props => [
    orderId,
    stationId,
    actualTimeMinutes,
    estimatedTimeMinutes,
  ];
}

/// DTO for station queries
class StationQueryDto extends Equatable {
  final StationType? type;
  final StationStatus? status;
  final bool? isActive;
  final int? maxCapacity;
  final int? minCapacity;

  const StationQueryDto({
    this.type,
    this.status,
    this.isActive,
    this.maxCapacity,
    this.minCapacity,
  });

  @override
  List<Object?> get props => [type, status, isActive, maxCapacity, minCapacity];
}
