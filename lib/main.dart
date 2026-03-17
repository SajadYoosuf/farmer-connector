import 'package:customer_app/ui/bott_navbar/bott_naav.dart';
import 'package:customer_app/ui/home/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  BottomScreen(),
    );
  }
}



