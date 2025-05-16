import 'package:cloud_firestore/cloud_firestore.dart';

class Establecimiento {
  final String id;
  final String nombre;
  final String tipo; // e.g., Restaurante, Banco, Hospital
  final String direccion;
  final String ownerId; // User ID of the establishment owner

  Establecimiento({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.direccion,
    required this.ownerId,
  });

  // Factory constructor for creating a new Establecimiento object from a Firestore document
  factory Establecimiento.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Establecimiento(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      tipo: data['tipo'] ?? '',
      direccion: data['direccion'] ?? '',
      ownerId: data['ownerId'] ?? '',
    );
  }

  // Method to convert an Establecimiento object into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      'direccion': direccion,
      'ownerId': ownerId,
    };
  }
}
