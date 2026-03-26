import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String? id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String message;
  final Timestamp? timestamp;
  final bool isRead;

  MessageModel({
    this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.message,
    this.timestamp,
    this.isRead = false,
  });

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'],
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }
}
