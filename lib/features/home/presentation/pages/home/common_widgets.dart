import 'dart:io';
import 'package:customer_app/features/home/presentation/pages/home/category_detail_page.dart';
import 'package:customer_app/features/product_details/presentation/pages/product_details/product_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/home/presentation/providers/product_provider.dart';
import 'package:customer_app/features/cart/presentation/providers/cart_provider.dart';
import 'search_page.dart';

void showSuccessPopup(BuildContext context, String productName, String imageUrl) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                content: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xff0F5700).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xff0F5700),
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Added to Basket',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$productName has been added!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0F5700),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Continue Shopping', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
  // Auto-close after 3 seconds if not dismissed by button
  Future.delayed(const Duration(seconds: 3), () {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  });
}

Widget ProductImage(String path, {BoxFit fit = BoxFit.cover, double? height, double? width}) {
  if (path.isEmpty) {
    return Image.asset('assets/images/apple.png', fit: fit, height: height, width: width);
  }
  if (path.startsWith('http')) {
    return Image.network(path, fit: fit, height: height, width: width,
      errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/apple.png', fit: fit),
    );
  }
  if (path.startsWith('assets/')) {
    return Image.asset(path, fit: fit, height: height, width: width);
  }
  // Handle file path (with or without file:// prefix)
  String cleanPath = path.replaceFirst('file://', '');
  return Image.file(File(cleanPath), fit: fit, height: height, width: width,
    errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/apple.png', fit: fit),
  );
}

void runAddToCartAnimation(BuildContext context, String imageUrl, GlobalKey startKey) {
  final OverlayState overlayState = Overlay.of(context);
  final RenderBox? renderBox = startKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) return;

  final startPosition = renderBox.localToGlobal(Offset.zero);

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCirc,
        onEnd: () {
          entry.remove();
        },
        builder: (context, value, child) {
          // Calculate parabolic path towards the Cart tab (approx 62.5% across the bottom bar)
          double targetX = MediaQuery.of(context).size.width * 0.62;
          double targetY = MediaQuery.of(context).size.height - 50;
          
          double x = startPosition.dx + (targetX - startPosition.dx) * value;
          // Add arc effect
          double y = startPosition.dy + (targetY - startPosition.dy) * value - (100 * (1 - (2 * value - 1).abs()));
          
          // Add a "pop" at the start with elastic feel
          double scale = 1.0;
          if (value < 0.3) {
            scale = 1.0 + (Curves.elasticOut.transform(value * 3.33) * 0.6);
          } else {
            scale = 1.6 - ((value - 0.3) * 1.42 * 1.2); // Shrink to 0.4
          }

          return Positioned(
            left: x,
            top: y,
            child: Opacity(
              opacity: (1.0 - (value * value)).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: scale.clamp(0.0, 2.0),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff0F5700).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: ProductImage(imageUrl, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );

  overlayState.insert(entry);
}

Widget BuildHeader(BuildContext context) {
  return Container(
    height: 180,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xff9AF055), Color(0xff8CE542)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 20,
                    color: Color(0xff0F5700),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Delivering to',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0x99000000),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Calicut, Kerala',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0F5700),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Color(0xff0F5700),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage())),
              child: Hero(
                tag: 'search-bar',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        SizedBox(width: 16),
                        Icon(Icons.search_rounded, color: Colors.grey, size: 22),
                        SizedBox(width: 12),
                        Text(
                          'Search fresh products...',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

///-----------------------------------shop by category--------------------------->>

class CategoryBanner extends StatelessWidget {
  const CategoryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Shop by Category',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              Text(
                'View All',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xff0F5700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            width: 400,
            child: categoryCard(
              title: 'Fruits',
              subtitle: 'Vibrant seasonal berries',
              image: "assets/images/fruits_banner.png",
              height: 180,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryDetailPage(categoryName: 'Fruits'))),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: categoryCard(
                  title: "Vegetables",
                  subtitle: "Crisp greens",
                  image: "assets/images/vegetables.png",
                  height: 140,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryDetailPage(categoryName: 'Vegetables'))),
                ),
              ),
              Expanded(
                child: categoryCard(
                  title: "Meat",
                  subtitle: "Fresh cuts",
                  image: "assets/images/meat.png",
                  height: 140,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryDetailPage(categoryName: 'Meat'))),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: categoryCard(
                  title: "Homemade",
                  subtitle: "Honey & Jams",
                  image: "assets/images/homemade_honey.png",
                  height: 140,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryDetailPage(categoryName: 'Homemade'))),
                ),
              ),
              Expanded(
                child: categoryCard(
                  title: "Dairy",
                  subtitle: "Milk & Cheese",
                  image: "assets/images/dairy.png",
                  height: 140,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryDetailPage(categoryName: 'Dairy'))),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget categoryCard({
  required String title,
  required String subtitle,
  required String image,
  required VoidCallback onTap,
  double height = 160,
  double? width,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
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
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class TrendingSection extends StatelessWidget {
  const TrendingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Trending Now',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              Icon(Icons.tune, size: 20, color: Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            final products = productProvider.products.take(10).toList();
            if (productProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xff0F5700)),
              );
            }
            if (products.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(40.0),
                child: Text('No products available right now.'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                  final product = products[index];
                  final GlobalKey addButtonKey = GlobalKey();
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetails(product: product),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 90,
                              width: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: const Color(0xfff8f8f8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: product.imageUrl.isNotEmpty
                                    ? Hero(
                                        tag:
                                            product.id ??
                                            'item-${product.name}-${index}',
                                        child: ProductImage(
                                          product.imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : ProductImage(
                                        '',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xff9AF055,
                                          ).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          "Best Seller",
                                          style: TextStyle(
                                            color: Color(0xff0F5700),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "by ${product.farmerName}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₹${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xff0F5700),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              key: addButtonKey,
                              onTap: () {
                                Provider.of<CartProvider>(
                                  context,
                                  listen: false,
                                ).addItem(product);
                                runAddToCartAnimation(context, product.imageUrl, addButtonKey);
                                showSuccessPopup(context, product.name, product.imageUrl);
                              },
                              child: Container(
                                height: 44,
                                width: 44,
                                decoration: const BoxDecoration(
                                  color: Color(0xff0F5700),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );

              },
            );
          },
        ),
      ],
    );
  }
}
