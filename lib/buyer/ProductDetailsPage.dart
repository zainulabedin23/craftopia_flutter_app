import 'package:flutter/material.dart';
import '../api_service.dart'; // Ensure you import your ApiService
import 'ChatScreen.dart';
import 'HomePage.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  final String image;
  final String description;
  final String price;
  final String productName;
  final double rating;
  final String enterpriseName;

  ProductDetailsPage({
    required this.productId,
    required this.image,
    required this.description,
    required this.price,
    required this.productName,
    required this.rating,
    required this.enterpriseName,
  });

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  String? buyerUserId; // To store fetched user ID
  final ApiService apiService = ApiService(); // Your ApiService instance
  bool isLoading = false; // To manage loading state

  @override
  void initState() {
    super.initState();
    fetchUserId(); // Fetch the user ID when the widget initializes
  }

  Future<void> fetchUserId() async {
    try {
      String? fetchedUserId = await apiService.fetchUserIdByEmail();
      if (mounted) {
        setState(() {
          buyerUserId = fetchedUserId;
        });
      }
      print('User ID: $buyerUserId'); // Debugging
    } catch (e) {
      print('Error fetching user ID: $e'); // Handle any errors
    }
  }

  Future<void> buyNow() async {
    if (buyerUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User ID not available. Please try again.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await apiService.createPurchaseEntry(
        productId: widget.productId,
        sellerId: widget.enterpriseName,
        buyerId: buyerUserId!,
        timestamp: DateTime.now(),

      );

      setState(() {
        isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Purchase successful!")),
      );

      // Navigate to HomePage after a short delay to allow the SnackBar to show
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to complete purchase.")),
      );
      print('Error during purchase: $e'); // Handle errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productName,
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage()),
            ); // Go back to HomePage
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 80), // To ensure content is not hidden behind the button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Displaying the passed image URL
                Container(
                  height: 300, // Adjust height as needed
                  child: PageView.builder(
                    itemCount: 1, // Display one image based on passed URL
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(child: Icon(Icons.error)); // Error fallback
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    widget.productName,
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple),
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '\$${widget.price}', // Assuming the price is in dollars; adjust if needed
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent),
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow),
                      SizedBox(width: 4),
                      Text('${widget.rating}/5',
                          style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: Container(
                    height: 60, // Adjusted height
                    width: 310, // Adjusted width
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.deepOrange,
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 36.0, vertical: 8.0),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(0),
                      ),
                      dropdownColor: Colors.deepOrange,
                      value: null,
                      hint: Text(
                        'Select Customization',
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: Icon(Icons.arrow_drop_down,
                          color: Colors.white),
                      items: <String>[
                        'Option 1',
                        'Option 2',
                        'Option 3'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style:
                            TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        // Navigate to the chat screen when a customization is selected
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     // builder: (context) => ChatScreen(),
                        //   ),
                        // );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Enterprise: ${widget.enterpriseName}',
                    style: TextStyle(
                        fontSize: 18, color: Colors.grey[700]),
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Description',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple),
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(widget.description,
                      style: TextStyle(fontSize: 16)),
                ),
                SizedBox(height: 16),
                // Display the user ID if available
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'User ID: ${buyerUserId ?? 'Loading...'}',
                    style: TextStyle(
                        fontSize: 18, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
          // Positioned Buy Now Button
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                await buyNow();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,

                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2.0,
                ),
              )
                  : Text(
                'Buy Now',
                style: TextStyle(
                  height: 1,
                    fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
