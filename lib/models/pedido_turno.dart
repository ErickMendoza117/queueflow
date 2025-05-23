import 'package:cloud_firestore/cloud_firestore.dart';

class PedidoTurno {
  final String id;
  final String establecimientoId;
  final String clienteId;
  final String estado; // e.g., 'en espera', 'listo', 'cancelado'
  final Timestamp timestamp; // Timestamp of creation
  final String? mensaje; // Optional message from the client

  PedidoTurno({
    required this.id,
    required this.establecimientoId,
    required this.clienteId,
    required this.estado,
    required this.timestamp,
    this.mensaje, // Make message optional
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
      mensaje: data['mensaje'], // Include message
    );
  }

  // Method to convert a PedidoTurno object into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'establecimientoId': establecimientoId,
      'clienteId': clienteId,
      'estado': estado,
      'timestamp': timestamp,
      'mensaje': mensaje, // Include message in map
    };
  }

  // Method to create a copy of PedidoTurno with updated fields
  PedidoTurno copyWith({
    String? id,
    String? establecimientoId,
    String? clienteId,
    String? estado,
    Timestamp? timestamp,
    String? mensaje, // Add message to copyWith
  }) {
    return PedidoTurno(
      id: id ?? this.id,
      establecimientoId: establecimientoId ?? this.establecimientoId,
      clienteId: clienteId ?? this.clienteId,
      estado: estado ?? this.estado,
      timestamp: timestamp ?? this.timestamp,
      mensaje: mensaje ?? this.mensaje, // Include message in copy
    );
  }
}
