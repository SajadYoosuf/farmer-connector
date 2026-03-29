import 'dart:async';
import 'package:flutter/material.dart';
import 'package:customer_app/services/order_service.dart';
import 'package:customer_app/models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  
  List<OrderModel> _userOrders = [];
  List<OrderModel> _farmerOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _userOrdersSubscription;
  StreamSubscription? _farmerOrdersSubscription;

  List<OrderModel> get userOrders => _userOrders;
  List<OrderModel> get farmerOrders => _farmerOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void fetchUserOrders(String userId) {
    _isLoading = true;
    notifyListeners();
    
    _userOrdersSubscription?.cancel();
    _userOrdersSubscription = _orderService.getUserOrdersStream(userId).listen(
      (orders) {
        _userOrders = orders;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        _isLoading = false;
        notifyListeners();
      }
    );
  }

  void fetchFarmerOrders(String farmerId) {
    _isLoading = true;
    notifyListeners();
    
    _farmerOrdersSubscription?.cancel();
    _farmerOrdersSubscription = _orderService.getFarmerOrdersStream(farmerId).listen(
      (orders) {
        _farmerOrders = orders;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        _isLoading = false;
        notifyListeners();
      }
    );
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _orderService.updateOrderStatus(orderId, status);
  }

  Future<String> placeOrder(OrderModel order) async {
    return await _orderService.placeOrder(order);
  }

  // Earnings calculations for Farmer
  double get totalEarnings {
    return _farmerOrders
        .where((o) => ['shipped', 'delivered', 'Shipped', 'Delivered'].contains(o.status))
        .fold(0, (sum, o) => sum + o.totalAmount);
  }

  Map<String, double> get cropEarnings {
    Map<String, double> earnings = {};
    for (var order in _farmerOrders) {
      if (!['shipped', 'delivered', 'Shipped', 'Delivered'].contains(order.status)) continue;
      for (var item in order.items) {
        earnings[item.name] = (earnings[item.name] ?? 0) + (item.price * item.quantity);
      }
    }
    return earnings;
  }

  Map<String, String> get cropImages {
    Map<String, String> images = {};
    for (var order in _farmerOrders) {
      for (var item in order.items) {
        if (item.imageUrl.isNotEmpty) images[item.name] = item.imageUrl;
      }
    }
    return images;
  }

  List<double> get weeklyEarnings {
    List<double> weekly = [0, 0, 0, 0];
    final now = DateTime.now();
    for (var order in _farmerOrders) {
       if (!['shipped', 'delivered', 'Shipped', 'Delivered'].contains(order.status)) continue;
       if (order.createdAt == null) continue;
       final date = order.createdAt!.toDate();
       if (date.month == now.month && date.year == now.year) {
          int week = (date.day - 1) ~/ 7;
          if (week > 3) week = 3;
          weekly[week] += order.totalAmount;
       }
    }
    return weekly;
  }

  String get topCrop {
    final earnings = cropEarnings;
    if (earnings.isEmpty) return "";
    return earnings.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  @override
  void dispose() {
    _userOrdersSubscription?.cancel();
    _farmerOrdersSubscription?.cancel();
    super.dispose();
  }
}
