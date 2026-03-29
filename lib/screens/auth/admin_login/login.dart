import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/providers/auth_provider.dart';
import 'package:customer_app/screens/auth/forgot_password/forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool obscure = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),

      body: Stack(
        children: [
          /// TOP CIRCLE
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              height: 250,
              width: 250,
              decoration: const BoxDecoration(
                color: Color(0xffA6EB7A),
                shape: BoxShape.circle,
              ),
            ),
          ),

          /// BOTTOM CIRCLE
          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              height: 300,
              width: 300,
              decoration: const BoxDecoration(
                color: Color(0xffA6EB7A),
                shape: BoxShape.circle,
              ),
            ),
          ),

          /// MAIN CONTENT
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 200),

                const Center(
                  child: Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(0, 0, 0, 1)
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    "Enter your admin credentials to manage services",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(0, 0, 0, 0.56),
                        fontSize: 14
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // EMAIL LABEL
                const Text(
                  "Email Address",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(0, 0, 0, 1),
                  ),
                ),
                const SizedBox(height: 8),

                // EMAIL INPUT
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      width: 1.0,
                      color: Color.fromRGBO(202, 216,229, 1),
                    )
                  ),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: "admin@seniorcare.com",
                      helperStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Color.fromRGBO(0, 0, 0, 0.6),
                      )
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Password",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(0, 0, 0, 1),
                  ),
                ),

                const SizedBox(height: 8),

                // PASSWORD INPUT
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        width: 1.0,
                        color: Color.fromRGBO(202, 216,229, 1),
                      )
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        ),
                        onPressed: () {
                          setState(() {
                            obscure = !obscure;
                          });
                        },
                      ),
                      hintText: "●●●●●●●●●●", hintStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPassword(),
                        ),
                      );
                    },
                    child: const Text(
                      "Forgot Password ?",
                      style: TextStyle(color: Color.fromRGBO(15, 87, 0, 1),
                      fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(15, 87, 0, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      final success = await context.read<AuthProvider>().signIn(emailController.text, passwordController.text, expectedRole: 'admin');
                      if (success && context.mounted) {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Access Denied. Ensure you have Admin privileges.')));
                      }
                    },
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        if (auth.isLoading) {
                          return const CircularProgressIndicator(color: Colors.white);
                        }
                        return const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
