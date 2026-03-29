import 'package:customer_app/screens/chat/message/message.dart';
import 'package:customer_app/screens/profile/profile/profile.dart';
import 'package:customer_app/screens/farmer_home/home/home.dart';
import 'package:customer_app/screens/farmer_orders/requests/customer_requests.dart';
import 'package:customer_app/screens/farmer_earnings/earnings/earnings_dashboard.dart';
import 'package:flutter/material.dart';

class FarmerBottomScreen extends StatefulWidget {
  const FarmerBottomScreen({super.key});

  @override
  State<FarmerBottomScreen> createState() => _FarmerBottomScreenState();
}

class _FarmerBottomScreenState extends State<FarmerBottomScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const FarmerHome(),
      const MessagePage(),
      const CustomerRequests(),
      const EarningsDashboard(),
      const Profile(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromRGBO(102, 255, 0, 1),
        unselectedItemColor: const Color.fromRGBO(149, 149, 149, 1),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.messenger), label: 'Message'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Earnings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
