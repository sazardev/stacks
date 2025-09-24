// Kitchen Dashboard Page - BLoC Integration
// Main dashboard for kitchen operations with real Order BLoC integration

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/order.dart';
import '../../../domain/value_objects/order_status.dart';
import '../../../infrastructure/core/injection.dart';
import '../../blocs/order/order_bloc.dart';
import '../../blocs/order/order_event.dart';
import '../../blocs/order/order_state.dart';

/// Kitchen Dashboard - Main operational interface
/// Shows order queues, station status, and kitchen metrics in real-time
class KitchenDashboardPage extends StatelessWidget {
  const KitchenDashboardPage({Key? key}) : super(key: key);

  static Widget create() {
    return BlocProvider<OrderBloc>(
      create: (context) => getIt<OrderBloc>()..add(LoadOrdersEvent()),
      child: const KitchenDashboardPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kitchen Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[600],
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshOrders(context),
            tooltip: 'Refresh Orders',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter Orders',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoadingState) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 16),
                  Text('Loading orders...', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          if (state is OrderErrorState) {
            return _buildErrorState(context, state);
          }

          if (state is OrdersLoadedState) {
            return _buildDashboard(context, state);
          }

          // Initial state
          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrdersLoadedState) {
            return FloatingActionButton.extended(
              onPressed: () => _showOrderSummary(context, state),
              backgroundColor: Colors.orange[700],
              icon: const Icon(Icons.analytics),
              label: const Text('Summary'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _refreshOrders(BuildContext context) {
    context.read<OrderBloc>().add(LoadOrdersEvent());
  }

  Widget _buildErrorState(BuildContext context, OrderErrorState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading orders',
            style: TextStyle(fontSize: 18, color: Colors.red[700]),
          ),
          const SizedBox(height: 8),
          Text(
            state.failure?.message ?? 'Unknown error occurred',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _refreshOrders(context),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No orders yet today',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders will appear here as they come in',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _refreshOrders(context),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, OrdersLoadedState state) {
    final orders = state.filteredOrders;
    final pendingOrders = state.pendingOrders;
    final inProgressOrders = state.inProgressOrders;
    final readyOrders = state.readyOrders;
    final completedToday = orders.where((o) => o.status.isCompleted).length;

    return Column(
      children: [
        // Kitchen Metrics Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[100]!, Colors.orange[50]!],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricCard(
                'Total Orders',
                orders.length.toString(),
                Icons.receipt_long,
              ),
              _buildMetricCard(
                'In Progress',
                inProgressOrders.length.toString(),
                Icons.kitchen,
              ),
              _buildMetricCard(
                'Ready to Serve',
                readyOrders.length.toString(),
                Icons.restaurant,
              ),
              _buildMetricCard(
                'Completed Today',
                completedToday.toString(),
                Icons.check_circle,
              ),
            ],
          ),
        ),

        // Order Queues
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pending Orders Column
                Expanded(
                  child: _buildOrderColumn(
                    context,
                    'Pending Orders',
                    pendingOrders,
                    Colors.blue[600]!,
                    Icons.schedule,
                  ),
                ),
                const SizedBox(width: 8),

                // In Progress Orders Column
                Expanded(
                  child: _buildOrderColumn(
                    context,
                    'In Progress',
                    inProgressOrders,
                    Colors.orange[600]!,
                    Icons.kitchen,
                  ),
                ),
                const SizedBox(width: 8),

                // Ready Orders Column
                Expanded(
                  child: _buildOrderColumn(
                    context,
                    'Ready to Serve',
                    readyOrders,
                    Colors.green[600]!,
                    Icons.restaurant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.orange[600], size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderColumn(
    BuildContext context,
    String title,
    List<Order> orders,
    Color color,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(7),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    orders.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: orders.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, color: Colors.grey[400], size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'No orders',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: orders.length,
                    itemBuilder: (context, index) =>
                        _buildOrderCard(context, orders[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showOrderDetails(context, order),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.value.substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  _buildPriorityBadge(order.priority),
                ],
              ),
              const SizedBox(height: 8),

              // Order Details
              Row(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${order.items.length} items',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${order.estimatedTimeMinutes} min',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Amount
              Text(
                '\$${order.totalAmount.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),

              // Special Instructions
              if (order.specialInstructions != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.amber[700],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order.specialInstructions!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action Buttons
              const SizedBox(height: 12),
              _buildOrderActions(context, order),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(priority) {
    Color color;
    String label;

    if (priority.isHigh) {
      color = Colors.red;
      label = 'HIGH';
    } else if (priority.isMedium) {
      color = Colors.orange;
      label = 'MED';
    } else {
      color = Colors.green;
      label = 'LOW';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrderActions(BuildContext context, Order order) {
    final orderBloc = context.read<OrderBloc>();

    if (order.status.isPending) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => orderBloc.add(
                UpdateOrderStatusEvent(
                  orderId: order.id,
                  newStatus: OrderStatus.preparing(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Start Prep'),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _showCancelDialog(context, order),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            child: const Text('Cancel'),
          ),
        ],
      );
    }

    if (order.status.isPreparing) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => orderBloc.add(
            UpdateOrderStatusEvent(
              orderId: order.id,
              newStatus: OrderStatus.ready(),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: const Text('Mark Ready'),
        ),
      );
    }

    if (order.status.isReady) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => orderBloc.add(
            UpdateOrderStatusEvent(
              orderId: order.id,
              newStatus: OrderStatus.completed(),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: const Text('Mark Served'),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showOrderDetails(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.id.value.substring(0, 8)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${order.status.displayName}'),
            Text('Items: ${order.items.length}'),
            Text('Total: \$${order.totalAmount.amount.toStringAsFixed(2)}'),
            Text('Created: ${order.createdAt.dateTime}'),
            if (order.specialInstructions != null)
              Text('Instructions: ${order.specialInstructions}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text(
          'Are you sure you want to cancel order #${order.id.value.substring(0, 8)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<OrderBloc>().add(
                UpdateOrderStatusEvent(
                  orderId: order.id,
                  newStatus: OrderStatus.cancelled(),
                  notes: 'Cancelled from kitchen dashboard',
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Orders'),
        content: const Text('Filter options will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kitchen Settings'),
        content: const Text('Kitchen settings will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showOrderSummary(BuildContext context, OrdersLoadedState state) {
    final totalOrders = state.orders.length;
    final pendingCount = state.pendingOrders.length;
    final inProgressCount = state.inProgressOrders.length;
    final readyCount = state.readyOrders.length;
    final completedCount = state.orders
        .where((o) => o.status.isCompleted)
        .length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kitchen Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Orders: $totalOrders'),
            Text('Pending: $pendingCount'),
            Text('In Progress: $inProgressCount'),
            Text('Ready: $readyCount'),
            Text('Completed Today: $completedCount'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
