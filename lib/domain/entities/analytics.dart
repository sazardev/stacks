import '../value_objects/user_id.dart';
import '../value_objects/time.dart';
import 'user.dart';

/// Metric types for kitchen analytics
enum MetricType {
  /// Order completion time
  orderCompletionTime,

  /// Station efficiency
  stationEfficiency,

  /// Staff performance
  staffPerformance,

  /// Food cost percentage
  foodCostPercentage,

  /// Waste percentage
  wastePercentage,

  /// Customer satisfaction
  customerSatisfaction,

  /// Revenue per hour
  revenuePerHour,

  /// Order accuracy
  orderAccuracy,

  /// Temperature compliance
  temperatureCompliance,

  /// Inventory turnover
  inventoryTurnover,
}

/// Time period for analytics
enum AnalyticsPeriod {
  /// Current hour
  hourly,

  /// Current day
  daily,

  /// Current week
  weekly,

  /// Current month
  monthly,

  /// Current quarter
  quarterly,

  /// Current year
  yearly,

  /// Custom date range
  custom,
}

/// Performance rating levels
enum PerformanceRating {
  /// Excellent performance (90-100%)
  excellent,

  /// Good performance (80-89%)
  good,

  /// Satisfactory performance (70-79%)
  satisfactory,

  /// Needs improvement (60-69%)
  needsImprovement,

  /// Poor performance (below 60%)
  poor,
}

/// Kitchen metrics data point
class KitchenMetric {
  final UserId _id;
  final MetricType _type;
  final String _name;
  final double _value;
  final String _unit;
  final double? _target;
  final double? _previousValue;
  final Time _recordedAt;
  final AnalyticsPeriod _period;
  final UserId? _stationId;
  final UserId? _userId;
  final Map<String, dynamic> _metadata;

  /// Creates a KitchenMetric
  KitchenMetric({
    required UserId id,
    required MetricType type,
    required String name,
    required double value,
    required String unit,
    double? target,
    double? previousValue,
    required Time recordedAt,
    required AnalyticsPeriod period,
    UserId? stationId,
    UserId? userId,
    Map<String, dynamic>? metadata,
  }) : _id = id,
       _type = type,
       _name = name,
       _value = value,
       _unit = unit,
       _target = target,
       _previousValue = previousValue,
       _recordedAt = recordedAt,
       _period = period,
       _stationId = stationId,
       _userId = userId,
       _metadata = Map.unmodifiable(metadata ?? {});

  /// Metric ID
  UserId get id => _id;

  /// Metric type
  MetricType get type => _type;

  /// Metric name
  String get name => _name;

  /// Metric value
  double get value => _value;

  /// Unit of measurement
  String get unit => _unit;

  /// Target value
  double? get target => _target;

  /// Previous period value
  double? get previousValue => _previousValue;

  /// When metric was recorded
  Time get recordedAt => _recordedAt;

  /// Time period for metric
  AnalyticsPeriod get period => _period;

  /// Associated station ID
  UserId? get stationId => _stationId;

  /// Associated user ID
  UserId? get userId => _userId;

  /// Additional metadata
  Map<String, dynamic> get metadata => _metadata;

  /// Business rule: Calculate percentage change from previous value
  double? get percentageChange {
    if (_previousValue == null || _previousValue == 0) return null;
    return ((_value - _previousValue) / _previousValue) * 100;
  }

  /// Business rule: Check if metric meets target
  bool get meetsTarget {
    if (_target == null) return true;
    return _value >= _target;
  }

  /// Business rule: Get performance rating
  PerformanceRating get performanceRating {
    if (_target == null) return PerformanceRating.satisfactory;

    final percentage = (_value / _target) * 100;

    if (percentage >= 90) return PerformanceRating.excellent;
    if (percentage >= 80) return PerformanceRating.good;
    if (percentage >= 70) return PerformanceRating.satisfactory;
    if (percentage >= 60) return PerformanceRating.needsImprovement;
    return PerformanceRating.poor;
  }

  /// Business rule: Check if metric is trending up
  bool get isTrendingUp {
    final change = percentageChange;
    return change != null && change > 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KitchenMetric &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'KitchenMetric(type: $_type, value: $_value $_unit, rating: $performanceRating)';
}

/// Kitchen performance report
class PerformanceReport {
  final UserId _id;
  final String _reportName;
  final AnalyticsPeriod _period;
  final Time _periodStart;
  final Time _periodEnd;
  final List<KitchenMetric> _metrics;
  final double _overallScore;
  final PerformanceRating _overallRating;
  final List<String> _insights;
  final List<String> _recommendations;
  final UserId _generatedBy;
  final Time _generatedAt;

  /// Creates a PerformanceReport
  PerformanceReport({
    required UserId id,
    required String reportName,
    required AnalyticsPeriod period,
    required Time periodStart,
    required Time periodEnd,
    List<KitchenMetric>? metrics,
    required double overallScore,
    required PerformanceRating overallRating,
    List<String>? insights,
    List<String>? recommendations,
    required UserId generatedBy,
    required Time generatedAt,
  }) : _id = id,
       _reportName = reportName,
       _period = period,
       _periodStart = periodStart,
       _periodEnd = periodEnd,
       _metrics = List.unmodifiable(metrics ?? []),
       _overallScore = overallScore,
       _overallRating = overallRating,
       _insights = List.unmodifiable(insights ?? []),
       _recommendations = List.unmodifiable(recommendations ?? []),
       _generatedBy = generatedBy,
       _generatedAt = generatedAt;

  /// Report ID
  UserId get id => _id;

  /// Report name
  String get reportName => _reportName;

  /// Reporting period
  AnalyticsPeriod get period => _period;

  /// Period start time
  Time get periodStart => _periodStart;

  /// Period end time
  Time get periodEnd => _periodEnd;

  /// Metrics included in report
  List<KitchenMetric> get metrics => _metrics;

  /// Overall performance score (0-100)
  double get overallScore => _overallScore;

  /// Overall performance rating
  PerformanceRating get overallRating => _overallRating;

  /// Key insights
  List<String> get insights => _insights;

  /// Improvement recommendations
  List<String> get recommendations => _recommendations;

  /// User who generated the report
  UserId get generatedBy => _generatedBy;

  /// When report was generated
  Time get generatedAt => _generatedAt;

  /// Business rule: Get metrics by type
  List<KitchenMetric> getMetricsByType(MetricType type) {
    return _metrics.where((metric) => metric.type == type).toList();
  }

  /// Business rule: Get metrics by station
  List<KitchenMetric> getMetricsByStation(UserId stationId) {
    return _metrics.where((metric) => metric.stationId == stationId).toList();
  }

  /// Business rule: Get metrics that need improvement
  List<KitchenMetric> get metricsNeedingImprovement {
    return _metrics
        .where(
          (metric) =>
              metric.performanceRating == PerformanceRating.needsImprovement ||
              metric.performanceRating == PerformanceRating.poor,
        )
        .toList();
  }

  /// Business rule: Get top performing metrics
  List<KitchenMetric> get topPerformingMetrics {
    return _metrics
        .where(
          (metric) => metric.performanceRating == PerformanceRating.excellent,
        )
        .toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerformanceReport &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'PerformanceReport(name: $_reportName, score: $_overallScore, rating: $_overallRating)';
}

/// Order analytics data
class OrderAnalytics {
  final UserId _id;
  final Time _date;
  final int _totalOrders;
  final double _averageOrderValue;
  final Duration _averageCompletionTime;
  final Duration _peakHourCompletionTime;
  final int _cancelledOrders;
  final double _cancellationRate;
  final int _refundedOrders;
  final double _refundRate;
  final Map<String, int> _popularItems;
  final Map<String, double> _revenueByCategory;
  final Map<int, int> _ordersByHour;

  /// Creates OrderAnalytics
  OrderAnalytics({
    required UserId id,
    required Time date,
    required int totalOrders,
    required double averageOrderValue,
    required Duration averageCompletionTime,
    required Duration peakHourCompletionTime,
    required int cancelledOrders,
    required int refundedOrders,
    Map<String, int>? popularItems,
    Map<String, double>? revenueByCategory,
    Map<int, int>? ordersByHour,
  }) : _id = id,
       _date = date,
       _totalOrders = totalOrders,
       _averageOrderValue = averageOrderValue,
       _averageCompletionTime = averageCompletionTime,
       _peakHourCompletionTime = peakHourCompletionTime,
       _cancelledOrders = cancelledOrders,
       _cancellationRate = totalOrders > 0
           ? (cancelledOrders / totalOrders) * 100
           : 0,
       _refundedOrders = refundedOrders,
       _refundRate = totalOrders > 0 ? (refundedOrders / totalOrders) * 100 : 0,
       _popularItems = Map.unmodifiable(popularItems ?? {}),
       _revenueByCategory = Map.unmodifiable(revenueByCategory ?? {}),
       _ordersByHour = Map.unmodifiable(ordersByHour ?? {});

  /// Analytics ID
  UserId get id => _id;

  /// Analysis date
  Time get date => _date;

  /// Total orders processed
  int get totalOrders => _totalOrders;

  /// Average order value
  double get averageOrderValue => _averageOrderValue;

  /// Average order completion time
  Duration get averageCompletionTime => _averageCompletionTime;

  /// Completion time during peak hours
  Duration get peakHourCompletionTime => _peakHourCompletionTime;

  /// Number of cancelled orders
  int get cancelledOrders => _cancelledOrders;

  /// Order cancellation rate (percentage)
  double get cancellationRate => _cancellationRate;

  /// Number of refunded orders
  int get refundedOrders => _refundedOrders;

  /// Order refund rate (percentage)
  double get refundRate => _refundRate;

  /// Popular items and their order counts
  Map<String, int> get popularItems => _popularItems;

  /// Revenue breakdown by category
  Map<String, double> get revenueByCategory => _revenueByCategory;

  /// Orders distributed by hour of day
  Map<int, int> get ordersByHour => _ordersByHour;

  /// Business rule: Get total revenue
  double get totalRevenue => _averageOrderValue * _totalOrders;

  /// Business rule: Get successful orders
  int get successfulOrders => _totalOrders - _cancelledOrders - _refundedOrders;

  /// Business rule: Get success rate
  double get successRate =>
      _totalOrders > 0 ? (successfulOrders / _totalOrders) * 100 : 0;

  /// Business rule: Get peak hour (hour with most orders)
  int? get peakHour {
    if (_ordersByHour.isEmpty) return null;
    return _ordersByHour.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Business rule: Check if performance is acceptable
  bool get isPerformanceAcceptable {
    return _cancellationRate < 10 && // Less than 10% cancellation
        _refundRate < 5 && // Less than 5% refunds
        _averageCompletionTime.inMinutes < 30; // Under 30 minutes average
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderAnalytics &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'OrderAnalytics(date: $_date, orders: $_totalOrders, success: ${successRate.toStringAsFixed(1)}%)';
}

/// Staff performance analytics
class StaffPerformanceAnalytics {
  final UserId _id;
  final UserId _staffId;
  final String _staffName;
  final UserRole _role;
  final Time _periodStart;
  final Time _periodEnd;
  final int _ordersCompleted;
  final Duration _averageOrderTime;
  final int _errorCount;
  final double _errorRate;
  final double _efficiencyScore;
  final int _customersServed;
  final double _customerSatisfactionScore;
  final Duration _totalWorkTime;
  final List<String> _achievements;
  final List<String> _improvementAreas;

  /// Creates StaffPerformanceAnalytics
  StaffPerformanceAnalytics({
    required UserId id,
    required UserId staffId,
    required String staffName,
    required UserRole role,
    required Time periodStart,
    required Time periodEnd,
    required int ordersCompleted,
    required Duration averageOrderTime,
    required int errorCount,
    required double efficiencyScore,
    required int customersServed,
    required double customerSatisfactionScore,
    required Duration totalWorkTime,
    List<String>? achievements,
    List<String>? improvementAreas,
  }) : _id = id,
       _staffId = staffId,
       _staffName = staffName,
       _role = role,
       _periodStart = periodStart,
       _periodEnd = periodEnd,
       _ordersCompleted = ordersCompleted,
       _averageOrderTime = averageOrderTime,
       _errorCount = errorCount,
       _errorRate = ordersCompleted > 0
           ? (errorCount / ordersCompleted) * 100
           : 0,
       _efficiencyScore = efficiencyScore,
       _customersServed = customersServed,
       _customerSatisfactionScore = customerSatisfactionScore,
       _totalWorkTime = totalWorkTime,
       _achievements = List.unmodifiable(achievements ?? []),
       _improvementAreas = List.unmodifiable(improvementAreas ?? []);

  /// Analytics ID
  UserId get id => _id;

  /// Staff member ID
  UserId get staffId => _staffId;

  /// Staff member name
  String get staffName => _staffName;

  /// Staff role
  UserRole get role => _role;

  /// Period start
  Time get periodStart => _periodStart;

  /// Period end
  Time get periodEnd => _periodEnd;

  /// Orders completed
  int get ordersCompleted => _ordersCompleted;

  /// Average time per order
  Duration get averageOrderTime => _averageOrderTime;

  /// Number of errors
  int get errorCount => _errorCount;

  /// Error rate percentage
  double get errorRate => _errorRate;

  /// Efficiency score (0-100)
  double get efficiencyScore => _efficiencyScore;

  /// Customers served
  int get customersServed => _customersServed;

  /// Customer satisfaction score (0-10)
  double get customerSatisfactionScore => _customerSatisfactionScore;

  /// Total work time
  Duration get totalWorkTime => _totalWorkTime;

  /// Achievements this period
  List<String> get achievements => _achievements;

  /// Areas for improvement
  List<String> get improvementAreas => _improvementAreas;

  /// Business rule: Get orders per hour
  double get ordersPerHour {
    if (_totalWorkTime.inHours == 0) return 0;
    return _ordersCompleted / _totalWorkTime.inHours;
  }

  /// Business rule: Get performance rating
  PerformanceRating get performanceRating {
    if (_efficiencyScore >= 90) return PerformanceRating.excellent;
    if (_efficiencyScore >= 80) return PerformanceRating.good;
    if (_efficiencyScore >= 70) return PerformanceRating.satisfactory;
    if (_efficiencyScore >= 60) return PerformanceRating.needsImprovement;
    return PerformanceRating.poor;
  }

  /// Business rule: Check if staff member is top performer
  bool get isTopPerformer {
    return _efficiencyScore >= 90 &&
        _errorRate < 5 &&
        _customerSatisfactionScore >= 8.0;
  }

  /// Business rule: Check if staff needs training
  bool get needsTraining {
    return _errorRate > 15 ||
        _efficiencyScore < 60 ||
        _customerSatisfactionScore < 6.0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaffPerformanceAnalytics &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'StaffPerformanceAnalytics(staff: $_staffName, efficiency: $_efficiencyScore%, rating: $performanceRating)';
}

/// Kitchen efficiency analytics
class KitchenEfficiencyAnalytics {
  final UserId _id;
  final Time _date;
  final Map<UserId, double> _stationUtilization;
  final Map<UserId, Duration> _stationAverageTime;
  final Map<UserId, int> _stationOrderCount;
  final double _overallEfficiency;
  final Duration _averageOrderTime;
  final Duration _peakHourAverageTime;
  final int _bottleneckStationCount;
  final List<UserId> _bottleneckStations;
  final double _capacityUtilization;
  final List<String> _efficiencyIssues;
  final List<String> _optimizationSuggestions;

  /// Creates KitchenEfficiencyAnalytics
  KitchenEfficiencyAnalytics({
    required UserId id,
    required Time date,
    Map<UserId, double>? stationUtilization,
    Map<UserId, Duration>? stationAverageTime,
    Map<UserId, int>? stationOrderCount,
    required double overallEfficiency,
    required Duration averageOrderTime,
    required Duration peakHourAverageTime,
    required int bottleneckStationCount,
    List<UserId>? bottleneckStations,
    required double capacityUtilization,
    List<String>? efficiencyIssues,
    List<String>? optimizationSuggestions,
  }) : _id = id,
       _date = date,
       _stationUtilization = Map.unmodifiable(stationUtilization ?? {}),
       _stationAverageTime = Map.unmodifiable(stationAverageTime ?? {}),
       _stationOrderCount = Map.unmodifiable(stationOrderCount ?? {}),
       _overallEfficiency = overallEfficiency,
       _averageOrderTime = averageOrderTime,
       _peakHourAverageTime = peakHourAverageTime,
       _bottleneckStationCount = bottleneckStationCount,
       _bottleneckStations = List.unmodifiable(bottleneckStations ?? []),
       _capacityUtilization = capacityUtilization,
       _efficiencyIssues = List.unmodifiable(efficiencyIssues ?? []),
       _optimizationSuggestions = List.unmodifiable(
         optimizationSuggestions ?? [],
       );

  /// Analytics ID
  UserId get id => _id;

  /// Analysis date
  Time get date => _date;

  /// Station utilization percentages
  Map<UserId, double> get stationUtilization => _stationUtilization;

  /// Average time per station
  Map<UserId, Duration> get stationAverageTime => _stationAverageTime;

  /// Order count per station
  Map<UserId, int> get stationOrderCount => _stationOrderCount;

  /// Overall kitchen efficiency (0-100)
  double get overallEfficiency => _overallEfficiency;

  /// Average order completion time
  Duration get averageOrderTime => _averageOrderTime;

  /// Average time during peak hours
  Duration get peakHourAverageTime => _peakHourAverageTime;

  /// Number of bottleneck stations
  int get bottleneckStationCount => _bottleneckStationCount;

  /// List of bottleneck stations
  List<UserId> get bottleneckStations => _bottleneckStations;

  /// Overall capacity utilization (0-100)
  double get capacityUtilization => _capacityUtilization;

  /// Identified efficiency issues
  List<String> get efficiencyIssues => _efficiencyIssues;

  /// Optimization suggestions
  List<String> get optimizationSuggestions => _optimizationSuggestions;

  /// Business rule: Check if kitchen is operating efficiently
  bool get isOperatingEfficiently {
    return _overallEfficiency >= 80 &&
        _bottleneckStationCount <= 1 &&
        _capacityUtilization >= 70 &&
        _capacityUtilization <= 95;
  }

  /// Business rule: Get least utilized station
  UserId? get leastUtilizedStation {
    if (_stationUtilization.isEmpty) return null;
    return _stationUtilization.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
  }

  /// Business rule: Get most utilized station
  UserId? get mostUtilizedStation {
    if (_stationUtilization.isEmpty) return null;
    return _stationUtilization.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Business rule: Check if rebalancing is needed
  bool get needsRebalancing {
    if (_stationUtilization.length < 2) return false;

    final utilizationValues = _stationUtilization.values.toList();
    final maxUtilization = utilizationValues.reduce((a, b) => a > b ? a : b);
    final minUtilization = utilizationValues.reduce((a, b) => a < b ? a : b);

    // If difference is more than 40%, rebalancing is needed
    return (maxUtilization - minUtilization) > 40;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KitchenEfficiencyAnalytics &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'KitchenEfficiencyAnalytics(date: $_date, efficiency: $_overallEfficiency%, capacity: $_capacityUtilization%)';
}
