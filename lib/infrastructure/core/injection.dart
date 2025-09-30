// Dependency Injection Configuration for Clean Architecture
// Registers all repositories, mappers, and services using GetIt
// USING ONLY FIREBASE IMPLEMENTATIONS - NO MOCKS!

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import all mappers
import '../mappers/user_mapper.dart';
import '../mappers/order_mapper.dart';
import '../mappers/station_mapper.dart';
import '../mappers/recipe_mapper.dart';
import '../mappers/inventory_mapper.dart';
import '../mappers/table_mapper.dart';
import '../mappers/analytics_mapper.dart';
import '../mappers/kitchen_timer_mapper.dart';
import '../mappers/food_safety_mapper.dart';
import '../mappers/cost_tracking_mapper.dart';

// Import ONLY Firebase repositories (NO MOCKS!)
import '../repositories/firebase_user_repository.dart';
import '../repositories/firebase_order_repository.dart';
import '../repositories/firebase_station_repository.dart';
import '../repositories/firebase_recipe_repository.dart';
import '../repositories/firebase_inventory_repository.dart';
import '../repositories/firebase_table_repository.dart';
import '../repositories/firebase_kitchen_timer_repository.dart';
import '../repositories/firebase_food_safety_repository.dart';
import '../repositories/firebase_analytics_repository.dart';
import '../repositories/firebase_cost_tracking_repository.dart';

// Import domain repository interfaces
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/station_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/repositories/table_repository.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../domain/repositories/kitchen_timer_repository.dart';
import '../../domain/repositories/food_safety_repository.dart';
import '../../domain/repositories/cost_tracking_repository.dart';

// Import presentation layer DI
import '../../presentation/core/presentation_injection.dart';

final GetIt getIt = GetIt.instance;

/// Configure dependency injection - ALL USING FIREBASE!
Future<void> configureDependencies() async {
  // Register Firebase instances
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Register all mappers
  getIt.registerLazySingleton<UserMapper>(() => UserMapper());
  getIt.registerLazySingleton<OrderMapper>(() => OrderMapper());
  getIt.registerLazySingleton<StationMapper>(() => StationMapper());
  getIt.registerLazySingleton<RecipeMapper>(() => RecipeMapper());
  getIt.registerLazySingleton<InventoryMapper>(() => InventoryMapper());
  getIt.registerLazySingleton<TableMapper>(() => TableMapper());
  getIt.registerLazySingleton<AnalyticsMapper>(() => AnalyticsMapper());
  getIt.registerLazySingleton<KitchenTimerMapper>(() => KitchenTimerMapper());
  getIt.registerLazySingleton<FoodSafetyMapper>(() => FoodSafetyMapper());
  getIt.registerLazySingleton<CostTrackingMapper>(() => CostTrackingMapper());

  // Register ALL repositories using Firebase - NO MOCKS!

  // Repositories that take ONLY mapper
  getIt.registerLazySingleton<UserRepository>(
    () => FirebaseUserRepository(getIt<UserMapper>()),
  );

  getIt.registerLazySingleton<OrderRepository>(
    () => FirebaseOrderRepository(getIt<OrderMapper>()),
  );

  getIt.registerLazySingleton<StationRepository>(
    () => FirebaseStationRepository(getIt<StationMapper>()),
  );

  getIt.registerLazySingleton<RecipeRepository>(
    () => FirebaseRecipeRepository(getIt<RecipeMapper>()),
  );

  getIt.registerLazySingleton<InventoryRepository>(
    () => FirebaseInventoryRepository(getIt<InventoryMapper>()),
  );

  getIt.registerLazySingleton<TableRepository>(
    () => FirebaseTableRepository(getIt<TableMapper>()),
  );

  getIt.registerLazySingleton<KitchenTimerRepository>(
    () => FirebaseKitchenTimerRepository(getIt<KitchenTimerMapper>()),
  );

  getIt.registerLazySingleton<CostTrackingRepository>(
    () => FirebaseCostTrackingRepository(getIt<CostTrackingMapper>()),
  );

  // Repositories that take BOTH firestore AND mapper

  // ✅ Using Firebase Analytics Repository - NOT the mock!
  getIt.registerLazySingleton<AnalyticsRepository>(
    () => FirebaseAnalyticsRepository(
      getIt<FirebaseFirestore>(),
      getIt<AnalyticsMapper>(),
    ),
  );

  // ✅ Using Firebase Food Safety Repository - NOT the stub!
  getIt.registerLazySingleton<FoodSafetyRepository>(
    () => FirebaseFoodSafetyRepository(
      firestore: getIt<FirebaseFirestore>(),
      foodSafetyMapper: getIt<FoodSafetyMapper>(),
    ),
  );

  // Setup presentation layer dependencies (BLoCs and use cases)
  setupPresentationDependencies(getIt);
}

// Helper methods to get services
T get<T extends Object>() => getIt.get<T>();

// Repository getters
UserRepository get userRepository => getIt<UserRepository>();
OrderRepository get orderRepository => getIt<OrderRepository>();
StationRepository get stationRepository => getIt<StationRepository>();
RecipeRepository get recipeRepository => getIt<RecipeRepository>();
InventoryRepository get inventoryRepository => getIt<InventoryRepository>();
TableRepository get tableRepository => getIt<TableRepository>();
AnalyticsRepository get analyticsRepository => getIt<AnalyticsRepository>();
KitchenTimerRepository get kitchenTimerRepository =>
    getIt<KitchenTimerRepository>();
FoodSafetyRepository get foodSafetyRepository => getIt<FoodSafetyRepository>();
CostTrackingRepository get costTrackingRepository =>
    getIt<CostTrackingRepository>();
