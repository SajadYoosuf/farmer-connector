import 'package:customer_app/models/order_model.dart';
import 'package:customer_app/services/order_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceOrderCommand {
  final OrderService _orderService = OrderService();

  Future<String?> execute({
    required String userId,
    required String userName,
    required String farmerId,
    required String farmerName,
    required List<OrderItem> items,
    required double totalAmount,
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    try {
      final order = OrderModel(
        userId: userId,
        userName: userName,
        farmerId: farmerId,
        farmerName: farmerName,
        items: items,
        totalAmount: totalAmount,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        status: 'pending',
        createdAt: Timestamp.now(),
      );
      final orderId = await _orderService.placeOrder(order);
      return orderId;
    } catch (e) {
      print("PlaceOrderCommand failed: $e");
      return null;
    }
  }
}
