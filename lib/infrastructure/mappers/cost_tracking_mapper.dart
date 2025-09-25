// Cost Tracking Mapper for Clean Architecture Infrastructure Layer
// Handles conversion between Cost Tracking entities and Firestore documents

import 'package:injectable/injectable.dart';
import '../../domain/entities/cost_tracking.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';
import '../../domain/value_objects/money.dart';

@LazySingleton()
class CostTrackingMapper {
  /// Converts Cost entity to Firestore document map
  Map<String, dynamic> costToFirestore(Cost cost) {
    return {
      'id': cost.id.value,
      'description': cost.description,
      'type': _costTypeToString(cost.type),
      'category': _costCategoryToString(cost.category),
      'amount': cost.amount.amount,
      'incurredDate': cost.incurredDate.millisecondsSinceEpoch,
      'relatedItemId': cost.relatedItemId?.value,
      'costCenterId': cost.costCenterId?.value,
      'allocationMethod': _costAllocationToString(cost.allocationMethod),
      'quantity': cost.quantity,
      'unit': cost.unit,
      'unitCost': cost.unitCost?.amount,
      'recordedBy': cost.recordedBy.value,
      'recordedAt': cost.recordedAt.millisecondsSinceEpoch,
      'isRecurring': cost.isRecurring,
      'recurringInterval': cost.recurringInterval?.inMinutes,
      'notes': cost.notes,
      'metadata': cost.metadata,
    };
  }

  /// Converts Firestore document to Cost entity
  Cost costFromFirestore(Map<String, dynamic> data, String id) {
    return Cost(
      id: UserId(id),
      description: data['description'] as String,
      type: _costTypeFromString(data['type'] as String),
      category: _costCategoryFromString(data['category'] as String),
      amount: Money(data['amount'] as double),
      incurredDate: Time.fromMillisecondsSinceEpoch(
        data['incurredDate'] as int,
      ),
      relatedItemId: data['relatedItemId'] != null
          ? UserId(data['relatedItemId'] as String)
          : null,
      costCenterId: data['costCenterId'] != null
          ? UserId(data['costCenterId'] as String)
          : null,
      allocationMethod: _costAllocationFromString(
        data['allocationMethod'] as String,
      ),
      quantity: (data['quantity'] as num).toDouble(),
      unit: data['unit'] as String,
      unitCost: data['unitCost'] != null
          ? Money(data['unitCost'] as double)
          : null,
      recordedBy: UserId(data['recordedBy'] as String),
      recordedAt: Time.fromMillisecondsSinceEpoch(data['recordedAt'] as int),
      isRecurring: data['isRecurring'] as bool? ?? false,
      recurringInterval: data['recurringInterval'] != null
          ? Duration(minutes: data['recurringInterval'] as int)
          : null,
      notes: data['notes'] as String?,
      metadata: Map<String, dynamic>.from(data['metadata'] as Map? ?? {}),
    );
  }

  /// Converts CostCenter entity to Firestore document map
  Map<String, dynamic> costCenterToFirestore(CostCenter costCenter) {
    return {
      'id': costCenter.id.value,
      'name': costCenter.name,
      'description': costCenter.description,
      'parentCenterId': costCenter.parentCenterId?.value,
      'managerId': costCenter.managerId.value,
      'allowedCostTypes': costCenter.allowedCostTypes
          .map((type) => _costTypeToString(type))
          .toList(),
      'budgetLimit': costCenter.budgetLimit.amount,
      'budgetPeriodStart': costCenter.budgetPeriodStart.millisecondsSinceEpoch,
      'budgetPeriodEnd': costCenter.budgetPeriodEnd.millisecondsSinceEpoch,
      'isActive': costCenter.isActive,
      'createdAt': costCenter.createdAt.millisecondsSinceEpoch,
      'tags': costCenter.tags,
    };
  }

  /// Converts Firestore document to CostCenter entity
  CostCenter costCenterFromFirestore(Map<String, dynamic> data, String id) {
    return CostCenter(
      id: UserId(id),
      name: data['name'] as String,
      description: data['description'] as String,
      parentCenterId: data['parentCenterId'] != null
          ? UserId(data['parentCenterId'] as String)
          : null,
      managerId: UserId(data['managerId'] as String),
      allowedCostTypes: (data['allowedCostTypes'] as List? ?? [])
          .map((typeStr) => _costTypeFromString(typeStr as String))
          .toList(),
      budgetLimit: Money((data['budgetLimit'] as num).toDouble()),
      budgetPeriodStart: Time.fromMillisecondsSinceEpoch(
        data['budgetPeriodStart'] as int,
      ),
      budgetPeriodEnd: Time.fromMillisecondsSinceEpoch(
        data['budgetPeriodEnd'] as int,
      ),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: Time.fromMillisecondsSinceEpoch(data['createdAt'] as int),
      tags: List<String>.from(data['tags'] as List? ?? []),
    );
  }

  /// Converts ProfitabilityReport entity to Firestore document map
  Map<String, dynamic> profitabilityReportToFirestore(
    ProfitabilityReport report,
  ) {
    return {
      'id': report.id.value,
      'reportName': report.reportName,
      'periodStart': report.periodStart.millisecondsSinceEpoch,
      'periodEnd': report.periodEnd.millisecondsSinceEpoch,
      'totalRevenue': report.totalRevenue.amount,
      'totalCosts': report.totalCosts.amount,
      'grossProfit': report.grossProfit.amount,
      'netProfit': report.netProfit.amount,
      'grossProfitMargin': report.grossProfitMargin,
      'netProfitMargin': report.netProfitMargin,
      'costBreakdown': report.costBreakdown.map(
        (type, amount) => MapEntry(_costTypeToString(type), amount.amount),
      ),
      'revenueByCategory': report.revenueByCategory.map(
        (category, amount) => MapEntry(category, amount.amount),
      ),
      'profitByItem': report.profitByItem.map(
        (itemId, amount) => MapEntry(itemId.value, amount.amount),
      ),
      'topProfitableItems': report.topProfitableItems
          .map((itemId) => itemId.value)
          .toList(),
      'leastProfitableItems': report.leastProfitableItems
          .map((itemId) => itemId.value)
          .toList(),
      'generatedBy': report.generatedBy.value,
      'generatedAt': report.generatedAt.millisecondsSinceEpoch,
      'insights': report.insights,
      'recommendations': report.recommendations,
    };
  }

  /// Converts Firestore document to ProfitabilityReport entity
  ProfitabilityReport profitabilityReportFromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    final costBreakdownData =
        data['costBreakdown'] as Map<String, dynamic>? ?? {};
    final costBreakdown = <CostType, Money>{};
    costBreakdownData.forEach((typeStr, amount) {
      costBreakdown[_costTypeFromString(typeStr)] = Money(
        (amount as num).toDouble(),
      );
    });

    final revenueByCategory = <String, Money>{};
    final revenueData =
        data['revenueByCategory'] as Map<String, dynamic>? ?? {};
    revenueData.forEach((category, amount) {
      revenueByCategory[category] = Money((amount as num).toDouble());
    });

    final profitByItem = <UserId, Money>{};
    final profitData = data['profitByItem'] as Map<String, dynamic>? ?? {};
    profitData.forEach((itemIdStr, amount) {
      profitByItem[UserId(itemIdStr)] = Money((amount as num).toDouble());
    });

    return ProfitabilityReport(
      id: UserId(id),
      reportName: data['reportName'] as String,
      periodStart: Time.fromMillisecondsSinceEpoch(data['periodStart'] as int),
      periodEnd: Time.fromMillisecondsSinceEpoch(data['periodEnd'] as int),
      totalRevenue: Money((data['totalRevenue'] as num).toDouble()),
      totalCosts: Money((data['totalCosts'] as num).toDouble()),
      costBreakdown: costBreakdown,
      revenueByCategory: revenueByCategory,
      profitByItem: profitByItem,
      topProfitableItems: (data['topProfitableItems'] as List? ?? [])
          .map((itemIdStr) => UserId(itemIdStr as String))
          .toList(),
      leastProfitableItems: (data['leastProfitableItems'] as List? ?? [])
          .map((itemIdStr) => UserId(itemIdStr as String))
          .toList(),
      generatedBy: UserId(data['generatedBy'] as String),
      generatedAt: Time.fromMillisecondsSinceEpoch(data['generatedAt'] as int),
      insights: List<String>.from(data['insights'] as List? ?? []),
      recommendations: List<String>.from(
        data['recommendations'] as List? ?? [],
      ),
    );
  }

  /// Converts RecipeCost entity to Firestore document map
  Map<String, dynamic> recipeCostToFirestore(RecipeCost recipeCost) {
    return {
      'id': recipeCost.id.value,
      'recipeId': recipeCost.recipeId.value,
      'recipeName': recipeCost.recipeName,
      'ingredientCosts': recipeCost.ingredientCosts.map(
        (ingredientId, cost) => MapEntry(ingredientId.value, cost.amount),
      ),
      'totalIngredientCost': recipeCost.totalIngredientCost.amount,
      'laborCost': recipeCost.laborCost.amount,
      'overheadCost': recipeCost.overheadCost.amount,
      'totalCost': recipeCost.totalCost.amount,
      'yield': recipeCost.yield,
      'costPerServing': recipeCost.costPerServing.amount,
      'suggestedPrice': recipeCost.suggestedPrice.amount,
      'targetProfitMargin': recipeCost.targetProfitMargin,
      'calculatedAt': recipeCost.calculatedAt.millisecondsSinceEpoch,
      'calculatedBy': recipeCost.calculatedBy.value,
      'isCurrentPricing': recipeCost.isCurrentPricing,
    };
  }

  /// Converts Firestore document to RecipeCost entity
  RecipeCost recipeCostFromFirestore(Map<String, dynamic> data, String id) {
    final ingredientCosts = <UserId, Money>{};
    final ingredientData =
        data['ingredientCosts'] as Map<String, dynamic>? ?? {};
    ingredientData.forEach((ingredientIdStr, cost) {
      ingredientCosts[UserId(ingredientIdStr)] = Money(
        (cost as num).toDouble(),
      );
    });

    return RecipeCost(
      id: UserId(id),
      recipeId: UserId(data['recipeId'] as String),
      recipeName: data['recipeName'] as String,
      ingredientCosts: ingredientCosts,
      laborCost: Money((data['laborCost'] as num).toDouble()),
      overheadCost: Money((data['overheadCost'] as num).toDouble()),
      yield: (data['yield'] as num).toDouble(),
      targetProfitMargin: (data['targetProfitMargin'] as num).toDouble(),
      calculatedAt: Time.fromMillisecondsSinceEpoch(
        data['calculatedAt'] as int,
      ),
      calculatedBy: UserId(data['calculatedBy'] as String),
      isCurrentPricing: data['isCurrentPricing'] as bool? ?? true,
    );
  }

  // Public methods for repository use
  String costTypeToString(CostType type) => _costTypeToString(type);
  String costCategoryToString(CostCategory category) =>
      _costCategoryToString(category);
  String costAllocationToString(CostAllocation allocation) =>
      _costAllocationToString(allocation);

  // Enum conversion methods
  String _costTypeToString(CostType type) {
    switch (type) {
      case CostType.ingredient:
        return 'ingredient';
      case CostType.labor:
        return 'labor';
      case CostType.equipment:
        return 'equipment';
      case CostType.utilities:
        return 'utilities';
      case CostType.overhead:
        return 'overhead';
      case CostType.packaging:
        return 'packaging';
      case CostType.waste:
        return 'waste';
      case CostType.marketing:
        return 'marketing';
      case CostType.transportation:
        return 'transportation';
      case CostType.services:
        return 'services';
    }
  }

  CostType _costTypeFromString(String type) {
    switch (type) {
      case 'ingredient':
        return CostType.ingredient;
      case 'labor':
        return CostType.labor;
      case 'equipment':
        return CostType.equipment;
      case 'utilities':
        return CostType.utilities;
      case 'overhead':
        return CostType.overhead;
      case 'packaging':
        return CostType.packaging;
      case 'waste':
        return CostType.waste;
      case 'marketing':
        return CostType.marketing;
      case 'transportation':
        return CostType.transportation;
      case 'services':
        return CostType.services;
      default:
        throw ArgumentError('Invalid cost type: $type');
    }
  }

  String _costCategoryToString(CostCategory category) {
    switch (category) {
      case CostCategory.variable:
        return 'variable';
      case CostCategory.fixed:
        return 'fixed';
      case CostCategory.semiVariable:
        return 'semi_variable';
      case CostCategory.oneTime:
        return 'one_time';
      case CostCategory.recurring:
        return 'recurring';
      case CostCategory.directLabor:
        return 'direct_labor';
      case CostCategory.indirectLabor:
        return 'indirect_labor';
      case CostCategory.foodIngredients:
        return 'food_ingredients';
      case CostCategory.packaging:
        return 'packaging';
      case CostCategory.beverages:
        return 'beverages';
      case CostCategory.utilities:
        return 'utilities';
    }
  }

  CostCategory _costCategoryFromString(String category) {
    switch (category) {
      case 'variable':
        return CostCategory.variable;
      case 'fixed':
        return CostCategory.fixed;
      case 'semi_variable':
        return CostCategory.semiVariable;
      case 'one_time':
        return CostCategory.oneTime;
      case 'recurring':
        return CostCategory.recurring;
      case 'direct_labor':
        return CostCategory.directLabor;
      case 'indirect_labor':
        return CostCategory.indirectLabor;
      case 'food_ingredients':
        return CostCategory.foodIngredients;
      case 'packaging':
        return CostCategory.packaging;
      case 'beverages':
        return CostCategory.beverages;
      case 'utilities':
        return CostCategory.utilities;
      default:
        throw ArgumentError('Invalid cost category: $category');
    }
  }

  String _costAllocationToString(CostAllocation allocation) {
    switch (allocation) {
      case CostAllocation.direct:
        return 'direct';
      case CostAllocation.volumeBased:
        return 'volume_based';
      case CostAllocation.timeBased:
        return 'time_based';
      case CostAllocation.revenueBased:
        return 'revenue_based';
      case CostAllocation.equalDistribution:
        return 'equal_distribution';
      case CostAllocation.activityBased:
        return 'activity_based';
    }
  }

  CostAllocation _costAllocationFromString(String allocation) {
    switch (allocation) {
      case 'direct':
        return CostAllocation.direct;
      case 'volume_based':
        return CostAllocation.volumeBased;
      case 'time_based':
        return CostAllocation.timeBased;
      case 'revenue_based':
        return CostAllocation.revenueBased;
      case 'equal_distribution':
        return CostAllocation.equalDistribution;
      case 'activity_based':
        return CostAllocation.activityBased;
      default:
        throw ArgumentError('Invalid cost allocation: $allocation');
    }
  }
}
