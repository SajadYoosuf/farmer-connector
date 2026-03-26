import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:customer_app/features/auth/presentation/pages/farmer_verification/farmer_verification.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController wardController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void _generatePassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%&*';
    final random = Random();
    final password = String.fromCharCodes(
      Iterable.generate(
        12,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
    setState(() {
      passwordController.text = password;
      confirmPasswordController.text = password;
      isPasswordVisible = true;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Strong password generated!")));
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
      return 'Please enter a valid email';
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) return 'Please enter mobile number';
    if (!RegExp(r'^\d{10}$').hasMatch(value))
      return 'Please enter 10 digit number';
    return null;
  }

  String? _validatePincode(String? value) {
    if (value == null || value.isEmpty) return 'Please enter pincode';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'Please enter 6 digit code';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromRGBO(154, 240, 85, 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create account",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(15, 87, 0, 1),
                  ),
                ),
                Text(
                  "Fill in all details to get started",
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
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        _buildFieldLabel("Full names"),
                        TextFormField(
                          controller: nameController,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                          decoration: _inputDecoration("Maya kk"),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel("Enter Mobile (10 digits)"),
                        TextFormField(
                          controller: mobileController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: _validateMobile,
                          decoration: _inputDecoration(
                            "9874563210",
                            prefix: "+91 ",
                          ).copyWith(counterText: ""),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel("Email Address"),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                          decoration: _inputDecoration("mayakk@gmail.com"),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel("Place"),
                                  TextFormField(
                                    controller: placeController,
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Required'
                                        : null,
                                    decoration: _inputDecoration("Calicut"),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel("Ward"),
                                  TextFormField(
                                    controller: wardController,
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Required'
                                        : null,
                                    decoration: _inputDecoration("5"),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel("Pincode"),
                        TextFormField(
                          controller: pincodeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          validator: _validatePincode,
                          decoration: _inputDecoration("673005"),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel("Password"),
                        TextFormField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          validator: (v) => (v == null || v.length < 6)
                              ? 'Password must be 6+ characters'
                              : null,
                          decoration: _passwordDecoration(
                            isPasswordVisible,
                            () => setState(
                              () => isPasswordVisible = !isPasswordVisible,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _generatePassword,
                            icon: const Icon(
                              Icons.auto_fix_high_rounded,
                              size: 18,
                              color: Colors.blue,
                            ),
                            label: const Text(
                              "Generate Strong Password",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel("Confirm Password"),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: !isConfirmPasswordVisible,
                          validator: (v) => (v != passwordController.text)
                              ? 'Passwords do not match'
                              : null,
                          decoration: _passwordDecoration(
                            isConfirmPasswordVisible,
                            () => setState(
                              () => isConfirmPasswordVisible =
                                  !isConfirmPasswordVisible,
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(
                                15,
                                87,
                                0,
                                1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: auth.isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      final extraData = {
                                        'fullName': nameController.text,
                                        'mobile': '+91${mobileController.text}',
                                        'place': placeController.text,
                                        'ward': wardController.text,
                                        'pincode': pincodeController.text,
                                      };
                                      final error = await auth.signUp(
                                        emailController.text,
                                        passwordController.text,
                                        auth.selectedRole,
                                        extraData: extraData,
                                      );

                                      if (error == null && context.mounted) {
                                        if (auth.selectedRole == 'farmer') {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const FarmerVerification(),
                                            ),
                                          );
                                        } else {
                                          Navigator.popUntil(
                                            context,
                                            (r) => r.isFirst,
                                          );
                                        }
                                      } else if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $error'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            child: auth.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "REGISTER",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: RichText(
                              text: const TextSpan(
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
                                      fontWeight: FontWeight.w700,
                                      color: Color.fromRGBO(26, 36, 60, 1),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: Color.fromRGBO(165, 165, 165, 1),
          fontWeight: FontWeight.w400,
          fontSize: 13,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? prefix}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      hintStyle: const TextStyle(
        color: Color.fromRGBO(180, 180, 180, 0.7),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black12),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black12),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color.fromRGBO(15, 87, 0, 1), width: 2),
      ),
    );
  }

  InputDecoration _passwordDecoration(bool visible, VoidCallback onToggle) {
    return _inputDecoration("******").copyWith(
      suffixIcon: IconButton(
        icon: Icon(
          visible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          color: const Color.fromRGBO(198, 203, 212, 1),
        ),
        onPressed: onToggle,
      ),
    );
  }
}
