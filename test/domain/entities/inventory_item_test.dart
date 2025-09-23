import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/entities/inventory_item.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';
import 'package:stacks/domain/value_objects/money.dart';
import 'package:stacks/domain/exceptions/domain_exception.dart';

void main() {
  group('Inventory Management', () {
    late UserId supplierId;
    late UserId inventoryId;
    late Time createdAt;
    late Time updatedAt;
    late Money unitCost;

    setUp(() {
      supplierId = UserId('supplier-001');
      inventoryId = UserId('inventory-001');
      createdAt = Time.now();
      updatedAt = Time.now();
      unitCost = Money(25.50);
    });

    group('Supplier', () {
      group('creation', () {
        test('should create Supplier with valid data', () {
          final supplier = Supplier(
            id: supplierId,
            name: 'Fresh Foods Distributors',
            contactPerson: 'John Smith',
            phone: '+1-555-123-4567',
            email: 'john@freshfoods.com',
            address: '123 Distribution Center Dr, City, ST 12345',
            categories: ['produce', 'dairy', 'protein'],
            isActive: true,
            createdAt: createdAt,
          );

          expect(supplier.id, equals(supplierId));
          expect(supplier.name, equals('Fresh Foods Distributors'));
          expect(supplier.contactPerson, equals('John Smith'));
          expect(supplier.phone, equals('+1-555-123-4567'));
          expect(supplier.email, equals('john@freshfoods.com'));
          expect(
            supplier.address,
            equals('123 Distribution Center Dr, City, ST 12345'),
          );
          expect(supplier.categories, hasLength(3));
          expect(supplier.categories, contains('produce'));
          expect(supplier.isActive, isTrue);
          expect(supplier.createdAt, equals(createdAt));
        });

        test('should create Supplier with minimum required fields', () {
          final supplier = Supplier(
            id: supplierId,
            name: 'Basic Supplier',
            contactPerson: 'Jane Doe',
            phone: '5551234567',
            email: 'jane@supplier.com',
            createdAt: createdAt,
          );

          expect(supplier.id, equals(supplierId));
          expect(supplier.address, isNull);
          expect(supplier.categories, isEmpty);
          expect(supplier.isActive, isTrue); // Default value
        });

        test('should throw DomainException for empty name', () {
          expect(
            () => Supplier(
              id: supplierId,
              name: '',
              contactPerson: 'John Smith',
              phone: '5551234567',
              email: 'john@supplier.com',
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException for excessively long name', () {
          final longName = 'a' * 250; // Exceeds 200 char limit

          expect(
            () => Supplier(
              id: supplierId,
              name: longName,
              contactPerson: 'John Smith',
              phone: '5551234567',
              email: 'john@supplier.com',
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException for empty contact person', () {
          expect(
            () => Supplier(
              id: supplierId,
              name: 'Test Supplier',
              contactPerson: '',
              phone: '5551234567',
              email: 'john@supplier.com',
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test(
          'should throw DomainException for excessively long contact person',
          () {
            final longContact = 'a' * 150; // Exceeds 100 char limit

            expect(
              () => Supplier(
                id: supplierId,
                name: 'Test Supplier',
                contactPerson: longContact,
                phone: '5551234567',
                email: 'john@supplier.com',
                createdAt: createdAt,
              ),
              throwsA(isA<DomainException>()),
            );
          },
        );

        test('should throw DomainException for invalid phone number', () {
          expect(
            () => Supplier(
              id: supplierId,
              name: 'Test Supplier',
              contactPerson: 'John Smith',
              phone: '123', // Too short
              email: 'john@supplier.com',
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException for invalid email', () {
          expect(
            () => Supplier(
              id: supplierId,
              name: 'Test Supplier',
              contactPerson: 'John Smith',
              phone: '5551234567',
              email: 'invalid-email',
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should normalize email to lowercase', () {
          final supplier = Supplier(
            id: supplierId,
            name: 'Test Supplier',
            contactPerson: 'John Smith',
            phone: '5551234567',
            email: 'JOHN@SUPPLIER.COM',
            createdAt: createdAt,
          );

          expect(supplier.email, equals('john@supplier.com'));
        });
      });

      group('equality', () {
        test('should be equal when ids are the same', () {
          final supplier1 = Supplier(
            id: supplierId,
            name: 'Supplier 1',
            contactPerson: 'Contact 1',
            phone: '5551111111',
            email: 'supplier1@test.com',
            createdAt: createdAt,
          );

          final supplier2 = Supplier(
            id: supplierId,
            name: 'Different Supplier',
            contactPerson: 'Different Contact',
            phone: '5552222222',
            email: 'supplier2@test.com',
            createdAt: Time.now(),
          );

          expect(supplier1, equals(supplier2));
          expect(supplier1.hashCode, equals(supplier2.hashCode));
        });

        test('should not be equal when ids are different', () {
          final supplier1 = Supplier(
            id: supplierId,
            name: 'Same Supplier',
            contactPerson: 'Same Contact',
            phone: '5551234567',
            email: 'same@supplier.com',
            createdAt: createdAt,
          );

          final supplier2 = Supplier(
            id: UserId('different-supplier'),
            name: 'Same Supplier',
            contactPerson: 'Same Contact',
            phone: '5551234567',
            email: 'same@supplier.com',
            createdAt: createdAt,
          );

          expect(supplier1, isNot(equals(supplier2)));
        });
      });

      group('string representation', () {
        test('should have meaningful toString', () {
          final supplier = Supplier(
            id: supplierId,
            name: 'Test Supplier',
            contactPerson: 'John Smith',
            phone: '5551234567',
            email: 'john@supplier.com',
            isActive: true,
            createdAt: createdAt,
          );

          final stringRep = supplier.toString();
          expect(stringRep, contains('Supplier'));
          expect(stringRep, contains(supplierId.value));
          expect(stringRep, contains('Test Supplier'));
          expect(stringRep, contains('true'));
        });
      });
    });

    group('InventoryItem', () {
      group('creation', () {
        test('should create InventoryItem with valid data', () {
          final item = InventoryItem(
            id: inventoryId,
            name: 'Organic Tomatoes',
            description: 'Fresh organic tomatoes from local farm',
            sku: 'ORG-TOM-001',
            category: InventoryCategory.produce,
            currentQuantity: 50.0,
            reorderLevel: 10.0,
            maxStockLevel: 100.0,
            unit: InventoryUnit.pounds,
            unitCost: unitCost,
            storageLocation: StorageLocation.walkInCooler,
            status: InventoryStatus.inStock,
            supplierId: supplierId,
            expirationDate: Time.now().add(Duration(days: 7)),
            receivedDate: Time.now().subtract(Duration(days: 1)),
            batchNumber: 'BATCH-001',
            lotNumber: 'LOT-A123',
            allergens: ['none'],
            isPerishable: true,
            requiresTemperatureControl: true,
            minimumTemperature: 1.0,
            maximumTemperature: 4.0,
            createdAt: createdAt,
            updatedAt: updatedAt,
          );

          expect(item.id, equals(inventoryId));
          expect(item.name, equals('Organic Tomatoes'));
          expect(
            item.description,
            equals('Fresh organic tomatoes from local farm'),
          );
          expect(item.sku, equals('ORG-TOM-001'));
          expect(item.category, equals(InventoryCategory.produce));
          expect(item.currentQuantity, equals(50.0));
          expect(item.reorderLevel, equals(10.0));
          expect(item.maxStockLevel, equals(100.0));
          expect(item.unit, equals(InventoryUnit.pounds));
          expect(item.unitCost, equals(unitCost));
          expect(item.storageLocation, equals(StorageLocation.walkInCooler));
          expect(item.status, equals(InventoryStatus.inStock));
          expect(item.supplierId, equals(supplierId));
          expect(item.isPerishable, isTrue);
          expect(item.requiresTemperatureControl, isTrue);
          expect(item.minimumTemperature, equals(1.0));
          expect(item.maximumTemperature, equals(4.0));
          expect(item.allergens, contains('none'));
        });

        test('should create InventoryItem with minimum required fields', () {
          final item = InventoryItem(
            id: inventoryId,
            name: 'Basic Item',
            sku: 'BASIC-001',
            category: InventoryCategory.dryGoods,
            currentQuantity: 25.0,
            reorderLevel: 5.0,
            maxStockLevel: 50.0,
            unit: InventoryUnit.pieces,
            unitCost: Money(10.0),
            storageLocation: StorageLocation.dryStorage,
            createdAt: createdAt,
          );

          expect(item.id, equals(inventoryId));
          expect(item.description, isNull);
          expect(item.status, equals(InventoryStatus.inStock)); // Default
          expect(item.supplierId, isNull);
          expect(item.expirationDate, isNull);
          expect(item.isPerishable, isFalse); // Default
          expect(item.requiresTemperatureControl, isFalse); // Default
          expect(item.allergens, isEmpty);
        });

        test('should throw DomainException for empty name', () {
          expect(
            () => InventoryItem(
              id: inventoryId,
              name: '',
              sku: 'TEST-001',
              category: InventoryCategory.produce,
              currentQuantity: 10.0,
              reorderLevel: 5.0,
              maxStockLevel: 20.0,
              unit: InventoryUnit.pieces,
              unitCost: Money(5.0),
              storageLocation: StorageLocation.dryStorage,
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException for excessively long name', () {
          final longName = 'a' * 250; // Exceeds 200 char limit

          expect(
            () => InventoryItem(
              id: inventoryId,
              name: longName,
              sku: 'TEST-001',
              category: InventoryCategory.produce,
              currentQuantity: 10.0,
              reorderLevel: 5.0,
              maxStockLevel: 20.0,
              unit: InventoryUnit.pieces,
              unitCost: Money(5.0),
              storageLocation: StorageLocation.dryStorage,
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test(
          'should throw DomainException for excessively long description',
          () {
            final longDescription = 'a' * 600; // Exceeds 500 char limit

            expect(
              () => InventoryItem(
                id: inventoryId,
                name: 'Test Item',
                description: longDescription,
                sku: 'TEST-001',
                category: InventoryCategory.produce,
                currentQuantity: 10.0,
                reorderLevel: 5.0,
                maxStockLevel: 20.0,
                unit: InventoryUnit.pieces,
                unitCost: Money(5.0),
                storageLocation: StorageLocation.dryStorage,
                createdAt: createdAt,
              ),
              throwsA(isA<DomainException>()),
            );
          },
        );

        test('should throw DomainException for negative quantity', () {
          expect(
            () => InventoryItem(
              id: inventoryId,
              name: 'Test Item',
              sku: 'TEST-001',
              category: InventoryCategory.produce,
              currentQuantity: -5.0,
              reorderLevel: 5.0,
              maxStockLevel: 20.0,
              unit: InventoryUnit.pieces,
              unitCost: Money(5.0),
              storageLocation: StorageLocation.dryStorage,
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException for quantity exceeding maximum', () {
          expect(
            () => InventoryItem(
              id: inventoryId,
              name: 'Test Item',
              sku: 'TEST-001',
              category: InventoryCategory.produce,
              currentQuantity: 1000000.0, // Exceeds max
              reorderLevel: 5.0,
              maxStockLevel: 20.0,
              unit: InventoryUnit.pieces,
              unitCost: Money(5.0),
              storageLocation: StorageLocation.dryStorage,
              createdAt: createdAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should normalize SKU to uppercase', () {
          final item = InventoryItem(
            id: inventoryId,
            name: 'Test Item',
            sku: 'test-001',
            category: InventoryCategory.produce,
            currentQuantity: 10.0,
            reorderLevel: 5.0,
            maxStockLevel: 20.0,
            unit: InventoryUnit.pieces,
            unitCost: Money(5.0),
            storageLocation: StorageLocation.dryStorage,
            createdAt: createdAt,
          );

          expect(item.sku, equals('TEST-001'));
        });
      });

      group('business rules', () {
        late InventoryItem item;

        setUp(() {
          item = InventoryItem(
            id: inventoryId,
            name: 'Test Item',
            sku: 'TEST-001',
            category: InventoryCategory.produce,
            currentQuantity: 15.0,
            reorderLevel: 10.0,
            maxStockLevel: 50.0,
            unit: InventoryUnit.pounds,
            unitCost: Money(5.0),
            storageLocation: StorageLocation.walkInCooler,
            isPerishable: true,
            expirationDate: Time.now().add(Duration(days: 2)),
            requiresTemperatureControl: true,
            minimumTemperature: 1.0,
            maximumTemperature: 4.0,
            createdAt: createdAt,
          );
        });

        test('should identify when reordering is needed', () {
          expect(item.needsReordering, isFalse); // 15.0 > 10.0

          final lowStockItem = InventoryItem(
            id: inventoryId,
            name: 'Low Stock Item',
            sku: 'LOW-001',
            category: InventoryCategory.produce,
            currentQuantity: 8.0, // Below reorder level
            reorderLevel: 10.0,
            maxStockLevel: 50.0,
            unit: InventoryUnit.pounds,
            unitCost: Money(5.0),
            storageLocation: StorageLocation.walkInCooler,
            createdAt: createdAt,
          );

          expect(lowStockItem.needsReordering, isTrue);
        });

        test('should identify low stock', () {
          expect(item.isLowStock, isTrue); // 15.0 <= 15.0 (reorder * 1.5)

          final normalStockItem = InventoryItem(
            id: inventoryId,
            name: 'Normal Stock Item',
            sku: 'NORMAL-001',
            category: InventoryCategory.produce,
            currentQuantity: 20.0, // Above 15.0 (10.0 * 1.5)
            reorderLevel: 10.0,
            maxStockLevel: 50.0,
            unit: InventoryUnit.pounds,
            unitCost: Money(5.0),
            storageLocation: StorageLocation.walkInCooler,
            createdAt: createdAt,
          );

          expect(normalStockItem.isLowStock, isFalse);
        });

        test('should identify out of stock', () {
          expect(item.isOutOfStock, isFalse);

          final outOfStockItem = InventoryItem(
            id: inventoryId,
            name: 'Out of Stock Item',
            sku: 'OUT-001',
            category: InventoryCategory.produce,
            currentQuantity: 0.0,
            reorderLevel: 10.0,
            maxStockLevel: 50.0,
            unit: InventoryUnit.pounds,
            unitCost: Money(5.0),
            storageLocation: StorageLocation.walkInCooler,
            createdAt: createdAt,
          );

          expect(outOfStockItem.isOutOfStock, isTrue);
        });

        test('should identify overstocked items', () {
          expect(item.isOverstocked, isFalse); // 15.0 <= 50.0

          final overstockedItem = InventoryItem(
            id: inventoryId,
            name: 'Overstocked Item',
            sku: 'OVER-001',
            category: InventoryCategory.produce,
            currentQuantity: 75.0, // Above max stock level
            reorderLevel: 10.0,
            maxStockLevel: 50.0,
            unit: InventoryUnit.pounds,
            unitCost: Money(5.0),
            storageLocation: StorageLocation.walkInCooler,
            createdAt: createdAt,
          );

          expect(overstockedItem.isOverstocked, isTrue);
        });

        test('should identify expired items', () {
          expect(item.isExpired, isFalse); // 2 days in future

          final expiredItem = InventoryItem(
            id: inventoryId,
            name: 'Expired Item',
            sku: 'EXP-001',
            category: InventoryCategory.produce,
            currentQuantity: 10.0,
            reorderLevel: 5.0,
            maxStockLevel: 20.0,
            unit: InventoryUnit.pounds,
            unitCost: Money(5.0),
            storageLocation: StorageLocation.walkInCooler,
            isPerishable: true,
            expirationDate: Time.now().subtract(Duration(days: 1)), // Expired
            createdAt: createdAt,
          );

          expect(expiredItem.isExpired, isTrue);
        });

        test('should handle non-perishable items for expiration', () {
          final nonPerishableItem = InventoryItem(
            id: inventoryId,
            name: 'Non-Perishable Item',
            sku: 'NON-001',
            category: InventoryCategory.dryGoods,
            currentQuantity: 10.0,
            reorderLevel: 5.0,
            maxStockLevel: 20.0,
            unit: InventoryUnit.pounds,
            unitCost: Money(5.0),
            storageLocation: StorageLocation.dryStorage,
            isPerishable: false,
            createdAt: createdAt,
          );

          expect(nonPerishableItem.isExpired, isFalse);
          expect(nonPerishableItem.daysUntilExpiration, isNull);
          expect(nonPerishableItem.expiresSoon, isFalse);
        });

        test('should calculate days until expiration', () {
          expect(item.daysUntilExpiration, equals(2));

          final soonToExpireItem = InventoryItem(
            id: inventoryId,
            name: 'Soon to Expire',
            sku: 'SOON-001',
            category: InventoryCategory.produce,
            currentQuantity: 10.0,
            reorderLevel: 5.0,
            maxStockLevel: 20.0,
            unit: InventoryUnit.pounds,
            unitCost: Money(5.0),
            storageLocation: StorageLocation.walkInCooler,
            isPerishable: true,
            expirationDate: Time.now().add(Duration(days: 1)),
            createdAt: createdAt,
          );

          expect(soonToExpireItem.daysUntilExpiration, equals(1));
          expect(soonToExpireItem.expiresSoon, isTrue); // <= 3 days
        });

        test('should calculate total value of stock', () {
          final totalValue = item.totalValue;
          expect(totalValue.amount, equals(75.0)); // 15.0 * 5.0
        });

        test('should calculate suggested order quantity', () {
          expect(item.suggestedOrderQuantity, equals(0.0)); // No reorder needed

          final reorderItem = InventoryItem(
            id: inventoryId,
            name: 'Reorder Item',
            sku: 'REORDER-001',
            category: InventoryCategory.produce,
            currentQuantity: 5.0, // Below reorder level
            reorderLevel: 10.0,
            maxStockLevel: 50.0,
            unit: InventoryUnit.pounds,
            unitCost: Money(5.0),
            storageLocation: StorageLocation.walkInCooler,
            createdAt: createdAt,
          );

          expect(
            reorderItem.suggestedOrderQuantity,
            equals(45.0),
          ); // 50.0 - 5.0
        });

        test('should check quantity availability', () {
          expect(item.isQuantityAvailable(10.0), isTrue);
          expect(
            item.isQuantityAvailable(20.0),
            isFalse,
          ); // More than available

          final expiredItem = InventoryItem(
            id: inventoryId,
            name: 'Expired Item',
            sku: 'EXP-001',
            category: InventoryCategory.produce,
            currentQuantity: 15.0,
            reorderLevel: 10.0,
            maxStockLevel: 50.0,
            unit: InventoryUnit.pounds,
            unitCost: Money(5.0),
            storageLocation: StorageLocation.walkInCooler,
            status: InventoryStatus.expired,
            createdAt: createdAt,
          );

          expect(
            expiredItem.isQuantityAvailable(10.0),
            isFalse,
          ); // Status not in stock
        });

        test(
          'should check temperature range for temperature-controlled items',
          () {
            expect(item.isTemperatureInRange(2.5), isTrue); // Within 1.0-4.0
            expect(item.isTemperatureInRange(0.5), isFalse); // Below minimum
            expect(item.isTemperatureInRange(5.0), isFalse); // Above maximum

            final nonTempControlItem = InventoryItem(
              id: inventoryId,
              name: 'Dry Item',
              sku: 'DRY-001',
              category: InventoryCategory.dryGoods,
              currentQuantity: 10.0,
              reorderLevel: 5.0,
              maxStockLevel: 20.0,
              unit: InventoryUnit.pounds,
              unitCost: Money(5.0),
              storageLocation: StorageLocation.dryStorage,
              requiresTemperatureControl: false,
              createdAt: createdAt,
            );

            expect(
              nonTempControlItem.isTemperatureInRange(100.0),
              isTrue,
            ); // Always true for non-temp control
          },
        );

        test('should use quantity and update status correctly', () {
          final beforeUse = Time.now();
          final updatedItem = item.useQuantity(5.0, 'Kitchen prep');

          expect(updatedItem.currentQuantity, equals(10.0)); // 15.0 - 5.0
          expect(
            updatedItem.status,
            equals(InventoryStatus.lowStock),
          ); // 10.0 <= 10.0 reorder level
          expect(
            updatedItem.updatedAt.isAfter(beforeUse) ||
                updatedItem.updatedAt.isAtSameMomentAs(beforeUse),
            isTrue,
          );

          final outOfStockUpdate = updatedItem.useQuantity(10.0, 'Final use');
          expect(outOfStockUpdate.currentQuantity, equals(0.0));
          expect(outOfStockUpdate.status, equals(InventoryStatus.outOfStock));
        });

        test('should throw DomainException when using more than available', () {
          expect(
            () =>
                item.useQuantity(20.0, 'Too much'), // More than 15.0 available
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException when using negative quantity', () {
          expect(
            () => item.useQuantity(-5.0, 'Invalid'),
            throwsA(isA<DomainException>()),
          );
        });

        test('should receive quantity and update accordingly', () {
          final receivedItem = item.receiveQuantity(
            receivedQuantity: 20.0,
            unitCost: Money(4.5),
            expirationDate: Time.now().add(Duration(days: 5)),
            batchNumber: 'BATCH-NEW',
          );

          expect(receivedItem.currentQuantity, equals(35.0)); // 15.0 + 20.0
          expect(receivedItem.unitCost, equals(Money(4.5))); // Updated cost
          expect(receivedItem.receivedDate, isNotNull);
          expect(receivedItem.batchNumber, equals('BATCH-NEW'));
          expect(receivedItem.status, equals(InventoryStatus.inStock));
        });

        test(
          'should throw DomainException when receiving negative quantity',
          () {
            expect(
              () => item.receiveQuantity(
                receivedQuantity: -10.0,
                unitCost: Money(5.0),
              ),
              throwsA(isA<DomainException>()),
            );
          },
        );

        test('should update stock count correctly', () {
          final countedItem = item.updateStockCount(8.0, 'Physical inventory');

          expect(countedItem.currentQuantity, equals(8.0));
          expect(countedItem.lastCountDate, isNotNull);
          expect(
            countedItem.status,
            equals(InventoryStatus.lowStock),
          ); // 8.0 <= 10.0 reorder level

          final zeroCountItem = item.updateStockCount(0.0, 'Zero count');
          expect(zeroCountItem.status, equals(InventoryStatus.outOfStock));

          final highCountItem = item.updateStockCount(25.0, 'High count');
          expect(
            highCountItem.status,
            equals(InventoryStatus.inStock),
          ); // 25.0 > 10.0 reorder level
        });

        test(
          'should throw DomainException when counting negative quantity',
          () {
            expect(
              () => item.updateStockCount(-5.0, 'Invalid count'),
              throwsA(isA<DomainException>()),
            );
          },
        );

        test('should mark item as expired', () {
          final beforeExpire = Time.now();
          final expiredItem = item.markExpired();

          expect(expiredItem.status, equals(InventoryStatus.expired));
          expect(
            expiredItem.updatedAt.isAfter(beforeExpire) ||
                expiredItem.updatedAt.isAtSameMomentAs(beforeExpire),
            isTrue,
          );
        });

        test(
          'should throw DomainException when marking non-perishable as expired',
          () {
            final nonPerishableItem = InventoryItem(
              id: inventoryId,
              name: 'Dry Good',
              sku: 'DRY-001',
              category: InventoryCategory.dryGoods,
              currentQuantity: 10.0,
              reorderLevel: 5.0,
              maxStockLevel: 20.0,
              unit: InventoryUnit.pounds,
              unitCost: Money(5.0),
              storageLocation: StorageLocation.dryStorage,
              isPerishable: false,
              createdAt: createdAt,
            );

            expect(
              () => nonPerishableItem.markExpired(),
              throwsA(isA<DomainException>()),
            );
          },
        );
      });

      group('equality', () {
        test('should be equal when ids are the same', () {
          final item1 = InventoryItem(
            id: inventoryId,
            name: 'Item 1',
            sku: 'ITEM-001',
            category: InventoryCategory.produce,
            currentQuantity: 10.0,
            reorderLevel: 5.0,
            maxStockLevel: 20.0,
            unit: InventoryUnit.pounds,
            unitCost: Money(5.0),
            storageLocation: StorageLocation.walkInCooler,
            createdAt: createdAt,
          );

          final item2 = InventoryItem(
            id: inventoryId,
            name: 'Different Item',
            sku: 'ITEM-002',
            category: InventoryCategory.dairy,
            currentQuantity: 50.0,
            reorderLevel: 15.0,
            maxStockLevel: 100.0,
            unit: InventoryUnit.gallons,
            unitCost: Money(25.0),
            storageLocation: StorageLocation.prepRefrigerator,
            createdAt: Time.now(),
          );

          expect(item1, equals(item2));
          expect(item1.hashCode, equals(item2.hashCode));
        });

        test('should not be equal when ids are different', () {
          final item1 = InventoryItem(
            id: inventoryId,
            name: 'Same Item',
            sku: 'SAME-001',
            category: InventoryCategory.produce,
            currentQuantity: 10.0,
            reorderLevel: 5.0,
            maxStockLevel: 20.0,
            unit: InventoryUnit.pounds,
            unitCost: Money(5.0),
            storageLocation: StorageLocation.walkInCooler,
            createdAt: createdAt,
          );

          final item2 = InventoryItem(
            id: UserId('different-inventory'),
            name: 'Same Item',
            sku: 'SAME-001',
            category: InventoryCategory.produce,
            currentQuantity: 10.0,
            reorderLevel: 5.0,
            maxStockLevel: 20.0,
            unit: InventoryUnit.pounds,
            unitCost: Money(5.0),
            storageLocation: StorageLocation.walkInCooler,
            createdAt: createdAt,
          );

          expect(item1, isNot(equals(item2)));
        });
      });

      group('string representation', () {
        test('should have meaningful toString', () {
          final item = InventoryItem(
            id: inventoryId,
            name: 'Test Item',
            sku: 'TEST-001',
            category: InventoryCategory.produce,
            currentQuantity: 15.0,
            reorderLevel: 10.0,
            maxStockLevel: 50.0,
            unit: InventoryUnit.pounds,
            unitCost: Money(5.0),
            storageLocation: StorageLocation.walkInCooler,
            status: InventoryStatus.inStock,
            createdAt: createdAt,
          );

          final stringRep = item.toString();
          expect(stringRep, contains('InventoryItem'));
          expect(stringRep, contains(inventoryId.value));
          expect(stringRep, contains('Test Item'));
          expect(stringRep, contains('15.0'));
          expect(stringRep, contains('pounds'));
          expect(stringRep, contains('inStock'));
        });
      });
    });
  });
}
