// Analytics BLoC Events
// Handles all analytics-related user actions and business events

import 'package:equatable/equatable.dart';
import '../../../domain/entities/analytics.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/time.dart';

/// Base class for all analytics events
abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

/// Load kitchen metrics for dashboard
class LoadKitchenMetrics extends AnalyticsEvent {
  final MetricType? filterType;
  final UserId? stationId;
  final AnalyticsPeriod period;
  final Time? startDate;
  final Time? endDate;

  const LoadKitchenMetrics({
    this.filterType,
    this.stationId,
    this.period = AnalyticsPeriod.daily,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
    filterType,
    stationId,
    period,
    startDate,
    endDate,
  ];
}

/// Load performance reports
class LoadPerformanceReports extends AnalyticsEvent {
  final AnalyticsPeriod period;
  final Time startDate;
  final Time endDate;

  const LoadPerformanceReports({
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [period, startDate, endDate];
}

/// Generate new performance report
class GeneratePerformanceReport extends AnalyticsEvent {
  final Time startDate;
  final Time endDate;
  final List<MetricType> includeMetrics;

  const GeneratePerformanceReport({
    required this.startDate,
    required this.endDate,
    required this.includeMetrics,
  });

  @override
  List<Object?> get props => [startDate, endDate, includeMetrics];
}

/// Load staff performance analytics
class LoadStaffPerformance extends AnalyticsEvent {
  final UserId? staffId;
  final Time startDate;
  final Time endDate;

  const LoadStaffPerformance({
    this.staffId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [staffId, startDate, endDate];
}

/// Load kitchen efficiency data
class LoadKitchenEfficiency extends AnalyticsEvent {
  final Time startDate;
  final Time endDate;

  const LoadKitchenEfficiency({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Subscribe to real-time metrics updates
class SubscribeToMetricsUpdates extends AnalyticsEvent {
  final MetricType? filterType;
  final UserId? stationId;

  const SubscribeToMetricsUpdates({this.filterType, this.stationId});

  @override
  List<Object?> get props => [filterType, stationId];
}

/// Unsubscribe from real-time updates
class UnsubscribeFromUpdates extends AnalyticsEvent {
  const UnsubscribeFromUpdates();
}

/// Refresh analytics data
class RefreshAnalytics extends AnalyticsEvent {
  const RefreshAnalytics();
}

/// Update metric filter
class UpdateMetricFilter extends AnalyticsEvent {
  final MetricType? type;
  final UserId? stationId;
  final AnalyticsPeriod? period;

  const UpdateMetricFilter({this.type, this.stationId, this.period});

  @override
  List<Object?> get props => [type, stationId, period];
}

/// Load metrics needing improvement
class LoadMetricsNeedingImprovement extends AnalyticsEvent {
  const LoadMetricsNeedingImprovement();
}

/// Load top performing metrics
class LoadTopPerformingMetrics extends AnalyticsEvent {
  const LoadTopPerformingMetrics();
}

/// Load analytics trends
class LoadAnalyticsTrends extends AnalyticsEvent {
  final UserId? staffId;
  final Time startDate;
  final Time endDate;

  const LoadAnalyticsTrends({
    this.staffId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [staffId, startDate, endDate];
}

/// Create new kitchen metric
class CreateKitchenMetric extends AnalyticsEvent {
  final KitchenMetric metric;

  const CreateKitchenMetric({required this.metric});

  @override
  List<Object?> get props => [metric];
}

/// Update existing metric
class UpdateKitchenMetric extends AnalyticsEvent {
  final KitchenMetric metric;

  const UpdateKitchenMetric({required this.metric});

  @override
  List<Object?> get props => [metric];
}

/// Delete metric
class DeleteKitchenMetric extends AnalyticsEvent {
  final UserId metricId;

  const DeleteKitchenMetric({required this.metricId});

  @override
  List<Object?> get props => [metricId];
}
