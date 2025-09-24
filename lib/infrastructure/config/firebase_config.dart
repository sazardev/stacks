// Firebase Configuration for Restaurant Management System
// Initializes Firebase services and configures Firestore settings

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_collections.dart';

class FirebaseConfig {
  static FirebaseFirestore? _firestore;
  static FirebaseAuth? _auth;
  static FirebaseStorage? _storage;

  /// Initialize Firebase with configuration
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        // Replace these with your actual Firebase project configuration
        apiKey: 'your-api-key',
        appId: 'your-app-id',
        messagingSenderId: 'your-sender-id',
        projectId: 'your-project-id',
        storageBucket: 'your-storage-bucket',
      ),
    );

    // Configure Firestore settings
    _configureFirestore();
  }

  /// Configure Firestore with appropriate settings for restaurant operations
  static void _configureFirestore() {
    _firestore = FirebaseFirestore.instance;

    // Configure Firestore settings for better performance
    _firestore!.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Enable offline persistence for better user experience
    _firestore!.enableNetwork();
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

      print('Firestore structure initialized successfully');
    } catch (e) {
      print('Error setting up Firestore structure: $e');
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
      print('Error creating initial document for $collectionName: $e');
    }
  }

  /// Configure Firestore composite indexes programmatically
  static void configureIndexes() {
    // Note: Composite indexes must be created in Firebase Console
    // or using Firebase CLI. This method documents the required indexes.

    print('Required Firestore Composite Indexes:');
    print('1. orders: status (ASC), createdAt (DESC)');
    print('2. orders: stationId (ASC), status (ASC), createdAt (DESC)');
    print('3. inventory: itemId (ASC), expirationDate (ASC)');
    print('4. inventory: location (ASC), quantity (ASC)');
    print('5. costs: incurredDate (ASC), type (ASC)');
    print('6. costs: costCenterId (ASC), incurredDate (DESC)');
    print('7. food_safety: facilityId (ASC), recordedAt (DESC)');
    print('8. kitchen_timers: stationId (ASC), isActive (ASC)');
    print('9. analytics: reportType (ASC), periodStart (DESC)');
    print('10. recipe_costs: recipeId (ASC), isCurrentPricing (ASC)');
    print('');
    print(
      'Create these indexes in Firebase Console under Firestore Database > Indexes',
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

      print('Firebase connection test successful');
      return true;
    } catch (e) {
      print('Firebase connection test failed: $e');
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
