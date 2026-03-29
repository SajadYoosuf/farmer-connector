import 'dart:async';
import 'package:customer_app/screens/orders/order_placed/order_success.dart';
import 'package:flutter/material.dart';

class OrderPlacedLoadingScreen extends StatefulWidget {
  const OrderPlacedLoadingScreen({super.key});

  @override
  State<OrderPlacedLoadingScreen> createState() =>
      _OrderPlacedLoadingScreenState();
}

class _OrderPlacedLoadingScreenState
    extends State<OrderPlacedLoadingScreen> {

  @override
  void initState() {
    super.initState();

    // Navigate after 2 seconds
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OrderSuccessScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Small green dot
            Container(
              height: 16,
              width: 16,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Placed Order!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(15, 87, 0, 1),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "We’ve received your order and are processing it",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(15, 87, 0, 1),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}