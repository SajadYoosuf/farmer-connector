import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/models/order_model.dart';
import 'package:customer_app/services/product_service.dart';
import 'package:customer_app/services/activity_service.dart';
import 'package:customer_app/models/activity_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();
  final ActivityService _activityService = ActivityService();

  Future<String> placeOrder(OrderModel order) async {
    final docRef = await _firestore.collection('orders').add(order.toMap());
    for (var item in order.items) {
      await docRef.collection('items').add(item.toMap());
    }
    await _firestore.collection('users').doc(order.userId).update({
      'totalOrders': FieldValue.increment(1),
      'totalSpent': FieldValue.increment(order.totalAmount),
    });
    await _firestore.collection('users').doc(order.farmerId).update({
      'totalSales': FieldValue.increment(order.totalAmount),
    });
    for (var item in order.items) {
      await _productService.updateProductStock(item.productId, item.quantity);
    }
    await _activityService.addActivity(ActivityModel(
      userId: order.userId,
      userName: order.userName,
      type: 'purchase',
      description: '${order.userName} placed an order worth ₹${order.totalAmount.toStringAsFixed(0)}',
      relatedId: docRef.id,
    ));
    return docRef.id;
  }

  Stream<List<OrderModel>> getAllOrdersStream() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<OrderModel>> getUserOrdersStream(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<OrderModel>> getFarmerOrdersStream(String farmerId) {
    return _firestore
        .collection('orders')
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>> getOrderStats() async {
    final snapshot = await _firestore.collection('orders').get();
    double totalRevenue = 0;
    int totalOrders = snapshot.docs.length;
    for (var doc in snapshot.docs) {
      totalRevenue += (doc.data()['totalAmount'] ?? 0).toDouble();
    }
    return {
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
    };
  }
}
