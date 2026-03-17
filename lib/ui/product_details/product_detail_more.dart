import 'package:flutter/material.dart';

///product details
// ── Top green header with images ──
Widget ProductDetailsHeader(context) {
  return Container(
    height: 150,
    color: Color.fromRGBO(154, 238, 86, 1),
    child: SafeArea(
      bottom: false,
      child: Column(
        children: [
          //appbar section
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
                  'Product Details',
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

/// product name and favourite button
Widget BuildTitleSection() {
  return Column(
    children: [
      /// PRODUCT IMAGE
      Container(
        margin: const EdgeInsets.all(16),
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: const DecorationImage(
            image: AssetImage("assets/images/apple.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),

      ///product info
      Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ///product info
                  Text(
                    'Organic fuji Apples',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Color.fromRGBO(255, 255, 255, 1),
                      border: Border.all(
                        width: 1.0,
                        color: Color.fromRGBO(0, 0, 0, 0.2),
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.favorite, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Text(
              "\$12.50/kg",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Color.fromRGBO(15, 87, 0, 1),
              ),
            ),
            SizedBox(height: 10),

            ///descripition product
            Text(
              'Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color.fromRGBO(0, 0, 0, 1),
              ),
            ),
            Text(
              'Apple stands out because its products work smoothly together, creating an integrated ecosystem. The brand also emphasizes simplicity, user-friendly interfaces, and stylish hardware.',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color.fromRGBO(0, 0, 0, 0.64),
              ),
            ),
            SizedBox(height: 25),
            FeatureCard(
              Icons.eco,
              "100% Organic Certified",
              "No synthetic pesticides used",
            ),
            SizedBox(height: 10),
            FeatureCard(
              Icons.local_shipping,
              "Farm to Door Delivery",
              "No synthetic pesticides used",
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    ],
  );
}

///feature card
Widget FeatureCard(icon, title, subtitle) {
  return Padding(
    padding: const EdgeInsets.only(left: 15, right: 15),
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(width: 0.1, color: Color.fromRGBO(0, 0, 0, 0.7)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Color.fromRGBO(200, 245, 200, 0.51),
            child: Icon(icon, color: Color.fromRGBO(15, 87, 0, 1)),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
