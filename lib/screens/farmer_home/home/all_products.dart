import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/screens/home/home/common_widgets.dart';
import 'package:customer_app/screens/farmer_home/add_product/add_product.dart';

class FarmerAllProducts extends StatefulWidget {
  final String? uid;
  const FarmerAllProducts({super.key, this.uid});

  @override
  State<FarmerAllProducts> createState() => _FarmerAllProductsState();
}

class _FarmerAllProductsState extends State<FarmerAllProducts> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ["All", "Fruits", "Vegetables", "Meat", "Home Made", "Dairy"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Stock Management", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black45,
          indicatorColor: const Color(0xff99f251),
          indicatorWeight: 4,
          tabs: _categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((cat) => _buildProductList(cat)).toList(),
      ),
    );
  }

  Widget _buildProductList(String category) {
    Query query = FirebaseFirestore.instance.collection('products').where('farmerId', isEqualTo: widget.uid);
    if (category != "All") {
      query = query.where('category', isEqualTo: category);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text("No products found in this category."));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _allProductItem(doc.id, data);
          },
        );
      },
    );
  }

  Widget _allProductItem(String id, Map<String, dynamic> data) {
    final name = data['name'] ?? 'Product';
    final price = data['price'] ?? 0;
    final stock = data['stock'] ?? 0;
    final image = data['imageUrl'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80, height: 80,
              color: Colors.grey.shade100,
              child: image.isNotEmpty
                  ? ProductImage(image, fit: BoxFit.cover)
                  : const Icon(Icons.eco, color: Colors.green),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text("Stock: $stock", style: const TextStyle(color: Colors.black54)),
                Text("₹$price", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FarmerAddProduct(productId: id, productData: data))),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(id, name),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete?"),
        content: Text("Delete '$name'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(onPressed: () async {
            Navigator.pop(context);
            await FirebaseFirestore.instance.collection('products').doc(id).delete();
          }, child: const Text("Yes", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
