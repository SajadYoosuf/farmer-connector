import 'package:flutter/material.dart';
// -------------------- REUSABLE MENU TILE --------------------
Widget menuTile(IconData icon, String title,
    { Color iconColor = const Color.fromRGBO(156, 229, 101, 1),
      VoidCallback? onTap,
    }) {
  return ListTile(
    leading: Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Icon(icon, color: iconColor),
    ),
    // >>> THIS ADDS SPACE BETWEEN ICON & TEXT <<<
    horizontalTitleGap: 45,
    title: Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Color.fromRGBO(15, 87, 0, 1))),
    trailing: const Icon(Icons.chevron_right, color: Color.fromRGBO(15, 87, 0, 1),),
    onTap: onTap ?? () {},
  );
}

// -------------------- THIN DIVIDER --------------------
Widget menuDivider() {
  return Divider(
    color: Color.fromRGBO(136, 136, 136, 0.23),
    height: 1,
    thickness: 1,
    indent: 15,
    endIndent: 15,
  );
}


