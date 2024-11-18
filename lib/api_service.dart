import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ApiService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Fetch categories from Firestore
  Future<List<String>> fetchCategories() async {
    List<String> categories = [];
    try {
      QuerySnapshot querySnapshot = await firestore.collection('category').get();

      // Check if any documents exist
      if (querySnapshot.docs.isNotEmpty) {
        categories = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return data['name'].toString();
        }).toList();
      } else {
        print('No categories found');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
    return categories;
  }
  Future<String?> fetchUserIdByEmail() async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;
      String? email = user?.email;

      if (email != null) {
        QuerySnapshot querySnapshot = await firestore.collection('users').where('email', isEqualTo: email).get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

          // Return the user ID (document ID)
          return documentSnapshot.id;
        } else {
          print('No user found with email: $email');
        }
      } else {
        print('No user is logged in');
      }
    } catch (e) {
      print('Error fetching user ID: $e');
    }
    return null;
  }
  Future<void> createPurchaseEntry({
    required String productId,
    required String sellerId,
    required String buyerId,
    required DateTime timestamp,
  }) async {
    try {
      // Create a new document in the "purchases" collection
      await firestore.collection("purchases").add({
        'productId': productId,
        'sellerId': sellerId,
        'buyerId': buyerId,
        'timestamp': timestamp.toIso8601String(),
      });
      print("Purchase entry created successfully.");
    } catch (e) {
      print("Error creating purchase entry: $e");
    }
  }

}
