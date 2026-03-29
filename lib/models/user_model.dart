class UserModel {
  final String uid;
  final String email;
  final String role;
  final String status;
  final String? fullName;
  final String? profileImage;
  final double? rating;
  final int? totalOrders;
  final double? totalSpent;
  final double? totalSales;
  final String? location;
  final Map<String, dynamic>? extraData;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.status,
    this.fullName,
    this.profileImage,
    this.rating,
    this.totalOrders,
    this.totalSpent,
    this.totalSales,
    this.location,
    this.extraData,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      role: map['role'] ?? 'customer',
      status: map['status'] ?? 'approved',
      fullName: map['fullName'],
      profileImage: map['profileImage'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalOrders: map['totalOrders'] ?? 0,
      totalSpent: (map['totalSpent'] ?? 0.0).toDouble(),
      totalSales: (map['totalSales'] ?? 0.0).toDouble(),
      location: map['location'],
      extraData: map,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'status': status,
      'fullName': fullName,
      'profileImage': profileImage,
      'rating': rating,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'totalSales': totalSales,
      'location': location,
      if (extraData != null) ...extraData!,
    };
  }
}
