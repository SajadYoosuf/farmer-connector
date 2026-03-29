import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String? id;
  final String userId;
  final String userName;
  final String farmerId;
  final String farmerName;
  final double totalAmount;
  final String status;
  final List<OrderItem> items;
  final String? shippingAddress;
  final String? paymentMethod;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  OrderModel({
    this.id,
    required this.userId,
    required this.userName,
    required this.farmerId,
    required this.farmerName,
    required this.totalAmount,
    this.status = 'pending',
    this.items = const [],
    this.shippingAddress,
    this.paymentMethod,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      shippingAddress: map['shippingAddress'],
      paymentMethod: map['paymentMethod'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'totalAmount': totalAmount,
      'status': status,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl = '',
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      name: map['productName'] ?? map['name'] ?? '',
      quantity: (map['quantity'] ?? 0).toInt(),
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}
