// Analytics Mapper for Clean Architecture Infrastructure Layer
// Handles conversion between Analytics entities and Firestore documents

import 'package:injectable/injectable.dart';
import '../../domain/entities/analytics.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';
import '../../domain/entities/user.dart';

@LazySingleton()
class AnalyticsMapper {
  /// Converts KitchenMetric entity to Firestore document map
  Map<String, dynamic> kitchenMetricToFirestore(KitchenMetric metric) {
    return {
      'id': metric.id.value,
      'type': _metricTypeToString(metric.type),
      'name': metric.name,
      'value': metric.value,
      'unit': metric.unit,
      'target': metric.target,
      'previousValue': metric.previousValue,
      'recordedAt': metric.recordedAt.millisecondsSinceEpoch,
      'period': _analyticsPeriodToString(metric.period),
      'stationId': metric.stationId?.value,
      'userId': metric.userId?.value,
      'metadata': metric.metadata,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Converts Firestore document to KitchenMetric entity
  KitchenMetric kitchenMetricFromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return KitchenMetric(
      id: UserId(id),
      type: _metricTypeFromString(data['type'] as String),
      name: data['name'] as String,
      value: (data['value'] as num).toDouble(),
      unit: data['unit'] as String,
      target: data['target'] != null
          ? (data['target'] as num).toDouble()
          : null,
      previousValue: data['previousValue'] != null
          ? (data['previousValue'] as num).toDouble()
          : null,
      recordedAt: Time.fromMillisecondsSinceEpoch(data['recordedAt'] as int),
      period: _analyticsPeriodFromString(data['period'] as String),
      stationId: data['stationId'] != null
          ? UserId(data['stationId'] as String)
          : null,
      userId: data['userId'] != null ? UserId(data['userId'] as String) : null,
      metadata: Map<String, dynamic>.from(data['metadata'] as Map? ?? {}),
    );
  }

  /// Converts PerformanceReport entity to Firestore document map
  Map<String, dynamic> performanceReportToFirestore(PerformanceReport report) {
    return {
      'id': report.id.value,
      'reportName': report.reportName,
      'period': _analyticsPeriodToString(report.period),
      'periodStart': report.periodStart.millisecondsSinceEpoch,
      'periodEnd': report.periodEnd.millisecondsSinceEpoch,
      'overallScore': report.overallScore,
      'overallRating': _performanceRatingToString(report.overallRating),
      'generatedBy': report.generatedBy.value,
      'generatedAt': report.generatedAt.millisecondsSinceEpoch,
      'metrics': report.metrics
          .map((metric) => kitchenMetricToFirestore(metric))
          .toList(),
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Converts Firestore document to PerformanceReport entity
  PerformanceReport performanceReportFromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    final metricsData = data['metrics'] as List<dynamic>? ?? [];
    final metrics = metricsData
        .cast<Map<String, dynamic>>()
        .map(
          (metricData) => kitchenMetricFromFirestore(
            metricData,
            metricData['id'] as String,
          ),
        )
        .toList();

    return PerformanceReport(
      id: UserId(id),
      reportName: data['reportName'] as String,
      period: _analyticsPeriodFromString(data['period'] as String),
      periodStart: Time.fromMillisecondsSinceEpoch(data['periodStart'] as int),
      periodEnd: Time.fromMillisecondsSinceEpoch(data['periodEnd'] as int),
      overallScore: (data['overallScore'] as num).toDouble(),
      overallRating: _performanceRatingFromString(
        data['overallRating'] as String,
      ),
      generatedBy: UserId(data['generatedBy'] as String),
      generatedAt: Time.fromMillisecondsSinceEpoch(data['generatedAt'] as int),
      metrics: metrics,
    );
  }

  /// Converts OrderAnalytics entity to Firestore document map
  Map<String, dynamic> orderAnalyticsToFirestore(OrderAnalytics analytics) {
    return {
      'id': analytics.id.value,
      'date': analytics.date.millisecondsSinceEpoch,
      'totalOrders': analytics.totalOrders,
      'averageOrderValue': analytics.averageOrderValue,
      'averageCompletionTime': analytics.averageCompletionTime.inMilliseconds,
      'peakHourCompletionTime': analytics.peakHourCompletionTime.inMilliseconds,
      'cancelledOrders': analytics.cancelledOrders,
      'cancellationRate': analytics.cancellationRate,
      'refundedOrders': analytics.refundedOrders,
      'refundRate': analytics.refundRate,
      'popularItems': analytics.popularItems,
      'revenueByCategory': analytics.revenueByCategory,
      'ordersByHour': analytics.ordersByHour,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Converts Firestore document to OrderAnalytics entity
  OrderAnalytics orderAnalyticsFromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return OrderAnalytics(
      id: UserId(id),
      date: Time.fromMillisecondsSinceEpoch(data['date'] as int),
      totalOrders: data['totalOrders'] as int,
      averageOrderValue: (data['averageOrderValue'] as num).toDouble(),
      averageCompletionTime: Duration(
        milliseconds: data['averageCompletionTime'] as int,
      ),
      peakHourCompletionTime: Duration(
        milliseconds: data['peakHourCompletionTime'] as int,
      ),
      cancelledOrders: data['cancelledOrders'] as int,
      refundedOrders: data['refundedOrders'] as int,
      popularItems: Map<String, int>.from(data['popularItems'] as Map? ?? {}),
      revenueByCategory: Map<String, double>.from(
        (data['revenueByCategory'] as Map? ?? {}).map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ),
      ),
      ordersByHour: Map<int, int>.from(
        (data['ordersByHour'] as Map? ?? {}).map(
          (key, value) => MapEntry(int.parse(key.toString()), value as int),
        ),
      ),
    );
  }

  /// Converts StaffPerformanceAnalytics entity to Firestore document map
  Map<String, dynamic> staffPerformanceToFirestore(
    StaffPerformanceAnalytics performance,
  ) {
    return {
      'id': performance.id.value,
      'staffId': performance.staffId.value,
      'staffName': performance.staffName,
      'role': _userRoleToString(performance.role),
      'periodStart': performance.periodStart.millisecondsSinceEpoch,
      'periodEnd': performance.periodEnd.millisecondsSinceEpoch,
      'ordersCompleted': performance.ordersCompleted,
      'averageOrderTime': performance.averageOrderTime.inMilliseconds,
      'errorCount': performance.errorCount,
      'errorRate': performance.errorRate,
      'efficiencyScore': performance.efficiencyScore,
      'customersServed': performance.customersServed,
      'customerSatisfactionScore': performance.customerSatisfactionScore,
      'totalWorkTime': performance.totalWorkTime.inMilliseconds,
      'achievements': performance.achievements,
      'improvementAreas': performance.improvementAreas,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Converts Firestore document to StaffPerformanceAnalytics entity
  StaffPerformanceAnalytics staffPerformanceFromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return StaffPerformanceAnalytics(
      id: UserId(id),
      staffId: UserId(data['staffId'] as String),
      staffName: data['staffName'] as String,
      role: _userRoleFromString(data['role'] as String),
      periodStart: Time.fromMillisecondsSinceEpoch(data['periodStart'] as int),
      periodEnd: Time.fromMillisecondsSinceEpoch(data['periodEnd'] as int),
      ordersCompleted: data['ordersCompleted'] as int,
      averageOrderTime: Duration(milliseconds: data['averageOrderTime'] as int),
      errorCount: data['errorCount'] as int,
      efficiencyScore: (data['efficiencyScore'] as num).toDouble(),
      customersServed: data['customersServed'] as int,
      customerSatisfactionScore: (data['customerSatisfactionScore'] as num)
          .toDouble(),
      totalWorkTime: Duration(milliseconds: data['totalWorkTime'] as int),
      achievements: List<String>.from(data['achievements'] as List? ?? []),
      improvementAreas: List<String>.from(
        data['improvementAreas'] as List? ?? [],
      ),
    );
  }

  // Enum conversion methods
  String _metricTypeToString(MetricType type) {
    switch (type) {
      case MetricType.orderCompletionTime:
        return 'order_completion_time';
      case MetricType.stationEfficiency:
        return 'station_efficiency';
      case MetricType.staffPerformance:
        return 'staff_performance';
      case MetricType.foodCostPercentage:
        return 'food_cost_percentage';
      case MetricType.wastePercentage:
        return 'waste_percentage';
      case MetricType.customerSatisfaction:
        return 'customer_satisfaction';
      case MetricType.revenuePerHour:
        return 'revenue_per_hour';
      case MetricType.orderAccuracy:
        return 'order_accuracy';
      case MetricType.temperatureCompliance:
        return 'temperature_compliance';
      case MetricType.inventoryTurnover:
        return 'inventory_turnover';
    }
  }

  MetricType _metricTypeFromString(String type) {
    switch (type) {
      case 'order_completion_time':
        return MetricType.orderCompletionTime;
      case 'station_efficiency':
        return MetricType.stationEfficiency;
      case 'staff_performance':
        return MetricType.staffPerformance;
      case 'food_cost_percentage':
        return MetricType.foodCostPercentage;
      case 'waste_percentage':
        return MetricType.wastePercentage;
      case 'customer_satisfaction':
        return MetricType.customerSatisfaction;
      case 'revenue_per_hour':
        return MetricType.revenuePerHour;
      case 'order_accuracy':
        return MetricType.orderAccuracy;
      case 'temperature_compliance':
        return MetricType.temperatureCompliance;
      case 'inventory_turnover':
        return MetricType.inventoryTurnover;
      default:
        return MetricType.orderCompletionTime;
    }
  }

  String _analyticsPeriodToString(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.hourly:
        return 'hourly';
      case AnalyticsPeriod.daily:
        return 'daily';
      case AnalyticsPeriod.weekly:
        return 'weekly';
      case AnalyticsPeriod.monthly:
        return 'monthly';
      case AnalyticsPeriod.quarterly:
        return 'quarterly';
      case AnalyticsPeriod.yearly:
        return 'yearly';
      case AnalyticsPeriod.custom:
        return 'custom';
    }
  }

  AnalyticsPeriod _analyticsPeriodFromString(String period) {
    switch (period) {
      case 'hourly':
        return AnalyticsPeriod.hourly;
      case 'daily':
        return AnalyticsPeriod.daily;
      case 'weekly':
        return AnalyticsPeriod.weekly;
      case 'monthly':
        return AnalyticsPeriod.monthly;
      case 'quarterly':
        return AnalyticsPeriod.quarterly;
      case 'yearly':
        return AnalyticsPeriod.yearly;
      case 'custom':
        return AnalyticsPeriod.custom;
      default:
        return AnalyticsPeriod.daily;
    }
  }

  String _userRoleToString(UserRole role) {
    switch (role) {
      case UserRole.dishwasher:
        return 'dishwasher';
      case UserRole.prepCook:
        return 'prep_cook';
      case UserRole.lineCook:
        return 'line_cook';
      case UserRole.cook:
        return 'cook';
      case UserRole.cookSenior:
        return 'cook_senior';
      case UserRole.chefAssistant:
        return 'chef_assistant';
      case UserRole.sousChef:
        return 'sous_chef';
      case UserRole.chefHead:
        return 'chef_head';
      case UserRole.expediter:
        return 'expediter';
      case UserRole.kitchenManager:
        return 'kitchen_manager';
      case UserRole.generalManager:
        return 'general_manager';
      case UserRole.admin:
        return 'admin';
    }
  }

  UserRole _userRoleFromString(String role) {
    switch (role) {
      case 'dishwasher':
        return UserRole.dishwasher;
      case 'prep_cook':
        return UserRole.prepCook;
      case 'line_cook':
        return UserRole.lineCook;
      case 'cook':
        return UserRole.cook;
      case 'cook_senior':
        return UserRole.cookSenior;
      case 'chef_assistant':
        return UserRole.chefAssistant;
      case 'sous_chef':
        return UserRole.sousChef;
      case 'chef_head':
        return UserRole.chefHead;
      case 'expediter':
        return UserRole.expediter;
      case 'kitchen_manager':
        return UserRole.kitchenManager;
      case 'general_manager':
        return UserRole.generalManager;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.lineCook;
    }
  }

  /// Converts StaffPerformanceAnalytics entity to Firestore document
  Map<String, dynamic> staffPerformanceAnalyticsToFirestore(
    StaffPerformanceAnalytics analytics,
  ) {
    return {
      'id': analytics.id.value,
      'staffId': analytics.staffId.value,
      'staffName': analytics.staffName,
      'role': _userRoleToString(analytics.role),
      'periodStart': analytics.periodStart.millisecondsSinceEpoch,
      'periodEnd': analytics.periodEnd.millisecondsSinceEpoch,
      'ordersCompleted': analytics.ordersCompleted,
      'averageOrderTime': analytics.averageOrderTime.inMilliseconds,
      'errorCount': analytics.errorCount,
      'efficiencyScore': analytics.efficiencyScore,
      'customersServed': analytics.customersServed,
      'customerSatisfactionScore': analytics.customerSatisfactionScore,
      'totalWorkTime': analytics.totalWorkTime.inMilliseconds,
      'achievements': analytics.achievements,
      'improvementAreas': analytics.improvementAreas,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Converts Firestore document to StaffPerformanceAnalytics entity
  StaffPerformanceAnalytics staffPerformanceAnalyticsFromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return StaffPerformanceAnalytics(
      id: UserId(id),
      staffId: UserId(data['staffId'] as String),
      staffName: data['staffName'] as String,
      role: _userRoleFromString(data['role'] as String),
      periodStart: Time.fromMillisecondsSinceEpoch(data['periodStart'] as int),
      periodEnd: Time.fromMillisecondsSinceEpoch(data['periodEnd'] as int),
      ordersCompleted: data['ordersCompleted'] as int,
      averageOrderTime: Duration(milliseconds: data['averageOrderTime'] as int),
      errorCount: data['errorCount'] as int,
      efficiencyScore: (data['efficiencyScore'] as num).toDouble(),
      customersServed: data['customersServed'] as int,
      customerSatisfactionScore: (data['customerSatisfactionScore'] as num)
          .toDouble(),
      totalWorkTime: Duration(milliseconds: data['totalWorkTime'] as int),
      achievements: List<String>.from(data['achievements'] ?? []),
      improvementAreas: List<String>.from(data['improvementAreas'] ?? []),
    );
  }

  /// Converts KitchenEfficiencyAnalytics entity to Firestore document
  Map<String, dynamic> kitchenEfficiencyAnalyticsToFirestore(
    KitchenEfficiencyAnalytics analytics,
  ) {
    return {
      'id': analytics.id.value,
      'date': analytics.date.millisecondsSinceEpoch,
      'stationUtilization': analytics.stationUtilization.map(
        (key, value) => MapEntry(key.value, value),
      ),
      'stationAverageTime': analytics.stationAverageTime.map(
        (key, value) => MapEntry(key.value, value.inMilliseconds),
      ),
      'stationOrderCount': analytics.stationOrderCount.map(
        (key, value) => MapEntry(key.value, value),
      ),
      'overallEfficiency': analytics.overallEfficiency,
      'averageOrderTime': analytics.averageOrderTime.inMilliseconds,
      'peakHourAverageTime': analytics.peakHourAverageTime.inMilliseconds,
      'bottleneckStationCount': analytics.bottleneckStationCount,
      'bottleneckStations': analytics.bottleneckStations
          .map((id) => id.value)
          .toList(),
      'capacityUtilization': analytics.capacityUtilization,
      'efficiencyIssues': analytics.efficiencyIssues,
      'optimizationSuggestions': analytics.optimizationSuggestions,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Converts Firestore document to KitchenEfficiencyAnalytics entity
  KitchenEfficiencyAnalytics kitchenEfficiencyAnalyticsFromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    final stationUtilizationData =
        data['stationUtilization'] as Map<String, dynamic>? ?? {};
    final stationAverageTimeData =
        data['stationAverageTime'] as Map<String, dynamic>? ?? {};
    final stationOrderCountData =
        data['stationOrderCount'] as Map<String, dynamic>? ?? {};

    return KitchenEfficiencyAnalytics(
      id: UserId(id),
      date: Time.fromMillisecondsSinceEpoch(data['date'] as int),
      stationUtilization: stationUtilizationData.map(
        (key, value) => MapEntry(UserId(key), (value as num).toDouble()),
      ),
      stationAverageTime: stationAverageTimeData.map(
        (key, value) =>
            MapEntry(UserId(key), Duration(milliseconds: value as int)),
      ),
      stationOrderCount: stationOrderCountData.map(
        (key, value) => MapEntry(UserId(key), value as int),
      ),
      overallEfficiency: (data['overallEfficiency'] as num).toDouble(),
      averageOrderTime: Duration(milliseconds: data['averageOrderTime'] as int),
      peakHourAverageTime: Duration(
        milliseconds: data['peakHourAverageTime'] as int,
      ),
      bottleneckStationCount: data['bottleneckStationCount'] as int,
      bottleneckStations: (data['bottleneckStations'] as List<dynamic>? ?? [])
          .map((id) => UserId(id as String))
          .toList(),
      capacityUtilization: (data['capacityUtilization'] as num).toDouble(),
      efficiencyIssues: List<String>.from(data['efficiencyIssues'] ?? []),
      optimizationSuggestions: List<String>.from(
        data['optimizationSuggestions'] ?? [],
      ),
    );
  }

  String _performanceRatingToString(PerformanceRating rating) {
    switch (rating) {
      case PerformanceRating.excellent:
        return 'excellent';
      case PerformanceRating.good:
        return 'good';
      case PerformanceRating.satisfactory:
        return 'satisfactory';
      case PerformanceRating.needsImprovement:
        return 'needs_improvement';
      case PerformanceRating.poor:
        return 'poor';
    }
  }

  PerformanceRating _performanceRatingFromString(String rating) {
    switch (rating) {
      case 'excellent':
        return PerformanceRating.excellent;
      case 'good':
        return PerformanceRating.good;
      case 'satisfactory':
        return PerformanceRating.satisfactory;
      case 'needs_improvement':
        return PerformanceRating.needsImprovement;
      case 'poor':
        return PerformanceRating.poor;
      default:
        return PerformanceRating.satisfactory;
    }
  }
}
