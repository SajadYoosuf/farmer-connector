import 'package:customer_app/screens/home/home/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/models/product_model.dart';
import 'package:customer_app/screens/chat/message/chat/chat_page.dart';

///product details
// ── Top green header ──
Widget ProductDetailsHeader(BuildContext context, ProductModel product) {
  return Container(
    height: 137,
    color: const Color.fromRGBO(154, 238, 86, 1),
    child: SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(232, 236, 244, 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.chevron_left,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(30, 35, 44, 1),
                    ),
                  ),
                ),
                const Text(
                  'Product Details',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: 48), // spacer to keep title centered
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Stateful section with favorite + farmer card ──
class BuildTitleSection extends StatefulWidget {
  final ProductModel product;
  final String userId;
  const BuildTitleSection({
    super.key,
    required this.product,
    required this.userId,
  });

  @override
  State<BuildTitleSection> createState() => _BuildTitleSectionState();
}

class _BuildTitleSectionState extends State<BuildTitleSection> {
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _loadFavStatus();
  }

  Future<void> _loadFavStatus() async {
    if (widget.userId.isEmpty || widget.product.id == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('favourites')
        .doc(widget.product.id)
        .get();
    if (mounted) setState(() => _isFav = doc.exists);
  }

  Future<void> _toggleFav() async {
    if (widget.userId.isEmpty || widget.product.id == null) return;
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('favourites')
        .doc(widget.product.id);
    setState(() => _isFav = !_isFav);
    if (_isFav) {
      await ref.set({
        'productId': widget.product.id,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Column(
      children: [
        /// PRODUCT IMAGE
        Container(
          margin: const EdgeInsets.all(16),
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: ProductImage(product.imageUrl, fit: BoxFit.cover),
          ),
        ),

        /// product info
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // ── FUNCTIONAL FAVOURITE BUTTON ──
                  GestureDetector(
                    onTap: _toggleFav,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: _isFav ? Colors.red.shade50 : Colors.white,
                        border: Border.all(
                          width: 1.0,
                          color: _isFav
                              ? Colors.red.shade200
                              : const Color.fromRGBO(0, 0, 0, 0.2),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _isFav ? Icons.favorite : Icons.favorite_border,
                          color: _isFav ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                '₹${product.price.toStringAsFixed(2)}/${product.unit}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Color.fromRGBO(15, 87, 0, 1),
                ),
              ),
              const SizedBox(height: 10),

              /// Description
              const Text(
                'Description',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              Text(
                product.name.isNotEmpty
                    ? 'Fresh ${product.name} sourced directly from the farm. Guaranteed quality and freshness delivered to your door.'
                    : 'Fresh farm produce sourced directly, guaranteed quality.',
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color.fromRGBO(0, 0, 0, 0.64),
                ),
              ),
              const SizedBox(height: 20),
              FeatureCard(
                Icons.eco,
                '100% Organic Certified',
                'No synthetic pesticides used',
              ),
              const SizedBox(height: 10),
              FeatureCard(
                Icons.local_shipping,
                'Farm to Door Delivery',
                'Fresh from the farm daily',
              ),
              const SizedBox(height: 20),

              // ── FARMER CARD ──
              FarmerInfoCard(product: product),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}

/// Farmer info card shown on product details
class FarmerInfoCard extends StatelessWidget {
  final ProductModel product;
  const FarmerInfoCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FarmerProfilePage(
              farmerId: product.farmerId,
              farmerName: product.farmerName,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xffF0FAF0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xff9AF055).withOpacity(0.4)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xff9AF055).withOpacity(0.3),
              child: const Icon(
                Icons.person,
                color: Color(0xff0F5700),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sold by',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  Text(
                    product.farmerName.isNotEmpty
                        ? product.farmerName
                        : 'Unknown Farmer',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'ID: ${product.farmerId.isNotEmpty ? product.farmerId.substring(0, 8) : '0'}...',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            // CHAT BUTTON
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      farmerId: product.farmerId,
                      farmerName: product.farmerName,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xff0F5700),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Message',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Farmer Profile Page (when tapping farmer card)
class FarmerProfilePage extends StatelessWidget {
  final String farmerId;
  final String farmerName;
  const FarmerProfilePage({
    super.key,
    required this.farmerId,
    required this.farmerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(farmerId)
            .snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final phone = data?['phone'] ?? data?['mobile'] ?? '0';
          final place =
              data?['place'] ?? data?['extraData']?['place'] ?? 'Kerala, India';
          final profileImg = data?['profileImage'] ?? '';

          return Column(
            children: [
              // GREEN HEADER
              Container(
                height: 220,
                color: const Color.fromRGBO(154, 238, 86, 1),
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                            const Expanded(
                              child: Text(
                                'Farmer Profile',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        backgroundImage: profileImg.isNotEmpty
                            ? NetworkImage(profileImg)
                            : null,
                        child: profileImg.isEmpty
                            ? Text(
                                farmerName.isNotEmpty
                                    ? farmerName[0].toUpperCase()
                                    : 'F',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff0F5700),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        farmerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // DETAILS
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _infoCard(Icons.phone, 'Phone', phone.toString()),
                      const SizedBox(height: 10),
                      _infoCard(
                        Icons.location_on,
                        'Location',
                        place.toString(),
                      ),
                      const SizedBox(height: 10),
                      _infoCard(
                        Icons.badge_outlined,
                        'Farmer ID',
                        farmerId.isNotEmpty ? farmerId : '0',
                      ),
                      const SizedBox(height: 24),
                      // SEND MESSAGE BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  farmerId: farmerId,
                                  farmerName: farmerName,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Send Message',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0F5700),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xffE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xff0F5700), size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

///feature card
Widget FeatureCard(icon, title, subtitle) {
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      border: Border.all(width: 0.1, color: const Color.fromRGBO(0, 0, 0, 0.7)),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: const Color.fromRGBO(200, 245, 200, 0.51),
          child: Icon(icon, color: const Color.fromRGBO(15, 87, 0, 1)),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
            ),
          ],
        ),
      ],
    ),
  );
}
