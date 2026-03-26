import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShipmentsPage extends StatefulWidget {
  final String? uid;
  const ShipmentsPage({super.key, this.uid});

  @override
  State<ShipmentsPage> createState() => _ShipmentsPageState();
}

class _ShipmentsPageState extends State<ShipmentsPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.uid == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Shipments Tracker", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders')
            .where('farmerId', isEqualTo: widget.uid)
            .where('status', isEqualTo: 'confirmed')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.local_shipping_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
                   const SizedBox(height: 16),
                   const Text("No active shipments", style: TextStyle(fontSize: 18, color: Colors.black45, fontWeight: FontWeight.w600)),
                   const SizedBox(height: 8),
                   const Text("Confirm a customer request to start a shipment.", style: TextStyle(color: Colors.black38, fontSize: 13)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final id = docs[index].id;
              final customer = data['userName'] ?? 'Customer';
              final items = data['items'] as List? ?? [];
              final crop = items.isNotEmpty ? (items[0]['name'] ?? 'Crop') : 'Crop';
              final qty = items.isNotEmpty ? "${items[0]['quantity']} ${items[0]['unit'] ?? 'kg'}" : "1 kg";
              
              return _shipmentCard(id, customer, crop, qty, data['shippingStatus'] ?? 'Preparing');
            },
          );
        },
      ),
    );
  }

  Widget _shipmentCard(String id, String customer, String crop, String qty, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xff99f251).withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Color(0xfff5f5f5), shape: BoxShape.circle),
                child: const Icon(Icons.local_shipping, color: Color.fromRGBO(15, 87, 0, 1)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TO: $customer", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text("$crop ($qty)", style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xff99f251).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Color.fromRGBO(15, 87, 0, 1), fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                   onPressed: () => _updateShipping(id, 'In Transit'),
                   style: OutlinedButton.styleFrom(
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                     side: const BorderSide(color: Colors.black12),
                   ),
                   child: const Text("Mark Shipped", style: TextStyle(color: Colors.black87, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                   onPressed: () => _updateShipping(id, 'Delivered'),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xff99f251),
                     foregroundColor: Colors.black,
                     elevation: 0,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                   ),
                   child: const Text("Complete", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateShipping(String id, String newStatus) async {
    try {
      final updates = {
        'shippingStatus': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (newStatus == 'Delivered') {
        updates['status'] = 'delivered';
      }

      await FirebaseFirestore.instance.collection('orders').doc(id).update(updates);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Shipment updated to $newStatus")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating shipment: $e")));
      }
    }
  }
}
