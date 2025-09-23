// Table Use Cases for Clean Architecture Application Layer

import 'package:dartz/dartz.dart';
import '../../../domain/entities/table.dart';
import '../../../domain/repositories/table_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../dtos/table_dtos.dart';

/// Use case for creating a table
class CreateTableUseCase {
  final TableRepository _repository;

  CreateTableUseCase(this._repository);

  Future<Either<Failure, Table>> call(CreateTableDto dto) {
    final table = dto.toEntity();
    return _repository.createTable(table);
  }
}

/// Use case for getting table by ID
class GetTableByIdUseCase {
  final TableRepository _repository;

  GetTableByIdUseCase(this._repository);

  Future<Either<Failure, Table>> call(UserId tableId) {
    return _repository.getTableById(tableId);
  }
}

/// Use case for getting all tables
class GetAllTablesUseCase {
  final TableRepository _repository;

  GetAllTablesUseCase(this._repository);

  Future<Either<Failure, List<Table>>> call() {
    return _repository.getAllTables();
  }
}

/// Use case for getting tables by status
class GetTablesByStatusUseCase {
  final TableRepository _repository;

  GetTablesByStatusUseCase(this._repository);

  Future<Either<Failure, List<Table>>> call(TableStatus status) {
    return _repository.getTablesByStatus(status);
  }
}

/// Use case for getting tables by section
class GetTablesBySectionUseCase {
  final TableRepository _repository;

  GetTablesBySectionUseCase(this._repository);

  Future<Either<Failure, List<Table>>> call(TableSection section) {
    return _repository.getTablesBySection(section);
  }
}

/// Use case for getting available tables
class GetAvailableTablesUseCase {
  final TableRepository _repository;

  GetAvailableTablesUseCase(this._repository);

  Future<Either<Failure, List<Table>>> call() {
    return _repository.getAvailableTables();
  }
}

/// Use case for getting occupied tables
class GetOccupiedTablesUseCase {
  final TableRepository _repository;

  GetOccupiedTablesUseCase(this._repository);

  Future<Either<Failure, List<Table>>> call() {
    return _repository.getOccupiedTables();
  }
}

/// Use case for getting tables requiring cleaning
class GetTablesRequiringCleaningUseCase {
  final TableRepository _repository;

  GetTablesRequiringCleaningUseCase(this._repository);

  Future<Either<Failure, List<Table>>> call() {
    return _repository.getTablesRequiringCleaning();
  }
}

/// Use case for getting tables by capacity range
class GetTablesByCapacityRangeUseCase {
  final TableRepository _repository;

  GetTablesByCapacityRangeUseCase(this._repository);

  Future<Either<Failure, List<Table>>> call(int minCapacity, int maxCapacity) {
    return _repository.getTablesByCapacityRange(minCapacity, maxCapacity);
  }
}

/// Use case for updating table
class UpdateTableUseCase {
  final TableRepository _repository;

  UpdateTableUseCase(this._repository);

  Future<Either<Failure, Table>> call(UpdateTableDto dto) async {
    // Get existing table
    final existingTableResult = await _repository.getTableById(UserId(dto.id));

    return existingTableResult.fold((failure) => Left(failure), (
      existingTable,
    ) {
      // Create updated table preserving existing data where not provided
      final updatedTable = Table(
        id: existingTable.id,
        tableNumber: dto.tableNumber ?? existingTable.tableNumber,
        capacity: dto.capacity ?? existingTable.capacity,
        section: dto.section != null
            ? _parseTableSection(dto.section!)
            : existingTable.section,
        status: dto.status != null
            ? _parseTableStatus(dto.status!)
            : existingTable.status,
        requirements: dto.requirements != null
            ? dto.requirements!.map(_parseTableRequirement).toList()
            : existingTable.requirements,
        currentServerId: dto.currentServerId != null
            ? (dto.currentServerId!.isEmpty
                  ? null
                  : UserId(dto.currentServerId!))
            : existingTable.currentServerId,
        xPosition: dto.xPosition ?? existingTable.xPosition,
        yPosition: dto.yPosition ?? existingTable.yPosition,
        notes: dto.notes ?? existingTable.notes,
        isActive: dto.isActive ?? existingTable.isActive,
        createdAt: existingTable.createdAt,
      );

      return _repository.updateTable(updatedTable);
    });
  }

  TableSection _parseTableSection(String section) {
    switch (section.toLowerCase()) {
      case 'maindining':
        return TableSection.mainDining;
      case 'bar':
        return TableSection.bar;
      case 'patio':
        return TableSection.patio;
      case 'privatedining':
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

  TableStatus _parseTableStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return TableStatus.available;
      case 'reserved':
        return TableStatus.reserved;
      case 'occupied':
        return TableStatus.occupied;
      case 'needscleaning':
        return TableStatus.needsCleaning;
      case 'cleaning':
        return TableStatus.cleaning;
      case 'outofservice':
        return TableStatus.outOfService;
      case 'maintenance':
        return TableStatus.maintenance;
      default:
        return TableStatus.available;
    }
  }

  TableRequirement _parseTableRequirement(String requirement) {
    switch (requirement.toLowerCase()) {
      case 'wheelchairaccessible':
        return TableRequirement.wheelchairAccessible;
      case 'highchair':
        return TableRequirement.highChair;
      case 'boosterseat':
        return TableRequirement.boosterSeat;
      case 'quiet':
        return TableRequirement.quiet;
      case 'view':
        return TableRequirement.view;
      case 'nearrestroom':
        return TableRequirement.nearRestroom;
      default:
        return TableRequirement.quiet;
    }
  }
}

/// Use case for updating table status
class UpdateTableStatusUseCase {
  final TableRepository _repository;

  UpdateTableStatusUseCase(this._repository);

  Future<Either<Failure, Table>> call(TableStatusDto dto) {
    final status = _parseTableStatus(dto.status);
    return _repository.updateTableStatus(UserId(dto.tableId), status);
  }

  TableStatus _parseTableStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return TableStatus.available;
      case 'reserved':
        return TableStatus.reserved;
      case 'occupied':
        return TableStatus.occupied;
      case 'needscleaning':
        return TableStatus.needsCleaning;
      case 'cleaning':
        return TableStatus.cleaning;
      case 'outofservice':
        return TableStatus.outOfService;
      case 'maintenance':
        return TableStatus.maintenance;
      default:
        return TableStatus.available;
    }
  }
}

/// Use case for reserving a table
class ReserveTableUseCase {
  final TableRepository _repository;

  ReserveTableUseCase(this._repository);

  Future<Either<Failure, Table>> call(TableReservationDto dto) {
    return _repository.reserveTable(
      UserId(dto.tableId),
      UserId(dto.customerId),
      dto.reservationTime,
      dto.partySize,
    );
  }
}

/// Use case for seating customers
class SeatCustomersUseCase {
  final TableRepository _repository;

  SeatCustomersUseCase(this._repository);

  Future<Either<Failure, Table>> call(
    UserId tableId,
    UserId customerId,
    int partySize,
  ) {
    return _repository.seatCustomers(tableId, customerId, partySize);
  }
}

/// Use case for clearing a table
class ClearTableUseCase {
  final TableRepository _repository;

  ClearTableUseCase(this._repository);

  Future<Either<Failure, Table>> call(UserId tableId) {
    return _repository.clearTable(tableId);
  }
}

/// Use case for setting table out of service
class SetTableOutOfServiceUseCase {
  final TableRepository _repository;

  SetTableOutOfServiceUseCase(this._repository);

  Future<Either<Failure, Table>> call(UserId tableId, String reason) {
    return _repository.setTableOutOfService(tableId, reason);
  }
}

/// Use case for returning table to service
class ReturnTableToServiceUseCase {
  final TableRepository _repository;

  ReturnTableToServiceUseCase(this._repository);

  Future<Either<Failure, Table>> call(UserId tableId) {
    return _repository.returnTableToService(tableId);
  }
}

/// Use case for deleting a table
class DeleteTableUseCase {
  final TableRepository _repository;

  DeleteTableUseCase(this._repository);

  Future<Either<Failure, Unit>> call(UserId tableId) {
    return _repository.deleteTable(tableId);
  }
}
