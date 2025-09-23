import '../entities/cost_tracking.dart';
import '../entities/recipe.dart';
import '../entities/inventory_item.dart';
import '../value_objects/money.dart';

/// Domain service for complex pricing and profitability calculations
/// Encapsulates cross-entity business logic for cost analysis and pricing strategies
class PricingService {
  /// Calculates optimal menu pricing based on costs, market analysis, and profit targets
  /// Complex business rule involving Recipe costs, Inventory costs, and target margins
  Money calculateOptimalPrice({
    required Recipe recipe,
    required Map<String, InventoryItem> ingredients,
    required double targetProfitMargin,
    required double marketPositioning, // 0.0 = budget, 1.0 = premium
    required List<Cost> overheadCosts,
    required double expectedVolume,
  }) {
    // Calculate ingredient costs
    final ingredientCosts = _calculateIngredientCosts(recipe, ingredients);

    // Calculate labor costs per serving
    final laborCost = _calculateLaborCostPerServing(recipe, expectedVolume);

    // Calculate overhead allocation per serving
    final overheadCost = _calculateOverheadAllocation(
      overheadCosts,
      expectedVolume,
    );

    // Base cost per serving
    final baseCost = ingredientCosts.add(laborCost).add(overheadCost);

    // Apply profit margin
    final profitMargin = _adjustProfitMarginForMarket(
      targetProfitMargin,
      marketPositioning,
    );
    final basePrice = Money(baseCost.amount / (1 - profitMargin / 100));

    // Apply market positioning adjustment
    final marketAdjustment = _calculateMarketPositioningAdjustment(
      marketPositioning,
    );
    final adjustedPrice = basePrice.multiply(marketAdjustment);

    // Round to appropriate price point
    return _roundToPricePoint(adjustedPrice);
  }

  /// Analyzes recipe profitability at current pricing
  /// Returns profitability analysis with recommendations
  ProfitabilityAnalysis analyzeProfitability({
    required Recipe recipe,
    required Money currentPrice,
    required Map<String, InventoryItem> ingredients,
    required List<Cost> operationalCosts,
    required double monthlyVolume,
  }) {
    // Calculate all costs
    final ingredientCosts = _calculateIngredientCosts(recipe, ingredients);
    final laborCost = _calculateLaborCostPerServing(recipe, monthlyVolume);
    final overheadCost = _calculateOverheadAllocation(
      operationalCosts,
      monthlyVolume,
    );

    final totalCost = ingredientCosts.add(laborCost).add(overheadCost);
    final profit = currentPrice.subtract(totalCost);
    final profitMargin = (profit.amount / currentPrice.amount) * 100;

    // Generate recommendations
    final recommendations = _generatePricingRecommendations(
      currentPrice: currentPrice,
      totalCost: totalCost,
      profitMargin: profitMargin,
      recipe: recipe,
    );

    return ProfitabilityAnalysis(
      recipe: recipe,
      currentPrice: currentPrice,
      totalCost: totalCost,
      profit: profit,
      profitMargin: profitMargin,
      recommendations: recommendations,
      isHealthyMargin: profitMargin >= 60.0, // Industry standard for food
      competitivePosition: _assessCompetitivePosition(
        currentPrice,
        recipe.category,
      ),
    );
  }

  /// Calculates break-even analysis for new recipes or price changes
  BreakEvenAnalysis calculateBreakEven({
    required Recipe recipe,
    required Money proposedPrice,
    required Map<String, InventoryItem> ingredients,
    required List<Cost> fixedCosts,
    required double expectedSalesVolume,
  }) {
    final variableCostPerUnit = _calculateVariableCostPerUnit(
      recipe,
      ingredients,
    );
    final monthlyFixedCosts = _calculateMonthlyFixedCosts(fixedCosts);

    final contributionMargin = proposedPrice.subtract(variableCostPerUnit);
    final contributionMarginPercent =
        (contributionMargin.amount / proposedPrice.amount) * 100;

    // Break-even point in units
    final breakEvenUnits = monthlyFixedCosts.amount / contributionMargin.amount;

    // Break-even point in revenue
    final breakEvenRevenue = Money(breakEvenUnits * proposedPrice.amount);

    // Safety margin
    final safetyMargin = expectedSalesVolume - breakEvenUnits;
    final safetyMarginPercent = (safetyMargin / expectedSalesVolume) * 100;

    return BreakEvenAnalysis(
      recipe: recipe,
      proposedPrice: proposedPrice,
      variableCostPerUnit: variableCostPerUnit,
      fixedCostsPerMonth: monthlyFixedCosts,
      contributionMargin: contributionMargin,
      contributionMarginPercent: contributionMarginPercent,
      breakEvenUnits: breakEvenUnits,
      breakEvenRevenue: breakEvenRevenue,
      expectedVolume: expectedSalesVolume,
      safetyMargin: safetyMargin,
      safetyMarginPercent: safetyMarginPercent,
      isViable: safetyMarginPercent >= 20.0, // Minimum 20% safety margin
    );
  }

  /// Validates pricing strategy against business rules
  bool validatePricingStrategy({
    required Recipe recipe,
    required Money proposedPrice,
    required Money competitorPrice,
    required double targetProfitMargin,
  }) {
    // Minimum price should cover costs + minimum margin
    final minimumPrice = _calculateMinimumViablePrice(recipe);
    if (proposedPrice.amount < minimumPrice.amount) {
      return false;
    }

    // Maximum price shouldn't exceed competitor price by more than 25%
    final maxAllowedPrice = competitorPrice.multiply(1.25);
    if (proposedPrice.amount > maxAllowedPrice.amount) {
      return false;
    }

    // Should meet target profit margin
    final estimatedMargin = _calculateEstimatedMargin(recipe, proposedPrice);
    if (estimatedMargin < targetProfitMargin) {
      return false;
    }

    return true;
  }

  // Private helper methods

  Money _calculateIngredientCosts(
    Recipe recipe,
    Map<String, InventoryItem> ingredients,
  ) {
    double totalCost = 0.0;

    for (final ingredient in recipe.ingredients) {
      final inventoryItem = ingredients[ingredient.name];
      if (inventoryItem != null) {
        // Parse quantity and calculate cost
        final quantity = _parseQuantityFromString(ingredient.quantity);
        final costPerUnit = inventoryItem.unitCost.amount;
        totalCost += quantity * costPerUnit;
      }
    }

    return Money(totalCost);
  }

  Money _calculateLaborCostPerServing(Recipe recipe, double expectedVolume) {
    // Assume average kitchen wage of $15/hour
    const hourlyWage = 15.0;

    // Calculate total preparation time in hours
    final totalTimeHours =
        (recipe.preparationTimeMinutes + recipe.cookingTimeMinutes) / 60.0;

    // Labor cost per recipe
    final laborCostPerRecipe = totalTimeHours * hourlyWage;

    // Divide by expected volume to get cost per serving
    return Money(laborCostPerRecipe / expectedVolume);
  }

  Money _calculateOverheadAllocation(
    List<Cost> overheadCosts,
    double expectedVolume,
  ) {
    final monthlyOverhead = overheadCosts
        .where((cost) => cost.type == CostType.overhead)
        .map((cost) => cost.amount.amount)
        .fold(0.0, (sum, amount) => sum + amount);

    // Allocate overhead per unit based on expected volume
    return Money(monthlyOverhead / expectedVolume);
  }

  double _adjustProfitMarginForMarket(
    double baseMargin,
    double marketPositioning,
  ) {
    // Premium positioning allows higher margins
    final marketMultiplier = 1.0 + (marketPositioning * 0.5);
    return baseMargin * marketMultiplier;
  }

  double _calculateMarketPositioningAdjustment(double marketPositioning) {
    // Budget: 0.9x, Mid-market: 1.0x, Premium: 1.3x
    return 0.9 + (marketPositioning * 0.4);
  }

  Money _roundToPricePoint(Money price) {
    // Round to nearest 0.25 for easier pricing
    final rounded = (price.amount * 4).round() / 4;
    return Money(rounded);
  }

  Money _calculateVariableCostPerUnit(
    Recipe recipe,
    Map<String, InventoryItem> ingredients,
  ) {
    // Simplified calculation - just ingredient costs for variable costs
    return _calculateIngredientCosts(recipe, ingredients);
  }

  Money _calculateMonthlyFixedCosts(List<Cost> costs) {
    return Money(
      costs
          .where(
            (cost) =>
                cost.type == CostType.overhead || cost.type == CostType.labor,
          )
          .map((cost) => cost.amount.amount)
          .fold(0.0, (sum, amount) => sum + amount),
    );
  }

  Money _calculateMinimumViablePrice(Recipe recipe) {
    // Simplified - should cover at least 40% margin on basic costs
    const minimumMargin = 0.4;
    const estimatedBaseCost = 5.0; // Placeholder
    return Money(estimatedBaseCost / (1 - minimumMargin));
  }

  double _calculateEstimatedMargin(Recipe recipe, Money price) {
    // Simplified estimation
    const estimatedCost = 5.0; // Would be calculated properly
    return ((price.amount - estimatedCost) / price.amount) * 100;
  }

  String _assessCompetitivePosition(Money price, RecipeCategory category) {
    // Simplified competitive analysis
    const categoryAverages = {
      RecipeCategory.appetizer: 8.0,
      RecipeCategory.main: 18.0,
      RecipeCategory.dessert: 7.0,
      RecipeCategory.beverage: 4.0,
      RecipeCategory.side: 6.0,
    };

    final averagePrice = categoryAverages[category] ?? 10.0;
    final ratio = price.amount / averagePrice;

    if (ratio < 0.8) return 'Budget';
    if (ratio > 1.3) return 'Premium';
    return 'Competitive';
  }

  double _parseQuantityFromString(String quantity) {
    // Simple parser - would need more sophisticated parsing
    final numbers = RegExp(r'\d+\.?\d*').firstMatch(quantity);
    return numbers != null ? double.parse(numbers.group(0)!) : 1.0;
  }

  List<String> _generatePricingRecommendations({
    required Money currentPrice,
    required Money totalCost,
    required double profitMargin,
    required Recipe recipe,
  }) {
    final recommendations = <String>[];

    if (profitMargin < 50.0) {
      recommendations.add(
        'Consider increasing price to achieve healthier profit margin',
      );
    }

    if (profitMargin > 80.0) {
      recommendations.add(
        'Price may be too high - consider reducing to increase volume',
      );
    }

    if (totalCost.amount > currentPrice.amount * 0.5) {
      recommendations.add(
        'Focus on cost reduction through supplier negotiations',
      );
    }

    return recommendations;
  }
}

/// Value object for profitability analysis results
class ProfitabilityAnalysis {
  final Recipe recipe;
  final Money currentPrice;
  final Money totalCost;
  final Money profit;
  final double profitMargin;
  final List<String> recommendations;
  final bool isHealthyMargin;
  final String competitivePosition;

  const ProfitabilityAnalysis({
    required this.recipe,
    required this.currentPrice,
    required this.totalCost,
    required this.profit,
    required this.profitMargin,
    required this.recommendations,
    required this.isHealthyMargin,
    required this.competitivePosition,
  });
}

/// Value object for break-even analysis results
class BreakEvenAnalysis {
  final Recipe recipe;
  final Money proposedPrice;
  final Money variableCostPerUnit;
  final Money fixedCostsPerMonth;
  final Money contributionMargin;
  final double contributionMarginPercent;
  final double breakEvenUnits;
  final Money breakEvenRevenue;
  final double expectedVolume;
  final double safetyMargin;
  final double safetyMarginPercent;
  final bool isViable;

  const BreakEvenAnalysis({
    required this.recipe,
    required this.proposedPrice,
    required this.variableCostPerUnit,
    required this.fixedCostsPerMonth,
    required this.contributionMargin,
    required this.contributionMarginPercent,
    required this.breakEvenUnits,
    required this.breakEvenRevenue,
    required this.expectedVolume,
    required this.safetyMargin,
    required this.safetyMarginPercent,
    required this.isViable,
  });
}
