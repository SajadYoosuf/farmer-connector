import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:customer_app/features/farmer_home/presentation/pages/add_product/add_product.dart';

class FarmerHome extends StatefulWidget {
  const FarmerHome({super.key});

  @override
  State<FarmerHome> createState() => _FarmerHomeState();
}

class _FarmerHomeState extends State<FarmerHome> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final name = user?.fullName ?? user?.email ?? 'Farmer';

    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      body: Column(
        children: [
          // ─── CUSTOM HEADER ───
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(15, 87, 0, 1),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Good Day,", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // QUICK STATS
                Row(
                  children: [
                    _buildListingCount(user?.uid),
                    const SizedBox(width: 12),
                    _buildEarningsSummary(user?.uid),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text("Recently Added", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       TextButton(onPressed: () {}, child: const Text("View All", style: TextStyle(color: Color.fromRGBO(15, 87, 0, 1)))),
                     ],
                   ),
                   
                   // LISTING SUMMARY (Live from Firestore)
                   StreamBuilder<QuerySnapshot>(
                     stream: user != null 
                        ? FirebaseFirestore.instance.collection('products')
                            .where('farmerId', isEqualTo: user.uid)
                            .orderBy('createdAt', descending: true)
                            .limit(5)
                            .snapshots()
                        : null,
                     builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                           return const Padding(
                             padding: EdgeInsets.symmetric(vertical: 40),
                             child: Center(child: Text("No products added yet.", style: TextStyle(color: Colors.grey))),
                           );
                        }

                        return Column(
                           children: snapshot.data!.docs.map((doc) {
                              final p = doc.data() as Map<String, dynamic>;
                              return _productCard(p['name'] ?? '', p['category'] ?? '', p['price']?.toString() ?? '0', p['unit'] ?? '');
                           }).toList(),
                        );
                     },
                   ),
                   
                   const SizedBox(height: 20),
                   
                   // ADD NEW PRODUCT CTA
                   InkWell(
                     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmerAddProduct())),
                     child: Container(
                       padding: const EdgeInsets.all(20),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(20),
                         border: Border.all(color: Colors.lightGreen, width: 2),
                       ),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: const [
                           Icon(Icons.add_circle_outline, color: Color.fromRGBO(15, 87, 0, 1)),
                           SizedBox(width: 10),
                           Text("Add New Product Listing", style: TextStyle(color: Color.fromRGBO(15, 87, 0, 1), fontWeight: FontWeight.bold, fontSize: 16)),
                         ],
                       ),
                     ),
                   ),
                   const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmerAddProduct())),
        backgroundColor: const Color.fromRGBO(15, 87, 0, 1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildListingCount(String? uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: uid != null ? FirebaseFirestore.instance.collection('products').where('farmerId', isEqualTo: uid).snapshots() : null,
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return _quickStat("Active Listings", "$count", Icons.category_outlined);
      },
    );
  }

  Widget _buildEarningsSummary(String? uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: uid != null ? FirebaseFirestore.instance.collection('orders')
          .where('farmerId', isEqualTo: uid)
          .where('status', isEqualTo: 'confirmed')
          .snapshots() : null,
      builder: (context, snapshot) {
        double total = 0;
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            total += (doc.data() as Map<String, dynamic>)['totalAmount'] ?? 0;
          }
        }
        final totalStr = total >= 1000 ? "₹ ${(total/1000).toStringAsFixed(1)}K" : "₹ $total";
        return _quickStat("Total Earnings", totalStr, Icons.payments_outlined);
      },
    );
  }

  Widget _quickStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _productCard(String name, String cat, String price, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 45, height: 45,
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.eco, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(cat, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text("₹$price$unit", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }
}
