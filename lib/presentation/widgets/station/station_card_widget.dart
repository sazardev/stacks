import 'package:flutter/material.dart';
import '../../../domain/entities/station.dart' as domain;
import '../../blocs/station/station_event.dart';

/// Widget for displaying a station card with status and actions
class StationCardWidget extends StatelessWidget {
  final domain.Station station;
  final VoidCallback? onTap;
  final Function(StationStatus)? onStatusUpdate;

  const StationCardWidget({
    super.key,
    required this.station,
    this.onTap,
    this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              _buildStationType(context),
              const SizedBox(height: 8),
              _buildStatus(context),
              const Spacer(),
              _buildWorkload(context),
              const SizedBox(height: 8),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            station.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(_getStationIcon(), color: _getStatusColor(), size: 20),
      ],
    );
  }

  Widget _buildStationType(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStationTypeColor().withOpacity(0.1),
        border: Border.all(color: _getStationTypeColor()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStationTypeLabel(),
        style: TextStyle(
          color: _getStationTypeColor(),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatus(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getStatusColor(),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _getStatusLabel(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: _getStatusColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkload(BuildContext context) {
    final workloadPercentage = station.currentWorkload / station.capacity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Workload',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            Text(
              '${station.currentWorkload}/${station.capacity}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: workloadPercentage.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getWorkloadColor(workloadPercentage),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (onStatusUpdate == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatusButton(
          context: context,
          status: StationStatus.active,
          icon: Icons.play_arrow,
          isSelected: _isStationActive(),
        ),
        _buildStatusButton(
          context: context,
          status: StationStatus.maintenance,
          icon: Icons.build,
          isSelected: station.status == domain.StationStatus.maintenance,
        ),
        _buildStatusButton(
          context: context,
          status: StationStatus.inactive,
          icon: Icons.pause,
          isSelected: station.status == domain.StationStatus.offline,
        ),
      ],
    );
  }

  Widget _buildStatusButton({
    required BuildContext context,
    required StationStatus status,
    required IconData icon,
    required bool isSelected,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: IconButton(
          onPressed: isSelected ? null : () => onStatusUpdate?.call(status),
          icon: Icon(icon),
          color: isSelected
              ? _getStatusColorForStatus(status)
              : Colors.grey[600],
          iconSize: 16,
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          style: IconButton.styleFrom(
            backgroundColor: isSelected
                ? _getStatusColorForStatus(status).withOpacity(0.1)
                : null,
          ),
        ),
      ),
    );
  }

  IconData _getStationIcon() {
    switch (station.stationType) {
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

  Color _getStationTypeColor() {
    switch (station.stationType) {
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

  String _getStationTypeLabel() {
    switch (station.stationType) {
      case domain.StationType.grill:
        return 'Grill';
      case domain.StationType.fryer:
        return 'Fryer';
      case domain.StationType.salad:
        return 'Salad';
      case domain.StationType.prep:
        return 'Prep';
      case domain.StationType.dessert:
        return 'Dessert';
      case domain.StationType.beverage:
        return 'Beverage';
    }
  }

  Color _getStatusColor() {
    switch (station.status) {
      case domain.StationStatus.available:
        return Colors.green;
      case domain.StationStatus.busy:
        return Colors.amber;
      case domain.StationStatus.maintenance:
        return Colors.red;
      case domain.StationStatus.offline:
        return Colors.grey;
    }
  }

  String _getStatusLabel() {
    switch (station.status) {
      case domain.StationStatus.available:
        return 'Available';
      case domain.StationStatus.busy:
        return 'Busy';
      case domain.StationStatus.maintenance:
        return 'Maintenance';
      case domain.StationStatus.offline:
        return 'Offline';
    }
  }

  Color _getWorkloadColor(double percentage) {
    if (percentage < 0.5) return Colors.green;
    if (percentage < 0.8) return Colors.amber;
    return Colors.red;
  }

  Color _getStatusColorForStatus(StationStatus status) {
    switch (status) {
      case StationStatus.active:
        return Colors.green;
      case StationStatus.inactive:
        return Colors.grey;
      case StationStatus.maintenance:
        return Colors.red;
      case StationStatus.outOfOrder:
        return Colors.red[800]!;
    }
  }

  bool _isStationActive() {
    return station.status == domain.StationStatus.available ||
        station.status == domain.StationStatus.busy;
  }
}
