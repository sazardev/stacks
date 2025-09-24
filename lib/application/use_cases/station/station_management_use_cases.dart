import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/station.dart';
import '../../../domain/repositories/station_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../dtos/station_dtos.dart';

/// Use case for managing kitchen stations with operational validation
@injectable
class GetStationStatusUseCase {
  final StationRepository _stationRepository;

  GetStationStatusUseCase(this._stationRepository);

  /// Execute the station status retrieval use case
  Future<Either<Failure, Station>> execute(UserId stationId) async {
    try {
      final result = await _stationRepository.getStationById(stationId);

      return result.fold(
        (failure) => Left(failure),
        (station) => Right(station),
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to get station status: ${e.toString()}'),
      );
    }
  }
}

/// Use case for updating station status with business logic validation
@injectable
class UpdateStationStatusUseCase {
  final StationRepository _stationRepository;

  UpdateStationStatusUseCase(this._stationRepository);

  /// Execute the station status update use case
  Future<Either<Failure, Station>> execute(UpdateStationStatusDto dto) async {
    try {
      // Step 1: Get existing station
      final stationResult = await _stationRepository.getStationById(
        dto.stationId,
      );

      final station = stationResult.fold(
        (failure) => null,
        (station) => station,
      );

      if (station == null) {
        return Left(
          NotFoundFailure('Station not found: ${dto.stationId.value}'),
        );
      }

      // Step 2: Validate status transition
      if (!_isValidStatusTransition(station.status, dto.newStatus)) {
        return Left(
          ValidationFailure(
            'Invalid status transition from ${station.status} to ${dto.newStatus}',
          ),
        );
      }

      // Step 3: Update station status
      final result = await _stationRepository.updateStationStatus(
        dto.stationId,
        dto.newStatus,
      );

      return result.fold(
        (failure) => Left(failure),
        (updatedStation) => Right(updatedStation),
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to update station status: ${e.toString()}'),
      );
    }
  }

  /// Validate status transition logic
  bool _isValidStatusTransition(
    StationStatus currentStatus,
    StationStatus newStatus,
  ) {
    // Basic validation - can be extended with complex business rules
    const validTransitions = {
      StationStatus.available: [
        StationStatus.busy,
        StationStatus.maintenance,
        StationStatus.offline,
      ],
      StationStatus.busy: [
        StationStatus.available,
        StationStatus.maintenance,
        StationStatus.offline,
      ],
      StationStatus.maintenance: [
        StationStatus.available,
        StationStatus.offline,
      ],
      StationStatus.offline: [
        StationStatus.available,
        StationStatus.maintenance,
      ],
    };

    return validTransitions[currentStatus]?.contains(newStatus) ?? false;
  }
}

/// Use case for assigning staff to kitchen stations
@injectable
class AssignStaffToStationUseCase {
  final StationRepository _stationRepository;

  AssignStaffToStationUseCase(this._stationRepository);

  /// Execute the staff assignment use case
  Future<Either<Failure, Station>> execute(AssignStaffToStationDto dto) async {
    try {
      // Step 1: Validate assignment
      if (dto.staffIds.isEmpty) {
        return Left(
          ValidationFailure('At least one staff member must be assigned'),
        );
      }

      // Step 2: Assign each staff member to station
      Station? updatedStation;
      for (final staffId in dto.staffIds) {
        final result = await _stationRepository.assignStaffToStation(
          dto.stationId,
          staffId,
        );

        final assignmentResult = result.fold((failure) => failure, (station) {
          updatedStation = station;
          return null;
        });

        // If any assignment fails, return the failure
        if (assignmentResult != null) {
          return Left(assignmentResult);
        }
      }

      return Right(updatedStation!);
    } catch (e) {
      return Left(
        ServerFailure('Failed to assign staff to station: ${e.toString()}'),
      );
    }
  }
}
