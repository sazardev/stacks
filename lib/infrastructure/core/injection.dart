// Dependency Injection Configuration for Clean Architecture
// Registers all repositories, mappers, and services using GetIt and Injectable

import 'package:get_it/get_it.dart';

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

// Import all repositories
import '../repositories/firebase_user_repository.dart';
import '../repositories/station_repository_impl.dart';
import '../repositories/recipe_repository_impl.dart';
import '../repositories/inventory_repository_impl.dart';
import '../repositories/table_repository_impl.dart';
import '../repositories/analytics_repository_impl.dart';
import '../repositories/kitchen_timer_repository_impl.dart';
import '../repositories/food_safety_repository_impl.dart';
import '../repositories/cost_tracking_repository_impl.dart';
import '../repositories/order_repository_impl.dart';

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

// Manual registration for cases where automatic generation might not work
Future<void> setupDependencyInjection() async {
  // Mappers
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

  // Repositories - Using Firebase implementations where available
  getIt.registerLazySingleton<UserRepository>(
    () => FirebaseUserRepository(getIt<UserMapper>()),
  );

  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(orderMapper: getIt<OrderMapper>()),
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
