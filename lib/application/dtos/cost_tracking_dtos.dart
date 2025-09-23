import 'package:equatable/equatable.dart';
import '../../domain/entities/cost_tracking.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';
import '../../domain/value_objects/money.dart';

/// DTO for creating a cost entry
class CreateCostDto extends Equatable {
  final String description;
  final CostType type;
  final CostCategory category;
  final Money amount;
  final Time incurredDate;
  final UserId? relatedItemId;
  final UserId? costCenterId;
  final CostAllocation allocationMethod;
  final double quantity;
  final String unit;
  final Money? unitCost;
  final UserId recordedBy;
  final bool isRecurring;
  final Duration? recurringInterval;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const CreateCostDto({
    required this.description,
    required this.type,
    required this.category,
    required this.amount,
    required this.incurredDate,
    this.relatedItemId,
    this.costCenterId,
    required this.allocationMethod,
    required this.quantity,
    required this.unit,
    this.unitCost,
    required this.recordedBy,
    this.isRecurring = false,
    this.recurringInterval,
    this.notes,
    this.metadata,
  });

  /// Converts DTO to entity
  Cost toEntity() {
    return Cost(
      id: UserId.generate(),
      description: description,
      type: type,
      category: category,
      amount: amount,
      incurredDate: incurredDate,
      relatedItemId: relatedItemId,
      costCenterId: costCenterId,
      allocationMethod: allocationMethod,
      quantity: quantity,
      unit: unit,
      unitCost: unitCost,
      recordedBy: recordedBy,
      recordedAt: Time.now(),
      isRecurring: isRecurring,
      recurringInterval: recurringInterval,
      notes: notes,
      metadata: metadata,
    );
  }

  @override
  List<Object?> get props => [
    description,
    type,
    category,
    amount,
    incurredDate,
    relatedItemId,
    costCenterId,
    allocationMethod,
    quantity,
    unit,
    unitCost,
    recordedBy,
    isRecurring,
    recurringInterval,
    notes,
    metadata,
  ];
}

/// DTO for updating a cost entry
class UpdateCostDto extends Equatable {
  final UserId id;
  final String? description;
  final CostType? type;
  final CostCategory? category;
  final Money? amount;
  final Time? incurredDate;
  final UserId? relatedItemId;
  final UserId? costCenterId;
  final CostAllocation? allocationMethod;
  final double? quantity;
  final String? unit;
  final Money? unitCost;
  final bool? isRecurring;
  final Duration? recurringInterval;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const UpdateCostDto({
    required this.id,
    this.description,
    this.type,
    this.category,
    this.amount,
    this.incurredDate,
    this.relatedItemId,
    this.costCenterId,
    this.allocationMethod,
    this.quantity,
    this.unit,
    this.unitCost,
    this.isRecurring,
    this.recurringInterval,
    this.notes,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    description,
    type,
    category,
    amount,
    incurredDate,
    relatedItemId,
    costCenterId,
    allocationMethod,
    quantity,
    unit,
    unitCost,
    isRecurring,
    recurringInterval,
    notes,
    metadata,
  ];
}

/// DTO for creating a cost center
class CreateCostCenterDto extends Equatable {
  final String name;
  final String description;
  final UserId? parentCenterId;
  final UserId managerId;
  final List<CostType> allowedCostTypes;
  final Money budgetLimit;
  final Time budgetPeriodStart;
  final Time budgetPeriodEnd;
  final bool isActive;
  final List<String>? tags;

  const CreateCostCenterDto({
    required this.name,
    required this.description,
    this.parentCenterId,
    required this.managerId,
    required this.allowedCostTypes,
    required this.budgetLimit,
    required this.budgetPeriodStart,
    required this.budgetPeriodEnd,
    this.isActive = true,
    this.tags,
  });

  /// Converts DTO to entity
  CostCenter toEntity() {
    return CostCenter(
      id: UserId.generate(),
      name: name,
      description: description,
      parentCenterId: parentCenterId,
      managerId: managerId,
      allowedCostTypes: allowedCostTypes,
      budgetLimit: budgetLimit,
      budgetPeriodStart: budgetPeriodStart,
      budgetPeriodEnd: budgetPeriodEnd,
      isActive: isActive,
      createdAt: Time.now(),
      tags: tags,
    );
  }

  @override
  List<Object?> get props => [
    name,
    description,
    parentCenterId,
    managerId,
    allowedCostTypes,
    budgetLimit,
    budgetPeriodStart,
    budgetPeriodEnd,
    isActive,
    tags,
  ];
}

/// DTO for generating a profitability report
class GenerateProfitabilityReportDto extends Equatable {
  final Time periodStart;
  final Time periodEnd;
  final String reportName;
  final UserId generatedBy;
  final List<UserId>? specificItems;
  final List<CostType>? costTypesToInclude;
  final List<UserId>? costCentersToInclude;
  final Map<String, dynamic>? filters;

  const GenerateProfitabilityReportDto({
    required this.periodStart,
    required this.periodEnd,
    required this.reportName,
    required this.generatedBy,
    this.specificItems,
    this.costTypesToInclude,
    this.costCentersToInclude,
    this.filters,
  });

  /// Converts DTO to entity
  ProfitabilityReport toEntity() {
    return ProfitabilityReport(
      id: UserId.generate(),
      reportName: reportName,
      periodStart: periodStart,
      periodEnd: periodEnd,
      generatedBy: generatedBy,
      generatedAt: Time.now(),
      totalRevenue: Money(0.0),
      totalCosts: Money(0.0),
    );
  }

  @override
  List<Object?> get props => [
    periodStart,
    periodEnd,
    reportName,
    generatedBy,
    specificItems,
    costTypesToInclude,
    costCentersToInclude,
    filters,
  ];
}

/// DTO for creating recipe cost analysis
class CreateRecipeCostDto extends Equatable {
  final UserId recipeId;
  final String recipeName;
  final Map<UserId, Money> ingredientCosts;
  final Money laborCost;
  final Money overheadCost;
  final double yield;
  final double targetProfitMargin;
  final UserId calculatedBy;

  const CreateRecipeCostDto({
    required this.recipeId,
    required this.recipeName,
    required this.ingredientCosts,
    required this.laborCost,
    required this.overheadCost,
    required this.yield,
    required this.targetProfitMargin,
    required this.calculatedBy,
  });

  /// Converts DTO to entity
  RecipeCost toEntity() {
    return RecipeCost(
      id: UserId.generate(),
      recipeId: recipeId,
      recipeName: recipeName,
      ingredientCosts: ingredientCosts,
      laborCost: laborCost,
      overheadCost: overheadCost,
      yield: yield,
      targetProfitMargin: targetProfitMargin,
      calculatedBy: calculatedBy,
      calculatedAt: Time.now(),
    );
  }

  @override
  List<Object?> get props => [
    recipeId,
    recipeName,
    ingredientCosts,
    laborCost,
    overheadCost,
    yield,
    targetProfitMargin,
    calculatedBy,
  ];
}

/// DTO for cost queries and filtering
class CostQueryDto extends Equatable {
  final Time? startDate;
  final Time? endDate;
  final List<CostType>? costTypes;
  final List<CostCategory>? categories;
  final UserId? costCenterId;
  final UserId? relatedItemId;
  final UserId? recordedBy;
  final bool? isRecurring;
  final Money? minAmount;
  final Money? maxAmount;
  final String? searchText;
  final Map<String, dynamic>? filters;

  const CostQueryDto({
    this.startDate,
    this.endDate,
    this.costTypes,
    this.categories,
    this.costCenterId,
    this.relatedItemId,
    this.recordedBy,
    this.isRecurring,
    this.minAmount,
    this.maxAmount,
    this.searchText,
    this.filters,
  });

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    costTypes,
    categories,
    costCenterId,
    relatedItemId,
    recordedBy,
    isRecurring,
    minAmount,
    maxAmount,
    searchText,
    filters,
  ];
}
