import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/home/presentation/providers/product_provider.dart';
import 'package:customer_app/core/models/product_model.dart';
import 'package:customer_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:customer_app/features/home/presentation/pages/home/common_widgets.dart';
import 'package:customer_app/features/product_details/presentation/pages/product_details/product_details.dart';
import 'package:customer_app/core/providers/network_provider.dart';
import 'package:customer_app/core/widgets/network_aware_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Hero(
          tag: 'search-bar',
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) => setState(() => _query = val),
                decoration: const InputDecoration(
                  hintText: 'Search for fruits, vegetables...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey, size: 22),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final isOnline = context.watch<NetworkProvider>().isOnline;

          if (!isOnline && productProvider.products.isEmpty) {
            return OfflinePlaceholder(onRetry: () {});
          }

          final results = productProvider.products.where((p) => 
            p.name.toLowerCase().contains(_query.toLowerCase()) || 
            p.category.toLowerCase().contains(_query.toLowerCase())
          ).toList();

          if (_query.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.search_rounded, size: 100, color: Colors.grey.shade200),
                   const SizedBox(height: 16),
                   Text('Search our fresh farm products', style: TextStyle(color: Colors.grey.shade400)),
                ],
              ),
            );
          }

          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.no_photography_rounded, size: 100, color: Colors.grey.shade200),
                   const SizedBox(height: 16),
                   Text('No products found for "$_query"', style: TextStyle(color: Colors.grey.shade400)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final product = results[index];
              return _searchItemCard(context, product);
            },
          );
        },
      ),
    );
  }

  Widget _searchItemCard(BuildContext context, ProductModel product) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetails(product: product))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 70,
                height: 70,
                child: ProductImage(product.imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${product.category} • ${product.farmerName}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('₹ ${product.price.toStringAsFixed(0)}/${product.unit}', style: const TextStyle(color: Color(0xff0F5700), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Provider.of<CartProvider>(context, listen: false).addItem(product);
                showSuccessPopup(context, product.name, product.imageUrl);
              },
              icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xff0F5700)),
            ),
          ],
        ),
      ),
    );
  }
}
