// Firebase Table Repository Implementation - Production Ready
// Real Firestore implementation for restaurant table management and reservations

import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/table.dart';
import '../../domain/repositories/table_repository.dart';
import '../../domain/failures/failures.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';
import '../config/firebase_config.dart';
import '../config/firebase_collections.dart';
import '../mappers/table_mapper.dart';

@LazySingleton(as: TableRepository)
class FirebaseTableRepository implements TableRepository {
  final TableMapper _mapper;

  FirebaseTableRepository(this._mapper);

  FirebaseFirestore get _firestore => FirebaseConfig.firestore;

  // Helper method to convert enum values for Firestore
  String _tableStatusToString(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'available';
      case TableStatus.reserved:
        return 'reserved';
      case TableStatus.occupied:
        return 'occupied';
      case TableStatus.needsCleaning:
        return 'needsCleaning';
      case TableStatus.cleaning:
        return 'cleaning';
      case TableStatus.outOfService:
        return 'outOfService';
      case TableStatus.maintenance:
        return 'maintenance';
    }
  }

  String _tableSectionToString(TableSection section) {
    switch (section) {
      case TableSection.mainDining:
        return 'mainDining';
      case TableSection.bar:
        return 'bar';
      case TableSection.patio:
        return 'patio';
      case TableSection.privateDining:
        return 'privateDining';
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

  @override
  Future<Either<Failure, Table>> createTable(Table table) async {
    try {
      developer.log(
        'Creating table: ${table.tableNumber}',
        name: 'FirebaseTableRepository',
      );

      final tableData = _mapper.toFirestore(table);

      String docId;
      if (table.id.value.isNotEmpty) {
        docId = table.id.value;
      } else {
        final docRef = _firestore.collection(FirebaseCollections.tables).doc();
        docId = docRef.id;
      }

      // Add Firestore metadata
      tableData.addAll({
        'id': docId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _firestore
          .collection(FirebaseCollections.tables)
          .doc(docId)
          .set(tableData);

      // Return the table with the new ID from Firestore
      final createdData = tableData;
      createdData['id'] = docId;
      final createdTable = _mapper.fromFirestore(createdData, docId);

      developer.log(
        'Successfully created table with ID: $docId',
        name: 'FirebaseTableRepository',
      );
      return Right(createdTable);
    } catch (e) {
      developer.log(
        'Error creating table: $e',
        name: 'FirebaseTableRepository',
      );
      return Left(ServerFailure('Failed to create table: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Table>> getTableById(UserId tableId) async {
    try {
      developer.log(
        'Getting table: ${tableId.value}',
        name: 'FirebaseTableRepository',
      );

      final doc = await _firestore
          .collection(FirebaseCollections.tables)
          .doc(tableId.value)
          .get();

      if (!doc.exists) {
        return Left(NotFoundFailure('Table not found'));
      }

      final table = _mapper.fromFirestore(doc.data()!, doc.id);
      return Right(table);
    } catch (e) {
      developer.log('Error getting table: $e', name: 'FirebaseTableRepository');
      return Left(ServerFailure('Failed to get table: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Table>>> getAllTables() async {
    try {
      developer.log('Getting all tables', name: 'FirebaseTableRepository');

      final snapshot = await _firestore
          .collection(FirebaseCollections.tables)
          .orderBy('tableNumber')
          .get();

      final tables = snapshot.docs
          .map((doc) => _mapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${tables.length} tables',
        name: 'FirebaseTableRepository',
      );
      return Right(tables);
    } catch (e) {
      developer.log(
        'Error getting tables: $e',
        name: 'FirebaseTableRepository',
      );
      return Left(ServerFailure('Failed to get tables: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Table>>> getTablesByStatus(
    TableStatus status,
  ) async {
    try {
      developer.log(
        'Getting tables by status: $status',
        name: 'FirebaseTableRepository',
      );

      final snapshot = await _firestore
          .collection(FirebaseCollections.tables)
          .where('status', isEqualTo: _tableStatusToString(status))
          .orderBy('tableNumber')
          .get();

      final tables = snapshot.docs
          .map((doc) => _mapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${tables.length} tables with status: $status',
        name: 'FirebaseTableRepository',
      );
      return Right(tables);
    } catch (e) {
      developer.log(
        'Error getting tables by status: $e',
        name: 'FirebaseTableRepository',
      );
      return Left(
        ServerFailure('Failed to get tables by status: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Table>>> getTablesBySection(
    TableSection section,
  ) async {
    try {
      developer.log(
        'Getting tables by section: $section',
        name: 'FirebaseTableRepository',
      );

      final snapshot = await _firestore
          .collection(FirebaseCollections.tables)
          .where('section', isEqualTo: _tableSectionToString(section))
          .orderBy('tableNumber')
          .get();

      final tables = snapshot.docs
          .map((doc) => _mapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${tables.length} tables in section: $section',
        name: 'FirebaseTableRepository',
      );
      return Right(tables);
    } catch (e) {
      developer.log(
        'Error getting tables by section: $e',
        name: 'FirebaseTableRepository',
      );
      return Left(
        ServerFailure('Failed to get tables by section: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Table>>> getAvailableTables() async {
    return getTablesByStatus(TableStatus.available);
  }

  @override
  Future<Either<Failure, List<Table>>> getOccupiedTables() async {
    return getTablesByStatus(TableStatus.occupied);
  }

  @override
  Future<Either<Failure, List<Table>>> getTablesRequiringCleaning() async {
    return getTablesByStatus(TableStatus.needsCleaning);
  }

  @override
  Future<Either<Failure, List<Table>>> getTablesByCapacityRange(
    int minCapacity,
    int maxCapacity,
  ) async {
    try {
      developer.log(
        'Getting tables by capacity range: $minCapacity-$maxCapacity',
        name: 'FirebaseTableRepository',
      );

      final snapshot = await _firestore
          .collection(FirebaseCollections.tables)
          .where('capacity', isGreaterThanOrEqualTo: minCapacity)
          .where('capacity', isLessThanOrEqualTo: maxCapacity)
          .orderBy('capacity')
          .get();

      final tables = snapshot.docs
          .map((doc) => _mapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${tables.length} tables in capacity range',
        name: 'FirebaseTableRepository',
      );
      return Right(tables);
    } catch (e) {
      developer.log(
        'Error getting tables by capacity: $e',
        name: 'FirebaseTableRepository',
      );
      return Left(
        ServerFailure('Failed to get tables by capacity: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Table>>> getTablesByServer(
    UserId serverId,
  ) async {
    try {
      developer.log(
        'Getting tables by server: ${serverId.value}',
        name: 'FirebaseTableRepository',
      );

      final snapshot = await _firestore
          .collection(FirebaseCollections.tables)
          .where('currentServerId', isEqualTo: serverId.value)
          .orderBy('tableNumber')
          .get();

      final tables = snapshot.docs
          .map((doc) => _mapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${tables.length} tables for server: ${serverId.value}',
        name: 'FirebaseTableRepository',
      );
      return Right(tables);
    } catch (e) {
      developer.log(
        'Error getting tables by server: $e',
        name: 'FirebaseTableRepository',
      );
      return Left(
        ServerFailure('Failed to get tables by server: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Table>>> getTablesByRequirements(
    List<TableRequirement> requirements,
  ) async {
    try {
      developer.log(
        'Getting tables by requirements: $requirements',
        name: 'FirebaseTableRepository',
      );

      final requirementStrings = requirements
          .map((req) => req.toString().split('.').last)
          .toList();

      final snapshot = await _firestore
          .collection(FirebaseCollections.tables)
          .where('requirements', arrayContainsAny: requirementStrings)
          .orderBy('tableNumber')
          .get();

      final tables = snapshot.docs
          .map((doc) => _mapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${tables.length} tables with requirements',
        name: 'FirebaseTableRepository',
      );
      return Right(tables);
    } catch (e) {
      developer.log(
        'Error getting tables by requirements: $e',
        name: 'FirebaseTableRepository',
      );
      return Left(
        ServerFailure('Failed to get tables by requirements: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Table>> updateTable(Table table) async {
    try {
      developer.log(
        'Updating table: ${table.id.value}',
        name: 'FirebaseTableRepository',
      );

      final tableData = _mapper.toFirestore(table);
      tableData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirebaseCollections.tables)
          .doc(table.id.value)
          .update(tableData);

      developer.log(
        'Successfully updated table: ${table.id.value}',
        name: 'FirebaseTableRepository',
      );
      return Right(table);
    } catch (e) {
      developer.log(
        'Error updating table: $e',
        name: 'FirebaseTableRepository',
      );
      return Left(ServerFailure('Failed to update table: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Table>> updateTableStatus(
    UserId tableId,
    TableStatus status,
  ) async {
    try {
      developer.log(
        'Updating table status: ${tableId.value} to $status',
        name: 'FirebaseTableRepository',
      );

      await _firestore
          .collection(FirebaseCollections.tables)
          .doc(tableId.value)
          .update({
            'status': _tableStatusToString(status),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Get updated table
      final result = await getTableById(tableId);
      return result;
    } catch (e) {
      developer.log(
        'Error updating table status: $e',
        name: 'FirebaseTableRepository',
      );
      return Left(
        ServerFailure('Failed to update table status: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Table>> assignServerToTable(
    UserId tableId,
    UserId serverId,
  ) async {
    try {
      developer.log(
        'Assigning server ${serverId.value} to table ${tableId.value}',
        name: 'FirebaseTableRepository',
      );

      await _firestore
          .collection(FirebaseCollections.tables)
          .doc(tableId.value)
          .update({
            'currentServerId': serverId.value,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Get updated table
      final result = await getTableById(tableId);
      return result;
    } catch (e) {
      developer.log(
        'Error assigning server to table: $e',
        name: 'FirebaseTableRepository',
      );
      return Left(
        ServerFailure('Failed to assign server to table: ${e.toString()}'),
      );
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
      developer.log(
        'Reserving table ${tableId.value} for customer ${customerId.value}',
        name: 'FirebaseTableRepository',
      );

      await _firestore
          .collection(FirebaseCollections.tables)
          .doc(tableId.value)
          .update({
            'status': _tableStatusToString(TableStatus.reserved),
            'currentReservationId': customerId.value,
            'reservationTime': Timestamp.fromDate(reservationTime.dateTime),
            'partySize': partySize,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Get updated table
      final result = await getTableById(tableId);
      return result;
    } catch (e) {
      developer.log(
        'Error reserving table: $e',
        name: 'FirebaseTableRepository',
      );
      return Left(ServerFailure('Failed to reserve table: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Table>> seatCustomers(
    UserId tableId,
    UserId customerId,
    int partySize,
  ) async {
    try {
      developer.log(
        'Seating customers at table ${tableId.value}',
        name: 'FirebaseTableRepository',
      );

      await _firestore
          .collection(FirebaseCollections.tables)
          .doc(tableId.value)
          .update({
            'status': _tableStatusToString(TableStatus.occupied),
            'currentReservationId': customerId.value,
            'partySize': partySize,
            'lastOccupiedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Get updated table
      final result = await getTableById(tableId);
      return result;
    } catch (e) {
      developer.log(
        'Error seating customers: $e',
        name: 'FirebaseTableRepository',
      );
      return Left(ServerFailure('Failed to seat customers: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Table>> clearTable(UserId tableId) async {
    try {
      developer.log(
        'Clearing table ${tableId.value}',
        name: 'FirebaseTableRepository',
      );

      await _firestore
          .collection(FirebaseCollections.tables)
          .doc(tableId.value)
          .update({
            'status': _tableStatusToString(TableStatus.needsCleaning),
            'currentReservationId': null,
            'partySize': null,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Get updated table
      final result = await getTableById(tableId);
      return result;
    } catch (e) {
      developer.log(
        'Error clearing table: $e',
        name: 'FirebaseTableRepository',
      );
      return Left(ServerFailure('Failed to clear table: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Table>> setTableOutOfService(
    UserId tableId,
    String reason,
  ) async {
    try {
      developer.log(
        'Setting table ${tableId.value} out of service: $reason',
        name: 'FirebaseTableRepository',
      );

      await _firestore
          .collection(FirebaseCollections.tables)
          .doc(tableId.value)
          .update({
            'status': _tableStatusToString(TableStatus.outOfService),
            'outOfServiceReason': reason,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Get updated table
      final result = await getTableById(tableId);
      return result;
    } catch (e) {
      developer.log(
        'Error setting table out of service: $e',
        name: 'FirebaseTableRepository',
      );
      return Left(
        ServerFailure('Failed to set table out of service: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Table>> returnTableToService(UserId tableId) async {
    try {
      developer.log(
        'Returning table ${tableId.value} to service',
        name: 'FirebaseTableRepository',
      );

      await _firestore
          .collection(FirebaseCollections.tables)
          .doc(tableId.value)
          .update({
            'status': _tableStatusToString(TableStatus.available),
            'outOfServiceReason': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Get updated table
      final result = await getTableById(tableId);
      return result;
    } catch (e) {
      developer.log(
        'Error returning table to service: $e',
        name: 'FirebaseTableRepository',
      );
      return Left(
        ServerFailure('Failed to return table to service: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTable(UserId tableId) async {
    try {
      developer.log(
        'Deleting table: ${tableId.value}',
        name: 'FirebaseTableRepository',
      );

      await _firestore
          .collection(FirebaseCollections.tables)
          .doc(tableId.value)
          .delete();

      developer.log(
        'Successfully deleted table: ${tableId.value}',
        name: 'FirebaseTableRepository',
      );
      return const Right(unit);
    } catch (e) {
      developer.log(
        'Error deleting table: $e',
        name: 'FirebaseTableRepository',
      );
      return Left(ServerFailure('Failed to delete table: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Table>>> searchTablesByNumber(
    String tableNumber,
  ) async {
    try {
      developer.log(
        'Searching tables by number: "$tableNumber"',
        name: 'FirebaseTableRepository',
      );

      final snapshot = await _firestore
          .collection(FirebaseCollections.tables)
          .where('tableNumber', isEqualTo: tableNumber)
          .get();

      final tables = snapshot.docs
          .map((doc) => _mapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Search found ${tables.length} matching tables',
        name: 'FirebaseTableRepository',
      );
      return Right(tables);
    } catch (e) {
      developer.log(
        'Error searching tables: $e',
        name: 'FirebaseTableRepository',
      );
      return Left(ServerFailure('Failed to search tables: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTableUtilizationStats(
    Time startDate,
    Time endDate,
  ) async {
    try {
      developer.log(
        'Getting table utilization stats from ${startDate.dateTime} to ${endDate.dateTime}',
        name: 'FirebaseTableRepository',
      );

      final snapshot = await _firestore
          .collection(FirebaseCollections.tables)
          .get();

      final totalTables = snapshot.docs.length;
      final availableTables = snapshot.docs
          .where((doc) => doc.data()['status'] == 'available')
          .length;
      final occupiedTables = snapshot.docs
          .where((doc) => doc.data()['status'] == 'occupied')
          .length;
      final reservedTables = snapshot.docs
          .where((doc) => doc.data()['status'] == 'reserved')
          .length;

      final stats = {
        'totalTables': totalTables,
        'availableTables': availableTables,
        'occupiedTables': occupiedTables,
        'reservedTables': reservedTables,
        'utilizationRate': totalTables > 0
            ? (occupiedTables + reservedTables) / totalTables
            : 0.0,
        'availabilityRate': totalTables > 0
            ? availableTables / totalTables
            : 0.0,
      };

      developer.log(
        'Table utilization stats: $stats',
        name: 'FirebaseTableRepository',
      );
      return Right(stats);
    } catch (e) {
      developer.log(
        'Error getting table utilization stats: $e',
        name: 'FirebaseTableRepository',
      );
      return Left(
        ServerFailure('Failed to get table utilization stats: ${e.toString()}'),
      );
    }
  }

  // Additional helper methods for real-time functionality
  Stream<Either<Failure, List<Table>>> watchTables() {
    try {
      developer.log(
        'Setting up tables stream',
        name: 'FirebaseTableRepository',
      );

      return _firestore
          .collection(FirebaseCollections.tables)
          .orderBy('tableNumber')
          .snapshots()
          .asyncMap((snapshot) async {
            try {
              final tables = snapshot.docs
                  .map((doc) => _mapper.fromFirestore(doc.data(), doc.id))
                  .toList();

              developer.log(
                'Tables stream updated: ${tables.length} tables',
                name: 'FirebaseTableRepository',
              );
              return Right<Failure, List<Table>>(tables);
            } catch (e) {
              developer.log(
                'Error in tables stream: $e',
                name: 'FirebaseTableRepository',
              );
              return Left<Failure, List<Table>>(
                ServerFailure(
                  'Failed to process table updates: ${e.toString()}',
                ),
              );
            }
          });
    } catch (e) {
      developer.log(
        'Error setting up tables stream: $e',
        name: 'FirebaseTableRepository',
      );
      return Stream.value(
        Left(ServerFailure('Failed to setup tables stream: ${e.toString()}')),
      );
    }
  }

  Stream<Either<Failure, List<Table>>> watchTablesByStatus(TableStatus status) {
    try {
      developer.log(
        'Setting up tables stream for status: $status',
        name: 'FirebaseTableRepository',
      );

      return _firestore
          .collection(FirebaseCollections.tables)
          .where('status', isEqualTo: _tableStatusToString(status))
          .orderBy('tableNumber')
          .snapshots()
          .asyncMap((snapshot) async {
            try {
              final tables = snapshot.docs
                  .map((doc) => _mapper.fromFirestore(doc.data(), doc.id))
                  .toList();

              developer.log(
                'Tables status stream updated: ${tables.length} tables',
                name: 'FirebaseTableRepository',
              );
              return Right<Failure, List<Table>>(tables);
            } catch (e) {
              developer.log(
                'Error in tables status stream: $e',
                name: 'FirebaseTableRepository',
              );
              return Left<Failure, List<Table>>(
                ServerFailure(
                  'Failed to process table status updates: ${e.toString()}',
                ),
              );
            }
          });
    } catch (e) {
      developer.log(
        'Error setting up tables status stream: $e',
        name: 'FirebaseTableRepository',
      );
      return Stream.value(
        Left(
          ServerFailure(
            'Failed to setup tables status stream: ${e.toString()}',
          ),
        ),
      );
    }
  }
}
