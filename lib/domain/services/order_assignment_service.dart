import '../entities/order.dart';
import '../entities/station.dart';
import '../entities/user.dart';
import '../entities/recipe.dart';
import '../value_objects/user_id.dart';

/// Domain service for complex order assignment business logic
/// Encapsulates cross-entity business rules that don't belong in a single entity
class OrderAssignmentService {
  /// Validates if an order can be assigned to a specific station
  /// Complex business rule that involves Order, Station, and current workload
  bool canAssignOrderToStation({
    required Order order,
    required Station station,
    required List<Order> currentStationOrders,
  }) {
    // Station must be available
    if (station.status != StationStatus.available) {
      return false;
    }

    // Check capacity constraints
    if (currentStationOrders.length >= station.capacity) {
      return false;
    }

    // Check station compatibility with order items
    for (final item in order.items) {
      if (!_isStationCompatibleWithRecipe(station.stationType, item.recipe)) {
        return false;
      }
    }

    // Check complexity vs station capabilities
    final orderComplexity = _calculateOrderComplexity(order);
    if (orderComplexity > _getStationMaxComplexity(station.stationType)) {
      return false;
    }

    // Check estimated completion time vs current workload
    final estimatedTime = order.estimatedCompletionTimeMinutes;
    final stationWorkload = _calculateStationWorkload(currentStationOrders);
    final maxWorkload = _getStationMaxWorkload(station.stationType);

    if (stationWorkload + estimatedTime > maxWorkload) {
      return false;
    }

    return true;
  }

  /// Finds the optimal station for an order based on business rules
  /// Returns the best station considering workload, capabilities, and efficiency
  Station? findOptimalStationForOrder({
    required Order order,
    required List<Station> availableStations,
    required Map<UserId, List<Order>> stationOrders,
  }) {
    final compatibleStations = availableStations
        .where(
          (station) => canAssignOrderToStation(
            order: order,
            station: station,
            currentStationOrders: stationOrders[station.id] ?? [],
          ),
        )
        .toList();

    if (compatibleStations.isEmpty) {
      return null;
    }

    // Score each station and return the best one
    Station? bestStation;
    double bestScore = -1;

    for (final station in compatibleStations) {
      final score = _calculateStationScore(
        station: station,
        order: order,
        currentOrders: stationOrders[station.id] ?? [],
      );

      if (score > bestScore) {
        bestScore = score;
        bestStation = station;
      }
    }

    return bestStation;
  }

  /// Validates staff assignment to station for specific order types
  /// Complex business rule involving User qualifications, Station requirements, and Order complexity
  bool canStaffHandleOrderAtStation({
    required User staff,
    required Station station,
    required Order order,
  }) {
    // Basic station compatibility - using KitchenStation enum from User entity
    if (!staff.canWorkAtStation(
      _mapStationTypeToKitchenStation(station.stationType),
    )) {
      return false;
    }

    // Check order complexity vs staff experience
    final orderComplexity = _calculateOrderComplexity(order);
    final staffLevel = _getStaffExperienceLevel(staff);

    if (orderComplexity > staffLevel) {
      return false;
    }

    // Special dietary requirements need experienced staff
    if (order.hasSpecialDietaryRequirements) {
      if (!_staffHasDietaryExperience(staff)) {
        return false;
      }
    }

    // High-value orders need senior staff
    if (order.totalAmount.amount > 100.0) {
      if (!_isSeniorStaff(staff)) {
        return false;
      }
    }

    return true;
  }

  /// Maps StationType to KitchenStation enum
  KitchenStation _mapStationTypeToKitchenStation(StationType stationType) {
    switch (stationType) {
      case StationType.grill:
        return KitchenStation.grill;
      case StationType.prep:
        return KitchenStation.prep;
      case StationType.fryer:
        return KitchenStation.fryer;
      case StationType.salad:
        return KitchenStation.salad;
      case StationType.dessert:
        return KitchenStation.pastry;
      case StationType.beverage:
        return KitchenStation.salad; // Closest mapping
    }
  }

  /// Checks if station type is compatible with recipe category
  bool _isStationCompatibleWithRecipe(StationType stationType, Recipe recipe) {
    switch (stationType) {
      case StationType.grill:
        return recipe.category == RecipeCategory.main;
      case StationType.prep:
        return true; // Prep station can handle any category
      case StationType.fryer:
        return recipe.category == RecipeCategory.main ||
            recipe.category == RecipeCategory.appetizer ||
            recipe.category == RecipeCategory.side;
      case StationType.salad:
        return recipe.category == RecipeCategory.appetizer ||
            recipe.category == RecipeCategory.side;
      case StationType.dessert:
        return recipe.category == RecipeCategory.dessert;
      case StationType.beverage:
        return recipe.category == RecipeCategory.beverage;
    }
  }

  /// Gets maximum complexity level for station type
  double _getStationMaxComplexity(StationType stationType) {
    switch (stationType) {
      case StationType.prep:
        return 5.0;
      case StationType.salad:
        return 6.0;
      case StationType.fryer:
        return 7.0;
      case StationType.beverage:
        return 4.0;
      case StationType.grill:
        return 8.0;
      case StationType.dessert:
        return 9.0;
    }
  }

  /// Gets maximum workload in minutes for station type
  double _getStationMaxWorkload(StationType stationType) {
    switch (stationType) {
      case StationType.prep:
        return 480.0; // 8 hours
      case StationType.salad:
        return 360.0; // 6 hours
      case StationType.fryer:
        return 420.0; // 7 hours
      case StationType.beverage:
        return 300.0; // 5 hours
      case StationType.grill:
        return 450.0; // 7.5 hours
      case StationType.dessert:
        return 400.0; // 6.7 hours
    }
  }

  /// Calculates order complexity based on items, special instructions, and timing
  double _calculateOrderComplexity(Order order) {
    double complexity = 0.0;

    // Base complexity from number of items
    complexity += order.items.length * 0.5;

    // Complexity from recipe difficulty
    for (final item in order.items) {
      switch (item.recipe.difficulty) {
        case RecipeDifficulty.easy:
          complexity += 1.0;
          break;
        case RecipeDifficulty.medium:
          complexity += 2.0;
          break;
        case RecipeDifficulty.hard:
          complexity += 3.0;
          break;
      }
    }

    // Special instructions add complexity
    if (order.specialInstructions != null &&
        order.specialInstructions!.isNotEmpty) {
      complexity += 1.5;
    }

    // Priority affects complexity handling
    complexity += order.priority.level * 0.5;

    return complexity;
  }

  /// Calculates current workload of a station in minutes
  double _calculateStationWorkload(List<Order> orders) {
    return orders
        .where((order) => !order.isCompleted)
        .map((order) => order.estimatedCompletionTimeMinutes)
        .fold(0.0, (sum, time) => sum + time);
  }

  /// Calculates score for station assignment (higher is better)
  double _calculateStationScore({
    required Station station,
    required Order order,
    required List<Order> currentOrders,
  }) {
    double score = 100.0; // Base score

    // Penalize based on current workload percentage
    final maxWorkload = _getStationMaxWorkload(station.stationType);
    final workloadPercentage =
        _calculateStationWorkload(currentOrders) / maxWorkload;
    score -= workloadPercentage * 30;

    // Bonus for lower current workload
    final workloadRatio = station.currentWorkload / station.capacity.toDouble();
    score += (1.0 - workloadRatio) * 20;

    // Bonus for station specialization
    if (_isStationSpecializedFor(
      station.stationType,
      order.items.first.recipe.category,
    )) {
      score += 20;
    }

    // Penalty for complexity mismatch
    final orderComplexity = _calculateOrderComplexity(order);
    final maxComplexity = _getStationMaxComplexity(station.stationType);
    if (orderComplexity > maxComplexity * 0.8) {
      score -= 15;
    }

    return score;
  }

  /// Checks if station is specialized for a recipe category
  bool _isStationSpecializedFor(
    StationType stationType,
    RecipeCategory category,
  ) {
    switch (stationType) {
      case StationType.grill:
        return category == RecipeCategory.main;
      case StationType.salad:
        return category == RecipeCategory.appetizer ||
            category == RecipeCategory.side;
      case StationType.dessert:
        return category == RecipeCategory.dessert;
      case StationType.beverage:
        return category == RecipeCategory.beverage;
      case StationType.fryer:
        return category == RecipeCategory.main ||
            category == RecipeCategory.appetizer;
      case StationType.prep:
        return false; // Prep is general, not specialized
    }
  }

  /// Gets staff experience level for complexity matching
  double _getStaffExperienceLevel(User staff) {
    switch (staff.role) {
      case UserRole.dishwasher:
        return 2.0;
      case UserRole.lineCook:
        return 5.0;
      case UserRole.cook:
        return 7.0;
      case UserRole.sousChef:
        return 9.0;
      case UserRole.kitchenManager:
        return 10.0;
      default:
        return 1.0;
    }
  }

  /// Checks if staff has dietary restrictions experience
  bool _staffHasDietaryExperience(User staff) {
    // Senior roles typically have dietary training
    return [
      UserRole.cook,
      UserRole.sousChef,
      UserRole.kitchenManager,
    ].contains(staff.role);
  }

  /// Checks if staff member is considered senior
  bool _isSeniorStaff(User staff) {
    return [UserRole.sousChef, UserRole.kitchenManager].contains(staff.role);
  }
}

/// Extension methods for enhanced Order business logic
extension OrderAssignmentExtensions on Order {
  /// Checks if order has special dietary requirements
  bool get hasSpecialDietaryRequirements {
    return items.any((item) => item.recipe.allergens.isNotEmpty) ||
        specialInstructions?.toLowerCase().contains('allerg') == true ||
        specialInstructions?.toLowerCase().contains('gluten') == true ||
        specialInstructions?.toLowerCase().contains('vegan') == true;
  }

  /// Gets estimated completion time considering all items
  double get estimatedCompletionTimeMinutes {
    if (items.isEmpty) return 0.0;

    // For multiple items, use the maximum time (parallel cooking)
    // Plus 20% overhead for coordination
    final maxTime = items
        .map((item) => item.estimatedTimeMinutes.toDouble())
        .reduce((a, b) => a > b ? a : b);

    return maxTime * 1.2;
  }
}
