// Inventory Mapper for Clean Architecture Infrastructure Layer
// Handles conversion between InventoryItem and Supplier entities and Firestore documents

import 'package:injectable/injectable.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';
import '../../domain/value_objects/money.dart';

@injectable
class InventoryMapper {
  /// Converts an InventoryItem entity to a Firestore-compatible Map
  Map<String, dynamic> toFirestore(InventoryItem item) {
    return {
      'id': item.id.value,
      'name': item.name,
      'description': item.description,
      'sku': item.sku,
      'category': _inventoryCategoryToString(item.category),
      'currentQuantity': item.currentQuantity,
      'reorderLevel': item.reorderLevel,
      'maxStockLevel': item.maxStockLevel,
      'unit': _inventoryUnitToString(item.unit),
      'unitCost': item.unitCost.amount,
      'currency': item.unitCost.currency,
      'storageLocation': _storageLocationToString(item.storageLocation),
      'status': _inventoryStatusToString(item.status),
      'supplierId': item.supplierId?.value,
      'expirationDate': item.expirationDate?.millisecondsSinceEpoch,
      'receivedDate': item.receivedDate?.millisecondsSinceEpoch,
      'lastCountDate': item.lastCountDate?.millisecondsSinceEpoch,
      'batchNumber': item.batchNumber,
      'lotNumber': item.lotNumber,
      'allergens': item.allergens,
      'isPerishable': item.isPerishable,
      'requiresTemperatureControl': item.requiresTemperatureControl,
      'minimumTemperature': item.minimumTemperature,
      'maximumTemperature': item.maximumTemperature,
      'createdAt': item.createdAt.millisecondsSinceEpoch,
      'updatedAt': item.updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Converts Firestore document data to an InventoryItem entity
  InventoryItem fromFirestore(Map<String, dynamic> data, String documentId) {
    return InventoryItem(
      id: UserId(data['id'] ?? documentId),
      name: data['name'] ?? '',
      description: data['description'],
      sku: data['sku'] ?? '',
      category: _stringToInventoryCategory(data['category']),
      currentQuantity: (data['currentQuantity'] ?? 0.0).toDouble(),
      reorderLevel: (data['reorderLevel'] ?? 0.0).toDouble(),
      maxStockLevel: (data['maxStockLevel'] ?? 0.0).toDouble(),
      unit: _stringToInventoryUnit(data['unit']),
      unitCost: Money(
        (data['unitCost'] ?? 0.0).toDouble(),
        currency: data['currency'] ?? 'USD',
      ),
      storageLocation: _stringToStorageLocation(data['storageLocation']),
      status: _stringToInventoryStatus(data['status']),
      supplierId: data['supplierId'] != null
          ? UserId(data['supplierId'])
          : null,
      expirationDate: data['expirationDate'] != null
          ? Time.fromMillisecondsSinceEpoch(data['expirationDate'])
          : null,
      receivedDate: data['receivedDate'] != null
          ? Time.fromMillisecondsSinceEpoch(data['receivedDate'])
          : null,
      lastCountDate: data['lastCountDate'] != null
          ? Time.fromMillisecondsSinceEpoch(data['lastCountDate'])
          : null,
      batchNumber: data['batchNumber'],
      lotNumber: data['lotNumber'],
      allergens: _parseStringList(data['allergens']),
      isPerishable: data['isPerishable'] ?? false,
      requiresTemperatureControl: data['requiresTemperatureControl'] ?? false,
      minimumTemperature: data['minimumTemperature']?.toDouble(),
      maximumTemperature: data['maximumTemperature']?.toDouble(),
      createdAt: Time.fromMillisecondsSinceEpoch(
        data['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: Time.fromMillisecondsSinceEpoch(
        data['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Converts a Supplier entity to a Firestore-compatible Map
  Map<String, dynamic> supplierToFirestore(Supplier supplier) {
    return {
      'id': supplier.id.value,
      'name': supplier.name,
      'contactPerson': supplier.contactPerson,
      'phone': supplier.phone,
      'email': supplier.email,
      'address': supplier.address,
      'categories': supplier.categories,
      'isActive': supplier.isActive,
      'createdAt': supplier.createdAt.millisecondsSinceEpoch,
    };
  }

  /// Converts Firestore document data to a Supplier entity
  Supplier supplierFromFirestore(Map<String, dynamic> data, String documentId) {
    return Supplier(
      id: UserId(data['id'] ?? documentId),
      name: data['name'] ?? '',
      contactPerson: data['contactPerson'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      address: data['address'],
      categories: _parseStringList(data['categories']),
      isActive: data['isActive'] ?? true,
      createdAt: Time.fromMillisecondsSinceEpoch(
        data['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Converts InventoryCategory enum to string for Firestore storage
  String _inventoryCategoryToString(InventoryCategory category) {
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

  /// Converts string from Firestore to InventoryCategory enum
  InventoryCategory _stringToInventoryCategory(dynamic value) {
    if (value == null || value is! String) return InventoryCategory.dryGoods;

    switch (value.toLowerCase()) {
      case 'produce':
        return InventoryCategory.produce;
      case 'protein':
        return InventoryCategory.protein;
      case 'dairy':
        return InventoryCategory.dairy;
      case 'dry_goods':
        return InventoryCategory.dryGoods;
      case 'frozen':
        return InventoryCategory.frozen;
      case 'beverages':
        return InventoryCategory.beverages;
      case 'seasonings':
        return InventoryCategory.seasonings;
      case 'cleaning':
        return InventoryCategory.cleaning;
      case 'disposables':
        return InventoryCategory.disposables;
      case 'equipment':
        return InventoryCategory.equipment;
      default:
        return InventoryCategory.dryGoods; // Default fallback
    }
  }

  /// Converts InventoryUnit enum to string for Firestore storage
  String _inventoryUnitToString(InventoryUnit unit) {
    switch (unit) {
      case InventoryUnit.pieces:
        return 'pieces';
      case InventoryUnit.pounds:
        return 'pounds';
      case InventoryUnit.kilograms:
        return 'kilograms';
      case InventoryUnit.liters:
        return 'liters';
      case InventoryUnit.gallons:
        return 'gallons';
      case InventoryUnit.cases:
        return 'cases';
      case InventoryUnit.boxes:
        return 'boxes';
      case InventoryUnit.bags:
        return 'bags';
      case InventoryUnit.cans:
        return 'cans';
      case InventoryUnit.bottles:
        return 'bottles';
    }
  }

  /// Converts string from Firestore to InventoryUnit enum
  InventoryUnit _stringToInventoryUnit(dynamic value) {
    if (value == null || value is! String) return InventoryUnit.pieces;

    switch (value.toLowerCase()) {
      case 'pieces':
        return InventoryUnit.pieces;
      case 'pounds':
        return InventoryUnit.pounds;
      case 'kilograms':
        return InventoryUnit.kilograms;
      case 'liters':
        return InventoryUnit.liters;
      case 'gallons':
        return InventoryUnit.gallons;
      case 'cases':
        return InventoryUnit.cases;
      case 'boxes':
        return InventoryUnit.boxes;
      case 'bags':
        return InventoryUnit.bags;
      case 'cans':
        return InventoryUnit.cans;
      case 'bottles':
        return InventoryUnit.bottles;
      default:
        return InventoryUnit.pieces; // Default fallback
    }
  }

  /// Converts StorageLocation enum to string for Firestore storage
  String _storageLocationToString(StorageLocation location) {
    switch (location) {
      case StorageLocation.walkInCooler:
        return 'walk_in_cooler';
      case StorageLocation.walkInFreezer:
        return 'walk_in_freezer';
      case StorageLocation.dryStorage:
        return 'dry_storage';
      case StorageLocation.prepRefrigerator:
        return 'prep_refrigerator';
      case StorageLocation.bar:
        return 'bar';
      case StorageLocation.chemicalStorage:
        return 'chemical_storage';
      case StorageLocation.equipmentStorage:
        return 'equipment_storage';
      case StorageLocation.receiving:
        return 'receiving';
    }
  }

  /// Converts string from Firestore to StorageLocation enum
  StorageLocation _stringToStorageLocation(dynamic value) {
    if (value == null || value is! String) return StorageLocation.dryStorage;

    switch (value.toLowerCase()) {
      case 'walk_in_cooler':
        return StorageLocation.walkInCooler;
      case 'walk_in_freezer':
        return StorageLocation.walkInFreezer;
      case 'dry_storage':
        return StorageLocation.dryStorage;
      case 'prep_refrigerator':
        return StorageLocation.prepRefrigerator;
      case 'bar':
        return StorageLocation.bar;
      case 'chemical_storage':
        return StorageLocation.chemicalStorage;
      case 'equipment_storage':
        return StorageLocation.equipmentStorage;
      case 'receiving':
        return StorageLocation.receiving;
      default:
        return StorageLocation.dryStorage; // Default fallback
    }
  }

  /// Converts InventoryStatus enum to string for Firestore storage
  String _inventoryStatusToString(InventoryStatus status) {
    switch (status) {
      case InventoryStatus.inStock:
        return 'in_stock';
      case InventoryStatus.lowStock:
        return 'low_stock';
      case InventoryStatus.outOfStock:
        return 'out_of_stock';
      case InventoryStatus.onOrder:
        return 'on_order';
      case InventoryStatus.expired:
        return 'expired';
      case InventoryStatus.reserved:
        return 'reserved';
      case InventoryStatus.audit:
        return 'audit';
    }
  }

  /// Converts string from Firestore to InventoryStatus enum
  InventoryStatus _stringToInventoryStatus(dynamic value) {
    if (value == null || value is! String) return InventoryStatus.inStock;

    switch (value.toLowerCase()) {
      case 'in_stock':
        return InventoryStatus.inStock;
      case 'low_stock':
        return InventoryStatus.lowStock;
      case 'out_of_stock':
        return InventoryStatus.outOfStock;
      case 'on_order':
        return InventoryStatus.onOrder;
      case 'expired':
        return InventoryStatus.expired;
      case 'reserved':
        return InventoryStatus.reserved;
      case 'audit':
        return InventoryStatus.audit;
      default:
        return InventoryStatus.inStock; // Default fallback
    }
  }

  /// Helper method to parse string lists from Firestore data
  List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => item is String ? item : item.toString())
          .toList();
    }
    return [];
  }
}
