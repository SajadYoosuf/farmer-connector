import 'dart:async';
import 'package:flutter/material.dart';
import 'package:customer_app/main.dart'; // To navigate to AuthWrapper

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ─── BACKGROUND GRADIENT ───
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFA9F251), // Vibrant light green
                  Color(0xFF86D52E), // Fresh green
                ],
              ),
            ),
          ),

          // ─── CLOUDS ───
          Positioned(top: 100, left: 40, child: _buildCloud(size: 0.8)),
          Positioned(top: 150, right: -20, child: _buildCloud(size: 1.2)),
          Positioned(top: 300, right: 40, child: _buildCloud(size: 0.7)),
          Positioned(top: 450, left: -10, child: _buildCloud(size: 0.6)),

          // ─── GROUND & TREES (Bottom Layer) ───
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 400,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Ground Wave 1
                  Positioned(
                    bottom: -50,
                    left: -50,
                    right: -50,
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6EBD1A).withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Ground Wave 2
                  Positioned(
                    bottom: -80,
                    left: -100,
                    child: Container(
                      height: 300,
                      width: 500,
                      decoration: const BoxDecoration(
                        color: Color(0xFF5CA314),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Sky Dome (Light Blue behind trees)
                  Positioned(
                    bottom: 120,
                    child: Container(
                      height: 300,
                      width: 600,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB3E5FC).withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Trees
                  const Positioned(
                    bottom: 60,
                    left: 20,
                    child: _TreeWidget(size: 1.1),
                  ),
                  const Positioned(
                    bottom: 80,
                    left: 100,
                    child: _TreeWidget(size: 0.6),
                  ),
                  const Positioned(
                    bottom: 70,
                    right: 40,
                    child: _TreeWidget(size: 1.3),
                  ),
                  const Positioned(
                    bottom: 100,
                    right: 120,
                    child: _TreeWidget(size: 0.5),
                  ),
                  const Positioned(
                    bottom: 40,
                    left: 180,
                    child: _TreeWidget(size: 0.8),
                  ),

                  // Foreground Grass Layer
                  Positioned(
                    bottom: -20,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B6B00),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.elliptical(300, 50),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── CENTER LOGO / TEXT ───
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: const Text(
                  "Farmer Connector",
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E4614), // Deep forest green
                    letterSpacing: -1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloud({double size = 1.0}) {
    return Transform.scale(
      scale: size,
      child: Stack(
        children: [
          Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Positioned(
            top: -15,
            left: 15,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -5,
            left: 35,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TreeWidget extends StatelessWidget {
  final double size;
  const _TreeWidget({this.size = 1.0});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Leaves
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF8BC34A),
                  shape: BoxShape.circle,
                ),
              ),
              Positioned(
                top: 0,
                left: 5,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9CCC65),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 5,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7CB342),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFF689F38),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          // Trunk
          Container(
            width: 15,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF5D4037),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
            ),
          ),
        ],
      ),
    );
  }
}
