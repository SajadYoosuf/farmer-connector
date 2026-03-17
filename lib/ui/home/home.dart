import 'package:customer_app/ui/home/common_widgets.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            BuildHeader(),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryBanner(),
                  SizedBox(
                    height: 10,
                  ),
                  TrendingSection(),
                ],
              ),
            )
        
          ],
        ),
      ),

    );
  }
}
