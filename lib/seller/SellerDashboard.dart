import 'package:craftopia/controller/LogoutService.dart';
import 'package:flutter/material.dart';
import 'InboxScreen.dart';
import 'ManageOrdersScreen.dart';
import 'ManageCategoriesScreen.dart';
import 'SellerProfilePage.dart';
import 'ManageComplaintsPage.dart';
class SellerDashboard extends StatelessWidget {
  final LogoutService _logoutService=LogoutService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(Icons.chat, color: Colors.white),
            onPressed: () {
              // Navigate to the chat notification screen
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatNotificationScreen()));
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildDashboardOption(
            icon: Icons.shopping_cart,
            title: 'Manage Orders',
            onTap: () {
              // Handle logout logic here
              // Handle logout logic here
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageOrdersScreen()), // Replace with your LoginScreen
              );
            },
          ),
          _buildDashboardOption(
            icon: Icons.category,
            title: 'Manage Product',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageCategoriesScreen()), // Replace with your LoginScreen
              );
            },
          ),
          _buildDashboardOption(
            icon: Icons.report_problem,
            title: 'Manage Complaints',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageComplaintsPage()), // Replace with your LoginScreen
              );
            },
          ),
          _buildDashboardOption(
            icon: Icons.notifications,
            title: 'Notifications & Chat Requests',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InboxScreen()), // Replace with your LoginScreen
              );
            },
          ),
          _buildDashboardOption(
            icon: Icons.person,
            title: 'Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SellerProfilePage()), // Replace with your LoginScreen
              );
            },
          ),  _buildDashboardOption(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () => _logoutService.logout(context)
          )
        ],
      ),
    );
  }

  Widget _buildDashboardOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.purple),
        title: Text(title, style: TextStyle(fontSize: 16.0)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class ChatNotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Text(
          'Here, you will see notifications and chat requests from buyers.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
