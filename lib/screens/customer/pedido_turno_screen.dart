import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/pedido_turno.dart';
import '../../services/pedido_turno_service.dart';

class PedidoTurnoScreen extends StatelessWidget {
  final String establecimientoId;

  const PedidoTurnoScreen({super.key, required this.establecimientoId});

  @override
  Widget build(BuildContext context) {
    final PedidoTurnoService _pedidoTurnoService = PedidoTurnoService();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // TODO: Handle case where user is not logged in
      return const Center(child: Text('Usuario no autenticado.'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Pedidos/Turnos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                final newPedidoTurno = PedidoTurno(
                  id: _pedidoTurnoService.getNewPedidoTurnoId(),
                  establecimientoId: establecimientoId,
                  clienteId: user.uid,
                  estado: 'en espera',
                  timestamp: Timestamp.now(),
                );
                try {
                  await _pedidoTurnoService.addPedidoTurno(newPedidoTurno);
                  // TODO: Show success message
                  print('Pedido/Turno creado.');
                } catch (e) {
                  // TODO: Show error message
                  print('Error al crear pedido/turno: $e');
                }
              },
              child: const Text('Generar Nuevo Pedido/Turno'),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PedidoTurno>>(
              stream: _pedidoTurnoService.getPedidosTurnosByCliente(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final pedidosTurnos = snapshot.data ?? [];

                if (pedidosTurnos.isEmpty) {
                  return const Center(
                    child: Text('No tienes pedidos o turnos activos.'),
                  );
                }

                return ListView.builder(
                  itemCount: pedidosTurnos.length,
                  itemBuilder: (context, index) {
                    final pedidoTurno = pedidosTurnos[index];
                    Color statusColor = Colors.grey;
                    if (pedidoTurno.estado == 'listo') {
                      statusColor = Colors.green;
                    } else if (pedidoTurno.estado == 'cancelado') {
                      statusColor = Colors.red;
                    } else {
                      statusColor = Colors.orange; // 'en espera'
                    }

                    return ListTile(
                      title: Text('Pedido/Turno ID: ${pedidoTurno.id}'),
                      subtitle: Text(
                        'Estado: ${pedidoTurno.estado} - Hora: ${pedidoTurno.timestamp.toDate().toLocal().toString().split('.')[0]}',
                      ),
                      trailing: CircleAvatar(
                        backgroundColor: statusColor,
                        radius: 8,
                      ),
                      // TODO: Add more details or actions if needed
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
