// Kitchen Configuration for Restaurant Operations
// Centralized configuration for kitchen capacity and operational limits

import 'package:injectable/injectable.dart';

/// Configuration settings for kitchen operations
@singleton
class KitchenConfig {
  /// Maximum number of concurrent orders the kitchen can handle
  static const int maxConcurrentOrders = 15;

  /// Maximum preparation time allowed per order (in minutes)
  static const int maxPreparationTimeMinutes = 120;

  /// Minimum staff required for kitchen operations
  static const int minimumKitchenStaff = 2;

  /// Maximum order complexity score before requiring approval
  static const double maxOrderComplexityScore = 100.0;

  /// Default order priority timeout (in minutes)
  static const int defaultPriorityTimeoutMinutes = 30;

  /// Kitchen capacity warning threshold (percentage)
  static const double capacityWarningThreshold = 0.8; // 80%

  /// Auto-reject orders when capacity exceeds this threshold
  static const double capacityRejectThreshold = 0.95; // 95%

  /// Get current max concurrent orders setting
  int get maxConcurrentOrdersLimit => maxConcurrentOrders;

  /// Get current max preparation time setting
  int get maxPreparationTime => maxPreparationTimeMinutes;

  /// Get minimum required staff
  int get minimumStaff => minimumKitchenStaff;

  /// Calculate if kitchen is approaching capacity
  bool isApproachingCapacity(int currentOrders) {
    return currentOrders >= (maxConcurrentOrders * capacityWarningThreshold);
  }

  /// Calculate if kitchen is at critical capacity
  bool isAtCriticalCapacity(int currentOrders) {
    return currentOrders >= (maxConcurrentOrders * capacityRejectThreshold);
  }

  /// Get recommended action based on current load
  String getCapacityRecommendation(int currentOrders, int availableStaff) {
    if (availableStaff < minimumStaff) {
      return 'Insufficient staff - kitchen operations compromised';
    }

    if (isAtCriticalCapacity(currentOrders)) {
      return 'Critical capacity - reject new orders temporarily';
    }

    if (isApproachingCapacity(currentOrders)) {
      return 'High capacity - prioritize order completion';
    }

    return 'Normal operations - accepting new orders';
  }
}
