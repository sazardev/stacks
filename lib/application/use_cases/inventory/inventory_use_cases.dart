// Inventory Use Cases for Clean Architecture Application Layer

import 'package:dartz/dartz.dart';
import '../../../domain/entities/inventory_item.dart';
import '../../../domain/repositories/inventory_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/time.dart';
import '../../../domain/value_objects/money.dart';
import '../../dtos/inventory_dtos.dart';

/// Use case for creating an inventory item
class CreateInventoryItemUseCase {
  final InventoryRepository _repository;

  CreateInventoryItemUseCase(this._repository);

  Future<Either<Failure, InventoryItem>> call(CreateInventoryItemDto dto) {
    final item = dto.toEntity();
    return _repository.createInventoryItem(item);
  }
}

/// Use case for getting inventory item by ID
class GetInventoryItemByIdUseCase {
  final InventoryRepository _repository;

  GetInventoryItemByIdUseCase(this._repository);

  Future<Either<Failure, InventoryItem>> call(String itemId) {
    return _repository.getInventoryItemById(UserId(itemId));
  }
}

/// Use case for getting all inventory items
class GetAllInventoryItemsUseCase {
  final InventoryRepository _repository;

  GetAllInventoryItemsUseCase(this._repository);

  Future<Either<Failure, List<InventoryItem>>> call() {
    return _repository.getAllInventoryItems();
  }
}

/// Use case for getting inventory items by category
class GetInventoryItemsByCategoryUseCase {
  final InventoryRepository _repository;

  GetInventoryItemsByCategoryUseCase(this._repository);

  Future<Either<Failure, List<InventoryItem>>> call(
    InventoryCategory category,
  ) {
    return _repository.getInventoryItemsByCategory(category);
  }
}

/// Use case for getting low stock items
class GetLowStockItemsUseCase {
  final InventoryRepository _repository;

  GetLowStockItemsUseCase(this._repository);

  Future<Either<Failure, List<InventoryItem>>> call() {
    return _repository.getLowStockItems();
  }
}

/// Use case for getting expiring items
class GetExpiringItemsUseCase {
  final InventoryRepository _repository;

  GetExpiringItemsUseCase(this._repository);

  Future<Either<Failure, List<InventoryItem>>> call(Time withinDays) {
    return _repository.getExpiringItems(withinDays);
  }
}

/// Use case for updating inventory item
class UpdateInventoryItemUseCase {
  final InventoryRepository _repository;

  UpdateInventoryItemUseCase(this._repository);

  Future<Either<Failure, InventoryItem>> call(
    UpdateInventoryItemDto dto,
  ) async {
    // Get existing item
    final existingResult = await _repository.getInventoryItemById(
      UserId(dto.id),
    );

    return existingResult.fold((failure) => Left(failure), (existingItem) {
      // Update fields that were provided
      final updatedItem = InventoryItem(
        id: existingItem.id,
        name: dto.name ?? existingItem.name,
        description: dto.description ?? existingItem.description,
        sku: dto.sku ?? existingItem.sku,
        category: dto.category != null
            ? InventoryCategory.values.firstWhere(
                (cat) => cat.name.toLowerCase() == dto.category!.toLowerCase(),
                orElse: () => existingItem.category,
              )
            : existingItem.category,
        currentQuantity: dto.currentQuantity ?? existingItem.currentQuantity,
        reorderLevel: dto.reorderLevel ?? existingItem.reorderLevel,
        maxStockLevel: dto.maxStockLevel ?? existingItem.maxStockLevel,
        unit: dto.unit != null
            ? InventoryUnit.values.firstWhere(
                (u) => u.name.toLowerCase() == dto.unit!.toLowerCase(),
                orElse: () => existingItem.unit,
              )
            : existingItem.unit,
        unitCost: dto.unitCost != null
            ? Money(dto.unitCost!)
            : existingItem.unitCost,
        storageLocation: dto.storageLocation != null
            ? StorageLocation.values.firstWhere(
                (loc) =>
                    loc.name.toLowerCase() ==
                    dto.storageLocation!.toLowerCase(),
                orElse: () => existingItem.storageLocation,
              )
            : existingItem.storageLocation,
        status: existingItem.status,
        supplierId: dto.supplierId != null
            ? UserId(dto.supplierId!)
            : existingItem.supplierId,
        expirationDate: dto.expirationDate ?? existingItem.expirationDate,
        receivedDate: existingItem.receivedDate,
        lastCountDate: existingItem.lastCountDate,
        batchNumber: existingItem.batchNumber,
        lotNumber: existingItem.lotNumber,
        allergens: existingItem.allergens,
        isPerishable: existingItem.isPerishable,
        requiresTemperatureControl: existingItem.requiresTemperatureControl,
        minimumTemperature: existingItem.minimumTemperature,
        maximumTemperature: existingItem.maximumTemperature,
        createdAt: existingItem.createdAt,
        updatedAt: Time.now(),
      );

      return _repository.updateInventoryItem(updatedItem);
    });
  }
}

/// Use case for updating item quantity
class UpdateItemQuantityUseCase {
  final InventoryRepository _repository;

  UpdateItemQuantityUseCase(this._repository);

  Future<Either<Failure, InventoryItem>> call(
    String itemId,
    double newQuantity,
  ) {
    return _repository.updateItemQuantity(UserId(itemId), newQuantity);
  }
}

/// Use case for deleting inventory item
class DeleteInventoryItemUseCase {
  final InventoryRepository _repository;

  DeleteInventoryItemUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String itemId) {
    return _repository.deleteInventoryItem(UserId(itemId));
  }
}

/// Use case for searching inventory items
class SearchInventoryItemsUseCase {
  final InventoryRepository _repository;

  SearchInventoryItemsUseCase(this._repository);

  Future<Either<Failure, List<InventoryItem>>> call(String query) {
    return _repository.searchInventoryItems(query);
  }
}

/// Use case for getting inventory valuation
class GetInventoryValuationUseCase {
  final InventoryRepository _repository;

  GetInventoryValuationUseCase(this._repository);

  Future<Either<Failure, double>> call() {
    return _repository.getInventoryValuation();
  }
}
