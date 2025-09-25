// Cost Analysis Use Cases for Clean Architecture Application Layer
// Comprehensive financial analysis and cost optimization workflows

import 'dart:math' as math;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/cost_tracking.dart';
import '../../../domain/repositories/cost_tracking_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/time.dart';
import '../../../domain/value_objects/money.dart';

/// Use case for comprehensive cost performance analysis
@injectable
class AnalyzeCostPerformanceUseCase {
  final CostTrackingRepository _repository;

  const AnalyzeCostPerformanceUseCase({
    required CostTrackingRepository repository,
  }) : _repository = repository;

  /// Analyzes cost performance and identifies opportunities
  Future<Either<Failure, CostPerformanceAnalysis>> execute({
    required Time startDate,
    required Time endDate,
    UserId? costCenterId,
  }) async {
    try {
      // Get costs for period
      final costResult = await _repository.getCostsByDateRange(
        startDate,
        endDate,
      );

      return await costResult.fold(
        (failure) async => Left(failure),
        (costs) async {
          // Filter by cost center if specified
          final List<Cost> filteredCosts = costCenterId != null
              ? costs.where((cost) => cost.costCenterId == costCenterId).toList()
              : costs;

          // Calculate metrics
          final metrics = await _calculateCostMetrics(filteredCosts);
          
          // Analyze trends
          final trends = _analyzeCostTrends(filteredCosts, startDate, endDate);
          
          // Compare with budget
          final budgetComparison = costCenterId != null
              ? await _compareBudgetPerformance(costCenterId, startDate, endDate)
              : null;
          
          // Identify opportunities
          final opportunities = _identifyOptimizationOpportunities(
            filteredCosts,
            metrics,
          );

          return Right(CostPerformanceAnalysis(
            periodStart: startDate,
            periodEnd: endDate,
            costCenterId: costCenterId,
            totalCosts: _calculateTotalCosts(filteredCosts),
            costsByType: _groupCostsByType(filteredCosts),
            costsByCategory: _groupCostsByCategory(filteredCosts),
            metrics: metrics,
            trends: trends,
            budgetComparison: budgetComparison,
            optimizationOpportunities: opportunities,
            generatedAt: Time.now(),
          ));
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to analyze cost performance: $e'));
    }
  }

  /// Calculate comprehensive cost metrics
  Future<CostMetrics> _calculateCostMetrics(List<Cost> costs) async {
    if (costs.isEmpty) {
      return CostMetrics(
        totalCosts: 0.0,
        averageCostPerEntry: 0.0,
        highestCostType: null,
        costsByType: {},
        costsByCategory: {},
        costPerDay: 0.0,
        totalEntries: 0,
      );
    }

    final totalCosts = costs.fold(0.0, (sum, cost) => sum + cost.amount.amount);
    final averageCost = totalCosts / costs.length;

    // Group by type
    final costsByType = <CostType, double>{};
    for (final cost in costs) {
      costsByType[cost.type] = 
          (costsByType[cost.type] ?? 0.0) + cost.amount.amount;
    }

    // Group by category
    final costsByCategory = <CostCategory, double>{};
    for (final cost in costs) {
      costsByCategory[cost.category] = 
          (costsByCategory[cost.category] ?? 0.0) + cost.amount.amount;
    }

    // Find highest cost type
    final highestCostType = costsByType.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Calculate daily average based on date range
    final dateRange = costs.map((c) => c.incurredDate.dateTime).toList()
      ..sort();
    final daySpan = dateRange.isEmpty 
        ? 1 
        : dateRange.last.difference(dateRange.first).inDays + 1;
    final costPerDay = totalCosts / daySpan;

    return CostMetrics(
      totalCosts: totalCosts,
      averageCostPerEntry: averageCost,
      highestCostType: highestCostType,
      costsByType: costsByType,
      costsByCategory: costsByCategory,
      costPerDay: costPerDay,
      totalEntries: costs.length,
    );
  }

  /// Analyze cost trends over the period
  CostTrendAnalysis _analyzeCostTrends(
    List<Cost> costs,
    Time startDate,
    Time endDate,
  ) {
    if (costs.isEmpty) {
      return CostTrendAnalysis(
        trendDirection: TrendDirection.stable,
        percentageChange: 0.0,
        dailyAverages: {},
        projectedNextPeriod: 0.0,
      );
    }

    // Create daily totals
    final dailyTotals = <DateTime, double>{};
    for (final cost in costs) {
      final date = DateTime(
        cost.incurredDate.dateTime.year,
        cost.incurredDate.dateTime.month,
        cost.incurredDate.dateTime.day,
      );
      dailyTotals[date] = (dailyTotals[date] ?? 0.0) + cost.amount.amount;
    }

    final sortedDates = dailyTotals.keys.toList()..sort();
    if (sortedDates.length < 2) {
      return CostTrendAnalysis(
        trendDirection: TrendDirection.stable,
        percentageChange: 0.0,
        dailyAverages: dailyTotals,
        projectedNextPeriod: dailyTotals.values.first,
      );
    }

    // Calculate trend
    final firstHalf = sortedDates.take(sortedDates.length ~/ 2);
    final secondHalf = sortedDates.skip(sortedDates.length ~/ 2);

    final firstHalfAvg = firstHalf
        .map((date) => dailyTotals[date] ?? 0.0)
        .reduce((a, b) => a + b) / firstHalf.length;
    
    final secondHalfAvg = secondHalf
        .map((date) => dailyTotals[date] ?? 0.0)
        .reduce((a, b) => a + b) / secondHalf.length;

    final percentageChange = firstHalfAvg != 0 
        ? ((secondHalfAvg - firstHalfAvg) / firstHalfAvg) * 100
        : 0.0;

    final trendDirection = percentageChange > 5
        ? TrendDirection.increasing
        : percentageChange < -5
            ? TrendDirection.decreasing
            : TrendDirection.stable;

    return CostTrendAnalysis(
      trendDirection: trendDirection,
      percentageChange: percentageChange,
      dailyAverages: dailyTotals,
      projectedNextPeriod: secondHalfAvg,
    );
  }

  /// Compare actual costs with budget
  Future<BudgetComparison?> _compareBudgetPerformance(
    UserId costCenterId,
    Time startDate,
    Time endDate,
  ) async {
    try {
      final budgetVarianceResult = await _repository.calculateBudgetVariance(
        costCenterId,
        startDate,
        endDate,
      );

      return budgetVarianceResult.fold(
        (failure) => null,
        (budgetData) {
          if (budgetData.isEmpty) return null;

          // Simple budget comparison based on available data
          final totalVariance = budgetData.values.fold(0.0, (sum, variance) => sum + variance);
          
          return BudgetComparison(
            budgetedAmount: 0.0, // Would need budget repository to get actual budget
            actualAmount: totalVariance.abs(), // Using variance as proxy
            variance: totalVariance,
            variancePercentage: 0.0, // Cannot calculate without budget amount
            isOverBudget: totalVariance > 0,
          );
        },
      );
    } catch (e) {
      return null;
    }
  }

  /// Identify cost optimization opportunities
  List<OptimizationOpportunity> _identifyOptimizationOpportunities(
    List<Cost> costs,
    CostMetrics metrics,
  ) {
    final opportunities = <OptimizationOpportunity>[];

    // High cost items opportunity
    if (metrics.totalCosts > 0) {
      final highCostThreshold = metrics.averageCostPerEntry * 2;
      final highCostItems = costs
          .where((cost) => cost.amount.amount > highCostThreshold)
          .length;

      if (highCostItems > 0) {
        opportunities.add(OptimizationOpportunity(
          title: 'Review High-Cost Items',
          description: 'Found $highCostItems items above average cost threshold',
          potentialSavings: (highCostThreshold * highCostItems * 0.15), // Estimate 15% savings
          priority: OpportunityPriority.high,
          effort: ImplementationEffort.medium,
          type: OptimizationType.highCostReduction,
        ));
      }
    }

    // Cost type concentration opportunity
    final topCostType = metrics.highestCostType;
    if (topCostType != null) {
      final topTypeAmount = metrics.costsByType[topCostType] ?? 0.0;
      final concentration = metrics.totalCosts > 0 
          ? (topTypeAmount / metrics.totalCosts) * 100 
          : 0.0;

      if (concentration > 40) {
        opportunities.add(OptimizationOpportunity(
          title: 'Diversify Cost Distribution',
          description: '${topCostType.name} costs represent ${concentration.toStringAsFixed(1)}% of total',
          potentialSavings: topTypeAmount * 0.10, // Estimate 10% savings
          priority: OpportunityPriority.medium,
          effort: ImplementationEffort.high,
          type: OptimizationType.processOptimization,
        ));
      }
    }

    return opportunities;
  }

  /// Calculate total costs from cost list
  double _calculateTotalCosts(List<Cost> costs) {
    return costs.fold(0.0, (sum, cost) => sum + cost.amount.amount);
  }

  /// Group costs by type
  Map<CostType, double> _groupCostsByType(List<Cost> costs) {
    final grouped = <CostType, double>{};
    for (final cost in costs) {
      grouped[cost.type] = (grouped[cost.type] ?? 0.0) + cost.amount.amount;
    }
    return grouped;
  }

  /// Group costs by category
  Map<CostCategory, double> _groupCostsByCategory(List<Cost> costs) {
    final grouped = <CostCategory, double>{};
    for (final cost in costs) {
      grouped[cost.category] = (grouped[cost.category] ?? 0.0) + cost.amount.amount;
    }
    return grouped;
  }
}

/// Use case for tracking cost trends over time
@injectable
class TrackCostTrendsUseCase {
  final CostTrackingRepository _repository;

  const TrackCostTrendsUseCase({required CostTrackingRepository repository})
      : _repository = repository;

  /// Generate trend analysis for costs
  Future<Either<Failure, CostTrendReport>> execute({
    required Time startDate,
    required Time endDate,
    Duration? interval,
  }) async {
    try {
      final costsResult = await _repository.getCostsByDateRange(startDate, endDate);

      return await costsResult.fold(
        (failure) async => Left(failure),
        (costs) async {
          final trendsResult = await _repository.getCostTrends(
            startDate,
            endDate,
            interval ?? const Duration(days: 1),
          );

          return trendsResult.fold(
            (failure) => Left(failure),
            (trends) {
              final analysis = _analyzeTrendData(trends, costs);
              
              return Right(CostTrendReport(
                periodStart: startDate,
                periodEnd: endDate,
                interval: interval ?? const Duration(days: 1),
                trends: trends,
                analysis: analysis,
                totalDataPoints: trends.length,
                generatedAt: Time.now(),
              ));
            },
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to track cost trends: $e'));
    }
  }

  /// Analyze trend data for insights
  TrendAnalysis _analyzeTrendData(Map<Time, Money> trends, List<Cost> costs) {
    if (trends.isEmpty) {
      return TrendAnalysis(
        averageChange: 0.0,
        volatility: 0.0,
        peaks: [],
        valleys: [],
        overallDirection: TrendDirection.stable,
      );
    }

    final values = trends.values.map((money) => money.amount).toList();
    final sortedTimes = trends.keys.toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // Calculate changes between periods
    final changes = <double>[];
    for (int i = 1; i < values.length; i++) {
      if (values[i - 1] != 0) {
        changes.add((values[i] - values[i - 1]) / values[i - 1] * 100);
      }
    }

    final averageChange = changes.isEmpty ? 0.0 : changes.reduce((a, b) => a + b) / changes.length;
    
    // Calculate volatility (standard deviation of changes)
    final variance = changes.isEmpty ? 0.0 : changes
        .map((change) => (change - averageChange) * (change - averageChange))
        .reduce((a, b) => a + b) / changes.length;
    final volatility = variance.isFinite ? variance.sqrt() : 0.0;

    // Find peaks and valleys (simple local maxima/minima)
    final peaks = <Time>[];
    final valleys = <Time>[];
    
    for (int i = 1; i < values.length - 1; i++) {
      if (values[i] > values[i - 1] && values[i] > values[i + 1]) {
        peaks.add(sortedTimes[i]);
      } else if (values[i] < values[i - 1] && values[i] < values[i + 1]) {
        valleys.add(sortedTimes[i]);
      }
    }

    final overallDirection = averageChange > 2
        ? TrendDirection.increasing
        : averageChange < -2
            ? TrendDirection.decreasing
            : TrendDirection.stable;

    return TrendAnalysis(
      averageChange: averageChange,
      volatility: volatility,
      peaks: peaks,
      valleys: valleys,
      overallDirection: overallDirection,
    );
  }
}

// Domain Models for Cost Analysis

/// Comprehensive cost performance analysis result
class CostPerformanceAnalysis {
  final Time periodStart;
  final Time periodEnd;
  final UserId? costCenterId;
  final double totalCosts;
  final Map<CostType, double> costsByType;
  final Map<CostCategory, double> costsByCategory;
  final CostMetrics metrics;
  final CostTrendAnalysis trends;
  final BudgetComparison? budgetComparison;
  final List<OptimizationOpportunity> optimizationOpportunities;
  final Time generatedAt;

  const CostPerformanceAnalysis({
    required this.periodStart,
    required this.periodEnd,
    this.costCenterId,
    required this.totalCosts,
    required this.costsByType,
    required this.costsByCategory,
    required this.metrics,
    required this.trends,
    this.budgetComparison,
    required this.optimizationOpportunities,
    required this.generatedAt,
  });
}

/// Cost metrics for analysis
class CostMetrics {
  final double totalCosts;
  final double averageCostPerEntry;
  final CostType? highestCostType;
  final Map<CostType, double> costsByType;
  final Map<CostCategory, double> costsByCategory;
  final double costPerDay;
  final int totalEntries;

  const CostMetrics({
    required this.totalCosts,
    required this.averageCostPerEntry,
    required this.highestCostType,
    required this.costsByType,
    required this.costsByCategory,
    required this.costPerDay,
    required this.totalEntries,
  });
}

/// Cost trend analysis
class CostTrendAnalysis {
  final TrendDirection trendDirection;
  final double percentageChange;
  final Map<DateTime, double> dailyAverages;
  final double projectedNextPeriod;

  const CostTrendAnalysis({
    required this.trendDirection,
    required this.percentageChange,
    required this.dailyAverages,
    required this.projectedNextPeriod,
  });
}

/// Budget comparison analysis
class BudgetComparison {
  final double budgetedAmount;
  final double actualAmount;
  final double variance;
  final double variancePercentage;
  final bool isOverBudget;

  const BudgetComparison({
    required this.budgetedAmount,
    required this.actualAmount,
    required this.variance,
    required this.variancePercentage,
    required this.isOverBudget,
  });
}

/// Cost optimization opportunity
class OptimizationOpportunity {
  final String title;
  final String description;
  final double potentialSavings;
  final OpportunityPriority priority;
  final ImplementationEffort effort;
  final OptimizationType type;

  const OptimizationOpportunity({
    required this.title,
    required this.description,
    required this.potentialSavings,
    required this.priority,
    required this.effort,
    required this.type,
  });
}

/// Cost trend report
class CostTrendReport {
  final Time periodStart;
  final Time periodEnd;
  final Duration interval;
  final Map<Time, Money> trends;
  final TrendAnalysis analysis;
  final int totalDataPoints;
  final Time generatedAt;

  const CostTrendReport({
    required this.periodStart,
    required this.periodEnd,
    required this.interval,
    required this.trends,
    required this.analysis,
    required this.totalDataPoints,
    required this.generatedAt,
  });
}

/// Detailed trend analysis
class TrendAnalysis {
  final double averageChange;
  final double volatility;
  final List<Time> peaks;
  final List<Time> valleys;
  final TrendDirection overallDirection;

  const TrendAnalysis({
    required this.averageChange,
    required this.volatility,
    required this.peaks,
    required this.valleys,
    required this.overallDirection,
  });
}

// Enums
enum TrendDirection { increasing, decreasing, stable }
enum OptimizationType { highCostReduction, processOptimization, wasteReduction }
enum OpportunityPriority { low, medium, high }
enum ImplementationEffort { low, medium, high }

// Extensions for better number handling
extension on double {
  double sqrt() => math.sqrt(this);
}

