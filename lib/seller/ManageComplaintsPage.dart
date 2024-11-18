import 'package:flutter/material.dart';
import 'ComplaintDetailPage.dart'; // Import the new page

class ManageComplaintsPage extends StatefulWidget {
  @override
  _ManageComplaintsPageState createState() => _ManageComplaintsPageState();
}

class _ManageComplaintsPageState extends State<ManageComplaintsPage> {
  final List<Map<String, String>> _complaints = [
    {'id': '1', 'title': 'Order Delay', 'description': 'My order has been delayed for a week.'},
    {'id': '2', 'title': 'Damaged Product', 'description': 'The product arrived damaged.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Complaints', style: TextStyle(color: Colors.white)),
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
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _complaints.length,
                itemBuilder: (context, index) {
                  final complaint = _complaints[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4.0,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.0),
                      title: Text(complaint['title'] ?? 'No Title'),
                      subtitle: Text(complaint['description'] ?? 'No Description'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComplaintDetailPage(complaint: complaint),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _removeComplaint(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addComplaint,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              child: Text('Add Complaint', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _addComplaint() async {
    final newComplaint = {
      'id': (_complaints.length + 1).toString(),
      'title': 'New Complaint',
      'description': 'This is a new complaint.',
    };

    setState(() {
      _complaints.add(newComplaint);
    });
  }

  void _removeComplaint(int index) {
    setState(() {
      _complaints.removeAt(index);
    });
  }
}
