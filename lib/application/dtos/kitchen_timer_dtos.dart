// Kitchen Timer DTOs for Clean Architecture Application Layer

import 'package:equatable/equatable.dart';
import '../../domain/entities/kitchen_timer.dart';
import '../../domain/value_objects/time.dart';
import '../../domain/value_objects/user_id.dart';

/// DTO for creating a kitchen timer
class CreateKitchenTimerDto extends Equatable {
  final String label;
  final String type;
  final int durationSeconds;
  final String priority;
  final String? orderId;
  final String? stationId;
  final String createdBy;
  final String? notes;
  final bool isRepeating;
  final bool soundAlert;
  final bool visualAlert;

  const CreateKitchenTimerDto({
    required this.label,
    required this.type,
    required this.durationSeconds,
    required this.priority,
    this.orderId,
    this.stationId,
    required this.createdBy,
    this.notes,
    this.isRepeating = false,
    this.soundAlert = true,
    this.visualAlert = true,
  });

  /// Convert DTO to KitchenTimer entity
  KitchenTimer toEntity() {
    return KitchenTimer(
      id: UserId.generate(),
      label: label,
      type: TimerType.values.firstWhere(
        (t) => t.name.toLowerCase() == type.toLowerCase(),
        orElse: () => TimerType.cooking,
      ),
      duration: Duration(seconds: durationSeconds),
      priority: TimerPriority.values.firstWhere(
        (p) => p.name.toLowerCase() == priority.toLowerCase(),
        orElse: () => TimerPriority.normal,
      ),
      orderId: orderId != null ? UserId(orderId!) : null,
      stationId: stationId != null ? UserId(stationId!) : null,
      createdBy: UserId(createdBy),
      createdAt: Time.now(),
      notes: notes,
      isRepeating: isRepeating,
      soundAlert: soundAlert,
      visualAlert: visualAlert,
    );
  }

  @override
  List<Object?> get props => [
    label,
    type,
    durationSeconds,
    priority,
    orderId,
    stationId,
    createdBy,
    notes,
    isRepeating,
    soundAlert,
    visualAlert,
  ];
}

/// DTO for updating a kitchen timer
class UpdateKitchenTimerDto extends Equatable {
  final String id;
  final String? label;
  final String? notes;
  final bool? soundAlert;
  final bool? visualAlert;

  const UpdateKitchenTimerDto({
    required this.id,
    this.label,
    this.notes,
    this.soundAlert,
    this.visualAlert,
  });

  @override
  List<Object?> get props => [id, label, notes, soundAlert, visualAlert];
}

/// DTO for timer operations
class TimerOperationDto extends Equatable {
  final String timerId;
  final String operation; // start, pause, resume, stop, cancel

  const TimerOperationDto({required this.timerId, required this.operation});

  @override
  List<Object?> get props => [timerId, operation];
}

/// DTO for timer queries
class TimerQueryDto extends Equatable {
  final String? type;
  final String? status;
  final String? stationId;
  final String? createdBy;
  final bool? activeOnly;

  const TimerQueryDto({
    this.type,
    this.status,
    this.stationId,
    this.createdBy,
    this.activeOnly,
  });

  @override
  List<Object?> get props => [type, status, stationId, createdBy, activeOnly];
}
