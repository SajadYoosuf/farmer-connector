import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FarmerStatusScreen extends StatefulWidget {
  final String status; // 'pending' or 'declined'
  final VoidCallback onSignOut;

  const FarmerStatusScreen({
    super.key, 
    required this.status,
    required this.onSignOut,
  });

  @override
  State<FarmerStatusScreen> createState() => _FarmerStatusScreenState();
}

class _FarmerStatusScreenState extends State<FarmerStatusScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPending = widget.status == 'pending';
    
    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 255, 241, 1),
      body: Stack(
        children: [
          // Dynamic background particles/shapes (animated)
          Positioned(
            top: -50,
            right: -50,
            child: FadeTransition(
              opacity: _controller,
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: (isPending ? Colors.orange : Colors.red).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // Big Animated Icon or Lottie
                  Center(
                    child: Container(
                      height: 280,
                      width: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: (isPending ? Colors.orange : Colors.red).withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 10,
                          )
                        ]
                      ),
                      child: isPending 
                        ? Lottie.network(
                            'https://assets9.lottiefiles.com/packages/lf20_st7u96.json', // Waiting animation
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.hourglass_bottom_rounded,
                              size: 150,
                              color: Colors.orange[400],
                            ),
                          )
                        : Lottie.network(
                            'https://assets1.lottiefiles.com/packages/lf20_TkwX6p.json', // Error/Declined animation
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.cancel_rounded,
                              size: 150,
                              color: Colors.red[400],
                            ),
                          ),
                    ),
                  ),

                  const SizedBox(height: 50),
                  
                  // Text Content with Fade and Slide
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0, end: 1),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          isPending ? "Verification in Progress" : "Account Declined",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: isPending ? const Color(0xffE67E22) : Colors.red[700],
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isPending 
                            ? "We've received your documents! Our team is currently reviewing your profile to ensure the best experience for everyone."
                            : "Unfortunately, your verification was not successful. Please reach out to our support team for clarification.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17, 
                            color: Colors.black.withOpacity(0.6),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(flex: 3),
                  
                  // Modern Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(15, 87, 0, 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ]
                    ),
                    child: ElevatedButton(
                      onPressed: widget.onSignOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(15, 87, 0, 1),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 65),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded),
                          SizedBox(width: 12),
                          Text(
                            "Logout and Exit",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
