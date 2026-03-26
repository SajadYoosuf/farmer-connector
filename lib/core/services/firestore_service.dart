import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/core/models/product_model.dart';
import 'package:customer_app/core/models/order_model.dart';
import 'package:customer_app/core/models/activity_model.dart';
import 'package:customer_app/core/models/message_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════
  // PRODUCTS
  // ═══════════════════════════════════════════════════

  /// Add a new product listing
  Future<String> addProduct(ProductModel product) async {
    final docRef = await _firestore.collection('products').add(product.toMap());

    // Log activity
    await addActivity(ActivityModel(
      userId: product.farmerId,
      userName: product.farmerName,
      type: 'listing',
      description: '${product.farmerName} listed "${product.name}" in ${product.category}',
      relatedId: docRef.id,
    ));

    return docRef.id;
  }

  /// Get products stream for a specific farmer
  Stream<QuerySnapshot> getFarmerProducts(String farmerId) {
    return _firestore
        .collection('products')
        .where('farmerId', isEqualTo: farmerId)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  /// Get all active products stream
  Stream<QuerySnapshot> getAllProducts() {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  /// Get products grouped by category (for analytics)
  Stream<QuerySnapshot> getProductsStream() {
    return _firestore.collection('products').snapshots();
  }

  /// Update product stock after purchase
  Future<void> updateProductStock(String productId, int quantitySold) async {
    await _firestore.collection('products').doc(productId).update({
      'stock': FieldValue.increment(-quantitySold),
      'totalSold': FieldValue.increment(quantitySold),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ═══════════════════════════════════════════════════
  // ORDERS
  // ═══════════════════════════════════════════════════

  /// Place a new order
  Future<String> placeOrder(OrderModel order) async {
    final docRef = await _firestore.collection('orders').add(order.toMap());

    // Add order items as subcollection
    for (var item in order.items) {
      await docRef.collection('items').add(item.toMap());
    }

    // Update user's totalSpent
    await _firestore.collection('users').doc(order.userId).update({
      'totalOrders': FieldValue.increment(1),
      'totalSpent': FieldValue.increment(order.totalAmount),
    });

    // Update farmer's totalSales
    await _firestore.collection('users').doc(order.farmerId).update({
      'totalSales': FieldValue.increment(order.totalAmount),
    });

    // Update product stock
    for (var item in order.items) {
      await updateProductStock(item.productId, item.quantity);
    }

    // Log activity
    await addActivity(ActivityModel(
      userId: order.userId,
      userName: order.userName,
      type: 'purchase',
      description: '${order.userName} placed an order worth ₹${order.totalAmount.toStringAsFixed(0)}',
      relatedId: docRef.id,
    ));

    return docRef.id;
  }

  /// Get all orders stream (for admin)
  Stream<QuerySnapshot> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get orders for a specific user
  Stream<QuerySnapshot> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get orders for a specific farmer
  Stream<QuerySnapshot> getFarmerOrders(String farmerId) {
    return _firestore
        .collection('orders')
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ═══════════════════════════════════════════════════
  // ACTIVITIES
  // ═══════════════════════════════════════════════════

  /// Add a new activity log
  Future<void> addActivity(ActivityModel activity) async {
    await _firestore.collection('activities').add(activity.toMap());
  }

  /// Get recent activities stream (for admin dashboard)
  Stream<QuerySnapshot> getRecentActivities({int limit = 10}) {
    return _firestore
        .collection('activities')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Log a signup activity (call this after successful registration)
  Future<void> logSignupActivity(String userId, String userName, String role) async {
    await addActivity(ActivityModel(
      userId: userId,
      userName: userName,
      type: 'signup',
      description: '$userName signed up as $role',
      relatedId: userId,
    ));
  }

  // ═══════════════════════════════════════════════════
  // CHATS
  // ═══════════════════════════════════════════════════

  /// Send a message
  Future<void> sendMessage(MessageModel message) async {
    final chatRoomId = getChatRoomId(message.senderId, message.receiverId);
    await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add(message.toMap());

    // Update last message in the chat room
    await _firestore.collection('chats').doc(chatRoomId).set({
      'lastMessage': message.message,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'participants': [message.senderId, message.receiverId],
      'usernames': {
        message.senderId: message.senderName,
        message.receiverId: message.receiverName,
      },
    }, SetOptions(merge: true));
  }

  /// Get messages for a specific chat room
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Get list of chat rooms for a user
  Stream<QuerySnapshot> getUserChatRooms(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

  /// Utility to generate a consistent chat room ID
  String getChatRoomId(String id1, String id2) {
    List<String> ids = [id1, id2];
    ids.sort();
    return ids.join('_');
  }

  // ═══════════════════════════════════════════════════
  // ADMIN STATS (aggregated queries)
  // ═══════════════════════════════════════════════════

  /// Get total orders count + total revenue
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

  /// Get products sold count
  Future<int> getTotalProductsSold() async {
    final snapshot = await _firestore.collection('products').get();
    int totalSold = 0;
    for (var doc in snapshot.docs) {
      totalSold += (doc.data()['totalSold'] ?? 0) as int;
    }
    return totalSold;
  }
}
