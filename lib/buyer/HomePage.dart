import 'package:flutter/material.dart';
import 'dart:async';
import 'CartPage.dart';
import 'ProfilePage.dart';
import 'OrderPage.dart';
import 'ProductDetailsPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _products = [];
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  Timer? _timer; // Timer for automatic sliding

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    _fetchProducts();
  }
  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_pageController.page!.toInt() + 1) % 3;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });



  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigate to the selected page
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              HomePage()), // Replace with your HomePage widget
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              OrderPage()), // Replace with your OrderPage widget
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              CartPage()), // Replace with your CartPage widget
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              ProfilePage()), // Replace with your ProfilePage widget
        );
        break;
    }



  }
  Future<void> _fetchProducts() async {
    try {
      var querySnapshot = await _firestore
          .collection('products')
          .limit(6) // Limit the results to the top 6 recent products
          .get();

      print('Number of products retrieved: ${querySnapshot.docs.length}');

      // Store the products in _products list without additional filtering or sorting
      setState(() {
        _products.addAll(
            querySnapshot.docs.map((doc) {
              var data = doc.data();
              data['productId'] = doc.id; // Add the unique product ID
              return data;
            }).toList()
        );
      });
      _products.forEach((product) {
        print('Product Data: $product');
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }
// Product data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/logo.jpg',
            height: 150, // Increase height
            width: 150,  // Increase width
          ),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for products',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.mic, color: Colors.grey.shade600),
                onPressed: () {
                  // Handle voice search action
                },
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Handle notifications action
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => CartPage() ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Carousel/Slider
          Container(
            height: 200,
            child: PageView(
              children: [
                Image.asset('assets/banner.jpg', fit: BoxFit.cover),
                Image.asset('assets/banner2.jpg', fit: BoxFit.cover),
                // Image.asset('assets/slider2.jpg', fit: BoxFit.cover),
                // Image.asset('assets/slider3.jpg', fit: BoxFit.cover),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),

            child: Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CategoryCard(
                  icon: Icons.watch,
                  label: 'Jewelry',
                  color: Colors.purple,
                ),
                CategoryCard(
                  icon: Icons.home,
                  label: 'Home Decor',
                  color: Colors.orange,
                ),
                CategoryCard(
                  icon: Icons.chair,
                  label: 'Furniture',
                  color: Colors.brown,
                ),
                CategoryCard(
                  icon: Icons.style,
                  label: 'Crocheted Items',
                  color: Colors.green,
                ),

              ],
            ),
          ),
          SizedBox(height: 16),

          // Featured Products
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Featured Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8),
          GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 17,
            ),
            itemCount: _products.length, // Updated itemCount to match _products length
            itemBuilder: (context, index) {
              final product = _products[index];
              return ProductCard(
                image: product['imagePath'], // Use the correct keys here
                name: product['title'],
                price: product['price'].toString(),
                productId: product['productId'].toString(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsPage(
                        productId: product['productId'] ?? 'Unknown', // Use fallback if null
                        image: product['imagePath'] ?? '', // Use fallback if null
                        description: product['description'] ?? 'No description available.', // Use fallback if null
                        price: (product['price'] ?? 0.0).toString(), // Use fallback if null, ensure it's a double
                        productName: product['title'] ?? 'Unnamed Product', // Add product name with fallback
                        rating: (product['rating'] ?? 0.0).toDouble(), // Use fallback for rating
                        enterpriseName: product['userId'] ?? 'Unknown Enterprise', // Add enterprise name with fallback
                     // userId : product['userId'] ?? '';
                      ),
                    ),
                  );


                },
              );
            },
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
          ),

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const CategoryCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  spreadRadius: 1, // Reduced spread radius
                  blurRadius: 4, // Reduced blur radius
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: color,
              child: Icon(icon, size: 24, color: Colors.white),
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14, // Reduced text size
              fontWeight: FontWeight.w400, // Optional: Adjust font weight if needed
            ),
          ),
        ],
      ),
    );
  }
}


class ProductCard extends StatelessWidget {
  final String image;
  final String name;
  final String price;
  final VoidCallback onTap;
  final String productId;

  const ProductCard({
    required this.image,
    required this.name,
    required this.price,
    required this.onTap,
    required this.productId
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Add this
      child:  Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: // Assuming ProductCard has an image parameter and uses it as follows:
              Image(
                image: NetworkImage(image), // Replace AssetImage with NetworkImage
                fit: BoxFit.cover,
                height: 120,
                width: double.infinity,
              ),

            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                price,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.purple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}