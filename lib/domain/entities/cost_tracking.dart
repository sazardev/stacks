import '../value_objects/user_id.dart';
import '../value_objects/time.dart';
import '../value_objects/money.dart';
import '../exceptions/domain_exception.dart';

/// Cost types for financial tracking
enum CostType {
  /// Direct ingredient costs
  ingredient,

  /// Labor costs for preparation
  labor,

  /// Equipment usage and depreciation
  equipment,

  /// Utilities (gas, electricity, water)
  utilities,

  /// Overhead costs (rent, insurance)
  overhead,

  /// Packaging and presentation materials
  packaging,

  /// Waste and spoilage costs
  waste,

  /// Marketing and promotional costs
  marketing,

  /// Transportation and delivery
  transportation,

  /// Third-party service fees
  services,
}

/// Cost categories for analysis
enum CostCategory {
  /// Variable costs that change with production
  variable,

  /// Fixed costs that remain constant
  fixed,

  /// Semi-variable costs with both fixed and variable components
  semiVariable,

  /// One-time or project-specific costs
  oneTime,

  /// Recurring monthly costs
  recurring,
}

/// Profitability metrics
enum ProfitabilityMetric {
  /// Gross profit margin
  grossProfitMargin,

  /// Net profit margin
  netProfitMargin,

  /// Food cost percentage
  foodCostPercentage,

  /// Labor cost percentage
  laborCostPercentage,

  /// Return on investment
  returnOnInvestment,

  /// Contribution margin
  contributionMargin,

  /// Break-even point
  breakEvenPoint,

  /// Cost per serving
  costPerServing,
}

/// Cost allocation methods
enum CostAllocation {
  /// Direct assignment to specific items
  direct,

  /// Allocated based on usage volume
  volumeBased,

  /// Allocated based on time spent
  timeBased,

  /// Allocated based on revenue percentage
  revenueBased,

  /// Equal distribution across all items
  equalDistribution,

  /// Activity-based costing
  activityBased,
}

/// Individual cost entry
class Cost {
  final UserId _id;
  final String _description;
  final CostType _type;
  final CostCategory _category;
  final Money _amount;
  final Time _incurredDate;
  final UserId? _relatedItemId;
  final UserId? _costCenterId;
  final CostAllocation _allocationMethod;
  final double _quantity;
  final String _unit;
  final Money? _unitCost;
  final UserId _recordedBy;
  final Time _recordedAt;
  final bool _isRecurring;
  final Duration? _recurringInterval;
  final String? _notes;
  final Map<String, dynamic> _metadata;

  /// Creates a Cost
  Cost({
    required UserId id,
    required String description,
    required CostType type,
    required CostCategory category,
    required Money amount,
    required Time incurredDate,
    UserId? relatedItemId,
    UserId? costCenterId,
    required CostAllocation allocationMethod,
    required double quantity,
    required String unit,
    Money? unitCost,
    required UserId recordedBy,
    required Time recordedAt,
    bool isRecurring = false,
    Duration? recurringInterval,
    String? notes,
    Map<String, dynamic>? metadata,
  }) : _id = id,
       _description = description,
       _type = type,
       _category = category,
       _amount = amount,
       _incurredDate = incurredDate,
       _relatedItemId = relatedItemId,
       _costCenterId = costCenterId,
       _allocationMethod = allocationMethod,
       _quantity = quantity,
       _unit = unit,
       _unitCost = unitCost,
       _recordedBy = recordedBy,
       _recordedAt = recordedAt,
       _isRecurring = isRecurring,
       _recurringInterval = recurringInterval,
       _notes = notes,
       _metadata = Map.unmodifiable(metadata ?? {}) {
    // Business rule validation
    if (_quantity <= 0) {
      throw DomainException('Cost quantity must be positive');
    }
    if (_isRecurring && _recurringInterval == null) {
      throw DomainException('Recurring costs must have an interval specified');
    }
  }

  /// Cost ID
  UserId get id => _id;

  /// Cost description
  String get description => _description;

  /// Type of cost
  CostType get type => _type;

  /// Cost category
  CostCategory get category => _category;

  /// Total cost amount
  Money get amount => _amount;

  /// When cost was incurred
  Time get incurredDate => _incurredDate;

  /// Related menu item or ingredient ID
  UserId? get relatedItemId => _relatedItemId;

  /// Cost center ID
  UserId? get costCenterId => _costCenterId;

  /// How cost is allocated
  CostAllocation get allocationMethod => _allocationMethod;

  /// Quantity associated with cost
  double get quantity => _quantity;

  /// Unit of measurement
  String get unit => _unit;

  /// Cost per unit
  Money? get unitCost => _unitCost;

  /// User who recorded the cost
  UserId get recordedBy => _recordedBy;

  /// When cost was recorded
  Time get recordedAt => _recordedAt;

  /// Whether cost recurs
  bool get isRecurring => _isRecurring;

  /// Recurring interval
  Duration? get recurringInterval => _recurringInterval;

  /// Additional notes
  String? get notes => _notes;

  /// Additional metadata
  Map<String, dynamic> get metadata => _metadata;

  /// Business rule: Calculate cost per unit if not provided
  Money get effectiveUnitCost {
    return _unitCost ?? Money(_amount.amount / _quantity);
  }

  /// Business rule: Check if cost is significant (over threshold)
  bool isSignificant(Money threshold) {
    return _amount.amount >= threshold.amount;
  }

  /// Business rule: Get next occurrence date for recurring costs
  Time? get nextOccurrenceDate {
    if (!_isRecurring || _recurringInterval == null) return null;
    return Time.fromDateTime(_incurredDate.dateTime.add(_recurringInterval));
  }

  /// Business rule: Check if cost needs review (over 30 days old)
  bool get needsReview {
    final daysSinceRecorded = Time.now().difference(_recordedAt);
    return daysSinceRecorded.inDays > 30;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cost && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'Cost(type: $_type, amount: $_amount, category: $_category)';
}

/// Cost center for organizing costs
class CostCenter {
  final UserId _id;
  final String _name;
  final String _description;
  final UserId? _parentCenterId;
  final UserId _managerId;
  final List<CostType> _allowedCostTypes;
  final Money _budgetLimit;
  final Time _budgetPeriodStart;
  final Time _budgetPeriodEnd;
  final bool _isActive;
  final Time _createdAt;
  final List<String> _tags;

  /// Creates a CostCenter
  CostCenter({
    required UserId id,
    required String name,
    required String description,
    UserId? parentCenterId,
    required UserId managerId,
    List<CostType>? allowedCostTypes,
    required Money budgetLimit,
    required Time budgetPeriodStart,
    required Time budgetPeriodEnd,
    bool isActive = true,
    required Time createdAt,
    List<String>? tags,
  }) : _id = id,
       _name = name,
       _description = description,
       _parentCenterId = parentCenterId,
       _managerId = managerId,
       _allowedCostTypes = List.unmodifiable(allowedCostTypes ?? []),
       _budgetLimit = budgetLimit,
       _budgetPeriodStart = budgetPeriodStart,
       _budgetPeriodEnd = budgetPeriodEnd,
       _isActive = isActive,
       _createdAt = createdAt,
       _tags = List.unmodifiable(tags ?? []) {
    // Business rule validation
    if (_budgetPeriodStart.dateTime.isAfter(_budgetPeriodEnd.dateTime)) {
      throw DomainException('Budget period start must be before end');
    }
    if (_budgetLimit.amount <= 0) {
      throw DomainException('Budget limit must be positive');
    }
  }

  /// Cost center ID
  UserId get id => _id;

  /// Cost center name
  String get name => _name;

  /// Description of cost center
  String get description => _description;

  /// Parent cost center ID
  UserId? get parentCenterId => _parentCenterId;

  /// Manager responsible for cost center
  UserId get managerId => _managerId;

  /// Types of costs allowed in this center
  List<CostType> get allowedCostTypes => _allowedCostTypes;

  /// Budget limit for current period
  Money get budgetLimit => _budgetLimit;

  /// Budget period start
  Time get budgetPeriodStart => _budgetPeriodStart;

  /// Budget period end
  Time get budgetPeriodEnd => _budgetPeriodEnd;

  /// Whether cost center is active
  bool get isActive => _isActive;

  /// When cost center was created
  Time get createdAt => _createdAt;

  /// Cost center tags
  List<String> get tags => _tags;

  /// Business rule: Check if cost type is allowed
  bool allowsCostType(CostType costType) {
    return _allowedCostTypes.isEmpty || _allowedCostTypes.contains(costType);
  }

  /// Business rule: Check if currently in budget period
  bool get isInBudgetPeriod {
    final now = Time.now();
    return now.dateTime.isAfter(_budgetPeriodStart.dateTime) &&
        now.dateTime.isBefore(_budgetPeriodEnd.dateTime);
  }

  /// Business rule: Check if has parent cost center
  bool get hasParent => _parentCenterId != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CostCenter &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'CostCenter(name: $_name, budget: $_budgetLimit, active: $_isActive)';
}

/// Profitability analysis report
class ProfitabilityReport {
  final UserId _id;
  final String _reportName;
  final Time _periodStart;
  final Time _periodEnd;
  final Money _totalRevenue;
  final Money _totalCosts;
  final Money _grossProfit;
  final Money _netProfit;
  final double _grossProfitMargin;
  final double _netProfitMargin;
  final Map<CostType, Money> _costBreakdown;
  final Map<String, Money> _revenueByCategory;
  final Map<UserId, Money> _profitByItem;
  final List<UserId> _topProfitableItems;
  final List<UserId> _leastProfitableItems;
  final UserId _generatedBy;
  final Time _generatedAt;
  final List<String> _insights;
  final List<String> _recommendations;

  /// Creates a ProfitabilityReport
  ProfitabilityReport({
    required UserId id,
    required String reportName,
    required Time periodStart,
    required Time periodEnd,
    required Money totalRevenue,
    required Money totalCosts,
    Map<CostType, Money>? costBreakdown,
    Map<String, Money>? revenueByCategory,
    Map<UserId, Money>? profitByItem,
    List<UserId>? topProfitableItems,
    List<UserId>? leastProfitableItems,
    required UserId generatedBy,
    required Time generatedAt,
    List<String>? insights,
    List<String>? recommendations,
  }) : _id = id,
       _reportName = reportName,
       _periodStart = periodStart,
       _periodEnd = periodEnd,
       _totalRevenue = totalRevenue,
       _totalCosts = totalCosts,
       _grossProfit = Money(totalRevenue.amount - totalCosts.amount),
       _netProfit = Money(totalRevenue.amount - totalCosts.amount),
       _grossProfitMargin = totalRevenue.amount > 0
           ? ((totalRevenue.amount - totalCosts.amount) / totalRevenue.amount) *
                 100
           : 0,
       _netProfitMargin = totalRevenue.amount > 0
           ? ((totalRevenue.amount - totalCosts.amount) / totalRevenue.amount) *
                 100
           : 0,
       _costBreakdown = Map.unmodifiable(costBreakdown ?? {}),
       _revenueByCategory = Map.unmodifiable(revenueByCategory ?? {}),
       _profitByItem = Map.unmodifiable(profitByItem ?? {}),
       _topProfitableItems = List.unmodifiable(topProfitableItems ?? []),
       _leastProfitableItems = List.unmodifiable(leastProfitableItems ?? []),
       _generatedBy = generatedBy,
       _generatedAt = generatedAt,
       _insights = List.unmodifiable(insights ?? []),
       _recommendations = List.unmodifiable(recommendations ?? []);

  /// Report ID
  UserId get id => _id;

  /// Report name
  String get reportName => _reportName;

  /// Period start
  Time get periodStart => _periodStart;

  /// Period end
  Time get periodEnd => _periodEnd;

  /// Total revenue for period
  Money get totalRevenue => _totalRevenue;

  /// Total costs for period
  Money get totalCosts => _totalCosts;

  /// Gross profit
  Money get grossProfit => _grossProfit;

  /// Net profit
  Money get netProfit => _netProfit;

  /// Gross profit margin percentage
  double get grossProfitMargin => _grossProfitMargin;

  /// Net profit margin percentage
  double get netProfitMargin => _netProfitMargin;

  /// Cost breakdown by type
  Map<CostType, Money> get costBreakdown => _costBreakdown;

  /// Revenue by category
  Map<String, Money> get revenueByCategory => _revenueByCategory;

  /// Profit by individual item
  Map<UserId, Money> get profitByItem => _profitByItem;

  /// Most profitable items
  List<UserId> get topProfitableItems => _topProfitableItems;

  /// Least profitable items
  List<UserId> get leastProfitableItems => _leastProfitableItems;

  /// User who generated report
  UserId get generatedBy => _generatedBy;

  /// When report was generated
  Time get generatedAt => _generatedAt;

  /// Key insights
  List<String> get insights => _insights;

  /// Improvement recommendations
  List<String> get recommendations => _recommendations;

  /// Business rule: Check if business is profitable
  bool get isProfitable => _netProfit.amount > 0;

  /// Business rule: Check if meeting profit targets (>15% margin)
  bool get meetsProfitTargets => _netProfitMargin >= 15;

  /// Business rule: Get largest cost category
  CostType? get largestCostCategory {
    if (_costBreakdown.isEmpty) return null;
    return _costBreakdown.entries
        .reduce((a, b) => a.value.amount > b.value.amount ? a : b)
        .key;
  }

  /// Business rule: Get food cost percentage
  double get foodCostPercentage {
    final ingredientCosts = _costBreakdown[CostType.ingredient];
    if (ingredientCosts == null || _totalRevenue.amount == 0) return 0;
    return (ingredientCosts.amount / _totalRevenue.amount) * 100;
  }

  /// Business rule: Check if food costs are under control (<30%)
  bool get foodCostsUnderControl => foodCostPercentage <= 30;

  /// Business rule: Calculate return on investment
  double calculateROI(Money investment) {
    if (investment.amount <= 0) return 0;
    return (_netProfit.amount / investment.amount) * 100;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfitabilityReport &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'ProfitabilityReport(name: $_reportName, profit: $_netProfit, margin: ${_netProfitMargin.toStringAsFixed(1)}%)';
}

/// Recipe cost analysis
class RecipeCost {
  final UserId _id;
  final UserId _recipeId;
  final String _recipeName;
  final Map<UserId, Money> _ingredientCosts;
  final Money _totalIngredientCost;
  final Money _laborCost;
  final Money _overheadCost;
  final Money _totalCost;
  final double _yield;
  final Money _costPerServing;
  final Money _suggestedPrice;
  final double _targetProfitMargin;
  final Time _calculatedAt;
  final UserId _calculatedBy;
  final bool _isCurrentPricing;

  /// Creates a RecipeCost
  RecipeCost({
    required UserId id,
    required UserId recipeId,
    required String recipeName,
    Map<UserId, Money>? ingredientCosts,
    required Money laborCost,
    required Money overheadCost,
    required double yield,
    required double targetProfitMargin,
    required Time calculatedAt,
    required UserId calculatedBy,
    bool isCurrentPricing = true,
  }) : _id = id,
       _recipeId = recipeId,
       _recipeName = recipeName,
       _ingredientCosts = Map.unmodifiable(ingredientCosts ?? {}),
       _totalIngredientCost = Money(
         (ingredientCosts ?? {}).values.fold(
           0.0,
           (sum, cost) => sum + cost.amount,
         ),
       ),
       _laborCost = laborCost,
       _overheadCost = overheadCost,
       _totalCost = Money(
         (ingredientCosts ?? {}).values.fold(
               0.0,
               (sum, cost) => sum + cost.amount,
             ) +
             laborCost.amount +
             overheadCost.amount,
       ),
       _yield = yield,
       _costPerServing = Money(
         ((ingredientCosts ?? {}).values.fold(
                   0.0,
                   (sum, cost) => sum + cost.amount,
                 ) +
                 laborCost.amount +
                 overheadCost.amount) /
             yield,
       ),
       _suggestedPrice = Money(
         (((ingredientCosts ?? {}).values.fold(
                       0.0,
                       (sum, cost) => sum + cost.amount,
                     ) +
                     laborCost.amount +
                     overheadCost.amount) /
                 yield) /
             (1 - targetProfitMargin / 100),
       ),
       _targetProfitMargin = targetProfitMargin,
       _calculatedAt = calculatedAt,
       _calculatedBy = calculatedBy,
       _isCurrentPricing = isCurrentPricing {
    // Business rule validation
    if (_yield <= 0) {
      throw DomainException('Recipe yield must be positive');
    }
    if (_targetProfitMargin < 0 || _targetProfitMargin >= 100) {
      throw DomainException('Target profit margin must be between 0 and 100');
    }
  }

  /// Recipe cost ID
  UserId get id => _id;

  /// Recipe ID
  UserId get recipeId => _recipeId;

  /// Recipe name
  String get recipeName => _recipeName;

  /// Cost breakdown by ingredient
  Map<UserId, Money> get ingredientCosts => _ingredientCosts;

  /// Total ingredient cost
  Money get totalIngredientCost => _totalIngredientCost;

  /// Labor cost for recipe
  Money get laborCost => _laborCost;

  /// Overhead cost allocation
  Money get overheadCost => _overheadCost;

  /// Total cost to make recipe
  Money get totalCost => _totalCost;

  /// Recipe yield (number of servings)
  double get yield => _yield;

  /// Cost per individual serving
  Money get costPerServing => _costPerServing;

  /// Suggested selling price
  Money get suggestedPrice => _suggestedPrice;

  /// Target profit margin percentage
  double get targetProfitMargin => _targetProfitMargin;

  /// When cost was calculated
  Time get calculatedAt => _calculatedAt;

  /// User who calculated cost
  UserId get calculatedBy => _calculatedBy;

  /// Whether this is current pricing
  bool get isCurrentPricing => _isCurrentPricing;

  /// Business rule: Calculate actual profit margin at given selling price
  double calculateProfitMargin(Money sellingPrice) {
    if (sellingPrice.amount <= 0) return 0;
    return ((sellingPrice.amount - _costPerServing.amount) /
            sellingPrice.amount) *
        100;
  }

  /// Business rule: Check if recipe is profitable at given price
  bool isProfitableAt(Money sellingPrice) {
    return sellingPrice.amount > _costPerServing.amount;
  }

  /// Business rule: Get most expensive ingredient
  UserId? get mostExpensiveIngredient {
    if (_ingredientCosts.isEmpty) return null;
    return _ingredientCosts.entries
        .reduce((a, b) => a.value.amount > b.value.amount ? a : b)
        .key;
  }

  /// Business rule: Get ingredient cost percentage of total
  double getIngredientPercentage(UserId ingredientId) {
    final ingredientCost = _ingredientCosts[ingredientId];
    if (ingredientCost == null || _totalCost.amount == 0) return 0;
    return (ingredientCost.amount / _totalCost.amount) * 100;
  }

  /// Business rule: Check if costing is outdated (over 30 days)
  bool get isOutdated {
    final daysSinceCalculated = Time.now().difference(_calculatedAt);
    return daysSinceCalculated.inDays > 30;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeCost &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'RecipeCost(recipe: $_recipeName, cost: $_costPerServing/serving, suggested: $_suggestedPrice)';
}
