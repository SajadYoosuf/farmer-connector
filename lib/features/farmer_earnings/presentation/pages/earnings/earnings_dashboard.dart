import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';

class EarningsDashboard extends StatefulWidget {
  const EarningsDashboard({super.key});

  @override
  State<EarningsDashboard> createState() => _EarningsDashboardState();
}

class _EarningsDashboardState extends State<EarningsDashboard> {
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
          "Earnings Dashboard",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders')
            .where('farmerId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'confirmed')
            .snapshots(),
        builder: (context, snapshot) {
          double totalEarnings = 0;
          Map<String, double> cropEarnings = {};
          
          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              final d = doc.data() as Map<String, dynamic>;
              final amount = (d['totalAmount'] ?? 0).toDouble();
              totalEarnings += amount;
              
              final items = d['items'] as List? ?? [];
              for (var item in items) {
                final name = item['name'] ?? 'Other';
                final itemTotal = (item['price'] ?? 0) * (item['quantity'] ?? 1);
                cropEarnings[name] = (cropEarnings[name] ?? 0) + itemTotal.toDouble();
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // TOTAL EARNINGS CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(156, 229, 101, 1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Earnings", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text("₹ ${totalEarnings.toStringAsFixed(2)}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 32)),
                      const SizedBox(height: 8),
                      const Text("Live data from confirmed orders", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 12)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // INCOME TRENDS (Static Placeholder for now as we'd need time-series data)
                _buildTrendsCard(),
                
                const SizedBox(height: 24),
                
                // EARNINGS BY CROP
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Earnings by Crop", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () {}, child: const Text("View All", style: TextStyle(color: Colors.green))),
                  ],
                ),
                
                if (cropEarnings.isEmpty)
                   const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No product sales yet.")))
                else
                   ...cropEarnings.entries.map((e) => _cropEarningsItem(e.key, "₹ ${e.value.toStringAsFixed(0)}", (e.value / totalEarnings).clamp(0.1, 1.0))).toList(),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Income Trends", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Icon(Icons.query_stats, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 120, width: double.infinity, child: CustomPaint(painter: _SimpleChartPainter())),
          const SizedBox(height: 10),
          const Text("Visual trend calculation pending more data points", style: TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _cropEarningsItem(String title, String amount, double progress) {
    return Container(
      padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.green.shade50), child: const Icon(Icons.eco, color: Colors.green)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade100, color: Colors.lightGreen, minHeight: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.lightGreen..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.1, size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width, size.height * 0.2);
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
