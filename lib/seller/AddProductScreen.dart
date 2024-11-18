import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import '../api_service.dart';
import 'package:path/path.dart';

import 'SellerDashboard.dart';
class AddProductScreen extends StatefulWidget {
  // final String category;

  // AddProductScreen({required this.category});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _selectedCategory;
  List<String> categories = [];
  String? userId;
  final ApiService apiService = ApiService();
  bool isLoading=false;

// print('categories line 21 $categories[0]');
  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchUserId();
  }
  Future<void> fetchUserId() async {
    String? fetchedUserId = await apiService.fetchUserIdByEmail();
    setState(() {
      userId = fetchedUserId;
    });

    if (userId != null) {
      print('User ID: $userId');
    }
  }
  Future<void> fetchCategories() async {
    // Firestore instance

    // Fetch all documents from the 'category' collection
    List<String> fetchedCategories = await apiService.fetchCategories();
    setState(() {
      categories = fetchedCategories;
    });
  }
  File? _pickedImage; // For storing the picked image
  final ImagePicker _picker = ImagePicker(); // To select images

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              // Dropdown for categories
              DropdownButton<String>(
                value: _selectedCategory,
                hint: Text('Select Category'),
                isExpanded: true,
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
              ),
              SizedBox(height: 20.0),
              // Image picker button and display
              GestureDetector(
                onTap: _pickImage, // Pick an image when tapped
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: _pickedImage == null
                      ? Icon(Icons.add_a_photo, color: Colors.grey, size: 50)
                      : Image.file(_pickedImage!, fit: BoxFit.cover),
                ),
              ),

              SizedBox(height: 20.0),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: () => _addProduct(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                child: Text('Add Product', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, // Use ImageSource.camera for camera
      maxWidth: 600,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _addProduct(BuildContext context) async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    setState(() {
      isLoading = true;
    });

    try {
      if (_pickedImage != null && _titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty && _selectedCategory != null) {
        // 1. Upload image to Firebase Storage
        String imageUrl = await _uploadImageToFirebaseStorage(_pickedImage!);

        // 2. Get the current user ID


        if (imageUrl.isNotEmpty && userId != null) {
          // 3. Create product data to be added to Firestore
          Map<String, dynamic> productData = {
            'title': _titleController.text,
            'description': _descriptionController.text,
            'category': _selectedCategory,
            'imagePath': imageUrl, // Add image URL
            'userId': userId,
            'createdAt': Timestamp.now(),
            'price':_priceController.text
          };

          // 4. Add product data to Firestore
          await FirebaseFirestore.instance.collection('products').add(productData);

          // Show success message or navigate to a different screen
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product added successfully')));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SellerDashboard()), // Replace with your LoginScreen
          );

        }
      } else {
        // Show error message if required fields are missing
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields and select an image')));
      }
    } catch (e) {
      print('Error adding product: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add product')));
    }
  }
Future<String> _uploadImageToFirebaseStorage(File image) async {
  try {
    // Generate a unique file name based on the image path
    String fileName = basename(image.path);

    // Reference to the Firebase Storage location
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('products/$fileName');

    // Upload the image
    UploadTask uploadTask = firebaseStorageRef.putFile(image);

    // Wait for the upload to complete and get the download URL
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    return downloadUrl; // Return the image URL
  } catch (e) {
    print('Error uploading image: $e');
    return ''; // Return an empty string in case of failure
  }
}
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }
}
