import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:customer_app/features/auth/presentation/pages/farmer_login/login.dart';
import 'package:customer_app/features/auth/presentation/pages/farmer_verification/farmer_verification.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromRGBO(154, 240, 85, 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),

          // Top Image
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              'assets/images/login_img.png', // add your image here
              height: 200,
            ),
          ),

          const SizedBox(height: 10),

          // Title
          const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create profile",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(15, 87, 0, 1),
                  ),
                ),
                Text(
                  "create a unique username",
                  style: TextStyle(
                    color: Color.fromRGBO(15, 87, 0, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // White Container
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(50),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        "Enter username",
                        style: TextStyle(
                            color: Color.fromRGBO(165, 165, 165, 1),
                            fontWeight: FontWeight.w400,
                            fontSize: 12),
                      ),
                      const TextField(
                        decoration: InputDecoration(
                          hintText: "Mayakk1122",
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(50, 54, 67, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Password",
                        style: TextStyle(
                            color: Color.fromRGBO(165, 165, 165, 1),
                            fontWeight: FontWeight.w400,
                            fontSize: 12),
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: "******",
                          hintStyle: const TextStyle(
                            color: Color.fromRGBO(50, 54, 67, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: const UnderlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: const Color.fromRGBO(198, 203, 212, 1),
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Confirm Password",
                        style: TextStyle(
                            color: Color.fromRGBO(165, 165, 165, 1),
                            fontWeight: FontWeight.w400,
                            fontSize: 12),
                      ),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: !isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          hintText: "******",
                          hintStyle: const TextStyle(
                            color: Color.fromRGBO(50, 54, 67, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: const UnderlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isConfirmPasswordVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: const Color.fromRGBO(198, 203, 212, 1),
                            ),
                            onPressed: () {
                              setState(() {
                                isConfirmPasswordVisible =
                                    !isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(15, 87, 0, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            if (passwordController.text ==
                                confirmPasswordController.text) {
                              final auth = context.read<AuthProvider>();
                              final error = await auth.signUp(auth.signupEmail,
                                  passwordController.text, auth.selectedRole);
                              if (error == null && context.mounted) {
                                if (auth.selectedRole == 'farmer') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const FarmerVerification()),
                                  );
                                } else {
                                  Navigator.popUntil(context, (r) => r.isFirst);
                                }
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Signup Failed: $error')));
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Passwords do not match')));
                            }
                          },
                          child: Consumer<AuthProvider>(
                            builder: (context, auth, child) {
                              if (auth.isLoading) {
                                return const CircularProgressIndicator(
                                    color: Colors.white);
                              }
                              return const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "SIGN UP",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.arrow_forward, color: Colors.white),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Register
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Login()),
                                (route) => false);
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Color.fromRGBO(50, 54, 67, 1),
                              ),
                              children: [
                                TextSpan(
                                  text: "Sign In",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(26, 36, 60, 1),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
