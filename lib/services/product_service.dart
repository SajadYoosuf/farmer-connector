import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/models/product_model.dart';
import 'package:customer_app/services/activity_service.dart';
import 'package:customer_app/models/activity_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ActivityService _activityService = ActivityService();

  Future<String> addProduct(ProductModel product) async {
    final docRef = await _firestore.collection('products').add(product.toMap());
    await _activityService.addActivity(ActivityModel(
      userId: product.farmerId,
      userName: product.farmerName,
      type: 'listing',
      description: '${product.farmerName} listed "${product.name}" in ${product.category}',
      relatedId: docRef.id,
    ));
    return docRef.id;
  }

  Stream<List<ProductModel>> getFarmerProductsStream(String farmerId) {
    return _firestore
        .collection('products')
        .where('farmerId', isEqualTo: farmerId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<ProductModel>> getAllProductsStream() {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<ProductModel>> getProductsStream() {
    return _firestore.collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> updateProductStock(String productId, int quantitySold) async {
    await _firestore.collection('products').doc(productId).update({
      'stock': FieldValue.increment(-quantitySold),
      'totalSold': FieldValue.increment(quantitySold),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<int> getTotalProductsSold() async {
    final snapshot = await _firestore.collection('products').get();
    int totalSold = 0;
    for (var doc in snapshot.docs) {
      totalSold += (doc.data()['totalSold'] ?? 0) as int;
    }
    return totalSold;
  }
}
