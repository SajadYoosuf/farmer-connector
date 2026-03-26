import 'package:customer_app/features/chat/presentation/pages/message/chat/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/chat/presentation/providers/chat_provider.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Widget MessageHeader(context) {
  return Container(
    height: 160,
    color: Color.fromRGBO(154, 238, 86, 1),
    child: SafeArea(
      bottom: false,
      child: Column(
        children: [
          ///appbar section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 35),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(232, 236, 244, 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    onPressed: () {
                    },
                    icon: Icon(
                      Icons.chevron_left,
                      fontWeight: FontWeight.w600,
                      size: 30,
                      color: Color.fromRGBO(30, 35, 44, 1),
                    ),
                  ),
                ),
                Text(
                  'messages',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Color.fromRGBO(15, 87, 0, 1),
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: Color.fromRGBO(255, 255, 255, 1),
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
              final users = room['users'] as List;
              final otherUserId = users.firstWhere((id) => id != userId, orElse: () => '');
              final otherUserName = room['usernames']?[otherUserId] ?? 'Farmer';

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
  const MessageTile({super.key, required this.name, required this.image, required this.lastMessage});

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
