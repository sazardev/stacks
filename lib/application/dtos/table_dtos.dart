// Table Management DTOs for Clean Architecture Application Layer

import 'package:equatable/equatable.dart';
import '../../domain/entities/table.dart';
import '../../domain/value_objects/time.dart';
import '../../domain/value_objects/user_id.dart';

/// DTO for creating a table
class CreateTableDto extends Equatable {
  final String tableNumber;
  final int capacity;
  final String section;
  final List<String>? requirements;
  final double? xPosition;
  final double? yPosition;
  final String? notes;

  const CreateTableDto({
    required this.tableNumber,
    required this.capacity,
    required this.section,
    this.requirements,
    this.xPosition,
    this.yPosition,
    this.notes,
  });

  /// Convert DTO to Table entity
  Table toEntity() {
    return Table(
      id: UserId.generate(),
      tableNumber: tableNumber,
      capacity: capacity,
      section: TableSection.values.firstWhere(
        (s) => s.name.toLowerCase() == section.toLowerCase(),
        orElse: () => TableSection.mainDining,
      ),
      requirements: requirements
          ?.map(
            (req) => TableRequirement.values.firstWhere(
              (r) => r.name.toLowerCase() == req.toLowerCase(),
              orElse: () => TableRequirement.quiet,
            ),
          )
          .toList(),
      xPosition: xPosition,
      yPosition: yPosition,
      notes: notes,
      createdAt: Time.now(),
    );
  }

  @override
  List<Object?> get props => [
    tableNumber,
    capacity,
    section,
    requirements,
    xPosition,
    yPosition,
    notes,
  ];
}

/// DTO for updating a table
class UpdateTableDto extends Equatable {
  final String id;
  final String? tableNumber;
  final int? capacity;
  final String? section;
  final String? status;
  final List<String>? requirements;
  final String? currentServerId;
  final double? xPosition;
  final double? yPosition;
  final String? notes;
  final bool? isActive;

  const UpdateTableDto({
    required this.id,
    this.tableNumber,
    this.capacity,
    this.section,
    this.status,
    this.requirements,
    this.currentServerId,
    this.xPosition,
    this.yPosition,
    this.notes,
    this.isActive,
  });

  @override
  List<Object?> get props => [
    id,
    tableNumber,
    capacity,
    section,
    status,
    requirements,
    currentServerId,
    xPosition,
    yPosition,
    notes,
    isActive,
  ];
}

/// DTO for table status changes
class TableStatusDto extends Equatable {
  final String tableId;
  final String status;
  final String? serverId;
  final String? reservationId;

  const TableStatusDto({
    required this.tableId,
    required this.status,
    this.serverId,
    this.reservationId,
  });

  @override
  List<Object?> get props => [tableId, status, serverId, reservationId];
}

/// DTO for table queries
class TableQueryDto extends Equatable {
  final String? section;
  final String? status;
  final int? minCapacity;
  final int? maxCapacity;
  final String? serverId;
  final bool? availableOnly;

  const TableQueryDto({
    this.section,
    this.status,
    this.minCapacity,
    this.maxCapacity,
    this.serverId,
    this.availableOnly,
  });

  @override
  List<Object?> get props => [
    section,
    status,
    minCapacity,
    maxCapacity,
    serverId,
    availableOnly,
  ];
}

/// DTO for table reservation
class TableReservationDto extends Equatable {
  final String tableId;
  final String customerId;
  final Time reservationTime;
  final int partySize;
  final String? notes;

  const TableReservationDto({
    required this.tableId,
    required this.customerId,
    required this.reservationTime,
    required this.partySize,
    this.notes,
  });

  @override
  List<Object?> get props => [
    tableId,
    customerId,
    reservationTime,
    partySize,
    notes,
  ];
}

/// DTO for updating table status
class UpdateTableStatusDto extends Equatable {
  final UserId tableId;
  final TableStatus newStatus;
  final String? reason;

  const UpdateTableStatusDto({
    required this.tableId,
    required this.newStatus,
    this.reason,
  });

  @override
  List<Object?> get props => [tableId, newStatus, reason];
}
