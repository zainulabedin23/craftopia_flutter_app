import 'package:craftopia/api_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ChatScreenBuyer extends StatefulWidget {
  final String productId;
  final String buyerId;

  ChatScreenBuyer({required this.productId, required this.buyerId});

  @override
  _ChatScreenBuyerState createState() => _ChatScreenBuyerState();
}

class _ChatScreenBuyerState extends State<ChatScreenBuyer> {
  late String sellerId;
  late String chatId;
  final ApiService apiService = ApiService();
  TextEditingController _messageController = TextEditingController();
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  late DatabaseReference _chatRef;
  ScrollController _scrollController = ScrollController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    sellerId = (await apiService.fetchUserIdByEmail())!;
    chatId = generateChatId(widget.buyerId, sellerId, widget.productId);
    _chatRef = _database.ref('chats/$chatId/messages');

    _chatRef.onChildAdded.listen((event) {
      setState(() {
        isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  String generateChatId(String buyerId, String sellerId, String productId) {
    List<String> ids = [buyerId, sellerId, productId];
    ids.sort();
    return ids.join("_");
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _chatRef.push().set({
        'senderId': sellerId,
        'text': _messageController.text,
        'timestamp': ServerValue.timestamp,
      });
      _messageController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

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
      appBar: AppBar(
        title: Text('Chat with Buyer ${widget.buyerId}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _chatRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  Map<dynamic, dynamic> messages = Map.from(snapshot.data!.snapshot.value as Map);
                  List<MapEntry<dynamic, dynamic>> sortedMessages = messages.entries.toList()
                    ..sort((a, b) => (b.value['timestamp'] ?? 0).compareTo(a.value['timestamp'] ?? 0));

                  List<Widget> messageWidgets = [];
                  for (var entry in sortedMessages) {
                    var value = entry.value;
                    bool isSeller = value['senderId'] == sellerId;
                    messageWidgets.add(
                      Align(
                        alignment: isSeller ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                          decoration: BoxDecoration(
                            color: isSeller ? Colors.orange[200] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            crossAxisAlignment: isSeller ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                value['text'] ?? 'No message',
                                style: TextStyle(color: isSeller ? Colors.white : Colors.black),
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                DateTime.fromMillisecondsSinceEpoch(value['timestamp'] ?? 0).toString(),
                                style: TextStyle(fontSize: 10.0, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView(
                    controller: _scrollController,
                    reverse: true,
                    children: messageWidgets,
                  );
                } else {
                  return Center(child: Text("No messages yet"));
                }
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
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
