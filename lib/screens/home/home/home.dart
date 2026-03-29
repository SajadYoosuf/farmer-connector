import 'package:customer_app/screens/home/home/common_widgets.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            BuildHeader(context),
            const CategoryBanner(),
            const SizedBox(height: 10),
            const TrendingSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
