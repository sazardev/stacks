import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/station/station_bloc.dart';
import '../../blocs/station/station_event.dart';
import '../../blocs/station/station_state.dart';
import '../../widgets/station/station_card_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../../domain/value_objects/user_id.dart';

/// Main stations page displaying all kitchen stations
class StationsPage extends StatelessWidget {
  const StationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Stations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshStations(context),
            tooltip: 'Refresh Stations',
          ),
        ],
      ),
      body: BlocConsumer<StationBloc, StationState>(
        listener: (context, state) {
          if (state is StationErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () => _refreshStations(context),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return _buildStationsContent(context, state);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStationDialog(context),
        tooltip: 'Add Station',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStationsContent(BuildContext context, StationState state) {
    if (state is StationLoadingState) {
      return const CustomLoadingWidget(message: 'Loading stations...');
    }

    if (state is StationErrorState) {
      return CustomErrorWidget(
        message: state.message,
        onRetry: () => _refreshStations(context),
      );
    }

    if (state is StationsLoadedState) {
      if (state.stations.isEmpty) {
        return _buildEmptyState(context);
      }

      return RefreshIndicator(
        onRefresh: () async => _refreshStations(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: state.stations.length,
            itemBuilder: (context, index) {
              final station = state.stations[index];
              return StationCardWidget(
                station: station,
                onTap: () =>
                    _navigateToStationDetail(context, station.id.value),
                onStatusUpdate: (newStatus) =>
                    _updateStationStatus(context, station.id, newStatus),
              );
            },
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.kitchen, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No stations configured',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first kitchen station to get started',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddStationDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Station'),
          ),
        ],
      ),
    );
  }

  void _refreshStations(BuildContext context) {
    context.read<StationBloc>().add(LoadStationsEvent());
  }

  void _updateStationStatus(
    BuildContext context,
    UserId stationId,
    StationStatus newStatus,
  ) {
    context.read<StationBloc>().add(
      UpdateStationStatusEvent(stationId: stationId, status: newStatus),
    );
  }

  void _navigateToStationDetail(BuildContext context, String stationId) {
    Navigator.of(context).pushNamed('/station-detail', arguments: stationId);
  }

  void _showAddStationDialog(BuildContext context) {
    // TODO: Implement add station dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add station functionality coming soon')),
    );
  }
}
