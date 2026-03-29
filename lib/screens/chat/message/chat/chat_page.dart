import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/providers/chat_provider.dart';
import 'package:customer_app/providers/auth_provider.dart';
import 'package:customer_app/models/message_model.dart';

class ChatPage extends StatefulWidget {
  final String farmerId;
  final String farmerName;
  const ChatPage({super.key, required this.farmerId, required this.farmerName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.uid ?? 'guest';

    chatProvider.sendMessage(
      MessageModel(
        senderId: userId,
        senderName: authProvider.currentUser?.email ?? 'User',
        receiverId: widget.farmerId,
        receiverName: widget.farmerName,
        message: _messageController.text.trim(),
      ),
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        elevation: 1,
        leading: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(232, 236, 244, 1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },

            icon: Icon(
              Icons.chevron_left,
              fontWeight: FontWeight.w600,
              size: 30,
              color: Color.fromRGBO(30, 35, 44, 1),
            ),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/person.png'),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.farmerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(0, 0, 0, 1),
                  ),
                ),
                const Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: Color.fromRGBO(88, 255, 38, 1),
                      size: 10,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: const [],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer2<ChatProvider, AuthProvider>(
              builder: (context, chatProvider, authProvider, child) {
                final userId = authProvider.currentUser?.uid ?? 'guest';
                return StreamBuilder<List<MessageModel>>(
                  stream: chatProvider.getChatStream(userId, widget.farmerId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("Start a conversation"));
                    }

                    final messages = snapshot.data!;
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(15),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == userId;

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Reduced vertical padding from 12 to 10
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                            decoration: BoxDecoration(
                              color: isMe ? const Color.fromRGBO(155, 235, 91, 1) : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(15),
                                topRight: const Radius.circular(15),
                                bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
                                bottomRight: isMe ? Radius.zero : const Radius.circular(15),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Text(
                              message.message,
                              style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          // INPUT FIELD
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                const SizedBox(width: 15),
                // TEXT FIELD
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Type your message",
                      hintStyle: const TextStyle(
                        color: Color.fromRGBO(85, 85, 85, 1),
                      ),
                      filled: true,
                      fillColor: const Color.fromRGBO(241, 245, 249, 1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // SEND BUTTON
                InkWell(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(155, 235, 91, 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
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
