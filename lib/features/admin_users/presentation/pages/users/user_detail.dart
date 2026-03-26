import 'package:customer_app/core/widgets/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class UserDetailPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserDetailPage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final uid = userData['uid'] ?? '';
    final name = userData['fullName'] ?? userData['email'] ?? 'Unknown User';
    final email = userData['email'] ?? '';
    final mobile = userData['mobile'] ?? '';
    final place = userData['place'] ?? '';
    final pincode = userData['pincode'] ?? '';
    final totalSpent = (userData['totalSpent'] ?? 0).toDouble();
    final totalOrders = (userData['totalOrders'] ?? 0).toInt();

    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      body: Column(
        children: [
          const CommonAppBar(title: 'Customer Profile'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ─── PROFILE HEADER ───
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: const Color.fromRGBO(255, 224, 178, 0.5),
                              child: Text(
                                name.toString()[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(15, 87, 0, 1),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.check, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name.toString(),
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.email_outlined, size: 16, color: Colors.black45),
                            const SizedBox(width: 6),
                            Text(email.toString(),
                                style: const TextStyle(fontSize: 14, color: Colors.black54)),
                          ],
                        ),
                        if (mobile.toString().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.phone_outlined, size: 16, color: Colors.black45),
                              const SizedBox(width: 6),
                              Text(mobile.toString(),
                                  style: const TextStyle(fontSize: 14, color: Colors.black54)),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(156, 229, 101, 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Member since 2025",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ─── ACTION BUTTONS ───
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.chat_bubble_outline, size: 18),
                            label: const Text("Contact"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(15, 87, 0, 1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.assignment_outlined,
                                size: 18, color: Colors.green.shade700),
                            label: Text("Tickets",
                                style: TextStyle(color: Colors.green.shade700)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.green.shade700),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─── SPENDING INSIGHTS (Live) ───
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Spending Insights",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            Text("ALL TIME",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<QuerySnapshot>(
                          stream: uid.toString().isNotEmpty
                              ? FirebaseFirestore.instance
                                  .collection('orders')
                                  .where('userId', isEqualTo: uid)
                                  .snapshots()
                              : null,
                          builder: (context, snapshot) {
                            double spent = totalSpent;
                            int orders = totalOrders;

                            if (snapshot.hasData) {
                              spent = 0;
                              orders = snapshot.data!.docs.length;
                              for (var doc in snapshot.data!.docs) {
                                final d = doc.data() as Map<String, dynamic>;
                                spent += (d['totalAmount'] ?? 0).toDouble();
                              }
                            }

                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(156, 229, 101, 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Total Purchases",
                                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        "₹${spent.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black87),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "$orders orders",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 80,
                                    child: CustomPaint(
                                      size: const Size(double.infinity, 80),
                                      painter: _SpendingChartPainter(
                                        data: [20, 35, 25, 45, 55, 70],
                                        labels: ["JAN", "FEB", "MAR", "APR", "MAY", "JUN"],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── ORDER HISTORY (Live) ───
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Order History",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        if (uid.toString().isNotEmpty)
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('orders')
                                .where('userId', isEqualTo: uid)
                                .orderBy('createdAt', descending: true)
                                .limit(5)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Text("No orders yet.",
                                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                                  ),
                                );
                              }

                              return Column(
                                children: snapshot.data!.docs.map((doc) {
                                  final o = doc.data() as Map<String, dynamic>;
                                  final status = o['status'] ?? 'pending';

                                  Color statusColor;
                                  switch (status) {
                                    case 'delivered':
                                      statusColor = Colors.green;
                                      break;
                                    case 'confirmed':
                                      statusColor = Colors.blue;
                                      break;
                                    case 'cancelled':
                                      statusColor = Colors.red;
                                      break;
                                    default:
                                      statusColor = Colors.orange;
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: statusColor.withOpacity(0.1),
                                          child: Icon(Icons.shopping_bag,
                                              size: 18, color: statusColor),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "From ${o['farmerName'] ?? 'Farmer'}",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500, fontSize: 14),
                                              ),
                                              Text(
                                                status.toString().toUpperCase(),
                                                style: TextStyle(
                                                    color: statusColor,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          "₹${(o['totalAmount'] ?? 0).toStringAsFixed(0)}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.green.shade700),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          )
                        else
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text("No orders yet.",
                                  style: TextStyle(color: Colors.grey, fontSize: 14)),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── LOCATION INFO ───
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Location Details",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        if (place.toString().isNotEmpty)
                          _infoRow(Icons.location_on_outlined, "Place: ${place.toString()}"),
                        if (pincode.toString().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _infoRow(Icons.pin_drop_outlined, "Pincode: ${pincode.toString()}"),
                        ],
                        if (place.toString().isEmpty && pincode.toString().isEmpty)
                          const Text("No location data available.",
                              style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black45),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ),
      ],
    );
  }
}

// ─── SPENDING LINE CHART ───
class _SpendingChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;

  _SpendingChartPainter({required this.data, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce(max);
    final minVal = data.reduce(min);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;
    final chartHeight = size.height - 20;

    final linePaint = Paint()
      ..color = const Color.fromRGBO(76, 175, 80, 1)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color.fromRGBO(76, 175, 80, 0.3),
          const Color.fromRGBO(76, 175, 80, 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = chartHeight - ((data[i] - minVal) / range) * chartHeight * 0.85;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, chartHeight);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = chartHeight - ((data[i - 1] - minVal) / range) * chartHeight * 0.85;
        final ctrlX = (prevX + x) / 2;
        path.cubicTo(ctrlX, prevY, ctrlX, y, x, y);
        fillPath.cubicTo(ctrlX, prevY, ctrlX, y, x, y);
      }

      if (i < labels.length) {
        final isLast = i == labels.length - 1;
        final tp = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: TextStyle(
              color: isLast
                  ? Colors.green.shade700
                  : const Color.fromRGBO(140, 140, 140, 1),
              fontSize: 9,
              fontWeight: isLast ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, chartHeight + 6));
      }
    }

    fillPath.lineTo(size.width, chartHeight);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
