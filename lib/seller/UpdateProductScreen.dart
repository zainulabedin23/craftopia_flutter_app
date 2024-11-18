import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'SellerDashboard.dart';

class UpdateProductScreen extends StatefulWidget {
  final String id;
  final String title;
  final double price;
  final String imagePath;
  // final DateTime createdAt;
  final String description;

  UpdateProductScreen({
    required this.id,
    required this.title,
    required this.price,
    required this.imagePath,
    // required this.createdAt,
    required this.description,
  });

  @override
  _UpdateProductScreenState createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  // DateTime? _createdAt;
  File? _newImage;
  late String _imagePath;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _priceController = TextEditingController(text: widget.price.toString());
    _descriptionController = TextEditingController(text: widget.description);
    // _createdAt = widget.createdAt;
    _imagePath = widget.imagePath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('products/${widget.id}.jpg');
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (error) {
      throw Exception('Failed to upload image: $error');
    }
  }

  Future<void> _updateProduct() async {
    String updatedImagePath = _imagePath;

    // Upload new image if selected
    if (_newImage != null) {
      updatedImagePath = await _uploadImage(_newImage!);
    }

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.id)
          .update({
        'title': _titleController.text,
        'price': double.parse(_priceController.text),
        'imagePath': updatedImagePath,
        // 'createdAt': _createdAt,
        'description': _descriptionController.text,
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SellerDashboard()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product updated successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product: $error')),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Product'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: _newImage != null
                    ? Image.file(
                  _newImage!,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                )
                    : Image.network(
                  _imagePath,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Choose New Image'),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _updateProduct,
                  child: Text('Update Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}