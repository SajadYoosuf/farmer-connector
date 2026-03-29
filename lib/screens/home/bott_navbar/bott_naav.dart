import 'package:customer_app/screens/cart/cart/cart_page.dart';
import 'package:customer_app/screens/home/home/home.dart';
import 'package:customer_app/screens/chat/message/message.dart';
import 'package:customer_app/screens/profile/profile/profile.dart';
import 'package:flutter/material.dart';

class BottomScreen extends StatefulWidget {
  const BottomScreen({super.key});

  @override
  State<BottomScreen> createState() => _BottomScreenState();
}

class _BottomScreenState extends State<BottomScreen> {
  List<Widget>screens=[
    HomePage(),MessagePage(), CartPage(),Profile(),

  ];
  int current_index = 0;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: screens[current_index],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: current_index,
          onTap: (num) {
            print("current index$num");
            setState(() {
              current_index = num;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          selectedItemColor: const Color.fromRGBO(15, 87, 0, 1),
          unselectedItemColor: const Color.fromRGBO(149, 149, 149, 1),
          selectedLabelStyle: const TextStyle(
            color: Color.fromRGBO(15, 87, 0, 1),
            fontWeight: FontWeight.bold,
          ),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.messenger), label: 'Message'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),



    );
  }
}
