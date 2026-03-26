import 'package:customer_app/core/widgets/common_widget.dart';
import 'package:customer_app/features/settings/presentation/pages/settings/settings_more.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CommonAppBar(title: 'Profile'),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // PROFILE IMAGE + EDIT ICON
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        //color: Colors.green.shade100,
                        color: Color.fromRGBO(205, 242, 178, 1),
                      ),
                      child: const CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage(
                          'assets/admin_images/profile_img.png',
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        //shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Text(
                  context
                          .read<AuthProvider>()
                          .currentUser
                          ?.email
                          .split('@')
                          .first ??
                      "Admin",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(15, 87, 0, 1),
                  ),
                ),
                const SizedBox(height: 20),

                // MENU CONTAINER
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      menuTile(Icons.notifications_outlined, "Notifications"),
                      menuDivider(),
                      menuTile(
                        Icons.logout,
                        "Log Out",
                        iconColor: Color.fromRGBO(156, 229, 101, 1),
                        onTap: () async {
                          await context.read<AuthProvider>().signOut();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
