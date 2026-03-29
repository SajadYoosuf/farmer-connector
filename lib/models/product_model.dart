import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String? id;
  final String farmerId;
  final String farmerName;
  final String name;
  final String category;
  final double price;
  final String unit;
  final int stock;
  final String imageUrl;
  final bool isActive;
  final String demand;
  final int totalSold;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  ProductModel({
    this.id,
    required this.farmerId,
    required this.farmerName,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.stock,
    this.imageUrl = '',
    this.isActive = true,
    this.demand = 'Normal',
    this.totalSold = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      unit: map['unit'] ?? '',
      stock: (map['stock'] ?? 0).toInt(),
      imageUrl: map['imageUrl'] ?? '',
      isActive: map['isActive'] ?? true,
      demand: map['demand'] ?? 'Normal',
      totalSold: (map['totalSold'] ?? 0).toInt(),
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'farmerName': farmerName,
      'name': name,
      'category': category,
      'price': price,
      'unit': unit,
      'stock': stock,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'demand': demand,
      'totalSold': totalSold,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
