import 'package:flutter/material.dart';
import '../../../domain/entities/station.dart' as domain;

/// Widget for displaying and updating station status
class StationStatusWidget extends StatelessWidget {
  final domain.Station station;
  final Function(domain.StationStatus)? onStatusChanged;
  final bool showLabel;
  final bool isCompact;

  const StationStatusWidget({
    super.key,
    required this.station,
    this.onStatusChanged,
    this.showLabel = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactStatus(context);
    }
    return _buildFullStatus(context);
  }

  Widget _buildCompactStatus(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getStatusColor(),
            shape: BoxShape.circle,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            _getStatusLabel(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFullStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        border: Border.all(color: _getStatusColor()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(), color: _getStatusColor(), size: 16),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              _getStatusLabel(),
              style: TextStyle(
                color: _getStatusColor(),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
          if (onStatusChanged != null) ...[
            const SizedBox(width: 8),
            PopupMenuButton<domain.StationStatus>(
              icon: Icon(
                Icons.arrow_drop_down,
                color: _getStatusColor(),
                size: 16,
              ),
              onSelected: onStatusChanged,
              itemBuilder: (context) => _buildStatusMenuItems(),
            ),
          ],
        ],
      ),
    );
  }

  List<PopupMenuEntry<domain.StationStatus>> _buildStatusMenuItems() {
    return domain.StationStatus.values.map((status) {
      final isSelected = status == station.status;
      return PopupMenuItem<domain.StationStatus>(
        value: status,
        enabled: !isSelected,
        child: Row(
          children: [
            Icon(
              _getStatusIconForStatus(status),
              color: _getStatusColorForStatus(status),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              _getStatusLabelForStatus(status),
              style: TextStyle(
                color: isSelected ? Colors.grey : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              const Icon(Icons.check, size: 16),
            ],
          ],
        ),
      );
    }).toList();
  }

  Color _getStatusColor() {
    return _getStatusColorForStatus(station.status);
  }

  String _getStatusLabel() {
    return _getStatusLabelForStatus(station.status);
  }

  IconData _getStatusIcon() {
    return _getStatusIconForStatus(station.status);
  }

  Color _getStatusColorForStatus(domain.StationStatus status) {
    switch (status) {
      case domain.StationStatus.available:
        return Colors.green;
      case domain.StationStatus.busy:
        return Colors.amber[700]!;
      case domain.StationStatus.maintenance:
        return Colors.red;
      case domain.StationStatus.offline:
        return Colors.grey[600]!;
    }
  }

  String _getStatusLabelForStatus(domain.StationStatus status) {
    switch (status) {
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

  IconData _getStatusIconForStatus(domain.StationStatus status) {
    switch (status) {
      case domain.StationStatus.available:
        return Icons.check_circle;
      case domain.StationStatus.busy:
        return Icons.schedule;
      case domain.StationStatus.maintenance:
        return Icons.build;
      case domain.StationStatus.offline:
        return Icons.power_off;
    }
  }
}

/// Animated status transition widget
class AnimatedStationStatusWidget extends StatefulWidget {
  final domain.Station station;
  final Function(domain.StationStatus)? onStatusChanged;
  final Duration animationDuration;

  const AnimatedStationStatusWidget({
    super.key,
    required this.station,
    this.onStatusChanged,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedStationStatusWidget> createState() =>
      _AnimatedStationStatusWidgetState();
}

class _AnimatedStationStatusWidgetState
    extends State<AnimatedStationStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedStationStatusWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.station.status != widget.station.status) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: StationStatusWidget(
            station: widget.station,
            onStatusChanged: widget.onStatusChanged,
          ),
        );
      },
    );
  }
}
