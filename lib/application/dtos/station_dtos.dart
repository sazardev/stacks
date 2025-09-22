import 'package:equatable/equatable.dart';
import '../../domain/entities/station.dart';
import '../../domain/value_objects/user_id.dart';

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
