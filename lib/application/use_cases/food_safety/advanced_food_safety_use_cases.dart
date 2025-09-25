// Advanced Food Safety Use Cases for Clean Architecture Application Layer
// Comprehensive coverage for food safety compliance, temperature monitoring, and HACCP management

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/food_safety.dart';
import '../../../domain/repositories/food_safety_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/time.dart';

/// Advanced use case for managing comprehensive food safety compliance programs
@injectable
class ManageFoodSafetyComplianceProgramUseCase {
  final FoodSafetyRepository _foodSafetyRepository;
  final UserRepository _userRepository;

  const ManageFoodSafetyComplianceProgramUseCase({
    required FoodSafetyRepository foodSafetyRepository,
    required UserRepository userRepository,
  }) : _foodSafetyRepository = foodSafetyRepository,
       _userRepository = userRepository;

  /// Execute comprehensive food safety compliance assessment and management
  Future<Either<Failure, Map<String, dynamic>>> execute({
    required Time assessmentPeriodStart,
    required Time assessmentPeriodEnd,
    List<CCPType>? focusAreas,
    bool generateCorrectiveActions = true,
  }) async {
    try {
      // 1. Gather all food safety data for the period
      final temperatureLogs = await _foodSafetyRepository
          .getTemperatureLogsByDateRange(
            assessmentPeriodStart,
            assessmentPeriodEnd,
          );

      // 2. Get violations for the period
      final violations = await _foodSafetyRepository.getViolationsByDateRange(
        assessmentPeriodStart,
        assessmentPeriodEnd,
      );

      // 3. Get control points
      final controlPoints = await _foodSafetyRepository.getActiveControlPoints();

      // 4. Get audits for the period
      final audits = await _foodSafetyRepository.getAuditsByDateRange(
        assessmentPeriodStart,
        assessmentPeriodEnd,
      );

      // 5. Calculate compliance metrics
      final complianceMetrics = _calculateComplianceMetrics(
        temperatureLogs,
        violations,
        controlPoints,
        audits,
      );

      // 6. Identify critical control points needing attention
      final criticalControlPoints = await _identifyCriticalControlPoints(
        temperatureLogs,
        violations,
        focusAreas,
      );

      // 7. Generate risk assessment
      final riskAssessment = _generateRiskAssessment(
        violations,
        audits,
      );

      // 8. Create corrective action plan if requested
      final correctiveActions = generateCorrectiveActions
          ? _generateCorrectiveActionPlan(
              violations,
              controlPoints,
            )
          : <String>[];

      // 9. Generate staff compliance tracking
      final staffCompliance = _generateStaffComplianceTracking(
        temperatureLogs,
        violations,
      );

      final result = {
        'id': UserId.generate().value,
        'assessment_period_start': assessmentPeriodStart.millisecondsSinceEpoch,
        'assessment_period_end': assessmentPeriodEnd.millisecondsSinceEpoch,
        'overall_compliance_score': complianceMetrics['overall_score'],
        'compliance_metrics': complianceMetrics,
        'critical_control_points': criticalControlPoints,
        'risk_assessment': riskAssessment,
        'corrective_actions': correctiveActions,
        'staff_compliance': staffCompliance,
        'temperature_log_count': temperatureLogs.length,
        'violation_count': violations.length,
        'audit_count': audits.length,
        'generated_at': Time.now().millisecondsSinceEpoch,
      };

      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Failed to execute compliance assessment: $e'));
    }
  }

  /// Calculate comprehensive compliance metrics
  Map<String, dynamic> _calculateComplianceMetrics(
    List<TemperatureLog> temperatureLogs,
    List<FoodSafetyViolation> violations,
    List<HACCPControlPoint> controlPoints,
    List<FoodSafetyAudit> audits,
  ) {
    final totalLogs = temperatureLogs.length;
    final compliantLogs = temperatureLogs.where((log) => log.isWithinSafeRange).length;
    final temperatureCompliance = totalLogs > 0 ? compliantLogs / totalLogs : 0.0;

    final resolvedViolations = violations.where((v) => v.isResolved).length;
    final violationResolution = violations.isNotEmpty ? resolvedViolations / violations.length : 1.0;

    final passedAudits = audits.where((audit) => audit.passed).length;
    final auditCompliance = audits.isNotEmpty ? passedAudits / audits.length : 1.0;

    final averageAuditScore = audits.isNotEmpty 
        ? audits.fold<double>(0.0, (sum, audit) => sum + audit.score) / audits.length
        : 0.0;

    final overallScore = (temperatureCompliance * 0.4) + 
                        (violationResolution * 0.3) + 
                        (auditCompliance * 0.3);

    return {
      'temperature_compliance': temperatureCompliance,
      'violation_resolution_rate': violationResolution,
      'audit_compliance': auditCompliance,
      'average_audit_score': averageAuditScore,
      'overall_score': overallScore,
      'total_temperature_logs': totalLogs,
      'compliant_temperature_logs': compliantLogs,
      'total_violations': violations.length,
      'resolved_violations': resolvedViolations,
      'total_audits': audits.length,
      'passed_audits': passedAudits,
      'active_control_points': controlPoints.length,
    };
  }

  /// Identify critical control points needing attention
  Future<List<Map<String, dynamic>>> _identifyCriticalControlPoints(
    List<TemperatureLog> temperatureLogs,
    List<FoodSafetyViolation> violations,
    List<CCPType>? focusAreas,
  ) async {
    final criticalPoints = <Map<String, dynamic>>[];

    // Group violations by location and type
    final violationsByLocation = <TemperatureLocation, List<FoodSafetyViolation>>{};
    for (final violation in violations) {
      if (violation.location != null) {
        violationsByLocation.putIfAbsent(violation.location!, () => []).add(violation);
      }
    }

    // Group temperature violations by location
    final tempViolationsByLocation = <TemperatureLocation, List<TemperatureLog>>{};
    for (final log in temperatureLogs) {
      if (!log.isWithinSafeRange) {
        tempViolationsByLocation.putIfAbsent(log.location, () => []).add(log);
      }
    }

    // Analyze each location for critical issues
    for (final location in TemperatureLocation.values) {
      final locationViolations = violationsByLocation[location] ?? [];
      final locationTempViolations = tempViolationsByLocation[location] ?? [];
      
      if (locationViolations.length >= 3 || locationTempViolations.length >= 5) {
        criticalPoints.add({
          'location': location.toString(),
          'violation_count': locationViolations.length,
          'temperature_violations': locationTempViolations.length,
          'severity_level': _calculateLocationSeverity(locationViolations),
          'requires_immediate_attention': locationViolations.length >= 5,
        });
      }
    }

    return criticalPoints;
  }

  /// Generate comprehensive risk assessment
  Map<String, dynamic> _generateRiskAssessment(
    List<FoodSafetyViolation> violations,
    List<FoodSafetyAudit> audits,
  ) {
    final criticalViolations = violations.where((v) => v.severity == ViolationSeverity.critical).length;
    final emergencyViolations = violations.where((v) => v.severity == ViolationSeverity.emergency).length;
    final unresolvedViolations = violations.where((v) => !v.isResolved).length;
    
    final failedAudits = audits.where((audit) => !audit.passed).length;
    final lowScoreAudits = audits.where((audit) => audit.score < 70.0).length;

    var riskLevel = 'low';
    if (emergencyViolations > 0 || criticalViolations > 5 || failedAudits > 2) {
      riskLevel = 'high';
    } else if (criticalViolations > 2 || unresolvedViolations > 10 || lowScoreAudits > 1) {
      riskLevel = 'medium';
    }

    return {
      'risk_level': riskLevel,
      'critical_violations': criticalViolations,
      'emergency_violations': emergencyViolations,
      'unresolved_violations': unresolvedViolations,
      'failed_audits': failedAudits,
      'low_score_audits': lowScoreAudits,
      'risk_factors': _identifyRiskFactors(violations, audits),
      'recommendations': _generateRiskRecommendations(riskLevel, violations),
    };
  }

  /// Generate corrective action plan
  List<String> _generateCorrectiveActionPlan(
    List<FoodSafetyViolation> violations,
    List<HACCPControlPoint> controlPoints,
  ) {
    final actions = <String>[];

    // Group violations by type for targeted actions
    final violationsByType = <ViolationType, List<FoodSafetyViolation>>{};
    for (final violation in violations.where((v) => !v.isResolved)) {
      violationsByType.putIfAbsent(violation.type, () => []).add(violation);
    }

    // Generate specific actions based on violation patterns
    violationsByType.forEach((type, typeViolations) {
      if (typeViolations.length >= 3) {
        switch (type) {
          case ViolationType.temperatureViolation:
            actions.add('Implement enhanced temperature monitoring protocols');
            actions.add('Conduct equipment calibration and maintenance checks');
            break;
          case ViolationType.hygieneBreach:
            actions.add('Schedule mandatory hand hygiene training');
            actions.add('Increase hygiene compliance monitoring');
            break;
          case ViolationType.crossContamination:
            actions.add('Review and reinforce cross-contamination prevention procedures');
            actions.add('Implement color-coded cutting board system');
            break;
          case ViolationType.equipmentFailure:
            actions.add('Schedule preventive maintenance for all equipment');
            actions.add('Create equipment backup plan');
            break;
          default:
            actions.add('Address ${type.toString()} violations through targeted training');
        }
      }
    });

    // Add general actions if no specific patterns found
    if (actions.isEmpty && violations.isNotEmpty) {
      actions.addAll([
        'Conduct comprehensive food safety training',
        'Review and update HACCP procedures',
        'Increase management oversight and inspections',
      ]);
    }

    return actions;
  }

  /// Generate staff compliance tracking
  Map<String, dynamic> _generateStaffComplianceTracking(
    List<TemperatureLog> temperatureLogs,
    List<FoodSafetyViolation> violations,
  ) {
    final staffPerformance = <String, Map<String, dynamic>>{};

    // Track temperature log compliance by staff
    for (final log in temperatureLogs) {
      final staffId = log.recordedBy.value;
      if (!staffPerformance.containsKey(staffId)) {
        staffPerformance[staffId] = {
          'total_logs': 0,
          'compliant_logs': 0,
          'violations_reported': 0,
          'compliance_rate': 0.0,
        };
      }

      staffPerformance[staffId]!['total_logs'] = 
          (staffPerformance[staffId]!['total_logs'] as int) + 1;
      
      if (log.isWithinSafeRange) {
        staffPerformance[staffId]!['compliant_logs'] = 
            (staffPerformance[staffId]!['compliant_logs'] as int) + 1;
      }
    }

    // Calculate compliance rates
    staffPerformance.forEach((staffId, performance) {
      final total = performance['total_logs'] as int;
      final compliant = performance['compliant_logs'] as int;
      performance['compliance_rate'] = total > 0 ? compliant / total : 0.0;
    });

    return {
      'staff_performance': staffPerformance,
      'top_performers': _getTopPerformers(staffPerformance),
      'needs_training': _getStaffNeedingTraining(staffPerformance),
    };
  }

  String _calculateLocationSeverity(List<FoodSafetyViolation> violations) {
    final criticalCount = violations.where((v) => v.severity == ViolationSeverity.critical).length;
    final emergencyCount = violations.where((v) => v.severity == ViolationSeverity.emergency).length;
    
    if (emergencyCount > 0) return 'emergency';
    if (criticalCount > 2) return 'critical';
    if (violations.length > 5) return 'high';
    return 'medium';
  }

  List<String> _identifyRiskFactors(
    List<FoodSafetyViolation> violations,
    List<FoodSafetyAudit> audits,
  ) {
    final factors = <String>[];
    
    // Check for recurring violation types
    final violationCounts = <ViolationType, int>{};
    for (final violation in violations) {
      violationCounts[violation.type] = (violationCounts[violation.type] ?? 0) + 1;
    }

    violationCounts.forEach((type, count) {
      if (count >= 3) {
        factors.add('Recurring ${type.toString()} violations');
      }
    });

    // Check audit trends
    if (audits.length >= 2) {
      final recentAudits = audits.take(2).toList();
      if (recentAudits.every((audit) => audit.score < 80)) {
        factors.add('Declining audit performance');
      }
    }

    return factors;
  }

  List<String> _generateRiskRecommendations(
    String riskLevel,
    List<FoodSafetyViolation> violations,
  ) {
    switch (riskLevel) {
      case 'high':
        return [
          'Immediate management review required',
          'Suspend operations until critical issues resolved',
          'Mandatory retraining for all staff',
          'Daily compliance inspections',
        ];
      case 'medium':
        return [
          'Increase monitoring frequency',
          'Schedule additional staff training',
          'Review and update procedures',
          'Weekly management inspections',
        ];
      default:
        return [
          'Maintain current protocols',
          'Continue regular monitoring',
          'Monthly compliance review',
        ];
    }
  }

  List<String> _getTopPerformers(Map<String, Map<String, dynamic>> staffPerformance) {
    final performers = staffPerformance.entries
        .where((entry) => (entry.value['compliance_rate'] as double) >= 0.95)
        .map((entry) => entry.key)
        .toList();
    
    return performers;
  }

  List<String> _getStaffNeedingTraining(Map<String, Map<String, dynamic>> staffPerformance) {
    final needsTraining = staffPerformance.entries
        .where((entry) => (entry.value['compliance_rate'] as double) < 0.8)
        .map((entry) => entry.key)
        .toList();
    
    return needsTraining;
  }
}

/// Temperature monitoring and alerting use case
@injectable
class TemperatureMonitoringUseCase {
  final FoodSafetyRepository _foodSafetyRepository;

  const TemperatureMonitoringUseCase({
    required FoodSafetyRepository foodSafetyRepository,
  }) : _foodSafetyRepository = foodSafetyRepository;

  /// Execute comprehensive temperature monitoring
  Future<Either<Failure, Map<String, dynamic>>> execute({
    required Time monitoringPeriodStart,
    required Time monitoringPeriodEnd,
    List<TemperatureLocation>? specificLocations,
  }) async {
    try {
      // Get temperature logs for the period
      final temperatureLogs = await _foodSafetyRepository
          .getTemperatureLogsByDateRange(monitoringPeriodStart, monitoringPeriodEnd);

      // Filter by specific locations if provided
      final filteredLogs = specificLocations != null
          ? temperatureLogs.where((log) => specificLocations.contains(log.location)).toList()
          : temperatureLogs;

      // Analyze temperature trends
      final analysis = _analyzeTemperatureTrends(filteredLogs);

      // Identify alerts and violations
      final alerts = await _identifyTemperatureAlerts(filteredLogs);

      // Generate monitoring report
      final report = {
        'monitoring_period_start': monitoringPeriodStart.millisecondsSinceEpoch,
        'monitoring_period_end': monitoringPeriodEnd.millisecondsSinceEpoch,
        'total_logs': filteredLogs.length,
        'locations_monitored': _getMonitoredLocations(filteredLogs),
        'temperature_analysis': analysis,
        'alerts': alerts,
        'compliance_summary': _generateComplianceSummary(filteredLogs),
        'generated_at': Time.now().millisecondsSinceEpoch,
      };

      return Right(report);
    } catch (e) {
      return Left(ServerFailure('Failed to execute temperature monitoring: $e'));
    }
  }

  Map<String, dynamic> _analyzeTemperatureTrends(List<TemperatureLog> logs) {
    if (logs.isEmpty) {
      return {
        'trend': 'no_data',
        'average_temperature': 0.0,
        'min_temperature': 0.0,
        'max_temperature': 0.0,
        'compliance_rate': 0.0,
      };
    }

    final temperatures = logs.map((log) => log.temperature).toList();
    final averageTemp = temperatures.reduce((a, b) => a + b) / temperatures.length;
    final minTemp = temperatures.reduce((a, b) => a < b ? a : b);
    final maxTemp = temperatures.reduce((a, b) => a > b ? a : b);
    
    final compliantLogs = logs.where((log) => log.isWithinSafeRange).length;
    final complianceRate = compliantLogs / logs.length;

    return {
      'average_temperature': averageTemp,
      'min_temperature': minTemp,
      'max_temperature': maxTemp,
      'compliance_rate': complianceRate,
      'trend': _determineTrend(logs),
      'temperature_distribution': _analyzeTemperatureDistribution(logs),
    };
  }

  Future<List<Map<String, dynamic>>> _identifyTemperatureAlerts(List<TemperatureLog> logs) async {
    final alerts = <Map<String, dynamic>>[];

    for (final log in logs) {
      if (!log.isWithinSafeRange || log.requiresCorrectiveAction) {
        alerts.add({
          'log_id': log.id.value,
          'location': log.location.toString(),
          'temperature': log.temperature,
          'recorded_at': log.recordedAt.millisecondsSinceEpoch,
          'alert_type': !log.isWithinSafeRange ? 'out_of_range' : 'requires_action',
          'severity': _calculateTemperatureAlertSeverity(log),
        });
      }
    }

    return alerts;
  }

  List<String> _getMonitoredLocations(List<TemperatureLog> logs) {
    return logs.map((log) => log.location.toString()).toSet().toList();
  }

  Map<String, dynamic> _generateComplianceSummary(List<TemperatureLog> logs) {
    final totalLogs = logs.length;
    final compliantLogs = logs.where((log) => log.isWithinSafeRange).length;
    final logsRequiringAction = logs.where((log) => log.requiresCorrectiveAction).length;

    return {
      'total_logs': totalLogs,
      'compliant_logs': compliantLogs,
      'non_compliant_logs': totalLogs - compliantLogs,
      'logs_requiring_action': logsRequiringAction,
      'compliance_percentage': totalLogs > 0 ? (compliantLogs / totalLogs * 100) : 0.0,
    };
  }

  String _determineTrend(List<TemperatureLog> logs) {
    if (logs.length < 3) return 'insufficient_data';
    
    final sortedLogs = logs..sort((a, b) => a.recordedAt.millisecondsSinceEpoch
        .compareTo(b.recordedAt.millisecondsSinceEpoch));
    
    final firstHalf = sortedLogs.take(logs.length ~/ 2);
    final secondHalf = sortedLogs.skip(logs.length ~/ 2);
    
    final firstAvg = firstHalf.fold<double>(0.0, (sum, log) => sum + log.temperature) / firstHalf.length;
    final secondAvg = secondHalf.fold<double>(0.0, (sum, log) => sum + log.temperature) / secondHalf.length;
    
    final difference = secondAvg - firstAvg;
    
    if (difference > 2.0) return 'increasing';
    if (difference < -2.0) return 'decreasing';
    return 'stable';
  }

  Map<String, int> _analyzeTemperatureDistribution(List<TemperatureLog> logs) {
    final distribution = <String, int>{};
    
    for (final log in logs) {
      String range;
      if (log.temperature < 32) {
        range = 'below_freezing';
      } else if (log.temperature < 41) {
        range = 'safe_cold';
      } else if (log.temperature < 140) {
        range = 'danger_zone';
      } else {
        range = 'safe_hot';
      }
      
      distribution[range] = (distribution[range] ?? 0) + 1;
    }
    
    return distribution;
  }

  String _calculateTemperatureAlertSeverity(TemperatureLog log) {
    if (log.temperature < 0 || log.temperature > 200) {
      return 'critical';
    } else if (!log.isWithinSafeRange) {
      return 'high';
    } else if (log.requiresCorrectiveAction) {
      return 'medium';
    }
    return 'low';
  }
}