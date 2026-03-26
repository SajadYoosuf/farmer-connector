import 'package:customer_app/features/orders/presentation/pages/order_placed/order_placed.dart';
import 'package:flutter/material.dart';
///----------------------------------------appbar part---------------------------------------///
Widget CheckoutHeader(context) {
  return Container(
    height: 150,
    color: Color.fromRGBO(154, 238, 86, 1),
    child: SafeArea(
      bottom: false,
      child: Column(
        children: [
          ///appbar section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 35),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(232, 236, 244, 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    icon: Icon(
                      Icons.chevron_left,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(30, 35, 44, 1),
                    ),
                  ),
                ),
                Text(
                  'Checkout',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                Icon(Icons.share),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
///----------------------------payment method--------------------------------------

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cardController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              'Select payment method',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 1),
              border: Border.all(color: Color.fromRGBO(155, 233, 95, 1), width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                /// Radio + Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.radio_button_checked, color: Color.fromRGBO(155, 233, 95, 1)),
                    const SizedBox(width: 10),
                    const Text(
                      "Credit/Debit card",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// Cardholder Name
                const Text("Cardholder Name", style: TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 0.56),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),),
                const SizedBox(height: 6),
                buildTextField(
                  controller: nameController,
                  hint: "Johnathan Doe",
                ),

                const SizedBox(height: 16),

                /// Card Number
                const Text("Card Number", style: TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 0.56),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),),
                const SizedBox(height: 6),
                buildTextField(
                  controller: cardController,
                  hint: "0000 0000 0000 0000",
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                /// Expiry + CVV
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Expiry date", style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 0.56),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),),
                          const SizedBox(height: 6),
                          buildTextField(
                            controller: expiryController,
                            hint: "MM/YY",
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Cvv", style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 0.56),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),),
                          const SizedBox(height: 6),
                          buildTextField(
                            controller: cvvController,
                            hint: "***",
                            keyboardType: TextInputType.number,
                            obscureText: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildTextField({
  required TextEditingController controller,
  required String hint,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Color.fromRGBO(0, 0, 0, 0.56)
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    ),
  );
}
///--------------------------------------upi method-----------------------------------------------
///------------------------apple pay--------------------------------------------
class Applepay extends StatefulWidget {
  const Applepay({super.key});

  @override
  State<Applepay> createState() => _ApplepayState();
}

class _ApplepayState extends State<Applepay> {
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Color.fromRGBO(0, 0, 0, 0.07),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 10,),
              Icon(Icons.radio_button_checked, color: Color.fromRGBO(237, 237, 237, 1), size: 35,),
              SizedBox(width: 15,),
              Text('Apple Pay', style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color.fromRGBO(0, 0, 0, 1),
              ),)



            ],
          ),
        ),
      ),
    );
  }
}

///----------------------- google pay--------------------------------

class Googlepay extends StatefulWidget {
  const Googlepay({super.key});

  @override
  _GooglepayState createState() => _GooglepayState();
}

class _GooglepayState extends State<Googlepay> {
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Color.fromRGBO(0, 0, 0, 0.07),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 10,),
              Icon(Icons.radio_button_checked, color: Color.fromRGBO(237, 237, 237, 1), size: 35,),
              SizedBox(width: 15,),
              Text('Google Pay', style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color.fromRGBO(0, 0, 0, 1),
              ),),
            ],
          ),
        ),
      ),
    );
  }
}
class PlaceOrderButton extends StatefulWidget {
  final double totalAmount;
  final VoidCallback onPlaced;
  const PlaceOrderButton({super.key, required this.totalAmount, required this.onPlaced});

  @override
  State<PlaceOrderButton> createState() => _PlaceOrderButtonState();
}

class _PlaceOrderButtonState extends State<PlaceOrderButton> {
  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        SizedBox(
          height: 35,
        ),
        Divider(
          thickness: 1.0,
          color: Color.fromRGBO(0, 0, 0, 0.19),
          indent: 20,
          endIndent: 20,
        ),
        SizedBox(height: 15,),
        Padding(
          padding: const EdgeInsets.only(left: 20,right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: TextStyle(
                fontSize:20,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(0, 0, 0, 1),
              ),),
              Text('\$${widget.totalAmount.toStringAsFixed(2)}', style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Color.fromRGBO(101, 255, 84, 1),
              ),),
            ],
          ),
        ),
        SizedBox(height: 50,),
        Padding(
          padding: const EdgeInsets.only(left: 20,right: 20),
          child: InkWell(
            onTap: () async {
              widget.onPlaced();
              Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPlacedLoadingScreen()));
            },
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Color.fromRGBO(15, 87, 0, 1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text('Place order', style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),),
              ),
            ),
          ),
        ),
        SizedBox(height: 10,),

      ],
    );
  }
}
