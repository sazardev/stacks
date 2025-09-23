import 'package:dartz/dartz.dart' show Either, Unit;
import '../entities/table.dart';
import '../value_objects/user_id.dart';
import '../value_objects/time.dart';
import '../failures/failures.dart';

/// Repository interface for Table operations
abstract class TableRepository {
  /// Creates a new table
  Future<Either<Failure, Table>> createTable(Table table);

  /// Gets a table by its ID
  Future<Either<Failure, Table>> getTableById(UserId tableId);

  /// Gets all tables
  Future<Either<Failure, List<Table>>> getAllTables();

  /// Gets tables by status
  Future<Either<Failure, List<Table>>> getTablesByStatus(TableStatus status);

  /// Gets tables by section
  Future<Either<Failure, List<Table>>> getTablesBySection(TableSection section);

  /// Gets available tables
  Future<Either<Failure, List<Table>>> getAvailableTables();

  /// Gets occupied tables
  Future<Either<Failure, List<Table>>> getOccupiedTables();

  /// Gets tables requiring cleaning
  Future<Either<Failure, List<Table>>> getTablesRequiringCleaning();

  /// Gets tables by capacity range
  Future<Either<Failure, List<Table>>> getTablesByCapacityRange(
    int minCapacity,
    int maxCapacity,
  );

  /// Gets tables by server
  Future<Either<Failure, List<Table>>> getTablesByServer(UserId serverId);

  /// Gets tables with specific requirements
  Future<Either<Failure, List<Table>>> getTablesByRequirements(
    List<TableRequirement> requirements,
  );

  /// Updates a table
  Future<Either<Failure, Table>> updateTable(Table table);

  /// Updates table status
  Future<Either<Failure, Table>> updateTableStatus(
    UserId tableId,
    TableStatus status,
  );

  /// Assigns server to table
  Future<Either<Failure, Table>> assignServerToTable(
    UserId tableId,
    UserId serverId,
  );

  /// Reserves a table
  Future<Either<Failure, Table>> reserveTable(
    UserId tableId,
    UserId customerId,
    Time reservationTime,
    int partySize,
  );

  /// Seats customers at table
  Future<Either<Failure, Table>> seatCustomers(
    UserId tableId,
    UserId customerId,
    int partySize,
  );

  /// Clears table after customers leave
  Future<Either<Failure, Table>> clearTable(UserId tableId);

  /// Sets table out of service
  Future<Either<Failure, Table>> setTableOutOfService(
    UserId tableId,
    String reason,
  );

  /// Returns table to service
  Future<Either<Failure, Table>> returnTableToService(UserId tableId);

  /// Deletes a table
  Future<Either<Failure, Unit>> deleteTable(UserId tableId);

  /// Searches tables by table number
  Future<Either<Failure, List<Table>>> searchTablesByNumber(String tableNumber);

  /// Gets table utilization statistics
  Future<Either<Failure, Map<String, dynamic>>> getTableUtilizationStats(
    Time startDate,
    Time endDate,
  );
}
