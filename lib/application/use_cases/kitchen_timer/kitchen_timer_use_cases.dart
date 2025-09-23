// Kitchen Timer Use Cases for Clean Architecture Application Layer
// Enhanced with ProductionSchedule and ProductionScheduleItem support

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/kitchen_timer.dart';
import '../../../domain/repositories/kitchen_timer_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/time.dart';
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

// =============================================================================
// ProductionSchedule Use Cases
// =============================================================================

/// Use case for creating a production schedule
@injectable
class CreateProductionScheduleUseCase {
  const CreateProductionScheduleUseCase();

  /// Creates a new production schedule
  Future<Either<Failure, ProductionSchedule>> call({
    required String name,
    required Time scheduleDate,
    required Time startTime,
    required Time endTime,
    required UserId createdBy,
    List<ProductionScheduleItem>? items,
  }) async {
    try {
      // Validate inputs
      final validationResult = _validateScheduleInput(
        name,
        scheduleDate,
        startTime,
        endTime,
      );
      if (validationResult != null) {
        return Left(validationResult);
      }

      final schedule = ProductionSchedule(
        id: UserId.generate(),
        name: name,
        scheduleDate: scheduleDate,
        startTime: startTime,
        endTime: endTime,
        items: items ?? [],
        createdBy: createdBy,
        createdAt: Time.now(),
      );

      // In a real implementation, this would use a ProductionScheduleRepository
      // For now, we return the created schedule as success
      return Right(schedule);
    } catch (e) {
      return Left(ServerFailure('Error creating production schedule: $e'));
    }
  }

  ValidationFailure? _validateScheduleInput(
    String name,
    Time scheduleDate,
    Time startTime,
    Time endTime,
  ) {
    if (name.trim().isEmpty) {
      return const ValidationFailure('Schedule name cannot be empty');
    }

    if (startTime.dateTime.isAfter(endTime.dateTime)) {
      return const ValidationFailure('Start time must be before end time');
    }

    if (scheduleDate.dateTime.isBefore(Time.now().dateTime)) {
      return const ValidationFailure('Schedule date cannot be in the past');
    }

    return null;
  }
}

/// Use case for adding items to a production schedule
@injectable
class AddItemToProductionScheduleUseCase {
  const AddItemToProductionScheduleUseCase();

  /// Adds a production item to a schedule
  Future<Either<Failure, ProductionSchedule>> call(
    ProductionSchedule schedule,
    ProductionScheduleItem item,
  ) async {
    try {
      // Validate that item doesn't already exist
      final existingItems = schedule.items;
      final itemExists = existingItems.any(
        (existing) => existing.id == item.id,
      );

      if (itemExists) {
        return Left(
          BusinessRuleFailure(
            'Item with ID ${item.id.value} already exists in schedule',
          ),
        );
      }

      // Create updated schedule with new item
      final updatedItems = [...existingItems, item];
      final updatedSchedule = ProductionSchedule(
        id: schedule.id,
        name: schedule.name,
        scheduleDate: schedule.scheduleDate,
        startTime: schedule.startTime,
        endTime: schedule.endTime,
        items: updatedItems,
        overallStatus: schedule.overallStatus,
        createdBy: schedule.createdBy,
        createdAt: schedule.createdAt,
        updatedAt: Time.now(),
      );

      return Right(updatedSchedule);
    } catch (e) {
      return Left(ServerFailure('Error adding item to schedule: $e'));
    }
  }
}

/// Use case for updating production schedule item status
@injectable
class UpdateProductionScheduleItemStatusUseCase {
  const UpdateProductionScheduleItemStatusUseCase();

  /// Updates the status of a production schedule item
  Future<Either<Failure, ProductionScheduleItem>> call(
    ProductionScheduleItem item,
    ProductionStatus newStatus,
  ) async {
    try {
      // Validate status transition
      final canTransition = _canTransitionStatus(item.status, newStatus);
      if (!canTransition) {
        return Left(
          BusinessRuleFailure(
            'Invalid status transition from ${item.status} to $newStatus',
          ),
        );
      }

      // Create updated item with new status
      final updatedItem = ProductionScheduleItem(
        id: item.id,
        type: item.type,
        description: item.description,
        recipeId: item.recipeId,
        inventoryItemId: item.inventoryItemId,
        quantity: item.quantity,
        estimatedDuration: item.estimatedDuration,
        actualDuration: item.actualDuration,
        assignedStationId: item.assignedStationId,
        assignedUserId: item.assignedUserId,
        scheduledStartTime: item.scheduledStartTime,
        actualStartTime: item.actualStartTime,
        completedTime: newStatus == ProductionStatus.completed
            ? Time.now()
            : item.completedTime,
        status: newStatus,
        priority: item.priority,
        dependencies: item.dependencies,
      );

      return Right(updatedItem);
    } catch (e) {
      return Left(ServerFailure('Error updating item status: $e'));
    }
  }

  bool _canTransitionStatus(ProductionStatus current, ProductionStatus target) {
    // Define valid status transitions
    const validTransitions = {
      ProductionStatus.planned: [
        ProductionStatus.inProgress,
        ProductionStatus.cancelled,
      ],
      ProductionStatus.inProgress: [
        ProductionStatus.completed,
        ProductionStatus.paused,
        ProductionStatus.cancelled,
      ],
      ProductionStatus.paused: [
        ProductionStatus.inProgress,
        ProductionStatus.cancelled,
      ],
      ProductionStatus.completed: <ProductionStatus>[],
      ProductionStatus.cancelled: <ProductionStatus>[],
    };

    final allowedTransitions = validTransitions[current] ?? [];
    return allowedTransitions.contains(target);
  }
}

/// Use case for getting production schedule by date range
@injectable
class GetProductionSchedulesByDateRangeUseCase {
  const GetProductionSchedulesByDateRangeUseCase();

  /// Gets production schedules within a date range
  Future<Either<Failure, List<ProductionSchedule>>> call(
    Time startDate,
    Time endDate,
  ) async {
    try {
      if (startDate.dateTime.isAfter(endDate.dateTime)) {
        return Left(ValidationFailure('Start date must be before end date'));
      }

      // In a real implementation, this would query a ProductionScheduleRepository
      // For now, we return an empty list as success
      return const Right(<ProductionSchedule>[]);
    } catch (e) {
      return Left(ServerFailure('Error getting schedules by date range: $e'));
    }
  }
}

/// Use case for getting overdue production items
@injectable
class GetOverdueProductionItemsUseCase {
  const GetOverdueProductionItemsUseCase();

  /// Gets all overdue production items across all schedules
  Future<Either<Failure, List<ProductionScheduleItem>>> call() async {
    try {
      // In a real implementation, this would query all schedules and
      // return items where actualEndTime > scheduledEndTime
      // For now, we return an empty list as success
      return const Right(<ProductionScheduleItem>[]);
    } catch (e) {
      return Left(ServerFailure('Error getting overdue items: $e'));
    }
  }
}
