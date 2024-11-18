import 'package:flutter/material.dart';

class ComplaintDetailPage extends StatefulWidget {
  final Map<String, String> complaint;

  ComplaintDetailPage({required this.complaint});

  @override
  _ComplaintDetailPageState createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends State<ComplaintDetailPage> {
  final TextEditingController _replyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint Details', style: TextStyle(color: Colors.white)),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.complaint['title'] ?? 'No Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.complaint['description'] ?? 'No Description',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _replyController,
              decoration: InputDecoration(
                labelText: 'Your Reply',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitReply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              child: Text('Submit Reply', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _submitReply() {
    final reply = _replyController.text.trim();
    if (reply.isNotEmpty) {
      // Handle reply submission
      // You can send this reply to your backend or handle it accordingly
      print('Reply submitted: $reply');

      // Show a confirmation snack bar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Reply submitted!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));

      // Optionally, navigate back to the previous page
      Navigator.pop(context);
    } else {
      // Show an error snack bar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a reply.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}
