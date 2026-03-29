import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/widgets/common_widget.dart';

class FarmerDetailPage extends StatelessWidget {
  final Map<String, dynamic> farmerData;

  const FarmerDetailPage({super.key, required this.farmerData});

  @override
  Widget build(BuildContext context) {
    final uid = farmerData['uid'] ?? '';
    final name = farmerData['fullName'] ?? farmerData['email'] ?? 'Unknown Farmer';
    final place = farmerData['place'] ?? 'Unknown Location';
    final ward = farmerData['Ward'] ?? '';
    final email = farmerData['email'] ?? '';
    final mobile = farmerData['mobileNumber'] ?? farmerData['mobile'] ?? '';
    final pincode = farmerData['pincode'] ?? '';
    final totalSales = (farmerData['totalSales'] ?? 0.0).toDouble();
    final rating = (farmerData['rating'] ?? 0.0).toDouble();
    final reviewCount = (farmerData['reviewCount'] ?? 0).toInt();
    final landLocation = farmerData['landLocation'] ?? 'Not provided';
    final status = (farmerData['status'] ?? 'pending').toString().toUpperCase();
    final aadharPath = farmerData['aadharPath'] as String?;
    final farmerIDPath = farmerData['farmerIDPath'] as String?;

    String formatMoney(double n) {
      if (n >= 1000) return '₹${(n / 1000).toStringAsFixed(1)}K';
      return '₹${n.toStringAsFixed(0)}';
    }

    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      body: Column(
        children: [
          const CommonAppBar(title: 'Farmer Profile', showBack: true),
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
                              backgroundColor: const Color.fromRGBO(156, 229, 101, 0.3),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
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
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.check, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$place${ward.toString().isNotEmpty ? ", Ward $ward" : ""}${pincode.toString().isNotEmpty ? " - $pincode" : ""}',
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, size: 18, color: Colors.green.shade700),
                            const SizedBox(width: 4),
                            Text(
                              rating > 0 ? rating.toStringAsFixed(1) : "New",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              reviewCount > 0 ? "($reviewCount reviews)" : "(No reviews yet)",
                              style: const TextStyle(fontSize: 13, color: Colors.black45),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── STATS ROW (Live) ───
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: uid.isNotEmpty
                          ? FirebaseFirestore.instance
                              .collection('products')
                              .where('farmerId', isEqualTo: uid)
                              .where('isActive', isEqualTo: true)
                              .snapshots()
                          : null,
                      builder: (context, prodSnap) {
                        int activeProducts = 0;
                        if (prodSnap.hasData) activeProducts = prodSnap.data!.docs.length;

                        return StreamBuilder<QuerySnapshot>(
                          stream: uid.isNotEmpty
                              ? FirebaseFirestore.instance
                                  .collection('orders')
                                  .where('farmerId', isEqualTo: uid)
                                  .snapshots()
                              : null,
                          builder: (context, orderSnap) {
                            double earnings = 0;
                            if (orderSnap.hasData) {
                              for (var doc in orderSnap.data!.docs) {
                                final d = doc.data() as Map<String, dynamic>;
                                earnings += (d['totalAmount'] ?? 0).toDouble();
                              }
                            }

                            return Row(
                              children: [
                                _statBox("TOTAL SALES", formatMoney(totalSales > 0 ? totalSales : earnings), "+${(earnings > 0 ? 12 : 0)}%"),
                                const SizedBox(width: 10),
                                _statBox("ACTIVE", activeProducts.toString(), "Products"),
                                const SizedBox(width: 10),
                                _statBox("EARNINGS", formatMoney(earnings), "Total"),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── VERIFICATION DOCUMENTS ───
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
                        const Text(
                          "Verification Documents",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildDocCard("Aadhar Card", aadharPath, context),
                            const SizedBox(width: 12),
                            _buildDocCard("Farmer ID", farmerIDPath, context),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text("Land Location", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
                        const SizedBox(height: 8),
                        _infoRow(Icons.map_outlined, landLocation),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── CONTACT INFO ───
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
                        const Text("Contact Information", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        _infoRow(Icons.email_outlined, email),
                        if (mobile.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _infoRow(Icons.phone_outlined, mobile),
                        ],
                        if (place.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _infoRow(Icons.location_on_outlined, '$place${pincode.isNotEmpty ? " - $pincode" : ""}'),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── ACTIVE LISTINGS (Live) ───
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
                            const Text("Active Listings", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            Text("View All", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green.shade700)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (uid.isNotEmpty)
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('products')
                                .where('farmerId', isEqualTo: uid)
                                .where('isActive', isEqualTo: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text("No active listings yet.", style: TextStyle(color: Colors.grey, fontSize: 14))));
                              }
                              return Column(
                                children: snapshot.data!.docs.map((doc) {
                                  final p = doc.data() as Map<String, dynamic>;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.eco, color: Colors.green.shade700, size: 28)),
                                        const SizedBox(width: 12),
                                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)), Text("${p['category'] ?? ''} · ${p['stock'] ?? 0} ${p['unit'] ?? ''} in stock", style: const TextStyle(color: Colors.black54, fontSize: 12))])),
                                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text("₹${(p['price'] ?? 0).toStringAsFixed(2)}/${p['unit'] ?? ''}", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green.shade700, fontSize: 13)), if (p['demand'] != null && p['demand'] != 'Normal') Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: p['demand'] == 'High Demand' ? Colors.green.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(6)), child: Text(p['demand'], style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: p['demand'] == 'High Demand' ? Colors.green.shade800 : Colors.orange.shade800)))]),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          )
                        else
                          const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text("No active listings yet.", style: TextStyle(color: Colors.grey, fontSize: 14)))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── RECENT ORDERS (Live) ───
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
                          children: const [
                            Text("Recent Earnings", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            Icon(Icons.filter_list, color: Colors.black54),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (uid.isNotEmpty)
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('orders')
                                .where('farmerId', isEqualTo: uid)
                                .orderBy('createdAt', descending: true)
                                .limit(5)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text("No earnings data yet.", style: TextStyle(color: Colors.grey, fontSize: 14))));
                              }
                              return Column(
                                children: snapshot.data!.docs.map((doc) {
                                  final o = doc.data() as Map<String, dynamic>;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        CircleAvatar(radius: 18, backgroundColor: Colors.blue.shade50, child: Icon(Icons.receipt_long, size: 18, color: Colors.blue.shade700)),
                                        const SizedBox(width: 12),
                                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(o['userName'] ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)), Text(o['status'] ?? 'pending', style: const TextStyle(color: Colors.black45, fontSize: 11))])),
                                        Text("₹${(o['totalAmount'] ?? 0).toStringAsFixed(0)}", style: TextStyle(fontWeight: FontWeight.w700, color: Colors.green.shade700)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          )
                        else
                          const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text("No earnings data yet.", style: TextStyle(color: Colors.grey, fontSize: 14)))),
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
      bottomNavigationBar: status.toLowerCase() == 'pending'
          ? Container(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 34, top: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(context, uid, 'declined'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Decline", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(context, uid, 'approved'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color.fromRGBO(15, 87, 0, 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Approve Farmer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Future<void> _updateStatus(BuildContext context, String uid, String status) async {
    if (uid.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'status': status});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Farmer ${status.toUpperCase()}'),
            backgroundColor: status == 'approved' ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _statBox(String label, String value, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(156, 229, 101, 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.green.shade800, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.green.shade600, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black45),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87))),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'declined': return Colors.red;
      default: return Colors.orange;
    }
  }

  Widget _buildDocCard(String label, String? path, BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (path != null && File(path).existsSync()) {
            _showImageDialog(context, path, label);
          }
        },
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (path != null && File(path).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(File(path), fit: BoxFit.cover, height: 80, width: double.infinity),
                )
              else
                const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 30),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String path, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(title),
              leading: const CloseButton(),
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.black,
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              child: Image.file(File(path)),
            ),
          ],
        ),
      ),
    );
  }
}
