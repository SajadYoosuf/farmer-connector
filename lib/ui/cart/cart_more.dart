import 'package:flutter/material.dart';

Widget CartHeader(context) {
  return Container(
    height: 150,
    color: Color.fromRGBO(154, 238, 86, 1),
    child: SafeArea(
      bottom: false,
      child: Column(
        children: [
          ///appbar section
      Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 35),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(232, 236, 244, 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    icon: Icon(
                      Icons.chevron_left,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(30, 35, 44, 1),
                    ),
                  ),
                ),
                Text(
                  'Your basket',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                Icon(Icons.share),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}