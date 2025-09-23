import 'package:dartz/dartz.dart' show Either, Unit;
import '../entities/analytics.dart';
import '../value_objects/user_id.dart';
import '../value_objects/time.dart';
import '../failures/failures.dart';

/// Repository interface for Analytics operations
abstract class AnalyticsRepository {
  /// Creates a new kitchen metric
  Future<Either<Failure, KitchenMetric>> createKitchenMetric(
    KitchenMetric metric,
  );

  /// Gets a kitchen metric by its ID
  Future<Either<Failure, KitchenMetric>> getKitchenMetricById(UserId metricId);

  /// Gets kitchen metrics by type
  Future<Either<Failure, List<KitchenMetric>>> getKitchenMetricsByType(
    MetricType type,
  );

  /// Gets kitchen metrics by period
  Future<Either<Failure, List<KitchenMetric>>> getKitchenMetricsByPeriod(
    AnalyticsPeriod period,
    Time startDate,
    Time endDate,
  );

  /// Gets kitchen metrics by station
  Future<Either<Failure, List<KitchenMetric>>> getKitchenMetricsByStation(
    UserId stationId,
  );

  /// Updates a kitchen metric
  Future<Either<Failure, KitchenMetric>> updateKitchenMetric(
    KitchenMetric metric,
  );

  /// Deletes a kitchen metric
  Future<Either<Failure, Unit>> deleteKitchenMetric(UserId metricId);

  /// Creates a new performance report
  Future<Either<Failure, PerformanceReport>> createPerformanceReport(
    PerformanceReport report,
  );

  /// Gets a performance report by its ID
  Future<Either<Failure, PerformanceReport>> getPerformanceReportById(
    UserId reportId,
  );

  /// Gets performance reports by period
  Future<Either<Failure, List<PerformanceReport>>>
  getPerformanceReportsByPeriod(
    AnalyticsPeriod period,
    Time startDate,
    Time endDate,
  );

  /// Creates order analytics
  Future<Either<Failure, OrderAnalytics>> createOrderAnalytics(
    OrderAnalytics analytics,
  );

  /// Gets order analytics by date
  Future<Either<Failure, OrderAnalytics>> getOrderAnalyticsByDate(Time date);

  /// Gets order analytics by date range
  Future<Either<Failure, List<OrderAnalytics>>> getOrderAnalyticsByDateRange(
    Time startDate,
    Time endDate,
  );

  /// Creates staff performance analytics
  Future<Either<Failure, StaffPerformanceAnalytics>>
  createStaffPerformanceAnalytics(StaffPerformanceAnalytics analytics);

  /// Gets staff performance analytics by staff ID
  Future<Either<Failure, List<StaffPerformanceAnalytics>>>
  getStaffPerformanceAnalyticsByStaffId(UserId staffId);

  /// Gets staff performance analytics by period
  Future<Either<Failure, List<StaffPerformanceAnalytics>>>
  getStaffPerformanceAnalyticsByPeriod(Time startDate, Time endDate);

  /// Creates kitchen efficiency analytics
  Future<Either<Failure, KitchenEfficiencyAnalytics>>
  createKitchenEfficiencyAnalytics(KitchenEfficiencyAnalytics analytics);

  /// Gets kitchen efficiency analytics by date
  Future<Either<Failure, KitchenEfficiencyAnalytics>>
  getKitchenEfficiencyAnalyticsByDate(Time date);

  /// Gets kitchen efficiency analytics by date range
  Future<Either<Failure, List<KitchenEfficiencyAnalytics>>>
  getKitchenEfficiencyAnalyticsByDateRange(Time startDate, Time endDate);

  /// Gets metrics needing improvement
  Future<Either<Failure, List<KitchenMetric>>> getMetricsNeedingImprovement();

  /// Gets top performing metrics
  Future<Either<Failure, List<KitchenMetric>>> getTopPerformingMetrics();

  /// Gets staff performance trends
  Future<Either<Failure, List<StaffPerformanceAnalytics>>>
  getStaffPerformanceTrends(UserId staffId, Time startDate, Time endDate);

  /// Gets kitchen efficiency trends
  Future<Either<Failure, List<KitchenEfficiencyAnalytics>>>
  getKitchenEfficiencyTrends(Time startDate, Time endDate);
}
