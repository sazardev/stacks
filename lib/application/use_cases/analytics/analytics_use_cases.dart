// Analytics Use Cases for Clean Architecture Application Layer

import 'package:dartz/dartz.dart';
import '../../../domain/entities/analytics.dart';
import '../../../domain/repositories/analytics_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/time.dart';
import '../../dtos/analytics_dtos.dart';

/// Use case for creating a kitchen metric
class CreateKitchenMetricUseCase {
  final AnalyticsRepository _repository;

  CreateKitchenMetricUseCase(this._repository);

  Future<Either<Failure, KitchenMetric>> call(CreateKitchenMetricDto dto) {
    final metric = dto.toEntity();
    return _repository.createKitchenMetric(metric);
  }
}

/// Use case for getting kitchen metric by ID
class GetKitchenMetricByIdUseCase {
  final AnalyticsRepository _repository;

  GetKitchenMetricByIdUseCase(this._repository);

  Future<Either<Failure, KitchenMetric>> call(UserId metricId) {
    return _repository.getKitchenMetricById(metricId);
  }
}

/// Use case for getting kitchen metrics by type
class GetKitchenMetricsByTypeUseCase {
  final AnalyticsRepository _repository;

  GetKitchenMetricsByTypeUseCase(this._repository);

  Future<Either<Failure, List<KitchenMetric>>> call(MetricType type) {
    return _repository.getKitchenMetricsByType(type);
  }
}

/// Use case for getting kitchen metrics by period
class GetKitchenMetricsByPeriodUseCase {
  final AnalyticsRepository _repository;

  GetKitchenMetricsByPeriodUseCase(this._repository);

  Future<Either<Failure, List<KitchenMetric>>> call(
    AnalyticsPeriod period,
    Time startTime,
    Time endTime,
  ) {
    return _repository.getKitchenMetricsByPeriod(period, startTime, endTime);
  }
}

/// Use case for getting kitchen metrics by station
class GetKitchenMetricsByStationUseCase {
  final AnalyticsRepository _repository;

  GetKitchenMetricsByStationUseCase(this._repository);

  Future<Either<Failure, List<KitchenMetric>>> call(UserId stationId) {
    return _repository.getKitchenMetricsByStation(stationId);
  }
}

/// Use case for updating kitchen metric
class UpdateKitchenMetricUseCase {
  final AnalyticsRepository _repository;

  UpdateKitchenMetricUseCase(this._repository);

  Future<Either<Failure, KitchenMetric>> call(KitchenMetric metric) {
    return _repository.updateKitchenMetric(metric);
  }
}

/// Use case for deleting kitchen metric
class DeleteKitchenMetricUseCase {
  final AnalyticsRepository _repository;

  DeleteKitchenMetricUseCase(this._repository);

  Future<Either<Failure, Unit>> call(UserId metricId) {
    return _repository.deleteKitchenMetric(metricId);
  }
}

/// Use case for creating performance report
class CreatePerformanceReportUseCase {
  final AnalyticsRepository _repository;

  CreatePerformanceReportUseCase(this._repository);

  Future<Either<Failure, PerformanceReport>> call(PerformanceReport report) {
    return _repository.createPerformanceReport(report);
  }
}

/// Use case for getting performance report by ID
class GetPerformanceReportByIdUseCase {
  final AnalyticsRepository _repository;

  GetPerformanceReportByIdUseCase(this._repository);

  Future<Either<Failure, PerformanceReport>> call(UserId reportId) {
    return _repository.getPerformanceReportById(reportId);
  }
}

/// Use case for getting performance reports by period
class GetPerformanceReportsByPeriodUseCase {
  final AnalyticsRepository _repository;

  GetPerformanceReportsByPeriodUseCase(this._repository);

  Future<Either<Failure, List<PerformanceReport>>> call(
    AnalyticsPeriod period,
    Time startTime,
    Time endTime,
  ) {
    return _repository.getPerformanceReportsByPeriod(
      period,
      startTime,
      endTime,
    );
  }
}

/// Use case for creating order analytics
class CreateOrderAnalyticsUseCase {
  final AnalyticsRepository _repository;

  CreateOrderAnalyticsUseCase(this._repository);

  Future<Either<Failure, OrderAnalytics>> call(OrderAnalytics analytics) {
    return _repository.createOrderAnalytics(analytics);
  }
}

/// Use case for getting order analytics by date
class GetOrderAnalyticsByDateUseCase {
  final AnalyticsRepository _repository;

  GetOrderAnalyticsByDateUseCase(this._repository);

  Future<Either<Failure, OrderAnalytics>> call(Time date) {
    return _repository.getOrderAnalyticsByDate(date);
  }
}

/// Use case for getting order analytics by date range
class GetOrderAnalyticsByDateRangeUseCase {
  final AnalyticsRepository _repository;

  GetOrderAnalyticsByDateRangeUseCase(this._repository);

  Future<Either<Failure, List<OrderAnalytics>>> call(
    Time startDate,
    Time endDate,
  ) {
    return _repository.getOrderAnalyticsByDateRange(startDate, endDate);
  }
}

/// Use case for creating staff performance analytics
class CreateStaffPerformanceAnalyticsUseCase {
  final AnalyticsRepository _repository;

  CreateStaffPerformanceAnalyticsUseCase(this._repository);

  Future<Either<Failure, StaffPerformanceAnalytics>> call(
    StaffPerformanceAnalytics analytics,
  ) {
    return _repository.createStaffPerformanceAnalytics(analytics);
  }
}

/// Use case for getting staff performance analytics by staff ID
class GetStaffPerformanceAnalyticsByStaffIdUseCase {
  final AnalyticsRepository _repository;

  GetStaffPerformanceAnalyticsByStaffIdUseCase(this._repository);

  Future<Either<Failure, List<StaffPerformanceAnalytics>>> call(
    UserId staffId,
  ) {
    return _repository.getStaffPerformanceAnalyticsByStaffId(staffId);
  }
}

/// Use case for getting staff performance analytics by period
class GetStaffPerformanceAnalyticsByPeriodUseCase {
  final AnalyticsRepository _repository;

  GetStaffPerformanceAnalyticsByPeriodUseCase(this._repository);

  Future<Either<Failure, List<StaffPerformanceAnalytics>>> call(
    Time startDate,
    Time endDate,
  ) {
    return _repository.getStaffPerformanceAnalyticsByPeriod(startDate, endDate);
  }
}

/// Use case for creating kitchen efficiency analytics
class CreateKitchenEfficiencyAnalyticsUseCase {
  final AnalyticsRepository _repository;

  CreateKitchenEfficiencyAnalyticsUseCase(this._repository);

  Future<Either<Failure, KitchenEfficiencyAnalytics>> call(
    KitchenEfficiencyAnalytics analytics,
  ) {
    return _repository.createKitchenEfficiencyAnalytics(analytics);
  }
}

/// Use case for getting kitchen efficiency analytics by date
class GetKitchenEfficiencyAnalyticsByDateUseCase {
  final AnalyticsRepository _repository;

  GetKitchenEfficiencyAnalyticsByDateUseCase(this._repository);

  Future<Either<Failure, KitchenEfficiencyAnalytics>> call(Time date) {
    return _repository.getKitchenEfficiencyAnalyticsByDate(date);
  }
}

/// Use case for getting kitchen efficiency analytics by date range
class GetKitchenEfficiencyAnalyticsByDateRangeUseCase {
  final AnalyticsRepository _repository;

  GetKitchenEfficiencyAnalyticsByDateRangeUseCase(this._repository);

  Future<Either<Failure, List<KitchenEfficiencyAnalytics>>> call(
    Time startDate,
    Time endDate,
  ) {
    return _repository.getKitchenEfficiencyAnalyticsByDateRange(
      startDate,
      endDate,
    );
  }
}

/// Use case for getting metrics needing improvement
class GetMetricsNeedingImprovementUseCase {
  final AnalyticsRepository _repository;

  GetMetricsNeedingImprovementUseCase(this._repository);

  Future<Either<Failure, List<KitchenMetric>>> call() {
    return _repository.getMetricsNeedingImprovement();
  }
}

/// Use case for getting top performing metrics
class GetTopPerformingMetricsUseCase {
  final AnalyticsRepository _repository;

  GetTopPerformingMetricsUseCase(this._repository);

  Future<Either<Failure, List<KitchenMetric>>> call() {
    return _repository.getTopPerformingMetrics();
  }
}

/// Use case for getting staff performance trends
class GetStaffPerformanceTrendsUseCase {
  final AnalyticsRepository _repository;

  GetStaffPerformanceTrendsUseCase(this._repository);

  Future<Either<Failure, List<StaffPerformanceAnalytics>>> call(
    UserId staffId,
    Time startDate,
    Time endDate,
  ) {
    return _repository.getStaffPerformanceTrends(staffId, startDate, endDate);
  }
}

/// Use case for getting kitchen efficiency trends
class GetKitchenEfficiencyTrendsUseCase {
  final AnalyticsRepository _repository;

  GetKitchenEfficiencyTrendsUseCase(this._repository);

  Future<Either<Failure, List<KitchenEfficiencyAnalytics>>> call(
    Time startDate,
    Time endDate,
  ) {
    return _repository.getKitchenEfficiencyTrends(startDate, endDate);
  }
}
