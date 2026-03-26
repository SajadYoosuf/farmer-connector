import 'package:customer_app/features/home/presentation/pages/home/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:customer_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:customer_app/core/models/product_model.dart';
import 'package:customer_app/features/product_details/presentation/pages/product_details/product_details.dart';

///---------------------------------------appbar-------------------------------------
Widget CartHeader(context) {
  return Container(
    height: 150,
    width: double.infinity,
    color: Color.fromRGBO(154, 238, 86, 1),
    child: SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ///appbar section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 35),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  'Your basket',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

///--------------------------------------------cart items--------------------------------------------
Widget CartItemWidget({
  required BuildContext context,
  required CartItem item,
  required VoidCallback onIncrement,
  required VoidCallback onDecrement,
  required VoidCallback onRemove,
}) {
  double total = item.quantity * item.product.price;
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetails(product: item.product),
        ),
      );
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetails(product: item.product),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromRGBO(255, 255, 255, 1),
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Colors.black12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          //image
          Container(
            width: 90,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ProductImage(item.product.imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          //Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(0, 0, 0, 1),
                  ),
                ),
                Text(
                  item.product.farmerName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(138, 138, 138, 1),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '₹${item.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color.fromRGBO(101, 255, 84, 1),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                //Quantity Selector
                Container(
                  height: 55,
                  width: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    color: const Color.fromRGBO(246, 248, 246, 1),
                    border: Border.all(
                      width: 1.0,
                      color: const Color.fromRGBO(0, 0, 0, 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 3),
                      Container(
                        height: 45,
                        width: 45,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromRGBO(255, 255, 255, 1),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              color: Colors.black12,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: onDecrement,
                          icon: const Icon(
                            Icons.remove,
                            color: Color.fromRGBO(0, 0, 0, 1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        item.quantity.toString(),
                        style: const TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 1),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 45,
                        width: 45,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromRGBO(155, 234, 94, 1),
                        ),
                        child: IconButton(
                          onPressed: onIncrement,
                          icon: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          //Right side
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.delete,
                  color: Color.fromRGBO(0, 0, 0, 0.63),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                '₹${total.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: Color.fromRGBO(15, 87, 0, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

}

///----------------------------------summary card -----------------------------------------------

class SummaryCard extends StatefulWidget {
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double total;

  const SummaryCard({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
  });

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  double get total => widget.subtotal + widget.deliveryFee + widget.serviceFee;

  Widget buildRow(String title, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.normal : FontWeight.w700,
              color: Color.fromRGBO(0, 0, 0, 0.7),
            ),
          ),
          Text(
            "\₹${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.normal : FontWeight.w700,
              color: Color.fromRGBO(15, 87, 0, 1),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            buildRow("Subtotal", widget.subtotal),
            buildRow("Delivery Fee", widget.deliveryFee),
            buildRow("Service Fee", widget.serviceFee),

            const Divider(
              height: 24,
              color: Color.fromRGBO(0, 0, 0, 0.14),
              thickness: 1.0,
            ),

            buildRow("Total", widget.total, isTotal: true),
          ],
        ),
      ),
    );
  }
}

class CheckoutButton extends StatefulWidget {
  const CheckoutButton({super.key});

  @override
  State<CheckoutButton> createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends State<CheckoutButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Color.fromRGBO(15, 87, 0, 1),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color.fromRGBO(0, 0, 0, 0.25),
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Proceed to checkout',
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
