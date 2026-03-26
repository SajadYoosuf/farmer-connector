import 'package:customer_app/features/auth/presentation/pages/farmer_signup1/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController divisionController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromRGBO(154, 240, 85, 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          // Top Image
          // Align(
          //   alignment: Alignment.topCenter,
          //   child: Image.asset(
          //     'assets/images/login_img.png', // add your image here
          //     height: 200,
          //   ),
          // ),

          const SizedBox(height: 10),
          // Title
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create your account",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(15, 87, 0, 1),
                  ),
                ),
                Text(
                  "Create your account for more details",
                  style: TextStyle(color: Color.fromRGBO(15, 87, 0, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(50),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30,),
                      const Text("Enter full name",
                        style: TextStyle(
                            color: Color.fromRGBO(165, 165, 165, 1),
                            fontWeight: FontWeight.w400,
                            fontSize: 12),
                      ),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: "Maya kk",
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(50, 54, 67, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text("Place name",
                        style: TextStyle(
                            color: Color.fromRGBO(165, 165, 165, 1),
                            fontWeight: FontWeight.w400,
                            fontSize: 12),
                      ),
                      TextField(
                        controller: placeController,
                        decoration: const InputDecoration(
                          hintText: "Calicut",
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(50, 54, 67, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                  
                      const Text("Division",
                        style: TextStyle(
                            color: Color.fromRGBO(165, 165, 165, 1),
                            fontWeight: FontWeight.w400,
                            fontSize: 12),
                      ),
                      TextField(
                        controller: divisionController,
                        decoration: const InputDecoration(
                          hintText: "5",
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(50, 54, 67, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text("Pincode",
                        style: TextStyle(
                            color: Color.fromRGBO(165, 165, 165, 1),
                            fontWeight: FontWeight.w400,
                            fontSize: 12),
                      ),
                      TextField(
                        controller: pincodeController,
                        decoration: const InputDecoration(
                          hintText: "673005",
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(50, 54, 67, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text("Enter Mobile number",
                        style: TextStyle(
                            color: Color.fromRGBO(165, 165, 165, 1),
                            fontWeight: FontWeight.w400,
                            fontSize: 12),
                      ),
                      TextField(
                        controller: mobileController,
                        decoration: const InputDecoration(
                          hintText: "9874563210",
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(50, 54, 67, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text("Enter Email",
                        style: TextStyle(
                            color: Color.fromRGBO(165, 165, 165, 1),
                            fontWeight: FontWeight.w400,
                            fontSize: 12),
                      ),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          hintText: "mayakk@gmail.com",
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(50, 54, 67, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                  
                      const SizedBox(height: 5),

                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(15, 87, 0, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            context.read<AuthProvider>().setSignupExtraData({
                              'fullName': nameController.text,
                              'place': placeController.text,
                              'division': divisionController.text,
                              'pincode': pincodeController.text,
                              'mobile': mobileController.text,
                            });
                            context.read<AuthProvider>().setSignupEmail(emailController.text);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUp()));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Next",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color.fromRGBO(255, 255, 255, 1)),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward, color:  Color.fromRGBO(255, 255, 255, 1),),
                            ],
                          ),
                        ),
                      ),
                  
                      const SizedBox(height: 30),
                  
                      // Register
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            context.read<AuthProvider>().setSignupEmail(emailController.text);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUp()));
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: "Already have an account?", style: TextStyle(fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Color.fromRGBO(50, 54, 67, 1),
                            ),
                              children: [
                                TextSpan(
                                  text: "sign In",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
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
