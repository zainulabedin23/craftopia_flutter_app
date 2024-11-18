import 'package:flutter/material.dart';

// Import the Order model from the file where it is defined
import 'ManageOrdersScreen.dart'; // Ensure this import matches the location of your Order model

class SellerOrderScreen extends StatelessWidget {
  final Order order;

  SellerOrderScreen({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${order.orderId}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8.0),
            Text('Buyer: ${order.buyerName}'),
            Text('Status: ${order.status}'),
            Text('Total: \$${order.total.toStringAsFixed(2)}'),
            SizedBox(height: 16),
            Text(
              'Shipping Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8.0),
            Text('Shipping Address: 123 Main Street, New York, NY'),
            Text('Phone Number: (123) 456-7890'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _acceptOrder(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Accept',style: TextStyle(color: Colors.white),),
                ),
                ElevatedButton(
                  onPressed: () => _rejectOrder(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Reject',style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _acceptOrder(BuildContext context) {
    // Handle order acceptance logic
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Order ${order.orderId} accepted!',
        style: TextStyle(color: Colors.white), // Set text color to white
      ),
      backgroundColor: Colors.green,
    ));
  }

  void _rejectOrder(BuildContext context) {
    // Handle order rejection logic
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Order ${order.orderId} rejected!',
        style: TextStyle(color: Colors.white), // Set text color to white
      ),
      backgroundColor: Colors.red,
    ));
  }
}
