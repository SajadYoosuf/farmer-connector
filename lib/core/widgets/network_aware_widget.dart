import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/core/providers/network_provider.dart';

/// Wraps any page/widget with an animated offline banner.
/// When online → no banner shown, content is fully interactive.
/// When offline → a premium animated banner slides down from the top.
class NetworkAwarePage extends StatelessWidget {
  final Widget child;
  const NetworkAwarePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<NetworkProvider>().isOnline;

    return Stack(
      children: [
        child,
        // Offline Banner — animated slide in/out
        AnimatedPositioned(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          top: isOnline ? -80 : 0,
          left: 0,
          right: 0,
          child: _OfflineBanner(isOnline: isOnline),
        ),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final bool isOnline;
  const _OfflineBanner({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isOnline ? const Color(0xff0F5700) : const Color(0xffB71C1C),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOnline ? Icons.wifi : Icons.wifi_off_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              isOnline ? 'Back online!' : 'No internet connection',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a full-screen offline placeholder.
/// Use inside StreamBuilder or FutureBuilder when data cannot load.
class OfflinePlaceholder extends StatelessWidget {
  final VoidCallback? onRetry;
  const OfflinePlaceholder({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded, size: 60, color: Colors.red.shade300),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Internet Connection',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              'Please check your network settings\nand try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14, height: 1.5),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text('Try Again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0F5700),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
