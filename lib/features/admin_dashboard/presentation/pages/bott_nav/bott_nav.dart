import 'package:customer_app/features/admin_analytics/presentation/pages/Analytics/analytics.dart';
import 'package:customer_app/features/admin_farmers/presentation/pages/farmer/farmer.dart';
import 'package:customer_app/features/admin_dashboard/presentation/pages/home/home.dart';
import 'package:customer_app/features/settings/presentation/pages/settings/settings.dart';
import 'package:customer_app/features/admin_users/presentation/pages/users/users.dart';
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
          onTap: (num){
            print("current index$num");
            current_index=num;
            setState(() {
            });
          },
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          selectedItemColor: Color.fromRGBO(15, 87, 0, 1),
          unselectedItemColor: Color.fromRGBO(149, 149, 149, 1),
          selectedLabelStyle: TextStyle(
            color: Color.fromRGBO(15, 87, 0, 1),
          ),
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home),label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt),label: 'Users'),
            BottomNavigationBarItem(icon: Icon(Icons.agriculture_rounded),label: 'Farmer'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics),label: 'Analytics'),
            BottomNavigationBarItem(icon: Icon(Icons.person),label: 'Settings'),
          ],)
    );
  }
}
