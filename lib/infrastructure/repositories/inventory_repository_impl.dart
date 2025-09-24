// Inventory Repository Implementation for Clean Architecture Infrastructure Layer
// Simplified mock implementation with inventory and supplier management

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/failures/failures.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';
import '../mappers/inventory_mapper.dart';

@LazySingleton(as: InventoryRepository)
class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryMapper _inventoryMapper;

  // In-memory storage for development
  final Map<String, Map<String, dynamic>> _inventoryItems = {};

  InventoryRepositoryImpl({required InventoryMapper inventoryMapper})
    : _inventoryMapper = inventoryMapper;

  @override
  Future<Either<Failure, InventoryItem>> createInventoryItem(
    InventoryItem item,
  ) async {
    try {
      if (_inventoryItems.containsKey(item.id.value)) {
        return Left(
          ValidationFailure('Inventory item already exists: ${item.id.value}'),
        );
      }

      final itemData = _inventoryMapper.toFirestore(item);
      _inventoryItems[item.id.value] = itemData;

      return Right(item);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InventoryItem>> getInventoryItemById(
    UserId itemId,
  ) async {
    try {
      final itemData = _inventoryItems[itemId.value];
      if (itemData == null) {
        return Left(
          NotFoundFailure('Inventory item not found: ${itemId.value}'),
        );
      }

      final item = _inventoryMapper.fromFirestore(itemData, itemId.value);
      return Right(item);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InventoryItem>>> getAllInventoryItems() async {
    try {
      final items = _inventoryItems.entries
          .map(
            (entry) => _inventoryMapper.fromFirestore(entry.value, entry.key),
          )
          .toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InventoryItem>>> getInventoryItemsByCategory(
    InventoryCategory category,
  ) async {
    try {
      final categoryString = _getCategoryString(category);
      final items = _inventoryItems.values
          .where((itemData) => itemData['category'] == categoryString)
          .map(
            (itemData) => _inventoryMapper.fromFirestore(
              itemData,
              itemData['id'] as String,
            ),
          )
          .toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InventoryItem>>> getLowStockItems() async {
    try {
      final items = _inventoryItems.values
          .where((itemData) {
            final currentQuantity =
                itemData['currentQuantity'] as double? ?? 0.0;
            final reorderLevel = itemData['reorderLevel'] as double? ?? 0.0;
            return currentQuantity <= reorderLevel;
          })
          .map(
            (itemData) => _inventoryMapper.fromFirestore(
              itemData,
              itemData['id'] as String,
            ),
          )
          .toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InventoryItem>>> getExpiringItems(
    Time beforeDate,
  ) async {
    try {
      final items = _inventoryItems.values
          .where((itemData) {
            final expirationDate = itemData['expirationDate'];
            if (expirationDate == null) return false;
            return expirationDate <= beforeDate.millisecondsSinceEpoch;
          })
          .map(
            (itemData) => _inventoryMapper.fromFirestore(
              itemData,
              itemData['id'] as String,
            ),
          )
          .toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InventoryItem>>> getItemsBySupplier(
    UserId supplierId,
  ) async {
    try {
      final items = _inventoryItems.values
          .where((itemData) => itemData['supplierId'] == supplierId.value)
          .map(
            (itemData) => _inventoryMapper.fromFirestore(
              itemData,
              itemData['id'] as String,
            ),
          )
          .toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InventoryItem>>> searchInventoryItems(
    String query,
  ) async {
    try {
      final lowerQuery = query.toLowerCase();
      final items = _inventoryItems.values
          .where((itemData) {
            final name = (itemData['name'] as String? ?? '').toLowerCase();
            final sku = (itemData['sku'] as String? ?? '').toLowerCase();
            final description = (itemData['description'] as String? ?? '')
                .toLowerCase();
            return name.contains(lowerQuery) ||
                sku.contains(lowerQuery) ||
                description.contains(lowerQuery);
          })
          .map(
            (itemData) => _inventoryMapper.fromFirestore(
              itemData,
              itemData['id'] as String,
            ),
          )
          .toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InventoryItem>> updateInventoryItem(
    InventoryItem item,
  ) async {
    try {
      if (!_inventoryItems.containsKey(item.id.value)) {
        return Left(
          NotFoundFailure('Inventory item not found: ${item.id.value}'),
        );
      }

      final itemData = _inventoryMapper.toFirestore(item);
      _inventoryItems[item.id.value] = itemData;

      return Right(item);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InventoryItem>> updateItemQuantity(
    UserId itemId,
    double newQuantity,
  ) async {
    try {
      final itemData = _inventoryItems[itemId.value];
      if (itemData == null) {
        return Left(
          NotFoundFailure('Inventory item not found: ${itemId.value}'),
        );
      }

      itemData['currentQuantity'] = newQuantity;
      itemData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      // Update status based on quantity
      final reorderLevel = itemData['reorderLevel'] as double? ?? 0.0;
      if (newQuantity <= 0) {
        itemData['status'] = 'out_of_stock';
      } else if (newQuantity <= reorderLevel) {
        itemData['status'] = 'low_stock';
      } else {
        itemData['status'] = 'in_stock';
      }

      final item = _inventoryMapper.fromFirestore(itemData, itemId.value);
      return Right(item);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getInventoryValuation() async {
    try {
      final allItems = await getAllInventoryItems();
      return allItems.fold((failure) => Left(failure), (items) {
        final totalValue = items.fold<double>(
          0.0,
          (sum, item) => sum + (item.currentQuantity * item.unitCost.amount),
        );
        return Right(totalValue);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getInventoryTurnoverRate(
    Time startDate,
    Time endDate,
  ) async {
    try {
      // Simplified calculation - in real implementation, would need sales data
      final allItems = await getAllInventoryItems();
      return allItems.fold((failure) => Left(failure), (items) {
        if (items.isEmpty) return const Right(0.0);

        // Mock calculation based on reorder levels as proxy for usage
        final totalReorderValue = items.fold<double>(
          0.0,
          (sum, item) => sum + (item.reorderLevel * item.unitCost.amount),
        );
        final totalCurrentValue = items.fold<double>(
          0.0,
          (sum, item) => sum + (item.currentQuantity * item.unitCost.amount),
        );

        if (totalCurrentValue == 0) return const Right(0.0);

        // Simple turnover rate calculation
        final turnoverRate = totalReorderValue / totalCurrentValue;
        return Right(turnoverRate);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteInventoryItem(UserId itemId) async {
    try {
      if (!_inventoryItems.containsKey(itemId.value)) {
        return Left(
          NotFoundFailure('Inventory item not found: ${itemId.value}'),
        );
      }

      _inventoryItems.remove(itemId.value);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Helper methods
  String _getCategoryString(InventoryCategory category) {
    switch (category) {
      case InventoryCategory.produce:
        return 'produce';
      case InventoryCategory.protein:
        return 'protein';
      case InventoryCategory.dairy:
        return 'dairy';
      case InventoryCategory.dryGoods:
        return 'dry_goods';
      case InventoryCategory.frozen:
        return 'frozen';
      case InventoryCategory.beverages:
        return 'beverages';
      case InventoryCategory.seasonings:
        return 'seasonings';
      case InventoryCategory.cleaning:
        return 'cleaning';
      case InventoryCategory.disposables:
        return 'disposables';
      case InventoryCategory.equipment:
        return 'equipment';
    }
  }
}
