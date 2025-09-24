// Kitchen Timer Repository Implementation for Clean Architecture Infrastructure Layer
// Simplified mock implementation for timer management and cooking schedules

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/kitchen_timer.dart';
import '../../domain/repositories/kitchen_timer_repository.dart';
import '../../domain/failures/failures.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';
import '../mappers/kitchen_timer_mapper.dart';

@LazySingleton(as: KitchenTimerRepository)
class KitchenTimerRepositoryImpl implements KitchenTimerRepository {
  final KitchenTimerMapper _timerMapper;

  // In-memory storage for development
  final Map<String, Map<String, dynamic>> _timers = {};

  KitchenTimerRepositoryImpl({required KitchenTimerMapper timerMapper})
    : _timerMapper = timerMapper;

  @override
  Future<Either<Failure, KitchenTimer>> createTimer(KitchenTimer timer) async {
    try {
      if (_timers.containsKey(timer.id.value)) {
        return Left(
          ValidationFailure('Timer already exists: ${timer.id.value}'),
        );
      }

      final timerData = _timerMapper.toFirestore(timer);
      _timers[timer.id.value] = timerData;

      return Right(timer);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KitchenTimer>> getTimerById(UserId timerId) async {
    try {
      final timerData = _timers[timerId.value];
      if (timerData == null) {
        return Left(NotFoundFailure('Timer not found: ${timerId.value}'));
      }

      final timer = _timerMapper.fromFirestore(timerData, timerId.value);
      return Right(timer);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KitchenTimer>>> getActiveTimers() async {
    try {
      final timers = _timers.values
          .where((timerData) {
            final status = timerData['status'] as String? ?? 'created';
            return status == 'running' || status == 'paused';
          })
          .map(
            (timerData) => _timerMapper.fromFirestore(
              timerData,
              timerData['id'] as String,
            ),
          )
          .toList();
      return Right(timers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KitchenTimer>>> getTimersByStation(
    UserId stationId,
  ) async {
    try {
      final timers = _timers.values
          .where((timerData) => timerData['stationId'] == stationId.value)
          .map(
            (timerData) => _timerMapper.fromFirestore(
              timerData,
              timerData['id'] as String,
            ),
          )
          .toList();
      return Right(timers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KitchenTimer>>> getTimersByType(
    TimerType type,
  ) async {
    try {
      final typeString = _timerTypeToString(type);
      final timers = _timers.values
          .where((timerData) => timerData['type'] == typeString)
          .map(
            (timerData) => _timerMapper.fromFirestore(
              timerData,
              timerData['id'] as String,
            ),
          )
          .toList();
      return Right(timers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KitchenTimer>>> getTimersByStatus(
    TimerStatus status,
  ) async {
    try {
      final statusString = _timerStatusToString(status);
      final timers = _timers.values
          .where((timerData) => timerData['status'] == statusString)
          .map(
            (timerData) => _timerMapper.fromFirestore(
              timerData,
              timerData['id'] as String,
            ),
          )
          .toList();
      return Right(timers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KitchenTimer>>> getTimersByUser(
    UserId userId,
  ) async {
    try {
      final timers = _timers.values
          .where((timerData) => timerData['createdBy'] == userId.value)
          .map(
            (timerData) => _timerMapper.fromFirestore(
              timerData,
              timerData['id'] as String,
            ),
          )
          .toList();
      return Right(timers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KitchenTimer>> startTimer(UserId timerId) async {
    try {
      final timerData = _timers[timerId.value];
      if (timerData == null) {
        return Left(NotFoundFailure('Timer not found: ${timerId.value}'));
      }

      final currentStatus = timerData['status'] as String?;
      if (currentStatus == 'running') {
        return Left(ValidationFailure('Timer is already running'));
      }

      timerData['status'] = 'running';
      timerData['startedAt'] = DateTime.now().millisecondsSinceEpoch;
      timerData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final timer = _timerMapper.fromFirestore(timerData, timerId.value);
      return Right(timer);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KitchenTimer>> pauseTimer(UserId timerId) async {
    try {
      final timerData = _timers[timerId.value];
      if (timerData == null) {
        return Left(NotFoundFailure('Timer not found: ${timerId.value}'));
      }

      final currentStatus = timerData['status'] as String?;
      if (currentStatus != 'running') {
        return Left(ValidationFailure('Timer is not running'));
      }

      timerData['status'] = 'paused';
      timerData['pausedAt'] = DateTime.now().millisecondsSinceEpoch;
      timerData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final timer = _timerMapper.fromFirestore(timerData, timerId.value);
      return Right(timer);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KitchenTimer>> resumeTimer(UserId timerId) async {
    try {
      final timerData = _timers[timerId.value];
      if (timerData == null) {
        return Left(NotFoundFailure('Timer not found: ${timerId.value}'));
      }

      final currentStatus = timerData['status'] as String?;
      if (currentStatus != 'paused') {
        return Left(ValidationFailure('Timer is not paused'));
      }

      timerData['status'] = 'running';
      timerData['pausedAt'] = null;
      timerData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final timer = _timerMapper.fromFirestore(timerData, timerId.value);
      return Right(timer);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KitchenTimer>> stopTimer(UserId timerId) async {
    try {
      final timerData = _timers[timerId.value];
      if (timerData == null) {
        return Left(NotFoundFailure('Timer not found: ${timerId.value}'));
      }

      timerData['status'] = 'completed';
      timerData['completedAt'] = DateTime.now().millisecondsSinceEpoch;
      timerData['remainingDuration'] = 0;
      timerData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final timer = _timerMapper.fromFirestore(timerData, timerId.value);
      return Right(timer);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KitchenTimer>> cancelTimer(UserId timerId) async {
    try {
      final timerData = _timers[timerId.value];
      if (timerData == null) {
        return Left(NotFoundFailure('Timer not found: ${timerId.value}'));
      }

      timerData['status'] = 'cancelled';
      timerData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final timer = _timerMapper.fromFirestore(timerData, timerId.value);
      return Right(timer);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KitchenTimer>> updateTimer(KitchenTimer timer) async {
    try {
      if (!_timers.containsKey(timer.id.value)) {
        return Left(NotFoundFailure('Timer not found: ${timer.id.value}'));
      }

      final timerData = _timerMapper.toFirestore(timer);
      _timers[timer.id.value] = timerData;

      return Right(timer);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTimer(UserId timerId) async {
    try {
      if (!_timers.containsKey(timerId.value)) {
        return Left(NotFoundFailure('Timer not found: ${timerId.value}'));
      }

      _timers.remove(timerId.value);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KitchenTimer>>> getExpiredTimers() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final timers = _timers.values
          .where((timerData) {
            final status = timerData['status'] as String?;
            final startedAt = timerData['startedAt'] as int?;
            final originalDuration = timerData['originalDuration'] as int?;

            if (status == 'running' &&
                startedAt != null &&
                originalDuration != null) {
              final expiredTime = startedAt + originalDuration;
              return now > expiredTime;
            }
            return status == 'expired';
          })
          .map((timerData) {
            // Mark as expired if not already
            if (timerData['status'] != 'expired') {
              timerData['status'] = 'expired';
              timerData['updatedAt'] = now;
            }
            return _timerMapper.fromFirestore(
              timerData,
              timerData['id'] as String,
            );
          })
          .toList();
      return Right(timers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KitchenTimer>>> getCompletedTimers(
    Time startDate,
    Time endDate,
  ) async {
    try {
      final timers = _timers.values
          .where((timerData) {
            final status = timerData['status'] as String?;
            final completedAt = timerData['completedAt'] as int?;
            return status == 'completed' &&
                completedAt != null &&
                completedAt >= startDate.millisecondsSinceEpoch &&
                completedAt <= endDate.millisecondsSinceEpoch;
          })
          .map(
            (timerData) => _timerMapper.fromFirestore(
              timerData,
              timerData['id'] as String,
            ),
          )
          .toList();
      return Right(timers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KitchenTimer>> updateTimerDuration(
    UserId timerId,
    Duration remainingDuration,
  ) async {
    try {
      final timerData = _timers[timerId.value];
      if (timerData == null) {
        return Left(NotFoundFailure('Timer not found: ${timerId.value}'));
      }

      timerData['remainingDuration'] = remainingDuration.inMilliseconds;
      timerData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final timer = _timerMapper.fromFirestore(timerData, timerId.value);
      return Right(timer);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Helper methods
  String _timerTypeToString(TimerType type) {
    switch (type) {
      case TimerType.cooking:
        return 'cooking';
      case TimerType.hold:
        return 'hold';
      case TimerType.prep:
        return 'prep';
      case TimerType.temperatureCheck:
        return 'temperature_check';
      case TimerType.maintenance:
        return 'maintenance';
      case TimerType.foodSafety:
        return 'food_safety';
      case TimerType.staffBreak:
        return 'staff_break';
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
}
