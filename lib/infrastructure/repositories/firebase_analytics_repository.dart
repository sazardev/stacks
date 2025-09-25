import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';

import '../../domain/failures/failures.dart';
import '../../domain/entities/analytics.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../mappers/analytics_mapper.dart';

@LazySingleton(as: AnalyticsRepository)
class FirebaseAnalyticsRepository implements AnalyticsRepository {
  final FirebaseFirestore _firestore;
  final AnalyticsMapper _analyticsMapper;

  FirebaseAnalyticsRepository(this._firestore, this._analyticsMapper);

  // Collection references
  CollectionReference get _kitchenMetricsCollection =>
      _firestore.collection('kitchenMetrics');
  CollectionReference get _performanceReportsCollection =>
      _firestore.collection('performanceReports');
  CollectionReference get _staffAnalyticsCollection =>
      _firestore.collection('staffAnalytics');
  CollectionReference get _efficiencyAnalyticsCollection =>
      _firestore.collection('efficiencyAnalytics');
  CollectionReference get _orderAnalyticsCollection =>
      _firestore.collection('orderAnalytics');

  @override
  Future<Either<Failure, KitchenMetric>> createKitchenMetric(
    KitchenMetric metric,
  ) async {
    try {
      final data = _analyticsMapper.kitchenMetricToFirestore(metric);
      final docRef = await _kitchenMetricsCollection.add(data);

      // Return the metric with the new ID (domain entities are immutable)
      final newMetric = KitchenMetric(
        id: UserId(docRef.id),
        type: metric.type,
        name: metric.name,
        value: metric.value,
        unit: metric.unit,
        target: metric.target,
        previousValue: metric.previousValue,
        recordedAt: metric.recordedAt,
        period: metric.period,
        stationId: metric.stationId,
        userId: metric.userId,
        metadata: metric.metadata,
      );

      return Right(newMetric);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KitchenMetric>> getKitchenMetricById(
    UserId metricId,
  ) async {
    try {
      final doc = await _kitchenMetricsCollection.doc(metricId.value).get();

      if (!doc.exists) {
        return const Left(NotFoundFailure('Kitchen metric not found'));
      }

      final data = doc.data() as Map<String, dynamic>;
      final metric = _analyticsMapper.kitchenMetricFromFirestore(data, doc.id);
      return Right(metric);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KitchenMetric>>> getKitchenMetricsByType(
    MetricType type,
  ) async {
    try {
      final query = _kitchenMetricsCollection.where(
        'type',
        isEqualTo: _metricTypeToString(type),
      );
      final querySnapshot = await query.get();

      final metrics = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _analyticsMapper.kitchenMetricFromFirestore(data, doc.id);
      }).toList();

      return Right(metrics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KitchenMetric>>> getKitchenMetricsByPeriod(
    AnalyticsPeriod period,
    Time startDate,
    Time endDate,
  ) async {
    try {
      final query = _kitchenMetricsCollection
          .where(
            'recordedAt',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
          )
          .where(
            'recordedAt',
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch,
          )
          .where('period', isEqualTo: _analyticsPeriodToString(period));

      final querySnapshot = await query.get();

      final metrics = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _analyticsMapper.kitchenMetricFromFirestore(data, doc.id);
      }).toList();

      return Right(metrics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KitchenMetric>>> getKitchenMetricsByStation(
    UserId stationId,
  ) async {
    try {
      final query = _kitchenMetricsCollection.where(
        'stationId',
        isEqualTo: stationId.value,
      );
      final querySnapshot = await query.get();

      final metrics = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _analyticsMapper.kitchenMetricFromFirestore(data, doc.id);
      }).toList();

      return Right(metrics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KitchenMetric>> updateKitchenMetric(
    KitchenMetric metric,
  ) async {
    try {
      final data = _analyticsMapper.kitchenMetricToFirestore(metric);
      await _kitchenMetricsCollection.doc(metric.id.value).update(data);
      return Right(metric);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteKitchenMetric(UserId metricId) async {
    try {
      await _kitchenMetricsCollection.doc(metricId.value).delete();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PerformanceReport>> createPerformanceReport(
    PerformanceReport report,
  ) async {
    try {
      final data = _analyticsMapper.performanceReportToFirestore(report);
      final docRef = await _performanceReportsCollection.add(data);

      final newReport = PerformanceReport(
        id: UserId(docRef.id),
        reportName: report.reportName,
        period: report.period,
        periodStart: report.periodStart,
        periodEnd: report.periodEnd,
        metrics: report.metrics,
        overallScore: report.overallScore,
        overallRating: report.overallRating,
        insights: report.insights,
        recommendations: report.recommendations,
        generatedBy: report.generatedBy,
        generatedAt: report.generatedAt,
      );

      return Right(newReport);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PerformanceReport>> getPerformanceReportById(
    UserId reportId,
  ) async {
    try {
      final doc = await _performanceReportsCollection.doc(reportId.value).get();

      if (!doc.exists) {
        return const Left(NotFoundFailure('Performance report not found'));
      }

      final data = doc.data() as Map<String, dynamic>;
      final report = _analyticsMapper.performanceReportFromFirestore(
        data,
        doc.id,
      );
      return Right(report);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PerformanceReport>>>
  getPerformanceReportsByPeriod(
    AnalyticsPeriod period,
    Time startDate,
    Time endDate,
  ) async {
    try {
      final query = _performanceReportsCollection
          .where(
            'periodStart',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
          )
          .where(
            'periodEnd',
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch,
          )
          .where('period', isEqualTo: _analyticsPeriodToString(period));

      final querySnapshot = await query.get();

      final reports = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _analyticsMapper.performanceReportFromFirestore(data, doc.id);
      }).toList();

      return Right(reports);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Additional helper methods (not in interface but useful)
  Future<Either<Failure, List<PerformanceReport>>> getPerformanceReportsByUser(
    UserId userId,
  ) async {
    try {
      final query = _performanceReportsCollection.where(
        'generatedBy',
        isEqualTo: userId.value,
      );
      final querySnapshot = await query.get();

      final reports = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _analyticsMapper.performanceReportFromFirestore(data, doc.id);
      }).toList();

      return Right(reports);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, PerformanceReport>> updatePerformanceReport(
    PerformanceReport report,
  ) async {
    try {
      final data = _analyticsMapper.performanceReportToFirestore(report);
      await _performanceReportsCollection.doc(report.id.value).update(data);
      return Right(report);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> deletePerformanceReport(UserId reportId) async {
    try {
      await _performanceReportsCollection.doc(reportId.value).delete();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StaffPerformanceAnalytics>>
  createStaffPerformanceAnalytics(StaffPerformanceAnalytics analytics) async {
    try {
      final data = _analyticsMapper.staffPerformanceAnalyticsToFirestore(
        analytics,
      );
      final docRef = await _staffAnalyticsCollection.add(data);

      final newAnalytics = StaffPerformanceAnalytics(
        id: UserId(docRef.id),
        staffId: analytics.staffId,
        staffName: analytics.staffName,
        role: analytics.role,
        periodStart: analytics.periodStart,
        periodEnd: analytics.periodEnd,
        ordersCompleted: analytics.ordersCompleted,
        averageOrderTime: analytics.averageOrderTime,
        errorCount: analytics.errorCount,
        efficiencyScore: analytics.efficiencyScore,
        customersServed: analytics.customersServed,
        customerSatisfactionScore: analytics.customerSatisfactionScore,
        totalWorkTime: analytics.totalWorkTime,
        achievements: analytics.achievements,
        improvementAreas: analytics.improvementAreas,
      );

      return Right(newAnalytics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StaffPerformanceAnalytics>>>
  getStaffPerformanceAnalyticsByStaffId(UserId staffId) async {
    try {
      final query = _staffAnalyticsCollection.where(
        'staffId',
        isEqualTo: staffId.value,
      );
      final querySnapshot = await query.get();

      final analytics = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _analyticsMapper.staffPerformanceAnalyticsFromFirestore(
          data,
          doc.id,
        );
      }).toList();

      return Right(analytics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StaffPerformanceAnalytics>>>
  getStaffPerformanceAnalyticsByPeriod(Time startDate, Time endDate) async {
    try {
      final query = _staffAnalyticsCollection
          .where(
            'periodStart',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
          )
          .where(
            'periodEnd',
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch,
          );

      final querySnapshot = await query.get();

      final analytics = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _analyticsMapper.staffPerformanceAnalyticsFromFirestore(
          data,
          doc.id,
        );
      }).toList();

      return Right(analytics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KitchenEfficiencyAnalytics>>
  createKitchenEfficiencyAnalytics(KitchenEfficiencyAnalytics analytics) async {
    try {
      final data = _analyticsMapper.kitchenEfficiencyAnalyticsToFirestore(
        analytics,
      );
      final docRef = await _efficiencyAnalyticsCollection.add(data);

      final newAnalytics = KitchenEfficiencyAnalytics(
        id: UserId(docRef.id),
        date: analytics.date,
        stationUtilization: analytics.stationUtilization,
        stationAverageTime: analytics.stationAverageTime,
        stationOrderCount: analytics.stationOrderCount,
        overallEfficiency: analytics.overallEfficiency,
        averageOrderTime: analytics.averageOrderTime,
        peakHourAverageTime: analytics.peakHourAverageTime,
        bottleneckStationCount: analytics.bottleneckStationCount,
        bottleneckStations: analytics.bottleneckStations,
        capacityUtilization: analytics.capacityUtilization,
        efficiencyIssues: analytics.efficiencyIssues,
        optimizationSuggestions: analytics.optimizationSuggestions,
      );

      return Right(newAnalytics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Additional helper method (not in interface)
  Future<Either<Failure, KitchenEfficiencyAnalytics>>
  getKitchenEfficiencyAnalyticsById(UserId analyticsId) async {
    try {
      final doc = await _efficiencyAnalyticsCollection
          .doc(analyticsId.value)
          .get();

      if (!doc.exists) {
        return const Left(
          NotFoundFailure('Kitchen efficiency analytics not found'),
        );
      }

      final data = doc.data() as Map<String, dynamic>;
      final analytics = _analyticsMapper
          .kitchenEfficiencyAnalyticsFromFirestore(data, doc.id);
      return Right(analytics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KitchenEfficiencyAnalytics>>
  getKitchenEfficiencyAnalyticsByDate(Time date) async {
    try {
      final startOfDay = Time.fromDateTime(
        DateTime(date.dateTime.year, date.dateTime.month, date.dateTime.day),
      );

      final endOfDay = Time.fromDateTime(
        DateTime(
          date.dateTime.year,
          date.dateTime.month,
          date.dateTime.day,
          23,
          59,
          59,
          999,
        ),
      );

      final query = _efficiencyAnalyticsCollection
          .where(
            'date',
            isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch,
          )
          .where('date', isLessThanOrEqualTo: endOfDay.millisecondsSinceEpoch)
          .limit(1);

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        return const Left(
          NotFoundFailure('Kitchen efficiency analytics not found for date'),
        );
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      final analytics = _analyticsMapper
          .kitchenEfficiencyAnalyticsFromFirestore(data, doc.id);

      return Right(analytics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KitchenEfficiencyAnalytics>>>
  getKitchenEfficiencyAnalyticsByDateRange(Time startDate, Time endDate) async {
    try {
      final query = _efficiencyAnalyticsCollection
          .where(
            'date',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
          )
          .where('date', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch);

      final querySnapshot = await query.get();

      final analytics = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _analyticsMapper.kitchenEfficiencyAnalyticsFromFirestore(
          data,
          doc.id,
        );
      }).toList();

      return Right(analytics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderAnalytics>> createOrderAnalytics(
    OrderAnalytics analytics,
  ) async {
    try {
      final data = _orderAnalyticsToFirestore(analytics);
      final docRef = await _orderAnalyticsCollection.add(data);

      final newAnalytics = OrderAnalytics(
        id: UserId(docRef.id),
        date: analytics.date,
        totalOrders: analytics.totalOrders,
        averageOrderValue: analytics.averageOrderValue,
        averageCompletionTime: analytics.averageCompletionTime,
        peakHourCompletionTime: analytics.peakHourCompletionTime,
        cancelledOrders: analytics.cancelledOrders,
        refundedOrders: analytics.refundedOrders,
        popularItems: analytics.popularItems,
        revenueByCategory: analytics.revenueByCategory,
        ordersByHour: analytics.ordersByHour,
      );

      return Right(newAnalytics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderAnalytics>> getOrderAnalyticsByDate(
    Time date,
  ) async {
    try {
      final startOfDay = Time.fromDateTime(
        DateTime(date.dateTime.year, date.dateTime.month, date.dateTime.day),
      );

      final endOfDay = Time.fromDateTime(
        DateTime(
          date.dateTime.year,
          date.dateTime.month,
          date.dateTime.day,
          23,
          59,
          59,
          999,
        ),
      );

      final query = _orderAnalyticsCollection
          .where(
            'date',
            isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch,
          )
          .where('date', isLessThanOrEqualTo: endOfDay.millisecondsSinceEpoch)
          .limit(1);

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        return const Left(
          NotFoundFailure('Order analytics not found for date'),
        );
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      final analytics = _orderAnalyticsFromFirestore(data, doc.id);
      return Right(analytics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderAnalytics>>> getOrderAnalyticsByDateRange(
    Time startDate,
    Time endDate,
  ) async {
    try {
      final query = _orderAnalyticsCollection
          .where(
            'date',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
          )
          .where('date', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch);

      final querySnapshot = await query.get();

      final analytics = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _orderAnalyticsFromFirestore(data, doc.id);
      }).toList();

      return Right(analytics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KitchenMetric>>>
  getMetricsNeedingImprovement() async {
    try {
      final query = _kitchenMetricsCollection
          .where('value', isLessThan: 70) // metrics below 70% performance
          .orderBy('value');

      final querySnapshot = await query.get();

      final metrics = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _analyticsMapper.kitchenMetricFromFirestore(data, doc.id);
      }).toList();

      return Right(metrics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KitchenMetric>>> getTopPerformingMetrics() async {
    try {
      final query = _kitchenMetricsCollection
          .where('value', isGreaterThan: 90) // metrics above 90% performance
          .orderBy('value', descending: true);

      final querySnapshot = await query.get();

      final metrics = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _analyticsMapper.kitchenMetricFromFirestore(data, doc.id);
      }).toList();

      return Right(metrics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StaffPerformanceAnalytics>>>
  getStaffPerformanceTrends(
    UserId staffId,
    Time startDate,
    Time endDate,
  ) async {
    try {
      final query = _staffAnalyticsCollection
          .where('staffId', isEqualTo: staffId.value)
          .where(
            'periodStart',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
          )
          .where(
            'periodEnd',
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch,
          )
          .orderBy('periodStart');

      final querySnapshot = await query.get();

      final analytics = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _analyticsMapper.staffPerformanceAnalyticsFromFirestore(
          data,
          doc.id,
        );
      }).toList();

      return Right(analytics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KitchenEfficiencyAnalytics>>>
  getKitchenEfficiencyTrends(Time startDate, Time endDate) async {
    try {
      final query = _efficiencyAnalyticsCollection
          .where(
            'date',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
          )
          .where('date', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
          .orderBy('date');

      final querySnapshot = await query.get();

      final analytics = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _analyticsMapper.kitchenEfficiencyAnalyticsFromFirestore(
          data,
          doc.id,
        );
      }).toList();

      return Right(analytics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Helper methods for string conversions
  String _metricTypeToString(MetricType type) {
    switch (type) {
      case MetricType.orderCompletionTime:
        return 'order_completion_time';
      case MetricType.stationEfficiency:
        return 'station_efficiency';
      case MetricType.staffPerformance:
        return 'staff_performance';
      case MetricType.foodCostPercentage:
        return 'food_cost_percentage';
      case MetricType.wastePercentage:
        return 'waste_percentage';
      case MetricType.customerSatisfaction:
        return 'customer_satisfaction';
      case MetricType.revenuePerHour:
        return 'revenue_per_hour';
      case MetricType.orderAccuracy:
        return 'order_accuracy';
      case MetricType.temperatureCompliance:
        return 'temperature_compliance';
      case MetricType.inventoryTurnover:
        return 'inventory_turnover';
    }
  }

  String _analyticsPeriodToString(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.hourly:
        return 'hourly';
      case AnalyticsPeriod.daily:
        return 'daily';
      case AnalyticsPeriod.weekly:
        return 'weekly';
      case AnalyticsPeriod.monthly:
        return 'monthly';
      case AnalyticsPeriod.quarterly:
        return 'quarterly';
      case AnalyticsPeriod.yearly:
        return 'yearly';
      case AnalyticsPeriod.custom:
        return 'custom';
    }
  }

  // OrderAnalytics mapper methods (simplified since OrderAnalytics is not in the main mapper)
  Map<String, dynamic> _orderAnalyticsToFirestore(OrderAnalytics analytics) {
    return {
      'id': analytics.id.value,
      'date': analytics.date.millisecondsSinceEpoch,
      'totalOrders': analytics.totalOrders,
      'averageOrderValue': analytics.averageOrderValue,
      'averageCompletionTime': analytics.averageCompletionTime.inMilliseconds,
      'peakHourCompletionTime': analytics.peakHourCompletionTime.inMilliseconds,
      'cancelledOrders': analytics.cancelledOrders,
      'refundedOrders': analytics.refundedOrders,
      'popularItems': analytics.popularItems,
      'revenueByCategory': analytics.revenueByCategory,
      'ordersByHour': analytics.ordersByHour,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  OrderAnalytics _orderAnalyticsFromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return OrderAnalytics(
      id: UserId(id),
      date: Time.fromMillisecondsSinceEpoch(data['date'] as int),
      totalOrders: data['totalOrders'] as int,
      averageOrderValue: (data['averageOrderValue'] as num).toDouble(),
      averageCompletionTime: Duration(
        milliseconds: data['averageCompletionTime'] as int,
      ),
      peakHourCompletionTime: Duration(
        milliseconds: data['peakHourCompletionTime'] as int,
      ),
      cancelledOrders: data['cancelledOrders'] as int,
      refundedOrders: data['refundedOrders'] as int,
      popularItems: Map<String, int>.from(data['popularItems'] ?? {}),
      revenueByCategory: Map<String, double>.from(
        (data['revenueByCategory'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      ordersByHour: Map<int, int>.from(data['ordersByHour'] ?? {}),
    );
  }

  @disposeMethod
  void dispose() {
    // Cleanup resources if needed
  }
}
