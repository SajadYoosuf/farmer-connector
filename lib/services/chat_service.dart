import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(MessageModel message) async {
    final chatRoomId = getChatRoomId(message.senderId, message.receiverId);
    await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add(message.toMap());
    await _firestore.collection('chats').doc(chatRoomId).set({
      'lastMessage': message.message,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'participants': [message.senderId, message.receiverId],
      'usernames': {
        message.senderId: message.senderName,
        message.receiverId: message.receiverName,
      },
    }, SetOptions(merge: true));
  }

  Stream<List<MessageModel>> getMessagesStream(String chatRoomId) {
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<QuerySnapshot> getUserChatRoomsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

  String getChatRoomId(String id1, String id2) {
    List<String> ids = [id1, id2];
    ids.sort();
    return ids.join('_');
  }
}
