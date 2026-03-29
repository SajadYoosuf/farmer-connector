import 'package:customer_app/screens/admin_analytics/Analytics/analytics.dart';
import 'package:customer_app/screens/admin_farmers/farmer/farmer.dart';
import 'package:customer_app/screens/admin_dashboard/home/home.dart';
import 'package:customer_app/screens/settings/settings/settings.dart';
import 'package:customer_app/screens/admin_users/users/users.dart';
import 'package:flutter/material.dart';

class BottomScreen extends StatefulWidget {
  const BottomScreen({super.key});

  @override
  State<BottomScreen> createState() => _BottomScreenState();
}

class _BottomScreenState extends State<BottomScreen> {
  List<Widget>screens=[
    AdminDashboard(), Users(),Farmer(),Analytics(),Settings(),

  ];
  int current_index = 0;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: screens[current_index],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: current_index,
          onTap: (index) {
            setState(() {
              current_index = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          selectedItemColor: const Color.fromRGBO(15, 87, 0, 1),
          unselectedItemColor: const Color.fromRGBO(149, 149, 149, 1),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            color: Color.fromRGBO(15, 87, 0, 1),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), activeIcon: Icon(Icons.people_alt), label: 'Users'),
            BottomNavigationBarItem(icon: Icon(Icons.agriculture_outlined), activeIcon: Icon(Icons.agriculture_rounded), label: 'Farmer'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Analytics'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Settings'),
          ],
        ),
    );
  }
}
