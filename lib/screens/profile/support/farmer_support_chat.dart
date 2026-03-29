import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class FarmerSupportChat extends StatefulWidget {
  const FarmerSupportChat({super.key});

  @override
  State<FarmerSupportChat> createState() => _FarmerSupportChatState();
}

class _FarmerSupportChatState extends State<FarmerSupportChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    _messageController.clear();

    final chatRef = FirebaseFirestore.instance.collection('support_chats').doc(user.uid);

    // Ensure the chat room exists with metadata
    await chatRef.set({
      'userId': user.uid,
      'userName': user.fullName ?? user.email,
      'userType': 'farmer',
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': FieldValue.increment(1),
    }, SetOptions(merge: true));

    // Add message to subcollection
    await chatRef.collection('messages').add({
      'senderId': user.uid,
      'senderName': user.fullName ?? user.email,
      'content': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        elevation: 1,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Admin Support", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            Text("We're here to help", style: TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('support_chats')
                  .doc(user.uid)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text("No messages yet. Send one to start!", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!.docs;
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == user.uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? const Color.fromRGBO(15, 87, 0, 1) : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                          ),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['content'] ?? '',
                              style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['timestamp'] != null 
                                ? DateFormat('hh:mm a').format((data['timestamp'] as Timestamp).toDate())
                                : "Just now",
                              style: TextStyle(color: isMe ? Colors.white70 : Colors.black38, fontSize: 10),
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
          
          // INPUT FIELD
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xfff5f5f5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(15, 87, 0, 1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
