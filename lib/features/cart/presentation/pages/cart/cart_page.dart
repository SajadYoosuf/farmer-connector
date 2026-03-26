import 'package:customer_app/features/cart/presentation/pages/cart/cart_more.dart';
import 'package:customer_app/features/checkout/presentation/pages/checkout/checkout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/cart/presentation/providers/cart_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final items = cartProvider.items.values.toList();
          
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('Your basket is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                CartHeader(context),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CartItemWidget(
                      item: item,
                      onIncrement: () => cartProvider.addItem(item.product),
                      onDecrement: () => cartProvider.removeOne(item.product.id!),
                      onRemove: () => cartProvider.removeItem(item.product.id!),
                    );
                  },
                ),
                SummaryCard(
                  subtotal: cartProvider.subtotal,
                  deliveryFee: cartProvider.deliveryFee,
                  serviceFee: cartProvider.serviceFee,
                  total: cartProvider.totalAmount,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutPage()));
                  },
                  child: const CheckoutButton(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),

    );
  }
}
