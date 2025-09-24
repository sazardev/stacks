// Station Repository Implementation for Clean Architecture Infrastructure Layer
// Simplified mock implementation with real-time updates and workload management

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/station.dart';
import '../../domain/repositories/station_repository.dart';
import '../../domain/failures/failures.dart';
import '../../domain/value_objects/user_id.dart';
import '../mappers/station_mapper.dart';

@LazySingleton(as: StationRepository)
class StationRepositoryImpl implements StationRepository {
  final StationMapper _stationMapper;

  // In-memory storage for development
  final Map<String, Map<String, dynamic>> _stations = {};

  StationRepositoryImpl({required StationMapper stationMapper})
    : _stationMapper = stationMapper;

  @override
  Future<Either<Failure, Station>> createStation(Station station) async {
    try {
      // Check if station ID already exists
      if (_stations.containsKey(station.id.value)) {
        return Left(
          ValidationFailure('Station already exists: ${station.id.value}'),
        );
      }

      final stationData = _stationMapper.toFirestore(station);
      _stations[station.id.value] = stationData;

      return Right(station);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Station>> getStationById(UserId stationId) async {
    try {
      final stationData = _stations[stationId.value];
      if (stationData == null) {
        return Left(NotFoundFailure('Station not found: ${stationId.value}'));
      }

      final station = _stationMapper.fromFirestore(
        stationData,
        stationId.value,
      );
      return Right(station);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Station>>> getAllStations() async {
    try {
      final stations = _stations.entries
          .map((entry) => _stationMapper.fromFirestore(entry.value, entry.key))
          .toList();
      return Right(stations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Station>>> getStationsByType(
    StationType type,
  ) async {
    try {
      final typeString = _getStationTypeString(type);
      final stations = _stations.values
          .where((stationData) => stationData['stationType'] == typeString)
          .map(
            (stationData) => _stationMapper.fromFirestore(
              stationData,
              stationData['id'] as String,
            ),
          )
          .toList();
      return Right(stations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Station>>> getStationsByStatus(
    StationStatus status,
  ) async {
    try {
      final statusString = _getStationStatusString(status);
      final stations = _stations.values
          .where((stationData) => stationData['status'] == statusString)
          .map(
            (stationData) => _stationMapper.fromFirestore(
              stationData,
              stationData['id'] as String,
            ),
          )
          .toList();
      return Right(stations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Station>>> getActiveStations() async {
    try {
      final stations = _stations.values
          .where((stationData) => stationData['isActive'] as bool? ?? true)
          .map(
            (stationData) => _stationMapper.fromFirestore(
              stationData,
              stationData['id'] as String,
            ),
          )
          .toList();
      return Right(stations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Station>>> getAvailableStations() async {
    try {
      final stations = _stations.values
          .where((stationData) {
            final isActive = stationData['isActive'] as bool? ?? true;
            final status = stationData['status'] as String?;
            return isActive && status == 'available';
          })
          .map(
            (stationData) => _stationMapper.fromFirestore(
              stationData,
              stationData['id'] as String,
            ),
          )
          .toList();
      return Right(stations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Station>> updateStation(Station station) async {
    try {
      if (!_stations.containsKey(station.id.value)) {
        return Left(NotFoundFailure('Station not found: ${station.id.value}'));
      }

      final stationData = _stationMapper.toFirestore(station);
      _stations[station.id.value] = stationData;

      return Right(station);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Station>> updateStationStatus(
    UserId stationId,
    StationStatus status,
  ) async {
    try {
      final result = await getStationById(stationId);
      return result.fold((failure) => Left(failure), (station) {
        Station updatedStation;
        switch (status) {
          case StationStatus.available:
            updatedStation = station.setAvailable();
            break;
          case StationStatus.busy:
            updatedStation = station.setBusy();
            break;
          case StationStatus.maintenance:
            updatedStation = station.setMaintenance();
            break;
          case StationStatus.offline:
            updatedStation = station.deactivate();
            break;
        }
        return updateStation(updatedStation);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Station>> assignStaffToStation(
    UserId stationId,
    UserId staffId,
  ) async {
    try {
      final result = await getStationById(stationId);
      return result.fold((failure) => Left(failure), (station) {
        final updatedStation = station.assignStaff(staffId);
        return updateStation(updatedStation);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Station>> removeStaffFromStation(
    UserId stationId,
    UserId staffId,
  ) async {
    try {
      final stationData = _stations[stationId.value];
      if (stationData == null) {
        return Left(NotFoundFailure('Station not found: ${stationId.value}'));
      }

      final assignedStaff = List<String>.from(
        stationData['assignedStaff'] ?? [],
      );
      assignedStaff.remove(staffId.value);
      stationData['assignedStaff'] = assignedStaff;

      final station = _stationMapper.fromFirestore(
        stationData,
        stationId.value,
      );
      return Right(station);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Station>> updateStationWorkload(
    UserId stationId,
    int workload,
  ) async {
    try {
      final result = await getStationById(stationId);
      return result.fold((failure) => Left(failure), (station) {
        final updatedStation = station.updateWorkload(workload);
        return updateStation(updatedStation);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Station>> addOrderToStation(
    UserId stationId,
    String orderId,
  ) async {
    try {
      final stationData = _stations[stationId.value];
      if (stationData == null) {
        return Left(NotFoundFailure('Station not found: ${stationId.value}'));
      }

      final currentOrders = List<String>.from(
        stationData['currentOrders'] ?? [],
      );
      if (!currentOrders.contains(orderId)) {
        currentOrders.add(orderId);
        stationData['currentOrders'] = currentOrders;
        stationData['currentWorkload'] = currentOrders.length;
      }

      final station = _stationMapper.fromFirestore(
        stationData,
        stationId.value,
      );
      return Right(station);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Station>> removeOrderFromStation(
    UserId stationId,
    String orderId,
  ) async {
    try {
      final stationData = _stations[stationId.value];
      if (stationData == null) {
        return Left(NotFoundFailure('Station not found: ${stationId.value}'));
      }

      final currentOrders = List<String>.from(
        stationData['currentOrders'] ?? [],
      );
      currentOrders.remove(orderId);
      stationData['currentOrders'] = currentOrders;
      stationData['currentWorkload'] = currentOrders.length;

      final station = _stationMapper.fromFirestore(
        stationData,
        stationId.value,
      );
      return Right(station);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Station>> activateStation(UserId stationId) async {
    try {
      final result = await getStationById(stationId);
      return result.fold((failure) => Left(failure), (station) {
        final updatedStation = station.activate();
        return updateStation(updatedStation);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Station>> deactivateStation(UserId stationId) async {
    try {
      final result = await getStationById(stationId);
      return result.fold((failure) => Left(failure), (station) {
        final updatedStation = station.deactivate();
        return updateStation(updatedStation);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Station>> setStationMaintenance(
    UserId stationId,
  ) async {
    try {
      final result = await getStationById(stationId);
      return result.fold((failure) => Left(failure), (station) {
        final updatedStation = station.setMaintenance();
        return updateStation(updatedStation);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStationStatistics(
    UserId stationId,
  ) async {
    try {
      final result = await getStationById(stationId);
      return result.fold((failure) => Left(failure), (station) {
        final statistics = <String, dynamic>{
          'stationId': station.id.value,
          'name': station.name,
          'type': station.stationType.name,
          'status': station.status.name,
          'capacity': station.capacity,
          'currentWorkload': station.currentWorkload,
          'workloadPercentage': station.workloadPercentage,
          'availableCapacity': station.availableCapacity,
          'assignedStaff': station.assignedStaff.length,
          'currentOrders': station.currentOrders.length,
          'isAtCapacity': station.isAtCapacity,
          'canAcceptOrder': station.canAcceptOrder,
        };
        return Right(statistics);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getWorkloadDistribution() async {
    try {
      final stations = await getAllStations();
      return stations.fold((failure) => Left(failure), (stationList) {
        final distribution = <String, dynamic>{
          'totalStations': stationList.length,
          'activeStations': stationList.where((s) => s.isActive).length,
          'stationsAtCapacity': stationList.where((s) => s.isAtCapacity).length,
          'totalCapacity': stationList.fold<int>(
            0,
            (sum, s) => sum + s.capacity,
          ),
          'totalWorkload': stationList.fold<int>(
            0,
            (sum, s) => sum + s.currentWorkload,
          ),
          'stationDetails': stationList
              .map(
                (s) => {
                  'id': s.id.value,
                  'name': s.name,
                  'type': s.stationType.name,
                  'workloadPercentage': s.workloadPercentage,
                },
              )
              .toList(),
        };
        return Right(distribution);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteStation(UserId stationId) async {
    try {
      if (!_stations.containsKey(stationId.value)) {
        return Left(NotFoundFailure('Station not found: ${stationId.value}'));
      }

      _stations.remove(stationId.value);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Station>>> watchStations() {
    return Stream.periodic(const Duration(seconds: 1), (_) {
      try {
        final stations = _stations.values
            .map(
              (stationData) => _stationMapper.fromFirestore(
                stationData,
                stationData['id'] as String,
              ),
            )
            .toList();
        return Right<Failure, List<Station>>(stations);
      } catch (e) {
        return Left<Failure, List<Station>>(ServerFailure(e.toString()));
      }
    });
  }

  @override
  Stream<Either<Failure, Station>> watchStation(UserId stationId) {
    return Stream.periodic(const Duration(seconds: 1), (_) {
      try {
        final stationData = _stations[stationId.value];
        if (stationData == null) {
          return Left<Failure, Station>(
            NotFoundFailure('Station not found: ${stationId.value}'),
          );
        }

        final station = _stationMapper.fromFirestore(
          stationData,
          stationId.value,
        );
        return Right<Failure, Station>(station);
      } catch (e) {
        return Left<Failure, Station>(ServerFailure(e.toString()));
      }
    });
  }

  // Helper method to convert StationType to string
  String _getStationTypeString(StationType type) {
    switch (type) {
      case StationType.grill:
        return 'grill';
      case StationType.prep:
        return 'prep';
      case StationType.fryer:
        return 'fryer';
      case StationType.salad:
        return 'salad';
      case StationType.dessert:
        return 'dessert';
      case StationType.beverage:
        return 'beverage';
    }
  }

  // Helper method to convert StationStatus to string
  String _getStationStatusString(StationStatus status) {
    switch (status) {
      case StationStatus.available:
        return 'available';
      case StationStatus.busy:
        return 'busy';
      case StationStatus.maintenance:
        return 'maintenance';
      case StationStatus.offline:
        return 'offline';
    }
  }
}
