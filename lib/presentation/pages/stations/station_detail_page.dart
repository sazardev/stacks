import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/station/station_bloc.dart';
import '../../blocs/station/station_event.dart';
import '../../blocs/station/station_state.dart';
import '../../widgets/station/station_status_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../../domain/entities/station.dart' as domain;
import '../../../domain/value_objects/user_id.dart';

/// Station detail page showing comprehensive station information
class StationDetailPage extends StatefulWidget {
  final String stationId;

  const StationDetailPage({super.key, required this.stationId});

  @override
  State<StationDetailPage> createState() => _StationDetailPageState();
}

class _StationDetailPageState extends State<StationDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadStationDetails();
  }

  void _loadStationDetails() {
    context.read<StationBloc>().add(
      GetStationDetailsEvent(stationId: UserId(widget.stationId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Station Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStationDetails,
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
                  onPressed: _loadStationDetails,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is StationLoadingState) {
            return const CustomLoadingWidget(
              message: 'Loading station details...',
            );
          }

          if (state is StationErrorState) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: _loadStationDetails,
            );
          }

          if (state is StationDetailsLoadedState) {
            return _buildStationDetail(context, state.station);
          }

          return const CustomErrorWidget(message: 'Station not found');
        },
      ),
    );
  }

  Widget _buildStationDetail(BuildContext context, domain.Station station) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStationHeader(context, station),
          const SizedBox(height: 24),
          _buildStationInfo(context, station),
          const SizedBox(height: 24),
          _buildWorkloadSection(context, station),
          const SizedBox(height: 24),
          _buildStaffSection(context, station),
          const SizedBox(height: 24),
          _buildOrdersSection(context, station),
          const SizedBox(height: 24),
          _buildActionButtons(context, station),
        ],
      ),
    );
  }

  Widget _buildStationHeader(BuildContext context, domain.Station station) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(
              _getStationIcon(station.stationType),
              size: 48,
              color: _getStationTypeColor(station.stationType),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStationTypeLabel(station.stationType),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _getStationTypeColor(station.stationType),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (station.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          station.location!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            AnimatedStationStatusWidget(
              station: station,
              onStatusChanged: (newStatus) => _updateStationStatus(newStatus),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationInfo(BuildContext context, domain.Station station) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Station Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              'Capacity',
              '${station.capacity} orders',
              Icons.groups,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Current Workload',
              '${station.currentWorkload} orders',
              Icons.work,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Active Status',
              station.isActive ? 'Active' : 'Inactive',
              station.isActive ? Icons.check_circle : Icons.cancel,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Created',
              _formatDateTime(station.createdAt),
              Icons.access_time,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkloadSection(BuildContext context, domain.Station station) {
    final workloadPercentage = station.currentWorkload / station.capacity;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workload Distribution',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Load',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${(workloadPercentage * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getWorkloadColor(workloadPercentage),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: workloadPercentage.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getWorkloadColor(workloadPercentage),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWorkloadStat(
                  'Available',
                  station.capacity - station.currentWorkload,
                ),
                _buildWorkloadStat('In Progress', station.currentWorkload),
                _buildWorkloadStat('Total Capacity', station.capacity),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffSection(BuildContext context, domain.Station station) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Assigned Staff',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${station.assignedStaff.length} staff members',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (station.assignedStaff.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No staff assigned to this station',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...station.assignedStaff.map(
                (staffId) => _buildStaffItem(staffId),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersSection(BuildContext context, domain.Station station) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Orders',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${station.currentOrders.length} orders',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (station.currentOrders.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No active orders for this station',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...station.currentOrders.map(
                (orderId) => _buildOrderItem(orderId),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, domain.Station station) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _assignStaff(station),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Assign Staff'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewAnalytics(station),
                    icon: const Icon(Icons.analytics),
                    label: const Text('View Analytics'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildWorkloadStat(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildStaffItem(UserId staffId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Staff ${staffId.value}', // In real app, fetch staff name
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            onPressed: () => _removeStaff(staffId),
            icon: const Icon(Icons.remove_circle_outline),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String orderId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.receipt, size: 20, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Order #$orderId',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            onPressed: () => _viewOrder(orderId),
            icon: const Icon(Icons.visibility),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getStationIcon(domain.StationType type) {
    switch (type) {
      case domain.StationType.grill:
        return Icons.outdoor_grill;
      case domain.StationType.fryer:
        return Icons.local_fire_department;
      case domain.StationType.salad:
        return Icons.eco;
      case domain.StationType.prep:
        return Icons.kitchen;
      case domain.StationType.dessert:
        return Icons.cake;
      case domain.StationType.beverage:
        return Icons.local_drink;
    }
  }

  Color _getStationTypeColor(domain.StationType type) {
    switch (type) {
      case domain.StationType.grill:
        return Colors.orange;
      case domain.StationType.fryer:
        return Colors.red;
      case domain.StationType.salad:
        return Colors.green;
      case domain.StationType.prep:
        return Colors.blue;
      case domain.StationType.dessert:
        return Colors.purple;
      case domain.StationType.beverage:
        return Colors.teal;
    }
  }

  String _getStationTypeLabel(domain.StationType type) {
    switch (type) {
      case domain.StationType.grill:
        return 'Grill Station';
      case domain.StationType.fryer:
        return 'Fryer Station';
      case domain.StationType.salad:
        return 'Salad Station';
      case domain.StationType.prep:
        return 'Prep Station';
      case domain.StationType.dessert:
        return 'Dessert Station';
      case domain.StationType.beverage:
        return 'Beverage Station';
    }
  }

  Color _getWorkloadColor(double percentage) {
    if (percentage < 0.5) return Colors.green;
    if (percentage < 0.8) return Colors.amber;
    return Colors.red;
  }

  String _formatDateTime(dynamic dateTime) {
    // Simple formatting - in real app use intl package
    return 'Recently'; // Placeholder
  }

  // Action methods
  void _updateStationStatus(domain.StationStatus newStatus) {
    // Convert domain status to presentation status for event
    StationStatus presentationStatus;
    switch (newStatus) {
      case domain.StationStatus.available:
      case domain.StationStatus.busy:
        presentationStatus = StationStatus.active;
        break;
      case domain.StationStatus.maintenance:
        presentationStatus = StationStatus.maintenance;
        break;
      case domain.StationStatus.offline:
        presentationStatus = StationStatus.inactive;
        break;
    }

    context.read<StationBloc>().add(
      UpdateStationStatusEvent(
        stationId: UserId(widget.stationId),
        status: presentationStatus,
      ),
    );
  }

  void _assignStaff(domain.Station station) {
    // TODO: Implement staff assignment dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Staff assignment coming soon')),
    );
  }

  void _removeStaff(UserId staffId) {
    // TODO: Implement staff removal
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Staff removal coming soon')));
  }

  void _viewAnalytics(domain.Station station) {
    // TODO: Navigate to analytics page
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Analytics coming soon')));
  }

  void _viewOrder(String orderId) {
    // TODO: Navigate to order details
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Order details coming soon')));
  }
}
