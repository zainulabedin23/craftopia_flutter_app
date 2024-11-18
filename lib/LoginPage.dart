import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:craftopia/buyer/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'buyer/HomePage.dart';
import 'RegistrationPage.dart';
import 'seller/SellerDashboard.dart';
import 'controller/LoginService.dart'; // Import the LoginService
import 'main.dart';

class LoginPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginService _loginService = LoginService(); // Instantiate LoginService
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void _login(BuildContext context) async {
    String email = _emailController.text;
    String password = _passwordController.text;

    // Perform the login using the service
    var user = await _loginService.login(email, password);
    print('User: $user');
    var querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: user?.email)
        .get();
    var userData = querySnapshot.docs.first.data();
    var role=userData['role'];
    print('$role');
    // Check if any documents were returned
    // if (querySnapshot.docs.isNotEmpty) {
    //   var userData = querySnapshot.docs.first.data();
    //
    //   // Print the user data
    //   print('User ID: ${querySnapshot.docs.first.id}');
    //   print('User Email: ${userData['email']}');
    //   // print('User Name: ${userData['name']}');
    //   print('User Name: ${userData['role']}');
    // } else {
    //   print('No user found with email $email');
    // }

      if (user != null ) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
        ));
        Navigator.pushReplacement(

          context,
          MaterialPageRoute(
            builder: (context) {
              // Assuming you have a `role` variable to check the user's role
              if (role == 'Seller') {
                return SellerDashboard(); // Redirect to SellerDashboard if the role is 'buyer'
              } else {
                return HomePage(); // Otherwise, redirect to HomePage
              }
            },
          ),
        );
      }

    else {
      // Login failed
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login failed! Please check your credentials.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryColor, kPrimaryLightColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.email, color: kPrimaryColor),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.lock, color: kPrimaryColor),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _login(context),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  ),
                  child: Text('LOGIN'),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => RegistrationPage()),
                    );
                  },
                  child: Text(
                    'Don\'t have an account? Register',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
