import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> syncCartItem(String userId, String productId, int quantity, Map<String, dynamic> productData) async {
    await _firestore.collection('users').doc(userId).collection('cart').doc(productId).set({
      'productId': productId,
      'quantity': quantity,
      'productData': productData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeCartItem(String userId, String productId) async {
    await _firestore.collection('users').doc(userId).collection('cart').doc(productId).delete();
  }

  Future<void> clearCart(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId).collection('cart').get();
    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> loadCart(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId).collection('cart').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
