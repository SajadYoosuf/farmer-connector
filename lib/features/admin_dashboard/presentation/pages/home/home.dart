import 'package:customer_app/features/admin_dashboard/presentation/pages/home/home_admin_more.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  void _updateFarmerStatus(String uid, String status) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'status': status,
        'approvedAt': status == 'approved' ? FieldValue.serverTimestamp() : null,
      });

      // Log activity
      final admin = context.read<AuthProvider>().currentUser;
      await FirebaseFirestore.instance.collection('activities').add({
        'userName': admin?.fullName ?? 'Admin',
        'description': 'Account for ${status == 'approved' ? 'approved' : 'declined'}',
        'type': 'status_update',
        'createdAt': FieldValue.serverTimestamp(),
        'userId': uid,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Farmer account $status successfully.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---------------- HEADER ----------------
              _buildHeader(),

              const SizedBox(height: 10),

              /// ---------------- PENDING APPROVALS ----------------
              _buildPendingSection(),

              const SizedBox(height: 20),

              /// ---------------- STATS CARDS ----------------
              _buildStatsStream(),

              const SizedBox(height: 20),

              /// ---------------- TOP FARMERS ----------------
              _buildTopFarmersHeader(),
              const SizedBox(height: 12),
              _buildFarmersStream(),

              const SizedBox(height: 25),

              /// ---------------- RECENT ACTIVITY ----------------
              _buildActivityHeader(),
              const SizedBox(height: 12),
              _buildActivityStream(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = context.watch<AuthProvider>().currentUser;
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Color.fromRGBO(15, 87, 0, 1),
          backgroundImage: AssetImage("assets/admin_images/admin_avatar.png"),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.fullName ?? user?.email.split('@').first ?? "Admin",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const Text("Administrator Dashboard", style: TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
        const Spacer(),
        const CircleAvatar(
          backgroundColor: Color.fromRGBO(15, 87, 0, 1),
          child: Icon(Icons.notifications, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildPendingSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'farmer')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();
        
        final docs = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "Pending Registration Approvals",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final name = data['fullName'] ?? 'New Farmer';
                  final place = data['place'] ?? 'Unknown Location';
                  final uid = docs[index].id;

                  return Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 16, bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.person, color: Colors.white)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1),
                                Text(place, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            )),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(child: OutlinedButton(
                              onPressed: () => _updateFarmerStatus(uid, 'declined'),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                              child: const Text("Decline"),
                            )),
                            const SizedBox(width: 8),
                            Expanded(child: ElevatedButton(
                              onPressed: () => _updateFarmerStatus(uid, 'approved'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text("Approve", style: TextStyle(color: Colors.white)),
                            )),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, orderSnapshot) {
        int totalOrders = orderSnapshot.data?.docs.length ?? 0;
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, prodSnapshot) {
            int totalSold = 0;
            if (prodSnapshot.hasData) {
              for (var doc in prodSnapshot.data!.docs) {
                totalSold += ((doc.data() as Map<String, dynamic>)['totalSold'] ?? 0) as int;
              }
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                height: 180,
                child: Row(
                  children: [
                    cardItem(
                      icon: Icons.inventory_2,
                      label: "Products sold",
                      value: totalSold >= 1000 ? '${(totalSold/1000).toStringAsFixed(1)}K' : totalSold.toString(),
                      percentage: "+12%", chartData: [3.0, 5.0, 4.0, 7.0, 6.0, 8.0, 9.0], bgColor: Colors.green.shade800,
                    ),
                    cardItem(
                      icon: Icons.shopping_bag,
                      label: "Total Orders",
                      value: totalOrders.toString(),
                      percentage: "+5%", chartData: [2.0, 4.0, 3.0, 5.0, 7.0, 6.0, 8.0], bgColor: const Color.fromRGBO(30, 70, 20, 1),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTopFarmersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text("Top performing farmer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text("View All", style: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFarmersStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'farmer').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text("No farmers registered.");
        final docs = snapshot.data!.docs;
        return Column(
          children: docs.take(3).map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _farmerTile(1, data['fullName'] ?? 'Farmer', "assets/admin_images/admin_avatar.png");
          }).toList(),
        );
      },
    );
  }

  Widget _buildActivityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text("Recent user activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text("History", style: TextStyle(fontSize: 16, color: Colors.green)),
      ],
    );
  }

  Widget _buildActivityStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('activities').orderBy('createdAt', descending: true).limit(5).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text("No recent activity.");
        return Column(
          children: snapshot.data!.docs.map((doc) {
             final d = doc.data() as Map<String, dynamic>;
             return activityCard(d['userName'] ?? 'User', d['description'] ?? '', d['type'] ?? 'info');
          }).toList(),
        );
      },
    );
  }

  Widget activityCard(String name, String desc, String type) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.green.withOpacity(0.1), child: const Icon(Icons.info_outline, color: Colors.green, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(desc, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          )),
        ],
      ),
    );
  }

  Widget _farmerTile(int rank, String name, String img) {
    return Container(
      padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(radius: 18, backgroundImage: AssetImage(img)),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500))),
          const Text("₹ 9,623", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
