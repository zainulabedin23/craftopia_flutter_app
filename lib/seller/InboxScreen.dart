import 'package:craftopia/api_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'BuyerListScren.dart';

class InboxScreen extends StatefulWidget {
  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String? userIdFinal;
 final ApiService apiService = ApiService();
  Map<String, List<String>> productBuyerMap = {}; // Map to hold product ID as key and list of buyer IDs as value
  Map<String, Map<String, dynamic>> productDetailsMap = {}; // Map to hold product details

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    String? fetchedUserId = await apiService.fetchUserIdByEmail();
    setState(() {
      userIdFinal = fetchedUserId;
    });

    if (userIdFinal != null) {
      _fetchPurchases();
    }
  }

  Future<void> _fetchPurchases() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('purchases')
          .where('sellerId', isEqualTo: userIdFinal)
          .get();

      Map<String, List<String>> tempMap = {};

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String productId = data['productId'];
        String buyerId = data['buyerId'];

        if (tempMap.containsKey(productId)) {
          tempMap[productId]!.add(buyerId);
        } else {
          tempMap[productId] = [buyerId];
        }
      }

      setState(() {
        productBuyerMap = tempMap;
      });

      // Fetch product details for each unique product ID
      for (String productId in productBuyerMap.keys) {
        await _fetchProductDetails(productId);
      }
    } catch (e) {
      print("Error fetching purchases: $e");
    }
  }

  Future<void> _fetchProductDetails(String productId) async {
    try {
      DocumentSnapshot productSnapshot =
      await FirebaseFirestore.instance.collection('products').doc(productId).get();

      if (productSnapshot.exists) {
        setState(() {
          productDetailsMap[productId] = productSnapshot.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print("Error fetching product details: $e");
    }
  }

  void _navigateToBuyerListScreen(String productId, List<String> buyers) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyerListScreen(
          productId: productId,
          buyers: buyers,

        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buyers by Product'),
      ),
      body: userIdFinal == null
          ? Center(child: CircularProgressIndicator())
          : productBuyerMap.isEmpty
          ? Center(child: Text("No buyers found."))
          : ListView.builder(
        itemCount: productBuyerMap.length,
        itemBuilder: (context, index) {
          String productId = productBuyerMap.keys.elementAt(index);
          List<String> buyers = productBuyerMap[productId]!;
          Map<String, dynamic>? productDetails = productDetailsMap[productId];

          if (productDetails == null) {
            return ListTile(title: Text("Loading..."));
          }

          String title = productDetails['title'] ?? 'No Title';
          String category = productDetails['category'] ?? 'No Category';
          String imagePath = productDetails['imagePath'] ?? '';

          return ListTile(
            leading: Image.network(
              imagePath,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(title),
            subtitle: Text(category),
            onTap: () => _navigateToBuyerListScreen(productId, buyers),
          );
        },
      ),
    );
  }
}
