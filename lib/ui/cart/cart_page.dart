import 'package:customer_app/ui/cart/cart_more.dart';
import 'package:customer_app/ui/checkout/checkout.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CartHeader(context),
            SizedBox(
              height: 600,
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index){
                return CartItem(
                  name: 'Pineapple',
                  subtitle: 'Sunny Hill farm',
                  image: 'assets/images/pineapple.png',
                  price: 14.5,
                  quantity: 3,
                );}
              ),
            ),
            SummaryCard(
              subtotal: 66.5,
              deliveryFee: 2.99,
              serviceFee: 1.50,
            ),
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutPage()));
              },
                child: CheckoutButton()),
            SizedBox(height: 10,)
        
          ],
        ),
      ),

    );
  }
}
