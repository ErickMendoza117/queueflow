import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/establecimiento.dart';

class EstablecimientoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get a stream of all establishments
  Stream<List<Establecimiento>> getEstablecimientos() {
    return _firestore.collection('establecimientos').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => Establecimiento.fromDocument(doc))
          .toList();
    });
  }

  // Get a specific establishment by ID
  Future<Establecimiento?> getEstablecimientoById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('establecimientos').doc(id).get();
      if (doc.exists) {
        return Establecimiento.fromDocument(doc);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting establishment by ID: $e');
      return null;
    }
  }

  // Add a new establishment
  Future<void> addEstablecimiento(Establecimiento establecimiento) {
    return _firestore
        .collection('establecimientos')
        .doc(establecimiento.id)
        .set(establecimiento.toMap());
  }

  // Update an existing establishment
  Future<void> updateEstablecimiento(Establecimiento establecimiento) {
    return _firestore
        .collection('establecimientos')
        .doc(establecimiento.id)
        .update(establecimiento.toMap());
  }

  // Delete an establishment
  Future<void> deleteEstablecimiento(String id) {
    return _firestore.collection('establecimientos').doc(id).delete();
  }

  // Generate a new Firestore document ID for an establishment
  String getNewEstablishmentId() {
    return _firestore.collection('establecimientos').doc().id;
  }
}
