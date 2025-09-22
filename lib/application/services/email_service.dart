import 'package:dartz/dartz.dart' show Either, Unit;
import '../../domain/entities/order.dart';
import '../../domain/entities/user.dart';
import '../../domain/failures/failures.dart';

/// Service interface for sending emails in the kitchen system
abstract class EmailService {
  /// Sends order confirmation email to customer
  Future<Either<Failure, Unit>> sendOrderConfirmation({
    required Order order,
    required String customerEmail,
    required String customerName,
  });

  /// Sends order ready notification email to customer
  Future<Either<Failure, Unit>> sendOrderReadyNotification({
    required Order order,
    required String customerEmail,
    required String customerName,
    required String pickupInstructions,
  });

  /// Sends order completed receipt email to customer
  Future<Either<Failure, Unit>> sendOrderReceipt({
    required Order order,
    required String customerEmail,
    required String customerName,
    required Map<String, dynamic> paymentDetails,
  });

  /// Sends order cancelled notification email to customer
  Future<Either<Failure, Unit>> sendOrderCancellationNotification({
    required Order order,
    required String customerEmail,
    required String customerName,
    required String cancellationReason,
    required String refundInformation,
  });

  /// Sends user registration welcome email
  Future<Either<Failure, Unit>> sendWelcomeEmail({
    required User user,
    required String temporaryPassword,
    required String loginUrl,
  });

  /// Sends password reset email to user
  Future<Either<Failure, Unit>> sendPasswordResetEmail({
    required String userEmail,
    required String userName,
    required String resetToken,
    required String resetUrl,
    required DateTime expiryTime,
  });

  /// Sends daily kitchen reports to managers
  Future<Either<Failure, Unit>> sendDailyReport({
    required List<String> managerEmails,
    required Map<String, dynamic> reportData,
    required DateTime reportDate,
  });

  /// Sends weekly performance summary to administrators
  Future<Either<Failure, Unit>> sendWeeklyPerformanceSummary({
    required List<String> adminEmails,
    required Map<String, dynamic> performanceData,
    required DateTime weekStartDate,
    required DateTime weekEndDate,
  });

  /// Sends system alert emails to administrators
  Future<Either<Failure, Unit>> sendSystemAlert({
    required List<String> adminEmails,
    required String alertTitle,
    required String alertMessage,
    required String alertLevel, // info, warning, error, critical
    required DateTime alertTime,
  });

  /// Sends staff schedule notifications
  Future<Either<Failure, Unit>> sendScheduleNotification({
    required List<String> staffEmails,
    required Map<String, dynamic> scheduleData,
    required DateTime scheduleDate,
  });

  /// Sends order delay notification to customer
  Future<Either<Failure, Unit>> sendOrderDelayNotification({
    required Order order,
    required String customerEmail,
    required String customerName,
    required int delayMinutes,
    required String delayReason,
  });

  /// Sends promotional emails to customers
  Future<Either<Failure, Unit>> sendPromotionalEmail({
    required List<String> customerEmails,
    required String subject,
    required String htmlContent,
    required String textContent,
    required Map<String, String> personalizations,
  });

  /// Sends order feedback request email to customer
  Future<Either<Failure, Unit>> sendFeedbackRequest({
    required Order order,
    required String customerEmail,
    required String customerName,
    required String feedbackUrl,
  });

  /// Sends kitchen performance alert to managers
  Future<Either<Failure, Unit>> sendPerformanceAlert({
    required List<String> managerEmails,
    required String metricName,
    required double currentValue,
    required double thresholdValue,
    required String recommendedAction,
  });

  /// Sends inventory alert emails
  Future<Either<Failure, Unit>> sendInventoryAlert({
    required List<String> managerEmails,
    required List<String> lowStockItems,
    required Map<String, int> currentQuantities,
    required Map<String, int> minimumThresholds,
  });

  /// Sends user account activation email
  Future<Either<Failure, Unit>> sendAccountActivationEmail({
    required String userEmail,
    required String userName,
    required String activationToken,
    required String activationUrl,
    required DateTime expiryTime,
  });
}
