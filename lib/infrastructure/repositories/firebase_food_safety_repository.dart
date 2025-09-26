// Firebase Food Safety Repository Implementation - Production Ready
// Real Firestore implementation for food safety management with real-time compliance tracking

import 'dart:developer' as developer;
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/food_safety.dart';
import '../../domain/repositories/food_safety_repository.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';
import '../mappers/food_safety_mapper.dart';
import '../config/firebase_collections.dart';

@LazySingleton(as: FoodSafetyRepository)
class FirebaseFoodSafetyRepository implements FoodSafetyRepository {
  final FirebaseFirestore _firestore;
  final FoodSafetyMapper _foodSafetyMapper;

  FirebaseFoodSafetyRepository({
    required FirebaseFirestore firestore,
    required FoodSafetyMapper foodSafetyMapper,
  }) : _firestore = firestore,
       _foodSafetyMapper = foodSafetyMapper;

  // ======================== Temperature Log Operations ========================

  @override
  Future<TemperatureLog> createTemperatureLog(
    TemperatureLog temperatureLog,
  ) async {
    try {
      developer.log(
        'Creating temperature log: ${temperatureLog.id.value}',
        name: 'FirebaseFoodSafetyRepository',
      );

      final logData = _foodSafetyMapper.temperatureLogToFirestore(
        temperatureLog,
      );

      await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('temperature_logs')
          .collection('logs')
          .doc(temperatureLog.id.value)
          .set(logData);

      // Check for temperature violations and create alerts if necessary
      await _checkTemperatureViolations(temperatureLog);

      return temperatureLog;
    } catch (e) {
      developer.log(
        'Error creating temperature log: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<TemperatureLog> updateTemperatureLog(
    TemperatureLog temperatureLog,
  ) async {
    try {
      final logData = _foodSafetyMapper.temperatureLogToFirestore(
        temperatureLog,
      );

      await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('temperature_logs')
          .collection('logs')
          .doc(temperatureLog.id.value)
          .update(logData);

      return temperatureLog;
    } catch (e) {
      developer.log(
        'Error updating temperature log: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<TemperatureLog?> getTemperatureLogById(UserId id) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('temperature_logs')
          .collection('logs')
          .doc(id.value)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return _foodSafetyMapper.temperatureLogFromFirestore(doc.data()!, doc.id);
    } catch (e) {
      developer.log(
        'Error getting temperature log by ID: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<TemperatureLog>> getTemperatureLogsByLocation(
    TemperatureLocation location,
  ) async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('temperature_logs')
          .collection('logs')
          .where('location', isEqualTo: _temperatureLocationToString(location))
          .orderBy('recordedAt', descending: true)
          .get();

      return query.docs
          .map(
            (doc) => _foodSafetyMapper.temperatureLogFromFirestore(
              doc.data(),
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting temperature logs by location: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<TemperatureLog>> getTemperatureLogsByEquipment(
    String equipmentId,
  ) async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('temperature_logs')
          .collection('logs')
          .where('equipmentId', isEqualTo: equipmentId)
          .orderBy('recordedAt', descending: true)
          .get();

      return query.docs
          .map(
            (doc) => _foodSafetyMapper.temperatureLogFromFirestore(
              doc.data(),
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting temperature logs by equipment: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<TemperatureLog>> getTemperatureLogsByDateRange(
    Time startDate,
    Time endDate,
  ) async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('temperature_logs')
          .collection('logs')
          .where(
            'recordedAt',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
          )
          .where(
            'recordedAt',
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch,
          )
          .orderBy('recordedAt', descending: true)
          .get();

      return query.docs
          .map(
            (doc) => _foodSafetyMapper.temperatureLogFromFirestore(
              doc.data(),
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting temperature logs by date range: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<TemperatureLog>> getTemperatureLogsRequiringAction() async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('temperature_logs')
          .collection('logs')
          .where('requiresCorrectiveAction', isEqualTo: true)
          .orderBy('recordedAt', descending: true)
          .get();

      return query.docs
          .map(
            (doc) => _foodSafetyMapper.temperatureLogFromFirestore(
              doc.data(),
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting temperature logs requiring action: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<TemperatureLog>> getTemperatureLogsOutsideSafeRange() async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('temperature_logs')
          .collection('logs')
          .where('isWithinSafeRange', isEqualTo: false)
          .orderBy('recordedAt', descending: true)
          .get();

      return query.docs
          .map(
            (doc) => _foodSafetyMapper.temperatureLogFromFirestore(
              doc.data(),
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting temperature logs outside safe range: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<TemperatureLog>> getTemperatureLogsByUser(
    UserId recordedBy,
  ) async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('temperature_logs')
          .collection('logs')
          .where('recordedBy', isEqualTo: recordedBy.value)
          .orderBy('recordedAt', descending: true)
          .get();

      return query.docs
          .map(
            (doc) => _foodSafetyMapper.temperatureLogFromFirestore(
              doc.data(),
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting temperature logs by user: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteTemperatureLog(UserId id) async {
    try {
      await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('temperature_logs')
          .collection('logs')
          .doc(id.value)
          .delete();
    } catch (e) {
      developer.log(
        'Error deleting temperature log: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  // ======================== Food Safety Violation Operations ========================

  @override
  Future<FoodSafetyViolation> createFoodSafetyViolation(
    FoodSafetyViolation violation,
  ) async {
    try {
      developer.log(
        'Creating food safety violation: ${violation.id.value}',
        name: 'FirebaseFoodSafetyRepository',
      );

      final violationData = _foodSafetyMapper.violationToFirestore(violation);

      await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('violations')
          .collection('reports')
          .doc(violation.id.value)
          .set(violationData);

      return violation;
    } catch (e) {
      developer.log(
        'Error creating food safety violation: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<FoodSafetyViolation> updateFoodSafetyViolation(
    FoodSafetyViolation violation,
  ) async {
    try {
      final violationData = _foodSafetyMapper.violationToFirestore(violation);

      await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('violations')
          .collection('reports')
          .doc(violation.id.value)
          .update(violationData);

      return violation;
    } catch (e) {
      developer.log(
        'Error updating food safety violation: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<FoodSafetyViolation?> getFoodSafetyViolationById(UserId id) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('violations')
          .collection('reports')
          .doc(id.value)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return _foodSafetyMapper.violationFromFirestore(doc.data()!, doc.id);
    } catch (e) {
      developer.log(
        'Error getting food safety violation by ID: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<FoodSafetyViolation>> getViolationsByType(
    ViolationType type,
  ) async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('violations')
          .collection('reports')
          .where('type', isEqualTo: _violationTypeToString(type))
          .orderBy('reportedAt', descending: true)
          .get();

      return query.docs
          .map(
            (doc) =>
                _foodSafetyMapper.violationFromFirestore(doc.data(), doc.id),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting violations by type: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<FoodSafetyViolation>> getViolationsBySeverity(
    ViolationSeverity severity,
  ) async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('violations')
          .collection('reports')
          .where('severity', isEqualTo: _violationSeverityToString(severity))
          .orderBy('reportedAt', descending: true)
          .get();

      return query.docs
          .map(
            (doc) =>
                _foodSafetyMapper.violationFromFirestore(doc.data(), doc.id),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting violations by severity: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<FoodSafetyViolation>> getViolationsByLocation(
    TemperatureLocation location,
  ) async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('violations')
          .collection('reports')
          .where('location', isEqualTo: _temperatureLocationToString(location))
          .orderBy('reportedAt', descending: true)
          .get();

      return query.docs
          .map(
            (doc) =>
                _foodSafetyMapper.violationFromFirestore(doc.data(), doc.id),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting violations by location: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<FoodSafetyViolation>> getUnresolvedViolations() async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('violations')
          .collection('reports')
          .where('isResolved', isEqualTo: false)
          .orderBy('reportedAt', descending: true)
          .get();

      return query.docs
          .map(
            (doc) =>
                _foodSafetyMapper.violationFromFirestore(doc.data(), doc.id),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting unresolved violations: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<FoodSafetyViolation>> getOverdueViolations() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('violations')
          .collection('reports')
          .where('isResolved', isEqualTo: false)
          .where(
            'reportedAt',
            isLessThan: now - (24 * 60 * 60 * 1000),
          ) // 24 hours ago
          .orderBy('reportedAt')
          .get();

      return query.docs
          .map(
            (doc) =>
                _foodSafetyMapper.violationFromFirestore(doc.data(), doc.id),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting overdue violations: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<FoodSafetyViolation>> getViolationsAssignedToUser(
    UserId userId,
  ) async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('violations')
          .collection('reports')
          .where('assignedTo', isEqualTo: userId.value)
          .orderBy('reportedAt', descending: true)
          .get();

      return query.docs
          .map(
            (doc) =>
                _foodSafetyMapper.violationFromFirestore(doc.data(), doc.id),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting violations assigned to user: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<FoodSafetyViolation>> getViolationsByDateRange(
    Time startDate,
    Time endDate,
  ) async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('violations')
          .collection('reports')
          .where(
            'reportedAt',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
          )
          .where(
            'reportedAt',
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch,
          )
          .orderBy('reportedAt', descending: true)
          .get();

      return query.docs
          .map(
            (doc) =>
                _foodSafetyMapper.violationFromFirestore(doc.data(), doc.id),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting violations by date range: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<FoodSafetyViolation> resolveViolation(
    UserId violationId,
    List<String> correctiveActions,
    String? rootCause,
    String? preventiveAction,
  ) async {
    try {
      final violationDoc = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('violations')
          .collection('reports')
          .doc(violationId.value)
          .get();

      if (!violationDoc.exists) {
        throw Exception('Violation not found');
      }

      final violation = _foodSafetyMapper.violationFromFirestore(
        violationDoc.data()!,
        violationDoc.id,
      );

      final resolvedViolation = FoodSafetyViolation(
        id: violation.id,
        type: violation.type,
        severity: violation.severity,
        description: violation.description,
        location: violation.location,
        reportedBy: violation.reportedBy,
        assignedTo: violation.assignedTo,
        reportedAt: violation.reportedAt,
        resolvedAt: Time.now(),
        correctiveActions: correctiveActions,
        rootCause: rootCause,
        preventiveAction: preventiveAction,
        temperatureReading: violation.temperatureReading,
        orderId: violation.orderId,
        inventoryItemId: violation.inventoryItemId,
      );

      await updateFoodSafetyViolation(resolvedViolation);
      return resolvedViolation;
    } catch (e) {
      developer.log(
        'Error resolving violation: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteFoodSafetyViolation(UserId id) async {
    try {
      await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('violations')
          .collection('reports')
          .doc(id.value)
          .delete();
    } catch (e) {
      developer.log(
        'Error deleting food safety violation: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  // ======================== HACCP Control Point Operations ========================

  @override
  Future<HACCPControlPoint> createHACCPControlPoint(
    HACCPControlPoint controlPoint,
  ) async {
    try {
      developer.log(
        'Creating HACCP control point: ${controlPoint.id.value}',
        name: 'FirebaseFoodSafetyRepository',
      );

      final controlPointData = _foodSafetyMapper.haccpControlPointToFirestore(
        controlPoint,
      );

      await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('haccp_control_points')
          .collection('points')
          .doc(controlPoint.id.value)
          .set(controlPointData);

      return controlPoint;
    } catch (e) {
      developer.log(
        'Error creating HACCP control point: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<HACCPControlPoint> updateHACCPControlPoint(
    HACCPControlPoint controlPoint,
  ) async {
    try {
      final controlPointData = _foodSafetyMapper.haccpControlPointToFirestore(
        controlPoint,
      );

      await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('haccp_control_points')
          .collection('points')
          .doc(controlPoint.id.value)
          .update(controlPointData);

      return controlPoint;
    } catch (e) {
      developer.log(
        'Error updating HACCP control point: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<HACCPControlPoint?> getHACCPControlPointById(UserId id) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('haccp_control_points')
          .collection('points')
          .doc(id.value)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return _foodSafetyMapper.haccpControlPointFromFirestore(
        doc.data()!,
        doc.id,
      );
    } catch (e) {
      developer.log(
        'Error getting HACCP control point by ID: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<HACCPControlPoint>> getControlPointsByType(CCPType type) async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('haccp_control_points')
          .collection('points')
          .where('ccpType', isEqualTo: _ccpTypeToString(type))
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map(
            (doc) => _foodSafetyMapper.haccpControlPointFromFirestore(
              doc.data(),
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting control points by type: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<HACCPControlPoint>> getActiveControlPoints() async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('haccp_control_points')
          .collection('points')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map(
            (doc) => _foodSafetyMapper.haccpControlPointFromFirestore(
              doc.data(),
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting active control points: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<HACCPControlPoint>> getControlPointsRequiringMonitoring() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('haccp_control_points')
          .collection('points')
          .where('isActive', isEqualTo: true)
          .where(
            'lastMonitoredAt',
            isLessThan: now - (4 * 60 * 60 * 1000),
          ) // 4 hours ago
          .orderBy('lastMonitoredAt')
          .get();

      return query.docs
          .map(
            (doc) => _foodSafetyMapper.haccpControlPointFromFirestore(
              doc.data(),
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting control points requiring monitoring: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<HACCPControlPoint>> getControlPointsByResponsibleUser(
    UserId userId,
  ) async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('haccp_control_points')
          .collection('points')
          .where('responsibleUser', isEqualTo: userId.value)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map(
            (doc) => _foodSafetyMapper.haccpControlPointFromFirestore(
              doc.data(),
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting control points by responsible user: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<HACCPControlPoint> updateControlPointMonitoring(
    UserId controlPointId,
    Time monitoredAt,
  ) async {
    try {
      final controlPointDoc = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('haccp_control_points')
          .collection('points')
          .doc(controlPointId.value)
          .get();

      if (!controlPointDoc.exists) {
        throw Exception('Control point not found');
      }

      await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('haccp_control_points')
          .collection('points')
          .doc(controlPointId.value)
          .update({'lastMonitoredAt': monitoredAt.millisecondsSinceEpoch});

      return _foodSafetyMapper.haccpControlPointFromFirestore(
        controlPointDoc.data()!,
        controlPointDoc.id,
      );
    } catch (e) {
      developer.log(
        'Error updating control point monitoring: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<HACCPControlPoint> deactivateControlPoint(
    UserId controlPointId,
  ) async {
    try {
      final controlPointDoc = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('haccp_control_points')
          .collection('points')
          .doc(controlPointId.value)
          .get();

      if (!controlPointDoc.exists) {
        throw Exception('Control point not found');
      }

      await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('haccp_control_points')
          .collection('points')
          .doc(controlPointId.value)
          .update({'isActive': false});

      return _foodSafetyMapper.haccpControlPointFromFirestore(
        controlPointDoc.data()!,
        controlPointDoc.id,
      );
    } catch (e) {
      developer.log(
        'Error deactivating control point: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<HACCPControlPoint> activateControlPoint(UserId controlPointId) async {
    try {
      final controlPointDoc = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('haccp_control_points')
          .collection('points')
          .doc(controlPointId.value)
          .get();

      if (!controlPointDoc.exists) {
        throw Exception('Control point not found');
      }

      await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('haccp_control_points')
          .collection('points')
          .doc(controlPointId.value)
          .update({'isActive': true});

      return _foodSafetyMapper.haccpControlPointFromFirestore(
        controlPointDoc.data()!,
        controlPointDoc.id,
      );
    } catch (e) {
      developer.log(
        'Error activating control point: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteHACCPControlPoint(UserId id) async {
    try {
      await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('haccp_control_points')
          .collection('points')
          .doc(id.value)
          .delete();
    } catch (e) {
      developer.log(
        'Error deleting HACCP control point: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  // ======================== Food Safety Audit Operations ========================

  @override
  Future<FoodSafetyAudit> createFoodSafetyAudit(FoodSafetyAudit audit) async {
    try {
      developer.log(
        'Creating food safety audit: ${audit.id.value}',
        name: 'FirebaseFoodSafetyRepository',
      );

      final auditData = _foodSafetyMapper.auditToFirestore(audit);

      await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('audits')
          .collection('reports')
          .doc(audit.id.value)
          .set(auditData);

      return audit;
    } catch (e) {
      developer.log(
        'Error creating food safety audit: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<FoodSafetyAudit> updateFoodSafetyAudit(FoodSafetyAudit audit) async {
    try {
      final auditData = _foodSafetyMapper.auditToFirestore(audit);

      await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('audits')
          .collection('reports')
          .doc(audit.id.value)
          .update(auditData);

      return audit;
    } catch (e) {
      developer.log(
        'Error updating food safety audit: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<FoodSafetyAudit?> getFoodSafetyAuditById(UserId id) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('audits')
          .collection('reports')
          .doc(id.value)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return _foodSafetyMapper.auditFromFirestore(doc.data()!, doc.id);
    } catch (e) {
      developer.log(
        'Error getting food safety audit by ID: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<FoodSafetyAudit>> getAuditsByAuditor(UserId auditor) async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('audits')
          .collection('reports')
          .where('auditorId', isEqualTo: auditor.value)
          .orderBy('auditDate', descending: true)
          .get();

      return query.docs
          .map(
            (doc) => _foodSafetyMapper.auditFromFirestore(doc.data(), doc.id),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting audits by auditor: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<FoodSafetyAudit>> getAuditsByDateRange(
    Time startDate,
    Time endDate,
  ) async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('audits')
          .collection('reports')
          .where(
            'auditDate',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
          )
          .where(
            'auditDate',
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch,
          )
          .orderBy('auditDate', descending: true)
          .get();

      return query.docs
          .map(
            (doc) => _foodSafetyMapper.auditFromFirestore(doc.data(), doc.id),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting audits by date range: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<FoodSafetyAudit>> getPassedAudits() async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('audits')
          .collection('reports')
          .where('passed', isEqualTo: true)
          .orderBy('auditDate', descending: true)
          .get();

      return query.docs
          .map(
            (doc) => _foodSafetyMapper.auditFromFirestore(doc.data(), doc.id),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting passed audits: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<FoodSafetyAudit>> getFailedAudits() async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('audits')
          .collection('reports')
          .where('passed', isEqualTo: false)
          .orderBy('auditDate', descending: true)
          .get();

      return query.docs
          .map(
            (doc) => _foodSafetyMapper.auditFromFirestore(doc.data(), doc.id),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting failed audits: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<FoodSafetyAudit>> getAuditsByMinScore(double minScore) async {
    try {
      final query = await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('audits')
          .collection('reports')
          .where('score', isGreaterThanOrEqualTo: minScore)
          .orderBy('score', descending: true)
          .get();

      return query.docs
          .map(
            (doc) => _foodSafetyMapper.auditFromFirestore(doc.data(), doc.id),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error getting audits by min score: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteFoodSafetyAudit(UserId id) async {
    try {
      await _firestore
          .collection(FirebaseCollections.foodSafety)
          .doc('audits')
          .collection('reports')
          .doc(id.value)
          .delete();
    } catch (e) {
      developer.log(
        'Error deleting food safety audit: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  // ======================== Analytics and Reporting ========================

  @override
  Future<Map<String, dynamic>> getTemperatureComplianceStats(
    Time startDate,
    Time endDate,
  ) async {
    try {
      final logs = await getTemperatureLogsByDateRange(startDate, endDate);

      if (logs.isEmpty) {
        return {
          'total_logs': 0,
          'compliant_logs': 0,
          'compliance_rate': 0.0,
          'violations': 0,
        };
      }

      final compliantLogs = logs.where((log) => log.isWithinSafeRange).length;

      return {
        'total_logs': logs.length,
        'compliant_logs': compliantLogs,
        'compliance_rate': (compliantLogs / logs.length * 100).round() / 100,
        'violations': logs.length - compliantLogs,
      };
    } catch (e) {
      developer.log(
        'Error getting temperature compliance stats: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getViolationTrends(
    Time startDate,
    Time endDate,
  ) async {
    try {
      final violations = await getViolationsByDateRange(startDate, endDate);

      final Map<String, int> violationsByType = {};
      final Map<String, int> violationsBySeverity = {};

      for (final violation in violations) {
        final typeKey = _violationTypeToString(violation.type);
        final severityKey = _violationSeverityToString(violation.severity);

        violationsByType[typeKey] = (violationsByType[typeKey] ?? 0) + 1;
        violationsBySeverity[severityKey] =
            (violationsBySeverity[severityKey] ?? 0) + 1;
      }

      return {
        'total_violations': violations.length,
        'violations_by_type': violationsByType,
        'violations_by_severity': violationsBySeverity,
        'resolved_violations': violations.where((v) => v.isResolved).length,
      };
    } catch (e) {
      developer.log(
        'Error getting violation trends: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getHACCPComplianceReport(
    Time startDate,
    Time endDate,
  ) async {
    try {
      final controlPoints = await getActiveControlPoints();
      final violations = await getViolationsByDateRange(startDate, endDate);

      return {
        'total_control_points': controlPoints.length,
        'active_control_points': controlPoints
            .where((cp) => cp.isActive)
            .length,
        'violations_in_period': violations.length,
        'control_point_violations': violations
            .where(
              (v) =>
                  v.type == ViolationType.temperatureViolation ||
                  v.type == ViolationType.timeViolation,
            )
            .length,
      };
    } catch (e) {
      developer.log(
        'Error getting HACCP compliance report: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getAuditPerformanceMetrics(
    Time startDate,
    Time endDate,
  ) async {
    try {
      final audits = await getAuditsByDateRange(startDate, endDate);

      if (audits.isEmpty) {
        return {
          'total_audits': 0,
          'passed_audits': 0,
          'pass_rate': 0.0,
          'average_score': 0.0,
        };
      }

      final passedAudits = audits.where((audit) => audit.passed).length;
      final totalScore = audits.fold<double>(
        0.0,
        (total, audit) => total + audit.score,
      );

      return {
        'total_audits': audits.length,
        'passed_audits': passedAudits,
        'pass_rate': (passedAudits / audits.length * 100).round() / 100,
        'average_score': (totalScore / audits.length * 100).round() / 100,
      };
    } catch (e) {
      developer.log(
        'Error getting audit performance metrics: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getControlPointEffectiveness(
    Time startDate,
    Time endDate,
  ) async {
    try {
      final controlPoints = await getActiveControlPoints();
      final violations = await getViolationsByDateRange(startDate, endDate);

      final controlPointViolations = violations
          .where(
            (v) =>
                v.type == ViolationType.temperatureViolation ||
                v.type == ViolationType.timeViolation ||
                v.type == ViolationType.equipmentFailure,
          )
          .length;

      return {
        'total_control_points': controlPoints.length,
        'control_point_violations': controlPointViolations,
        'effectiveness_rate': controlPoints.isEmpty
            ? 0.0
            : ((controlPoints.length - controlPointViolations) /
                          controlPoints.length *
                          100)
                      .round() /
                  100,
      };
    } catch (e) {
      developer.log(
        'Error getting control point effectiveness: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getFoodSafetyDashboardData() async {
    try {
      final now = Time.now();
      final last30Days = now.subtract(Duration(days: 30));

      final [
        temperatureStats,
        violationTrends,
        auditMetrics,
      ] = await Future.wait([
        getTemperatureComplianceStats(last30Days, now),
        getViolationTrends(last30Days, now),
        getAuditPerformanceMetrics(last30Days, now),
      ]);

      return {
        'temperature_compliance': temperatureStats,
        'violation_trends': violationTrends,
        'audit_performance': auditMetrics,
        'dashboard_updated_at': now.millisecondsSinceEpoch,
      };
    } catch (e) {
      developer.log(
        'Error getting food safety dashboard data: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getTemperatureAlertSummary() async {
    try {
      final logsRequiringAction = await getTemperatureLogsRequiringAction();
      final logsOutsideRange = await getTemperatureLogsOutsideSafeRange();

      return {
        'logs_requiring_action': logsRequiringAction.length,
        'logs_outside_safe_range': logsOutsideRange.length,
        'total_alerts': logsRequiringAction.length + logsOutsideRange.length,
      };
    } catch (e) {
      developer.log(
        'Error getting temperature alert summary: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getViolationResolutionMetrics(
    Time startDate,
    Time endDate,
  ) async {
    try {
      final violations = await getViolationsByDateRange(startDate, endDate);

      final resolvedViolations = violations.where((v) => v.isResolved).length;
      final overdueViolations = violations
          .where(
            (v) =>
                !v.isResolved &&
                v.reportedAt.isBefore(Time.now().subtract(Duration(hours: 24))),
          )
          .length;

      return {
        'total_violations': violations.length,
        'resolved_violations': resolvedViolations,
        'resolution_rate': violations.isEmpty
            ? 0.0
            : (resolvedViolations / violations.length * 100).round() / 100,
        'overdue_violations': overdueViolations,
      };
    } catch (e) {
      developer.log(
        'Error getting violation resolution metrics: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      rethrow;
    }
  }

  // ======================== Helper Methods ========================

  Future<void> _checkTemperatureViolations(TemperatureLog log) async {
    try {
      if (!log.isWithinSafeRange && log.requiresCorrectiveAction) {
        // Create automatic violation for temperature abuse
        final violation = FoodSafetyViolation(
          id: UserId.generate(),
          type: ViolationType.temperatureViolation,
          severity: ViolationSeverity.critical,
          description:
              'Temperature out of safe range: ${log.temperature}°${log.unit == TemperatureUnit.fahrenheit ? 'F' : 'C'} at ${_temperatureLocationToString(log.location)}',
          location: log.location,
          reportedBy: log.recordedBy,
          reportedAt: log.recordedAt,
          temperatureReading: log.temperature,
        );

        await createFoodSafetyViolation(violation);
      }
    } catch (e) {
      developer.log(
        'Error checking temperature violations: $e',
        name: 'FirebaseFoodSafetyRepository',
      );
      // Don't rethrow here as this is a side effect
    }
  }

  String _temperatureLocationToString(TemperatureLocation location) {
    switch (location) {
      case TemperatureLocation.walkInCooler:
        return 'walk_in_cooler';
      case TemperatureLocation.walkInFreezer:
        return 'walk_in_freezer';
      case TemperatureLocation.prepRefrigerator:
        return 'prep_refrigerator';
      case TemperatureLocation.displayCase:
        return 'display_case';
      case TemperatureLocation.grillSurface:
        return 'grill_surface';
      case TemperatureLocation.fryerOil:
        return 'fryer_oil';
      case TemperatureLocation.hotHolding:
        return 'hot_holding';
      case TemperatureLocation.coldHolding:
        return 'cold_holding';
      case TemperatureLocation.dishwasherSanitizer:
        return 'dishwasher_sanitizer';
      case TemperatureLocation.handWashSink:
        return 'hand_wash_sink';
      case TemperatureLocation.foodInternal:
        return 'food_internal';
      case TemperatureLocation.ambientRoom:
        return 'ambient_room';
    }
  }

  String _violationTypeToString(ViolationType type) {
    switch (type) {
      case ViolationType.temperatureViolation:
        return 'temperature_violation';
      case ViolationType.timeViolation:
        return 'time_violation';
      case ViolationType.crossContamination:
        return 'cross_contamination';
      case ViolationType.hygieneBreach:
        return 'hygiene_breach';
      case ViolationType.equipmentFailure:
        return 'equipment_failure';
      case ViolationType.allergenContamination:
        return 'allergen_contamination';
      case ViolationType.expiredProduct:
        return 'expired_product';
      case ViolationType.improperStorage:
        return 'improper_storage';
      case ViolationType.cleaningViolation:
        return 'cleaning_violation';
      case ViolationType.documentationMissing:
        return 'documentation_missing';
    }
  }

  String _violationSeverityToString(ViolationSeverity severity) {
    switch (severity) {
      case ViolationSeverity.minor:
        return 'minor';
      case ViolationSeverity.major:
        return 'major';
      case ViolationSeverity.critical:
        return 'critical';
      case ViolationSeverity.emergency:
        return 'emergency';
    }
  }

  String _ccpTypeToString(CCPType type) {
    switch (type) {
      case CCPType.receiving:
        return 'receiving';
      case CCPType.storage:
        return 'storage';
      case CCPType.preparation:
        return 'preparation';
      case CCPType.cooking:
        return 'cooking';
      case CCPType.hotHolding:
        return 'hot_holding';
      case CCPType.coldHolding:
        return 'cold_holding';
      case CCPType.holding:
        return 'holding';
      case CCPType.cooling:
        return 'cooling';
      case CCPType.reheating:
        return 'reheating';
      case CCPType.service:
        return 'service';
      case CCPType.sanitizerConcentration:
        return 'sanitizer_concentration';
      case CCPType.handWashing:
        return 'hand_washing';
      case CCPType.crossContaminationPrevention:
        return 'cross_contamination_prevention';
    }
  }
}
