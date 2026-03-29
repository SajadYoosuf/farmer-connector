import 'package:customer_app/widgets/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/screens/admin_farmers/farmer/farmer_detail.dart';

class Farmer extends StatefulWidget {
  const Farmer({super.key});

  @override
  State<Farmer> createState() => _FarmerState();
}

class _FarmerState extends State<Farmer> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Column(
        children: [
          const CommonAppBar(title: 'Farmer', showBack: false),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search by name or email...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(29, 29, 29, 0.1),
                    width: 0.1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'farmer')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No registered farmers yet.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['fullName'] ?? '')
                      .toString()
                      .toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) ||
                      email.contains(_searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No farmers match your search.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final name = data['fullName'] ?? data['email'] ?? 'Unknown';
                    final place = data['place'] ?? 'No location';
                    final Ward = data['Ward'] ?? '';
                    final mobile = data['mobile'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        final fullData = Map<String, dynamic>.from(data);
                        fullData['uid'] = docs[index].id;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FarmerDetailPage(farmerData: fullData),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            width: 1.0,
                            color: const Color.fromRGBO(0, 0, 0, 0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: const Color.fromRGBO(
                                156,
                                229,
                                101,
                                0.3,
                              ),
                              child: Text(
                                name.toString().isNotEmpty
                                    ? name.toString()[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(15, 87, 0, 1),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Color.fromRGBO(77, 77, 77, 1),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$place${Ward.toString().isNotEmpty ? ", Div $Ward" : ""}',
                                        style: const TextStyle(
                                          color: Color.fromRGBO(0, 0, 0, 0.7),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (mobile.toString().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.phone,
                                            size: 12,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            mobile.toString(),
                                            style: const TextStyle(
                                              color: Color.fromRGBO(
                                                0,
                                                0,
                                                0,
                                                0.5,
                                              ),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "Active",
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Color.fromRGBO(15, 87, 0, 1),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
