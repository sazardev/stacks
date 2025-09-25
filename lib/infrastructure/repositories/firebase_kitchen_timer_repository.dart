// Firebase Kitchen Timer Repository Implementation - Production Ready
// Real Firestore implementation for real-time timer management and cooking operations

import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/kitchen_timer.dart';
import '../../domain/repositories/kitchen_timer_repository.dart';
import '../../domain/failures/failures.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';
import '../config/firebase_config.dart';
import '../config/firebase_collections.dart';
import '../mappers/kitchen_timer_mapper.dart';

@LazySingleton(as: KitchenTimerRepository)
class FirebaseKitchenTimerRepository implements KitchenTimerRepository {
  final KitchenTimerMapper _mapper;

  FirebaseKitchenTimerRepository(this._mapper);

  FirebaseFirestore get _firestore => FirebaseConfig.firestore;

  // Helper method to convert enum values for Firestore
  String _timerTypeToString(TimerType type) {
    switch (type) {
      case TimerType.cooking:
        return 'cooking';
      case TimerType.hold:
        return 'hold';
      case TimerType.prep:
        return 'prep';
      case TimerType.temperatureCheck:
        return 'temperatureCheck';
      case TimerType.maintenance:
        return 'maintenance';
      case TimerType.foodSafety:
        return 'foodSafety';
      case TimerType.staffBreak:
        return 'staffBreak';
      case TimerType.cleaning:
        return 'cleaning';
    }
  }

  String _timerStatusToString(TimerStatus status) {
    switch (status) {
      case TimerStatus.created:
        return 'created';
      case TimerStatus.running:
        return 'running';
      case TimerStatus.paused:
        return 'paused';
      case TimerStatus.completed:
        return 'completed';
      case TimerStatus.cancelled:
        return 'cancelled';
      case TimerStatus.expired:
        return 'expired';
    }
  }

  @override
  Future<Either<Failure, KitchenTimer>> createTimer(KitchenTimer timer) async {
    try {
      developer.log(
        'Creating kitchen timer: ${timer.label}',
        name: 'FirebaseKitchenTimerRepository',
      );

      final timerData = _mapper.toFirestore(timer);

      String docId;
      if (timer.id.value.isNotEmpty) {
        docId = timer.id.value;
      } else {
        final docRef = _firestore
            .collection(FirebaseCollections.kitchenTimers)
            .doc();
        docId = docRef.id;
      }

      // Add Firestore metadata
      timerData.addAll({
        'id': docId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .doc(docId)
          .set(timerData);

      // Return the timer with the new ID from Firestore
      final createdData = timerData;
      createdData['id'] = docId;
      final createdTimer = _mapper.fromFirestore(createdData, docId);

      developer.log(
        'Successfully created kitchen timer with ID: $docId',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Right(createdTimer);
    } catch (e) {
      developer.log(
        'Error creating kitchen timer: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Left(
        ServerFailure('Failed to create kitchen timer: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, KitchenTimer>> getTimerById(UserId timerId) async {
    try {
      developer.log(
        'Getting kitchen timer: ${timerId.value}',
        name: 'FirebaseKitchenTimerRepository',
      );

      final doc = await _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .doc(timerId.value)
          .get();

      if (!doc.exists) {
        return Left(NotFoundFailure('Kitchen timer not found'));
      }

      final timer = _mapper.fromFirestore(doc.data()!, doc.id);
      return Right(timer);
    } catch (e) {
      developer.log(
        'Error getting kitchen timer: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Left(
        ServerFailure('Failed to get kitchen timer: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<KitchenTimer>>> getActiveTimers() async {
    try {
      developer.log(
        'Getting active kitchen timers',
        name: 'FirebaseKitchenTimerRepository',
      );

      final snapshot = await _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .where('status', whereIn: ['running', 'paused'])
          .orderBy('createdAt', descending: true)
          .get();

      final timers = snapshot.docs
          .map((doc) => _mapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${timers.length} active timers',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Right(timers);
    } catch (e) {
      developer.log(
        'Error getting active timers: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Left(
        ServerFailure('Failed to get active timers: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<KitchenTimer>>> getTimersByStation(
    UserId stationId,
  ) async {
    try {
      developer.log(
        'Getting timers by station: ${stationId.value}',
        name: 'FirebaseKitchenTimerRepository',
      );

      final snapshot = await _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .where('stationId', isEqualTo: stationId.value)
          .orderBy('createdAt', descending: true)
          .get();

      final timers = snapshot.docs
          .map((doc) => _mapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${timers.length} timers for station: ${stationId.value}',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Right(timers);
    } catch (e) {
      developer.log(
        'Error getting timers by station: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Left(
        ServerFailure('Failed to get timers by station: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<KitchenTimer>>> getTimersByType(
    TimerType type,
  ) async {
    try {
      developer.log(
        'Getting timers by type: $type',
        name: 'FirebaseKitchenTimerRepository',
      );

      final snapshot = await _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .where('type', isEqualTo: _timerTypeToString(type))
          .orderBy('createdAt', descending: true)
          .get();

      final timers = snapshot.docs
          .map((doc) => _mapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${timers.length} timers for type: $type',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Right(timers);
    } catch (e) {
      developer.log(
        'Error getting timers by type: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Left(
        ServerFailure('Failed to get timers by type: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<KitchenTimer>>> getTimersByStatus(
    TimerStatus status,
  ) async {
    try {
      developer.log(
        'Getting timers by status: $status',
        name: 'FirebaseKitchenTimerRepository',
      );

      final snapshot = await _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .where('status', isEqualTo: _timerStatusToString(status))
          .orderBy('createdAt', descending: true)
          .get();

      final timers = snapshot.docs
          .map((doc) => _mapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${timers.length} timers with status: $status',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Right(timers);
    } catch (e) {
      developer.log(
        'Error getting timers by status: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Left(
        ServerFailure('Failed to get timers by status: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<KitchenTimer>>> getTimersByUser(
    UserId userId,
  ) async {
    try {
      developer.log(
        'Getting timers by user: ${userId.value}',
        name: 'FirebaseKitchenTimerRepository',
      );

      final snapshot = await _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .where('createdBy', isEqualTo: userId.value)
          .orderBy('createdAt', descending: true)
          .get();

      final timers = snapshot.docs
          .map((doc) => _mapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${timers.length} timers for user: ${userId.value}',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Right(timers);
    } catch (e) {
      developer.log(
        'Error getting timers by user: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Left(
        ServerFailure('Failed to get timers by user: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, KitchenTimer>> startTimer(UserId timerId) async {
    try {
      developer.log(
        'Starting timer: ${timerId.value}',
        name: 'FirebaseKitchenTimerRepository',
      );

      await _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .doc(timerId.value)
          .update({
            'status': _timerStatusToString(TimerStatus.running),
            'startedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Get updated timer
      final result = await getTimerById(timerId);
      return result;
    } catch (e) {
      developer.log(
        'Error starting timer: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Left(ServerFailure('Failed to start timer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, KitchenTimer>> pauseTimer(UserId timerId) async {
    try {
      developer.log(
        'Pausing timer: ${timerId.value}',
        name: 'FirebaseKitchenTimerRepository',
      );

      await _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .doc(timerId.value)
          .update({
            'status': _timerStatusToString(TimerStatus.paused),
            'pausedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Get updated timer
      final result = await getTimerById(timerId);
      return result;
    } catch (e) {
      developer.log(
        'Error pausing timer: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Left(ServerFailure('Failed to pause timer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, KitchenTimer>> resumeTimer(UserId timerId) async {
    try {
      developer.log(
        'Resuming timer: ${timerId.value}',
        name: 'FirebaseKitchenTimerRepository',
      );

      await _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .doc(timerId.value)
          .update({
            'status': _timerStatusToString(TimerStatus.running),
            'pausedAt': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Get updated timer
      final result = await getTimerById(timerId);
      return result;
    } catch (e) {
      developer.log(
        'Error resuming timer: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Left(ServerFailure('Failed to resume timer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, KitchenTimer>> stopTimer(UserId timerId) async {
    try {
      developer.log(
        'Stopping timer: ${timerId.value}',
        name: 'FirebaseKitchenTimerRepository',
      );

      await _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .doc(timerId.value)
          .update({
            'status': _timerStatusToString(TimerStatus.completed),
            'completedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Get updated timer
      final result = await getTimerById(timerId);
      return result;
    } catch (e) {
      developer.log(
        'Error stopping timer: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Left(ServerFailure('Failed to stop timer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, KitchenTimer>> cancelTimer(UserId timerId) async {
    try {
      developer.log(
        'Cancelling timer: ${timerId.value}',
        name: 'FirebaseKitchenTimerRepository',
      );

      await _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .doc(timerId.value)
          .update({
            'status': _timerStatusToString(TimerStatus.cancelled),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Get updated timer
      final result = await getTimerById(timerId);
      return result;
    } catch (e) {
      developer.log(
        'Error cancelling timer: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Left(ServerFailure('Failed to cancel timer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, KitchenTimer>> updateTimer(KitchenTimer timer) async {
    try {
      developer.log(
        'Updating timer: ${timer.id.value}',
        name: 'FirebaseKitchenTimerRepository',
      );

      final timerData = _mapper.toFirestore(timer);
      timerData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .doc(timer.id.value)
          .update(timerData);

      developer.log(
        'Successfully updated timer: ${timer.id.value}',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Right(timer);
    } catch (e) {
      developer.log(
        'Error updating timer: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Left(ServerFailure('Failed to update timer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTimer(UserId timerId) async {
    try {
      developer.log(
        'Deleting timer: ${timerId.value}',
        name: 'FirebaseKitchenTimerRepository',
      );

      await _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .doc(timerId.value)
          .delete();

      developer.log(
        'Successfully deleted timer: ${timerId.value}',
        name: 'FirebaseKitchenTimerRepository',
      );
      return const Right(unit);
    } catch (e) {
      developer.log(
        'Error deleting timer: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Left(ServerFailure('Failed to delete timer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<KitchenTimer>>> getExpiredTimers() async {
    try {
      developer.log(
        'Getting expired timers',
        name: 'FirebaseKitchenTimerRepository',
      );

      final snapshot = await _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .where('status', isEqualTo: _timerStatusToString(TimerStatus.expired))
          .orderBy('createdAt', descending: true)
          .get();

      final timers = snapshot.docs
          .map((doc) => _mapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${timers.length} expired timers',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Right(timers);
    } catch (e) {
      developer.log(
        'Error getting expired timers: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Left(
        ServerFailure('Failed to get expired timers: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<KitchenTimer>>> getCompletedTimers(
    Time startDate,
    Time endDate,
  ) async {
    try {
      developer.log(
        'Getting completed timers from ${startDate.dateTime} to ${endDate.dateTime}',
        name: 'FirebaseKitchenTimerRepository',
      );

      final snapshot = await _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .where(
            'status',
            isEqualTo: _timerStatusToString(TimerStatus.completed),
          )
          .where(
            'completedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate.dateTime),
          )
          .where(
            'completedAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate.dateTime),
          )
          .orderBy('completedAt', descending: true)
          .get();

      final timers = snapshot.docs
          .map((doc) => _mapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${timers.length} completed timers',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Right(timers);
    } catch (e) {
      developer.log(
        'Error getting completed timers: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Left(
        ServerFailure('Failed to get completed timers: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, KitchenTimer>> updateTimerDuration(
    UserId timerId,
    Duration remainingDuration,
  ) async {
    try {
      developer.log(
        'Updating timer duration: ${timerId.value}',
        name: 'FirebaseKitchenTimerRepository',
      );

      await _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .doc(timerId.value)
          .update({
            'remainingDurationSeconds': remainingDuration.inSeconds,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Get updated timer
      final result = await getTimerById(timerId);
      return result;
    } catch (e) {
      developer.log(
        'Error updating timer duration: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Left(
        ServerFailure('Failed to update timer duration: ${e.toString()}'),
      );
    }
  }

  // Additional helper methods for real-time functionality
  Stream<Either<Failure, List<KitchenTimer>>> watchActiveTimers() {
    try {
      developer.log(
        'Setting up active timers stream',
        name: 'FirebaseKitchenTimerRepository',
      );

      return _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .where('status', whereIn: ['running', 'paused'])
          .orderBy('createdAt', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
            try {
              final timers = snapshot.docs
                  .map((doc) => _mapper.fromFirestore(doc.data(), doc.id))
                  .toList();

              developer.log(
                'Active timers stream updated: ${timers.length} timers',
                name: 'FirebaseKitchenTimerRepository',
              );
              return Right<Failure, List<KitchenTimer>>(timers);
            } catch (e) {
              developer.log(
                'Error in active timers stream: $e',
                name: 'FirebaseKitchenTimerRepository',
              );
              return Left<Failure, List<KitchenTimer>>(
                ServerFailure(
                  'Failed to process timer updates: ${e.toString()}',
                ),
              );
            }
          });
    } catch (e) {
      developer.log(
        'Error setting up active timers stream: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Stream.value(
        Left(ServerFailure('Failed to setup timers stream: ${e.toString()}')),
      );
    }
  }

  Stream<Either<Failure, List<KitchenTimer>>> watchTimersByStation(
    UserId stationId,
  ) {
    try {
      developer.log(
        'Setting up station timers stream for: ${stationId.value}',
        name: 'FirebaseKitchenTimerRepository',
      );

      return _firestore
          .collection(FirebaseCollections.kitchenTimers)
          .where('stationId', isEqualTo: stationId.value)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
            try {
              final timers = snapshot.docs
                  .map((doc) => _mapper.fromFirestore(doc.data(), doc.id))
                  .toList();

              developer.log(
                'Station timers stream updated: ${timers.length} timers',
                name: 'FirebaseKitchenTimerRepository',
              );
              return Right<Failure, List<KitchenTimer>>(timers);
            } catch (e) {
              developer.log(
                'Error in station timers stream: $e',
                name: 'FirebaseKitchenTimerRepository',
              );
              return Left<Failure, List<KitchenTimer>>(
                ServerFailure(
                  'Failed to process station timer updates: ${e.toString()}',
                ),
              );
            }
          });
    } catch (e) {
      developer.log(
        'Error setting up station timers stream: $e',
        name: 'FirebaseKitchenTimerRepository',
      );
      return Stream.value(
        Left(
          ServerFailure(
            'Failed to setup station timers stream: ${e.toString()}',
          ),
        ),
      );
    }
  }
}
