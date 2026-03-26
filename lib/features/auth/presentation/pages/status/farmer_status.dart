import 'package:flutter/material.dart';

class FarmerStatusScreen extends StatelessWidget {
  final String status; // 'pending' or 'declined'
  final VoidCallback onSignOut;

  const FarmerStatusScreen({
    super.key, 
    required this.status,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'pending';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: (isPending ? Colors.orange : Colors.red).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPending ? Icons.hourglass_empty : Icons.error_outline,
                size: 80,
                color: isPending ? Colors.orange : Colors.red,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              isPending ? "Account Pending Approval" : "Account Declined",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              isPending 
                ? "Your farmer registration is currently being reviewed by our administration team. This usually takes 24-48 hours. Please check back later."
                : "We regret to inform you that your registration failed our verification process. Please contact support for more details.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: onSignOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(15, 87, 0, 1),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Log Out", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
