// Kitchen Timer Mapper for Clean Architecture Infrastructure Layer
// Handles conversion between KitchenTimer entity and Firestore documents

import 'package:injectable/injectable.dart';
import '../../domain/entities/kitchen_timer.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';

@LazySingleton()
class KitchenTimerMapper {
  /// Converts KitchenTimer entity to Firestore document map
  Map<String, dynamic> toFirestore(KitchenTimer timer) {
    return {
      'id': timer.id.value,
      'label': timer.label,
      'type': _timerTypeToString(timer.type),
      'originalDuration': timer.originalDuration.inMilliseconds,
      'remainingDuration': timer.remainingDuration.inMilliseconds,
      'status': _timerStatusToString(timer.status),
      'priority': _timerPriorityToString(timer.priority),
      'orderId': timer.orderId?.value,
      'stationId': timer.stationId?.value,
      'createdBy': timer.createdBy.value,
      'createdAt': timer.createdAt.millisecondsSinceEpoch,
      'startedAt': timer.startedAt?.millisecondsSinceEpoch,
      'pausedAt': timer.pausedAt?.millisecondsSinceEpoch,
      'completedAt': timer.completedAt?.millisecondsSinceEpoch,
      'notes': timer.notes,
      'isRepeating': timer.isRepeating,
      'repeatCount': timer.repeatCount,
      'soundAlert': timer.soundAlert,
      'visualAlert': timer.visualAlert,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Converts Firestore document to KitchenTimer entity
  KitchenTimer fromFirestore(Map<String, dynamic> data, String id) {
    return KitchenTimer(
      id: UserId(id),
      label: data['label'] as String,
      type: _timerTypeFromString(data['type'] as String),
      duration: Duration(milliseconds: data['originalDuration'] as int),
      remainingDuration: Duration(
        milliseconds: data['remainingDuration'] as int,
      ),
      status: _timerStatusFromString(data['status'] as String? ?? 'created'),
      priority: _timerPriorityFromString(
        data['priority'] as String? ?? 'normal',
      ),
      orderId: data['orderId'] != null
          ? UserId(data['orderId'] as String)
          : null,
      stationId: data['stationId'] != null
          ? UserId(data['stationId'] as String)
          : null,
      createdBy: UserId(data['createdBy'] as String),
      createdAt: Time.fromMillisecondsSinceEpoch(data['createdAt'] as int),
      startedAt: data['startedAt'] != null
          ? Time.fromMillisecondsSinceEpoch(data['startedAt'] as int)
          : null,
      pausedAt: data['pausedAt'] != null
          ? Time.fromMillisecondsSinceEpoch(data['pausedAt'] as int)
          : null,
      completedAt: data['completedAt'] != null
          ? Time.fromMillisecondsSinceEpoch(data['completedAt'] as int)
          : null,
      notes: data['notes'] as String?,
      isRepeating: data['isRepeating'] as bool? ?? false,
      repeatCount: data['repeatCount'] as int? ?? 0,
      soundAlert: data['soundAlert'] as bool? ?? true,
      visualAlert: data['visualAlert'] as bool? ?? true,
    );
  }

  // TimerType enum conversion
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

  TimerType _timerTypeFromString(String type) {
    switch (type) {
      case 'cooking':
        return TimerType.cooking;
      case 'hold':
        return TimerType.hold;
      case 'prep':
        return TimerType.prep;
      case 'temperature_check':
        return TimerType.temperatureCheck;
      case 'maintenance':
        return TimerType.maintenance;
      case 'food_safety':
        return TimerType.foodSafety;
      case 'staff_break':
        return TimerType.staffBreak;
      case 'cleaning':
        return TimerType.cleaning;
      default:
        return TimerType.cooking;
    }
  }

  // TimerStatus enum conversion
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

  TimerStatus _timerStatusFromString(String status) {
    switch (status) {
      case 'created':
        return TimerStatus.created;
      case 'running':
        return TimerStatus.running;
      case 'paused':
        return TimerStatus.paused;
      case 'completed':
        return TimerStatus.completed;
      case 'cancelled':
        return TimerStatus.cancelled;
      case 'expired':
        return TimerStatus.expired;
      default:
        return TimerStatus.created;
    }
  }

  // TimerPriority enum conversion
  String _timerPriorityToString(TimerPriority priority) {
    switch (priority) {
      case TimerPriority.low:
        return 'low';
      case TimerPriority.normal:
        return 'normal';
      case TimerPriority.high:
        return 'high';
      case TimerPriority.critical:
        return 'critical';
    }
  }

  TimerPriority _timerPriorityFromString(String priority) {
    switch (priority) {
      case 'low':
        return TimerPriority.low;
      case 'normal':
        return TimerPriority.normal;
      case 'high':
        return TimerPriority.high;
      case 'critical':
        return TimerPriority.critical;
      default:
        return TimerPriority.normal;
    }
  }
}
