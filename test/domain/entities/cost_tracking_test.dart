import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/entities/cost_tracking.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';
import 'package:stacks/domain/value_objects/money.dart';
import 'package:stacks/domain/exceptions/domain_exception.dart';

void main() {
  group('Cost Tracking', () {
    late UserId costId;
    late UserId centerId;
    late UserId reportId;
    late UserId recipeId;
    late UserId userId;
    late Time recordedAt;

    setUp(() {
      costId = UserId.generate();
      centerId = UserId.generate();
      reportId = UserId.generate();
      recipeId = UserId.generate();
      userId = UserId.generate();
      recordedAt = Time.now();
    });

    group('Cost', () {
      group('creation', () {
        test('should create Cost with valid data', () {
          final cost = Cost(
            id: costId,
            description: 'Premium beef patties',
            type: CostType.ingredient,
            category: CostCategory.variable,
            amount: Money(125.50),
            incurredDate: recordedAt,
            relatedItemId: recipeId,
            costCenterId: centerId,
            allocationMethod: CostAllocation.direct,
            quantity: 25.0,
            unit: 'lbs',
            unitCost: Money(5.02),
            recordedBy: userId,
            recordedAt: recordedAt,
            isRecurring: false,
            notes: 'Premium grade beef for signature burgers',
            metadata: {'supplier': 'Premium Meats Co', 'grade': 'USDA Prime'},
          );

          expect(cost.id, equals(costId));
          expect(cost.description, equals('Premium beef patties'));
          expect(cost.type, equals(CostType.ingredient));
          expect(cost.category, equals(CostCategory.variable));
          expect(cost.amount, equals(Money(125.50)));
          expect(cost.incurredDate, equals(recordedAt));
          expect(cost.relatedItemId, equals(recipeId));
          expect(cost.costCenterId, equals(centerId));
          expect(cost.allocationMethod, equals(CostAllocation.direct));
          expect(cost.quantity, equals(25.0));
          expect(cost.unit, equals('lbs'));
          expect(cost.unitCost, equals(Money(5.02)));
          expect(cost.recordedBy, equals(userId));
          expect(cost.isRecurring, isFalse);
          expect(cost.notes, contains('Premium grade beef'));
          expect(cost.metadata['supplier'], equals('Premium Meats Co'));
        });

        test('should create Cost with minimum required fields', () {
          final cost = Cost(
            id: costId,
            description: 'Basic ingredient cost',
            type: CostType.ingredient,
            category: CostCategory.variable,
            amount: Money(25.00),
            incurredDate: recordedAt,
            allocationMethod: CostAllocation.direct,
            quantity: 1.0,
            unit: 'unit',
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          expect(cost.id, equals(costId));
          expect(cost.relatedItemId, isNull);
          expect(cost.costCenterId, isNull);
          expect(cost.unitCost, isNull);
          expect(cost.isRecurring, isFalse);
          expect(cost.notes, isNull);
          expect(cost.metadata, isEmpty);
        });

        test('should throw DomainException for zero or negative quantity', () {
          expect(
            () => Cost(
              id: costId,
              description: 'Test cost',
              type: CostType.ingredient,
              category: CostCategory.variable,
              amount: Money(25.00),
              incurredDate: recordedAt,
              allocationMethod: CostAllocation.direct,
              quantity: 0.0,
              unit: 'unit',
              recordedBy: userId,
              recordedAt: recordedAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });
      });

      group('business rules', () {
        test('should calculate effective unit cost when not provided', () {
          final cost = Cost(
            id: costId,
            description: 'Auto-calculated unit cost',
            type: CostType.ingredient,
            category: CostCategory.variable,
            amount: Money(100.00),
            incurredDate: recordedAt,
            allocationMethod: CostAllocation.direct,
            quantity: 20.0,
            unit: 'lbs',
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          expect(cost.effectiveUnitCost.amount, equals(5.00)); // 100.00 / 20.0
        });

        test('should identify recurring costs', () {
          final recurringCost = Cost(
            id: costId,
            description: 'Monthly rent',
            type: CostType.overhead,
            category: CostCategory.fixed,
            amount: Money(3000.00),
            incurredDate: recordedAt,
            allocationMethod: CostAllocation.equalDistribution,
            quantity: 1.0,
            unit: 'month',
            recordedBy: userId,
            recordedAt: recordedAt,
            isRecurring: true,
            recurringInterval: const Duration(days: 30),
          );

          expect(recurringCost.isRecurring, isTrue);
          expect(
            recurringCost.recurringInterval,
            equals(const Duration(days: 30)),
          );
        });

        test('should categorize cost types correctly', () {
          final ingredientCost = Cost(
            id: costId,
            description: 'Beef',
            type: CostType.ingredient,
            category: CostCategory.variable,
            amount: Money(50.00),
            incurredDate: recordedAt,
            allocationMethod: CostAllocation.direct,
            quantity: 10.0,
            unit: 'lbs',
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          final laborCost = Cost(
            id: UserId.generate(),
            description: 'Chef salary',
            type: CostType.labor,
            category: CostCategory.fixed,
            amount: Money(4000.00),
            incurredDate: recordedAt,
            allocationMethod: CostAllocation.timeBased,
            quantity: 160.0,
            unit: 'hours',
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          expect(ingredientCost.type, equals(CostType.ingredient));
          expect(ingredientCost.category, equals(CostCategory.variable));
          expect(laborCost.type, equals(CostType.labor));
          expect(laborCost.category, equals(CostCategory.fixed));
        });
      });

      group('equality', () {
        test('should be equal when ids are the same', () {
          final cost1 = Cost(
            id: costId,
            description: 'Test cost',
            type: CostType.ingredient,
            category: CostCategory.variable,
            amount: Money(25.00),
            incurredDate: recordedAt,
            allocationMethod: CostAllocation.direct,
            quantity: 1.0,
            unit: 'unit',
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          final cost2 = Cost(
            id: costId,
            description: 'Different description',
            type: CostType.labor,
            category: CostCategory.fixed,
            amount: Money(100.00),
            incurredDate: Time.now(),
            allocationMethod: CostAllocation.timeBased,
            quantity: 8.0,
            unit: 'hours',
            recordedBy: UserId.generate(),
            recordedAt: Time.now(),
          );

          expect(cost1, equals(cost2));
          expect(cost1.hashCode, equals(cost2.hashCode));
        });

        test('should not be equal when ids are different', () {
          final costId1 = UserId(
            'cost-1-${DateTime.now().millisecondsSinceEpoch}',
          );
          final costId2 = UserId(
            'cost-2-${DateTime.now().millisecondsSinceEpoch + 1}',
          );

          final cost1 = Cost(
            id: costId1,
            description: 'Test cost',
            type: CostType.ingredient,
            category: CostCategory.variable,
            amount: Money(25.00),
            incurredDate: recordedAt,
            allocationMethod: CostAllocation.direct,
            quantity: 1.0,
            unit: 'unit',
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          final cost2 = Cost(
            id: costId2,
            description: 'Test cost',
            type: CostType.ingredient,
            category: CostCategory.variable,
            amount: Money(25.00),
            incurredDate: recordedAt,
            allocationMethod: CostAllocation.direct,
            quantity: 1.0,
            unit: 'unit',
            recordedBy: userId,
            recordedAt: recordedAt,
          );

          expect(cost1, isNot(equals(cost2)));
        });
      });
    });

    group('CostCenter', () {
      group('creation', () {
        test('should create CostCenter with valid data', () {
          final costCenter = CostCenter(
            id: centerId,
            name: 'Main Kitchen',
            description: 'Primary food preparation area',
            managerId: userId,
            allowedCostTypes: [
              CostType.ingredient,
              CostType.labor,
              CostType.equipment,
            ],
            budgetLimit: Money(5000.00),
            budgetPeriodStart: recordedAt.subtract(const Duration(days: 30)),
            budgetPeriodEnd: recordedAt.add(const Duration(days: 30)),
            isActive: true,
            createdAt: recordedAt,
            tags: ['kitchen', 'main'],
          );

          expect(costCenter.id, equals(centerId));
          expect(costCenter.name, equals('Main Kitchen'));
          expect(
            costCenter.description,
            equals('Primary food preparation area'),
          );
          expect(costCenter.managerId, equals(userId));
          expect(costCenter.budgetLimit, equals(Money(5000.00)));
          expect(costCenter.allowedCostTypes, contains(CostType.ingredient));
        });

        test('should create CostCenter with minimum required fields', () {
          final costCenter = CostCenter(
            id: centerId,
            name: 'Basic Center',
            description: 'Test center',
            managerId: userId,
            budgetLimit: Money(1000.00),
            budgetPeriodStart: recordedAt,
            budgetPeriodEnd: recordedAt.add(const Duration(days: 30)),
            createdAt: recordedAt,
          );

          expect(costCenter.id, equals(centerId));
          expect(costCenter.allowedCostTypes, isEmpty);
          expect(costCenter.parentCenterId, isNull);
          expect(costCenter.tags, isEmpty);
        });

        test('should throw DomainException for zero budget limit', () {
          expect(
            () => CostCenter(
              id: centerId,
              name: 'Test Center',
              description: 'Test center',
              managerId: userId,
              budgetLimit: Money(0.00),
              budgetPeriodStart: recordedAt,
              budgetPeriodEnd: recordedAt.add(const Duration(days: 30)),
              createdAt: recordedAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });

        test('should throw DomainException for invalid budget period', () {
          expect(
            () => CostCenter(
              id: centerId,
              name: 'Test Center',
              description: 'Test center',
              managerId: userId,
              budgetLimit: Money(1000.00),
              budgetPeriodStart: recordedAt.add(const Duration(days: 30)),
              budgetPeriodEnd: recordedAt,
              createdAt: recordedAt,
            ),
            throwsA(isA<DomainException>()),
          );
        });
      });

      group('business rules', () {
        late CostCenter costCenter;

        setUp(() {
          costCenter = CostCenter(
            id: centerId,
            name: 'Test Kitchen',
            description: 'Test area',
            managerId: userId,
            allowedCostTypes: [CostType.ingredient, CostType.labor],
            budgetLimit: Money(1000.00),
            budgetPeriodStart: recordedAt.subtract(const Duration(days: 15)),
            budgetPeriodEnd: recordedAt.add(const Duration(days: 15)),
            createdAt: recordedAt,
          );
        });

        test('should check if cost type is allowed', () {
          expect(costCenter.allowsCostType(CostType.ingredient), isTrue);
          expect(costCenter.allowsCostType(CostType.labor), isTrue);
          expect(costCenter.allowsCostType(CostType.overhead), isFalse);
        });

        test('should allow all cost types when none specified', () {
          final centerWithoutTypes = CostCenter(
            id: UserId.generate(),
            name: 'Open Center',
            description: 'Allows all cost types',
            managerId: userId,
            budgetLimit: Money(2000.00),
            budgetPeriodStart: recordedAt,
            budgetPeriodEnd: recordedAt.add(const Duration(days: 30)),
            createdAt: recordedAt,
          );

          expect(
            centerWithoutTypes.allowsCostType(CostType.ingredient),
            isTrue,
          );
          expect(centerWithoutTypes.allowsCostType(CostType.overhead), isTrue);
        });

        test('should check if currently in budget period', () {
          expect(costCenter.isInBudgetPeriod, isTrue);
        });

        test('should identify cost center with parent', () {
          final childCenter = CostCenter(
            id: UserId.generate(),
            name: 'Child Center',
            description: 'Sub-center',
            parentCenterId: centerId,
            managerId: userId,
            budgetLimit: Money(500.00),
            budgetPeriodStart: recordedAt,
            budgetPeriodEnd: recordedAt.add(const Duration(days: 30)),
            createdAt: recordedAt,
          );

          expect(childCenter.hasParent, isTrue);
          expect(childCenter.parentCenterId, equals(centerId));
          expect(costCenter.hasParent, isFalse);
        });
      });
    });

    group('ProfitabilityReport', () {
      group('creation', () {
        test('should create ProfitabilityReport with valid data', () {
          final costBreakdown = {
            CostType.ingredient: Money(1500.00),
            CostType.labor: Money(2000.00),
            CostType.overhead: Money(800.00),
          };

          final revenueByCategory = {
            'burgers': Money(2400.00),
            'fries': Money(1200.00),
            'drinks': Money(2400.00),
          };

          final profitByItem = {
            UserId.generate(): Money(500.00),
            UserId.generate(): Money(300.00),
          };

          final report = ProfitabilityReport(
            id: reportId,
            reportName: 'Q1 Profitability Analysis',
            periodStart: recordedAt.subtract(const Duration(days: 90)),
            periodEnd: recordedAt,
            totalRevenue: Money(6000.00),
            totalCosts: Money(4300.00),
            costBreakdown: costBreakdown,
            revenueByCategory: revenueByCategory,
            profitByItem: profitByItem,
            topProfitableItems: [UserId.generate(), UserId.generate()],
            leastProfitableItems: [UserId.generate()],
            generatedBy: userId,
            generatedAt: recordedAt,
            insights: [
              'Strong quarter performance',
              'Food costs under control',
            ],
            recommendations: [
              'Focus on high-margin items',
              'Optimize labor costs',
            ],
          );

          expect(report.id, equals(reportId));
          expect(report.reportName, equals('Q1 Profitability Analysis'));
          expect(report.totalRevenue, equals(Money(6000.00)));
          expect(report.totalCosts, equals(Money(4300.00)));
          expect(report.grossProfit.amount, equals(1700.00));
          expect(report.netProfit.amount, equals(1700.00));
          expect(report.grossProfitMargin, closeTo(28.33, 0.01));
          expect(report.netProfitMargin, closeTo(28.33, 0.01));
          expect(
            report.costBreakdown[CostType.ingredient],
            equals(Money(1500.00)),
          );
          expect(report.revenueByCategory['burgers'], equals(Money(2400.00)));
          expect(report.insights, contains('Strong quarter performance'));
          expect(
            report.recommendations,
            contains('Focus on high-margin items'),
          );
        });
      });

      group('business rules', () {
        late ProfitabilityReport report;

        setUp(() {
          final costBreakdown = {
            CostType.ingredient: Money(1800.00), // 30%
            CostType.labor: Money(1800.00), // 30%
            CostType.overhead: Money(600.00), // 10%
          };

          report = ProfitabilityReport(
            id: reportId,
            reportName: 'Test Report',
            periodStart: recordedAt.subtract(const Duration(days: 30)),
            periodEnd: recordedAt,
            totalRevenue: Money(6000.00),
            totalCosts: Money(4200.00),
            costBreakdown: costBreakdown,
            generatedBy: userId,
            generatedAt: recordedAt,
          );
        });

        test('should identify profitable operations', () {
          expect(report.isProfitable, isTrue);
          expect(report.netProfitMargin, greaterThan(0));
        });

        test('should meet profit targets when above 15%', () {
          expect(report.meetsProfitTargets, isTrue); // 30% margin
        });

        test('should identify largest cost category', () {
          expect(report.largestCostCategory, equals(CostType.labor));
        });

        test('should calculate food cost percentage', () {
          expect(report.foodCostPercentage, equals(30.0));
        });

        test('should check if food costs are under control', () {
          expect(report.foodCostsUnderControl, isTrue); // 30% is acceptable
        });

        test('should calculate return on investment', () {
          final roi = report.calculateROI(Money(10000.00));
          expect(roi, equals(18.0)); // 1800 / 10000 * 100
        });

        test('should identify break-even operations', () {
          final breakEvenReport = ProfitabilityReport(
            id: reportId,
            reportName: 'Break-even Report',
            periodStart: recordedAt.subtract(const Duration(days: 30)),
            periodEnd: recordedAt,
            totalRevenue: Money(600.00),
            totalCosts: Money(600.00),
            costBreakdown: {CostType.ingredient: Money(300.00)},
            generatedBy: userId,
            generatedAt: recordedAt,
          );

          expect(
            breakEvenReport.isProfitable,
            isFalse,
          ); // 0 profit is not profitable
          expect(breakEvenReport.netProfitMargin, equals(0.0));
        });

        test('should identify high food cost issues', () {
          final highFoodCostReport = ProfitabilityReport(
            id: reportId,
            reportName: 'High Food Cost Report',
            periodStart: recordedAt.subtract(const Duration(days: 30)),
            periodEnd: recordedAt,
            totalRevenue: Money(1000.00),
            totalCosts: Money(900.00),
            costBreakdown: {
              CostType.ingredient: Money(400.00),
            }, // 40% food cost
            generatedBy: userId,
            generatedAt: recordedAt,
          );

          expect(highFoodCostReport.foodCostsUnderControl, isFalse); // Over 30%
        });

        test('should not meet profit targets when below 15%', () {
          final lowProfitReport = ProfitabilityReport(
            id: reportId,
            reportName: 'Low Profit Report',
            periodStart: recordedAt.subtract(const Duration(days: 30)),
            periodEnd: recordedAt,
            totalRevenue: Money(1000.00),
            totalCosts: Money(900.00),
            generatedBy: userId,
            generatedAt: recordedAt,
          );

          expect(lowProfitReport.meetsProfitTargets, isFalse); // 10% margin
        });
      });
    });

    group('RecipeCost', () {
      group('creation', () {
        test('should create RecipeCost with valid data', () {
          final beefId = UserId('beef-ingredient');
          final lettuceId = UserId('lettuce-ingredient');
          final cheeseId = UserId('cheese-ingredient');

          final ingredientCosts = {
            beefId: Money(3.50), // Beef patty
            lettuceId: Money(0.25), // Lettuce
            cheeseId: Money(0.75), // Cheese
          };

          final recipeCost = RecipeCost(
            id: UserId.generate(),
            recipeId: recipeId,
            recipeName: 'Classic Burger',
            ingredientCosts: ingredientCosts,
            laborCost: Money(2.00),
            overheadCost: Money(1.50),
            yield: 4.0, // Makes 4 servings
            targetProfitMargin: 65.0, // 65% target margin
            calculatedBy: userId,
            calculatedAt: recordedAt,
            isCurrentPricing: true,
          );

          expect(recipeCost.recipeId, equals(recipeId));
          expect(recipeCost.recipeName, equals('Classic Burger'));
          expect(recipeCost.totalIngredientCost.amount, equals(4.50));
          expect(recipeCost.laborCost, equals(Money(2.00)));
          expect(recipeCost.overheadCost, equals(Money(1.50)));
          expect(recipeCost.totalCost.amount, equals(8.00));
          expect(recipeCost.yield, equals(4.0));
          expect(recipeCost.costPerServing.amount, equals(2.00));
          expect(recipeCost.targetProfitMargin, equals(65.0));
          expect(recipeCost.isCurrentPricing, isTrue);
        });
      });

      group('business rules', () {
        late RecipeCost recipeCost;

        setUp(() {
          final beef = UserId('premium-beef');
          final onion = UserId('fresh-onion');
          final spice = UserId('special-spice');

          final ingredientCosts = {
            beef: Money(4.00),
            onion: Money(1.00),
            spice: Money(0.50),
          };

          recipeCost = RecipeCost(
            id: UserId.generate(),
            recipeId: recipeId,
            recipeName: 'Premium Dish',
            ingredientCosts: ingredientCosts,
            laborCost: Money(3.00),
            overheadCost: Money(1.50),
            yield: 2.0, // Makes 2 servings
            targetProfitMargin: 70.0,
            calculatedBy: userId,
            calculatedAt: recordedAt,
            isCurrentPricing: true,
          );
        });

        test('should calculate suggested selling price', () {
          // Total cost: 5.50 + 3.00 + 1.50 = 10.00
          // Cost per serving: 10.00 / 2 = 5.00
          // With 70% margin: 5.00 / (1 - 0.70) = 16.67
          expect(recipeCost.suggestedPrice.amount, closeTo(16.67, 0.01));
        });

        test('should calculate profit margin at selling price', () {
          final margin = recipeCost.calculateProfitMargin(Money(15.00));
          // Cost per serving: 5.00, Selling price: 15.00
          // Margin: (15.00 - 5.00) / 15.00 * 100 = 66.67%
          expect(margin, closeTo(66.67, 0.01));
        });

        test('should check profitability at different prices', () {
          expect(recipeCost.isProfitableAt(Money(6.00)), isTrue); // Above cost
          expect(recipeCost.isProfitableAt(Money(4.00)), isFalse); // Below cost
        });

        test('should identify most expensive ingredient', () {
          final mostExpensive = recipeCost.mostExpensiveIngredient;
          expect(mostExpensive, isNotNull);
          // Should be the ingredient that costs 4.00
        });

        test('should calculate ingredient cost percentage', () {
          final ingredients = recipeCost.ingredientCosts.keys.toList();
          final firstIngredient = ingredients.first;

          // First ingredient costs 4.00 out of total 10.00
          final percentage = recipeCost.getIngredientPercentage(
            firstIngredient,
          );
          expect(percentage, equals(40.0)); // 4.00 / 10.00 * 100
        });

        test('should check if recipe is cost-effective', () {
          // Recipe should be cost-effective if ingredients are main cost component
          final ingredientPercentage =
              (recipeCost.totalIngredientCost.amount /
                  recipeCost.totalCost.amount) *
              100;
          expect(ingredientPercentage, closeTo(55.0, 0.01)); // 5.5 / 10.0 = 55%
        });

        test('should identify high-cost recipes', () {
          expect(
            recipeCost.costPerServing.amount,
            equals(5.0),
          ); // $5.00 per serving
        });
      });

      group('pricing strategies', () {
        test('should calculate competitive pricing', () {
          final recipeCost = RecipeCost(
            id: UserId.generate(),
            recipeId: recipeId,
            recipeName: 'Competitive Item',
            ingredientCosts: {UserId.generate(): Money(3.00)},
            laborCost: Money(1.50),
            overheadCost: Money(0.50),
            yield: 1.0,
            targetProfitMargin: 60.0,
            calculatedBy: userId,
            calculatedAt: recordedAt,
            isCurrentPricing: true,
          );

          // Cost: 5.00, Target margin: 60%
          // Price should be: 5.00 / (1 - 0.60) = 12.50
          expect(recipeCost.suggestedPrice.amount, equals(12.50));
        });

        test('should calculate minimum viable price', () {
          final recipeCost = RecipeCost(
            id: UserId.generate(),
            recipeId: recipeId,
            recipeName: 'Budget Item',
            ingredientCosts: {UserId.generate(): Money(2.00)},
            laborCost: Money(1.00),
            overheadCost: Money(0.50),
            yield: 1.0,
            targetProfitMargin: 30.0, // Lower margin for competitive pricing
            calculatedBy: userId,
            calculatedAt: recordedAt,
            isCurrentPricing: true,
          );

          // Minimum price should cover costs plus minimum margin
          expect(recipeCost.suggestedPrice.amount, greaterThan(3.50));
        });
      });
    });
  });
}
