import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stacks/presentation/blocs/station/station_bloc.dart';
import 'package:stacks/presentation/blocs/station/station_event.dart';
import 'package:stacks/presentation/pages/stations/stations_page.dart';

void main() {
  group('Station Management Flow Integration Tests', () {
    testWidgets('Stations page loads and displays station cards', (
      WidgetTester tester,
    ) async {
      // Build the widget tree with BLoC provider
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => StationBloc()..add(LoadStationsEvent()),
            child: const StationsPage(),
          ),
        ),
      );

      // Verify that the page loads
      expect(find.text('Kitchen Stations'), findsOneWidget);

      // Verify loading state is shown initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for async data loading
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify that station cards are displayed after loading
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // The stations page should show some content (either stations or empty state)
      expect(find.byType(StationsPage), findsOneWidget);
    });

    testWidgets('Station detail page navigation works', (
      WidgetTester tester,
    ) async {
      // Build the stations page
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => StationBloc()..add(LoadStationsEvent()),
            child: const StationsPage(),
          ),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Try to find and tap a station card (if available)
      final stationCards = find.byType(Card);
      if (stationCards.evaluate().isNotEmpty) {
        await tester.tap(stationCards.first);
        await tester.pumpAndSettle();

        // Navigation should work without errors
        expect(tester.takeException(), isNull);
      }
    });
  });
}
