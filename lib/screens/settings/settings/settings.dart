import 'package:customer_app/widgets/common_widget.dart';
import 'package:customer_app/screens/settings/settings/settings_more.dart';
import 'package:customer_app/screens/admin_support/support/support_chat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/providers/auth_provider.dart';

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
          SafeArea(
            child: CommonAppBar(
              title: 'Profile',
              showBack: false,
              // showAdminActions: true,
              showNotification: false,
            ),
          ),
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
                        child: Icon(Icons.add_moderator_outlined),
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
                      menuTile(
                        Icons.support_agent,
                        "Users & Farmer Support",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AdminSupportChatPage(),
                            ),
                          );
                        },
                      ),
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
