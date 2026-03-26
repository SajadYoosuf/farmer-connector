import 'package:customer_app/core/widgets/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminSupportChatPage extends StatefulWidget {
  const AdminSupportChatPage({super.key});

  @override
  State<AdminSupportChatPage> createState() => _AdminSupportChatPageState();
}

class _AdminSupportChatPageState extends State<AdminSupportChatPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      body: Column(
        children: [
          const SafeArea(child: CommonAppBar(title: 'Support Center', showBack: true)),
          
          // ─── TAB BAR CONTAINER ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            color: Colors.white,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xfff3f4f6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color.fromRGBO(15, 87, 0, 1),
                  borderRadius: BorderRadius.circular(14),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                tabs: const [
                  Tab(text: "Customers"),
                  Tab(text: "Farmers"),
                ],
              ),
            ),
          ),

          // ─── TAB BAR VIEW ───
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChatList("customer"),
                _buildChatList("farmer"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(String userType) {
    return StreamBuilder<QuerySnapshot>(
      // Listen to a hypothetical 'support_chats' collection where userType indicates 'farmer' or 'customer'
      stream: FirebaseFirestore.instance
          .collection('support_chats')
          .where('userType', isEqualTo: userType)
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color.fromRGBO(15, 87, 0, 1)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(userType);
        }

        final chats = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final data = chats[index].data() as Map<String, dynamic>;
            final chatId = chats[index].id;
            
            return _chatTile(
              context: context,
              chatId: chatId,
              name: data['userName'] ?? "Unknown User",
              lastMessage: data['lastMessage'] ?? "New support request",
              time: data['lastMessageTime'],
              unreadCount: data['unreadCount'] ?? 0,
              userRole: userType,
            );
          },
        );
      },
    );
  }

  Widget _chatTile({
    required BuildContext context,
    required String chatId,
    required String name,
    required String lastMessage,
    required dynamic time,
    required int unreadCount,
    required String userRole,
  }) {
    String timeStr = "Just now";
    if (time != null && time is Timestamp) {
      timeStr = DateFormat('hh:mm a').format(time.toDate());
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: unreadCount > 0 ? Border.all(color: const Color.fromRGBO(15, 87, 0, 0.2), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to message detail
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ─── AVATAR ───
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color.fromRGBO(156, 229, 101, 0.2),
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(15, 87, 0, 1), fontSize: 18),
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              
              // ─── CONTENT ───
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black),
                        ),
                        if (time != null)
                          Text(
                            timeStr,
                            style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.4)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14, 
                              color: unreadCount > 0 ? Colors.black87 : Colors.black54,
                              fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(15, 87, 0, 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String userType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              userType == "customer" ? Icons.people_outline : Icons.agriculture_outlined,
              size: 50,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No Active $userType Support Requests",
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            "New messages will appear here.",
            style: TextStyle(fontSize: 14, color: Colors.black38),
          ),
        ],
      ),
    );
  }
}
