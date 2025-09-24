// Presentation Layer Dependency Injection
// Registers BLoCs, Use Cases, and other presentation layer dependencies

import 'pa    getIt.registerFactory<StationBloc>(
      () => StationBloc(),
    );_it/get_it.dart';

// Import use cases
import '../../application/use_cases/user/user_use_cases.dart'
    hide AuthenticateUserUseCase, RegisterUserUseCase;
import '../../application/use_cases/user/authenticate_user_use_case.dart';
import '../../application/use_cases/order/order_use_cases.dart';
import '../../application/use_cases/station/station_use_cases.dart';

// Import repositories
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/repositories/station_repository.dart';

// Import BLoCs
import '../blocs/auth/auth_bloc.dart';
import '../blocs/order/order_bloc.dart';
import '../blocs/station/station_bloc_simple.dart';

/// Setup presentation layer dependencies
/// Must be called after infrastructure layer setup
void setupPresentationDependencies(GetIt getIt) {
  // ======================== Use Cases ========================

  // Authentication Use Cases
  getIt.registerLazySingleton<AuthenticateUserUseCase>(
    () => AuthenticateUserUseCase(getIt<UserRepository>()),
  );

  getIt.registerLazySingleton<RegisterUserUseCase>(
    () => RegisterUserUseCase(getIt<UserRepository>()),
  );

  getIt.registerLazySingleton<LogoutUserUseCase>(
    () => LogoutUserUseCase(getIt<UserRepository>()),
  );

  getIt.registerLazySingleton<UpdateUserUseCase>(
    () => UpdateUserUseCase(getIt<UserRepository>()),
  );

  getIt.registerLazySingleton<IsSessionValidUseCase>(
    () => IsSessionValidUseCase(getIt<UserRepository>()),
  );

  // Order Use Cases
  getIt.registerLazySingleton<CreateOrderUseCase>(
    () => CreateOrderUseCase(
      orderRepository: getIt<OrderRepository>(),
      recipeRepository: getIt<RecipeRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetAllOrdersUseCase>(
    () => GetAllOrdersUseCase(getIt<OrderRepository>()),
  );

  getIt.registerLazySingleton<GetOrderByIdUseCase>(
    () => GetOrderByIdUseCase(repository: getIt<OrderRepository>()),
  );

  getIt.registerLazySingleton<UpdateOrderStatusUseCase>(
    () => UpdateOrderStatusUseCase(repository: getIt<OrderRepository>()),
  );

  getIt.registerLazySingleton<AssignOrderToStationUseCase>(
    () => AssignOrderToStationUseCase(
      orderRepository: getIt<OrderRepository>(),
      stationRepository: getIt<StationRepository>(),
    ),
  );

  getIt.registerLazySingleton<CancelOrderUseCase>(
    () => CancelOrderUseCase(getIt<OrderRepository>()),
  );

  // Station Use Cases
  getIt.registerLazySingleton<GetAllStationsUseCase>(
    () => GetAllStationsUseCase(getIt<StationRepository>()),
  );

  getIt.registerLazySingleton<GetStationByIdUseCase>(
    () => GetStationByIdUseCase(getIt<StationRepository>()),
  );

  getIt.registerLazySingleton<CreateStationUseCase>(
    () => CreateStationUseCase(getIt<StationRepository>()),
  );

  getIt.registerLazySingleton<UpdateStationUseCase>(
    () => UpdateStationUseCase(getIt<StationRepository>()),
  );

  getIt.registerLazySingleton<AssignStaffToStationUseCase>(
    () => AssignStaffToStationUseCase(getIt<StationRepository>()),
  );

  getIt.registerLazySingleton<RemoveStaffFromStationUseCase>(
    () => RemoveStaffFromStationUseCase(getIt<StationRepository>()),
  );

  // ======================== BLoCs ========================

  // Authentication BLoC
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      authenticateUserUseCase: getIt<AuthenticateUserUseCase>(),
      registerUserUseCase: getIt<RegisterUserUseCase>(),
      logoutUserUseCase: getIt<LogoutUserUseCase>(),
      isSessionValidUseCase: getIt<IsSessionValidUseCase>(),
      updateUserUseCase: getIt<UpdateUserUseCase>(),
    ),
  );

  // Order BLoC
  getIt.registerFactory<OrderBloc>(
    () => OrderBloc(
      getAllOrdersUseCase: getIt<GetAllOrdersUseCase>(),
      getOrderByIdUseCase: getIt<GetOrderByIdUseCase>(),
      updateOrderStatusUseCase: getIt<UpdateOrderStatusUseCase>(),
      assignOrderToStationUseCase: getIt<AssignOrderToStationUseCase>(),
      cancelOrderUseCase: getIt<CancelOrderUseCase>(),
    ),
  );

  // Station BLoC
  getIt.registerFactory<StationBloc>(
    () => StationBloc(
      getAllStationsUseCase: getIt<GetAllStationsUseCase>(),
      getStationByIdUseCase: getIt<GetStationByIdUseCase>(),
      createStationUseCase: getIt<CreateStationUseCase>(),
      updateStationUseCase: getIt<UpdateStationUseCase>(),
      assignStaffToStationUseCase: getIt<AssignStaffToStationUseCase>(),
      removeStaffFromStationUseCase: getIt<RemoveStaffFromStationUseCase>(),
    ),
  );
}

/// Helper getters for BLoCs
extension PresentationGetters on GetIt {
  AuthBloc get authBloc => get<AuthBloc>();
  OrderBloc get orderBloc => get<OrderBloc>();
  StationBloc get stationBloc => get<StationBloc>();
}
