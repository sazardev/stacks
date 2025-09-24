// Firebase Authentication Service for Restaurant Management System
// Production-ready authentication with comprehensive error handling

import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import '../../domain/failures/failures.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register new user with email and password
  Future<Either<Failure, domain.User>> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required domain.UserRole role,
  }) async {
    try {
      developer.log('Registering user: $email', name: 'AuthService');

      // Create user with email and password
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user == null) {
        return const Left(ServerFailure('Failed to create user account'));
      }

      // Update display name
      await credential.user!.updateDisplayName(name);

      // Create domain user entity
      final domainUser = domain.User(
        id: UserId(credential.user!.uid),
        email: email,
        name: name,
        role: role,
        createdAt: Time.now(),
        isActive: true,
        isAuthenticated: true,
        lastLoginAt: Time.now(),
      );

      developer.log(
        'User registered successfully: ${credential.user!.uid}',
        name: 'AuthService',
      );
      return Right(domainUser);
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Registration error: ${e.code} - ${e.message}',
        name: 'AuthService',
      );
      return Left(_mapFirebaseAuthError(e));
    } catch (e) {
      developer.log('Unexpected registration error: $e', name: 'AuthService');
      return const Left(
        ServerFailure('An unexpected error occurred during registration'),
      );
    }
  }

  /// Sign in with email and password
  Future<Either<Failure, domain.User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      developer.log('Signing in user: $email', name: 'AuthService');

      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left(ServerFailure('Failed to sign in'));
      }

      // Create domain user entity (in production, this would fetch from Firestore)
      final domainUser = domain.User(
        id: UserId(credential.user!.uid),
        email: email,
        name: credential.user!.displayName ?? 'User',
        role: domain.UserRole.lineCook, // This should be fetched from Firestore
        createdAt: Time.fromDateTime(credential.user!.metadata.creationTime!),
        isActive: true,
        isAuthenticated: true,
        lastLoginAt: Time.now(),
      );

      developer.log(
        'User signed in successfully: ${credential.user!.uid}',
        name: 'AuthService',
      );
      return Right(domainUser);
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Sign in error: ${e.code} - ${e.message}',
        name: 'AuthService',
      );
      return Left(_mapFirebaseAuthError(e));
    } catch (e) {
      developer.log('Unexpected sign in error: $e', name: 'AuthService');
      return const Left(
        ServerFailure('An unexpected error occurred during sign in'),
      );
    }
  }

  /// Sign out current user
  Future<Either<Failure, Unit>> signOut() async {
    try {
      developer.log('Signing out user', name: 'AuthService');
      await _auth.signOut();
      developer.log('User signed out successfully', name: 'AuthService');
      return const Right(unit);
    } catch (e) {
      developer.log('Sign out error: $e', name: 'AuthService');
      return const Left(ServerFailure('Failed to sign out'));
    }
  }

  /// Send password reset email
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email) async {
    try {
      developer.log(
        'Sending password reset email to: $email',
        name: 'AuthService',
      );
      await _auth.sendPasswordResetEmail(email: email);
      developer.log(
        'Password reset email sent successfully',
        name: 'AuthService',
      );
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Password reset error: ${e.code} - ${e.message}',
        name: 'AuthService',
      );
      return Left(_mapFirebaseAuthError(e));
    } catch (e) {
      developer.log('Unexpected password reset error: $e', name: 'AuthService');
      return const Left(ServerFailure('Failed to send password reset email'));
    }
  }

  /// Change user password
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(
          AuthenticationFailure('No user is currently signed in'),
        );
      }

      developer.log(
        'Changing password for user: ${user.uid}',
        name: 'AuthService',
      );

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      developer.log('Password changed successfully', name: 'AuthService');
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Password change error: ${e.code} - ${e.message}',
        name: 'AuthService',
      );
      return Left(_mapFirebaseAuthError(e));
    } catch (e) {
      developer.log(
        'Unexpected password change error: $e',
        name: 'AuthService',
      );
      return const Left(ServerFailure('Failed to change password'));
    }
  }

  /// Delete current user account
  Future<Either<Failure, Unit>> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(
          AuthenticationFailure('No user is currently signed in'),
        );
      }

      developer.log(
        'Deleting account for user: ${user.uid}',
        name: 'AuthService',
      );

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Delete account
      await user.delete();

      developer.log('Account deleted successfully', name: 'AuthService');
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Account deletion error: ${e.code} - ${e.message}',
        name: 'AuthService',
      );
      return Left(_mapFirebaseAuthError(e));
    } catch (e) {
      developer.log(
        'Unexpected account deletion error: $e',
        name: 'AuthService',
      );
      return const Left(ServerFailure('Failed to delete account'));
    }
  }

  /// Map Firebase Auth exceptions to domain failures
  Failure _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
        return const AuthenticationFailure('Invalid email or password');
      case 'user-disabled':
        return const AuthenticationFailure('This account has been disabled');
      case 'too-many-requests':
        return const AuthenticationFailure(
          'Too many failed attempts. Please try again later',
        );
      case 'email-already-in-use':
        return const ValidationFailure(
          'An account with this email already exists',
        );
      case 'invalid-email':
        return const ValidationFailure('Please enter a valid email address');
      case 'weak-password':
        return const ValidationFailure(
          'Password is too weak. Please choose a stronger password',
        );
      case 'requires-recent-login':
        return const AuthenticationFailure(
          'Please sign in again to perform this action',
        );
      case 'network-request-failed':
        return const NetworkFailure(
          'Network error. Please check your connection',
        );
      default:
        developer.log(
          'Unmapped Firebase Auth error: ${e.code}',
          name: 'AuthService',
        );
        return ServerFailure('Authentication error: ${e.message}');
    }
  }
}

/// Authentication failure types
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
