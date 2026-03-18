import 'package:customer_app/ui/checkout/checkout_more.dart';
import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckoutHeader(context),
            PaymentMethod(),
            Applepay(),
            SizedBox(height: 10,),
            Googlepay(),
            PlaceOrderButton()

        
          ],
        ),
      ),
    );
  }
}
