import 'package:customer_app/ui/home/common_widgets.dart';
import 'package:customer_app/ui/product_details/product_detail_more.dart';
import 'package:flutter/material.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int quantity = 1;

  void increment() {
    setState(() {
      quantity++;
    });
  }

  void decrement() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
     backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductDetailsHeader(context),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BuildTitleSection(),
              ],
            )

          ],
        ),
      ),
      /// BOTTOM BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 1),
            border: Border.all(
            width: 0.1,
            color: Color.fromRGBO(0, 0, 0, 0.3),
          )
        ),
        child: Row(
            children: [

        /// QUANTITY SELECTOR
        Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Color.fromRGBO(232, 232, 232, 1),
          border: Border.all(
            width: 0.1,
            color: Color.fromRGBO(0, 0, 0, 0.7),
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [

            IconButton(
              icon: const Icon(Icons.remove, color: Color.fromRGBO(0, 0, 0, 1)),
              onPressed: decrement,
            ),

            Text(
              quantity.toString(),
              style: const TextStyle(fontSize: 18, color: Color.fromRGBO(0, 0, 0, 1)),
            ),

            IconButton(
              icon: const Icon(Icons.add, color: Color.fromRGBO(0, 0, 0, 1),),
              onPressed: increment,
            ),
          ],
        ),
      ),

      const SizedBox(width: 20),


              /// ADD TO BASKET BUTTON
              Expanded(
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(15, 87, 0, 1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart, color: Color.fromRGBO(255, 255, 255, 1)),
                        SizedBox(width: 10),
                        Text(
                          "Add to Basket",
                          style: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
        ),
      ),
    );
  }


  }


