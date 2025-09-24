// Kitchen Dashboard Page - Simplified Mock Version
// Main dashboard for kitchen operations with mock data display

import 'package:flutter/material.dart';

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
  List<MockOrder> _mockOrders = [];
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

  List<MockOrder> _generateMockOrders() {
    return [
      MockOrder(
        id: '001',
        status: OrderStatus.pending,
        itemCount: 3,
        estimatedTime: 15,
        totalAmount: 25.99,
        priority: Priority.medium,
        specialInstructions: 'Extra spicy',
      ),
      MockOrder(
        id: '002',
        status: OrderStatus.preparing,
        itemCount: 2,
        estimatedTime: 12,
        totalAmount: 18.50,
        priority: Priority.high,
        specialInstructions: null,
      ),
      MockOrder(
        id: '003',
        status: OrderStatus.ready,
        itemCount: 1,
        estimatedTime: 8,
        totalAmount: 12.99,
        priority: Priority.low,
        specialInstructions: 'No onions',
      ),
      MockOrder(
        id: '004',
        status: OrderStatus.pending,
        itemCount: 5,
        estimatedTime: 20,
        totalAmount: 42.75,
        priority: Priority.high,
        specialInstructions: 'Allergic to nuts',
      ),
      MockOrder(
        id: '005',
        status: OrderStatus.preparing,
        itemCount: 2,
        estimatedTime: 10,
        totalAmount: 16.25,
        priority: Priority.medium,
        specialInstructions: null,
      ),
    ];
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

  Widget _buildDashboard(BuildContext context) {
    final pendingOrders = _mockOrders
        .where((o) => o.status == OrderStatus.pending)
        .toList();
    final inProgressOrders = _mockOrders
        .where((o) => o.status == OrderStatus.preparing)
        .toList();
    final readyOrders = _mockOrders
        .where((o) => o.status == OrderStatus.ready)
        .toList();
    final completedToday = _mockOrders
        .where((o) => o.status == OrderStatus.completed)
        .length;

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
                _mockOrders.length.toString(),
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
    List<MockOrder> orders,
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

  Widget _buildOrderCard(BuildContext context, MockOrder order) {
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
                    'Order #${order.id}',
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
                      color: _getPriorityColor(order.priority),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.priority.displayName.toUpperCase(),
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
                'Time: ${order.estimatedTime} min',
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
                  if (order.status == OrderStatus.pending) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _startOrder(order),
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
                  ] else if (order.status == OrderStatus.preparing) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _markReady(order),
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
                  ] else if (order.status == OrderStatus.ready) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _completeOrder(order),
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
            onPressed: _refreshOrders,
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

  // Helper methods
  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  // Action methods
  void _startOrder(MockOrder order) {
    setState(() {
      order.status = OrderStatus.preparing;
    });
    _showSnackBar('Order #${order.id} started preparation', Colors.orange);
  }

  void _markReady(MockOrder order) {
    setState(() {
      order.status = OrderStatus.ready;
    });
    _showSnackBar('Order #${order.id} is ready to serve', Colors.green);
  }

  void _completeOrder(MockOrder order) {
    setState(() {
      order.status = OrderStatus.completed;
    });
    _showSnackBar('Order #${order.id} has been served', Colors.blue);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, MockOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${order.status.displayName}'),
            Text('Items: ${order.itemCount}'),
            Text('Estimated time: ${order.estimatedTime} minutes'),
            Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
            Text('Priority: ${order.priority.displayName}'),
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
    final totalOrders = _mockOrders.length;
    final pendingCount = _mockOrders
        .where((o) => o.status == OrderStatus.pending)
        .length;
    final inProgressCount = _mockOrders
        .where((o) => o.status == OrderStatus.preparing)
        .length;
    final readyCount = _mockOrders
        .where((o) => o.status == OrderStatus.ready)
        .length;
    final completedCount = _mockOrders
        .where((o) => o.status == OrderStatus.completed)
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

// Mock data models
class MockOrder {
  String id;
  OrderStatus status;
  int itemCount;
  int estimatedTime;
  double totalAmount;
  Priority priority;
  String? specialInstructions;

  MockOrder({
    required this.id,
    required this.status,
    required this.itemCount,
    required this.estimatedTime,
    required this.totalAmount,
    required this.priority,
    this.specialInstructions,
  });
}

enum OrderStatus { pending, preparing, ready, completed, cancelled }

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum Priority { low, medium, high }

extension PriorityExtension on Priority {
  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }
}
