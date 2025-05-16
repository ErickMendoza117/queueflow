import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new user document in Firestore
  Future<void> createUser(AppUser user) {
    return _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  // Get a user document by ID
  Future<AppUser?> getUserById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        return AppUser.fromDocument(doc);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  // Update the FCM token for a user
  Future<void> updateFcmToken(String userId, String? fcmToken) {
    return _firestore.collection('users').doc(userId).update({
      'fcmToken': fcmToken,
    });
  }

  // Update the establecimientoId for a user
  Future<void> updateEstablecimientoId(
    String userId,
    String? establecimientoId,
  ) {
    return _firestore.collection('users').doc(userId).update({
      'establecimientoId': establecimientoId,
    });
  }

  // TODO: Add methods to get users by role if needed
}
