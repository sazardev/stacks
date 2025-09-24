// Kitchen Dashboard Page
// Main dashboard for kitchen operations with order management and station monitoring

import 'package:flutter/material.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/value_objects/order_status.dart';
import '../../../domain/value_objects/money.dart';
import '../../../domain/value_objects/priority.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/order_id.dart';

/// Kitchen Dashboard - Main operational interface
/// Shows order queues, station status, and kitchen metrics in real-time
class KitchenDashboardPage extends StatefulWidget {
  const KitchenDashboardPage({Key? key}) : super(key: key);

  static Widget create() {
    return const KitchenDashboardPage();
  }

  @override
  State<KitchenDashboardPage> createState() => _KitchenDashboardPageState();
}

class _KitchenDashboardPageState extends State<KitchenDashboardPage> {
  List<Order> _mockOrders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _mockOrders = _generateMockOrders();
        _isLoading = false;
      });
    });
  }

  List<Order> _generateMockOrders() {
    try {
      return [
        // Mock Order 1 - Pending
        Order.create(
          customerId: UserId.fromString('customer1'),
          items: [], // Empty for now
          totalAmount: Money(25.99),
          specialInstructions: 'Extra spicy',
        ),
        // Add more mock orders as needed
      ];
    } catch (e) {
      // If there are issues with Order creation, return empty list
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Dashboard'),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrders,
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
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 16),
                  Text('Loading orders...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : _mockOrders.isEmpty
          ? _buildEmptyState(context)
          : _buildDashboard(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOrderSummary(context),
        backgroundColor: Colors.orange[700],
        icon: const Icon(Icons.analytics),
        label: const Text('Summary'),
      ),
    );
  }

  void _refreshOrders() {
    _loadMockData();
  }

  Widget _buildDashboard(BuildContext context, OrdersLoadedState state) {
    final pendingOrders = state.pendingOrders;
    final inProgressOrders = state.inProgressOrders;
    final readyOrders = state.readyOrders;

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
                state.totalOrders.toString(),
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
                state.completedToday.toString(),
                Icons.check_circle,
              ),
            ],
          ),
        ),

        // Order Queues
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pending Orders Column
                Expanded(
                  child: _buildOrderColumn(
                    context,
                    'Pending Orders',
                    pendingOrders,
                    Colors.blue[100]!,
                    Colors.blue[800]!,
                  ),
                ),
                const SizedBox(width: 16),

                // In Progress Orders Column
                Expanded(
                  child: _buildOrderColumn(
                    context,
                    'In Progress',
                    inProgressOrders,
                    Colors.orange[100]!,
                    Colors.orange[800]!,
                  ),
                ),
                const SizedBox(width: 16),

                // Ready Orders Column
                Expanded(
                  child: _buildOrderColumn(
                    context,
                    'Ready to Serve',
                    readyOrders,
                    Colors.green[100]!,
                    Colors.green[800]!,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32, color: Colors.orange[700]),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orange[800],
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderColumn(
    BuildContext context,
    String title,
    List<Order> orders,
    Color backgroundColor,
    Color titleColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: titleColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: titleColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              '$title (${orders.length})',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: titleColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No orders',
                            style: TextStyle(
                              color: titleColor.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(context, orders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(order.priority.level),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getPriorityText(order.priority.level),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Order Info
              Text(
                'Items: ${order.itemCount}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                'Time: ${order.estimatedTimeMinutes} min',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              if (order.specialInstructions != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Note: ${order.specialInstructions}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange[700],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 8),

              // Action Buttons
              Row(
                children: [
                  if (order.status.isPending) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _startOrder(context, order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 32),
                        ),
                        child: const Text(
                          'Start',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ] else if (order.status.isPreparing) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _markReady(context, order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 32),
                        ),
                        child: const Text(
                          'Ready',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ] else if (order.status.isReady) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _completeOrder(context, order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 32),
                        ),
                        child: const Text(
                          'Serve',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No orders in the kitchen',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders will appear here as they come in',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<OrderBloc>().add(RefreshOrdersEvent()),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.kitchen, size: 64, color: Colors.orange[400]),
          const SizedBox(height: 16),
          Text(
            'Kitchen Dashboard',
            style: TextStyle(
              fontSize: 24,
              color: Colors.orange[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap refresh to load orders',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<OrderBloc>().add(LoadOrdersEvent()),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Load Orders'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getPriorityColor(int priority) {
    if (priority >= 80) return Colors.red;
    if (priority >= 60) return Colors.orange;
    if (priority >= 40) return Colors.yellow[700]!;
    return Colors.green;
  }

  String _getPriorityText(int priority) {
    if (priority >= 80) return 'HIGH';
    if (priority >= 60) return 'MED';
    return 'LOW';
  }

  // Action methods
  void _startOrder(BuildContext context, Order order) {
    context.read<OrderBloc>().add(
      StartOrderPreparationEvent(
        orderId: order.id,
        chefId:
            di.getIt.currentUser?.id ?? order.customerId, // Mock current user
      ),
    );
  }

  void _markReady(BuildContext context, Order order) {
    context.read<OrderBloc>().add(
      MarkOrderReadyEvent(
        orderId: order.id,
        chefId:
            di.getIt.currentUser?.id ?? order.customerId, // Mock current user
      ),
    );
  }

  void _completeOrder(BuildContext context, Order order) {
    context.read<OrderBloc>().add(
      CompleteOrderEvent(
        orderId: order.id,
        completedByUserId:
            di.getIt.currentUser?.id ?? order.customerId, // Mock current user
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Order order) {
    context.read<OrderBloc>().add(GetOrderDetailsEvent(orderId: order.id));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.id.value.substring(0, 8)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${order.status.displayName}'),
            Text('Items: ${order.itemCount}'),
            Text('Estimated time: ${order.estimatedTimeMinutes} minutes'),
            Text('Total: \$${order.totalAmount.value.toStringAsFixed(2)}'),
            if (order.specialInstructions != null)
              Text('Notes: ${order.specialInstructions}'),
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

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Orders'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filter options will be implemented here'),
            // TODO: Add filter options
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dashboard Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Settings options will be implemented here'),
            // TODO: Add settings options
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

  void _showOrderSummary(BuildContext context) {
    final orderBloc = context.read<OrderBloc>();
    final state = orderBloc.state;

    if (state is OrdersLoadedState) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kitchen Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Orders: ${state.totalOrders}'),
              Text('Pending: ${state.pendingOrders.length}'),
              Text('In Progress: ${state.inProgressOrders.length}'),
              Text('Ready: ${state.readyOrders.length}'),
              Text('Completed Today: ${state.completedToday}'),
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
}
