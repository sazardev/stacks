// Infrastructure Layer Exports
// Clean Architecture - Infrastructure Layer

// Repositories
export 'repositories/order_repository_impl.dart';

// Mappers
export 'mappers/order_mapper.dart';

// Dependency Injection
export 'infrastructure_module.dart';

/// Infrastructure Layer Overview:
/// 
/// This layer contains concrete implementations of repository interfaces
/// defined in the domain layer. It handles data persistence, external APIs,
/// and infrastructure concerns.
/// 
/// Key Components:
/// - Repository Implementations: Concrete classes implementing domain repository interfaces
/// - Data Mappers: Convert between domain entities and data transfer objects
/// - Dependency Injection: Service registration and configuration
/// 
/// Architecture Pattern:
/// - Repository Pattern: Concrete implementations of domain repositories
/// - Data Mapper Pattern: Entity to/from database/API conversion
/// - Dependency Injection: Injectable services with GetIt/Injectable
/// 
/// Dependencies:
/// - Domain Layer: Repository interfaces, entities, value objects
/// - External: Firebase, SQLite, REST APIs, etc.
/// 
/// Usage:
/// ```dart
/// // In main.dart or dependency injection setup
/// import 'package:stacks/infrastructure/infrastructure.dart';
/// 
/// void configureDependencies() {
///   registerInfrastructureServices();
/// }
/// ```