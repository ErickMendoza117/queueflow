import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/pedido_turno.dart';
import '../../services/pedido_turno_service.dart';

class PedidoTurnoScreen extends StatefulWidget {
  final String establecimientoId;

  const PedidoTurnoScreen({super.key, required this.establecimientoId});

  @override
  _PedidoTurnoScreenState createState() => _PedidoTurnoScreenState();
}

class _PedidoTurnoScreenState extends State<PedidoTurnoScreen> {
  final PedidoTurnoService _pedidoTurnoService = PedidoTurnoService();
  final TextEditingController _messageController =
      TextEditingController(); // Controller for the message input

  @override
  void dispose() {
    _messageController
        .dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              // Use a Column to arrange the text field and button
              children: [
                TextFormField(
                  controller: _messageController, // Assign the controller
                  decoration: const InputDecoration(
                    labelText: 'Mensaje para el establecimiento (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3, // Allow multiple lines for the message
                ),
                const SizedBox(height: 16.0), // Add some spacing
                ElevatedButton(
                  onPressed: () async {
                    final newPedidoTurno = PedidoTurno(
                      id: _pedidoTurnoService.getNewPedidoTurnoId(),
                      establecimientoId:
                          widget
                              .establecimientoId, // Use widget.establecimientoId
                      clienteId: user.uid,
                      estado: 'en espera',
                      timestamp: Timestamp.now(),
                      mensaje:
                          _messageController.text.trim().isEmpty
                              ? null
                              : _messageController.text
                                  .trim(), // Include the message, or null if empty
                    );
                    try {
                      await _pedidoTurnoService.addPedidoTurno(newPedidoTurno);
                      // TODO: Show success message
                      print('Pedido/Turno creado.');
                      _messageController
                          .clear(); // Clear the text field after creating the order
                    } catch (e) {
                      // TODO: Show error message
                      print('Error al crear pedido/turno: $e');
                    }
                  },
                  child: const Text('Generar Nuevo Pedido/Turno'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PedidoTurno>>(
              stream: _pedidoTurnoService
                  .getPedidosTurnosByEstablecimientoAndCliente(
                    widget.establecimientoId, // Use widget.establecimientoId
                    user.uid,
                  ),
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
                      trailing: Row(
                        // Use a Row to place multiple widgets in the trailing position
                        mainAxisSize:
                            MainAxisSize.min, // Keep the row size to a minimum
                        children: [
                          CircleAvatar(backgroundColor: statusColor, radius: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              try {
                                await _pedidoTurnoService.deletePedidoTurno(
                                  pedidoTurno.id,
                                );
                                // TODO: Show success message
                                print(
                                  'Pedido/Turno ${pedidoTurno.id} eliminado.',
                                );
                              } catch (e) {
                                // TODO: Show error message
                                print(
                                  'Error al eliminar pedido/turno ${pedidoTurno.id}: $e',
                                );
                              }
                            },
                          ),
                        ],
                      ),
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
