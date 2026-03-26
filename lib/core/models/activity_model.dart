import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String? id;
  final String userId;
  final String userName;
  final String type; // 'purchase', 'signup', 'listing', 'review'
  final String description;
  final String relatedId;
  final Timestamp? createdAt;

  ActivityModel({
    this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.description,
    this.relatedId = '',
    this.createdAt,
  });

  factory ActivityModel.fromMap(String id, Map<String, dynamic> map) {
    return ActivityModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      relatedId: map['relatedId'] ?? '',
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'type': type,
      'description': description,
      'relatedId': relatedId,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
