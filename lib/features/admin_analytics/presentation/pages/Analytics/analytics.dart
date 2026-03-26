import 'package:customer_app/core/widgets/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  void _showDateFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 450,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select Date Range",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: CalendarDatePicker(
                  initialDate: _selectedDateRange.end,
                  firstDate: DateTime(2023),
                  lastDate: DateTime.now(),
                  onDateChanged: (date) {
                    setState(() {
                      _selectedDateRange = DateTimeRange(
                        start: date.subtract(const Duration(days: 7)),
                        end: date,
                      );
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Note: Picking a date focuses on the 7-day window around it.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        "${DateFormat('MMM d').format(_selectedDateRange.start)} - ${DateFormat('MMM d, yyyy').format(_selectedDateRange.end)}";

    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      body: Column(
        children: [
          const CommonAppBar(title: 'Sale Analytics', showBack: false),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── DATE RANGE SELECTOR ───
                  InkWell(
                    onTap: _showDateFilter,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "Change",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Colors.green.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─── SALES TRENDS BAR CHART ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Sales Trends",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 200,
                          child: CustomPaint(
                            size: const Size(double.infinity, 200),
                            painter: _BarChartPainter(
                              data: [35, 40, 55, 70, 50, 60, 80],
                              labels: [
                                "Jan 1",
                                "Jan 10",
                                "Jan 15",
                                "Jan 20",
                                "Jan 25",
                                "Jan 31",
                                "Feb 1",
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─── PRODUCTS BREAKDOWN DONUT ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Products Breakdown",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            // Donut chart
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CustomPaint(
                                painter: _DonutChartPainter(
                                  values: [45, 30, 25],
                                  colors: [
                                    const Color.fromRGBO(15, 87, 0, 1),
                                    const Color.fromRGBO(255, 152, 0, 1),
                                    const Color.fromRGBO(156, 229, 101, 1),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "Sales",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 30),
                            // Legend
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _legendItem(
                                    const Color.fromRGBO(15, 87, 0, 1),
                                    "Fruits",
                                    "45%",
                                  ),
                                  const SizedBox(height: 14),
                                  _legendItem(
                                    const Color.fromRGBO(255, 152, 0, 1),
                                    "Vegetables",
                                    "30%",
                                  ),
                                  const SizedBox(height: 14),
                                  _legendItem(
                                    const Color.fromRGBO(156, 229, 101, 1),
                                    "Grains",
                                    "25%",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─── PLATFORM OVERVIEW (from Firestore) ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Platform Overview",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .snapshots(),
                          builder: (context, snapshot) {
                            int totalUsers = 0;
                            int totalFarmers = 0;
                            int totalAdmins = 0;

                            if (snapshot.hasData) {
                              for (var doc in snapshot.data!.docs) {
                                final data = doc.data() as Map<String, dynamic>;
                                final role = data['role'] ?? '';
                                if (role == 'user') totalUsers++;
                                if (role == 'farmer') totalFarmers++;
                                if (role == 'admin') totalAdmins++;
                              }
                            }

                            return Column(
                              children: [
                                _overviewRow(
                                  "Total Customers",
                                  totalUsers.toString(),
                                ),
                                const Divider(),
                                _overviewRow(
                                  "Total Farmers",
                                  totalFarmers.toString(),
                                ),
                                const Divider(),
                                _overviewRow(
                                  "Total Admins",
                                  totalAdmins.toString(),
                                ),
                                const Divider(),
                                _overviewRow(
                                  "Total Accounts",
                                  (totalUsers + totalFarmers + totalAdmins)
                                      .toString(),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─── RECENT SIGNUPS ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Recent Signups",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .orderBy('createdAt', descending: true)
                              .limit(5)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Text(
                                "No recent signups.",
                                style: TextStyle(color: Colors.grey),
                              );
                            }

                            return Column(
                              children: snapshot.data!.docs.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final name =
                                    data['fullName'] ??
                                    data['email'] ??
                                    'Unknown';
                                final role = data['role'] ?? 'user';

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: const Color.fromRGBO(
                                          156,
                                          229,
                                          101,
                                          0.3,
                                        ),
                                        child: Text(
                                          name.toString()[0].toUpperCase(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromRGBO(15, 87, 0, 1),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          name.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: role == 'farmer'
                                              ? Colors.green.shade100
                                              : Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          role.toString().toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: role == 'farmer'
                                                ? Colors.green.shade800
                                                : Colors.blue.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
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

  Widget _legendItem(Color color, String label, String percentage) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          percentage,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _overviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(15, 87, 0, 1),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── BAR CHART PAINTER ───────────────────
class _BarChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;

  _BarChartPainter({required this.data, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce(max);
    final barCount = data.length;
    final barWidth = (size.width - 40) / (barCount * 1.8);
    final chartHeight = size.height - 30;

    for (int i = 0; i < barCount; i++) {
      final barHeight = (data[i] / maxVal) * chartHeight * 0.9;
      final x = 20 + i * (size.width - 40) / barCount;
      final y = chartHeight - barHeight;

      // Gradient for each bar
      final isHighBar = data[i] > maxVal * 0.6;
      final barColor = isHighBar
          ? const Color.fromRGBO(15, 87, 0, 1)
          : const Color.fromRGBO(156, 229, 101, 0.7);

      final paint = Paint()
        ..color = barColor
        ..style = PaintingStyle.fill;

      final rRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );
      canvas.drawRRect(rRect, paint);

      // Draw label
      if (i < labels.length) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: const TextStyle(
              color: Color.fromRGBO(120, 120, 120, 1),
              fontSize: 9,
              fontWeight: FontWeight.w400,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(x + barWidth / 2 - textPainter.width / 2, chartHeight + 8),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────── DONUT CHART PAINTER ───────────────────
class _DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _DonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    const strokeWidth = 18.0;
    final total = values.fold(0.0, (a, b) => a + b);

    double startAngle = -pi / 2;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 2 * pi;

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle - 0.04, // small gap between segments
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
