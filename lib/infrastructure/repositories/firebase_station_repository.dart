// Firebase Station Repository Implementation - Production Ready
// Real Firestore implementation for station management and kitchen operations

import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/station.dart';
import '../../domain/repositories/station_repository.dart';
import '../../domain/failures/failures.dart';
import '../../domain/value_objects/user_id.dart';
import '../config/firebase_config.dart';
import '../config/firebase_collections.dart';
import '../mappers/station_mapper.dart';

/// Firebase implementation of StationRepository with real Firestore operations
@LazySingleton(as: StationRepository)
class FirebaseStationRepository implements StationRepository {
  final StationMapper _stationMapper;
  late final FirebaseFirestore _firestore;

  FirebaseStationRepository(this._stationMapper) {
    _firestore = FirebaseConfig.firestore;
  }

  CollectionReference<Map<String, dynamic>> get _stationsCollection =>
      _firestore.collection(FirebaseCollections.stations);

  @override
  Future<Either<Failure, Station>> createStation(Station station) async {
    try {
      developer.log('Creating station: ${station.name}', name: 'FirebaseStationRepository');
      
      final stationData = _stationMapper.toFirestore(station);
      final docRef = await _stationsCollection.add(stationData);
      
      // Update the station with the actual Firestore document ID
      final createdStation = Station(
        id: UserId(docRef.id),
        name: station.name,
        capacity: station.capacity,
        location: station.location,
        stationType: station.stationType,
        status: station.status,
        isActive: station.isActive,
        currentWorkload: station.currentWorkload,
        assignedStaff: station.assignedStaff,
        currentOrders: station.currentOrders,
        createdAt: station.createdAt,
      );
      await docRef.update({'id': docRef.id});
      
      developer.log('Station created successfully: ${docRef.id}', name: 'FirebaseStationRepository');
      return Right(createdStation);
    } catch (e, stackTrace) {
      developer.log('Error creating station: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to create station: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Station>> getStationById(UserId stationId) async {
    try {
      developer.log('Getting station by ID: ${stationId.value}', name: 'FirebaseStationRepository');
      
      final doc = await _stationsCollection.doc(stationId.value).get();
      
      if (!doc.exists) {
        developer.log('Station not found: ${stationId.value}', name: 'FirebaseStationRepository');
        return Left(NotFoundFailure('Station not found'));
      }
      
      final station = _stationMapper.fromFirestore(doc.data()!, doc.id);
      return Right(station);
    } catch (e, stackTrace) {
      developer.log('Error getting station: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to get station: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Station>>> getAllStations() async {
    try {
      developer.log('Getting all stations', name: 'FirebaseStationRepository');
      
      final querySnapshot = await _stationsCollection.get();
      
      final stations = querySnapshot.docs
          .map((doc) => _stationMapper.fromFirestore(doc.data(), doc.id))
          .toList();
      
      developer.log('Retrieved ${stations.length} stations', name: 'FirebaseStationRepository');
      return Right(stations);
    } catch (e, stackTrace) {
      developer.log('Error getting stations: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to get stations: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Station>>> getStationsByType(StationType type) async {
    try {
      developer.log('Getting stations by type: $type', name: 'FirebaseStationRepository');
      
      final stationTypeString = _stationTypeToString(type);
      final querySnapshot = await _stationsCollection
          .where('stationType', isEqualTo: stationTypeString)
          .get();
      
      final stations = querySnapshot.docs
          .map((doc) => _stationMapper.fromFirestore(doc.data(), doc.id))
          .toList();
      
      developer.log('Retrieved ${stations.length} stations of type $type', name: 'FirebaseStationRepository');
      return Right(stations);
    } catch (e, stackTrace) {
      developer.log('Error getting stations by type: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to get stations by type: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Station>>> getStationsByStatus(StationStatus status) async {
    try {
      developer.log('Getting stations by status: $status', name: 'FirebaseStationRepository');
      
      final statusString = _stationStatusToString(status);
      final querySnapshot = await _stationsCollection
          .where('status', isEqualTo: statusString)
          .get();
      
      final stations = querySnapshot.docs
          .map((doc) => _stationMapper.fromFirestore(doc.data(), doc.id))
          .toList();
      
      developer.log('Retrieved ${stations.length} stations with status $status', name: 'FirebaseStationRepository');
      return Right(stations);
    } catch (e, stackTrace) {
      developer.log('Error getting stations by status: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to get stations by status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Station>>> getActiveStations() async {
    try {
      developer.log('Getting active stations', name: 'FirebaseStationRepository');
      
      final querySnapshot = await _stationsCollection
          .where('isActive', isEqualTo: true)
          .get();
      
      final stations = querySnapshot.docs
          .map((doc) => _stationMapper.fromFirestore(doc.data(), doc.id))
          .toList();
      
      developer.log('Retrieved ${stations.length} active stations', name: 'FirebaseStationRepository');
      return Right(stations);
    } catch (e, stackTrace) {
      developer.log('Error getting active stations: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to get active stations: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Station>>> getAvailableStations() async {
    try {
      developer.log('Getting available stations', name: 'FirebaseStationRepository');
      
      final querySnapshot = await _stationsCollection
          .where('status', isEqualTo: 'available')
          .where('isActive', isEqualTo: true)
          .get();
      
      final stations = querySnapshot.docs
          .map((doc) => _stationMapper.fromFirestore(doc.data(), doc.id))
          .toList();
      
      developer.log('Retrieved ${stations.length} available stations', name: 'FirebaseStationRepository');
      return Right(stations);
    } catch (e, stackTrace) {
      developer.log('Error getting available stations: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to get available stations: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Station>> updateStation(Station station) async {
    try {
      developer.log('Updating station: ${station.id.value}', name: 'FirebaseStationRepository');
      
      final stationData = _stationMapper.toFirestore(station);
      await _stationsCollection.doc(station.id.value).update(stationData);
      
      developer.log('Station updated successfully: ${station.id.value}', name: 'FirebaseStationRepository');
      return Right(station);
    } catch (e, stackTrace) {
      developer.log('Error updating station: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to update station: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Station>> updateStationStatus(
    UserId stationId,
    StationStatus status,
  ) async {
    try {
      developer.log('Updating station status: ${stationId.value} to $status', name: 'FirebaseStationRepository');
      
      final statusString = _stationStatusToString(status);
      await _stationsCollection.doc(stationId.value).update({
        'status': statusString,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Retrieve and return updated station
      final updatedStationResult = await getStationById(stationId);
      return updatedStationResult;
    } catch (e, stackTrace) {
      developer.log('Error updating station status: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to update station status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Station>> assignStaffToStation(
    UserId stationId,
    UserId staffId,
  ) async {
    try {
      developer.log('Assigning staff ${staffId.value} to station ${stationId.value}', name: 'FirebaseStationRepository');
      
      await _stationsCollection.doc(stationId.value).update({
        'assignedStaff': FieldValue.arrayUnion([staffId.value]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Retrieve and return updated station
      final updatedStationResult = await getStationById(stationId);
      return updatedStationResult;
    } catch (e, stackTrace) {
      developer.log('Error assigning staff to station: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to assign staff to station: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Station>> removeStaffFromStation(
    UserId stationId,
    UserId staffId,
  ) async {
    try {
      developer.log('Removing staff ${staffId.value} from station ${stationId.value}', name: 'FirebaseStationRepository');
      
      await _stationsCollection.doc(stationId.value).update({
        'assignedStaff': FieldValue.arrayRemove([staffId.value]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Retrieve and return updated station
      final updatedStationResult = await getStationById(stationId);
      return updatedStationResult;
    } catch (e, stackTrace) {
      developer.log('Error removing staff from station: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to remove staff from station: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Station>> updateStationWorkload(
    UserId stationId,
    int workload,
  ) async {
    try {
      developer.log('Updating station workload: ${stationId.value} to $workload', name: 'FirebaseStationRepository');
      
      await _stationsCollection.doc(stationId.value).update({
        'currentWorkload': workload,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Retrieve and return updated station
      final updatedStationResult = await getStationById(stationId);
      return updatedStationResult;
    } catch (e, stackTrace) {
      developer.log('Error updating station workload: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to update station workload: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Station>> addOrderToStation(
    UserId stationId,
    String orderId,
  ) async {
    try {
      developer.log('Adding order $orderId to station ${stationId.value}', name: 'FirebaseStationRepository');
      
      await _stationsCollection.doc(stationId.value).update({
        'currentOrders': FieldValue.arrayUnion([orderId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Retrieve and return updated station
      final updatedStationResult = await getStationById(stationId);
      return updatedStationResult;
    } catch (e, stackTrace) {
      developer.log('Error adding order to station: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to add order to station: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Station>> removeOrderFromStation(
    UserId stationId,
    String orderId,
  ) async {
    try {
      developer.log('Removing order $orderId from station ${stationId.value}', name: 'FirebaseStationRepository');
      
      await _stationsCollection.doc(stationId.value).update({
        'currentOrders': FieldValue.arrayRemove([orderId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Retrieve and return updated station
      final updatedStationResult = await getStationById(stationId);
      return updatedStationResult;
    } catch (e, stackTrace) {
      developer.log('Error removing order from station: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to remove order from station: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Station>> activateStation(UserId stationId) async {
    try {
      developer.log('Activating station: ${stationId.value}', name: 'FirebaseStationRepository');
      
      await _stationsCollection.doc(stationId.value).update({
        'isActive': true,
        'status': 'available',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Retrieve and return updated station
      final updatedStationResult = await getStationById(stationId);
      return updatedStationResult;
    } catch (e, stackTrace) {
      developer.log('Error activating station: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to activate station: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Station>> deactivateStation(UserId stationId) async {
    try {
      developer.log('Deactivating station: ${stationId.value}', name: 'FirebaseStationRepository');
      
      await _stationsCollection.doc(stationId.value).update({
        'isActive': false,
        'status': 'offline',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Retrieve and return updated station
      final updatedStationResult = await getStationById(stationId);
      return updatedStationResult;
    } catch (e, stackTrace) {
      developer.log('Error deactivating station: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to deactivate station: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Station>> setStationMaintenance(UserId stationId) async {
    try {
      developer.log('Setting station to maintenance: ${stationId.value}', name: 'FirebaseStationRepository');
      
      await _stationsCollection.doc(stationId.value).update({
        'status': 'maintenance',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Retrieve and return updated station
      final updatedStationResult = await getStationById(stationId);
      return updatedStationResult;
    } catch (e, stackTrace) {
      developer.log('Error setting station maintenance: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to set station maintenance: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStationStatistics(
    UserId stationId,
  ) async {
    try {
      developer.log('Getting station statistics: ${stationId.value}', name: 'FirebaseStationRepository');
      
      final doc = await _stationsCollection.doc(stationId.value).get();
      
      if (!doc.exists) {
        return Left(NotFoundFailure('Station not found'));
      }
      
      final data = doc.data()!;
      final station = _stationMapper.fromFirestore(data, doc.id);
      
      // Calculate basic statistics
      final statistics = {
        'stationId': stationId.value,
        'currentWorkload': station.currentWorkload,
        'capacity': station.capacity,
        'utilizationPercentage': (station.currentWorkload / station.capacity * 100).toInt(),
        'assignedStaffCount': station.assignedStaff.length,
        'currentOrdersCount': station.currentOrders.length,
        'isOverCapacity': station.currentWorkload > station.capacity,
        'status': station.status.toString(),
        'isActive': station.isActive,
      };
      
      developer.log('Retrieved station statistics', name: 'FirebaseStationRepository');
      return Right(statistics);
    } catch (e, stackTrace) {
      developer.log('Error getting station statistics: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to get station statistics: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getWorkloadDistribution() async {
    try {
      developer.log('Getting workload distribution', name: 'FirebaseStationRepository');
      
      final querySnapshot = await _stationsCollection
          .where('isActive', isEqualTo: true)
          .get();
      
      final stations = querySnapshot.docs
          .map((doc) => _stationMapper.fromFirestore(doc.data(), doc.id))
          .toList();
      
      // Calculate workload distribution
      int totalCapacity = 0;
      int totalWorkload = 0;
      final Map<String, Map<String, dynamic>> stationWorkloads = {};
      
      for (final station in stations) {
        totalCapacity += station.capacity;
        totalWorkload += station.currentWorkload;
        
        stationWorkloads[station.id.value] = {
          'name': station.name,
          'workload': station.currentWorkload,
          'capacity': station.capacity,
          'utilizationPercentage': (station.currentWorkload / station.capacity * 100).toInt(),
          'type': station.stationType.toString(),
          'status': station.status.toString(),
        };
      }
      
      final distribution = {
        'totalStations': stations.length,
        'totalCapacity': totalCapacity,
        'totalWorkload': totalWorkload,
        'overallUtilizationPercentage': totalCapacity > 0 
            ? (totalWorkload / totalCapacity * 100).toInt() 
            : 0,
        'stations': stationWorkloads,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      developer.log('Retrieved workload distribution for ${stations.length} stations', name: 'FirebaseStationRepository');
      return Right(distribution);
    } catch (e, stackTrace) {
      developer.log('Error getting workload distribution: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to get workload distribution: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteStation(UserId stationId) async {
    try {
      developer.log('Deleting station: ${stationId.value}', name: 'FirebaseStationRepository');
      
      await _stationsCollection.doc(stationId.value).delete();
      
      developer.log('Station deleted successfully: ${stationId.value}', name: 'FirebaseStationRepository');
      return const Right(unit);
    } catch (e, stackTrace) {
      developer.log('Error deleting station: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Left(NetworkFailure('Failed to delete station: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<Station>>> watchStations() {
    try {
      developer.log('Starting real-time stations stream', name: 'FirebaseStationRepository');
      
      return _stationsCollection
          .orderBy('name')
          .snapshots()
          .asyncMap((querySnapshot) async {
        try {
          final stations = querySnapshot.docs
              .map((doc) => _stationMapper.fromFirestore(doc.data(), doc.id))
              .toList();
          
          developer.log('Real-time stations update: ${stations.length} stations', name: 'FirebaseStationRepository');
          return Right<Failure, List<Station>>(stations);
        } catch (e, stackTrace) {
          developer.log('Error in stations stream: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
          return Left<Failure, List<Station>>(
            NetworkFailure('Failed to process stations stream: ${e.toString()}')
          );
        }
      });
    } catch (e, stackTrace) {
      developer.log('Error creating stations stream: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Stream.value(
        Left(NetworkFailure('Failed to create stations stream: ${e.toString()}'))
      );
    }
  }

  @override
  Stream<Either<Failure, Station>> watchStation(UserId stationId) {
    try {
      developer.log('Starting real-time station stream: ${stationId.value}', name: 'FirebaseStationRepository');
      
      return _stationsCollection
          .doc(stationId.value)
          .snapshots()
          .asyncMap((documentSnapshot) async {
        try {
          if (!documentSnapshot.exists) {
            developer.log('Station not found in stream: ${stationId.value}', name: 'FirebaseStationRepository');
            return Left<Failure, Station>(NotFoundFailure('Station not found'));
          }
          
          final station = _stationMapper.fromFirestore(
            documentSnapshot.data()!,
            documentSnapshot.id,
          );
          
          developer.log('Real-time station update: ${station.name}', name: 'FirebaseStationRepository');
          return Right<Failure, Station>(station);
        } catch (e, stackTrace) {
          developer.log('Error in station stream: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
          return Left<Failure, Station>(
            NetworkFailure('Failed to process station stream: ${e.toString()}')
          );
        }
      });
    } catch (e, stackTrace) {
      developer.log('Error creating station stream: $e', error: e, stackTrace: stackTrace, name: 'FirebaseStationRepository');
      return Stream.value(
        Left(NetworkFailure('Failed to create station stream: ${e.toString()}'))
      );
    }
  }

  // Helper methods for enum conversions
  String _stationTypeToString(StationType stationType) {
    switch (stationType) {
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

  String _stationStatusToString(StationStatus status) {
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