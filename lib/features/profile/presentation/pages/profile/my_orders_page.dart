import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:customer_app/core/widgets/network_aware_widget.dart';
import 'package:customer_app/core/providers/network_provider.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  int _selectedTab = 0; // 0=Active, 1=Completed, 2=Cancelled

  static const _tabs = ['Active', 'Completed', 'Cancelled'];

  // Maps tab index to Firestore status values
  List<String> _statusFilter() {
    if (_selectedTab == 0) return ['pending', 'confirmed', 'Preparing', 'shipped'];
    if (_selectedTab == 1) return ['delivered'];
    return ['cancelled'];
  }

  // User-friendly label for status
  Map<String, dynamic> _statusChip(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return {'label': 'Waiting for farmer', 'color': Colors.orange.shade700, 'bg': Colors.orange.shade50, 'icon': Icons.hourglass_top_rounded};
      case 'confirmed':
        return {'label': 'Accepted by farmer', 'color': Colors.blue.shade700, 'bg': Colors.blue.shade50, 'icon': Icons.check_circle_outline};
      case 'preparing':
        return {'label': 'Preparing order', 'color': Colors.purple.shade700, 'bg': Colors.purple.shade50, 'icon': Icons.inventory_2_outlined};
      case 'shipped':
        return {'label': 'On the way', 'color': Colors.teal.shade700, 'bg': Colors.teal.shade50, 'icon': Icons.local_shipping_outlined};
      case 'delivered':
        return {'label': 'Delivered', 'color': const Color(0xff0F5700), 'bg': const Color(0xffE8F5E9), 'icon': Icons.task_alt_rounded};
      case 'cancelled':
        return {'label': 'Cancelled', 'color': Colors.red.shade700, 'bg': Colors.red.shade50, 'icon': Icons.cancel_outlined};
      default:
        return {'label': status, 'color': Colors.grey, 'bg': Colors.grey.shade100, 'icon': Icons.info_outline};
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(154, 238, 86, 1),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // ── TAB BAR ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final selected = _selectedTab == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xff0F5700) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          _tabs[i],
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // ── ORDER LIST ──
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: user.uid)
                  .where('status', whereIn: _statusFilter())
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                final isOnline = context.watch<NetworkProvider>().isOnline;

                if (!isOnline && snapshot.data == null) {
                  return OfflinePlaceholder(onRetry: () => setState(() {}));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xff0F5700)));
                }

                if (snapshot.hasError) {
                  return OfflinePlaceholder(onRetry: () => setState(() {}));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No ${_tabs[_selectedTab].toLowerCase()} orders',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final orderId = docs[index].id;
                    return _orderCard(orderId, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(String orderId, Map<String, dynamic> data) {
    final status = (data['status'] ?? 'pending') as String;
    final chip = _statusChip(status);
    final farmerName = data['farmerName'] ?? 'Farmer';
    final totalAmount = (data['totalAmount'] ?? 0).toDouble();
    final items = data['items'] as List? ?? [];
    final createdAt = data['createdAt'];
    final shippingStatus = data['shippingStatus'] as String?;

    String dateStr = 'Just now';
    if (createdAt is Timestamp) {
      final dt = createdAt.toDate();
      dateStr = '${dt.day}/${dt.month}/${dt.year}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // ── ORDER HEADER ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xffE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.store_outlined, color: Color(0xff0F5700), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(farmerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Ordered on $dateStr', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                // STATUS CHIP
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: chip['bg'] as Color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(chip['icon'] as IconData, size: 12, color: chip['color'] as Color),
                      const SizedBox(width: 4),
                      Text(
                        chip['label'] as String,
                        style: TextStyle(color: chip['color'] as Color, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── ITEMS PREVIEW ──
          if (items.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xfff9f9f9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: List.generate(items.length > 3 ? 3 : items.length, (i) {
                  final item = items[i] as Map<String, dynamic>;
                  return Padding(
                    padding: EdgeInsets.only(bottom: i < items.length - 1 ? 8 : 0),
                    child: Row(
                      children: [
                        const Icon(Icons.eco_outlined, size: 16, color: Color(0xff0F5700)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(item['name'] ?? 'Product',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ),
                        Text('x${item['quantity']}', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        const SizedBox(width: 10),
                        Text('₹${((item['price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xff0F5700))),
                      ],
                    ),
                  );
                }),
              ),
            ),

          // ── SHIPPING TRACKER (only if confirmed/preparing/shipped) ──
          if (['confirmed', 'preparing', 'shipped'].contains(status.toLowerCase()))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildTracker(status.toLowerCase(), shippingStatus),
            ),

          // ── FOOTER ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${items.length} item${items.length != 1 ? 's' : ''} • Total',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
                Text(
                  '₹${totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff0F5700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTracker(String status, String? shippingStatus) {
    final steps = ['Accepted', 'Preparing', 'Shipped', 'Delivered'];
    int activeStep = 0;
    if (status == 'confirmed') activeStep = 1;
    if (status == 'preparing' || shippingStatus?.toLowerCase() == 'preparing') activeStep = 1;
    if (status == 'shipped' || shippingStatus?.toLowerCase() == 'shipped') activeStep = 2;
    if (status == 'delivered') activeStep = 3;

    return Row(
      children: List.generate(steps.length, (i) {
        final done = i <= activeStep;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (i > 0) Expanded(child: Container(height: 2, color: done ? const Color(0xff0F5700) : Colors.grey.shade200)),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? const Color(0xff0F5700) : Colors.grey.shade200,
                    ),
                    child: Icon(Icons.check, size: 12, color: done ? Colors.white : Colors.grey.shade400),
                  ),
                  if (i < steps.length - 1) Expanded(child: Container(height: 2, color: i < activeStep ? const Color(0xff0F5700) : Colors.grey.shade200)),
                ],
              ),
              const SizedBox(height: 4),
              Text(steps[i], style: TextStyle(fontSize: 9, color: done ? const Color(0xff0F5700) : Colors.grey, fontWeight: done ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        );
      }),
    );
  }
}
