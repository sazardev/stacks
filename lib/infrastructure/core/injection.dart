// Dependency Injection Configuration for Clean Architecture
// Registers all repositories, mappers, and services using GetIt and Injectable

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Import all mappers
import '../mappers/user_mapper.dart';
import '../mappers/station_mapper.dart';
import '../mappers/recipe_mapper.dart';
import '../mappers/inventory_mapper.dart';
import '../mappers/table_mapper.dart';
import '../mappers/analytics_mapper.dart';
import '../mappers/kitchen_timer_mapper.dart';
import '../mappers/food_safety_mapper.dart';
import '../mappers/cost_tracking_mapper.dart';

// Import all repositories
import '../repositories/user_repository_impl.dart';
import '../repositories/station_repository_impl.dart';
import '../repositories/recipe_repository_impl.dart';
import '../repositories/inventory_repository_impl.dart';
import '../repositories/table_repository_impl.dart';
import '../repositories/analytics_repository_impl.dart';
import '../repositories/kitchen_timer_repository_impl.dart';
import '../repositories/food_safety_repository_impl.dart';
import '../repositories/cost_tracking_repository_impl.dart';

// Import domain repository interfaces
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/station_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/repositories/table_repository.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../domain/repositories/kitchen_timer_repository.dart';
import '../../domain/repositories/food_safety_repository.dart';
import '../../domain/repositories/cost_tracking_repository.dart';

final GetIt getIt = GetIt.instance;

// Manual registration for cases where automatic generation might not work
Future<void> setupDependencyInjection() async {
  // Firebase services
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // Mappers
  getIt.registerLazySingleton<UserMapper>(() => UserMapper());
  getIt.registerLazySingleton<StationMapper>(() => StationMapper());
  getIt.registerLazySingleton<RecipeMapper>(() => RecipeMapper());
  getIt.registerLazySingleton<InventoryMapper>(() => InventoryMapper());
  getIt.registerLazySingleton<TableMapper>(() => TableMapper());
  getIt.registerLazySingleton<AnalyticsMapper>(() => AnalyticsMapper());
  getIt.registerLazySingleton<KitchenTimerMapper>(() => KitchenTimerMapper());
  getIt.registerLazySingleton<FoodSafetyMapper>(() => FoodSafetyMapper());
  getIt.registerLazySingleton<CostTrackingMapper>(() => CostTrackingMapper());

  // Repositories
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(userMapper: getIt<UserMapper>()),
  );

  getIt.registerLazySingleton<StationRepository>(
    () => StationRepositoryImpl(stationMapper: getIt<StationMapper>()),
  );

  getIt.registerLazySingleton<RecipeRepository>(
    () => RecipeRepositoryImpl(recipeMapper: getIt<RecipeMapper>()),
  );

  getIt.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(inventoryMapper: getIt<InventoryMapper>()),
  );

  getIt.registerLazySingleton<TableRepository>(
    () => TableRepositoryImpl(tableMapper: getIt<TableMapper>()),
  );

  getIt.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(analyticsMapper: getIt<AnalyticsMapper>()),
  );

  getIt.registerLazySingleton<KitchenTimerRepository>(
    () => KitchenTimerRepositoryImpl(timerMapper: getIt<KitchenTimerMapper>()),
  );

  getIt.registerLazySingleton<FoodSafetyRepository>(
    () => FoodSafetyRepositoryImpl(),
  );

  getIt.registerLazySingleton<CostTrackingRepository>(
    () => CostTrackingRepositoryImpl(),
  );
}

// Helper methods to get services
T get<T extends Object>() => getIt.get<T>();

// Specific getters for common services
FirebaseFirestore get firestore => getIt<FirebaseFirestore>();
FirebaseAuth get auth => getIt<FirebaseAuth>();
FirebaseStorage get storage => getIt<FirebaseStorage>();

// Repository getters
UserRepository get userRepository => getIt<UserRepository>();
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
