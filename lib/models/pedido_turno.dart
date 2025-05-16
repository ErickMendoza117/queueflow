import 'package:cloud_firestore/cloud_firestore.dart';

class PedidoTurno {
  final String id;
  final String establecimientoId;
  final String clienteId;
  final String estado; // e.g., 'en espera', 'listo', 'cancelado'
  final Timestamp timestamp; // Timestamp of creation

  PedidoTurno({
    required this.id,
    required this.establecimientoId,
    required this.clienteId,
    required this.estado,
    required this.timestamp,
  });

  // Factory constructor for creating a new PedidoTurno object from a Firestore document
  factory PedidoTurno.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PedidoTurno(
      id: doc.id,
      establecimientoId: data['establecimientoId'] ?? '',
      clienteId: data['clienteId'] ?? '',
      estado: data['estado'] ?? 'en espera',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Method to convert a PedidoTurno object into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'establecimientoId': establecimientoId,
      'clienteId': clienteId,
      'estado': estado,
      'timestamp': timestamp,
    };
  }
}
