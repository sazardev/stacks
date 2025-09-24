// Presentation Layer Structure and Exports
// Clean Architecture - Presentation Layer

// Core BLoC Infrastructure
export 'core/base_bloc.dart';
export 'core/base_event.dart';
export 'core/base_state.dart';

// BLoC State Management
export 'blocs/auth/auth_event.dart';
export 'blocs/auth/auth_state.dart';
export 'blocs/auth/auth_bloc.dart';
export 'blocs/order/order_bloc.dart';
export 'blocs/station/station_bloc.dart';
// TODO: Add when implemented
// export 'blocs/user/user_bloc.dart';
// export 'blocs/kitchen/kitchen_bloc.dart';
// export 'blocs/analytics/analytics_bloc.dart';

// Pages
export 'pages/auth/login_page.dart';
export 'pages/auth/register_page.dart';
export 'pages/kitchen/kitchen_dashboard_page.dart';
export 'pages/stations/stations_page.dart';
export 'pages/stations/station_detail_page.dart';
// TODO: Add when implemented
// export 'pages/orders/orders_page.dart';
// export 'pages/analytics/analytics_page.dart';

// Widgets
export 'widgets/common/loading_widget.dart';
export 'widgets/common/error_widget.dart';
export 'widgets/station/station_status_widget.dart';
export 'widgets/station/station_card_widget.dart';
// TODO: Add when implemented
// export 'widgets/order/order_card_widget.dart';

// Theme & Design System
// TODO: Add when implemented
// export 'theme/app_theme.dart';
// export 'theme/app_colors.dart';
// export 'theme/app_text_styles.dart';

// Navigation
// TODO: Add when implemented
// export 'navigation/app_router.dart';
// export 'navigation/route_names.dart';

/// Presentation Layer Overview:
/// 
/// This layer handles the user interface and user interaction using the BLoC pattern
/// for state management. It follows Clean Architecture principles by depending only
/// on the application layer through use cases.
/// 
/// Key Components:
/// - **BLoCs**: State management for different features
/// - **Pages**: Complete screen implementations
/// - **Widgets**: Reusable UI components
/// - **Navigation**: App routing and navigation
/// - **Theme**: Design system and styling
/// 
/// Architecture Flow:
/// ```
/// Widget -> BLoC -> Use Case -> Repository -> Data Source
/// ```
/// 
/// The presentation layer never directly accesses domain entities or repositories,
/// maintaining strict separation of concerns.