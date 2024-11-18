import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:craftopia/buyer/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'seller/SellerDashboard.dart';
import 'SplashScreen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
const kPrimaryColor = Color(0xFF6F35A5);
const kPrimaryLightColor = Color(0xFFF1E6FF);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.safetyNet,
    // webRecaptchaSiteKey: 'your-site-key', // Only for web if you need it
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  String? role;
  bool isLoading = true; // To show loading state

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _fetchUserRole(); // Fetch the user's role from Firestore if logged in
    } else {
      setState(() {
        isLoading = false; // If no user is logged in, stop loading
      });
    }
  }

  // Fetch the user's role from Firestore
  Future<void> _fetchUserRole() async {
    try {
      var querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user?.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data();
        setState(() {
          role = userData['role']; // Fetch the role
          isLoading = false; // Done loading
        });
      } else {
        setState(() {
          isLoading = false; // Done loading even if no user is found
        });
      }
    } catch (e) {
      print('Error fetching user role: $e');
      setState(() {
        isLoading = false; // Handle error and stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth UI Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner while fetching role
          : _getHomePage(), // Decide the home page based on user role or login state
    );
  }

  // Decide the home page based on the user's role or login state
  Widget _getHomePage() {
    if (user == null) {
      return LoginPage(); // Redirect to LoginPage if no user is logged in
    } else if (role == 'Seller') {
      return SellerDashboard(); // Redirect to SellerDashboard if the role is 'Seller'
    } else if (role == 'Buyer') {
      return HomePage(); // Redirect to HomePage if the role is 'Buyer'
    } else {
      return LoginPage(); // Default to LoginPage if role is not found
    }
  }
}
