// Analytics BLoC States
// Represents different states of the analytics feature

import 'package:equatable/equatable.dart';
import '../../../domain/entities/analytics.dart';
import '../../../domain/failures/failures.dart';

/// Base class for all analytics states
abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when analytics screen is first opened
class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

/// Loading state - showing progress indicators
class AnalyticsLoading extends AnalyticsState {
  final String? message;

  const AnalyticsLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Successfully loaded analytics data
class AnalyticsLoaded extends AnalyticsState {
  final List<KitchenMetric> metrics;
  final List<PerformanceReport> reports;
  final List<OrderAnalytics> orderAnalytics;
  final List<StaffPerformanceAnalytics> staffPerformance;
  final List<KitchenEfficiencyAnalytics> kitchenEfficiency;
  final MetricType? currentFilter;
  final AnalyticsPeriod currentPeriod;
  final bool isRealTimeEnabled;

  const AnalyticsLoaded({
    this.metrics = const [],
    this.reports = const [],
    this.orderAnalytics = const [],
    this.staffPerformance = const [],
    this.kitchenEfficiency = const [],
    this.currentFilter,
    this.currentPeriod = AnalyticsPeriod.daily,
    this.isRealTimeEnabled = false,
  });

  @override
  List<Object?> get props => [
    metrics,
    reports,
    orderAnalytics,
    staffPerformance,
    kitchenEfficiency,
    currentFilter,
    currentPeriod,
    isRealTimeEnabled,
  ];

  /// Create a copy of the state with updated values
  AnalyticsLoaded copyWith({
    List<KitchenMetric>? metrics,
    List<PerformanceReport>? reports,
    List<OrderAnalytics>? orderAnalytics,
    List<StaffPerformanceAnalytics>? staffPerformance,
    List<KitchenEfficiencyAnalytics>? kitchenEfficiency,
    MetricType? currentFilter,
    AnalyticsPeriod? currentPeriod,
    bool? isRealTimeEnabled,
  }) {
    return AnalyticsLoaded(
      metrics: metrics ?? this.metrics,
      reports: reports ?? this.reports,
      orderAnalytics: orderAnalytics ?? this.orderAnalytics,
      staffPerformance: staffPerformance ?? this.staffPerformance,
      kitchenEfficiency: kitchenEfficiency ?? this.kitchenEfficiency,
      currentFilter: currentFilter ?? this.currentFilter,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      isRealTimeEnabled: isRealTimeEnabled ?? this.isRealTimeEnabled,
    );
  }

  /// Get metrics that need improvement
  List<KitchenMetric> get metricsNeedingImprovement {
    return metrics.where((metric) {
      if (metric.target == null) return false;
      return (metric.value / metric.target!) < 0.8; // Less than 80% of target
    }).toList();
  }

  /// Get top performing metrics
  List<KitchenMetric> get topPerformingMetrics {
    final sortedMetrics = List<KitchenMetric>.from(metrics)
      ..sort((a, b) {
        double scoreA = a.target != null ? (a.value / a.target!) : a.value;
        double scoreB = b.target != null ? (b.value / b.target!) : b.value;
        return scoreB.compareTo(scoreA);
      });
    return sortedMetrics.take(5).toList();
  }

  /// Get average performance score
  double get averagePerformanceScore {
    if (metrics.isEmpty) return 0.0;

    final scoresWithTargets = metrics
        .where((metric) => metric.target != null)
        .map((metric) => (metric.value / metric.target!) * 100)
        .toList();

    if (scoresWithTargets.isEmpty) return 0.0;

    return scoresWithTargets.reduce((a, b) => a + b) / scoresWithTargets.length;
  }

  /// Check if data is fresh (less than 5 minutes old)
  bool get isDataFresh {
    if (metrics.isEmpty) return false;

    final now = DateTime.now();
    final latestMetric = metrics.reduce(
      (a, b) => a.recordedAt.dateTime.isAfter(b.recordedAt.dateTime) ? a : b,
    );

    return now.difference(latestMetric.recordedAt.dateTime).inMinutes < 5;
  }
}

/// Real-time updates received
class AnalyticsRealTimeUpdate extends AnalyticsState {
  final List<KitchenMetric> updatedMetrics;
  final AnalyticsLoaded previousState;

  const AnalyticsRealTimeUpdate({
    required this.updatedMetrics,
    required this.previousState,
  });

  @override
  List<Object?> get props => [updatedMetrics, previousState];
}

/// Successfully performed an action (create, update, delete)
class AnalyticsActionSuccess extends AnalyticsState {
  final String message;
  final AnalyticsLoaded updatedState;

  const AnalyticsActionSuccess({
    required this.message,
    required this.updatedState,
  });

  @override
  List<Object?> get props => [message, updatedState];
}

/// Error state when something goes wrong
class AnalyticsError extends AnalyticsState {
  final Failure failure;
  final String userFriendlyMessage;
  final AnalyticsLoaded? previousState;

  const AnalyticsError({
    required this.failure,
    required this.userFriendlyMessage,
    this.previousState,
  });

  @override
  List<Object?> get props => [failure, userFriendlyMessage, previousState];

  /// Create user-friendly error messages
  factory AnalyticsError.fromFailure(
    Failure failure, {
    AnalyticsLoaded? previousState,
  }) {
    String message;

    switch (failure.runtimeType) {
      case NetworkFailure:
        message = 'Check your internet connection and try again';
        break;
      case ServerFailure:
        message = 'Server error occurred. Please try again later';
        break;
      case NotFoundFailure:
        message = 'Requested analytics data not found';
        break;
      case ValidationFailure:
        message = 'Invalid data provided. Please check your input';
        break;
      default:
        message = 'An unexpected error occurred. Please try again';
    }

    return AnalyticsError(
      failure: failure,
      userFriendlyMessage: message,
      previousState: previousState,
    );
  }
}

/// Empty state when no analytics data is available
class AnalyticsEmpty extends AnalyticsState {
  final String message;

  const AnalyticsEmpty({
    this.message = 'No analytics data available for the selected period',
  });

  @override
  List<Object?> get props => [message];
}

/// Performance report generation in progress
class AnalyticsGeneratingReport extends AnalyticsState {
  final double progress; // 0.0 to 1.0
  final String currentStep;

  const AnalyticsGeneratingReport({
    required this.progress,
    required this.currentStep,
  });

  @override
  List<Object?> get props => [progress, currentStep];
}

/// Performance report successfully generated
class AnalyticsReportGenerated extends AnalyticsState {
  final PerformanceReport report;
  final AnalyticsLoaded updatedState;

  const AnalyticsReportGenerated({
    required this.report,
    required this.updatedState,
  });

  @override
  List<Object?> get props => [report, updatedState];
}
