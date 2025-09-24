// Table Mapper for Clean Architecture Infrastructure Layer
// Handles conversion between Table entity and Firestore documents

import 'package:injectable/injectable.dart';
import '../../domain/entities/table.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';

@LazySingleton()
class TableMapper {
  /// Converts Table entity to Firestore document map
  Map<String, dynamic> toFirestore(Table table) {
    return {
      'id': table.id.value,
      'tableNumber': table.tableNumber,
      'capacity': table.capacity,
      'section': _sectionToString(table.section),
      'status': _statusToString(table.status),
      'requirements': table.requirements.map(_requirementToString).toList(),
      'currentServerId': table.currentServerId?.value,
      'currentReservationId': table.currentReservationId?.value,
      'lastOccupiedAt': table.lastOccupiedAt?.millisecondsSinceEpoch,
      'lastCleanedAt': table.lastCleanedAt?.millisecondsSinceEpoch,
      'isActive': table.isActive,
      'xPosition': table.xPosition,
      'yPosition': table.yPosition,
      'notes': table.notes,
      'createdAt': table.createdAt.millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Converts Firestore document to Table entity
  Table fromFirestore(Map<String, dynamic> data, String id) {
    return Table(
      id: UserId(id),
      tableNumber: data['tableNumber'] as String,
      capacity: data['capacity'] as int,
      section: _sectionFromString(data['section'] as String),
      status: _statusFromString(data['status'] as String? ?? 'available'),
      requirements: (data['requirements'] as List<dynamic>?)
          ?.map((req) => _requirementFromString(req as String))
          .toList(),
      currentServerId: data['currentServerId'] != null
          ? UserId(data['currentServerId'] as String)
          : null,
      currentReservationId: data['currentReservationId'] != null
          ? UserId(data['currentReservationId'] as String)
          : null,
      lastOccupiedAt: data['lastOccupiedAt'] != null
          ? Time.fromMillisecondsSinceEpoch(data['lastOccupiedAt'] as int)
          : null,
      lastCleanedAt: data['lastCleanedAt'] != null
          ? Time.fromMillisecondsSinceEpoch(data['lastCleanedAt'] as int)
          : null,
      isActive: data['isActive'] as bool? ?? true,
      xPosition: data['xPosition'] as double?,
      yPosition: data['yPosition'] as double?,
      notes: data['notes'] as String?,
      createdAt: Time.fromMillisecondsSinceEpoch(data['createdAt'] as int),
    );
  }

  // TableSection enum conversion
  String _sectionToString(TableSection section) {
    switch (section) {
      case TableSection.mainDining:
        return 'main_dining';
      case TableSection.bar:
        return 'bar';
      case TableSection.patio:
        return 'patio';
      case TableSection.privateDining:
        return 'private_dining';
      case TableSection.counter:
        return 'counter';
      case TableSection.booth:
        return 'booth';
      case TableSection.window:
        return 'window';
      case TableSection.vip:
        return 'vip';
    }
  }

  TableSection _sectionFromString(String section) {
    switch (section) {
      case 'main_dining':
        return TableSection.mainDining;
      case 'bar':
        return TableSection.bar;
      case 'patio':
        return TableSection.patio;
      case 'private_dining':
        return TableSection.privateDining;
      case 'counter':
        return TableSection.counter;
      case 'booth':
        return TableSection.booth;
      case 'window':
        return TableSection.window;
      case 'vip':
        return TableSection.vip;
      default:
        return TableSection.mainDining;
    }
  }

  // TableStatus enum conversion
  String _statusToString(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'available';
      case TableStatus.reserved:
        return 'reserved';
      case TableStatus.occupied:
        return 'occupied';
      case TableStatus.needsCleaning:
        return 'needs_cleaning';
      case TableStatus.cleaning:
        return 'cleaning';
      case TableStatus.outOfService:
        return 'out_of_service';
      case TableStatus.maintenance:
        return 'maintenance';
    }
  }

  TableStatus _statusFromString(String status) {
    switch (status) {
      case 'available':
        return TableStatus.available;
      case 'reserved':
        return TableStatus.reserved;
      case 'occupied':
        return TableStatus.occupied;
      case 'needs_cleaning':
        return TableStatus.needsCleaning;
      case 'cleaning':
        return TableStatus.cleaning;
      case 'out_of_service':
        return TableStatus.outOfService;
      case 'maintenance':
        return TableStatus.maintenance;
      default:
        return TableStatus.available;
    }
  }

  // TableRequirement enum conversion
  String _requirementToString(TableRequirement requirement) {
    switch (requirement) {
      case TableRequirement.wheelchairAccessible:
        return 'wheelchair_accessible';
      case TableRequirement.highChair:
        return 'high_chair';
      case TableRequirement.boosterSeat:
        return 'booster_seat';
      case TableRequirement.quiet:
        return 'quiet';
      case TableRequirement.view:
        return 'view';
      case TableRequirement.nearRestroom:
        return 'near_restroom';
      case TableRequirement.largeParty:
        return 'large_party';
      case TableRequirement.private:
        return 'private';
    }
  }

  TableRequirement _requirementFromString(String requirement) {
    switch (requirement) {
      case 'wheelchair_accessible':
        return TableRequirement.wheelchairAccessible;
      case 'high_chair':
        return TableRequirement.highChair;
      case 'booster_seat':
        return TableRequirement.boosterSeat;
      case 'quiet':
        return TableRequirement.quiet;
      case 'view':
        return TableRequirement.view;
      case 'near_restroom':
        return TableRequirement.nearRestroom;
      case 'large_party':
        return TableRequirement.largeParty;
      case 'private':
        return TableRequirement.private;
      default:
        return TableRequirement.quiet;
    }
  }
}
