import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:customer_app/core/models/order_model.dart';
import 'package:customer_app/features/orders/presentation/pages/order_placed/order_placed.dart';

/// Shows the address popup. Call this before placing an order.
Future<void> showAddressPopup(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _AddressSheet(),
  );
}

class _AddressSheet extends StatefulWidget {
  const _AddressSheet();

  @override
  State<_AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends State<_AddressSheet> {
  final TextEditingController _addressController = TextEditingController();
  bool _isLocating = false;
  bool _isPlacing = false;
  var _detectedAddress = '';

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        _showError('Location permission denied. Please enter manually.');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final addr = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.postalCode,
        ].where((s) => s != null && s.isNotEmpty).join(', ');
        setState(() {
          _detectedAddress = addr;
          _addressController.text = addr;
        });
      }
    } catch (e) {
      _showError('Could not detect location. Please enter manually.');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _placeOrder() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      _showError('Please enter your delivery address.');
      return;
    }

    setState(() => _isPlacing = true);
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (cartProvider.items.isEmpty) {
        _showError('Your basket is empty.');
        return;
      }

      final user = authProvider.currentUser;
      // Group items by farmer
      final grouped = <String, List<dynamic>>{};
      cartProvider.items.values.forEach((item) {
        grouped.putIfAbsent(item.product.farmerId, () => []).add(item);
      });

      // Create one order per farmer
      for (final entry in grouped.entries) {
        final farmerId = entry.key;
        final items = entry.value;
        final farmerName = items.first.product.farmerName;
        final total = items.fold<double>(0, (sum, i) => sum + i.total);

        final order = OrderModel(
          userId: user?.uid ?? 'guest',
          userName: user?.fullName ?? user?.email ?? 'Guest',
          farmerId: farmerId,
          farmerName: farmerName,
          totalAmount: total,
          items: items
              .map(
                (item) => OrderItem(
                  productId: item.product.id ?? 'unknown',
                  productName: item.product.name,
                  quantity: item.quantity,
                  price: item.product.price,
                  subtotal: item.total,
                ),
              )
              .toList(),
        );

        // Save with delivery address
        await FirebaseFirestore.instance.collection('orders').add({
          ...order.toMap(),
          'deliveryAddress': address,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Log activity
        await FirebaseFirestore.instance.collection('activities').add({
          'title': 'New Order Placed',
          'description': '${user?.fullName ?? 'Customer'} placed an order.',
          'type': 'order_placed',
          'timestamp': FieldValue.serverTimestamp(),
          'userId': user?.uid,
        });
      }

      cartProvider.clear();
      if (mounted) {
        Navigator.pop(context); // close sheet
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderPlacedLoadingScreen()),
        );
      }
    } catch (e) {
      _showError('Failed to place order: $e');
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Where should we deliver your order?',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // DETECT LOCATION BUTTON
            OutlinedButton.icon(
              onPressed: _isLocating ? null : _detectLocation,
              icon: _isLocating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xff0F5700),
                      ),
                    )
                  : const Icon(
                      Icons.my_location,
                      size: 18,
                      color: Color(0xff0F5700),
                    ),
              label: Text(
                _isLocating ? 'Detecting...' : 'Use Current Location',
                style: const TextStyle(
                  color: Color(0xff0F5700),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xff9AF055), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade200)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or enter manually',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade200)),
              ],
            ),
            const SizedBox(height: 16),

            // ADDRESS TEXT FIELD
            TextField(
              controller: _addressController,
              maxLines: 3,
              keyboardType: TextInputType.streetAddress,
              decoration: InputDecoration(
                hintText: 'House no., Street, City, State, Pincode...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 12, top: 14),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: Color(0xff0F5700),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xff9AF055),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // PLACE ORDER BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPlacing ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0F5700),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: _isPlacing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Confirm & Place Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
