// Advanced Analytics Use Cases for Clean Architecture Application Layer
// Comprehensive coverage for business intelligence, performance analysis, and reporting

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/analytics.dart';
import '../../../domain/repositories/analytics_repository.dart';
import '../../../domain/repositories/order_repository.dart';
import '../../../domain/repositories/station_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/time.dart';

/// Advanced use case for generating comprehensive kitchen performance analytics
@injectable
class GenerateKitchenPerformanceAnalyticsUseCase {
  final AnalyticsRepository _analyticsRepository;
  // Note: These are injected for potential future cross-repository analytics
  // ignore: unused_field
  final OrderRepository _orderRepository;
  final StationRepository _stationRepository;
  // ignore: unused_field
  final UserRepository _userRepository;

  const GenerateKitchenPerformanceAnalyticsUseCase({
    required AnalyticsRepository analyticsRepository,
    required OrderRepository orderRepository,
    required StationRepository stationRepository,
    required UserRepository userRepository,
  }) : _analyticsRepository = analyticsRepository,
       _orderRepository = orderRepository,
       _stationRepository = stationRepository,
       _userRepository = userRepository;

  /// Generate comprehensive kitchen performance analytics for a given period
  Future<Either<Failure, KitchenPerformanceReport>> execute({
    required Time startDate,
    required Time endDate,
    UserId? stationId,
    List<MetricType>? focusMetrics,
    AnalyticsPeriod period = AnalyticsPeriod.daily,
  }) async {
    try {
      // 1. Gather base metrics from analytics repository
      final metricsResult = await _analyticsRepository
          .getKitchenMetricsByPeriod(period, startDate, endDate);

      return metricsResult.fold((failure) => Left(failure), (metrics) async {
        // Filter by station if specified
        final filteredMetrics = stationId != null
            ? metrics.where((m) => m.stationId == stationId).toList()
            : metrics;

        // Filter by focus metrics if specified
        final finalMetrics = focusMetrics != null
            ? filteredMetrics
                  .where((m) => focusMetrics.contains(m.type))
                  .toList()
            : filteredMetrics;

        // 2. Calculate performance scores
        final performanceScores = await _calculatePerformanceScores(
          finalMetrics,
        );

        // 3. Identify improvement opportunities
        final improvementOpportunities =
            await _identifyImprovementOpportunities(finalMetrics);

        // 4. Generate station comparisons
        final stationComparisons = await _generateStationComparisons(
          finalMetrics,
          startDate,
          endDate,
        );

        // 5. Calculate trend analysis
        final trendAnalysis = await _calculateTrendAnalysis(
          finalMetrics,
          startDate,
          endDate,
        );

        // 6. Generate recommendations
        final recommendations = await _generateRecommendations(
          finalMetrics,
          performanceScores,
          improvementOpportunities,
        );

        // 7. Create comprehensive report
        final report = KitchenPerformanceReport(
          id: UserId.generate(),
          reportName:
              'Kitchen Performance Analysis ${startDate.dateTime.toIso8601String()} - ${endDate.dateTime.toIso8601String()}',
          periodStart: startDate,
          periodEnd: endDate,
          generatedAt: Time.now(),
          metrics: finalMetrics,
          performanceScores: performanceScores,
          improvementOpportunities: improvementOpportunities,
          stationComparisons: stationComparisons,
          trendAnalysis: trendAnalysis,
          recommendations: recommendations,
          overallScore: _calculateOverallScore(performanceScores),
        );

        return Right(report);
      });
    } catch (e) {
      return Left(
        ServerFailure('Failed to generate kitchen performance analytics: $e'),
      );
    }
  }

  Future<Map<MetricType, double>> _calculatePerformanceScores(
    List<KitchenMetric> metrics,
  ) async {
    final scores = <MetricType, double>{};

    // Group metrics by type
    final metricsByType = <MetricType, List<KitchenMetric>>{};
    for (final metric in metrics) {
      metricsByType.putIfAbsent(metric.type, () => []).add(metric);
    }

    // Calculate average performance for each metric type
    for (final entry in metricsByType.entries) {
      final typeMetrics = entry.value;
      final avgPerformance =
          typeMetrics.fold(0.0, (sum, m) {
            // Calculate performance as percentage of target achievement
            final performance = m.target != null && m.target! > 0
                ? (m.value / m.target!) * 100
                : 0.0;
            return sum +
                (m.meetsTarget
                    ? performance
                    : performance * 0.5); // Penalize unmet targets
          }) /
          typeMetrics.length;

      scores[entry.key] = avgPerformance.clamp(0.0, 100.0);
    }

    return scores;
  }

  Future<List<ImprovementOpportunity>> _identifyImprovementOpportunities(
    List<KitchenMetric> metrics,
  ) async {
    final opportunities = <ImprovementOpportunity>[];

    // Identify metrics that don't meet targets
    final underperformingMetrics = metrics
        .where((m) => !m.meetsTarget)
        .toList();

    // Sort by priority and impact
    underperformingMetrics.sort((a, b) {
      final aPriority = _getMetricPriorityScore(a);
      final bPriority = _getMetricPriorityScore(b);
      return bPriority.compareTo(aPriority);
    });

    for (final metric in underperformingMetrics.take(5)) {
      // Top 5 opportunities
      final opportunity = ImprovementOpportunity(
        metricType: metric.type,
        currentValue: metric.value,
        targetValue: metric.target ?? 0.0,
        gap: (metric.target ?? 0.0) - metric.value,
        impactLevel: _calculateImpactLevel(metric),
        recommendedActions: _getRecommendedActions(metric),
        estimatedTimeframe: _getEstimatedTimeframe(metric),
        stationId: metric.stationId,
      );

      opportunities.add(opportunity);
    }

    return opportunities;
  }

  Future<List<StationComparison>> _generateStationComparisons(
    List<KitchenMetric> metrics,
    Time startDate,
    Time endDate,
  ) async {
    final comparisons = <StationComparison>[];

    // Get all stations
    final stationsResult = await _stationRepository.getAllStations();

    return stationsResult.fold((failure) => comparisons, (stations) async {
      for (final station in stations) {
        final stationMetrics = metrics
            .where((m) => m.stationId == station.id)
            .toList();

        if (stationMetrics.isNotEmpty) {
          final avgPerformance =
              stationMetrics.fold(0.0, (sum, m) {
                final performance = m.target != null && m.target! > 0
                    ? (m.value / m.target!) * 100
                    : 0.0;
                return sum + performance;
              }) /
              stationMetrics.length;

          final comparison = StationComparison(
            stationId: station.id,
            stationName: station.name,
            averagePerformance: avgPerformance,
            metricCount: stationMetrics.length,
            topMetrics: _getTopMetrics(stationMetrics),
            improvementAreas: _getImprovementAreas(stationMetrics),
          );

          comparisons.add(comparison);
        }
      }

      // Sort by performance descending
      comparisons.sort(
        (a, b) => b.averagePerformance.compareTo(a.averagePerformance),
      );

      return comparisons;
    });
  }

  Future<TrendAnalysis> _calculateTrendAnalysis(
    List<KitchenMetric> metrics,
    Time startDate,
    Time endDate,
  ) async {
    // Sort metrics by recorded time
    final sortedMetrics = List<KitchenMetric>.from(metrics)
      ..sort((a, b) => a.recordedAt.dateTime.compareTo(b.recordedAt.dateTime));

    if (sortedMetrics.length < 2) {
      return TrendAnalysis(
        overallTrend: TrendDirection.stable,
        trendStrength: 0.0,
        metricTrends: {},
        periodComparison: {},
      );
    }

    // Calculate trends by metric type
    final metricTrends = <MetricType, TrendDirection>{};
    final metricsByType = <MetricType, List<KitchenMetric>>{};

    for (final metric in sortedMetrics) {
      metricsByType.putIfAbsent(metric.type, () => []).add(metric);
    }

    for (final entry in metricsByType.entries) {
      final typeMetrics = entry.value;
      if (typeMetrics.length >= 2) {
        final firstValue = typeMetrics.first.value;
        final lastValue = typeMetrics.last.value;

        final changePercent = firstValue > 0
            ? ((lastValue - firstValue) / firstValue) * 100
            : 0.0;

        if (changePercent > 5) {
          metricTrends[entry.key] = TrendDirection.improving;
        } else if (changePercent < -5) {
          metricTrends[entry.key] = TrendDirection.declining;
        } else {
          metricTrends[entry.key] = TrendDirection.stable;
        }
      }
    }

    // Calculate overall trend
    final improvingCount = metricTrends.values
        .where((t) => t == TrendDirection.improving)
        .length;
    final decliningCount = metricTrends.values
        .where((t) => t == TrendDirection.declining)
        .length;

    TrendDirection overallTrend;
    if (improvingCount > decliningCount) {
      overallTrend = TrendDirection.improving;
    } else if (decliningCount > improvingCount) {
      overallTrend = TrendDirection.declining;
    } else {
      overallTrend = TrendDirection.stable;
    }

    return TrendAnalysis(
      overallTrend: overallTrend,
      trendStrength:
          (improvingCount - decliningCount).abs() / metricTrends.length,
      metricTrends: metricTrends,
      periodComparison: {},
    );
  }

  Future<List<String>> _generateRecommendations(
    List<KitchenMetric> metrics,
    Map<MetricType, double> performanceScores,
    List<ImprovementOpportunity> opportunities,
  ) async {
    final recommendations = <String>[];

    // Performance-based recommendations
    for (final entry in performanceScores.entries) {
      if (entry.value < 70) {
        recommendations.add(
          _getPerformanceRecommendation(entry.key, entry.value),
        );
      }
    }

    // Opportunity-based recommendations
    for (final opportunity in opportunities.take(3)) {
      recommendations.add(_getOpportunityRecommendation(opportunity));
    }

    // General best practices
    if (recommendations.isEmpty) {
      recommendations.addAll(_getGeneralRecommendations(metrics));
    }

    return recommendations;
  }

  double _calculateOverallScore(Map<MetricType, double> performanceScores) {
    if (performanceScores.isEmpty) return 0.0;

    // Weighted average based on metric importance
    double totalScore = 0.0;
    double totalWeight = 0.0;

    for (final entry in performanceScores.entries) {
      final weight = _getMetricWeight(entry.key);
      totalScore += entry.value * weight;
      totalWeight += weight;
    }

    return totalWeight > 0 ? totalScore / totalWeight : 0.0;
  }

  double _getMetricPriorityScore(KitchenMetric metric) {
    // Calculate priority based on business impact
    final baseScore = switch (metric.type) {
      MetricType.orderCompletionTime => 90.0,
      MetricType.stationEfficiency => 85.0,
      MetricType.staffPerformance => 80.0,
      MetricType.orderAccuracy => 75.0,
      MetricType.wastePercentage => 70.0,
      _ => 60.0,
    };

    // Adjust for target miss severity
    final targetMissPercent = metric.target != null && metric.target! > 0
        ? ((metric.target! - metric.value) / metric.target!) * 100
        : 0.0;
    return baseScore + (targetMissPercent * 0.5);
  }

  String _calculateImpactLevel(KitchenMetric metric) {
    final target = metric.target ?? 0.0;
    final gap = target - metric.value;
    final gapPercent = target > 0 ? (gap / target) * 100 : 0.0;

    if (gapPercent > 30) return 'High';
    if (gapPercent > 15) return 'Medium';
    return 'Low';
  }

  List<String> _getRecommendedActions(KitchenMetric metric) {
    return switch (metric.type) {
      MetricType.orderCompletionTime => [
        'Optimize station workflow and equipment layout',
        'Review staffing levels during peak hours',
        'Implement batch processing for similar orders',
      ],
      MetricType.staffPerformance => [
        'Review recipe preparation steps',
        'Train staff on efficient cooking techniques',
        'Check equipment performance and maintenance',
      ],
      MetricType.orderAccuracy => [
        'Implement quality control checkpoints',
        'Provide additional training to kitchen staff',
        'Review ingredient sourcing and storage',
      ],
      MetricType.stationEfficiency => [
        'Analyze workflow bottlenecks',
        'Optimize mise en place procedures',
        'Implement lean kitchen principles',
      ],
      MetricType.wastePercentage => [
        'Implement better portion control',
        'Review inventory management practices',
        'Train staff on waste reduction techniques',
      ],
      _ => [
        'Monitor performance regularly',
        'Implement best practices for kitchen operations',
      ],
    };
  }

  String _getEstimatedTimeframe(KitchenMetric metric) {
    return switch (metric.type) {
      MetricType.orderCompletionTime => '2-4 weeks',
      MetricType.staffPerformance => '1-2 weeks',
      MetricType.orderAccuracy => '3-6 weeks',
      MetricType.stationEfficiency => '2-4 weeks',
      MetricType.wastePercentage => '1-3 weeks',
      _ => '2-3 weeks',
    };
  }

  List<String> _getTopMetrics(List<KitchenMetric> metrics) {
    final meetingTarget = metrics.where((m) => m.meetsTarget).toList();
    meetingTarget.sort((a, b) => b.value.compareTo(a.value));

    return meetingTarget.take(3).map((m) => m.type.name).toList();
  }

  List<String> _getImprovementAreas(List<KitchenMetric> metrics) {
    final needingImprovement = metrics.where((m) => !m.meetsTarget).toList();
    needingImprovement.sort((a, b) {
      final aTarget = a.target ?? 1.0;
      final bTarget = b.target ?? 1.0;
      final aGap = (aTarget - a.value) / aTarget;
      final bGap = (bTarget - b.value) / bTarget;
      return bGap.compareTo(aGap);
    });

    return needingImprovement.take(2).map((m) => m.type.name).toList();
  }

  String _getPerformanceRecommendation(MetricType type, double score) {
    return 'Improve ${type.name} performance (current: ${score.toStringAsFixed(1)}%) by focusing on targeted interventions and staff training.';
  }

  String _getOpportunityRecommendation(ImprovementOpportunity opportunity) {
    return 'Address ${opportunity.metricType.name} gap of ${opportunity.gap.toStringAsFixed(2)} units through ${opportunity.recommendedActions.first.toLowerCase()}.';
  }

  List<String> _getGeneralRecommendations(List<KitchenMetric> metrics) {
    return [
      'Continue monitoring key performance indicators daily',
      'Implement regular team performance reviews',
      'Consider cross-training staff to improve flexibility',
      'Maintain consistent quality standards across all stations',
    ];
  }

  double _getMetricWeight(MetricType type) {
    return switch (type) {
      MetricType.orderCompletionTime => 0.25,
      MetricType.orderAccuracy => 0.25,
      MetricType.staffPerformance => 0.20,
      MetricType.stationEfficiency => 0.20,
      MetricType.wastePercentage => 0.10,
      _ => 0.15,
    };
  }
}

/// Use case for real-time kitchen efficiency monitoring
@injectable
class MonitorKitchenEfficiencyUseCase {
  final AnalyticsRepository _analyticsRepository;
  final StationRepository _stationRepository;

  const MonitorKitchenEfficiencyUseCase({
    required AnalyticsRepository analyticsRepository,
    required StationRepository stationRepository,
  }) : _analyticsRepository = analyticsRepository,
       _stationRepository = stationRepository;

  /// Stream real-time efficiency metrics with alerts
  Stream<Either<Failure, KitchenEfficiencySnapshot>> execute({
    Duration updateInterval = const Duration(minutes: 5),
    double alertThreshold = 70.0,
  }) async* {
    yield* Stream.periodic(updateInterval).asyncExpand((_) async* {
      try {
        // Get current metrics
        final metricsResult = await _analyticsRepository
            .getTopPerformingMetrics();

        yield* metricsResult.fold(
          (failure) async* {
            yield Left(failure);
          },
          (metrics) async* {
            // Calculate current efficiency score
            final efficiencyScore = await _calculateCurrentEfficiencyScore(
              metrics,
            );

            // Get station status
            final stationStatusResult = await _getStationEfficiencyStatus();

            yield* stationStatusResult.fold(
              (failure) async* {
                yield Left(failure);
              },
              (stationStatus) async* {
                // Check for alerts
                final alerts = _generateEfficiencyAlerts(
                  efficiencyScore,
                  stationStatus,
                  alertThreshold,
                );

                final snapshot = KitchenEfficiencySnapshot(
                  timestamp: Time.now(),
                  overallEfficiency: efficiencyScore,
                  stationEfficiencies: stationStatus,
                  alerts: alerts,
                  metrics: metrics,
                );

                yield Right(snapshot);
              },
            );
          },
        );
      } catch (e) {
        yield Left(ServerFailure('Failed to monitor kitchen efficiency: $e'));
      }
    });
  }

  Future<double> _calculateCurrentEfficiencyScore(
    List<KitchenMetric> metrics,
  ) async {
    if (metrics.isEmpty) return 0.0;

    double totalScore = 0.0;
    double totalWeight = 0.0;

    for (final metric in metrics) {
      final weight = _getMetricWeight(metric.type);
      final target = metric.target ?? 0.0;
      final normalizedScore = target > 0 ? (metric.value / target) * 100 : 0.0;
      totalScore += normalizedScore * weight;
      totalWeight += weight;
    }

    return totalWeight > 0 ? totalScore / totalWeight : 0.0;
  }

  Future<Either<Failure, Map<UserId, double>>>
  _getStationEfficiencyStatus() async {
    final stationsResult = await _stationRepository.getActiveStations();

    return stationsResult.fold((failure) => Left(failure), (stations) async {
      final stationEfficiencies = <UserId, double>{};

      for (final station in stations) {
        // Get station-specific metrics
        final stationMetricsResult = await _analyticsRepository
            .getKitchenMetricsByStation(station.id);

        await stationMetricsResult.fold(
          (failure) async {
            stationEfficiencies[station.id] = 0.0;
          },
          (stationMetrics) async {
            final efficiency = stationMetrics.isEmpty
                ? 0.0
                : await _calculateCurrentEfficiencyScore(stationMetrics);
            stationEfficiencies[station.id] = efficiency;
          },
        );
      }

      return Right(stationEfficiencies);
    });
  }

  List<EfficiencyAlert> _generateEfficiencyAlerts(
    double overallEfficiency,
    Map<UserId, double> stationEfficiencies,
    double threshold,
  ) {
    final alerts = <EfficiencyAlert>[];

    // Overall efficiency alert
    if (overallEfficiency < threshold) {
      alerts.add(
        EfficiencyAlert(
          type: AlertType.lowEfficiency,
          severity: _getAlertSeverity(overallEfficiency, threshold),
          message:
              'Overall kitchen efficiency is below threshold: ${overallEfficiency.toStringAsFixed(1)}%',
          stationId: null,
          value: overallEfficiency,
        ),
      );
    }

    // Station-specific alerts
    for (final entry in stationEfficiencies.entries) {
      if (entry.value < threshold) {
        alerts.add(
          EfficiencyAlert(
            type: AlertType.stationUnderperforming,
            severity: _getAlertSeverity(entry.value, threshold),
            message:
                'Station efficiency below threshold: ${entry.value.toStringAsFixed(1)}%',
            stationId: entry.key,
            value: entry.value,
          ),
        );
      }
    }

    return alerts;
  }

  AlertSeverity _getAlertSeverity(double value, double threshold) {
    final percentBelow = ((threshold - value) / threshold) * 100;

    if (percentBelow > 30) return AlertSeverity.critical;
    if (percentBelow > 15) return AlertSeverity.warning;
    return AlertSeverity.info;
  }

  double _getMetricWeight(MetricType type) {
    return switch (type) {
      MetricType.orderCompletionTime => 0.30,
      MetricType.staffPerformance => 0.25,
      MetricType.orderAccuracy => 0.20,
      MetricType.stationEfficiency => 0.15,
      MetricType.wastePercentage => 0.10,
      _ => 0.10,
    };
  }
}

// ======================== Supporting Data Classes ========================

class KitchenPerformanceReport {
  final UserId id;
  final String reportName;
  final Time periodStart;
  final Time periodEnd;
  final Time generatedAt;
  final List<KitchenMetric> metrics;
  final Map<MetricType, double> performanceScores;
  final List<ImprovementOpportunity> improvementOpportunities;
  final List<StationComparison> stationComparisons;
  final TrendAnalysis trendAnalysis;
  final List<String> recommendations;
  final double overallScore;

  KitchenPerformanceReport({
    required this.id,
    required this.reportName,
    required this.periodStart,
    required this.periodEnd,
    required this.generatedAt,
    required this.metrics,
    required this.performanceScores,
    required this.improvementOpportunities,
    required this.stationComparisons,
    required this.trendAnalysis,
    required this.recommendations,
    required this.overallScore,
  });
}

class ImprovementOpportunity {
  final MetricType metricType;
  final double currentValue;
  final double targetValue;
  final double gap;
  final String impactLevel;
  final List<String> recommendedActions;
  final String estimatedTimeframe;
  final UserId? stationId;

  ImprovementOpportunity({
    required this.metricType,
    required this.currentValue,
    required this.targetValue,
    required this.gap,
    required this.impactLevel,
    required this.recommendedActions,
    required this.estimatedTimeframe,
    this.stationId,
  });
}

class StationComparison {
  final UserId stationId;
  final String stationName;
  final double averagePerformance;
  final int metricCount;
  final List<String> topMetrics;
  final List<String> improvementAreas;

  StationComparison({
    required this.stationId,
    required this.stationName,
    required this.averagePerformance,
    required this.metricCount,
    required this.topMetrics,
    required this.improvementAreas,
  });
}

class TrendAnalysis {
  final TrendDirection overallTrend;
  final double trendStrength;
  final Map<MetricType, TrendDirection> metricTrends;
  final Map<String, dynamic> periodComparison;

  TrendAnalysis({
    required this.overallTrend,
    required this.trendStrength,
    required this.metricTrends,
    required this.periodComparison,
  });
}

enum TrendDirection { improving, declining, stable }

class KitchenEfficiencySnapshot {
  final Time timestamp;
  final double overallEfficiency;
  final Map<UserId, double> stationEfficiencies;
  final List<EfficiencyAlert> alerts;
  final List<KitchenMetric> metrics;

  KitchenEfficiencySnapshot({
    required this.timestamp,
    required this.overallEfficiency,
    required this.stationEfficiencies,
    required this.alerts,
    required this.metrics,
  });
}

class EfficiencyAlert {
  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final UserId? stationId;
  final double value;

  EfficiencyAlert({
    required this.type,
    required this.severity,
    required this.message,
    this.stationId,
    required this.value,
  });
}

enum AlertType { lowEfficiency, stationUnderperforming, qualityIssue }

enum AlertSeverity { info, warning, critical }
