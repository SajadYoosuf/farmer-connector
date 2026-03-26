import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/features/profile/presentation/pages/profile/edit_profile.dart';
import 'package:customer_app/features/profile/presentation/pages/support/farmer_support_chat.dart';
import 'package:customer_app/features/profile/presentation/pages/profile/my_orders_page.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<Profile> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Profile Photo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(Icons.camera_alt, "Camera", ImageSource.camera),
                _buildPickerOption(Icons.photo_library, "Gallery", ImageSource.gallery),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption(IconData icon, String label, ImageSource source) {
    return Column(
      children: [
        IconButton(
          onPressed: () async {
            Navigator.pop(context);
            final XFile? image = await _picker.pickImage(source: source);
            if (image != null) {
              _updateProfileImage(image.path);
            }
          },
          icon: Icon(icon, color: const Color.fromRGBO(15, 87, 0, 1), size: 32),
        ),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Future<void> _updateProfileImage(String path) async {
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'profileImage': path, // Realistically would upload to Firebase Storage
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile image updated")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget buildMenuItem(IconData icon, String title, {VoidCallback? onTap, Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? const Color.fromRGBO(15, 87, 0, 1), size: 22),
            const SizedBox(width: 25),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.black26,
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
    final place = user?.extraData?['place'] ?? 'Calicut, Kerala';
    final profileImage = user?.extraData?['profileImage'];

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // No back navigation as per request
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.green.shade50,
                          backgroundImage: profileImage != null 
                            ? (profileImage.startsWith('http') 
                                ? NetworkImage(profileImage) 
                                : FileImage(File(profileImage)) as ImageProvider)
                            : null,
                          child: profileImage == null ? Text(
                            name[0].toUpperCase(),
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                          ) : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(15, 87, 0, 1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${role.toUpperCase()} • Member since 2026",
                    style: const TextStyle(color: Colors.black45, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color.fromRGBO(102, 255, 0, 1)),
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  buildMenuItem(Icons.receipt_long_outlined, "My Orders", onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersPage()));
                  }),
                  buildMenuItem(Icons.person_outline, "Edit Profile", onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
                  }),
                  buildMenuItem(Icons.help_outline, "Help and Support", onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const FarmerSupportChat()));
                  }),
                  
                  buildMenuItem(
                    Icons.logout,
                    "Log Out",
                    color: Colors.redAccent,
                    onTap: () {
                      _showLogoutDialog(context);
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Out?"),
        content: const Text("Are you sure you want to log out of your account?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().signOut();
            },
            child: const Text("Log Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
