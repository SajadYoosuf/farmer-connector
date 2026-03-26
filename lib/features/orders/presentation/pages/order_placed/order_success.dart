import 'dart:async';

import 'package:customer_app/features/home/presentation/pages/bott_navbar/bott_naav.dart';
import 'package:customer_app/features/home/presentation/pages/home/home.dart';
import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate after 2 seconds
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BottomScreen(),
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

            // Big circle with check icon
            Container(
              height: 100,
              width: 100,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(159, 255, 195, 1), // light green
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(159, 255, 195, 1),
                    border: Border.all(
                      color: Color.fromRGBO(34, 197, 94, 1),
                      width: 5,
                    )
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 35,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
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

            const SizedBox(height: 20),

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