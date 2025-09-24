// Station Mapper for Clean Architecture Infrastructure Layer
// Handles conversion between Station entities and Firestore documents

import 'package:injectable/injectable.dart';
import '../../domain/entities/station.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';

@injectable
class StationMapper {
  /// Converts a Station entity to a Firestore-compatible Map
  Map<String, dynamic> toFirestore(Station station) {
    return {
      'id': station.id.value,
      'name': station.name,
      'capacity': station.capacity,
      'location': station.location,
      'stationType': _stationTypeToString(station.stationType),
      'status': _stationStatusToString(station.status),
      'isActive': station.isActive,
      'currentWorkload': station.currentWorkload,
      'assignedStaff': station.assignedStaff
          .map((userId) => userId.value)
          .toList(),
      'currentOrders': station.currentOrders,
      'createdAt': station.createdAt.millisecondsSinceEpoch,
    };
  }

  /// Converts Firestore document data to a Station entity
  Station fromFirestore(Map<String, dynamic> data, String documentId) {
    return Station(
      id: UserId(data['id'] ?? documentId),
      name: data['name'] ?? '',
      capacity: data['capacity'] ?? 1,
      location: data['location'],
      stationType: _stringToStationType(data['stationType']),
      status: _stringToStationStatus(data['status']),
      isActive: data['isActive'] ?? true,
      currentWorkload: data['currentWorkload'] ?? 0,
      assignedStaff: _parseAssignedStaff(data['assignedStaff']),
      currentOrders: _parseCurrentOrders(data['currentOrders']),
      createdAt: Time.fromMillisecondsSinceEpoch(
        data['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Converts StationType enum to string for Firestore storage
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

  /// Converts string from Firestore to StationType enum
  StationType _stringToStationType(dynamic value) {
    if (value == null || value is! String) return StationType.prep;

    switch (value.toLowerCase()) {
      case 'grill':
        return StationType.grill;
      case 'prep':
        return StationType.prep;
      case 'fryer':
        return StationType.fryer;
      case 'salad':
        return StationType.salad;
      case 'dessert':
        return StationType.dessert;
      case 'beverage':
        return StationType.beverage;
      default:
        return StationType.prep; // Default fallback
    }
  }

  /// Converts StationStatus enum to string for Firestore storage
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

  /// Converts string from Firestore to StationStatus enum
  StationStatus _stringToStationStatus(dynamic value) {
    if (value == null || value is! String) return StationStatus.available;

    switch (value.toLowerCase()) {
      case 'available':
        return StationStatus.available;
      case 'busy':
        return StationStatus.busy;
      case 'maintenance':
        return StationStatus.maintenance;
      case 'offline':
        return StationStatus.offline;
      default:
        return StationStatus.available; // Default fallback
    }
  }

  /// Parses assigned staff list from Firestore data
  List<UserId> _parseAssignedStaff(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => item is String ? UserId(item) : null)
          .where((userId) => userId != null)
          .cast<UserId>()
          .toList();
    }
    return [];
  }

  /// Parses current orders list from Firestore data
  List<String> _parseCurrentOrders(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => item is String ? item : item.toString())
          .toList();
    }
    return [];
  }
}
