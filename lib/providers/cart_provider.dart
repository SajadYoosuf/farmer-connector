import 'package:flutter/material.dart';
import 'package:customer_app/models/product_model.dart';
import 'package:customer_app/services/cart_service.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();
  final Map<String, CartItem> _items = {};
  String? _userId;

  void updateUserId(String? id) {
    if (_userId != id) {
      _userId = id;
      if (_userId != null) {
        _loadCartFromFirestore();
      } else {
        _items.clear();
        notifyListeners();
      }
    }
  }

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  double get subtotal {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.total;
    });
    return total;
  }

  double get deliveryFee => 2.99;
  double get serviceFee => 1.50;
  double get totalAmount => subtotal + deliveryFee + serviceFee;

  void addItem(ProductModel product) {
    final productId = product.id ?? 'temp_${product.name}';
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items[productId] = CartItem(product: product);
    }
    _syncCartToFirestore(productId);
    notifyListeners();
  }

  void removeOne(String productId) {
    if (!_items.containsKey(productId)) return;
    
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity - 1,
        ),
      );
      _syncCartToFirestore(productId);
    } else {
      _items.remove(productId);
      _removeFromFirestore(productId);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    _removeFromFirestore(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _clearFirestore();
    notifyListeners();
  }

  Future<void> _syncCartToFirestore(String productId) async {
    if (_userId == null) return;
    final item = _items[productId];
    if (item != null) {
      await _cartService.syncCartItem(_userId!, productId, item.quantity, item.product.toMap());
    }
  }

  Future<void> _removeFromFirestore(String productId) async {
    if (_userId == null) return;
    await _cartService.removeCartItem(_userId!, productId);
  }

  Future<void> _clearFirestore() async {
    if (_userId == null) return;
    await _cartService.clearCart(_userId!);
  }

  Future<void> _loadCartFromFirestore() async {
    if (_userId == null) return;
    final cartList = await _cartService.loadCart(_userId!);
    
    _items.clear();
    for (var data in cartList) {
      final product = ProductModel.fromMap(data['productId'], data['productData']);
      _items[data['productId']] = CartItem(product: product, quantity: (data['quantity'] as num).toInt());
    }
    notifyListeners();
  }
}
