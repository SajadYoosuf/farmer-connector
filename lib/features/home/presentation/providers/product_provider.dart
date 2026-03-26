import 'package:flutter/material.dart';
import 'package:customer_app/core/services/firestore_service.dart';
import 'package:customer_app/core/models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProductProvider() {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _firestoreService.getAllProducts().listen((snapshot) {
        _products = snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ProductModel> getProductsByCategory(String category) {
    if (category.toLowerCase() == 'all') return _products;
    return _products.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
  }

  List<ProductModel> getTrendingProducts() {
    // For now, just return top 10 products
    return _products.take(10).toList();
  }
}
