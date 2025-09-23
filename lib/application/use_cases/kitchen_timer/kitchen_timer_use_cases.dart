// Kitchen Timer Use Cases for Clean Architecture Application Layer

import 'package:dartz/dartz.dart';
import '../../../domain/entities/kitchen_timer.dart';
import '../../../domain/repositories/kitchen_timer_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../dtos/kitchen_timer_dtos.dart';

/// Use case for creating a kitchen timer
class CreateKitchenTimerUseCase {
  final KitchenTimerRepository _repository;

  CreateKitchenTimerUseCase(this._repository);

  Future<Either<Failure, KitchenTimer>> call(CreateKitchenTimerDto dto) {
    final timer = dto.toEntity();
    return _repository.createTimer(timer);
  }
}

/// Use case for getting timer by ID
class GetTimerByIdUseCase {
  final KitchenTimerRepository _repository;

  GetTimerByIdUseCase(this._repository);

  Future<Either<Failure, KitchenTimer>> call(String timerId) {
    return _repository.getTimerById(UserId(timerId));
  }
}

/// Use case for getting active timers
class GetActiveTimersUseCase {
  final KitchenTimerRepository _repository;

  GetActiveTimersUseCase(this._repository);

  Future<Either<Failure, List<KitchenTimer>>> call() {
    return _repository.getActiveTimers();
  }
}

/// Use case for getting timers by station
class GetTimersByStationUseCase {
  final KitchenTimerRepository _repository;

  GetTimersByStationUseCase(this._repository);

  Future<Either<Failure, List<KitchenTimer>>> call(String stationId) {
    return _repository.getTimersByStation(UserId(stationId));
  }
}

/// Use case for starting a timer
class StartTimerUseCase {
  final KitchenTimerRepository _repository;

  StartTimerUseCase(this._repository);

  Future<Either<Failure, KitchenTimer>> call(String timerId) {
    return _repository.startTimer(UserId(timerId));
  }
}

/// Use case for pausing a timer
class PauseTimerUseCase {
  final KitchenTimerRepository _repository;

  PauseTimerUseCase(this._repository);

  Future<Either<Failure, KitchenTimer>> call(String timerId) {
    return _repository.pauseTimer(UserId(timerId));
  }
}

/// Use case for resuming a timer
class ResumeTimerUseCase {
  final KitchenTimerRepository _repository;

  ResumeTimerUseCase(this._repository);

  Future<Either<Failure, KitchenTimer>> call(String timerId) {
    return _repository.resumeTimer(UserId(timerId));
  }
}

/// Use case for stopping a timer
class StopTimerUseCase {
  final KitchenTimerRepository _repository;

  StopTimerUseCase(this._repository);

  Future<Either<Failure, KitchenTimer>> call(String timerId) {
    return _repository.stopTimer(UserId(timerId));
  }
}

/// Use case for cancelling a timer
class CancelTimerUseCase {
  final KitchenTimerRepository _repository;

  CancelTimerUseCase(this._repository);

  Future<Either<Failure, KitchenTimer>> call(String timerId) {
    return _repository.cancelTimer(UserId(timerId));
  }
}

/// Use case for timer operations (start, pause, resume, stop, cancel)
class TimerOperationUseCase {
  final KitchenTimerRepository _repository;

  TimerOperationUseCase(this._repository);

  Future<Either<Failure, KitchenTimer>> call(TimerOperationDto dto) {
    switch (dto.operation.toLowerCase()) {
      case 'start':
        return _repository.startTimer(UserId(dto.timerId));
      case 'pause':
        return _repository.pauseTimer(UserId(dto.timerId));
      case 'resume':
        return _repository.resumeTimer(UserId(dto.timerId));
      case 'stop':
        return _repository.stopTimer(UserId(dto.timerId));
      case 'cancel':
        return _repository.cancelTimer(UserId(dto.timerId));
      default:
        return Future.value(
          Left(ValidationFailure('Invalid timer operation: ${dto.operation}')),
        );
    }
  }
}

/// Use case for updating a timer
class UpdateKitchenTimerUseCase {
  final KitchenTimerRepository _repository;

  UpdateKitchenTimerUseCase(this._repository);

  Future<Either<Failure, KitchenTimer>> call(UpdateKitchenTimerDto dto) async {
    // Get existing timer
    final existingResult = await _repository.getTimerById(UserId(dto.id));

    return existingResult.fold((failure) => Left(failure), (existingTimer) {
      // Update fields that were provided
      final updatedTimer = KitchenTimer(
        id: existingTimer.id,
        label: dto.label ?? existingTimer.label,
        type: existingTimer.type,
        duration: existingTimer.originalDuration,
        remainingDuration: existingTimer.remainingDuration,
        status: existingTimer.status,
        priority: existingTimer.priority,
        orderId: existingTimer.orderId,
        stationId: existingTimer.stationId,
        createdBy: existingTimer.createdBy,
        createdAt: existingTimer.createdAt,
        startedAt: existingTimer.startedAt,
        pausedAt: existingTimer.pausedAt,
        completedAt: existingTimer.completedAt,
        notes: dto.notes ?? existingTimer.notes,
        isRepeating: existingTimer.isRepeating,
        repeatCount: existingTimer.repeatCount,
        soundAlert: dto.soundAlert ?? existingTimer.soundAlert,
        visualAlert: dto.visualAlert ?? existingTimer.visualAlert,
      );

      return _repository.updateTimer(updatedTimer);
    });
  }
}

/// Use case for deleting a timer
class DeleteKitchenTimerUseCase {
  final KitchenTimerRepository _repository;

  DeleteKitchenTimerUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String timerId) {
    return _repository.deleteTimer(UserId(timerId));
  }
}

/// Use case for getting expired timers
class GetExpiredTimersUseCase {
  final KitchenTimerRepository _repository;

  GetExpiredTimersUseCase(this._repository);

  Future<Either<Failure, List<KitchenTimer>>> call() {
    return _repository.getExpiredTimers();
  }
}
