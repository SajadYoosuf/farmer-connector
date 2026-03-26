import 'package:customer_app/features/auth/presentation/pages/choose_page/choose_page.dart';
import 'package:customer_app/features/auth/presentation/pages/choose_page/choose_page_more.dart';
import 'package:customer_app/features/auth/presentation/pages/admin_login/login.dart'
    as admin_login;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';

class WelcomeFarmer extends StatefulWidget {
  const WelcomeFarmer({super.key});

  @override
  State<WelcomeFarmer> createState() => _WelcomeFarmerState();
}

class _WelcomeFarmerState extends State<WelcomeFarmer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(153, 242, 81, 1),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/images/welcome_farmer.png'),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to \nHi Farmer',
                    style: TextStyle(
                      color: Color.fromRGBO(15, 87, 0, 1),
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'By good food your self for pesticide free and healthy life',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(15, 87, 0, 1),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChoosePageMore()),
                  );
                },
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(15, 87, 0, 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SIGN IN',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const admin_login.LoginPage(),
                    ),
                  );
                },
                child: Text(
                  'Admin Access',
                  style: TextStyle(
                    color: Color.fromRGBO(15, 87, 0, 1),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
