import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../api_service.dart';
import 'AddProductScreen.dart';
import 'UpdateProductScreen.dart';
// import 'CategoryDetailScreen.dart';

class ManageCategoriesScreen extends StatefulWidget {
  @override
  _ManageCategoriesScreenState createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiService apiService = ApiService();
  final List<Map<String, dynamic>> _products = [];
  bool isLoading = true;
  User? user;
  String? userIdFinal;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    _fetchUserProducts();
  }

  Future<void> _fetchUserId() async {
    String? fetchedUserId = await apiService.fetchUserIdByEmail();
    setState(() {
      userIdFinal = fetchedUserId;
    });

    if (userIdFinal != null) {
      print('User ID: $userIdFinal');
    }
  }

  // Fetch products added by the current user from Firestore
  Future<void> _fetchUserProducts() async {
    try {
      final userId = userIdFinal;
      var querySnapshot = await _firestore
          .collection('products')
          .where('userId', isEqualTo: userIdFinal)
          .get();
      print('Number of products retrieved: ${querySnapshot.docs.length}');
      // Store the products in _products list
      var filteredProducts = querySnapshot.docs.where((doc) => doc['userId'] == userIdFinal).toList();

      setState(() {
        _products.addAll(
            querySnapshot.docs
                .where((doc) => doc['userId'] == userIdFinal) // Filter by userId
                .map((doc) {

              var data = doc.data();
              data['productId'] = doc.id; // Add the unique product ID
              return data;
            })
                .toList()
        );
        _products.sort((a, b) {
          DateTime dateA = a['createdAt'];
          DateTime dateB = b['createdAt'];
          return dateA.compareTo(dateB);
        });
// Optionally print the filtered products
        _products.forEach((product) {
          print('Product Data: $product');
        });
        isLoading = false;
      });
      for (var doc in querySnapshot.docs) {
        print('Product ID: ${doc.id}, User ID: ${doc['userId']}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Product', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return _buildCategoryItem(_products[index]);
                },
              ),
            ),
            SizedBox(height: 16.0),
            _buildAddProductSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> product) {
    // final createdAt = (product['createdAt'] as Timestamp).toDate();

    return ListTile(
      leading: product['imagePath'] != null
          ? Image.network(
        product['imagePath'],
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      )
          : Container(
        width: 50,
        height: 50,
        color: Colors.grey[300],
        child: Icon(Icons.image, color: Colors.grey[700]),
      ),
      title: Text(product['title'], style: TextStyle(fontSize: 16.0)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price: \$${product['price']}'),
          // Text('Created: ${createdAt.toString()}'),
        ],
      ),
      onTap: () {
        print('Product ID: ${product['productId']}');
        print('Title: ${product['title']}');
        print('Price: ${product['price']}');
        print('Image Path: ${product['imagePath']}');
        print('Created At: ${product['createdAt']}');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateProductScreen(
              id: product['productId'] ?? 'Unknown ID',
              title: product['title'] ?? 'No Title',
              price: double.tryParse(product['price'].toString()) ?? 0.0,
              imagePath: product['imagePath'] ?? 'default_image_url',
              // createdAt: (product['createdAt'] as Timestamp).toDate(),
              description: product['description'] ?? "",
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddProductSection() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
        ),
        child: Text('Add Product', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }
}
