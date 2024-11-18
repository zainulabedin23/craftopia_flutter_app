import 'package:craftopia/seller/SellerDashboard.dart'; // Ensure this import is correct
import 'package:flutter/material.dart';
import 'SellerOrderScreen.dart';

class ManageOrdersScreen extends StatelessWidget {
  final List<Order> orders = [
    Order(orderId: '1234', buyerName: 'John Doe', status: 'Pending', total: 150.00),
    Order(orderId: '5678', buyerName: 'Jane Smith', status: 'Shipped', total: 99.99),
    Order(orderId: '91011', buyerName: 'Mike Johnson', status: 'Delivered', total: 200.00),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => SellerDashboard()), // Ensure this is correct
                  (route) => false, // Remove all previous routes
            );
          },
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index], context);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order, BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text('Order ID: ${order.orderId}', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buyer: ${order.buyerName}'),
            Text('Status: ${order.status}'),
            Text('Total: \$${order.total.toStringAsFixed(2)}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String result) {
            _updateOrderStatus(result, order, context);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'Shipped',
              child: Text('Mark as Shipped'),
            ),
            PopupMenuItem<String>(
              value: 'Delivered',
              child: Text('Mark as Delivered'),
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SellerOrderScreen(order: order),
            ),
          );
        },
      ),
    );
  }

  void _updateOrderStatus(String newStatus, Order order, BuildContext context) {
    // Simulate updating order status
    order.status = newStatus;

    // Show feedback message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Order ${order.orderId} marked as $newStatus.'),
      backgroundColor: Colors.green,
    ));
  }
}

// Order model
class Order {
  final String orderId;
  final String buyerName;
  String status;
  final double total;

  Order({
    required this.orderId,
    required this.buyerName,
    required this.status,
    required this.total,
  });
}
