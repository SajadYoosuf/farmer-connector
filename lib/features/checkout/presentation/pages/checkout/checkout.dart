import 'package:customer_app/features/checkout/presentation/pages/checkout/checkout_more.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:customer_app/core/services/firestore_service.dart';
import 'package:customer_app/core/models/order_model.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, AuthProvider>(
      builder: (context, cartProvider, authProvider, child) {
        return Scaffold(
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckoutHeader(context),
                const PaymentMethod(),
                const Applepay(),
                const SizedBox(height: 10),
                const Googlepay(),
                PlaceOrderButton(
                  totalAmount: cartProvider.totalAmount,
                  onPlaced: () async {
                    if (cartProvider.items.isEmpty) return;

                    final firstItem = cartProvider.items.values.first;
                    final order = OrderModel(
                      userId: authProvider.currentUser?.uid ?? 'guest',
                      userName: authProvider.currentUser?.email ?? 'Guest',
                      farmerId: firstItem.product.farmerId,
                      farmerName: firstItem.product.farmerName,
                      totalAmount: cartProvider.totalAmount,
                      items: cartProvider.items.values.map((item) => OrderItem(
                        productId: item.product.id!,
                        productName: item.product.name,
                        quantity: item.quantity,
                        price: item.product.price,
                        subtotal: item.total,
                      )).toList(),
                    );

                    await FirestoreService().placeOrder(order);
                    cartProvider.clear();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
