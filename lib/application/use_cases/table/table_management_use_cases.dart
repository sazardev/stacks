import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/table.dart';
import '../../../domain/repositories/table_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../dtos/table_dtos.dart';

/// Use case for managing table assignments and reservations
@injectable
class GetTableStatusUseCase {
  final TableRepository _tableRepository;

  GetTableStatusUseCase(this._tableRepository);

  /// Execute the table status retrieval use case
  Future<Either<Failure, Table>> execute(UserId tableId) async {
    try {
      final result = await _tableRepository.getTableById(tableId);

      return result.fold((failure) => Left(failure), (table) => Right(table));
    } catch (e) {
      return Left(ServerFailure('Failed to get table status: ${e.toString()}'));
    }
  }
}

/// Use case for updating table status with validation
@injectable
class UpdateTableStatusUseCase {
  final TableRepository _tableRepository;

  UpdateTableStatusUseCase(this._tableRepository);

  /// Execute the table status update use case
  Future<Either<Failure, Table>> execute(UpdateTableStatusDto dto) async {
    try {
      // Step 1: Get existing table
      final tableResult = await _tableRepository.getTableById(dto.tableId);

      final table = tableResult.fold((failure) => null, (table) => table);

      if (table == null) {
        return Left(NotFoundFailure('Table not found: ${dto.tableId.value}'));
      }

      // Step 2: Validate status transition
      if (!_isValidStatusTransition(table.status, dto.newStatus)) {
        return Left(
          ValidationFailure(
            'Invalid status transition from ${table.status} to ${dto.newStatus}',
          ),
        );
      }

      // Step 3: Update table status
      final result = await _tableRepository.updateTableStatus(
        dto.tableId,
        dto.newStatus,
      );

      return result.fold(
        (failure) => Left(failure),
        (updatedTable) => Right(updatedTable),
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to update table status: ${e.toString()}'),
      );
    }
  }

  /// Validate status transition logic
  bool _isValidStatusTransition(
    TableStatus currentStatus,
    TableStatus newStatus,
  ) {
    // Basic validation - can be extended with complex business rules
    const validTransitions = {
      TableStatus.available: [
        TableStatus.occupied,
        TableStatus.reserved,
        TableStatus.outOfService,
      ],
      TableStatus.occupied: [TableStatus.available, TableStatus.outOfService],
      TableStatus.reserved: [
        TableStatus.occupied,
        TableStatus.available,
        TableStatus.outOfService,
      ],
      TableStatus.outOfService: [TableStatus.available],
    };

    return validTransitions[currentStatus]?.contains(newStatus) ?? false;
  }
}

/// Use case for getting all available tables
@injectable
class GetAvailableTablesUseCase {
  final TableRepository _tableRepository;

  GetAvailableTablesUseCase(this._tableRepository);

  /// Execute the available tables retrieval use case
  Future<Either<Failure, List<Table>>> execute() async {
    try {
      final result = await _tableRepository.getAllTables();

      return result.fold((failure) => Left(failure), (tables) {
        final availableTables = tables
            .where((table) => table.status == TableStatus.available)
            .toList();
        return Right(availableTables);
      });
    } catch (e) {
      return Left(
        ServerFailure('Failed to get available tables: ${e.toString()}'),
      );
    }
  }
}
