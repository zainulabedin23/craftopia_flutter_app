import 'package:flutter/material.dart';

import 'ChatScreenSeller.dart';

class BuyerListScreen extends StatelessWidget {
  final String productId;
  final List<String> buyers;

  BuyerListScreen({required this.productId, required this.buyers});

  void _navigateToChatScreen(BuildContext context, String buyerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreenBuyer(
          productId: productId,
          buyerId: buyerId,

        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buyers for Product'),
      ),
      body: buyers.isEmpty
          ? Center(child: Text("No buyers found."))
          : ListView.builder(
        itemCount: buyers.length,
        itemBuilder: (context, index) {
          String buyerId = buyers[index];
          return ListTile(
            title: Text('Buyer ID: $buyerId'),
            onTap: () => _navigateToChatScreen(context, buyerId),
          );
        },
      ),
    );
  }
}
