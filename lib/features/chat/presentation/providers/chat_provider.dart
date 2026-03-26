import 'package:flutter/material.dart';
import 'package:customer_app/core/services/firestore_service.dart';
import 'package:customer_app/core/models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<MessageModel> _messages = [];
  bool _isLoading = false;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  Stream<List<MessageModel>> getMessages(String receiverId) {
    // We assume current user is the one sending/receiving
    // For a real stream, we need both IDs to get the room
    // In ChatPage, we can use Provider to get current userId
    // But for the stream, let's just make it easy
    return Stream.empty(); // Placeholder, better define it in ChatPage with FirestoreService directly or fix here
  }

  // Improved stream getter
  Stream<List<MessageModel>> getChatStream(String userId, String otherUserId) {
    final chatRoomId = _firestoreService.getChatRoomId(userId, otherUserId);
    return _firestoreService.getMessages(chatRoomId).map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> sendMessage({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String content,
  }) async {
    final message = MessageModel(
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      receiverName: receiverName,
      message: content,
    );
    await _firestoreService.sendMessage(message);
  }

  Stream getUserChatRooms(String userId) {
    return _firestoreService.getUserChatRooms(userId);
  }
}
