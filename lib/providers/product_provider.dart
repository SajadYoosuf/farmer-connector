import 'dart:async';
import 'package:flutter/material.dart';
import 'package:customer_app/services/product_service.dart';
import 'package:customer_app/models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _productsSubscription;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProductProvider() {
    _init();
  }

  void _init() {
    _isLoading = true;
    notifyListeners();
    
    _productsSubscription = _productService.getAllProductsStream().listen(
      (productList) {
        _products = productList;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      }
    );
  }

  List<ProductModel> getProductsByCategory(String category) {
    if (category.toLowerCase() == 'all') return _products;
    return _products.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
  }

  List<ProductModel> getTrendingProducts() {
    final sorted = List<ProductModel>.from(_products);
    sorted.sort((a, b) => b.totalSold.compareTo(a.totalSold));
    return sorted.take(10).toList();
  }

  Future<void> addProduct(ProductModel product) async {
    await _productService.addProduct(product);
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }
}
