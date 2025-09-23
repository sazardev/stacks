import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/entities/analytics.dart';
import 'package:stacks/domain/entities/user.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';

void main() {
  group('Analytics', () {
    late UserId metricId;
    late UserId reportId;
    late UserId stationId;
    late UserId userId;
    late Time recordedAt;

    setUp(() {
      metricId = UserId.generate();
      reportId = UserId.generate();
      stationId = UserId.generate();
      userId = UserId.generate();
      recordedAt = Time.now();
    });

    group('KitchenMetric', () {
      group('creation', () {
        test('should create KitchenMetric with valid data', () {
          final metric = KitchenMetric(
            id: metricId,
            type: MetricType.orderCompletionTime,
            name: 'Average Order Completion',
            value: 12.5,
            unit: 'minutes',
            target: 15.0,
            previousValue: 14.2,
            recordedAt: recordedAt,
            period: AnalyticsPeriod.daily,
            stationId: stationId,
            userId: userId,
            metadata: {'rush_hour': true},
          );

          expect(metric.id, equals(metricId));
          expect(metric.type, equals(MetricType.orderCompletionTime));
          expect(metric.name, equals('Average Order Completion'));
          expect(metric.value, equals(12.5));
          expect(metric.unit, equals('minutes'));
          expect(metric.target, equals(15.0));
          expect(metric.previousValue, equals(14.2));
          expect(metric.recordedAt, equals(recordedAt));
          expect(metric.period, equals(AnalyticsPeriod.daily));
          expect(metric.stationId, equals(stationId));
          expect(metric.userId, equals(userId));
          expect(metric.metadata['rush_hour'], isTrue);
        });

        test('should create KitchenMetric with minimum required fields', () {
          final metric = KitchenMetric(
            id: metricId,
            type: MetricType.stationEfficiency,
            name: 'Station Efficiency',
            value: 85.0,
            unit: 'percentage',
            recordedAt: recordedAt,
            period: AnalyticsPeriod.hourly,
          );

          expect(metric.id, equals(metricId));
          expect(metric.target, isNull);
          expect(metric.previousValue, isNull);
          expect(metric.stationId, isNull);
          expect(metric.userId, isNull);
          expect(metric.metadata, isEmpty);
        });
      });

      group('business rules', () {
        test('should calculate percentage change from previous value', () {
          final metric = KitchenMetric(
            id: metricId,
            type: MetricType.orderCompletionTime,
            name: 'Order Time',
            value: 12.0,
            unit: 'minutes',
            previousValue: 15.0,
            recordedAt: recordedAt,
            period: AnalyticsPeriod.daily,
          );

          expect(metric.percentageChange, equals(-20.0)); // 20% improvement
        });

        test('should return null percentage change without previous value', () {
          final metric = KitchenMetric(
            id: metricId,
            type: MetricType.orderCompletionTime,
            name: 'Order Time',
            value: 12.0,
            unit: 'minutes',
            recordedAt: recordedAt,
            period: AnalyticsPeriod.daily,
          );

          expect(metric.percentageChange, isNull);
        });

        test('should check if metric meets target', () {
          final meetsTarget = KitchenMetric(
            id: metricId,
            type: MetricType.stationEfficiency,
            name: 'Station Efficiency',
            value: 85.0,
            unit: 'percentage',
            target: 80.0,
            recordedAt: recordedAt,
            period: AnalyticsPeriod.daily,
          );

          final missesTarget = KitchenMetric(
            id: metricId,
            type: MetricType.stationEfficiency,
            name: 'Station Efficiency',
            value: 75.0,
            unit: 'percentage',
            target: 80.0,
            recordedAt: recordedAt,
            period: AnalyticsPeriod.daily,
          );

          expect(meetsTarget.meetsTarget, isTrue);
          expect(missesTarget.meetsTarget, isFalse);
        });

        test('should get correct performance rating', () {
          final excellentMetric = KitchenMetric(
            id: metricId,
            type: MetricType.stationEfficiency,
            name: 'Efficiency',
            value: 95.0,
            unit: 'percentage',
            target: 100.0,
            recordedAt: recordedAt,
            period: AnalyticsPeriod.daily,
          );

          final poorMetric = KitchenMetric(
            id: metricId,
            type: MetricType.stationEfficiency,
            name: 'Efficiency',
            value: 50.0,
            unit: 'percentage',
            target: 100.0,
            recordedAt: recordedAt,
            period: AnalyticsPeriod.daily,
          );

          expect(
            excellentMetric.performanceRating,
            equals(PerformanceRating.excellent),
          );
          expect(poorMetric.performanceRating, equals(PerformanceRating.poor));
        });

        test('should check trending direction', () {
          final trendingUp = KitchenMetric(
            id: metricId,
            type: MetricType.stationEfficiency,
            name: 'Station Efficiency',
            value: 85.0,
            unit: 'percentage',
            previousValue: 80.0,
            recordedAt: recordedAt,
            period: AnalyticsPeriod.daily,
          );

          final trendingDown = KitchenMetric(
            id: metricId,
            type: MetricType.stationEfficiency,
            name: 'Station Efficiency',
            value: 75.0,
            unit: 'percentage',
            previousValue: 80.0,
            recordedAt: recordedAt,
            period: AnalyticsPeriod.daily,
          );

          expect(trendingUp.isTrendingUp, isTrue);
          expect(trendingDown.isTrendingUp, isFalse);
        });
      });

      group('equality', () {
        test('should be equal when ids are the same', () {
          final metric1 = KitchenMetric(
            id: metricId,
            type: MetricType.orderCompletionTime,
            name: 'Order Time',
            value: 12.0,
            unit: 'minutes',
            recordedAt: recordedAt,
            period: AnalyticsPeriod.daily,
          );

          final metric2 = KitchenMetric(
            id: metricId,
            type: MetricType.stationEfficiency,
            name: 'Different Name',
            value: 85.0,
            unit: 'percentage',
            recordedAt: Time.now(),
            period: AnalyticsPeriod.hourly,
          );

          expect(metric1, equals(metric2));
          expect(metric1.hashCode, equals(metric2.hashCode));
        });

        test('should not be equal when ids are different', () {
          final differentId = UserId('different-metric-id');

          final metric1 = KitchenMetric(
            id: metricId,
            type: MetricType.orderCompletionTime,
            name: 'Order Time',
            value: 12.0,
            unit: 'minutes',
            recordedAt: recordedAt,
            period: AnalyticsPeriod.daily,
          );

          final metric2 = KitchenMetric(
            id: differentId,
            type: MetricType.orderCompletionTime,
            name: 'Order Time',
            value: 12.0,
            unit: 'minutes',
            recordedAt: recordedAt,
            period: AnalyticsPeriod.daily,
          );

          expect(metric1, isNot(equals(metric2)));
        });
      });

      group('string representation', () {
        test('should return string representation', () {
          final metric = KitchenMetric(
            id: metricId,
            type: MetricType.orderCompletionTime,
            name: 'Order Time',
            value: 12.5,
            unit: 'minutes',
            recordedAt: recordedAt,
            period: AnalyticsPeriod.daily,
          );

          final result = metric.toString();
          expect(result, contains('KitchenMetric'));
          expect(result, contains('12.5'));
          expect(result, contains('minutes'));
          expect(result, contains('orderCompletionTime'));
        });
      });
    });

    group('PerformanceReport', () {
      group('creation', () {
        test('should create PerformanceReport with valid data', () {
          final metrics = [
            KitchenMetric(
              id: UserId.generate(),
              type: MetricType.orderCompletionTime,
              name: 'Order Time',
              value: 12.0,
              unit: 'minutes',
              recordedAt: recordedAt,
              period: AnalyticsPeriod.daily,
            ),
            KitchenMetric(
              id: UserId.generate(),
              type: MetricType.stationEfficiency,
              name: 'Station Efficiency',
              value: 85.0,
              unit: 'percentage',
              recordedAt: recordedAt,
              period: AnalyticsPeriod.daily,
            ),
          ];

          final report = PerformanceReport(
            id: reportId,
            reportName: 'Daily Kitchen Performance',
            period: AnalyticsPeriod.daily,
            periodStart: recordedAt.subtract(const Duration(days: 1)),
            periodEnd: recordedAt,
            metrics: metrics,
            overallScore: 82.5,
            overallRating: PerformanceRating.good,
            insights: ['Kitchen efficiency improved by 15%'],
            recommendations: ['Focus on reducing order completion time'],
            generatedBy: userId,
            generatedAt: recordedAt,
          );

          expect(report.id, equals(reportId));
          expect(report.reportName, equals('Daily Kitchen Performance'));
          expect(report.period, equals(AnalyticsPeriod.daily));
          expect(report.metrics, hasLength(2));
          expect(report.overallScore, equals(82.5));
          expect(report.overallRating, equals(PerformanceRating.good));
          expect(report.insights, hasLength(1));
          expect(report.recommendations, hasLength(1));
          expect(report.generatedBy, equals(userId));
        });
      });

      group('business rules', () {
        late PerformanceReport report;
        late List<KitchenMetric> testMetrics;

        setUp(() {
          testMetrics = [
            KitchenMetric(
              id: UserId.generate(),
              type: MetricType.orderCompletionTime,
              name: 'Order Time',
              value: 12.0,
              unit: 'minutes',
              target: 15.0,
              recordedAt: recordedAt,
              period: AnalyticsPeriod.daily,
              stationId: stationId,
            ),
            KitchenMetric(
              id: UserId.generate(),
              type: MetricType.stationEfficiency,
              name: 'Station Efficiency',
              value: 95.0,
              unit: 'percentage',
              target: 100.0,
              recordedAt: recordedAt,
              period: AnalyticsPeriod.daily,
              stationId: stationId,
            ),
            KitchenMetric(
              id: UserId.generate(),
              type: MetricType.orderCompletionTime,
              name: 'Poor Metric',
              value: 50.0,
              unit: 'percentage',
              target: 100.0,
              recordedAt: recordedAt,
              period: AnalyticsPeriod.daily,
            ),
          ];

          report = PerformanceReport(
            id: reportId,
            reportName: 'Test Report',
            period: AnalyticsPeriod.daily,
            periodStart: recordedAt.subtract(const Duration(days: 1)),
            periodEnd: recordedAt,
            metrics: testMetrics,
            overallScore: 82.5,
            overallRating: PerformanceRating.good,
            generatedBy: userId,
            generatedAt: recordedAt,
          );
        });

        test('should get metrics by type', () {
          final orderMetrics = report.getMetricsByType(
            MetricType.orderCompletionTime,
          );
          expect(orderMetrics, hasLength(2));
          expect(
            orderMetrics.every((m) => m.type == MetricType.orderCompletionTime),
            isTrue,
          );
        });

        test('should get metrics by station', () {
          final stationMetrics = report.getMetricsByStation(stationId);
          expect(stationMetrics, hasLength(2));
          expect(stationMetrics.every((m) => m.stationId == stationId), isTrue);
        });

        test('should get metrics needing improvement', () {
          final needsImprovement = report.metricsNeedingImprovement;
          expect(needsImprovement, hasLength(1));
          expect(needsImprovement.first.value, equals(50.0));
        });

        test('should get top performing metrics', () {
          final topPerforming = report.topPerformingMetrics;
          expect(topPerforming, hasLength(1));
          expect(topPerforming.first.value, equals(95.0));
        });
      });
    });

    group('OrderAnalytics', () {
      group('creation', () {
        test('should create OrderAnalytics with valid data', () {
          final analytics = OrderAnalytics(
            id: UserId.generate(),
            date: recordedAt,
            totalOrders: 150,
            averageOrderValue: 25.50,
            averageCompletionTime: const Duration(minutes: 12),
            peakHourCompletionTime: const Duration(minutes: 15),
            cancelledOrders: 5,
            refundedOrders: 2,
            popularItems: {'burger': 45, 'fries': 78},
            revenueByCategory: {'main': 1500.0, 'sides': 650.0},
            ordersByHour: {12: 25, 13: 30, 18: 45},
          );

          expect(analytics.totalOrders, equals(150));
          expect(analytics.averageOrderValue, equals(25.50));
          expect(
            analytics.averageCompletionTime,
            equals(const Duration(minutes: 12)),
          );
          expect(analytics.cancelledOrders, equals(5));
          expect(analytics.cancellationRate, closeTo(3.33, 0.01));
          expect(analytics.refundRate, closeTo(1.33, 0.01));
          expect(analytics.popularItems['burger'], equals(45));
          expect(analytics.revenueByCategory['main'], equals(1500.0));
        });

        test('should handle zero orders gracefully', () {
          final analytics = OrderAnalytics(
            id: UserId.generate(),
            date: recordedAt,
            totalOrders: 0,
            averageOrderValue: 0.0,
            averageCompletionTime: Duration.zero,
            peakHourCompletionTime: Duration.zero,
            cancelledOrders: 0,
            refundedOrders: 0,
          );

          expect(analytics.cancellationRate, equals(0.0));
          expect(analytics.refundRate, equals(0.0));
        });
      });

      group('business rules', () {
        test('should calculate rates correctly', () {
          final analytics = OrderAnalytics(
            id: UserId.generate(),
            date: recordedAt,
            totalOrders: 100,
            averageOrderValue: 30.0,
            averageCompletionTime: const Duration(minutes: 10),
            peakHourCompletionTime: const Duration(minutes: 12),
            cancelledOrders: 8,
            refundedOrders: 3,
          );

          expect(analytics.cancellationRate, equals(8.0));
          expect(analytics.refundRate, equals(3.0));
        });

        test('should identify performance issues', () {
          final highCancellation = OrderAnalytics(
            id: UserId.generate(),
            date: recordedAt,
            totalOrders: 100,
            averageOrderValue: 30.0,
            averageCompletionTime: const Duration(minutes: 10),
            peakHourCompletionTime: const Duration(minutes: 12),
            cancelledOrders: 15, // 15% cancellation rate
            refundedOrders: 3,
          );

          expect(highCancellation.cancellationRate, greaterThan(10.0));
        });
      });
    });

    group('StaffPerformanceAnalytics', () {
      group('creation', () {
        test('should create StaffPerformanceAnalytics with valid data', () {
          final analytics = StaffPerformanceAnalytics(
            id: UserId.generate(),
            staffId: userId,
            staffName: 'John Chef',
            role: UserRole.lineCook,
            periodStart: recordedAt.subtract(const Duration(days: 1)),
            periodEnd: recordedAt,
            ordersCompleted: 45,
            averageOrderTime: const Duration(minutes: 8),
            errorCount: 2,
            efficiencyScore: 87.5,
            customersServed: 40,
            customerSatisfactionScore: 4.2,
            totalWorkTime: const Duration(hours: 8),
            achievements: ['fast_service', 'quality_excellence'],
            improvementAreas: ['communication', 'multitasking'],
          );

          expect(analytics.staffId, equals(userId));
          expect(analytics.staffName, equals('John Chef'));
          expect(analytics.role, equals(UserRole.lineCook));
          expect(analytics.ordersCompleted, equals(45));
          expect(
            analytics.averageOrderTime,
            equals(const Duration(minutes: 8)),
          );
          expect(analytics.errorCount, equals(2));
          expect(analytics.efficiencyScore, equals(87.5));
          expect(analytics.customersServed, equals(40));
          expect(analytics.customerSatisfactionScore, equals(4.2));
          expect(analytics.totalWorkTime, equals(const Duration(hours: 8)));
          expect(analytics.achievements, contains('fast_service'));
          expect(analytics.improvementAreas, contains('communication'));
        });
      });

      group('business rules', () {
        test('should identify high performers', () {
          final highPerformer = StaffPerformanceAnalytics(
            id: UserId.generate(),
            staffId: userId,
            staffName: 'Top Chef',
            role: UserRole.sousChef,
            periodStart: recordedAt.subtract(const Duration(days: 1)),
            periodEnd: recordedAt,
            ordersCompleted: 60,
            averageOrderTime: const Duration(minutes: 6),
            errorCount: 1,
            efficiencyScore: 95.0,
            customersServed: 55,
            customerSatisfactionScore: 8.5,
            totalWorkTime: const Duration(hours: 8),
          );

          expect(
            highPerformer.performanceRating,
            equals(PerformanceRating.excellent),
          );
          expect(highPerformer.efficiencyScore, greaterThan(90.0));
          expect(highPerformer.customerSatisfactionScore, greaterThan(4.5));
          expect(highPerformer.isTopPerformer, isTrue);
        });

        test('should identify areas for improvement', () {
          final needsImprovement = StaffPerformanceAnalytics(
            id: UserId.generate(),
            staffId: userId,
            staffName: 'Learning Chef',
            role: UserRole.prepCook,
            periodStart: recordedAt.subtract(const Duration(days: 1)),
            periodEnd: recordedAt,
            ordersCompleted: 20,
            averageOrderTime: const Duration(minutes: 15),
            errorCount: 5,
            efficiencyScore: 65.0,
            customersServed: 18,
            customerSatisfactionScore: 3.2,
            totalWorkTime: const Duration(hours: 8),
          );

          expect(
            needsImprovement.performanceRating,
            equals(PerformanceRating.needsImprovement),
          );
          expect(needsImprovement.efficiencyScore, lessThan(70.0));
          expect(needsImprovement.customerSatisfactionScore, lessThan(3.5));
          expect(needsImprovement.needsTraining, isTrue);
        });

        test('should calculate orders per hour', () {
          final analytics = StaffPerformanceAnalytics(
            id: UserId.generate(),
            staffId: userId,
            staffName: 'Test Chef',
            role: UserRole.lineCook,
            periodStart: recordedAt.subtract(const Duration(days: 1)),
            periodEnd: recordedAt,
            ordersCompleted: 32,
            averageOrderTime: const Duration(minutes: 8),
            errorCount: 2,
            efficiencyScore: 80.0,
            customersServed: 30,
            customerSatisfactionScore: 4.0,
            totalWorkTime: const Duration(hours: 8),
          );

          expect(analytics.ordersPerHour, equals(4.0)); // 32 orders / 8 hours
        });
      });
    });

    group('KitchenEfficiencyAnalytics', () {
      group('creation', () {
        test('should create KitchenEfficiencyAnalytics with valid data', () {
          final station1Id = UserId('station-001');
          final station2Id = UserId('station-002');

          final analytics = KitchenEfficiencyAnalytics(
            id: UserId.generate(),
            date: recordedAt,
            stationUtilization: {station1Id: 85.0, station2Id: 78.0},
            stationAverageTime: {station1Id: const Duration(minutes: 12)},
            stationOrderCount: {station1Id: 45, station2Id: 38},
            overallEfficiency: 82.3,
            averageOrderTime: const Duration(minutes: 12),
            peakHourAverageTime: const Duration(minutes: 18),
            bottleneckStationCount: 1,
            bottleneckStations: [station1Id],
            capacityUtilization: 78.5,
            efficiencyIssues: ['Peak hour bottlenecks'],
            optimizationSuggestions: ['Add prep station capacity'],
          );

          expect(analytics.date, equals(recordedAt));
          expect(analytics.stationUtilization[station1Id], equals(85.0));
          expect(
            analytics.stationAverageTime[station1Id],
            equals(const Duration(minutes: 12)),
          );
          expect(analytics.stationOrderCount[station1Id], equals(45));
          expect(analytics.overallEfficiency, equals(82.3));
          expect(
            analytics.averageOrderTime,
            equals(const Duration(minutes: 12)),
          );
          expect(
            analytics.peakHourAverageTime,
            equals(const Duration(minutes: 18)),
          );
          expect(analytics.bottleneckStationCount, equals(1));
          expect(analytics.bottleneckStations, contains(station1Id));
          expect(analytics.capacityUtilization, equals(78.5));
          expect(analytics.efficiencyIssues, contains('Peak hour bottlenecks'));
          expect(
            analytics.optimizationSuggestions,
            contains('Add prep station capacity'),
          );
        });
      });

      group('business rules', () {
        test('should identify efficiency bottlenecks', () {
          final analytics = KitchenEfficiencyAnalytics(
            id: UserId.generate(),
            date: recordedAt,
            stationUtilization: {stationId: 95.0, userId: 55.0}, // Imbalanced
            overallEfficiency: 45.0, // Poor efficiency
            averageOrderTime: const Duration(minutes: 20), // Slow
            peakHourAverageTime: const Duration(minutes: 35), // Very slow
            bottleneckStationCount: 3,
            capacityUtilization: 45.0, // Low capacity usage
          );

          // Check for performance issues
          expect(analytics.averageOrderTime.inMinutes, greaterThan(15));
          expect(analytics.overallEfficiency, lessThan(60.0));
          expect(analytics.bottleneckStationCount, greaterThan(2));
          expect(analytics.isOperatingEfficiently, isFalse);
        });

        test('should identify optimal performance', () {
          final analytics = KitchenEfficiencyAnalytics(
            id: UserId.generate(),
            date: recordedAt,
            stationUtilization: {stationId: 82.0, userId: 78.0}, // Balanced
            overallEfficiency: 92.5, // Excellent
            averageOrderTime: const Duration(minutes: 8), // Fast
            peakHourAverageTime: const Duration(
              minutes: 12,
            ), // Good under pressure
            bottleneckStationCount: 0,
            capacityUtilization: 85.0, // Optimal capacity usage
          );

          expect(analytics.averageOrderTime.inMinutes, lessThan(10));
          expect(analytics.overallEfficiency, greaterThan(90.0));
          expect(analytics.bottleneckStationCount, equals(0));
          expect(analytics.isOperatingEfficiently, isTrue);
        });

        test('should identify station utilization patterns', () {
          final highUtilizationStation = UserId('high-station');
          final lowUtilizationStation = UserId('low-station');

          final analytics = KitchenEfficiencyAnalytics(
            id: UserId.generate(),
            date: recordedAt,
            stationUtilization: {
              highUtilizationStation: 95.0, // High utilization
              lowUtilizationStation: 45.0, // Low utilization
            },
            overallEfficiency: 75.0,
            averageOrderTime: const Duration(minutes: 12),
            peakHourAverageTime: const Duration(minutes: 15),
            bottleneckStationCount: 1,
            capacityUtilization: 70.0,
          );

          expect(analytics.mostUtilizedStation, equals(highUtilizationStation));
          expect(analytics.leastUtilizedStation, equals(lowUtilizationStation));
          expect(analytics.needsRebalancing, isTrue); // 50% difference
        });

        test('should detect balanced operations', () {
          final analytics = KitchenEfficiencyAnalytics(
            id: UserId.generate(),
            date: recordedAt,
            stationUtilization: {
              stationId: 82.0,
              userId: 78.0,
            }, // Well balanced (4% difference)
            overallEfficiency: 85.0,
            averageOrderTime: const Duration(minutes: 10),
            peakHourAverageTime: const Duration(minutes: 13),
            bottleneckStationCount: 0,
            capacityUtilization: 80.0,
          );

          expect(
            analytics.needsRebalancing,
            isFalse,
          ); // Less than 40% difference
          expect(analytics.isOperatingEfficiently, isTrue);
        });
      });
    });
  });
}
