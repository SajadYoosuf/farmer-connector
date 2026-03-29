import 'package:customer_app/screens/auth/choose_page/choose_page_more.dart';
import 'package:flutter/material.dart';

class ChoosePageMore extends StatefulWidget {
  const ChoosePageMore({super.key});

  @override
  State<ChoosePageMore> createState() => _ChoosePageMoreState();
}

class _ChoosePageMoreState extends State<ChoosePageMore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromRGBO(153, 242, 81, 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30, top: 80),
            child: Text(
              'Choose your role',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: Color.fromRGBO(15, 87, 0, 1),
              ),
            ),
          ),
          SizedBox(height: 50),

          buildRoleCard(
            context,
            title: 'I am a Customer',
            subtitle:
                'Discover seasonal produce and support your local farmer with direct delivery',
            buttonText: 'Start Shopping',
            image: 'assets/images/choose_customer.png',
            role: 'user',
          ),
          SizedBox(height: 35),
          buildRoleCard(
            context,
            title: 'I am a Farmer',
            subtitle:
                'Grow your business by selling directly to conscious consumers in your area',
            buttonText: 'Start Selling',
            image: 'assets/images/choose_farmer.png',
            role: 'farmer',
          ),
        ],
      ),
    );
  }
}
