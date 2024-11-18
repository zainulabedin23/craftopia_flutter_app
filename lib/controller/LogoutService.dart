import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../LoginPage.dart';

class LogoutService{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> logout(BuildContext context) async {
    try {
      await _auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Logged out successfully!'),
        backgroundColor: Colors.green,
      ));

      // Navigate to login or splash screen after logout
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      ); // Adjust the route as needed
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to log out. Please try again.'),
        backgroundColor: Colors.red,
      ));
    }
  }
}