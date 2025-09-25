// Food Safety BLoC
// Main BLoC for managing food safety operations in the presentation layer

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/repositories/food_safety_repository.dart';
import '../../../application/use_cases/food_safety/advanced_food_safety_use_cases.dart';
import 'food_safety_event.dart';
import 'food_safety_state.dart';

@injectable
class FoodSafetyBLoC extends Bloc<FoodSafetyEvent, FoodSafetyState> {
  final FoodSafetyRepository _foodSafetyRepository;
  final ManageFoodSafetyComplianceProgramUseCase _complianceProgramUseCase;
  final TemperatureMonitoringUseCase _temperatureMonitoringUseCase;

  // Real-time monitoring
  StreamSubscription? _realTimeSubscription;
  bool _isRealTimeActive = false;

  FoodSafetyBLoC({
    required FoodSafetyRepository foodSafetyRepository,
    required ManageFoodSafetyComplianceProgramUseCase complianceProgramUseCase,
    required TemperatureMonitoringUseCase temperatureMonitoringUseCase,
  }) : _foodSafetyRepository = foodSafetyRepository,
       _complianceProgramUseCase = complianceProgramUseCase,
       _temperatureMonitoringUseCase = temperatureMonitoringUseCase,
       super(const FoodSafetyInitial()) {
    // Register event handlers
    on<LoadTemperatureLogsEvent>(_onLoadTemperatureLogs);
    on<CreateTemperatureLogEvent>(_onCreateTemperatureLog);
    on<LoadTemperatureLogsRequiringActionEvent>(
      _onLoadTemperatureLogsRequiringAction,
    );
    on<LoadTemperatureLogsOutsideSafeRangeEvent>(
      _onLoadTemperatureLogsOutsideSafeRange,
    );
    on<LoadTemperatureLogsByLocationEvent>(_onLoadTemperatureLogsByLocation);
    on<LoadTemperatureLogsByUserEvent>(_onLoadTemperatureLogsByUser);

    on<LoadViolationsEvent>(_onLoadViolations);
    on<CreateViolationEvent>(_onCreateViolation);
    on<ResolveViolationEvent>(_onResolveViolation);
    on<LoadUnresolvedViolationsEvent>(_onLoadUnresolvedViolations);
    on<LoadOverdueViolationsEvent>(_onLoadOverdueViolations);
    on<LoadViolationsByTypeEvent>(_onLoadViolationsByType);
    on<LoadViolationsBySeverityEvent>(_onLoadViolationsBySeverity);
    on<LoadViolationsAssignedToUserEvent>(_onLoadViolationsAssignedToUser);

    on<LoadHACCPControlPointsEvent>(_onLoadHACCPControlPoints);
    on<CreateHACCPControlPointEvent>(_onCreateHACCPControlPoint);
    on<UpdateControlPointMonitoringEvent>(_onUpdateControlPointMonitoring);
    on<DeactivateControlPointEvent>(_onDeactivateControlPoint);
    on<ActivateControlPointEvent>(_onActivateControlPoint);
    on<LoadControlPointsRequiringMonitoringEvent>(
      _onLoadControlPointsRequiringMonitoring,
    );
    on<LoadControlPointsByResponsibleUserEvent>(
      _onLoadControlPointsByResponsibleUser,
    );

    on<LoadAuditsEvent>(_onLoadAudits);
    on<CreateAuditEvent>(_onCreateAudit);
    on<LoadPassedAuditsEvent>(_onLoadPassedAudits);
    on<LoadFailedAuditsEvent>(_onLoadFailedAudits);
    on<LoadAuditsByAuditorEvent>(_onLoadAuditsByAuditor);
    on<LoadAuditsByMinScoreEvent>(_onLoadAuditsByMinScore);

    on<LoadTemperatureComplianceStatsEvent>(_onLoadTemperatureComplianceStats);
    on<LoadViolationTrendsEvent>(_onLoadViolationTrends);
    on<LoadHACCPComplianceReportEvent>(_onLoadHACCPComplianceReport);
    on<LoadAuditPerformanceMetricsEvent>(_onLoadAuditPerformanceMetrics);
    on<LoadControlPointEffectivenessEvent>(_onLoadControlPointEffectiveness);
    on<LoadFoodSafetyDashboardEvent>(_onLoadFoodSafetyDashboard);
    on<LoadTemperatureAlertSummaryEvent>(_onLoadTemperatureAlertSummary);
    on<LoadViolationResolutionMetricsEvent>(_onLoadViolationResolutionMetrics);

    on<ExecuteComplianceAssessmentEvent>(_onExecuteComplianceAssessment);
    on<ExecuteTemperatureMonitoringEvent>(_onExecuteTemperatureMonitoring);

    on<StartRealTimeMonitoringEvent>(_onStartRealTimeMonitoring);
    on<StopRealTimeMonitoringEvent>(_onStopRealTimeMonitoring);
    on<RealTimeDataUpdateEvent>(_onRealTimeDataUpdate);

    on<ClearFoodSafetyErrorsEvent>(_onClearErrors);
    on<RetryFoodSafetyOperationEvent>(_onRetryOperation);
  }

  @override
  Future<void> close() {
    _realTimeSubscription?.cancel();
    return super.close();
  }

  // ======================== Temperature Log Event Handlers ========================

  Future<void> _onLoadTemperatureLogs(
    LoadTemperatureLogsEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(const FoodSafetyLoading(operation: 'Loading temperature logs'));

        final logs = await _foodSafetyRepository.getTemperatureLogsByDateRange(
          event.startDate,
          event.endDate,
        );

        final filteredLogs = event.location != null
            ? logs.where((log) => log.location == event.location).toList()
            : logs;

        emit(
          TemperatureLogsLoaded(
            temperatureLogs: filteredLogs,
            filterType: event.location?.toString(),
          ),
        );
      },
      errorMessage: 'Failed to load temperature logs',
    );
  }

  Future<void> _onCreateTemperatureLog(
    CreateTemperatureLogEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(const FoodSafetyLoading(operation: 'Creating temperature log'));

        final createdLog = await _foodSafetyRepository.createTemperatureLog(
          event.temperatureLog,
        );

        emit(TemperatureLogCreated(temperatureLog: createdLog));
      },
      errorMessage: 'Failed to create temperature log',
    );
  }

  Future<void> _onLoadTemperatureLogsRequiringAction(
    LoadTemperatureLogsRequiringActionEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(operation: 'Loading logs requiring action'),
        );

        final logs = await _foodSafetyRepository
            .getTemperatureLogsRequiringAction();

        emit(TemperatureLogsRequiringActionLoaded(temperatureLogs: logs));
      },
      errorMessage: 'Failed to load temperature logs requiring action',
    );
  }

  Future<void> _onLoadTemperatureLogsOutsideSafeRange(
    LoadTemperatureLogsOutsideSafeRangeEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(operation: 'Loading logs outside safe range'),
        );

        final logs = await _foodSafetyRepository
            .getTemperatureLogsOutsideSafeRange();

        emit(TemperatureLogsOutsideSafeRangeLoaded(temperatureLogs: logs));
      },
      errorMessage: 'Failed to load temperature logs outside safe range',
    );
  }

  Future<void> _onLoadTemperatureLogsByLocation(
    LoadTemperatureLogsByLocationEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(const FoodSafetyLoading(operation: 'Loading logs by location'));

        final logs = await _foodSafetyRepository.getTemperatureLogsByLocation(
          event.location,
        );

        emit(
          TemperatureLogsLoaded(
            temperatureLogs: logs,
            filterType: 'location:${event.location}',
          ),
        );
      },
      errorMessage: 'Failed to load temperature logs by location',
    );
  }

  Future<void> _onLoadTemperatureLogsByUser(
    LoadTemperatureLogsByUserEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(const FoodSafetyLoading(operation: 'Loading logs by user'));

        final logs = await _foodSafetyRepository.getTemperatureLogsByUser(
          event.userId,
        );

        emit(
          TemperatureLogsLoaded(
            temperatureLogs: logs,
            filterType: 'user:${event.userId.value}',
          ),
        );
      },
      errorMessage: 'Failed to load temperature logs by user',
    );
  }

  // ======================== Violation Event Handlers ========================

  Future<void> _onLoadViolations(
    LoadViolationsEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(const FoodSafetyLoading(operation: 'Loading violations'));

        var violations = await _foodSafetyRepository.getViolationsByDateRange(
          event.startDate,
          event.endDate,
        );

        if (event.type != null) {
          violations = violations.where((v) => v.type == event.type).toList();
        }

        if (event.severity != null) {
          violations = violations
              .where((v) => v.severity == event.severity)
              .toList();
        }

        String? filterType;
        if (event.type != null && event.severity != null) {
          filterType = 'type:${event.type},severity:${event.severity}';
        } else if (event.type != null) {
          filterType = 'type:${event.type}';
        } else if (event.severity != null) {
          filterType = 'severity:${event.severity}';
        }

        emit(ViolationsLoaded(violations: violations, filterType: filterType));
      },
      errorMessage: 'Failed to load violations',
    );
  }

  Future<void> _onCreateViolation(
    CreateViolationEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(const FoodSafetyLoading(operation: 'Creating violation'));

        final createdViolation = await _foodSafetyRepository
            .createFoodSafetyViolation(event.violation);

        emit(ViolationCreated(violation: createdViolation));
      },
      errorMessage: 'Failed to create violation',
    );
  }

  Future<void> _onResolveViolation(
    ResolveViolationEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(const FoodSafetyLoading(operation: 'Resolving violation'));

        final resolvedViolation = await _foodSafetyRepository.resolveViolation(
          event.violationId,
          event.correctiveActions,
          event.rootCause,
          event.preventiveAction,
        );

        emit(ViolationResolved(violation: resolvedViolation));
      },
      errorMessage: 'Failed to resolve violation',
    );
  }

  Future<void> _onLoadUnresolvedViolations(
    LoadUnresolvedViolationsEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(operation: 'Loading unresolved violations'),
        );

        final violations = await _foodSafetyRepository
            .getUnresolvedViolations();

        emit(UnresolvedViolationsLoaded(violations: violations));
      },
      errorMessage: 'Failed to load unresolved violations',
    );
  }

  Future<void> _onLoadOverdueViolations(
    LoadOverdueViolationsEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(const FoodSafetyLoading(operation: 'Loading overdue violations'));

        final violations = await _foodSafetyRepository.getOverdueViolations();

        emit(OverdueViolationsLoaded(violations: violations));
      },
      errorMessage: 'Failed to load overdue violations',
    );
  }

  Future<void> _onLoadViolationsByType(
    LoadViolationsByTypeEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(const FoodSafetyLoading(operation: 'Loading violations by type'));

        final violations = await _foodSafetyRepository.getViolationsByType(
          event.type,
        );

        emit(
          ViolationsLoaded(
            violations: violations,
            filterType: 'type:${event.type}',
          ),
        );
      },
      errorMessage: 'Failed to load violations by type',
    );
  }

  Future<void> _onLoadViolationsBySeverity(
    LoadViolationsBySeverityEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(operation: 'Loading violations by severity'),
        );

        final violations = await _foodSafetyRepository.getViolationsBySeverity(
          event.severity,
        );

        emit(
          ViolationsLoaded(
            violations: violations,
            filterType: 'severity:${event.severity}',
          ),
        );
      },
      errorMessage: 'Failed to load violations by severity',
    );
  }

  Future<void> _onLoadViolationsAssignedToUser(
    LoadViolationsAssignedToUserEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(const FoodSafetyLoading(operation: 'Loading assigned violations'));

        final violations = await _foodSafetyRepository
            .getViolationsAssignedToUser(event.userId);

        emit(
          ViolationsLoaded(
            violations: violations,
            filterType: 'assigned:${event.userId.value}',
          ),
        );
      },
      errorMessage: 'Failed to load violations assigned to user',
    );
  }

  // ======================== HACCP Control Point Event Handlers ========================

  Future<void> _onLoadHACCPControlPoints(
    LoadHACCPControlPointsEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(operation: 'Loading HACCP control points'),
        );

        List<dynamic> controlPoints;

        if (event.activeOnly) {
          controlPoints = await _foodSafetyRepository.getActiveControlPoints();
        } else if (event.type != null) {
          controlPoints = await _foodSafetyRepository.getControlPointsByType(
            event.type!,
          );
        } else {
          controlPoints = await _foodSafetyRepository.getActiveControlPoints();
        }

        emit(
          HACCPControlPointsLoaded(
            controlPoints: controlPoints.cast(),
            filterType: event.type?.toString(),
          ),
        );
      },
      errorMessage: 'Failed to load HACCP control points',
    );
  }

  Future<void> _onCreateHACCPControlPoint(
    CreateHACCPControlPointEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(operation: 'Creating HACCP control point'),
        );

        final createdControlPoint = await _foodSafetyRepository
            .createHACCPControlPoint(event.controlPoint);

        emit(HACCPControlPointCreated(controlPoint: createdControlPoint));
      },
      errorMessage: 'Failed to create HACCP control point',
    );
  }

  Future<void> _onUpdateControlPointMonitoring(
    UpdateControlPointMonitoringEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(
            operation: 'Updating control point monitoring',
          ),
        );

        final updatedControlPoint = await _foodSafetyRepository
            .updateControlPointMonitoring(
              event.controlPointId,
              event.monitoredAt,
            );

        emit(ControlPointMonitoringUpdated(controlPoint: updatedControlPoint));
      },
      errorMessage: 'Failed to update control point monitoring',
    );
  }

  Future<void> _onDeactivateControlPoint(
    DeactivateControlPointEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(const FoodSafetyLoading(operation: 'Deactivating control point'));

        final deactivatedControlPoint = await _foodSafetyRepository
            .deactivateControlPoint(event.controlPointId);

        emit(ControlPointDeactivated(controlPoint: deactivatedControlPoint));
      },
      errorMessage: 'Failed to deactivate control point',
    );
  }

  Future<void> _onActivateControlPoint(
    ActivateControlPointEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(const FoodSafetyLoading(operation: 'Activating control point'));

        final activatedControlPoint = await _foodSafetyRepository
            .activateControlPoint(event.controlPointId);

        emit(ControlPointActivated(controlPoint: activatedControlPoint));
      },
      errorMessage: 'Failed to activate control point',
    );
  }

  Future<void> _onLoadControlPointsRequiringMonitoring(
    LoadControlPointsRequiringMonitoringEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(
            operation: 'Loading control points requiring monitoring',
          ),
        );

        final controlPoints = await _foodSafetyRepository
            .getControlPointsRequiringMonitoring();

        emit(
          ControlPointsRequiringMonitoringLoaded(controlPoints: controlPoints),
        );
      },
      errorMessage: 'Failed to load control points requiring monitoring',
    );
  }

  Future<void> _onLoadControlPointsByResponsibleUser(
    LoadControlPointsByResponsibleUserEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(operation: 'Loading control points by user'),
        );

        final controlPoints = await _foodSafetyRepository
            .getControlPointsByResponsibleUser(event.userId);

        emit(
          HACCPControlPointsLoaded(
            controlPoints: controlPoints,
            filterType: 'user:${event.userId.value}',
          ),
        );
      },
      errorMessage: 'Failed to load control points by responsible user',
    );
  }

  // ======================== Audit Event Handlers ========================

  Future<void> _onLoadAudits(
    LoadAuditsEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(const FoodSafetyLoading(operation: 'Loading audits'));

        var audits = await _foodSafetyRepository.getAuditsByDateRange(
          event.startDate,
          event.endDate,
        );

        if (event.auditorId != null) {
          audits =
              audits; // Note: Would need additional filtering if auditorId field exists
        }

        emit(AuditsLoaded(audits: audits, filterType: event.auditorId?.value));
      },
      errorMessage: 'Failed to load audits',
    );
  }

  Future<void> _onCreateAudit(
    CreateAuditEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(const FoodSafetyLoading(operation: 'Creating audit'));

        final createdAudit = await _foodSafetyRepository.createFoodSafetyAudit(
          event.audit,
        );

        emit(AuditCreated(audit: createdAudit));
      },
      errorMessage: 'Failed to create audit',
    );
  }

  Future<void> _onLoadPassedAudits(
    LoadPassedAuditsEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(const FoodSafetyLoading(operation: 'Loading passed audits'));

        final audits = await _foodSafetyRepository.getPassedAudits();

        emit(PassedAuditsLoaded(audits: audits));
      },
      errorMessage: 'Failed to load passed audits',
    );
  }

  Future<void> _onLoadFailedAudits(
    LoadFailedAuditsEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(const FoodSafetyLoading(operation: 'Loading failed audits'));

        final audits = await _foodSafetyRepository.getFailedAudits();

        emit(FailedAuditsLoaded(audits: audits));
      },
      errorMessage: 'Failed to load failed audits',
    );
  }

  Future<void> _onLoadAuditsByAuditor(
    LoadAuditsByAuditorEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(const FoodSafetyLoading(operation: 'Loading audits by auditor'));

        final audits = await _foodSafetyRepository.getAuditsByAuditor(
          event.auditorId,
        );

        emit(
          AuditsLoaded(
            audits: audits,
            filterType: 'auditor:${event.auditorId.value}',
          ),
        );
      },
      errorMessage: 'Failed to load audits by auditor',
    );
  }

  Future<void> _onLoadAuditsByMinScore(
    LoadAuditsByMinScoreEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(operation: 'Loading audits by minimum score'),
        );

        final audits = await _foodSafetyRepository.getAuditsByMinScore(
          event.minScore,
        );

        emit(
          AuditsLoaded(
            audits: audits,
            filterType: 'minScore:${event.minScore}',
          ),
        );
      },
      errorMessage: 'Failed to load audits by minimum score',
    );
  }

  // ======================== Analytics Event Handlers ========================

  Future<void> _onLoadTemperatureComplianceStats(
    LoadTemperatureComplianceStatsEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(
            operation: 'Loading temperature compliance stats',
          ),
        );

        final stats = await _foodSafetyRepository.getTemperatureComplianceStats(
          event.startDate,
          event.endDate,
        );

        emit(TemperatureComplianceStatsLoaded(stats: stats));
      },
      errorMessage: 'Failed to load temperature compliance statistics',
    );
  }

  Future<void> _onLoadViolationTrends(
    LoadViolationTrendsEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(const FoodSafetyLoading(operation: 'Loading violation trends'));

        final trends = await _foodSafetyRepository.getViolationTrends(
          event.startDate,
          event.endDate,
        );

        emit(ViolationTrendsLoaded(trends: trends));
      },
      errorMessage: 'Failed to load violation trends',
    );
  }

  Future<void> _onLoadHACCPComplianceReport(
    LoadHACCPComplianceReportEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(operation: 'Loading HACCP compliance report'),
        );

        final report = await _foodSafetyRepository.getHACCPComplianceReport(
          event.startDate,
          event.endDate,
        );

        emit(HACCPComplianceReportLoaded(report: report));
      },
      errorMessage: 'Failed to load HACCP compliance report',
    );
  }

  Future<void> _onLoadAuditPerformanceMetrics(
    LoadAuditPerformanceMetricsEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(
            operation: 'Loading audit performance metrics',
          ),
        );

        final metrics = await _foodSafetyRepository.getAuditPerformanceMetrics(
          event.startDate,
          event.endDate,
        );

        emit(AuditPerformanceMetricsLoaded(metrics: metrics));
      },
      errorMessage: 'Failed to load audit performance metrics',
    );
  }

  Future<void> _onLoadControlPointEffectiveness(
    LoadControlPointEffectivenessEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(
            operation: 'Loading control point effectiveness',
          ),
        );

        final effectiveness = await _foodSafetyRepository
            .getControlPointEffectiveness(event.startDate, event.endDate);

        emit(ControlPointEffectivenessLoaded(effectiveness: effectiveness));
      },
      errorMessage: 'Failed to load control point effectiveness',
    );
  }

  Future<void> _onLoadFoodSafetyDashboard(
    LoadFoodSafetyDashboardEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(operation: 'Loading food safety dashboard'),
        );

        final dashboardData = await _foodSafetyRepository
            .getFoodSafetyDashboardData();

        emit(FoodSafetyDashboardLoaded(dashboardData: dashboardData));
      },
      errorMessage: 'Failed to load food safety dashboard',
    );
  }

  Future<void> _onLoadTemperatureAlertSummary(
    LoadTemperatureAlertSummaryEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(
            operation: 'Loading temperature alert summary',
          ),
        );

        final alertSummary = await _foodSafetyRepository
            .getTemperatureAlertSummary();

        emit(TemperatureAlertSummaryLoaded(alertSummary: alertSummary));
      },
      errorMessage: 'Failed to load temperature alert summary',
    );
  }

  Future<void> _onLoadViolationResolutionMetrics(
    LoadViolationResolutionMetricsEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(
            operation: 'Loading violation resolution metrics',
          ),
        );

        final metrics = await _foodSafetyRepository
            .getViolationResolutionMetrics(event.startDate, event.endDate);

        emit(ViolationResolutionMetricsLoaded(metrics: metrics));
      },
      errorMessage: 'Failed to load violation resolution metrics',
    );
  }

  // ======================== Advanced Use Case Event Handlers ========================

  Future<void> _onExecuteComplianceAssessment(
    ExecuteComplianceAssessmentEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(operation: 'Executing compliance assessment'),
        );

        final result = await _complianceProgramUseCase.execute(
          assessmentPeriodStart: event.assessmentPeriodStart,
          assessmentPeriodEnd: event.assessmentPeriodEnd,
          focusAreas: event.focusAreas,
          generateCorrectiveActions: event.generateCorrectiveActions,
        );

        result.fold(
          (failure) => throw Exception(failure.toString()),
          (assessment) =>
              emit(ComplianceAssessmentCompleted(assessment: assessment)),
        );
      },
      errorMessage: 'Failed to execute compliance assessment',
    );
  }

  Future<void> _onExecuteTemperatureMonitoring(
    ExecuteTemperatureMonitoringEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    await handleOperation(
      emit: emit,
      operation: () async {
        emit(
          const FoodSafetyLoading(
            operation: 'Executing temperature monitoring',
          ),
        );

        final result = await _temperatureMonitoringUseCase.execute(
          monitoringPeriodStart: event.monitoringPeriodStart,
          monitoringPeriodEnd: event.monitoringPeriodEnd,
          specificLocations: event.specificLocations,
        );

        result.fold(
          (failure) => throw Exception(failure.toString()),
          (monitoring) =>
              emit(TemperatureMonitoringCompleted(monitoring: monitoring)),
        );
      },
      errorMessage: 'Failed to execute temperature monitoring',
    );
  }

  // ======================== Real-time Event Handlers ========================

  Future<void> _onStartRealTimeMonitoring(
    StartRealTimeMonitoringEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    try {
      if (_isRealTimeActive) return;

      developer.log('Starting real-time monitoring', name: 'FoodSafetyBLoC');

      _isRealTimeActive = true;
      emit(const RealTimeMonitoringActive(isActive: true));

      // Note: In a real implementation, you would set up Firebase listeners here
      // This is a placeholder for the real-time monitoring setup
    } catch (e) {
      developer.log(
        'Error starting real-time monitoring: $e',
        name: 'FoodSafetyBLoC',
      );
      emit(
        FoodSafetyError(message: 'Failed to start real-time monitoring: $e'),
      );
    }
  }

  Future<void> _onStopRealTimeMonitoring(
    StopRealTimeMonitoringEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    try {
      developer.log('Stopping real-time monitoring', name: 'FoodSafetyBLoC');

      await _realTimeSubscription?.cancel();
      _realTimeSubscription = null;
      _isRealTimeActive = false;

      emit(const RealTimeMonitoringActive(isActive: false));
    } catch (e) {
      developer.log(
        'Error stopping real-time monitoring: $e',
        name: 'FoodSafetyBLoC',
      );
      emit(FoodSafetyError(message: 'Failed to stop real-time monitoring: $e'));
    }
  }

  Future<void> _onRealTimeDataUpdate(
    RealTimeDataUpdateEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    emit(
      RealTimeDataUpdated(
        updateType: event.updateType,
        data: event.data,
        timestamp: DateTime.now(),
      ),
    );
  }

  // ======================== Utility Event Handlers ========================

  Future<void> _onClearErrors(
    ClearFoodSafetyErrorsEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    emit(const FoodSafetyInitial());
  }

  Future<void> _onRetryOperation(
    RetryFoodSafetyOperationEvent event,
    Emitter<FoodSafetyState> emit,
  ) async {
    developer.log(
      'Retrying operation: ${event.originalEvent.runtimeType}',
      name: 'FoodSafetyBLoC',
    );
    add(event.originalEvent);
  }

  // ======================== Utility Methods ========================

  /// Handles operation execution with error handling
  Future<void> handleOperation({
    required Emitter<FoodSafetyState> emit,
    required Future<void> Function() operation,
    required String errorMessage,
  }) async {
    try {
      await operation();
    } catch (e, stackTrace) {
      developer.log(
        errorMessage,
        name: 'FoodSafetyBLoC',
        error: e,
        stackTrace: stackTrace,
      );
      emit(FoodSafetyError(message: '$errorMessage: $e'));
    }
  }

  /// Check if real-time monitoring is currently active
  bool get isRealTimeActive => _isRealTimeActive;

  /// Get current state information for debugging
  Map<String, dynamic> get debugInfo => {
    'currentState': state.runtimeType.toString(),
    'isRealTimeActive': _isRealTimeActive,
    'hasActiveSubscription': _realTimeSubscription != null,
  };
}
