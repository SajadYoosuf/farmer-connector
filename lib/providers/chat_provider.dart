import 'dart:async';
import 'package:flutter/material.dart';
import 'package:customer_app/services/chat_service.dart';
import 'package:customer_app/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _messagesSubscription;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void fetchMessages(String chatRoomId) {
    _isLoading = true;
    notifyListeners();
    
    _messagesSubscription?.cancel();
    _messagesSubscription = _chatService.getMessagesStream(chatRoomId).listen(
      (mList) {
        _messages = mList;
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

  Stream<List<MessageModel>> getChatStream(String userId, String otherId) {
    final chatRoomId = _chatService.getChatRoomId(userId, otherId);
    return _chatService.getMessagesStream(chatRoomId);
  }

  Future<void> sendMessage(MessageModel message) async {
    await _chatService.sendMessage(message);
  }

  Stream<QuerySnapshot> getUserChatRooms(String userId) {
    return _chatService.getUserChatRoomsStream(userId);
  }

  String getChatRoomId(String id1, String id2) {
    return _chatService.getChatRoomId(id1, id2);
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
