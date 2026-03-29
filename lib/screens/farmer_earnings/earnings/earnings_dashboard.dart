import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/providers/auth_provider.dart';

class EarningsDashboard extends StatefulWidget {
  const EarningsDashboard({super.key});

  @override
  State<EarningsDashboard> createState() => _EarningsDashboardState();
}

class _EarningsDashboardState extends State<EarningsDashboard> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        actions: [],
        centerTitle: true,
        title: const Text(
          "Earnings Dashboard",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('farmerId', isEqualTo: user.uid)
            .where('status', whereIn: ['shipped', 'delivered', 'Shipped', 'Delivered'])
            .snapshots(),
        builder: (context, snapshot) {
          double totalEarnings = 0;
          Map<String, double> cropEarnings = {};
          Map<String, String> cropImages = {};
          List<double> weeklyData = [0, 0, 0, 0];

          if (snapshot.hasData) {
            final now = DateTime.now();
            for (var doc in snapshot.data!.docs) {
              final d = doc.data() as Map<String, dynamic>;
              final amount = (d['totalAmount'] ?? 0).toDouble();
              totalEarnings += amount;

              final createdAt = d['createdAt'];
              if (createdAt is Timestamp) {
                final date = createdAt.toDate();
                if (date.month == now.month && date.year == now.year) {
                  int week = (date.day - 1) ~/ 7;
                  if (week > 3) week = 3; // Cap at 4 weeks (index 3)
                  weeklyData[week] += amount;
                }
              }

              final items = d['items'] as List? ?? [];
              for (var item in items) {
                final name = item['name'] ?? 'Other';
                final imageUrl = item['imageUrl'] ?? '';
                final price = (item['price'] ?? 0).toDouble();
                final quantity = (item['quantity'] ?? 1).toDouble();
                final itemTotal = price * quantity;
                
                cropEarnings[name] = (cropEarnings[name] ?? 0) + itemTotal;
                if (imageUrl.isNotEmpty) cropImages[name] = imageUrl;
              }
            }
          }

          // Normalize weekly data for chart (0.0 to 1.0)
          double maxWeek = weeklyData.reduce((a, b) => a > b ? a : b);
          List<double> normalizedWeeks = weeklyData
              .map((e) => maxWeek > 0 ? (e / maxWeek) : 0.0)
              .toList();

          // Find top selling crop
          String topCrop = "";
          double maxCropEarning = 0;
          cropEarnings.forEach((key, value) {
            if (value > maxCropEarning) {
              maxCropEarning = value;
              topCrop = key;
            }
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOTAL EARNINGS CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xff9AFE56),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Earnings (March)",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            "₹ ${totalEarnings.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "+12.5%",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "+₹5200.00 from last month",
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // INCOME TRENDS
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Income Trends",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  "Last 30 days",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _PremiumChartPainter(
                            points: normalizedWeeks,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "week 1",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            "week 2",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            "week 3",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            "week 4",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // EARNINGS BY CROP HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Earnings by Crop",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "View All",
                        style: TextStyle(
                          color: Colors.lightGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (cropEarnings.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50),
                      child: Text("Data pending shipped orders."),
                    ),
                  )
                else
                  ...cropEarnings.entries
                      .map(
                        (e) => _cropEarningsItem(
                          e.key,
                          "₹ ${e.value.toStringAsFixed(2)}",
                          (e.value / totalEarnings),
                          imageUrl: cropImages[e.key],
                          isTop: e.key == topCrop,
                        ),
                      )
                      .toList(),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _cropEarningsItem(
    String title,
    String amount,
    double progress, {
    String? imageUrl,
    bool isTop = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTop
              ? const Color(0xff9AFE56).withOpacity(0.5)
              : Colors.grey.shade100,
        ),
        boxShadow: [
          if (isTop)
            BoxShadow(color: Colors.green.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.shade50,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.eco, color: Colors.green),
                    )
                  : const Icon(Icons.eco, color: Colors.green),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xff0F5700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress.clamp(0.05, 1.0),
                  backgroundColor: Colors.grey.shade100,
                  color: const Color(0xff9AFE56),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 6),
                Text(
                  isTop
                      ? "Most Selling • ${(progress * 100).toStringAsFixed(0)}% of total"
                      : "${(progress * 100).toStringAsFixed(0)}% of total income",
                  style: TextStyle(
                    color: isTop
                        ? const Color(0xff0F5700)
                        : Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
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

class _PremiumChartPainter extends CustomPainter {
  final List<double> points;
  _PremiumChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xff9AFE56)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = const Color(0xff9AFE56).withOpacity(0.2)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    double stepX = size.width / (points.length - 1);

    path.moveTo(0, size.height * (1 - points[0] * 0.8));

    for (int i = 1; i < points.length; i++) {
      double x1 = (i - 1) * stepX;
      double y1 = size.height * (1 - points[i - 1] * 0.8);
      double x2 = i * stepX;
      double y2 = size.height * (1 - points[i] * 0.8);

      path.cubicTo(x1 + stepX / 2, y1, x1 + stepX / 2, y2, x2, y2);
    }

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // Draw dots at points
    final dotPaint = Paint()..color = const Color(0xff0F5700);
    final dotBg = Paint()..color = Colors.white;
    for (int i = 0; i < points.length; i++) {
      double dx = i * stepX;
      double dy = size.height * (1 - points[i] * 0.8);
      canvas.drawCircle(Offset(dx, dy), 6, dotBg);
      canvas.drawCircle(Offset(dx, dy), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
