import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/models/activity_model.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addActivity(ActivityModel activity) async {
    await _firestore.collection('activities').add(activity.toMap());
  }

  Stream<List<ActivityModel>> getRecentActivitiesStream({int limit = 10}) {
    return _firestore
        .collection('activities')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ActivityModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> logSignupActivity(
    String userId,
    String userName,
    String role,
  ) async {
    await addActivity(
      ActivityModel(
        userId: userId,
        userName: userName,
        type: 'signup',
        description: '$userName signed up as $role',
        relatedId: userId,
      ),
    );
  }
}
