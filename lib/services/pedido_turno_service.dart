import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pedido_turno.dart';

class PedidoTurnoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get a stream of orders/turns for a specific establishment
  Stream<List<PedidoTurno>> getPedidosTurnosByEstablecimiento(
    String establecimientoId,
  ) {
    return _firestore
        .collection('pedidos_turnos')
        .where('establecimientoId', isEqualTo: establecimientoId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PedidoTurno.fromDocument(doc))
              .toList();
        });
  }

  // Get a stream of orders/turns for a specific client
  Stream<List<PedidoTurno>> getPedidosTurnosByCliente(String clienteId) {
    return _firestore
        .collection('pedidos_turnos')
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PedidoTurno.fromDocument(doc))
              .toList();
        });
  }

  // Add a new order/turn
  Future<void> addPedidoTurno(PedidoTurno pedidoTurno) {
    return _firestore
        .collection('pedidos_turnos')
        .doc(pedidoTurno.id)
        .set(pedidoTurno.toMap());
  }

  // Update an existing order/turn
  Future<void> updatePedidoTurno(PedidoTurno pedidoTurno) {
    return _firestore
        .collection('pedidos_turnos')
        .doc(pedidoTurno.id)
        .update(pedidoTurno.toMap());
  }

  // Delete an order/turn
  Future<void> deletePedidoTurno(String id) {
    return _firestore.collection('pedidos_turnos').doc(id).delete();
  }

  // Generate a new Firestore document ID for a pedido/turno
  String getNewPedidoTurnoId() {
    return _firestore.collection('pedidos_turnos').doc().id;
  }
}
