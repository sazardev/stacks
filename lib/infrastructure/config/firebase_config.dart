// Firebase Configuration for Restaurant Management System
// Initializes Firebase services and configures Firestore settings

import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import 'firebase_collections.dart';

class FirebaseConfig {
  static FirebaseFirestore? _firestore;
  static FirebaseAuth? _auth;
  static FirebaseStorage? _storage;

  /// Initialize Firebase with configuration
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      developer.log(
        'Firebase initialized successfully',
        name: 'FirebaseConfig',
      );

      // Configure Firestore settings
      _configureFirestore();

      // Configure Authentication settings
      _configureAuth();

      // Configure Storage settings
      _configureStorage();
    } catch (e) {
      developer.log(
        'Firebase initialization failed: $e',
        name: 'FirebaseConfig',
      );
      rethrow;
    }
  }

  /// Configure Firestore with appropriate settings for restaurant operations
  static void _configureFirestore() {
    _firestore = FirebaseFirestore.instance;

    // Configure Firestore settings for better performance
    if (!kIsWeb) {
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    }

    developer.log('Firestore configured successfully', name: 'FirebaseConfig');
  }

  /// Configure Firebase Auth settings
  static void _configureAuth() {
    _auth = FirebaseAuth.instance;

    // Set language code for auth operations
    _auth!.setLanguageCode('en');

    developer.log(
      'Firebase Auth configured successfully',
      name: 'FirebaseConfig',
    );
  }

  /// Configure Firebase Storage settings
  static void _configureStorage() {
    _storage = FirebaseStorage.instance;

    developer.log(
      'Firebase Storage configured successfully',
      name: 'FirebaseConfig',
    );
  }

  /// Get Firestore instance
  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw StateError(
        'Firebase must be initialized before accessing Firestore',
      );
    }
    return _firestore!;
  }

  /// Get Firebase Auth instance
  static FirebaseAuth get auth {
    _auth ??= FirebaseAuth.instance;
    return _auth!;
  }

  /// Get Firebase Storage instance
  static FirebaseStorage get storage {
    _storage ??= FirebaseStorage.instance;
    return _storage!;
  }

  /// Initialize Firestore security rules and indexes
  static Future<void> setupFirestoreStructure() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Create initial documents to establish collections
      // This helps with Firestore console navigation and security rules

      await _createInitialDocument(firestore, FirebaseCollections.users);
      await _createInitialDocument(firestore, FirebaseCollections.orders);
      await _createInitialDocument(firestore, FirebaseCollections.stations);
      await _createInitialDocument(firestore, FirebaseCollections.recipes);
      await _createInitialDocument(firestore, FirebaseCollections.inventory);
      await _createInitialDocument(firestore, FirebaseCollections.tables);
      await _createInitialDocument(firestore, FirebaseCollections.analytics);
      await _createInitialDocument(
        firestore,
        FirebaseCollections.kitchenTimers,
      );
      await _createInitialDocument(firestore, FirebaseCollections.foodSafety);
      await _createInitialDocument(firestore, FirebaseCollections.costs);
      await _createInitialDocument(firestore, FirebaseCollections.costCenters);
      await _createInitialDocument(
        firestore,
        FirebaseCollections.profitabilityReports,
      );
      await _createInitialDocument(firestore, FirebaseCollections.recipeCosts);

      developer.log(
        'Firestore structure initialized successfully',
        name: 'FirebaseConfig',
      );
    } catch (e) {
      developer.log(
        'Error setting up Firestore structure: $e',
        name: 'FirebaseConfig',
      );
    }
  }

  /// Create an initial placeholder document to establish collection
  static Future<void> _createInitialDocument(
    FirebaseFirestore firestore,
    String collectionName,
  ) async {
    try {
      final docRef = firestore.collection(collectionName).doc('_placeholder');

      // Check if placeholder already exists
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set({
          'placeholder': true,
          'createdAt': FieldValue.serverTimestamp(),
          'description':
              'Initial document to establish $collectionName collection',
        });
      }
    } catch (e) {
      developer.log(
        'Error creating initial document for $collectionName: $e',
        name: 'FirebaseConfig',
      );
    }
  }

  /// Configure Firestore composite indexes programmatically
  static void configureIndexes() {
    // Note: Composite indexes must be created in Firebase Console
    // or using Firebase CLI. This method documents the required indexes.

    developer.log(
      'Required Firestore Composite Indexes:',
      name: 'FirebaseConfig',
    );
    developer.log(
      '1. orders: status (ASC), createdAt (DESC)',
      name: 'FirebaseConfig',
    );
    developer.log(
      '2. orders: stationId (ASC), status (ASC), createdAt (DESC)',
      name: 'FirebaseConfig',
    );
    developer.log(
      '3. inventory: itemId (ASC), expirationDate (ASC)',
      name: 'FirebaseConfig',
    );
    developer.log(
      '4. inventory: location (ASC), quantity (ASC)',
      name: 'FirebaseConfig',
    );
    developer.log(
      '5. costs: incurredDate (ASC), type (ASC)',
      name: 'FirebaseConfig',
    );
    developer.log(
      '6. costs: costCenterId (ASC), incurredDate (DESC)',
      name: 'FirebaseConfig',
    );
    developer.log(
      '7. food_safety: facilityId (ASC), recordedAt (DESC)',
      name: 'FirebaseConfig',
    );
    developer.log(
      '8. kitchen_timers: stationId (ASC), isActive (ASC)',
      name: 'FirebaseConfig',
    );
    developer.log(
      '9. analytics: reportType (ASC), periodStart (DESC)',
      name: 'FirebaseConfig',
    );
    developer.log(
      '10. recipe_costs: recipeId (ASC), isCurrentPricing (ASC)',
      name: 'FirebaseConfig',
    );
    developer.log(
      'Create these indexes in Firebase Console under Firestore Database > Indexes',
      name: 'FirebaseConfig',
    );
  }

  /// Test Firebase connection
  static Future<bool> testConnection() async {
    try {
      // Test Firestore connection
      await firestore.doc('test/connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'test': true,
      });

      // Clean up test document
      await firestore.doc('test/connection').delete();

      developer.log(
        'Firebase connection test successful',
        name: 'FirebaseConfig',
      );
      return true;
    } catch (e) {
      developer.log(
        'Firebase connection test failed: $e',
        name: 'FirebaseConfig',
      );
      return false;
    }
  }

  /// Get Firestore server timestamp
  static FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  /// Batch write helper for transactions
  static WriteBatch createBatch() => firestore.batch();

  /// Transaction helper
  static Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    return await firestore.runTransaction(updateFunction);
  }
}
