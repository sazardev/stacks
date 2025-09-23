import 'package:dartz/dartz.dart';
import '../entities/inventory_item.dart';
import '../failures/failures.dart';
import '../value_objects/user_id.dart';
import '../value_objects/time.dart';

/// Repository interface for Inventory operations
abstract class InventoryRepository {
  /// Creates a new inventory item
  Future<Either<Failure, InventoryItem>> createInventoryItem(
    InventoryItem item,
  );

  /// Gets an inventory item by its ID
  Future<Either<Failure, InventoryItem>> getInventoryItemById(UserId itemId);

  /// Gets all inventory items
  Future<Either<Failure, List<InventoryItem>>> getAllInventoryItems();

  /// Gets inventory items by category
  Future<Either<Failure, List<InventoryItem>>> getInventoryItemsByCategory(
    InventoryCategory category,
  );

  /// Gets low stock items
  Future<Either<Failure, List<InventoryItem>>> getLowStockItems();

  /// Gets expiring items
  Future<Either<Failure, List<InventoryItem>>> getExpiringItems(
    Time withinDays,
  );

  /// Gets items by supplier
  Future<Either<Failure, List<InventoryItem>>> getItemsBySupplier(
    UserId supplierId,
  );

  /// Updates an inventory item
  Future<Either<Failure, InventoryItem>> updateInventoryItem(
    InventoryItem item,
  );

  /// Updates item quantity
  Future<Either<Failure, InventoryItem>> updateItemQuantity(
    UserId itemId,
    double newQuantity,
  );

  /// Deletes an inventory item
  Future<Either<Failure, Unit>> deleteInventoryItem(UserId itemId);

  /// Searches inventory items by name or SKU
  Future<Either<Failure, List<InventoryItem>>> searchInventoryItems(
    String query,
  );

  /// Gets inventory valuation
  Future<Either<Failure, double>> getInventoryValuation();

  /// Gets inventory turnover rate
  Future<Either<Failure, double>> getInventoryTurnoverRate(
    Time startDate,
    Time endDate,
  );
}
