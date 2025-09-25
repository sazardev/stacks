// Analytics BLoC - Business Logic Component
// Manages analytics state and handles analytics-related events

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../application/use_cases/analytics/advanced_analytics_use_cases.dart';
import '../../../domain/repositories/analytics_repository.dart';
import '../../../domain/entities/analytics.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/time.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

/// BLoC for managing analytics feature state and business logic
@injectable
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository _analyticsRepository;
  final GenerateKitchenPerformanceAnalyticsUseCase _generateAnalyticsUseCase;

  // Stream subscriptions for real-time updates
  StreamSubscription<List<KitchenMetric>>? _metricsSubscription;
  StreamSubscription<List<PerformanceReport>>? _reportsSubscription;

  AnalyticsBloc({
    required AnalyticsRepository analyticsRepository,
    required GenerateKitchenPerformanceAnalyticsUseCase
    generateAnalyticsUseCase,
  }) : _analyticsRepository = analyticsRepository,
       _generateAnalyticsUseCase = generateAnalyticsUseCase,
       super(const AnalyticsInitial()) {
    // Register event handlers
    on<LoadKitchenMetrics>(_onLoadKitchenMetrics);
    on<LoadPerformanceReports>(_onLoadPerformanceReports);
    on<GeneratePerformanceReport>(_onGeneratePerformanceReport);
    on<LoadStaffPerformance>(_onLoadStaffPerformance);
    on<LoadKitchenEfficiency>(_onLoadKitchenEfficiency);
    on<SubscribeToMetricsUpdates>(_onSubscribeToMetricsUpdates);
    on<UnsubscribeFromUpdates>(_onUnsubscribeFromUpdates);
    on<RefreshAnalytics>(_onRefreshAnalytics);
    on<UpdateMetricFilter>(_onUpdateMetricFilter);
    on<LoadMetricsNeedingImprovement>(_onLoadMetricsNeedingImprovement);
    on<LoadTopPerformingMetrics>(_onLoadTopPerformingMetrics);
    on<LoadAnalyticsTrends>(_onLoadAnalyticsTrends);
    on<CreateKitchenMetric>(_onCreateKitchenMetric);
    on<UpdateKitchenMetric>(_onUpdateKitchenMetric);
    on<DeleteKitchenMetric>(_onDeleteKitchenMetric);

    developer.log('AnalyticsBloc initialized', name: 'AnalyticsBloc');
  }

  @override
  Future<void> close() {
    _metricsSubscription?.cancel();
    _reportsSubscription?.cancel();
    return super.close();
  }

  /// Load kitchen metrics based on filters
  Future<void> _onLoadKitchenMetrics(
    LoadKitchenMetrics event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(const AnalyticsLoading(message: 'Loading kitchen metrics...'));

      developer.log(
        'Loading kitchen metrics with filters: type=${event.filterType}, station=${event.stationId}, period=${event.period}',
        name: 'AnalyticsBloc._onLoadKitchenMetrics',
      );

      List<KitchenMetric> metrics = [];

      // Load metrics based on filters
      if (event.filterType != null) {
        final result = await _analyticsRepository.getKitchenMetricsByType(
          event.filterType!,
        );
        metrics = result.fold((failure) => throw failure, (data) => data);
      } else if (event.stationId != null) {
        final result = await _analyticsRepository.getKitchenMetricsByStation(
          event.stationId!,
        );
        metrics = result.fold((failure) => throw failure, (data) => data);
      } else if (event.startDate != null && event.endDate != null) {
        final result = await _analyticsRepository.getKitchenMetricsByPeriod(
          event.period,
          event.startDate!,
          event.endDate!,
        );
        metrics = result.fold((failure) => throw failure, (data) => data);
      }

      // Update state with loaded metrics
      final currentState = state is AnalyticsLoaded
          ? (state as AnalyticsLoaded)
          : const AnalyticsLoaded();

      emit(
        currentState.copyWith(
          metrics: metrics,
          currentFilter: event.filterType,
          currentPeriod: event.period,
        ),
      );

      developer.log(
        'Successfully loaded ${metrics.length} kitchen metrics',
        name: 'AnalyticsBloc._onLoadKitchenMetrics',
      );
    } catch (error, stackTrace) {
      developer.log(
        'Error loading kitchen metrics: $error',
        name: 'AnalyticsBloc._onLoadKitchenMetrics',
        error: error,
        stackTrace: stackTrace,
      );

      emit(
        AnalyticsError.fromFailure(
          error as dynamic,
          previousState: state is AnalyticsLoaded
              ? (state as AnalyticsLoaded)
              : null,
        ),
      );
    }
  }

  /// Load performance reports
  Future<void> _onLoadPerformanceReports(
    LoadPerformanceReports event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(const AnalyticsLoading(message: 'Loading performance reports...'));

      final result = await _analyticsRepository.getPerformanceReportsByPeriod(
        event.period,
        event.startDate,
        event.endDate,
      );

      final reports = result.fold((failure) => throw failure, (data) => data);

      final currentState = state is AnalyticsLoaded
          ? (state as AnalyticsLoaded)
          : const AnalyticsLoaded();

      emit(currentState.copyWith(reports: reports));
    } catch (error) {
      emit(
        AnalyticsError.fromFailure(
          error as dynamic,
          previousState: state is AnalyticsLoaded
              ? (state as AnalyticsLoaded)
              : null,
        ),
      );
    }
  }

  /// Generate new performance report
  Future<void> _onGeneratePerformanceReport(
    GeneratePerformanceReport event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(
        const AnalyticsGeneratingReport(
          progress: 0.0,
          currentStep: 'Initializing report generation...',
        ),
      );

      // Step 1: Collect metrics data
      emit(
        const AnalyticsGeneratingReport(
          progress: 0.2,
          currentStep: 'Collecting performance metrics...',
        ),
      );

      final analysisResult = await _generateAnalyticsUseCase.execute(
        startDate: event.startDate,
        endDate: event.endDate,
        focusMetrics: event.includeMetrics,
      );

      // Step 2: Process data
      emit(
        const AnalyticsGeneratingReport(
          progress: 0.6,
          currentStep: 'Processing analytics data...',
        ),
      );

      final analysis = analysisResult.fold(
        (failure) => throw failure,
        (data) => data,
      );

      // Step 3: Create report
      emit(
        const AnalyticsGeneratingReport(
          progress: 0.8,
          currentStep: 'Generating performance report...',
        ),
      );

      // Create performance report from analysis
      final report = PerformanceReport(
        id: UserId.generate(),
        reportName: 'Kitchen Performance Report',
        period: AnalyticsPeriod.custom,
        periodStart: event.startDate,
        periodEnd: event.endDate,
        generatedAt: Time.now(),
        generatedBy: UserId.generate(), // Should be actual user ID
        overallScore: analysis.overallScore,
        overallRating: analysis.overallScore >= 90
            ? PerformanceRating.excellent
            : analysis.overallScore >= 80
            ? PerformanceRating.good
            : analysis.overallScore >= 70
            ? PerformanceRating.satisfactory
            : analysis.overallScore >= 60
            ? PerformanceRating.needsImprovement
            : PerformanceRating.poor,
        insights: analysis.improvementOpportunities
            .map(
              (opp) =>
                  '${opp.metricType} improvement needed (${opp.impactLevel} impact)',
            )
            .toList(),
        recommendations: [
          'Review metrics performance',
          'Focus on improvement areas',
        ],
      );

      // Save the report
      final saveResult = await _analyticsRepository.createPerformanceReport(
        report,
      );
      saveResult.fold((failure) => throw failure, (_) => {});

      // Update state with new report
      final currentState = state is AnalyticsLoaded
          ? (state as AnalyticsLoaded)
          : const AnalyticsLoaded();
      final updatedReports = [report, ...currentState.reports];

      emit(
        AnalyticsReportGenerated(
          report: report,
          updatedState: currentState.copyWith(reports: updatedReports),
        ),
      );
    } catch (error) {
      emit(AnalyticsError.fromFailure(error as dynamic));
    }
  }

  /// Load staff performance analytics
  Future<void> _onLoadStaffPerformance(
    LoadStaffPerformance event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(const AnalyticsLoading(message: 'Loading staff performance...'));

      List<StaffPerformanceAnalytics> staffPerformance = [];

      if (event.staffId != null) {
        final result = await _analyticsRepository
            .getStaffPerformanceAnalyticsByStaffId(event.staffId!);
        staffPerformance = result.fold(
          (failure) => throw failure,
          (data) => data,
        );
      } else {
        final result = await _analyticsRepository
            .getStaffPerformanceAnalyticsByPeriod(
              event.startDate,
              event.endDate,
            );
        staffPerformance = result.fold(
          (failure) => throw failure,
          (data) => data,
        );
      }

      final currentState = state is AnalyticsLoaded
          ? (state as AnalyticsLoaded)
          : const AnalyticsLoaded();
      emit(currentState.copyWith(staffPerformance: staffPerformance));
    } catch (error) {
      emit(AnalyticsError.fromFailure(error as dynamic));
    }
  }

  /// Load kitchen efficiency analytics
  Future<void> _onLoadKitchenEfficiency(
    LoadKitchenEfficiency event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(
        const AnalyticsLoading(message: 'Loading kitchen efficiency data...'),
      );

      final result = await _analyticsRepository
          .getKitchenEfficiencyAnalyticsByDateRange(
            event.startDate,
            event.endDate,
          );

      final efficiency = result.fold(
        (failure) => throw failure,
        (data) => data,
      );

      final currentState = state is AnalyticsLoaded
          ? (state as AnalyticsLoaded)
          : const AnalyticsLoaded();
      emit(currentState.copyWith(kitchenEfficiency: efficiency));
    } catch (error) {
      emit(AnalyticsError.fromFailure(error as dynamic));
    }
  }

  /// Subscribe to real-time metrics updates
  Future<void> _onSubscribeToMetricsUpdates(
    SubscribeToMetricsUpdates event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      // Cancel existing subscriptions
      await _metricsSubscription?.cancel();

      // Note: Real-time streams would be implemented if the repository supports them
      // For now, we'll mark as real-time enabled in the state
      final currentState = state is AnalyticsLoaded
          ? (state as AnalyticsLoaded)
          : const AnalyticsLoaded();
      emit(currentState.copyWith(isRealTimeEnabled: true));

      developer.log(
        'Subscribed to real-time metrics updates',
        name: 'AnalyticsBloc',
      );
    } catch (error) {
      emit(AnalyticsError.fromFailure(error as dynamic));
    }
  }

  /// Unsubscribe from real-time updates
  Future<void> _onUnsubscribeFromUpdates(
    UnsubscribeFromUpdates event,
    Emitter<AnalyticsState> emit,
  ) async {
    await _metricsSubscription?.cancel();
    await _reportsSubscription?.cancel();

    final currentState = state is AnalyticsLoaded
        ? (state as AnalyticsLoaded)
        : const AnalyticsLoaded();
    emit(currentState.copyWith(isRealTimeEnabled: false));

    developer.log('Unsubscribed from real-time updates', name: 'AnalyticsBloc');
  }

  /// Refresh all analytics data
  Future<void> _onRefreshAnalytics(
    RefreshAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    final currentState = state is AnalyticsLoaded
        ? (state as AnalyticsLoaded)
        : null;

    if (currentState != null) {
      // Reload current data with same filters
      add(
        LoadKitchenMetrics(
          filterType: currentState.currentFilter,
          period: currentState.currentPeriod,
        ),
      );
    }
  }

  /// Update metric filters
  Future<void> _onUpdateMetricFilter(
    UpdateMetricFilter event,
    Emitter<AnalyticsState> emit,
  ) async {
    if (state is AnalyticsLoaded) {
      final currentState = state as AnalyticsLoaded;
      emit(currentState.copyWith());

      // Reload data with new filters if needed
      if (event.type != null || event.period != null) {
        add(LoadKitchenMetrics(period: event.period ?? AnalyticsPeriod.daily));
      }
    }
  }

  /// Load metrics needing improvement
  Future<void> _onLoadMetricsNeedingImprovement(
    LoadMetricsNeedingImprovement event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(
        const AnalyticsLoading(
          message: 'Loading metrics needing improvement...',
        ),
      );

      final result = await _analyticsRepository.getMetricsNeedingImprovement();
      final metrics = result.fold((failure) => throw failure, (data) => data);

      final currentState = state is AnalyticsLoaded
          ? (state as AnalyticsLoaded)
          : const AnalyticsLoaded();
      emit(currentState.copyWith(metrics: metrics));
    } catch (error) {
      emit(AnalyticsError.fromFailure(error as dynamic));
    }
  }

  /// Load top performing metrics
  Future<void> _onLoadTopPerformingMetrics(
    LoadTopPerformingMetrics event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(
        const AnalyticsLoading(message: 'Loading top performing metrics...'),
      );

      final result = await _analyticsRepository.getTopPerformingMetrics();
      final metrics = result.fold((failure) => throw failure, (data) => data);

      final currentState = state is AnalyticsLoaded
          ? (state as AnalyticsLoaded)
          : const AnalyticsLoaded();
      emit(currentState.copyWith(metrics: metrics));
    } catch (error) {
      emit(AnalyticsError.fromFailure(error as dynamic));
    }
  }

  /// Load analytics trends
  Future<void> _onLoadAnalyticsTrends(
    LoadAnalyticsTrends event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(const AnalyticsLoading(message: 'Loading analytics trends...'));

      if (event.staffId != null) {
        // Load staff performance trends
        final result = await _analyticsRepository.getStaffPerformanceTrends(
          event.staffId!,
          event.startDate,
          event.endDate,
        );
        final trends = result.fold((failure) => throw failure, (data) => data);

        final currentState = state is AnalyticsLoaded
            ? (state as AnalyticsLoaded)
            : const AnalyticsLoaded();
        emit(currentState.copyWith(staffPerformance: trends));
      } else {
        // Load kitchen efficiency trends
        final result = await _analyticsRepository.getKitchenEfficiencyTrends(
          event.startDate,
          event.endDate,
        );
        final trends = result.fold((failure) => throw failure, (data) => data);

        final currentState = state is AnalyticsLoaded
            ? (state as AnalyticsLoaded)
            : const AnalyticsLoaded();
        emit(currentState.copyWith(kitchenEfficiency: trends));
      }
    } catch (error) {
      emit(AnalyticsError.fromFailure(error as dynamic));
    }
  }

  /// Create new kitchen metric
  Future<void> _onCreateKitchenMetric(
    CreateKitchenMetric event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(const AnalyticsLoading(message: 'Creating kitchen metric...'));

      final result = await _analyticsRepository.createKitchenMetric(
        event.metric,
      );
      result.fold((failure) => throw failure, (_) => {});

      // Refresh current data
      add(const RefreshAnalytics());

      emit(
        const AnalyticsActionSuccess(
          message: 'Kitchen metric created successfully',
          updatedState: AnalyticsLoaded(),
        ),
      );
    } catch (error) {
      emit(AnalyticsError.fromFailure(error as dynamic));
    }
  }

  /// Update existing kitchen metric
  Future<void> _onUpdateKitchenMetric(
    UpdateKitchenMetric event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(const AnalyticsLoading(message: 'Updating kitchen metric...'));

      final result = await _analyticsRepository.updateKitchenMetric(
        event.metric,
      );
      result.fold((failure) => throw failure, (_) => {});

      // Refresh current data
      add(const RefreshAnalytics());

      emit(
        const AnalyticsActionSuccess(
          message: 'Kitchen metric updated successfully',
          updatedState: AnalyticsLoaded(),
        ),
      );
    } catch (error) {
      emit(AnalyticsError.fromFailure(error as dynamic));
    }
  }

  /// Delete kitchen metric
  Future<void> _onDeleteKitchenMetric(
    DeleteKitchenMetric event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(const AnalyticsLoading(message: 'Deleting kitchen metric...'));

      final result = await _analyticsRepository.deleteKitchenMetric(
        event.metricId,
      );
      result.fold((failure) => throw failure, (_) => {});

      // Refresh current data
      add(const RefreshAnalytics());

      emit(
        const AnalyticsActionSuccess(
          message: 'Kitchen metric deleted successfully',
          updatedState: AnalyticsLoaded(),
        ),
      );
    } catch (error) {
      emit(AnalyticsError.fromFailure(error as dynamic));
    }
  }
}
