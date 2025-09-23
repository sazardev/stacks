import '../entities/order.dart';
import '../entities/user.dart';
import '../entities/analytics.dart';
import '../entities/recipe.dart';
import '../value_objects/order_status.dart';

/// Domain service for complex workflow validation and business rule enforcement
/// Encapsulates cross-entity business logic that spans multiple domains
class WorkflowValidationService {
  /// Validates complete order lifecycle transitions
  /// Complex business rule involving Order states, User permissions, and timing constraints
  bool validateOrderStatusTransition({
    required Order order,
    required OrderStatus newStatus,
    required User requestingUser,
  }) {
    // Basic state transition validation
    if (!_isValidStatusTransition(order.status, newStatus)) {
      return false;
    }

    // User authorization validation
    if (!_userCanPerformStatusChange(requestingUser, order.status, newStatus)) {
      return false;
    }

    // Order-specific business rules
    if (!_validateOrderSpecificRules(order, newStatus)) {
      return false;
    }

    return true;
  }

  /// Validates kitchen workflow capacity and resource allocation
  /// Complex business rule for maintaining operational efficiency
  bool validateKitchenCapacity({
    required List<Order> currentOrders,
    required List<User> availableStaff,
    required int maxConcurrentOrders,
  }) {
    // Check basic capacity constraints
    final activeOrders = currentOrders
        .where(
          (order) =>
              order.status.value == 'preparing' ||
              order.status.value == 'confirmed',
        )
        .length;

    if (activeOrders >= maxConcurrentOrders) {
      return false;
    }

    // Validate staff-to-order ratio
    final availableStaffCount = availableStaff
        .where((staff) => staff.isActive)
        .length;

    // Minimum 1 staff per 3 active orders
    if (availableStaffCount * 3 < activeOrders) {
      return false;
    }

    // Check for skill mix requirements
    if (!_validateSkillMixRequirements(currentOrders, availableStaff)) {
      return false;
    }

    return true;
  }

  /// Validates business rule compliance for special handling
  /// Complex rules for dietary restrictions, VIP orders, and compliance
  bool validateSpecialHandlingRequirements({
    required Order order,
    required User assignedChef,
    required List<String> availableEquipment,
  }) {
    // Check dietary restriction handling capability
    if (_orderHasSpecialRequirements(order)) {
      if (!_chefCanHandleDietaryRestrictions(assignedChef)) {
        return false;
      }

      // Check for dedicated equipment availability
      if (!_hasDedicatedEquipmentForDietary(availableEquipment)) {
        return false;
      }
    }

    // VIP order handling
    if (_isVipOrder(order)) {
      if (!_chefQualifiedForVipOrders(assignedChef)) {
        return false;
      }
    }

    // High-value order validation
    if (order.totalAmount.amount > 100.0) {
      if (!_chefCanHandleHighValueOrders(assignedChef)) {
        return false;
      }
    }

    return true;
  }

  /// Validates analytics data integrity and business logic
  /// Ensures metrics align with business rules and operational reality
  bool validateAnalyticsIntegrity({
    required KitchenMetric metric,
    required List<Order> relatedOrders,
  }) {
    // Validate metric values against business constraints
    if (!_isMetricValueRealistic(metric)) {
      return false;
    }

    // Cross-reference with actual order data
    if (!_metricAlignWithOrderData(metric, relatedOrders)) {
      return false;
    }

    return true;
  }

  // Private validation methods

  bool _isValidStatusTransition(OrderStatus current, OrderStatus next) {
    // Define valid state transitions based on OrderStatus values
    final validTransitions = {
      'pending': ['confirmed', 'cancelled'],
      'confirmed': ['preparing', 'cancelled'],
      'preparing': ['ready', 'cancelled'],
      'ready': ['completed'],
      'completed': [], // Terminal state
      'cancelled': [], // Terminal state
    };

    final allowedTransitions = validTransitions[current.value] ?? [];
    return allowedTransitions.contains(next.value);
  }

  bool _userCanPerformStatusChange(
    User user,
    OrderStatus current,
    OrderStatus next,
  ) {
    // Different roles have different permissions for status changes
    switch (next.value) {
      case 'confirmed':
        return [UserRole.sousChef, UserRole.kitchenManager].contains(user.role);
      case 'preparing':
        return [
          UserRole.lineCook,
          UserRole.cook,
          UserRole.sousChef,
          UserRole.kitchenManager,
        ].contains(user.role);
      case 'ready':
        return [
          UserRole.lineCook,
          UserRole.cook,
          UserRole.sousChef,
          UserRole.kitchenManager,
        ].contains(user.role);
      case 'completed':
        return [
          UserRole.cook,
          UserRole.sousChef,
          UserRole.kitchenManager,
        ].contains(user.role);
      case 'cancelled':
        return [UserRole.sousChef, UserRole.kitchenManager].contains(user.role);
      default:
        return false;
    }
  }

  bool _validateOrderSpecificRules(Order order, OrderStatus newStatus) {
    // Business rule: Empty orders cannot be confirmed
    if (newStatus.value == 'confirmed' && order.items.isEmpty) {
      return false;
    }

    // Business rule: Orders with special instructions need special handling
    if (newStatus.value == 'preparing' &&
        order.specialInstructions != null &&
        order.specialInstructions!.isNotEmpty) {
      // Additional validation logic would go here
    }

    return true;
  }

  bool _validateSkillMixRequirements(List<Order> orders, List<User> staff) {
    // Ensure proper skill distribution
    final complexOrders = orders
        .where(
          (order) => order.items.any(
            (item) => item.recipe.difficulty == RecipeDifficulty.hard,
          ),
        )
        .length;

    final seniorStaff = staff
        .where(
          (s) => [
            UserRole.cook,
            UserRole.sousChef,
            UserRole.kitchenManager,
          ].contains(s.role),
        )
        .length;

    // Need at least 1 senior staff member for every 2 complex orders
    return seniorStaff * 2 >= complexOrders;
  }

  bool _orderHasSpecialRequirements(Order order) {
    // Check for special dietary requirements in order
    return order.items.any((item) => item.recipe.allergens.isNotEmpty) ||
        order.specialInstructions?.toLowerCase().contains('allerg') == true ||
        order.specialInstructions?.toLowerCase().contains('gluten') == true ||
        order.specialInstructions?.toLowerCase().contains('vegan') == true;
  }

  bool _chefCanHandleDietaryRestrictions(User chef) {
    // Senior chefs can handle dietary restrictions
    return [
      UserRole.cook,
      UserRole.sousChef,
      UserRole.kitchenManager,
    ].contains(chef.role);
  }

  bool _hasDedicatedEquipmentForDietary(List<String> equipment) {
    // Check for allergen-free equipment
    return equipment.contains('allergen_free_prep_area') ||
        equipment.contains('dedicated_gluten_free_station');
  }

  bool _isVipOrder(Order order) {
    // Simplified VIP detection
    return order.totalAmount.amount > 150.0 || order.priority.level >= 4;
  }

  bool _chefQualifiedForVipOrders(User chef) {
    return [
      UserRole.cook,
      UserRole.sousChef,
      UserRole.kitchenManager,
    ].contains(chef.role);
  }

  bool _chefCanHandleHighValueOrders(User chef) {
    return [
      UserRole.cook,
      UserRole.sousChef,
      UserRole.kitchenManager,
    ].contains(chef.role);
  }

  bool _isMetricValueRealistic(KitchenMetric metric) {
    // Validate metric values against realistic bounds
    switch (metric.type) {
      case MetricType.orderCompletionTime:
        return metric.value >= 1.0 && metric.value <= 180.0; // 1-180 minutes
      case MetricType.stationEfficiency:
        return metric.value >= 0.0 && metric.value <= 100.0; // 0-100%
      case MetricType.staffPerformance:
        return metric.value >= 0.0 && metric.value <= 100.0; // 0-100%
      default:
        return true; // Default to valid
    }
  }

  bool _metricAlignWithOrderData(KitchenMetric metric, List<Order> orders) {
    // Cross-reference metric with actual order performance
    if (metric.type == MetricType.orderCompletionTime && orders.isNotEmpty) {
      final completedOrders = orders.where((order) => order.isCompleted);
      if (completedOrders.isNotEmpty) {
        final avgCompletionTime =
            completedOrders
                .map((order) => _getEstimatedCompletionTime(order).toDouble())
                .fold(0.0, (sum, time) => sum + time) /
            completedOrders.length;

        // Metric should be within 20% of actual average
        final variance =
            (metric.value - avgCompletionTime).abs() / avgCompletionTime;
        return variance <= 0.20;
      }
    }

    return true;
  }

  int _getEstimatedCompletionTime(Order order) {
    // Calculate estimated completion time based on order items
    if (order.items.isEmpty) return 0;

    // Use the maximum time from all items (parallel cooking)
    return order.items
        .map((item) => item.estimatedTimeMinutes)
        .reduce((a, b) => a > b ? a : b);
  }
}

/// Extension for Order workflow validation
extension OrderWorkflowExtensions on Order {
  /// Gets required chef skill level for this order
  int getRequiredSkillLevel() {
    var maxDifficulty = RecipeDifficulty.easy;

    for (final item in items) {
      if (item.recipe.difficulty.index > maxDifficulty.index) {
        maxDifficulty = item.recipe.difficulty;
      }
    }

    switch (maxDifficulty) {
      case RecipeDifficulty.easy:
        return 1;
      case RecipeDifficulty.medium:
        return 2;
      case RecipeDifficulty.hard:
        return 3;
    }
  }

  /// Checks if order is high priority
  bool get isHighPriority => priority.level >= 4;

  /// Checks if order requires special attention
  bool get requiresSpecialAttention {
    return totalAmount.amount > 100.0 ||
        items.any((item) => item.recipe.difficulty == RecipeDifficulty.hard) ||
        specialInstructions?.isNotEmpty == true;
  }
}
