// Application Layer Exports
// Clean Architecture - Application Layer

// Configuration
export 'config/kitchen_config.dart';

// DTOs (Data Transfer Objects)
export 'dtos/order_dtos.dart';
export 'dtos/user_dtos.dart';
export 'dtos/station_dtos.dart' hide AssignOrderToStationDto;
export 'dtos/recipe_dtos.dart';
export 'dtos/inventory_dtos.dart';
export 'dtos/table_dtos.dart';
export 'dtos/kitchen_timer_dtos.dart';
export 'dtos/food_safety_dtos.dart';
export 'dtos/cost_tracking_dtos.dart';

// Use Cases
export 'use_cases/order/order_use_cases.dart';
export 'use_cases/user/user_use_cases.dart';
export 'use_cases/station/station_use_cases.dart';
export 'use_cases/recipe/recipe_use_cases.dart';
export 'use_cases/inventory/inventory_use_cases.dart';
export 'use_cases/table/table_use_cases.dart';
export 'use_cases/kitchen_timer/kitchen_timer_use_cases.dart';
export 'use_cases/food_safety/food_safety_use_cases.dart';
export 'use_cases/cost_tracking/cost_tracking_use_cases.dart';

/// Application Layer Overview:
/// 
/// This layer contains the business logic and use cases of the application.
/// It coordinates between the presentation layer and the domain layer,
/// orchestrating the flow of data and business rules.
/// 
/// Key Components:
/// - **Use Cases**: Business logic implementations
/// - **DTOs**: Data transfer objects for communication between layers
/// - **Configuration**: Application-level configuration settings
/// - **Services**: Application-specific services and orchestrators
/// 
/// Dependencies:
/// - Domain Layer (entities, repositories, services)
/// - No dependencies on infrastructure or presentation layers
/// 
/// Example Usage:
/// ```dart
/// // Import application layer
/// import 'package:stacks/application/application.dart';
/// 
/// // Use a use case
/// final createOrder = CreateOrderUseCase(
///   orderRepository,
///   recipeRepository,
///   userRepository,
///   workflowValidator,
///   kitchenConfig,
/// );
/// ```