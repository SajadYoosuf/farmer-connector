import 'package:flutter/material.dart';
import 'package:customer_app/core/services/firestore_service.dart';
import 'package:customer_app/core/models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<MessageModel> _messages = [];
  bool _isLoading = false;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  void listenToMessages(String senderId, String receiverId) {
    final chatRoomId = _firestoreService.getChatRoomId(senderId, receiverId);
    _firestoreService.getMessages(chatRoomId).listen((snapshot) {
      _messages = snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    });
  }

  Future<void> sendMessage(String senderId, String senderName, String receiverId, String messageText) async {
    final message = MessageModel(
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      message: messageText,
    );
    await _firestoreService.sendMessage(message);
  }

  Stream getUserChatRooms(String userId) {
    return _firestoreService.getUserChatRooms(userId);
  }
}
