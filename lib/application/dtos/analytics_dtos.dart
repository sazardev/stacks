// Analytics DTOs for Clean Architecture Application Layer

import 'package:equatable/equatable.dart';
import '../../domain/entities/analytics.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_objects/time.dart';
import '../../domain/value_objects/user_id.dart';

/// DTO for creating a kitchen metric
class CreateKitchenMetricDto extends Equatable {
  final MetricType type;
  final String name;
  final double value;
  final String unit;
  final Time recordedAt;
  final AnalyticsPeriod period;
  final double? target;
  final double? previousValue;
  final String? stationId;
  final String? userId;
  final Map<String, dynamic>? metadata;

  const CreateKitchenMetricDto({
    required this.type,
    required this.name,
    required this.value,
    required this.unit,
    required this.recordedAt,
    required this.period,
    this.target,
    this.previousValue,
    this.stationId,
    this.userId,
    this.metadata,
  });

  /// Convert DTO to KitchenMetric entity
  KitchenMetric toEntity() {
    return KitchenMetric(
      id: UserId.generate(),
      type: type,
      name: name,
      value: value,
      unit: unit,
      recordedAt: recordedAt,
      period: period,
      target: target,
      previousValue: previousValue,
      stationId: stationId != null ? UserId(stationId!) : null,
      userId: userId != null ? UserId(userId!) : null,
      metadata: metadata,
    );
  }

  @override
  List<Object?> get props => [
    type,
    name,
    value,
    unit,
    recordedAt,
    period,
    target,
    previousValue,
    stationId,
    userId,
    metadata,
  ];
}

/// DTO for analytics queries
class AnalyticsQueryDto extends Equatable {
  final AnalyticsPeriod period;
  final Time startDate;
  final Time endDate;
  final List<MetricType>? metricTypes;
  final String? stationId;
  final String? userId;
  final String? staffId;
  final Time? date;

  const AnalyticsQueryDto({
    required this.period,
    required this.startDate,
    required this.endDate,
    this.metricTypes,
    this.stationId,
    this.userId,
    this.staffId,
    this.date,
  });

  @override
  List<Object?> get props => [
    period,
    startDate,
    endDate,
    metricTypes,
    stationId,
    userId,
    staffId,
    date,
  ];
}

/// DTO for generating performance reports
class GeneratePerformanceReportDto extends Equatable {
  final String reportName;
  final AnalyticsPeriod period;
  final Time periodStart;
  final Time periodEnd;
  final String? generatedBy;

  const GeneratePerformanceReportDto({
    required this.reportName,
    required this.period,
    required this.periodStart,
    required this.periodEnd,
    this.generatedBy,
  });

  /// Convert DTO to PerformanceReport entity
  PerformanceReport toEntity() {
    return PerformanceReport(
      id: UserId.generate(),
      reportName: reportName,
      period: period,
      periodStart: periodStart,
      periodEnd: periodEnd,
      overallScore: 0.0,
      overallRating: PerformanceRating.good,
      generatedBy: generatedBy != null
          ? UserId(generatedBy!)
          : UserId.generate(),
      generatedAt: Time.now(),
    );
  }

  @override
  List<Object?> get props => [
    reportName,
    period,
    periodStart,
    periodEnd,
    generatedBy,
  ];
}

/// DTO for creating order analytics
class CreateOrderAnalyticsDto extends Equatable {
  final Time date;
  final int totalOrders;
  final double averageOrderValue;
  final Duration averageCompletionTime;
  final Duration peakHourCompletionTime;
  final int cancelledOrders;
  final int refundedOrders;
  final Map<String, int>? popularItems;
  final Map<String, double>? revenueByCategory;
  final Map<int, int>? ordersByHour;

  const CreateOrderAnalyticsDto({
    required this.date,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.averageCompletionTime,
    required this.peakHourCompletionTime,
    required this.cancelledOrders,
    required this.refundedOrders,
    this.popularItems,
    this.revenueByCategory,
    this.ordersByHour,
  });

  /// Convert DTO to OrderAnalytics entity
  OrderAnalytics toEntity() {
    return OrderAnalytics(
      id: UserId.generate(),
      date: date,
      totalOrders: totalOrders,
      averageOrderValue: averageOrderValue,
      averageCompletionTime: averageCompletionTime,
      peakHourCompletionTime: peakHourCompletionTime,
      cancelledOrders: cancelledOrders,
      refundedOrders: refundedOrders,
      popularItems: popularItems,
      revenueByCategory: revenueByCategory,
      ordersByHour: ordersByHour,
    );
  }

  @override
  List<Object?> get props => [
    date,
    totalOrders,
    averageOrderValue,
    averageCompletionTime,
    peakHourCompletionTime,
    cancelledOrders,
    refundedOrders,
    popularItems,
    revenueByCategory,
    ordersByHour,
  ];
}

/// DTO for creating staff performance analytics
class CreateStaffPerformanceAnalyticsDto extends Equatable {
  final String staffId;
  final String staffName;
  final UserRole role;
  final Time periodStart;
  final Time periodEnd;
  final int ordersCompleted;
  final Duration averageOrderTime;
  final int errorCount;
  final double efficiencyScore;
  final int customersServed;
  final double customerSatisfactionScore;
  final Duration totalWorkTime;
  final List<String>? achievements;
  final List<String>? improvementAreas;

  const CreateStaffPerformanceAnalyticsDto({
    required this.staffId,
    required this.staffName,
    required this.role,
    required this.periodStart,
    required this.periodEnd,
    required this.ordersCompleted,
    required this.averageOrderTime,
    required this.errorCount,
    required this.efficiencyScore,
    required this.customersServed,
    required this.customerSatisfactionScore,
    required this.totalWorkTime,
    this.achievements,
    this.improvementAreas,
  });

  /// Convert DTO to StaffPerformanceAnalytics entity
  StaffPerformanceAnalytics toEntity() {
    return StaffPerformanceAnalytics(
      id: UserId.generate(),
      staffId: UserId(staffId),
      staffName: staffName,
      role: role,
      periodStart: periodStart,
      periodEnd: periodEnd,
      ordersCompleted: ordersCompleted,
      averageOrderTime: averageOrderTime,
      errorCount: errorCount,
      efficiencyScore: efficiencyScore,
      customersServed: customersServed,
      customerSatisfactionScore: customerSatisfactionScore,
      totalWorkTime: totalWorkTime,
      achievements: achievements,
      improvementAreas: improvementAreas,
    );
  }

  @override
  List<Object?> get props => [
    staffId,
    staffName,
    role,
    periodStart,
    periodEnd,
    ordersCompleted,
    averageOrderTime,
    errorCount,
    efficiencyScore,
    customersServed,
    customerSatisfactionScore,
    totalWorkTime,
    achievements,
    improvementAreas,
  ];
}

/// DTO for creating kitchen efficiency analytics
class CreateKitchenEfficiencyAnalyticsDto extends Equatable {
  final Time date;
  final Map<String, double>? stationUtilization;
  final Map<String, Duration>? stationAverageTime;
  final Map<String, int>? stationOrderCount;
  final double overallEfficiency;
  final Duration averageOrderTime;
  final Duration peakHourAverageTime;
  final int bottleneckStationCount;
  final List<String>? bottleneckStations;
  final double capacityUtilization;
  final List<String>? efficiencyIssues;
  final List<String>? optimizationSuggestions;

  const CreateKitchenEfficiencyAnalyticsDto({
    required this.date,
    this.stationUtilization,
    this.stationAverageTime,
    this.stationOrderCount,
    required this.overallEfficiency,
    required this.averageOrderTime,
    required this.peakHourAverageTime,
    required this.bottleneckStationCount,
    this.bottleneckStations,
    required this.capacityUtilization,
    this.efficiencyIssues,
    this.optimizationSuggestions,
  });

  /// Convert DTO to KitchenEfficiencyAnalytics entity
  KitchenEfficiencyAnalytics toEntity() {
    return KitchenEfficiencyAnalytics(
      id: UserId.generate(),
      date: date,
      stationUtilization: stationUtilization?.map(
        (key, value) => MapEntry(UserId(key), value),
      ),
      stationAverageTime: stationAverageTime?.map(
        (key, value) => MapEntry(UserId(key), value),
      ),
      stationOrderCount: stationOrderCount?.map(
        (key, value) => MapEntry(UserId(key), value),
      ),
      overallEfficiency: overallEfficiency,
      averageOrderTime: averageOrderTime,
      peakHourAverageTime: peakHourAverageTime,
      bottleneckStationCount: bottleneckStationCount,
      bottleneckStations: bottleneckStations?.map((id) => UserId(id)).toList(),
      capacityUtilization: capacityUtilization,
      efficiencyIssues: efficiencyIssues,
      optimizationSuggestions: optimizationSuggestions,
    );
  }

  @override
  List<Object?> get props => [
    date,
    stationUtilization,
    stationAverageTime,
    stationOrderCount,
    overallEfficiency,
    averageOrderTime,
    peakHourAverageTime,
    bottleneckStationCount,
    bottleneckStations,
    capacityUtilization,
    efficiencyIssues,
    optimizationSuggestions,
  ];
}
