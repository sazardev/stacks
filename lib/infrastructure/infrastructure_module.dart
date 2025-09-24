// Infrastructure Dependency Injection Configuration
// Service registration for repositories and mappers

import 'package:injectable/injectable.dart';
import 'mappers/order_mapper.dart';

/// Infrastructure module for dependency injection
@module
abstract class InfrastructureModule {
  /// Order Mapper singleton registration
  @singleton
  OrderMapper get orderMapper => OrderMapper();

  /// Additional infrastructure dependencies can be registered here
  /// Example: Firebase, Firestore, Cloud Storage, etc.
}

/// Register all infrastructure services
/// This function should be called during app initialization
void registerInfrastructureServices() {
  // All services are automatically registered via @Injectable annotations
  // OrderRepositoryImpl is registered as OrderRepository implementation
  // OrderMapper is registered as singleton
}
