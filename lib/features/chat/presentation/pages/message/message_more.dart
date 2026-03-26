import 'package:customer_app/features/chat/presentation/pages/message/chat/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/chat/presentation/providers/chat_provider.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Widget MessageHeader(context) {
  return Container(
    height: 160,
    color: Colors.lightGreen,
    child: SafeArea(
      bottom: false,
      child: Column(
        children: [
          ///appbar section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 35),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Messages',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget MessageList() {
  return Consumer2<ChatProvider, AuthProvider>(
    builder: (context, chatProvider, authProvider, child) {
      final userId = authProvider.currentUser?.uid ?? 'guest';
      return StreamBuilder<QuerySnapshot>(
        stream: chatProvider.getUserChatRooms(userId) as Stream<QuerySnapshot>,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No messages yet"),
              ),
            );
          }

          final rooms = snapshot.data!.docs;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index].data() as Map<String, dynamic>;
              final participants = room['participants'] as List? ?? [];
              final otherUserId = participants.firstWhere(
                (id) => id != userId,
                orElse: () => '',
              );
              final usernames =
                  room['usernames'] as Map<String, dynamic>? ?? {};
              final otherUserName = usernames[otherUserId] ?? 'User';

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        farmerId: otherUserId,
                        farmerName: otherUserName,
                      ),
                    ),
                  );
                },
                child: MessageTile(
                  name: otherUserName,
                  image: 'assets/images/person.png',
                  lastMessage: room['lastMessage'] ?? 'Click to chat',
                ),
              );
            },
          );
        },
      );
    },
  );
}

//Message tile
class MessageTile extends StatefulWidget {
  final String name;
  final String image;
  final String lastMessage;
  const MessageTile({
    super.key,
    required this.name,
    required this.image,
    required this.lastMessage,
  });

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[300],
            backgroundImage: widget.image.isNotEmpty
                ? AssetImage(widget.image)
                : null,
            child: widget.image.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),

          title: Text(
            widget.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            children: [
              const Icon(Icons.done_all, size: 18, color: Colors.blue),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  widget.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const Divider(indent: 80, endIndent: 20),
      ],
    );
  }
}
