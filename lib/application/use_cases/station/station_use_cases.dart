// Station Use Cases for Clean Architecture Application Layer

import 'package:dartz/dartz.dart';
import '../../../domain/entities/station.dart';
import '../../../domain/repositories/station_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../dtos/station_dtos.dart';

/// Use case for creating a station
class CreateStationUseCase {
  final StationRepository _repository;

  CreateStationUseCase(this._repository);

  Future<Either<Failure, Station>> call(CreateStationDto dto) {
    final station = dto.toEntity();
    return _repository.createStation(station);
  }
}

/// Use case for getting station by ID
class GetStationByIdUseCase {
  final StationRepository _repository;

  GetStationByIdUseCase(this._repository);

  Future<Either<Failure, Station>> call(UserId stationId) {
    return _repository.getStationById(stationId);
  }
}

/// Use case for getting all stations
class GetAllStationsUseCase {
  final StationRepository _repository;

  GetAllStationsUseCase(this._repository);

  Future<Either<Failure, List<Station>>> call() {
    return _repository.getAllStations();
  }
}

/// Use case for getting stations by type
class GetStationsByTypeUseCase {
  final StationRepository _repository;

  GetStationsByTypeUseCase(this._repository);

  Future<Either<Failure, List<Station>>> call(StationType type) {
    return _repository.getStationsByType(type);
  }
}

/// Use case for getting stations by status
class GetStationsByStatusUseCase {
  final StationRepository _repository;

  GetStationsByStatusUseCase(this._repository);

  Future<Either<Failure, List<Station>>> call(StationStatus status) {
    return _repository.getStationsByStatus(status);
  }
}

/// Use case for getting active stations
class GetActiveStationsUseCase {
  final StationRepository _repository;

  GetActiveStationsUseCase(this._repository);

  Future<Either<Failure, List<Station>>> call() {
    return _repository.getActiveStations();
  }
}

/// Use case for getting available stations
class GetAvailableStationsUseCase {
  final StationRepository _repository;

  GetAvailableStationsUseCase(this._repository);

  Future<Either<Failure, List<Station>>> call() {
    return _repository.getAvailableStations();
  }
}

/// Use case for getting stations by assigned staff
class GetStationsByStaffUseCase {
  final StationRepository _repository;

  GetStationsByStaffUseCase(this._repository);

  Future<Either<Failure, List<Station>>> call(UserId staffId) async {
    // Get all stations and filter by assigned staff
    final allStationsResult = await _repository.getAllStations();

    return allStationsResult.fold((failure) => Left(failure), (stations) {
      final filteredStations = stations
          .where((station) => station.assignedStaff.contains(staffId))
          .toList();
      return Right(filteredStations);
    });
  }
}

/// Use case for updating station
class UpdateStationUseCase {
  final StationRepository _repository;

  UpdateStationUseCase(this._repository);

  Future<Either<Failure, Station>> call(UpdateStationDto dto) async {
    // Get existing station
    final existingStationResult = await _repository.getStationById(
      UserId(dto.id),
    );

    return existingStationResult.fold((failure) => Left(failure), (
      existingStation,
    ) {
      // Create updated station preserving existing data where not provided
      final updatedStation = Station(
        id: existingStation.id,
        name: dto.name ?? existingStation.name,
        capacity: dto.capacity ?? existingStation.capacity,
        location: dto.location ?? existingStation.location,
        stationType: dto.stationType != null
            ? _parseStationType(dto.stationType!)
            : existingStation.stationType,
        status: dto.status != null
            ? _parseStationStatus(dto.status!)
            : existingStation.status,
        isActive: dto.isActive ?? existingStation.isActive,
        currentWorkload: dto.currentWorkload ?? existingStation.currentWorkload,
        assignedStaff:
            dto.assignedStaff?.map((id) => UserId(id)).toList() ??
            existingStation.assignedStaff,
        currentOrders: dto.currentOrders ?? existingStation.currentOrders,
        createdAt: existingStation.createdAt,
      );

      return _repository.updateStation(updatedStation);
    });
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

  StationStatus _parseStationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return StationStatus.available;
      case 'busy':
        return StationStatus.busy;
      case 'maintenance':
        return StationStatus.maintenance;
      case 'offline':
        return StationStatus.offline;
      default:
        return StationStatus.available;
    }
  }
}

/// Use case for updating station status
class UpdateStationStatusUseCase {
  final StationRepository _repository;

  UpdateStationStatusUseCase(this._repository);

  Future<Either<Failure, Station>> call(StationStatusDto dto) {
    final status = _parseStationStatus(dto.status);
    return _repository.updateStationStatus(UserId(dto.stationId), status);
  }

  StationStatus _parseStationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return StationStatus.available;
      case 'busy':
        return StationStatus.busy;
      case 'maintenance':
        return StationStatus.maintenance;
      case 'offline':
        return StationStatus.offline;
      default:
        return StationStatus.available;
    }
  }
}

/// Use case for assigning staff to station
class AssignStaffToStationUseCase {
  final StationRepository _repository;

  AssignStaffToStationUseCase(this._repository);

  Future<Either<Failure, Station>> call(UserId stationId, UserId staffId) {
    return _repository.assignStaffToStation(stationId, staffId);
  }
}

/// Use case for removing staff from station
class RemoveStaffFromStationUseCase {
  final StationRepository _repository;

  RemoveStaffFromStationUseCase(this._repository);

  Future<Either<Failure, Station>> call(UserId stationId, UserId staffId) {
    return _repository.removeStaffFromStation(stationId, staffId);
  }
}

/// Use case for adding order to station
class AddOrderToStationUseCase {
  final StationRepository _repository;

  AddOrderToStationUseCase(this._repository);

  Future<Either<Failure, Station>> call(UserId stationId, String orderId) {
    return _repository.addOrderToStation(stationId, orderId);
  }
}

/// Use case for removing order from station
class RemoveOrderFromStationUseCase {
  final StationRepository _repository;

  RemoveOrderFromStationUseCase(this._repository);

  Future<Either<Failure, Station>> call(UserId stationId, String orderId) {
    return _repository.removeOrderFromStation(stationId, orderId);
  }
}

/// Use case for updating station workload
class UpdateStationWorkloadUseCase {
  final StationRepository _repository;

  UpdateStationWorkloadUseCase(this._repository);

  Future<Either<Failure, Station>> call(UserId stationId, int workload) {
    return _repository.updateStationWorkload(stationId, workload);
  }
}

/// Use case for setting station maintenance
class SetStationMaintenanceUseCase {
  final StationRepository _repository;

  SetStationMaintenanceUseCase(this._repository);

  Future<Either<Failure, Station>> call(UserId stationId, String reason) {
    return _repository.setStationMaintenance(stationId);
  }
}

/// Use case for returning station to service
class ReturnStationToServiceUseCase {
  final StationRepository _repository;

  ReturnStationToServiceUseCase(this._repository);

  Future<Either<Failure, Station>> call(UserId stationId) {
    return _repository.activateStation(stationId);
  }
}

/// Use case for deleting a station
class DeleteStationUseCase {
  final StationRepository _repository;

  DeleteStationUseCase(this._repository);

  Future<Either<Failure, Unit>> call(UserId stationId) {
    return _repository.deleteStation(stationId);
  }
}
