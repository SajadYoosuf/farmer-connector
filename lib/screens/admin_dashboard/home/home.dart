import 'dart:io';
import 'package:customer_app/screens/admin_dashboard/home/home_admin_more.dart';
import 'package:customer_app/screens/admin_farmers/farmer/farmer_detail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/providers/auth_provider.dart';

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
        'approvedAt': status == 'approved'
            ? FieldValue.serverTimestamp()
            : null,
      });

      // Log activity
      final admin = context.read<AuthProvider>().currentUser;
      await FirebaseFirestore.instance.collection('activities').add({
        'userName': admin?.fullName ?? 'Admin',
        'description':
            'Account for ${status == 'approved' ? 'approved' : 'declined'}',
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
            const Text(
              "Administrator Dashboard",
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
        // const Spacer(),
        // const CircleAvatar(
        //   backgroundColor: Color.fromRGBO(43, 255, 0, 1),
        //   child: Icon(Icons.notifications, color: Colors.white),
        // ),
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
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const SizedBox.shrink();

        final docs = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "Pending Registration Approvals",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            SizedBox(
              height: 380,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final name = data['fullName'] ?? 'New Farmer';
                  final place = data['place'] ?? 'Unknown Location';
                  final landLocation = data['landLocation'] ?? 'No land data';
                  final aadharPath = data['aadharPath'] as String?;
                  final farmerIDPath = data['farmerIDPath'] as String?;
                  final uid = docs[index].id;

                  return InkWell(
                    onTap: () {
                      final farmerData = Map<String, dynamic>.from(data);
                      farmerData['uid'] = uid;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FarmerDetailPage(
                            farmerData: farmerData,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 320,
                    margin: const EdgeInsets.only(right: 16, bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color.fromRGBO(15, 87, 0, 1),
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    maxLines: 1,
                                  ),
                                  Text(
                                    place,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.verified_user,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ],
                        ),
                        const Divider(height: 25),
                        const Text(
                          "Documents Provided:",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildDocThumb("Aadhar", aadharPath),
                            const SizedBox(width: 10),
                            _buildDocThumb("Farmer ID", farmerIDPath),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Land Location:",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                landLocation,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    _updateFarmerStatus(uid, 'declined'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text("Decline"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    _updateFarmerStatus(uid, 'approved'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(
                                    15,
                                    87,
                                    0,
                                    1,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Approve",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                totalSold +=
                    ((doc.data() as Map<String, dynamic>)['totalSold'] ?? 0)
                        as int;
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
                      value: totalSold >= 1000
                          ? '${(totalSold / 1000).toStringAsFixed(1)}K'
                          : totalSold.toString(),
                      percentage: "+12%",
                      chartData: [3.0, 5.0, 4.0, 7.0, 6.0, 8.0, 9.0],
                      bgColor: Colors.green.shade800,
                    ),
                    cardItem(
                      icon: Icons.shopping_bag,
                      label: "Total Orders",
                      value: totalOrders.toString(),
                      percentage: "+5%",
                      chartData: [2.0, 4.0, 3.0, 5.0, 7.0, 6.0, 8.0],
                      bgColor: const Color.fromRGBO(30, 70, 20, 1),
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
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          "Top performing farmers",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFarmersStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'farmer')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const Text("No farmers registered.");
        final docs = snapshot.data!.docs;
        return Column(
          children: docs.take(3).map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return InkWell(
              onTap: () {
                final farmerData = Map<String, dynamic>.from(data);
                farmerData['uid'] = doc.id;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FarmerDetailPage(
                      farmerData: farmerData,
                    ),
                  ),
                );
              },
              child: _farmerTile(
                doc.id,
                1,
                data['fullName'] ?? 'Farmer',
                "assets/admin_images/admin_avatar.png",
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildActivityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          "Recent user activity",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text("History", style: TextStyle(fontSize: 16, color: Colors.green)),
      ],
    );
  }

  Widget _buildActivityStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('activities')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const Text("No recent activity.");
        return Column(
          children: snapshot.data!.docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return activityCard(
              d['userName'] ?? 'User',
              d['description'] ?? '',
              d['type'] ?? 'info',
            );
          }).toList(),
        );
      },
    );
  }

  Widget activityCard(String name, String desc, String type) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.withOpacity(0.1),
            child: const Icon(
              Icons.info_outline,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocThumb(String label, String? path) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: (path != null && File(path).existsSync())
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(path), fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                        size: 24,
                      ),
                      Text(
                        "No Image",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _farmerTile(String uid, int rank, String name, String img) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 18, backgroundImage: AssetImage(img)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('farmerId', isEqualTo: uid)
                .where('status', isEqualTo: 'confirmed')
                .snapshots(),
            builder: (context, snapshot) {
              double total = 0;
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  total +=
                      (doc.data() as Map<String, dynamic>)['totalAmount'] ?? 0;
                }
              }
              return Text(
                "₹ ${total.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
