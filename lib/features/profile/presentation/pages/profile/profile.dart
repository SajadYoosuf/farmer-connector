import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<Profile> {
  Widget buildMenuItem(IconData icon, String title, {VoidCallback? onTap, Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? const Color.fromRGBO(15, 87, 0, 1)),
            const SizedBox(width: 30),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final name = user?.fullName ?? user?.email ?? 'Unknown User';
    final role = user?.role ?? 'user';
    final place = (user?.role == 'farmer') ? (user?.extraData?['place'] ?? 'Unknown Location') : 'Calicut, Kerala';

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Profile & settings",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── PROFILE HEADER ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              color: Colors.white,
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.green.shade50,
                        child: Text(
                          name[0].toUpperCase(),
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(15, 87, 0, 1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromRGBO(15, 87, 0, 1)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Verified ${role == 'farmer' ? 'Farmer' : 'Member'} since 2026",
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color.fromRGBO(15, 87, 0, 1)),
                      const SizedBox(width: 4),
                      Text(place, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── MENU LIST ───
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  // ADMIN gets fewer options as per user request
                  if (role != 'admin') ...[
                    buildMenuItem(Icons.person_outline, "Edit Profile"),
                    buildMenuItem(Icons.notifications_none, "Notifications"),
                    buildMenuItem(Icons.settings_outlined, "Settings"),
                    buildMenuItem(Icons.help_outline, "Help and Support"),
                  ] else ...[
                    buildMenuItem(Icons.notifications_none, "System Notifications"),
                    buildMenuItem(Icons.admin_panel_settings_outlined, "Manage Users"),
                  ],
                  
                  buildMenuItem(
                    Icons.logout,
                    "Log Out",
                    color: Colors.redAccent,
                    onTap: () async {
                      await authProvider.signOut();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
