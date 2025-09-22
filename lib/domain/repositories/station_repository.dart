import 'package:dartz/dartz.dart' show Either, Unit;
import '../entities/station.dart';
import '../value_objects/user_id.dart';
import '../failures/failures.dart';

/// Repository interface for Station operations
abstract class StationRepository {
  /// Creates a new station
  Future<Either<Failure, Station>> createStation(Station station);

  /// Gets a station by its ID
  Future<Either<Failure, Station>> getStationById(UserId stationId);

  /// Gets all stations
  Future<Either<Failure, List<Station>>> getAllStations();

  /// Gets stations by type
  Future<Either<Failure, List<Station>>> getStationsByType(StationType type);

  /// Gets stations by status
  Future<Either<Failure, List<Station>>> getStationsByStatus(
    StationStatus status,
  );

  /// Gets active stations
  Future<Either<Failure, List<Station>>> getActiveStations();

  /// Gets available stations
  Future<Either<Failure, List<Station>>> getAvailableStations();

  /// Updates a station
  Future<Either<Failure, Station>> updateStation(Station station);

  /// Updates station status
  Future<Either<Failure, Station>> updateStationStatus(
    UserId stationId,
    StationStatus status,
  );

  /// Assigns staff to station
  Future<Either<Failure, Station>> assignStaffToStation(
    UserId stationId,
    UserId staffId,
  );

  /// Removes staff from station
  Future<Either<Failure, Station>> removeStaffFromStation(
    UserId stationId,
    UserId staffId,
  );

  /// Updates station workload
  Future<Either<Failure, Station>> updateStationWorkload(
    UserId stationId,
    int workload,
  );

  /// Adds order to station
  Future<Either<Failure, Station>> addOrderToStation(
    UserId stationId,
    String orderId,
  );

  /// Removes order from station
  Future<Either<Failure, Station>> removeOrderFromStation(
    UserId stationId,
    String orderId,
  );

  /// Activates a station
  Future<Either<Failure, Station>> activateStation(UserId stationId);

  /// Deactivates a station
  Future<Either<Failure, Station>> deactivateStation(UserId stationId);

  /// Sets station to maintenance
  Future<Either<Failure, Station>> setStationMaintenance(UserId stationId);

  /// Gets station utilization statistics
  Future<Either<Failure, Map<String, dynamic>>> getStationStatistics(
    UserId stationId,
  );

  /// Gets workload distribution across stations
  Future<Either<Failure, Map<String, dynamic>>> getWorkloadDistribution();

  /// Deletes a station
  Future<Either<Failure, Unit>> deleteStation(UserId stationId);

  /// Watches real-time station updates
  Stream<Either<Failure, List<Station>>> watchStations();

  /// Watches specific station updates
  Stream<Either<Failure, Station>> watchStation(UserId stationId);
}
