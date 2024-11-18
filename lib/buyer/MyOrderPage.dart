import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../api_service.dart';
import 'ChatScreen.dart';

class MyOrderPage extends StatefulWidget {
  @override
  _MyOrderPageState createState() => _MyOrderPageState();
}

class _MyOrderPageState extends State<MyOrderPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> orders = [];
  String? UserId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserId();
    fetchOrders(); // Call the function to fetch orders when the page loads
  }
  Future<void> fetchUserId() async {
    try {
      String? fetchedUserId = await apiService.fetchUserIdByEmail();
      if (mounted) {
        setState(() {
          UserId = fetchedUserId;
        });
      }
      // print('User ID: $buyerUserId'); // Debugging
    } catch (e) {
      print('Error fetching user ID: $e'); // Handle any errors
    }
  }
  Future<void> fetchOrders() async {
    try {
      // Get the current user ID
       // Replace with the actual user ID logic

      // Fetch all purchases where buyerId matches the user ID
      QuerySnapshot purchaseSnapshot = await _firestore
          .collection('purchases')
          .where('buyerId', isEqualTo: UserId)
          .get();

      List<Map<String, dynamic>> orderList = [];

      for (var purchase in purchaseSnapshot.docs) {
        String productId = purchase['productId'];
        var orderTimestamp = purchase['timestamp'];
        String sellerId =purchase['sellerId'];

        String formattedOrderDate;

        // Check if orderTimestamp is a Timestamp or String and format it
        if (orderTimestamp is Timestamp) {
          formattedOrderDate = DateFormat('MM/dd/yyyy')
              .format(orderTimestamp.toDate());
        } else if (orderTimestamp is String) {
          DateTime parsedDate = DateTime.parse(orderTimestamp);
          formattedOrderDate = DateFormat('MM/dd/yyyy').format(parsedDate);
        } else {
          formattedOrderDate = "Unknown Date"; // Fallback if type is unexpected
        }

        // Fetch product details from the products collection using productId
        DocumentSnapshot productSnapshot =
        await _firestore.collection('products').doc(productId).get();

        if (productSnapshot.exists) {
          // Add product details to the order list
          Map<String,dynamic> productData = productSnapshot.data() as Map<String,dynamic>;
          productData['createdAt']= formattedOrderDate;
          productData['sellerId']=sellerId;
          productData['productId']=productId;
          print("$productData");
          orderList.add(productData);
        }
      }

      setState(() {
        orders = orderList;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching orders: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? Center(child: Text("No orders found."))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Title: ${order['title']}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text("Category: ${order['category']}"),
                  Text("Description: ${order['description']}"),
                  Text("Price: \$${order['price']}"),
                  SizedBox(height: 8),
                  Image.network(
                    order['imagePath'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Ordered on: ${order['createdAt']}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement chat functionality here.

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen( sellerId: order['sellerId'],
                            buyerId: UserId ?? "defaultSellerId",
                              productId : order['productId']
                          ),
                        ),
                      );
                      print("Chat with Seller ${order['sellerId']}");
                    },
                    icon: Icon(Icons.chat),
                    label: Text("Chat with Seller"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,

                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
