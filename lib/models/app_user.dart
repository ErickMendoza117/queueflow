import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String? fcmToken; // FCM token for push notifications
  final String role; // e.g., 'cliente', 'establecimiento'
  final String?
  establecimientoId; // ID of the associated establishment for 'establecimiento' role

  AppUser({
    required this.uid,
    required this.email,
    this.fcmToken,
    required this.role,
    this.establecimientoId,
  });

  // Factory constructor for creating a new AppUser object from a Firestore document
  factory AppUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      fcmToken: data['fcmToken'],
      role: data['role'] ?? 'cliente', // Default role is 'cliente'
      establecimientoId: data['establecimientoId'],
    );
  }

  // Method to convert an AppUser object into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fcmToken': fcmToken,
      'role': role,
      'establecimientoId': establecimientoId,
    };
  }

  // Method to create a copy of AppUser with updated fields
  AppUser copyWith({
    String? uid,
    String? email,
    String? fcmToken,
    String? role,
    String? establecimientoId,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fcmToken: fcmToken ?? this.fcmToken,
      role: role ?? this.role,
      establecimientoId: establecimientoId ?? this.establecimientoId,
    );
  }
}
