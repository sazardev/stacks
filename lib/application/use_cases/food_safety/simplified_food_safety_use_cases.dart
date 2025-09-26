// Simplified Food Safety Use Cases for Clean Architecture Application Layer
// Focused on working with existing domain entities and repository methods

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/food_safety.dart';
import '../../../domain/repositories/food_safety_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/time.dart';

/// Use case for monitoring temperature compliance across all locations
@injectable
class MonitorTemperatureComplianceUseCase {
  final FoodSafetyRepository _foodSafetyRepository;
  final UserRepository _userRepository;

  const MonitorTemperatureComplianceUseCase({
    required FoodSafetyRepository foodSafetyRepository,
    required UserRepository userRepository,
  }) : _foodSafetyRepository = foodSafetyRepository,
       _userRepository = userRepository;

  /// Generate comprehensive temperature compliance report
  Future<Either<Failure, TemperatureComplianceReport>> execute({
    required Time startDate,
    required Time endDate,
    TemperatureLocation? specificLocation,
    bool includeCorrectiveActions = true,
  }) async {
    try {
      // 1. Get all temperature logs for the period
      final temperatureLogs = await _foodSafetyRepository
          .getTemperatureLogsByDateRange(startDate, endDate);

      // Filter by location if specified
      final filteredLogs = specificLocation != null
          ? temperatureLogs
                .where((log) => log.location == specificLocation)
                .toList()
          : temperatureLogs;

      // 2. Get logs outside safe range
      final violatingLogs = await _foodSafetyRepository
          .getTemperatureLogsOutsideSafeRange();
      final periodViolatingLogs = violatingLogs
          .where((log) => _isWithinPeriod(log.recordedAt, startDate, endDate))
          .toList();

      // 3. Calculate compliance metrics
      final complianceMetrics = _calculateComplianceMetrics(
        filteredLogs,
        periodViolatingLogs,
      );

      // 4. Analyze by location
      final locationAnalysis = _analyzeByLocation(filteredLogs);

      // 5. Get corrective actions if requested
      final correctiveActions = includeCorrectiveActions
          ? await _getCorrectiveActions(filteredLogs)
          : <String>[];

      // 6. Generate recommendations
      final recommendations = _generateRecommendations(
        complianceMetrics,
        locationAnalysis,
      );

      final report = TemperatureComplianceReport(
        id: UserId.generate(),
        periodStart: startDate,
        periodEnd: endDate,
        totalLogs: filteredLogs.length,
        violatingLogs: periodViolatingLogs.length,
        complianceRate: complianceMetrics.overallComplianceRate,
        locationAnalysis: locationAnalysis,
        correctiveActions: correctiveActions,
        recommendations: recommendations,
        criticalLocations: _identifyCriticalLocations(locationAnalysis),
        generatedAt: Time.now(),
      );

      return Right(report);
    } catch (e) {
      return Left(
        ServerFailure('Failed to generate temperature compliance report: $e'),
      );
    }
  }

  bool _isWithinPeriod(Time logTime, Time startDate, Time endDate) {
    return logTime.dateTime.isAfter(startDate.dateTime) &&
        logTime.dateTime.isBefore(endDate.dateTime);
  }

  TemperatureComplianceMetrics _calculateComplianceMetrics(
    List<TemperatureLog> allLogs,
    List<TemperatureLog> violatingLogs,
  ) {
    final totalChecks = allLogs.length;
    final violations = violatingLogs.length;
    final complianceRate = totalChecks > 0
        ? ((totalChecks - violations) / totalChecks) * 100
        : 100.0;

    // Calculate average deviation for violating logs
    final averageDeviation = violatingLogs.isNotEmpty
        ? violatingLogs.fold(0.0, (sum, log) {
                if (log.minSafeTemperature != null &&
                    log.maxSafeTemperature != null) {
                  if (log.temperature < log.minSafeTemperature!) {
                    return sum + (log.minSafeTemperature! - log.temperature);
                  } else if (log.temperature > log.maxSafeTemperature!) {
                    return sum + (log.temperature - log.maxSafeTemperature!);
                  }
                }
                return sum;
              }) /
              violatingLogs.length
        : 0.0;

    // Count critical violations (major temperature deviations)
    final criticalViolations = violatingLogs.where((log) {
      if (log.minSafeTemperature != null && log.maxSafeTemperature != null) {
        final deviation = log.temperature < log.minSafeTemperature!
            ? log.minSafeTemperature! - log.temperature
            : log.temperature > log.maxSafeTemperature!
            ? log.temperature - log.maxSafeTemperature!
            : 0.0;
        return deviation > 10.0; // Critical if more than 10 degrees off
      }
      return false;
    }).length;

    return TemperatureComplianceMetrics(
      overallComplianceRate: complianceRate,
      totalChecks: totalChecks,
      violations: violations,
      criticalViolations: criticalViolations,
      averageDeviation: averageDeviation,
    );
  }

  Map<TemperatureLocation, LocationAnalysis> _analyzeByLocation(
    List<TemperatureLog> logs,
  ) {
    final analysis = <TemperatureLocation, LocationAnalysis>{};

    // Group logs by location
    final logsByLocation = <TemperatureLocation, List<TemperatureLog>>{};
    for (final log in logs) {
      logsByLocation.putIfAbsent(log.location, () => []).add(log);
    }

    // Analyze each location
    for (final entry in logsByLocation.entries) {
      final locationLogs = entry.value;
      final violations = locationLogs
          .where((log) => !log.isWithinSafeRange)
          .length;
      final complianceRate = locationLogs.isNotEmpty
          ? ((locationLogs.length - violations) / locationLogs.length) * 100
          : 100.0;

      // Calculate temperature stability (standard deviation)
      final temperatures = locationLogs.map((log) => log.temperature).toList();
      final meanTemp =
          temperatures.fold(0.0, (a, b) => a + b) / temperatures.length;
      final variance =
          temperatures.fold(0.0, (sum, temp) {
            return sum + ((temp - meanTemp) * (temp - meanTemp));
          }) /
          temperatures.length;
      final standardDeviation = variance > 0
          ? variance
          : 0.0; // Simplified sqrt

      analysis[entry.key] = LocationAnalysis(
        location: entry.key,
        totalLogs: locationLogs.length,
        violations: violations,
        complianceRate: complianceRate,
        averageTemperature: meanTemp,
        temperatureStability: standardDeviation,
        riskLevel: _calculateLocationRiskLevel(complianceRate, violations),
      );
    }

    return analysis;
  }

  Future<List<String>> _getCorrectiveActions(List<TemperatureLog> logs) async {
    final actions = <String>[];

    // Get logs requiring corrective action
    final requiresAction = logs
        .where((log) => log.requiresCorrectiveAction)
        .toList();

    for (final log in requiresAction) {
      if (log.correctiveActionTaken != null) {
        actions.add('${log.location.name}: ${log.correctiveActionTaken}');
      } else {
        actions.add(
          '${log.location.name}: Action required for temperature violation',
        );
      }
    }

    return actions;
  }

  List<String> _generateRecommendations(
    TemperatureComplianceMetrics metrics,
    Map<TemperatureLocation, LocationAnalysis> locationAnalysis,
  ) {
    final recommendations = <String>[];

    // Overall compliance recommendations
    if (metrics.overallComplianceRate < 95.0) {
      recommendations.add(
        'Improve overall temperature monitoring - compliance rate is ${metrics.overallComplianceRate.toStringAsFixed(1)}%',
      );
    }

    if (metrics.criticalViolations > 0) {
      recommendations.add(
        'Address ${metrics.criticalViolations} critical temperature violations immediately',
      );
    }

    // Location-specific recommendations
    final highRiskLocations = locationAnalysis.entries
        .where((entry) => entry.value.riskLevel == RiskLevel.high)
        .toList();

    if (highRiskLocations.isNotEmpty) {
      for (final location in highRiskLocations) {
        recommendations.add(
          'High priority: Review ${location.key.name} temperature control systems',
        );
      }
    }

    // Temperature stability recommendations
    final unstableLocations = locationAnalysis.entries
        .where((entry) => entry.value.temperatureStability > 5.0)
        .toList();

    if (unstableLocations.isNotEmpty) {
      for (final location in unstableLocations) {
        recommendations.add(
          'Temperature instability detected at ${location.key.name} - check equipment calibration',
        );
      }
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        'Temperature compliance is excellent - maintain current monitoring practices',
      );
    }

    return recommendations;
  }

  List<TemperatureLocation> _identifyCriticalLocations(
    Map<TemperatureLocation, LocationAnalysis> locationAnalysis,
  ) {
    return locationAnalysis.entries
        .where(
          (entry) =>
              entry.value.riskLevel == RiskLevel.high ||
              entry.value.complianceRate < 90.0,
        )
        .map((entry) => entry.key)
        .toList();
  }

  RiskLevel _calculateLocationRiskLevel(double complianceRate, int violations) {
    if (complianceRate < 80.0 || violations > 10) return RiskLevel.high;
    if (complianceRate < 95.0 || violations > 3) return RiskLevel.medium;
    return RiskLevel.low;
  }
}

/// Use case for managing food safety violations and corrective actions
@injectable
class ManageFoodSafetyViolationsUseCase {
  final FoodSafetyRepository _foodSafetyRepository;
  final UserRepository _userRepository;

  const ManageFoodSafetyViolationsUseCase({
    required FoodSafetyRepository foodSafetyRepository,
    required UserRepository userRepository,
  }) : _foodSafetyRepository = foodSafetyRepository,
       _userRepository = userRepository;

  /// Create and manage a food safety violation with automated workflow
  Future<Either<Failure, FoodSafetyViolation>> reportViolation({
    required ViolationType violationType,
    required ViolationSeverity severity,
    required String description,
    required UserId reportedBy,
    TemperatureLocation? location,
    String? equipmentId,
    List<String>? photosUrls,
  }) async {
    try {
      // 1. Create violation record
      final violation = FoodSafetyViolation(
        id: UserId.generate(),
        type: violationType,
        severity: severity,
        description: description,
        reportedBy: reportedBy,
        reportedAt: Time.now(),
        location: location,
      );

      // 2. Save violation
      final createdViolation = await _foodSafetyRepository
          .createFoodSafetyViolation(violation);

      // 3. Auto-assign corrective action based on severity
      if (severity == ViolationSeverity.critical ||
          severity == ViolationSeverity.emergency) {
        await _autoAssignCorrectiveAction(createdViolation);
      }

      // 4. Generate violation notification workflow
      await _triggerNotificationWorkflow(createdViolation);

      return Right(createdViolation);
    } catch (e) {
      return Left(ServerFailure('Failed to report food safety violation: $e'));
    }
  }

  /// Get comprehensive violation analysis and trends
  Future<Either<Failure, ViolationAnalysisReport>> analyzeViolations({
    required Time startDate,
    required Time endDate,
    ViolationType? specificType,
    ViolationSeverity? minimumSeverity,
  }) async {
    try {
      // 1. Get violations for the period
      final violations = await _foodSafetyRepository.getViolationsByDateRange(
        startDate,
        endDate,
      );

      // 2. Filter by criteria
      var filteredViolations = violations;

      if (specificType != null) {
        filteredViolations = filteredViolations
            .where((v) => v.type == specificType)
            .toList();
      }

      if (minimumSeverity != null) {
        filteredViolations = filteredViolations
            .where(
              (v) =>
                  _getSeverityPriority(v.severity) >=
                  _getSeverityPriority(minimumSeverity),
            )
            .toList();
      }

      // 3. Calculate violation trends
      final trends = _calculateViolationTrends(
        filteredViolations,
        startDate,
        endDate,
      );

      // 4. Analyze by severity
      final severityAnalysis = _analyzeBySeverity(filteredViolations);

      // 5. Analyze by type
      final typeAnalysis = _analyzeByType(filteredViolations);

      // 6. Calculate resolution metrics
      final resolutionMetrics = _calculateResolutionMetrics(filteredViolations);

      // 7. Generate action items
      final actionItems = _generateActionItems(
        filteredViolations,
        trends,
        resolutionMetrics,
      );

      final report = ViolationAnalysisReport(
        id: UserId.generate(),
        periodStart: startDate,
        periodEnd: endDate,
        totalViolations: filteredViolations.length,
        trends: trends,
        severityAnalysis: severityAnalysis,
        typeAnalysis: typeAnalysis,
        resolutionMetrics: resolutionMetrics,
        actionItems: actionItems,
        generatedAt: Time.now(),
      );

      return Right(report);
    } catch (e) {
      return Left(ServerFailure('Failed to analyze violations: $e'));
    }
  }

  Future<void> _autoAssignCorrectiveAction(
    FoodSafetyViolation violation,
  ) async {
    // Log corrective action requirement (would integrate with task management system)
    print(
      'Corrective action required for ${violation.severity.name} violation: ${violation.description}',
    );

    // In a real implementation, this would create a task in a task management system
    // or send notifications to relevant personnel
  }

  Future<void> _triggerNotificationWorkflow(
    FoodSafetyViolation violation,
  ) async {
    // Implementation would integrate with notification system
    // For now, just log the need for notification
    print(
      'Notification required for ${violation.severity.name} violation: ${violation.description}',
    );
  }

  ViolationTrends _calculateViolationTrends(
    List<FoodSafetyViolation> violations,
    Time startDate,
    Time endDate,
  ) {
    // Calculate daily violation counts
    final dailyCounts = <DateTime, int>{};
    final periodDays = endDate.dateTime.difference(startDate.dateTime).inDays;

    for (int i = 0; i <= periodDays; i++) {
      final date = startDate.dateTime.add(Duration(days: i));
      final dayKey = DateTime(date.year, date.month, date.day);
      dailyCounts[dayKey] = 0;
    }

    for (final violation in violations) {
      final dayKey = DateTime(
        violation.reportedAt.dateTime.year,
        violation.reportedAt.dateTime.month,
        violation.reportedAt.dateTime.day,
      );
      dailyCounts[dayKey] = (dailyCounts[dayKey] ?? 0) + 1;
    }

    // Calculate trend direction
    final firstHalf = dailyCounts.values.take(dailyCounts.length ~/ 2).toList();
    final secondHalf = dailyCounts.values
        .skip(dailyCounts.length ~/ 2)
        .toList();

    final firstHalfAvg = firstHalf.isNotEmpty
        ? firstHalf.reduce((a, b) => a + b) / firstHalf.length
        : 0.0;
    final secondHalfAvg = secondHalf.isNotEmpty
        ? secondHalf.reduce((a, b) => a + b) / secondHalf.length
        : 0.0;

    final trendDirection = secondHalfAvg > firstHalfAvg + 0.5
        ? TrendDirection.increasing
        : secondHalfAvg < firstHalfAvg - 0.5
        ? TrendDirection.decreasing
        : TrendDirection.stable;

    return ViolationTrends(
      trendDirection: trendDirection,
      dailyCounts: dailyCounts,
      averagePerDay: violations.length / (periodDays + 1),
      peakDay: dailyCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key,
    );
  }

  Map<ViolationSeverity, int> _analyzeBySeverity(
    List<FoodSafetyViolation> violations,
  ) {
    final analysis = <ViolationSeverity, int>{};

    for (final severity in ViolationSeverity.values) {
      analysis[severity] = violations
          .where((v) => v.severity == severity)
          .length;
    }

    return analysis;
  }

  Map<ViolationType, int> _analyzeByType(List<FoodSafetyViolation> violations) {
    final analysis = <ViolationType, int>{};

    for (final type in ViolationType.values) {
      analysis[type] = violations.where((v) => v.type == type).length;
    }

    return analysis;
  }

  ViolationResolutionMetrics _calculateResolutionMetrics(
    List<FoodSafetyViolation> violations,
  ) {
    final resolvedViolations = violations.where((v) => v.isResolved).toList();
    final resolutionRate = violations.isNotEmpty
        ? (resolvedViolations.length / violations.length) * 100
        : 0.0;

    // Calculate average resolution time
    final resolutionTimes = resolvedViolations
        .where((v) => v.resolvedAt != null)
        .map((v) => v.resolvedAt!.dateTime.difference(v.reportedAt.dateTime))
        .toList();

    final averageResolutionHours = resolutionTimes.isNotEmpty
        ? resolutionTimes
                  .fold(Duration.zero, (sum, duration) => sum + duration)
                  .inHours /
              resolutionTimes.length
        : 0.0;

    return ViolationResolutionMetrics(
      totalViolations: violations.length,
      resolvedCount: resolvedViolations.length,
      resolutionRate: resolutionRate,
      averageResolutionHours: averageResolutionHours,
      overdueCount: violations
          .where((v) => !v.isResolved && _isOverdue(v))
          .length,
    );
  }

  List<String> _generateActionItems(
    List<FoodSafetyViolation> violations,
    ViolationTrends trends,
    ViolationResolutionMetrics metrics,
  ) {
    final actions = <String>[];

    // Trend-based actions
    if (trends.trendDirection == TrendDirection.increasing) {
      actions.add(
        'URGENT: Violation trend is increasing - implement preventive measures',
      );
    }

    // Resolution-based actions
    if (metrics.resolutionRate < 80.0) {
      actions.add(
        'Improve violation resolution process - current rate: ${metrics.resolutionRate.toStringAsFixed(1)}%',
      );
    }

    if (metrics.overdueCount > 0) {
      actions.add(
        'Address ${metrics.overdueCount} overdue violations immediately',
      );
    }

    // Critical violations
    final criticalUnresolved = violations
        .where((v) => v.severity == ViolationSeverity.critical && !v.isResolved)
        .length;

    if (criticalUnresolved > 0) {
      actions.add(
        'CRITICAL: $criticalUnresolved unresolved critical violations require immediate attention',
      );
    }

    return actions;
  }

  int _getSeverityPriority(ViolationSeverity severity) {
    return switch (severity) {
      ViolationSeverity.emergency => 4,
      ViolationSeverity.critical => 3,
      ViolationSeverity.major => 2,
      ViolationSeverity.minor => 1,
    };
  }

  bool _isOverdue(FoodSafetyViolation violation) {
    final maxHours = switch (violation.severity) {
      ViolationSeverity.emergency => 1,
      ViolationSeverity.critical => 4,
      ViolationSeverity.major => 24,
      ViolationSeverity.minor => 72,
    };

    final deadline = violation.reportedAt.add(Duration(hours: maxHours));
    return Time.now().dateTime.isAfter(deadline.dateTime);
  }
}

// ======================== Supporting Data Classes ========================

enum RiskLevel { low, medium, high }

enum TrendDirection { increasing, decreasing, stable }

class TemperatureComplianceReport {
  final UserId id;
  final Time periodStart;
  final Time periodEnd;
  final int totalLogs;
  final int violatingLogs;
  final double complianceRate;
  final Map<TemperatureLocation, LocationAnalysis> locationAnalysis;
  final List<String> correctiveActions;
  final List<String> recommendations;
  final List<TemperatureLocation> criticalLocations;
  final Time generatedAt;

  TemperatureComplianceReport({
    required this.id,
    required this.periodStart,
    required this.periodEnd,
    required this.totalLogs,
    required this.violatingLogs,
    required this.complianceRate,
    required this.locationAnalysis,
    required this.correctiveActions,
    required this.recommendations,
    required this.criticalLocations,
    required this.generatedAt,
  });
}

class TemperatureComplianceMetrics {
  final double overallComplianceRate;
  final int totalChecks;
  final int violations;
  final int criticalViolations;
  final double averageDeviation;

  TemperatureComplianceMetrics({
    required this.overallComplianceRate,
    required this.totalChecks,
    required this.violations,
    required this.criticalViolations,
    required this.averageDeviation,
  });
}

class LocationAnalysis {
  final TemperatureLocation location;
  final int totalLogs;
  final int violations;
  final double complianceRate;
  final double averageTemperature;
  final double temperatureStability;
  final RiskLevel riskLevel;

  LocationAnalysis({
    required this.location,
    required this.totalLogs,
    required this.violations,
    required this.complianceRate,
    required this.averageTemperature,
    required this.temperatureStability,
    required this.riskLevel,
  });
}

class ViolationAnalysisReport {
  final UserId id;
  final Time periodStart;
  final Time periodEnd;
  final int totalViolations;
  final ViolationTrends trends;
  final Map<ViolationSeverity, int> severityAnalysis;
  final Map<ViolationType, int> typeAnalysis;
  final ViolationResolutionMetrics resolutionMetrics;
  final List<String> actionItems;
  final Time generatedAt;

  ViolationAnalysisReport({
    required this.id,
    required this.periodStart,
    required this.periodEnd,
    required this.totalViolations,
    required this.trends,
    required this.severityAnalysis,
    required this.typeAnalysis,
    required this.resolutionMetrics,
    required this.actionItems,
    required this.generatedAt,
  });
}

class ViolationTrends {
  final TrendDirection trendDirection;
  final Map<DateTime, int> dailyCounts;
  final double averagePerDay;
  final DateTime peakDay;

  ViolationTrends({
    required this.trendDirection,
    required this.dailyCounts,
    required this.averagePerDay,
    required this.peakDay,
  });
}

class ViolationResolutionMetrics {
  final int totalViolations;
  final int resolvedCount;
  final double resolutionRate;
  final double averageResolutionHours;
  final int overdueCount;

  ViolationResolutionMetrics({
    required this.totalViolations,
    required this.resolvedCount,
    required this.resolutionRate,
    required this.averageResolutionHours,
    required this.overdueCount,
  });
}
