// Restaurant Management System Application Initialization
// Sets up Firebase, dependency injection, and core services

import 'package:flutter/material.dart';
import 'config/firebase_config.dart';
import 'core/injection.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/repositories/station_repository.dart';
import '../domain/repositories/recipe_repository.dart';
import '../domain/repositories/inventory_repository.dart';
import '../domain/repositories/table_repository.dart';
import '../domain/repositories/analytics_repository.dart';
import '../domain/repositories/kitchen_timer_repository.dart';
import '../domain/repositories/food_safety_repository.dart';
import '../domain/repositories/cost_tracking_repository.dart';

class RestaurantApp {
  /// Initialize the restaurant management system
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      // Initialize Firebase
      await FirebaseConfig.initialize();
      print('✅ Firebase initialized successfully');

      // Test Firebase connection
      final connectionOk = await FirebaseConfig.testConnection();
      if (!connectionOk) {
        print('⚠️  Firebase connection test failed');
      }

      // Setup Firestore structure
      await FirebaseConfig.setupFirestoreStructure();
      print('✅ Firestore structure initialized');

      // Configure dependency injection
      await configureDependencies();
      print('✅ Dependency injection configured');

      // Display required indexes information
      FirebaseConfig.configureIndexes();

      print('🎉 Restaurant Management System initialized successfully!');
      print('');
      print('Available Services:');
      print('- User Management & Authentication');
      print('- Station Operations & Equipment');
      print('- Recipe Management & Instructions');
      print('- Inventory Tracking & Alerts');
      print('- Table Management & Dining');
      print('- Kitchen Analytics & Performance');
      print('- Timer Operations & Coordination');
      print('- Food Safety & HACCP Compliance');
      print('- Cost Tracking & Profitability');
      print('');
    } catch (e) {
      print('❌ Error initializing Restaurant Management System: $e');
      rethrow;
    }
  }

  /// Quick health check of all services
  static Future<Map<String, bool>> healthCheck() async {
    final results = <String, bool>{};

    try {
      // Test Firebase connection
      results['firebase'] = await FirebaseConfig.testConnection();

      // Test repository access through dependency injection
      results['userRepository'] = getIt.isRegistered<UserRepository>();
      results['stationRepository'] = getIt.isRegistered<StationRepository>();
      results['recipeRepository'] = getIt.isRegistered<RecipeRepository>();
      results['inventoryRepository'] = getIt
          .isRegistered<InventoryRepository>();
      results['tableRepository'] = getIt.isRegistered<TableRepository>();
      results['analyticsRepository'] = getIt
          .isRegistered<AnalyticsRepository>();
      results['kitchenTimerRepository'] = getIt
          .isRegistered<KitchenTimerRepository>();
      results['foodSafetyRepository'] = getIt
          .isRegistered<FoodSafetyRepository>();
      results['costTrackingRepository'] = getIt
          .isRegistered<CostTrackingRepository>();

      print('Health Check Results:');
      results.forEach((service, isHealthy) {
        final status = isHealthy ? '✅' : '❌';
        print('$status $service');
      });
    } catch (e) {
      print('❌ Error during health check: $e');
    }

    return results;
  }
}
