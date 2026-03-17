
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<Profile> {

  Widget buildMenuItem(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Color.fromRGBO(15, 87, 0, 1)),
          const SizedBox(width: 30),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(0, 0, 0, 1)),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: (Color.fromRGBO(0, 0, 0, 1))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      // 🔹 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        elevation: 0,
        leading:
        IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {},
          ),

        centerTitle: true,
        title: const Text(
          "Profile & settings",
          style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1), fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),

      body: Column(
        children: [

          // 🔹 PROFILE HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: Color.fromRGBO(255, 255, 255, 1),
            child: Column(
              children: [

                // Profile Image
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/maya.png',),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(15, 87, 0, 1),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10,), topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          )
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 10),

                const Text(
                  "Maya",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(15, 87, 0, 1),
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Verified member since 2026",
                  style: TextStyle(color: Color.fromRGBO(15, 87, 0, 1), fontSize: 14, fontWeight: FontWeight.w400),
                ),

                const SizedBox(height: 5),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.location_on, size: 16, color: Color.fromRGBO(15, 87, 0, 1)),
                    SizedBox(width: 5),
                    Text("Upper east side , calicut", style: TextStyle(
                      color: Color.fromRGBO(15, 87, 0, 1), fontSize: 14,fontWeight: FontWeight.w400
                    ),),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 MENU LIST
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                buildMenuItem(Icons.person, "Edit Profile"),
                buildMenuItem(Icons.notifications, "Notifications"),
                buildMenuItem(Icons.settings, "Settings"),
                buildMenuItem(Icons.support_agent, "Help and Support"),
                buildMenuItem(Icons.logout, "Log Out"),
              ],
            ),
          )
        ],
      ),


    );
  }
}