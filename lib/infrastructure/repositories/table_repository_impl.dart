// Table Repository Implementation for Clean Architecture Infrastructure Layer
// Simplified mock implementation for restaurant table management

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/table.dart';
import '../../domain/repositories/table_repository.dart';
import '../../domain/failures/failures.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';
import '../mappers/table_mapper.dart';

@LazySingleton(as: TableRepository)
class TableRepositoryImpl implements TableRepository {
  final TableMapper _tableMapper;

  // In-memory storage for development
  final Map<String, Map<String, dynamic>> _tables = {};

  TableRepositoryImpl({required TableMapper tableMapper})
    : _tableMapper = tableMapper;

  @override
  Future<Either<Failure, Table>> createTable(Table table) async {
    try {
      if (_tables.containsKey(table.id.value)) {
        return Left(
          ValidationFailure('Table already exists: ${table.id.value}'),
        );
      }

      final tableData = _tableMapper.toFirestore(table);
      _tables[table.id.value] = tableData;

      return Right(table);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Table>> getTableById(UserId tableId) async {
    try {
      final tableData = _tables[tableId.value];
      if (tableData == null) {
        return Left(NotFoundFailure('Table not found: ${tableId.value}'));
      }

      final table = _tableMapper.fromFirestore(tableData, tableId.value);
      return Right(table);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Table>>> getAllTables() async {
    try {
      final tables = _tables.entries
          .map((entry) => _tableMapper.fromFirestore(entry.value, entry.key))
          .toList();
      return Right(tables);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Table>>> getTablesByStatus(
    TableStatus status,
  ) async {
    try {
      final statusString = _statusToString(status);
      final tables = _tables.values
          .where((tableData) => tableData['status'] == statusString)
          .map(
            (tableData) => _tableMapper.fromFirestore(
              tableData,
              tableData['id'] as String,
            ),
          )
          .toList();
      return Right(tables);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Table>>> getTablesBySection(
    TableSection section,
  ) async {
    try {
      final sectionString = _sectionToString(section);
      final tables = _tables.values
          .where((tableData) => tableData['section'] == sectionString)
          .map(
            (tableData) => _tableMapper.fromFirestore(
              tableData,
              tableData['id'] as String,
            ),
          )
          .toList();
      return Right(tables);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Table>>> getAvailableTables() async {
    try {
      final tables = _tables.values
          .where((tableData) {
            final status = tableData['status'] as String? ?? 'available';
            final isActive = tableData['isActive'] as bool? ?? true;
            return status == 'available' && isActive;
          })
          .map(
            (tableData) => _tableMapper.fromFirestore(
              tableData,
              tableData['id'] as String,
            ),
          )
          .toList();
      return Right(tables);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Table>>> getOccupiedTables() async {
    try {
      final tables = _tables.values
          .where((tableData) => tableData['status'] == 'occupied')
          .map(
            (tableData) => _tableMapper.fromFirestore(
              tableData,
              tableData['id'] as String,
            ),
          )
          .toList();
      return Right(tables);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Table>>> getTablesRequiringCleaning() async {
    try {
      final tables = _tables.values
          .where((tableData) => tableData['status'] == 'needs_cleaning')
          .map(
            (tableData) => _tableMapper.fromFirestore(
              tableData,
              tableData['id'] as String,
            ),
          )
          .toList();
      return Right(tables);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Table>>> getTablesByCapacityRange(
    int minCapacity,
    int maxCapacity,
  ) async {
    try {
      final tables = _tables.values
          .where((tableData) {
            final capacity = tableData['capacity'] as int? ?? 0;
            return capacity >= minCapacity && capacity <= maxCapacity;
          })
          .map(
            (tableData) => _tableMapper.fromFirestore(
              tableData,
              tableData['id'] as String,
            ),
          )
          .toList();
      return Right(tables);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Table>>> getTablesByServer(
    UserId serverId,
  ) async {
    try {
      final tables = _tables.values
          .where((tableData) => tableData['currentServerId'] == serverId.value)
          .map(
            (tableData) => _tableMapper.fromFirestore(
              tableData,
              tableData['id'] as String,
            ),
          )
          .toList();
      return Right(tables);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Table>>> getTablesByRequirements(
    List<TableRequirement> requirements,
  ) async {
    try {
      final requiredStrings = requirements.map(_requirementToString).toSet();
      final tables = _tables.values
          .where((tableData) {
            final tableReqs =
                (tableData['requirements'] as List<dynamic>?)?.cast<String>() ??
                [];
            return requiredStrings.every((req) => tableReqs.contains(req));
          })
          .map(
            (tableData) => _tableMapper.fromFirestore(
              tableData,
              tableData['id'] as String,
            ),
          )
          .toList();
      return Right(tables);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Table>> updateTable(Table table) async {
    try {
      if (!_tables.containsKey(table.id.value)) {
        return Left(NotFoundFailure('Table not found: ${table.id.value}'));
      }

      final tableData = _tableMapper.toFirestore(table);
      _tables[table.id.value] = tableData;

      return Right(table);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Table>> updateTableStatus(
    UserId tableId,
    TableStatus status,
  ) async {
    try {
      final tableData = _tables[tableId.value];
      if (tableData == null) {
        return Left(NotFoundFailure('Table not found: ${tableId.value}'));
      }

      tableData['status'] = _statusToString(status);
      tableData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      // Update cleaning timestamp when status changes to cleaning
      if (status == TableStatus.cleaning) {
        tableData['lastCleanedAt'] = DateTime.now().millisecondsSinceEpoch;
      }

      final table = _tableMapper.fromFirestore(tableData, tableId.value);
      return Right(table);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Table>> assignServerToTable(
    UserId tableId,
    UserId serverId,
  ) async {
    try {
      final tableData = _tables[tableId.value];
      if (tableData == null) {
        return Left(NotFoundFailure('Table not found: ${tableId.value}'));
      }

      tableData['currentServerId'] = serverId.value;
      tableData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final table = _tableMapper.fromFirestore(tableData, tableId.value);
      return Right(table);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Table>> reserveTable(
    UserId tableId,
    UserId customerId,
    Time reservationTime,
    int partySize,
  ) async {
    try {
      final tableData = _tables[tableId.value];
      if (tableData == null) {
        return Left(NotFoundFailure('Table not found: ${tableId.value}'));
      }

      // Check if table has sufficient capacity
      final capacity = tableData['capacity'] as int? ?? 0;
      if (partySize > capacity) {
        return Left(ValidationFailure('Party size exceeds table capacity'));
      }

      tableData['status'] = 'reserved';
      tableData['currentReservationId'] = customerId.value;
      tableData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final table = _tableMapper.fromFirestore(tableData, tableId.value);
      return Right(table);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Table>> seatCustomers(
    UserId tableId,
    UserId customerId,
    int partySize,
  ) async {
    try {
      final tableData = _tables[tableId.value];
      if (tableData == null) {
        return Left(NotFoundFailure('Table not found: ${tableId.value}'));
      }

      // Check if table has sufficient capacity
      final capacity = tableData['capacity'] as int? ?? 0;
      if (partySize > capacity) {
        return Left(ValidationFailure('Party size exceeds table capacity'));
      }

      tableData['status'] = 'occupied';
      tableData['currentReservationId'] = customerId.value;
      tableData['lastOccupiedAt'] = DateTime.now().millisecondsSinceEpoch;
      tableData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final table = _tableMapper.fromFirestore(tableData, tableId.value);
      return Right(table);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Table>> clearTable(UserId tableId) async {
    try {
      final tableData = _tables[tableId.value];
      if (tableData == null) {
        return Left(NotFoundFailure('Table not found: ${tableId.value}'));
      }

      tableData['status'] = 'needs_cleaning';
      tableData['currentServerId'] = null;
      tableData['currentReservationId'] = null;
      tableData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final table = _tableMapper.fromFirestore(tableData, tableId.value);
      return Right(table);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Table>> setTableOutOfService(
    UserId tableId,
    String reason,
  ) async {
    try {
      final tableData = _tables[tableId.value];
      if (tableData == null) {
        return Left(NotFoundFailure('Table not found: ${tableId.value}'));
      }

      tableData['status'] = 'out_of_service';
      tableData['notes'] = reason;
      tableData['isActive'] = false;
      tableData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final table = _tableMapper.fromFirestore(tableData, tableId.value);
      return Right(table);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Table>> returnTableToService(UserId tableId) async {
    try {
      final tableData = _tables[tableId.value];
      if (tableData == null) {
        return Left(NotFoundFailure('Table not found: ${tableId.value}'));
      }

      tableData['status'] = 'available';
      tableData['isActive'] = true;
      tableData['notes'] = null;
      tableData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final table = _tableMapper.fromFirestore(tableData, tableId.value);
      return Right(table);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTable(UserId tableId) async {
    try {
      if (!_tables.containsKey(tableId.value)) {
        return Left(NotFoundFailure('Table not found: ${tableId.value}'));
      }

      _tables.remove(tableId.value);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Table>>> searchTablesByNumber(
    String tableNumber,
  ) async {
    try {
      final lowerQuery = tableNumber.toLowerCase();
      final tables = _tables.values
          .where((tableData) {
            final number = (tableData['tableNumber'] as String? ?? '')
                .toLowerCase();
            return number.contains(lowerQuery);
          })
          .map(
            (tableData) => _tableMapper.fromFirestore(
              tableData,
              tableData['id'] as String,
            ),
          )
          .toList();
      return Right(tables);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTableUtilizationStats(
    Time startDate,
    Time endDate,
  ) async {
    try {
      final allTables = await getAllTables();
      return allTables.fold((failure) => Left(failure), (tables) {
        final statistics = <String, dynamic>{
          'totalTables': tables.length,
          'availableTables': tables
              .where((table) => table.status == TableStatus.available)
              .length,
          'occupiedTables': tables
              .where((table) => table.status == TableStatus.occupied)
              .length,
          'reservedTables': tables
              .where((table) => table.status == TableStatus.reserved)
              .length,
          'tablesNeedingCleaning': tables
              .where((table) => table.status == TableStatus.needsCleaning)
              .length,
          'outOfServiceTables': tables
              .where((table) => table.status == TableStatus.outOfService)
              .length,
          'totalSeats': tables.fold<int>(
            0,
            (sum, table) => sum + table.capacity,
          ),
          'averageCapacity': tables.isNotEmpty
              ? tables.fold<int>(0, (sum, table) => sum + table.capacity) /
                    tables.length
              : 0,
          'sectionCounts': _getSectionCounts(tables),
        };
        return Right(statistics);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Helper methods
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

  Map<String, int> _getSectionCounts(List<Table> tables) {
    final counts = <String, int>{};
    for (final table in tables) {
      final section = table.section.name;
      counts[section] = (counts[section] ?? 0) + 1;
    }
    return counts;
  }
}
