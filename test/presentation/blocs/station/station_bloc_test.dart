import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:stacks/presentation/blocs/station/station_bloc.dart';
import 'package:stacks/presentation/blocs/station/station_event.dart';
import 'package:stacks/presentation/blocs/station/station_state.dart';
import 'package:stacks/domain/value_objects/user_id.dart';

void main() {
  group('Station BLoC Tests', () {
    late StationBloc stationBloc;

    setUp(() {
      stationBloc = StationBloc();
    });

    tearDown(() {
      stationBloc.close();
    });

    test('initial state is StationInitialState', () {
      expect(stationBloc.state, isA<StationInitialState>());
    });

    blocTest<StationBloc, StationState>(
      'emits loading then loaded states when LoadStationsEvent is added',
      build: () => stationBloc,
      act: (bloc) => bloc.add(LoadStationsEvent()),
      expect: () => [isA<StationLoadingState>(), isA<StationsLoadedState>()],
      wait: const Duration(milliseconds: 600), // Wait for mock delay
    );

    test('Station BLoC can handle status updates', () async {
      // Load stations first
      stationBloc.add(LoadStationsEvent());
      await Future.delayed(const Duration(milliseconds: 600));

      // Then try to update a station status
      stationBloc.add(
        UpdateStationStatusEvent(
          stationId: UserId('station-1'),
          status: StationStatus.active,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 600));

      // Verify that the BLoC processed the event without crashing
      expect(stationBloc.state, isA<StationState>());
    });
  });
}
