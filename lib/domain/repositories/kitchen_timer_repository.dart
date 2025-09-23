import 'package:dartz/dartz.dart';
import '../entities/kitchen_timer.dart';
import '../failures/failures.dart';
import '../value_objects/user_id.dart';
import '../value_objects/time.dart';

/// Repository interface for Kitchen Timer operations
abstract class KitchenTimerRepository {
  /// Creates a new kitchen timer
  Future<Either<Failure, KitchenTimer>> createTimer(KitchenTimer timer);

  /// Gets a timer by its ID
  Future<Either<Failure, KitchenTimer>> getTimerById(UserId timerId);

  /// Gets all active timers
  Future<Either<Failure, List<KitchenTimer>>> getActiveTimers();

  /// Gets timers by station
  Future<Either<Failure, List<KitchenTimer>>> getTimersByStation(
    UserId stationId,
  );

  /// Gets timers by type
  Future<Either<Failure, List<KitchenTimer>>> getTimersByType(TimerType type);

  /// Gets timers by status
  Future<Either<Failure, List<KitchenTimer>>> getTimersByStatus(
    TimerStatus status,
  );

  /// Gets timers created by user
  Future<Either<Failure, List<KitchenTimer>>> getTimersByUser(UserId userId);

  /// Starts a timer
  Future<Either<Failure, KitchenTimer>> startTimer(UserId timerId);

  /// Pauses a timer
  Future<Either<Failure, KitchenTimer>> pauseTimer(UserId timerId);

  /// Resumes a paused timer
  Future<Either<Failure, KitchenTimer>> resumeTimer(UserId timerId);

  /// Stops a timer
  Future<Either<Failure, KitchenTimer>> stopTimer(UserId timerId);

  /// Cancels a timer
  Future<Either<Failure, KitchenTimer>> cancelTimer(UserId timerId);

  /// Updates a timer
  Future<Either<Failure, KitchenTimer>> updateTimer(KitchenTimer timer);

  /// Deletes a timer
  Future<Either<Failure, Unit>> deleteTimer(UserId timerId);

  /// Gets expired timers
  Future<Either<Failure, List<KitchenTimer>>> getExpiredTimers();

  /// Gets completed timers
  Future<Either<Failure, List<KitchenTimer>>> getCompletedTimers(
    Time startDate,
    Time endDate,
  );

  /// Updates timer remaining duration
  Future<Either<Failure, KitchenTimer>> updateTimerDuration(
    UserId timerId,
    Duration remainingDuration,
  );
}
