///---------Green Header------------------------------//

import 'package:customer_app/ui/product_details/product_details.dart';
import 'package:flutter/material.dart';

Widget BuildHeader() {
  return Container(height: 190,
    color: Color.fromRGBO(154, 238, 86, 1),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 25, color: Color.fromRGBO(0, 0, 0, 1)),
                SizedBox(width: 3),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delivering to',
                        style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w400)),
                    Row(
                      children: [
                        Text('Calicut',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color.fromRGBO(0, 0, 0, 1))),
                        Icon(Icons.keyboard_arrow_down, size: 18, fontWeight: FontWeight.w600,),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Color.fromRGBO(15, 87, 0, 1), shape: BoxShape.circle),
                  child: Icon(Icons.notifications, color: Colors.white, size: 20),
                ),
                SizedBox(width: 8),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    border: Border.all(color: Color.fromRGBO(15, 87, 0, 1), width: 3),
                  ),
                  // child: Icon(Icons.person, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 48,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  SizedBox(width: 12),
                  Icon(Icons.search, color: Color.fromRGBO(0, 0, 0, 0.5), fontWeight: FontWeight.w800,),
                  SizedBox(width: 8),
                  Text('Search across all categories...',
                      style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5), fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

///-----------------------------------shop by category--------------------------->>

class CategoryBanner extends StatefulWidget {
  const CategoryBanner({super.key});

  @override
  State<CategoryBanner> createState() => _CategoryBannerState();
}

class _CategoryBannerState extends State<CategoryBanner> {
  @override
  Widget build(BuildContext context) {
    return  Container(
      child: Column(
        children: [
          SizedBox(height: 15,),
          Padding(
            padding:  EdgeInsets.only(right: 230),
            child: Text('Shop by Category', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Color.fromRGBO(0, 0, 0, 1)),),
          ),
         SizedBox(height: 15,),

          categoryCard(
                title: 'Fruits',
                subtitle: 'Vibrant seasonal berries',
                image: "assets/images/fruits_banner.png",
            ),
        

          ///--------------Row 1------------------------>>
          SizedBox(height: 15,),
          Padding(
            padding:  EdgeInsets.only(left: 8, right: 8),
            child: Row(
              children: [
                Expanded(
                  child: categoryCard(
                    title: "Vegetables",
                    subtitle: "Crisp garden greens",
                    image: "assets/images/vegetables.png",
                  ),
                ),
                Expanded(
                  child: categoryCard(
                    title: "Meat",
                    subtitle: "Farm fresh cuts",
                    image: "assets/images/meat.png",
                  ),
                ),
              ],
            ),
          ),
          ///----------------------------Row 2----------------------------------->>
          SizedBox(height: 15,),
          Padding(
            padding:  EdgeInsets.only(left: 8, right: 8),
            child: Row(
              children: [
                Expanded(
                  child: categoryCard(
                    title: "Homemade",
                    subtitle: "Local honey & jams",
                    image: "assets/images/homemade_honey.png",
                  ),
                ),
                Expanded(
                  child: categoryCard(
                    title: "Dairy",
                    subtitle: "Fresh milk & cheese",
                    image: "assets/images/dairy.png",
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

Widget categoryCard({
  required String title,
  required String subtitle,
  required String image,
  double height = 160,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 12, right: 12),
    child: Container(
      width: double.infinity, // makes the card take full width
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color.fromRGBO(255, 255, 225, 1),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color.fromRGBO(255, 255, 225, 1),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

///--------------------------------------trending now------------------------------------------------------>>

class TrendingSection extends StatefulWidget {
  const TrendingSection({super.key});

  @override
  State<TrendingSection> createState() => _TrendingSectionState();
}

class _TrendingSectionState extends State<TrendingSection> {

  @override
  Widget build(BuildContext context) {
    return  Container(
      child: Column(
        children: [
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(right:250),
            child: Text('Trending Now', style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color.fromRGBO(0, 0, 0, 1),
            ),),
          ),
          SizedBox(height: 15,),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetails()));
                },
                child: Container(
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1.0,
                      color: Color.fromRGBO(0, 0, 0, 0.13),
                    ),
                  ),
                  child: Row(
                    children: [
                      ///product image
                      Container(
                        height: 100,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                            child: Image.asset('assets/images/apple.png', fit: BoxFit.cover,), ),
                      ),
                      SizedBox(width: 12,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Apple', style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color.fromRGBO(0, 0, 0, 1),
                            ),),
                            SizedBox(height: 3,),
                            Text(
                              'Sunny Hill farm',
                              style: TextStyle(
                                color: Color.fromRGBO(138, 138, 138, 1),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),

                            const SizedBox(height: 3),
                            Text(
                              '\$11.00',
                              style: const TextStyle(
                                color: Color.fromRGBO(101, 255, 84, 1),
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      /// add bottons
                      Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(15, 87, 0, 1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 28,
                        ),
                      )

                    ],
                  ),
                ),
              ),
            );}
          )
        ],
      ),

    );
  }
}



