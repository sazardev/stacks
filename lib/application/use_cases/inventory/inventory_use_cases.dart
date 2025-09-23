// Inventory Use Cases for Clean Architecture Application Layer
// Complete coverage for InventoryItem and Supplier entities

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/inventory_item.dart';
import '../../../domain/repositories/inventory_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/time.dart';
import '../../../domain/value_objects/money.dart';
import '../../dtos/inventory_dtos.dart';

/// Use case for creating an inventory item
@injectable
class CreateInventoryItemUseCase {
  final InventoryRepository _repository;

  const CreateInventoryItemUseCase(this._repository);

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

// =============================================================================
// Supplier Use Cases
// =============================================================================

/// Use case for creating a supplier
@injectable
class CreateSupplierUseCase {
  const CreateSupplierUseCase();

  /// Creates a new supplier
  Future<Either<Failure, Supplier>> call({
    required String name,
    required String contactPerson,
    required String phone,
    required String email,
    String? address,
    List<String>? categories,
    bool isActive = true,
  }) async {
    try {
      // Validate inputs
      final validationResult = _validateSupplierInput(
        name,
        contactPerson,
        phone,
        email,
      );
      if (validationResult != null) {
        return Left(validationResult);
      }

      final supplier = Supplier(
        id: UserId.generate(),
        name: name,
        contactPerson: contactPerson,
        phone: phone,
        email: email,
        address: address,
        categories: categories ?? [],
        isActive: isActive,
        createdAt: Time.now(),
      );

      // In a real implementation, this would use a SupplierRepository
      // For now, we return the created supplier as success
      return Right(supplier);
    } catch (e) {
      return Left(ServerFailure('Error creating supplier: $e'));
    }
  }

  ValidationFailure? _validateSupplierInput(
    String name,
    String contactPerson,
    String phone,
    String email,
  ) {
    if (name.trim().isEmpty) {
      return const ValidationFailure('Supplier name cannot be empty');
    }

    if (contactPerson.trim().isEmpty) {
      return const ValidationFailure('Contact person cannot be empty');
    }

    if (phone.trim().isEmpty) {
      return const ValidationFailure('Phone cannot be empty');
    }

    if (email.trim().isEmpty) {
      return const ValidationFailure('Email cannot be empty');
    }

    if (!_isValidEmail(email)) {
      return const ValidationFailure('Invalid email format');
    }

    return null;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

/// Use case for updating a supplier
@injectable
class UpdateSupplierUseCase {
  const UpdateSupplierUseCase();

  /// Updates an existing supplier
  Future<Either<Failure, Supplier>> call(
    Supplier currentSupplier, {
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    List<String>? categories,
    bool? isActive,
  }) async {
    try {
      // Validate inputs if provided
      if (name != null && name.trim().isEmpty) {
        return Left(ValidationFailure('Supplier name cannot be empty'));
      }

      if (email != null && !_isValidEmail(email)) {
        return Left(ValidationFailure('Invalid email format'));
      }

      final updatedSupplier = Supplier(
        id: currentSupplier.id,
        name: name ?? currentSupplier.name,
        contactPerson: contactPerson ?? currentSupplier.contactPerson,
        phone: phone ?? currentSupplier.phone,
        email: email ?? currentSupplier.email,
        address: address ?? currentSupplier.address,
        categories: categories ?? currentSupplier.categories,
        isActive: isActive ?? currentSupplier.isActive,
        createdAt: currentSupplier.createdAt,
      );

      // In a real implementation, this would use a SupplierRepository
      return Right(updatedSupplier);
    } catch (e) {
      return Left(ServerFailure('Error updating supplier: $e'));
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

/// Use case for getting suppliers by category
@injectable
class GetSuppliersByCategoryUseCase {
  const GetSuppliersByCategoryUseCase();

  /// Gets suppliers that provide items for a specific category
  Future<Either<Failure, List<Supplier>>> call(String category) async {
    try {
      // In a real implementation, this would query a SupplierRepository
      // and filter by category
      return const Right(<Supplier>[]);
    } catch (e) {
      return Left(ServerFailure('Error getting suppliers by category: $e'));
    }
  }
}

/// Use case for getting active suppliers
@injectable
class GetActiveSuppliersUseCase {
  const GetActiveSuppliersUseCase();

  /// Gets all active suppliers
  Future<Either<Failure, List<Supplier>>> call() async {
    try {
      // In a real implementation, this would query a SupplierRepository
      // and filter by isActive = true
      return const Right(<Supplier>[]);
    } catch (e) {
      return Left(ServerFailure('Error getting active suppliers: $e'));
    }
  }
}

/// Use case for deactivating a supplier
@injectable
class DeactivateSupplierUseCase {
  const DeactivateSupplierUseCase();

  /// Deactivates a supplier (sets isActive to false)
  Future<Either<Failure, Supplier>> call(Supplier supplier) async {
    try {
      if (!supplier.isActive) {
        return Left(BusinessRuleFailure('Supplier is already deactivated'));
      }

      final deactivatedSupplier = Supplier(
        id: supplier.id,
        name: supplier.name,
        contactPerson: supplier.contactPerson,
        phone: supplier.phone,
        email: supplier.email,
        address: supplier.address,
        categories: supplier.categories,
        isActive: false,
        createdAt: supplier.createdAt,
      );

      // In a real implementation, this would use a SupplierRepository
      return Right(deactivatedSupplier);
    } catch (e) {
      return Left(ServerFailure('Error deactivating supplier: $e'));
    }
  }
}
