import 'package:flutter/material.dart';


///-----------------------------------------common appbar-------------------------------------------------->>

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final bool showNotification;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.showNotification = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// ---------- BACK BUTTON ----------
                showBack
                    ? Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xfff3f4f6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.black, size: 22),
                    ),
                  ),
                )
                    : const SizedBox(width: 40),

                /// ---------- TITLE ----------
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                /// ---------- NOTIFICATION BUTTON ----------
                showNotification
                    ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xfff3f4f6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications,
                        color: Colors.black),
                  ),
                )
                    : const SizedBox(width: 40),
              ],
            ),
          ),

          /// ---------- DIVIDER ----------
          Container(height: 1, color: const Color(0xffe6e6e6)),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}



///<<<<<<<<<<======================================================================================================>>>
/// ----------------------------------card listview-----------------------------------------
class UserCard extends StatelessWidget {
  final String name;
  final String location;
  final String image;
  final String status;
  final double amount;
  final VoidCallback onTap;

  const UserCard({
    super.key,
    required this.name,
    required this.location,
    required this.image,
    required this.status,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: SizedBox(
          height: 550,
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    width: 1.0,
                    color: Color.fromRGBO(0, 0, 0, 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage(image),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Color.fromRGBO(77, 77, 77, 1),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                location,
                                style: TextStyle(
                                  color: Color.fromRGBO(0, 0, 0, 0.7),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹ ${amount.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(15, 87, 0, 1),
                      ),
                    ),
                    SizedBox(width: 5),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Color.fromRGBO(15, 87, 0, 1),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
///<<<<<<<<<<=======================================================================================>>>
///---------------------Filter button-----------------------------

// class FilterButtons extends StatefulWidget {
//   const FilterButtons({super.key});
//
//   @override
//   State<FilterButtons> createState() => _FilterButtonsState();
// }
//
// class _FilterButtonsState extends State<FilterButtons> {
//   bool isAll = true;
//   bool isStatus = false;
//   bool isLocation = false;
//   bool isActive = false;
//
//   void select(String type) {
//     setState(() {
//       isAll = type == "all";
//       isStatus = type == "status";
//       isLocation = type == "location";
//       isActive = type == "active";
//     });
//   }
//
//   Widget buildButton(String text, bool selected, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         decoration: BoxDecoration(
//           color: selected
//               ? Color.fromRGBO(156, 229, 101, 1)
//               : Color.fromRGBO(237, 237, 237, 1),
//           borderRadius: BorderRadius.circular(30),
//           border: Border.all(width: 1, color: Color.fromRGBO(92, 92, 92, 0.1)),
//           boxShadow: selected
//               ? [
//             BoxShadow(
//               color: Colors.green.withOpacity(0.4),
//               spreadRadius: 2,
//               blurRadius: 10,
//               offset: const Offset(0, 3),
//             ),
//           ]
//               : [],
//         ),
//         child: Text(
//           text,
//           style: TextStyle(
//             color: selected
//                 ? Color.fromRGBO(255, 255, 255, 1)
//                 : Color.fromRGBO(0, 0, 0, 1),
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 20),
//       child: Row(
//         children: [
//           buildButton("All", isAll, () => select("all")),
//           const SizedBox(width: 10),
//           buildButton("Status", isStatus, () => select("status")),
//           const SizedBox(width: 10),
//           buildButton("Location", isLocation, () => select("location")),
//           const SizedBox(width: 10),
//           buildButton("Active", isActive, () => select("active")),
//         ],
//       ),
//     );
//   }
// }
class FilterButtons extends StatefulWidget {
  const FilterButtons({super.key});

  @override
  State<FilterButtons> createState() => _FilterButtonsState();
}

class _FilterButtonsState extends State<FilterButtons> {
  String selectedType = "all";

  // Instead of a list, we define a simple inline map
  final Map<String, String> filterItems = {
    "all": "All",
    "status": "Status",
    "location": "Location",
    "active": "Active",
    "deactive" : "Deactive"
  };

  void select(String type) {
    setState(() => selectedType = type);
  }

  Widget buildButton(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? Color.fromRGBO(156, 229, 101, 1)
              : Color.fromRGBO(237, 237, 237, 1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(width: 1, color: Color.fromRGBO(92, 92, 92, 0.1)),
          boxShadow: selected
              ? [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected
                ? Color.fromRGBO(255, 255, 255, 1)
                : Color.fromRGBO(0, 0, 0, 1),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50, // needed for ListView horizontal
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: filterItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          String key = filterItems.keys.elementAt(index);
          String label = filterItems.values.elementAt(index);

          return buildButton(
            label,
            selectedType == key,
                () => select(key),
          );
        },
      ),
    );
  }
}
///====================================================================================================>
///--------------------------------------------------SearchBar--------------------------------------------->>
Widget SearchBarContainer() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: TextField(
      decoration: InputDecoration(
        hintText: "Search by name or email...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color.fromRGBO(29, 29, 29, 0.1), // Border color
            width: 0.1, // Border width
          ),
        ),
      ),
    ),
  );
}
