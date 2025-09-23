// Analytics Use Cases for Clean Architecture Application Layer

import 'package:dartz/dartz.dart';
import '../../../domain/entities/analytics.dart';
import '../../../domain/repositories/analytics_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
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

/// Use case for getting kitchen metrics by type
class GetKitchenMetricsByTypeUseCase {
  final AnalyticsRepository _repository;

  GetKitchenMetricsByTypeUseCase(this._repository);

  Future<Either<Failure, List<KitchenMetric>>> call(MetricType type) {
    return _repository.getKitchenMetricsByType(type);
  }
}

/// Use case for getting kitchen metrics by station
class GetKitchenMetricsByStationUseCase {
  final AnalyticsRepository _repository;

  GetKitchenMetricsByStationUseCase(this._repository);

  Future<Either<Failure, List<KitchenMetric>>> call(AnalyticsQueryDto dto) {
    return _repository.getKitchenMetricsByStation(UserId(dto.stationId!));
  }
}

/// Use case for generating performance report
class GeneratePerformanceReportUseCase {
  final AnalyticsRepository _repository;

  GeneratePerformanceReportUseCase(this._repository);

  Future<Either<Failure, PerformanceReport>> call(
    GeneratePerformanceReportDto dto,
  ) {
    final report = dto.toEntity();
    return _repository.createPerformanceReport(report);
  }
}

/// Use case for creating order analytics
class CreateOrderAnalyticsUseCase {
  final AnalyticsRepository _repository;

  CreateOrderAnalyticsUseCase(this._repository);

  Future<Either<Failure, OrderAnalytics>> call(CreateOrderAnalyticsDto dto) {
    final analytics = dto.toEntity();
    return _repository.createOrderAnalytics(analytics);
  }
}

/// Use case for creating staff performance analytics
class CreateStaffPerformanceAnalyticsUseCase {
  final AnalyticsRepository _repository;

  CreateStaffPerformanceAnalyticsUseCase(this._repository);

  Future<Either<Failure, StaffPerformanceAnalytics>> call(
    CreateStaffPerformanceAnalyticsDto dto,
  ) {
    final analytics = dto.toEntity();
    return _repository.createStaffPerformanceAnalytics(analytics);
  }
}

/// Use case for creating kitchen efficiency analytics
class CreateKitchenEfficiencyAnalyticsUseCase {
  final AnalyticsRepository _repository;

  CreateKitchenEfficiencyAnalyticsUseCase(this._repository);

  Future<Either<Failure, KitchenEfficiencyAnalytics>> call(
    CreateKitchenEfficiencyAnalyticsDto dto,
  ) {
    final analytics = dto.toEntity();
    return _repository.createKitchenEfficiencyAnalytics(analytics);
  }
}
