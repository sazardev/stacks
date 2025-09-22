# Stacks - Kitchen Display System (KDS) for Modern Food Service

[![Build Status](https://img.shields.io/github/actions/workflow/status/sazardev/stacks/flutter.yml?branch=main)](https://github.com/sazardev/stacks/actions)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Stacks is a comprehensive, open-source Kitchen Display System designed to optimize food service operations through intelligent order management and real-time kitchen coordination. Built with Flutter using Clean Architecture principles and Test-Driven Development, leveraging Firebase ecosystem for scalable, real-time operations.

**Developed by [Sazar Dev](https://sazar.netlify.app/) - Specialized restaurant technology solutions**

## 🏗️ Architecture & Business Logic

### Clean Architecture Implementation
Stacks follows Clean Architecture principles with strict separation of concerns and dependency inversion:

- **Domain Layer**: Core business entities, value objects, and domain rules
- **Application Layer**: Use cases, application services, and business orchestration
- **Infrastructure Layer**: External services integration (Firebase, APIs)
- **Presentation Layer**: UI components, state management, and user interactions

### Core Business Logic
- **Order Lifecycle Management**: Complete order flow from creation to completion
- **Kitchen Workflow Optimization**: Intelligent order routing and priority management
- **Real-time State Synchronization**: Multi-device state management with conflict resolution
- **Performance Analytics**: Data-driven insights for operational efficiency

### System Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Presentation  │    │   Application   │    │     Domain      │    │ Infrastructure  │
│     Layer       │◄──►│     Layer       │◄──►│     Layer       │◄──►│     Layer       │
│ (UI/Controllers)│    │  (Use Cases)    │    │   (Entities)    │    │   (Firebase)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔧 Technology Stack

### Frontend & Architecture
- **Flutter 3.0+**: Cross-platform UI framework
- **Dart 3.0+**: Primary programming language
- **Clean Architecture**: Domain-driven design with dependency inversion
- **BLoC Pattern**: Business Logic Component for state management
- **Injectable**: Code generation for dependency injection
- **GetIt**: Service locator for dependency injection
- **Auto Route**: Type-safe navigation management
- **Freezed**: Code generation for immutable classes and unions
- **Dartz**: Functional programming (Either, Option) for error handling

### Firebase & Google Cloud Services
- **Firebase Authentication**: User management with Google Sign-In
- **Firestore**: Real-time NoSQL database for orders and kitchen data
- **Firebase Cloud Functions**: Server-side business logic and triggers
- **Firebase Cloud Messaging**: Push notifications for kitchen alerts
- **Firebase Analytics**: User behavior and performance tracking
- **Firebase Hosting**: Progressive Web App deployment
- **Google Cloud Storage**: File and image storage
- **Firebase Remote Config**: Dynamic app configuration
- **Firebase Performance Monitoring**: App performance insights

### Development & Testing
- **Test-Driven Development (TDD)**: Red-Green-Refactor methodology
- **Unit Testing**: 100% coverage for domain and application layers
- **Integration Testing**: Firebase emulator testing
- **Widget Testing**: UI component testing
- **Firebase Emulators**: Local development and testing environment
- **Mockito**: Mocking framework for unit tests
- **Build Runner**: Code generation for Freezed, Injectable, and JSON serialization
- **JSON Annotation**: Serialization support for DTOs and models

### Additional Technologies
- **Camera**: Barcode scanning functionality
- **Local Notifications**: Kitchen alerts and timers
- **Connectivity**: Network status monitoring
- **Material 3**: Modern UI design system

## 📦 Clean Architecture Layers

### Domain Layer (Core Business Logic)
**Entities & Value Objects**: Pure business logic without external dependencies
- **Order Entity**: Order lifecycle, status transitions, business rules (with Freezed)
- **User Entity**: User roles, permissions, authentication state
- **Station Entity**: Kitchen station management and capacity
- **Recipe Entity**: Recipe data, ingredients, preparation instructions
- **Value Objects**: Money, Time, Priority, OrderStatus (immutable with Freezed)
- **Failures**: Domain-specific error types with Dartz Either pattern

### Application Layer (Use Cases)
**Business Orchestration**: Coordinates domain entities and external services
- **Order Management**: CreateOrder, UpdateOrderStatus, PrioritizeOrder
- **User Management**: AuthenticateUser, ManageUserRoles, GetPermissions
- **Kitchen Operations**: AssignOrderToStation, TrackPreparationTime
- **Analytics**: GenerateReports, CalculateMetrics
- **Error Handling**: Either<Failure, Success> pattern for all use cases
- **Input/Output DTOs**: Freezed classes for type-safe data transfer

### Infrastructure Layer (External Services)
**Firebase Integration**: Implementation of repository interfaces
- **Firestore Repositories**: Real-time data persistence and synchronization
- **Firebase Auth Service**: User authentication and session management
- **Cloud Messaging**: Push notifications for kitchen alerts
- **Cloud Functions**: Server-side business logic execution
- **Analytics Service**: Performance and usage tracking
- **Data Mappers**: JSON serialization with json_annotation
- **Dependency Injection**: Injectable registration for all services

### Presentation Layer (UI & Controllers)
**User Interface**: Reactive UI with BLoC state management
- **BLoC Components**: Business Logic Components for each feature
- **Events & States**: Freezed classes for type-safe state management
- **UI Components**: Reusable widgets with Material 3 design
- **Screens**: Kitchen display, order management, user interface
- **Navigation**: Type-safe routing with Auto Route and authentication guards
- **BLoC Listeners**: Real-time UI updates based on state changes

## 🚀 Key Features

### Operational Features
- **Smart Order Routing**: Intelligent distribution based on kitchen capacity
- **Dynamic Priority Management**: Auto-prioritization based on order type and timing
- **Multi-Station Coordination**: Synchronized workflow across kitchen stations
- **Real-time Performance Monitoring**: Live KPI tracking and alerts

### Technical Features
- **Clean Architecture**: Separation of concerns with dependency inversion
- **BLoC Pattern**: Predictable state management with clear data flow
- **Test-Driven Development**: TDD methodology for reliable code
- **Firebase Real-time**: Instant synchronization across all devices
- **Functional Programming**: Dartz Either pattern for error handling
- **Code Generation**: Freezed for immutable classes, Injectable for DI
- **Offline-First Architecture**: Continues operation without internet connectivity
- **Progressive Web App (PWA)**: Web-based deployment with Firebase Hosting
- **Responsive Design**: Adaptive UI for various screen sizes
- **Hot Reload Development**: Fast development cycle with Flutter

### Integration Capabilities
- **Firebase Ecosystem**: Seamless integration with all Firebase services
- **Repository Pattern**: Abstracted data access for easy service switching
- **API-First Design**: Clean interfaces for future integrations
- **Real-time Notifications**: Firebase Cloud Messaging for instant alerts
- **Data Synchronization**: Firestore real-time bi-directional sync

## 🛠️ Development Philosophy

### Clean Architecture Principles
- **Domain Independence**: Core business logic isolated from external dependencies
- **Dependency Inversion**: Abstract interfaces for all external services
- **Single Responsibility**: Each class and module has one clear purpose
- **SOLID Principles**: Maintainable and extensible codebase architecture
- **Immutability**: Freezed classes for immutable data structures
- **Functional Error Handling**: Dartz Either pattern instead of exceptions

### Test-Driven Development (TDD)
- **Red-Green-Refactor**: Write tests first, implement, then refactor
- **100% Domain Coverage**: Complete unit testing for all business logic
- **BLoC Testing**: Comprehensive testing for all BLoCs with bloc_test
- **Integration Testing**: Firebase emulator testing for realistic scenarios
- **Widget Testing**: Comprehensive UI component testing
- **Mock Generation**: Mockito for creating test doubles
- **Continuous Integration**: Automated testing and quality checks

### Firebase-First Approach
- **Infrastructure Layer**: Firebase services as implementation details
- **Real-time by Design**: Leverage Firestore's real-time capabilities
- **Scalable Backend**: Automatic scaling with Firebase infrastructure
- **Developer Experience**: Firebase emulators for local development

### Code Quality Standards
- **Linting & Formatting**: Strict code quality rules and automated formatting
- **Code Reviews**: Mandatory peer reviews for all changes
- **Documentation**: Comprehensive code and architecture documentation
- **Performance Monitoring**: Continuous performance tracking and optimization
- **Code Generation**: Build runner for Freezed, Injectable, and JSON serialization
- **Static Analysis**: Very Good Analysis for enhanced Dart linting rules

### Customization Options
- **Firebase Remote Config**: Dynamic configuration without app updates
- **Theme System**: Customizable UI themes and branding via Remote Config
- **Role-Based Features**: Feature access based on user roles and permissions
- **Multi-Environment**: Development, staging, and production environments
- **Localization Support**: Multi-language internationalization support

## 📊 Analytics & Business Intelligence

### Firebase Analytics Integration
- **Real-time Dashboards**: Live operational metrics with Firebase Analytics
- **Custom Events**: Kitchen-specific analytics events and user behavior
- **Performance Insights**: App performance monitoring and optimization
- **User Journey Tracking**: Complete user interaction analysis

### Kitchen Performance Metrics
- **Order Completion Times**: Average preparation and delivery times
- **Station Efficiency**: Kitchen station utilization and throughput analysis
- **Real-time KPIs**: Live performance indicators and operational alerts
- **Custom Reports**: Firestore-powered reporting with data export capabilities

### Business Intelligence Features
- **BigQuery Integration**: Advanced analytics with Google BigQuery
- **Automated Reporting**: Scheduled report generation and delivery
- **Data Export**: CSV and JSON export capabilities
- **Performance Optimization**: Data-driven insights for operational efficiency
