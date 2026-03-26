import 'package:customer_app/features/home/presentation/pages/home/common_widgets.dart';
import 'package:customer_app/features/product_details/presentation/pages/product_details/product_detail_more.dart';
import 'package:flutter/material.dart';
import 'package:customer_app/core/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:customer_app/features/checkout/presentation/pages/checkout/address_popup.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';

class ProductDetails extends StatefulWidget {
  final ProductModel product;
  const ProductDetails({super.key, required this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int quantity = 1;

  void increment() => setState(() => quantity++);
  void decrement() { if (quantity > 1) setState(() => quantity--); }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductDetailsHeader(context, widget.product),
            BuildTitleSection(product: widget.product, userId: userId),
          ],
        ),
      ),
      /// BOTTOM BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(15, 12, 15, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 0.1, color: const Color.fromRGBO(0, 0, 0, 0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // QUANTITY SELECTOR
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(232, 232, 232, 1),
                    border: Border.all(width: 0.1, color: const Color.fromRGBO(0, 0, 0, 0.7)),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Color.fromRGBO(0, 0, 0, 1)),
                        onPressed: decrement,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                      Text(quantity.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add, color: Color.fromRGBO(0, 0, 0, 1)),
                        onPressed: increment,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // ADD TO BASKET
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final cart = Provider.of<CartProvider>(context, listen: false);
                      for (int i = 0; i < quantity; i++) {
                        cart.addItem(widget.product);
                      }
                      showSuccessPopup(context, widget.product.name, widget.product.imageUrl);
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(15, 87, 0, 1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text('Add to Basket', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // BUY NOW — shows address popup then places order
            InkWell(
              onTap: () => _showAddressAndOrder(context),
              child: Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromRGBO(15, 87, 0, 1), width: 2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text('Buy Now', style: TextStyle(color: Color.fromRGBO(15, 87, 0, 1), fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddressAndOrder(BuildContext context) async {
    // Add to cart first
    final cart = Provider.of<CartProvider>(context, listen: false);
    for (int i = 0; i < quantity; i++) {
      cart.addItem(widget.product);
    }
    // Show address popup
    await showAddressPopup(context);
  }
}
