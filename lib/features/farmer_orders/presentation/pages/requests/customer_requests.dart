import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';

class CustomerRequests extends StatefulWidget {
  const CustomerRequests({super.key});

  @override
  State<CustomerRequests> createState() => _CustomerRequestsState();
}

class _CustomerRequestsState extends State<CustomerRequests> {
  int _selectedTab = 0; // 0 for New Request, 1 for History

  void _updateStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Log Activity
      final user = context.read<AuthProvider>().currentUser;
      await FirebaseFirestore.instance.collection('activities').add({
         'title': 'Order $newStatus',
         'description': 'Farmer ${user?.fullName} $newStatus a customer request.',
         'type': 'order_update',
         'timestamp': FieldValue.serverTimestamp(),
         'userId': user?.uid,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Customer Requests",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // TABS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                _tabItem("New Request", _selectedTab == 0, () => setState(() => _selectedTab = 0)),
                _tabItem("History", _selectedTab == 1, () => setState(() => _selectedTab = 1)),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders')
                  .where('farmerId', isEqualTo: user.uid)
                  .where('status', isEqualTo: _selectedTab == 0 ? 'pending' : 'delivered')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final docs = snapshot.data?.docs ?? [];
                
                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Text(_selectedTab == 0 ? "No pending requests." : "No history found."),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final id = docs[index].id;
                    final customerName = data['userName'] ?? 'Customer';
                    final price = data['totalAmount'] ?? 0;
                    final items = data['items'] as List? ?? [];
                    final cropName = items.isNotEmpty ? (items[0]['name'] ?? 'Crop') : 'Crop';
                    final quantity = items.isNotEmpty ? "${items[0]['quantity']} ${items[0]['unit'] ?? 'kg'}" : "1 kg";

                    return _requestCard(id, customerName, "Just now", "₹$price", cropName, quantity, _selectedTab == 0);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabItem(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color.fromRGBO(156, 229, 101, 1) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Text(title, style: TextStyle(color: isSelected ? Colors.black : Colors.grey, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _requestCard(String id, String marketName, String timeAgo, String price, String crop, String quantity, bool isPending) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green.shade50,
                child: const Icon(Icons.person, color: Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(marketName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Requested $timeAgo", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Proposed price", style: TextStyle(color: Colors.black54, fontSize: 12)),
                  Text(price, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xfff9f9f9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.shade200),
                  child: const Icon(Icons.park, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Requested crop", style: TextStyle(color: Colors.black54, fontSize: 12)),
                      Text(crop, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Quantity", style: TextStyle(color: Colors.black54, fontSize: 10)),
                    Text(quantity, style: const TextStyle(color: Color.fromRGBO(15, 87, 0, 1), fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(id, 'cancelled'),
                    style: OutlinedButton.styleFrom(backgroundColor: const Color(0xfff0f0f0), side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text("Decline", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(id, 'confirmed'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(156, 229, 101, 1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text("Accept Request", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
