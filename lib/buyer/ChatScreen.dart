import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatScreen extends StatefulWidget {
  final String buyerId;
  final String sellerId;
  final String productId;

  ChatScreen({required this.buyerId, required this.sellerId, required this.productId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final TextEditingController _messageController = TextEditingController();
  late DatabaseReference _messagesRef;
  ScrollController _scrollController = ScrollController(); // Scroll controller for smooth scrolling

  @override
  void initState() {
    super.initState();
    String chatId = generateChatId(widget.buyerId, widget.sellerId, widget.productId);
    _messagesRef = _database.ref().child('chats').child(chatId).child('messages');
  }

  String generateChatId(String buyerId, String sellerId, String productId) {
    List<String> ids = [buyerId, sellerId, productId];
    ids.sort();
    return ids.join("_");
  }

  void sendMessage() {
    if (_messageController.text.isEmpty) return;
    final message = {
      'senderId': widget.buyerId, // The buyer is the sender
      'text': _messageController.text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    _messagesRef.push().set(message);
    _messageController.clear();
    _scrollToBottom(); // Scroll to the bottom after sending the message
  }

  // Function to scroll to the bottom
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _messagesRef.orderByChild('timestamp').onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                  return Center(child: Text("No messages yet."));
                }

                Map<dynamic, dynamic> messagesMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                List<Map> messagesList = messagesMap.entries.map((entry) => {
                  'key': entry.key,
                  ...entry.value,
                }).toList();

                // Sort messages based on timestamp
                messagesList.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

                return ListView.builder(
                  controller: _scrollController, // Set the scroll controller here
                  reverse: false, // Reverse set to false to show new messages at the bottom
                  itemCount: messagesList.length,
                  itemBuilder: (context, index) {
                    var message = messagesList[index];
                    String messageText = message['text'] ?? 'No message'; // Handle null message text

                    // Check if the sender is the buyer or seller
                    bool isBuyer = message['senderId'] == widget.buyerId;

                    return Align(
                      alignment: isBuyer ? Alignment.centerRight : Alignment.centerLeft, // Right for buyer, left for seller
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                        decoration: BoxDecoration(
                          color: isBuyer ? Colors.orange[200] : Colors.blue[200], // Different colors for buyer and seller
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: isBuyer ? CrossAxisAlignment.end : CrossAxisAlignment.start, // Align text accordingly
                          children: [
                            Text(
                              messageText,
                              style: TextStyle(color: Colors.white), // Text color for messages
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              DateTime.fromMillisecondsSinceEpoch(message['timestamp']).toString(),
                              style: TextStyle(fontSize: 10.0, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: "Type a message..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
