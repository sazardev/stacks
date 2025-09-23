// Inventory Management DTOs for Clean Architecture Application Layer

import 'package:equatable/equatable.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/value_objects/time.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/money.dart';

/// DTO for creating an inventory item
class CreateInventoryItemDto extends Equatable {
  final String name;
  final String description;
  final String sku;
  final String category;
  final String unit;
  final double currentQuantity;
  final double reorderLevel;
  final double maxStockLevel;
  final double unitCost;
  final String storageLocation;
  final String? supplierId;
  final Time? expirationDate;

  const CreateInventoryItemDto({
    required this.name,
    required this.description,
    required this.sku,
    required this.category,
    required this.unit,
    required this.currentQuantity,
    required this.reorderLevel,
    required this.maxStockLevel,
    required this.unitCost,
    required this.storageLocation,
    this.supplierId,
    this.expirationDate,
  });

  /// Convert DTO to InventoryItem entity
  InventoryItem toEntity() {
    return InventoryItem(
      id: UserId.generate(),
      name: name,
      description: description,
      sku: sku,
      category: InventoryCategory.values.firstWhere(
        (cat) => cat.name.toLowerCase() == category.toLowerCase(),
        orElse: () => InventoryCategory.seasonings,
      ),
      unit: InventoryUnit.values.firstWhere(
        (u) => u.name.toLowerCase() == unit.toLowerCase(),
        orElse: () => InventoryUnit.pieces,
      ),
      currentQuantity: currentQuantity,
      reorderLevel: reorderLevel,
      maxStockLevel: maxStockLevel,
      unitCost: Money(unitCost),
      storageLocation: StorageLocation.values.firstWhere(
        (loc) => loc.name.toLowerCase() == storageLocation.toLowerCase(),
        orElse: () => StorageLocation.dryStorage,
      ),
      supplierId: supplierId != null ? UserId(supplierId!) : null,
      expirationDate: expirationDate,
      createdAt: Time.now(),
    );
  }

  @override
  List<Object?> get props => [
    name,
    description,
    sku,
    category,
    unit,
    currentQuantity,
    reorderLevel,
    maxStockLevel,
    unitCost,
    storageLocation,
    supplierId,
    expirationDate,
  ];
}

/// DTO for updating an inventory item
class UpdateInventoryItemDto extends Equatable {
  final String id;
  final String? name;
  final String? description;
  final String? sku;
  final String? category;
  final String? unit;
  final double? currentQuantity;
  final double? reorderLevel;
  final double? maxStockLevel;
  final double? unitCost;
  final String? storageLocation;
  final String? supplierId;
  final Time? expirationDate;

  const UpdateInventoryItemDto({
    required this.id,
    this.name,
    this.description,
    this.sku,
    this.category,
    this.unit,
    this.currentQuantity,
    this.reorderLevel,
    this.maxStockLevel,
    this.unitCost,
    this.storageLocation,
    this.supplierId,
    this.expirationDate,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    sku,
    category,
    unit,
    currentQuantity,
    reorderLevel,
    maxStockLevel,
    unitCost,
    storageLocation,
    supplierId,
    expirationDate,
  ];
}

/// DTO for inventory queries
class InventoryQueryDto extends Equatable {
  final String? category;
  final bool? lowStock;
  final bool? expiringSoon;
  final Time? startDate;
  final Time? endDate;
  final String? supplierId;

  const InventoryQueryDto({
    this.category,
    this.lowStock,
    this.expiringSoon,
    this.startDate,
    this.endDate,
    this.supplierId,
  });

  @override
  List<Object?> get props => [
    category,
    lowStock,
    expiringSoon,
    startDate,
    endDate,
    supplierId,
  ];
}
