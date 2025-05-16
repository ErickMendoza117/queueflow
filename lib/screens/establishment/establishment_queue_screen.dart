import 'package:flutter/material.dart';
import '../../models/pedido_turno.dart';
import '../../services/pedido_turno_service.dart';

class EstablishmentQueueScreen extends StatelessWidget {
  final String establecimientoId;

  const EstablishmentQueueScreen({super.key, required this.establecimientoId});

  @override
  Widget build(BuildContext context) {
    final PedidoTurnoService _pedidoTurnoService = PedidoTurnoService();

    return Scaffold(
      appBar: AppBar(title: const Text('Cola del Establecimiento')),
      body: StreamBuilder<List<PedidoTurno>>(
        stream: _pedidoTurnoService.getPedidosTurnosByEstablecimiento(
          establecimientoId,
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
              child: Text('No hay pedidos o turnos en la cola.'),
            );
          }

          return ListView.builder(
            itemCount: pedidosTurnos.length,
            itemBuilder: (context, index) {
              final pedidoTurno = pedidosTurnos[index];
              return ListTile(
                title: Text('Pedido/Turno ID: ${pedidoTurno.id}'),
                subtitle: Text('Estado: ${pedidoTurno.estado}'),
                trailing: DropdownButton<String>(
                  value: pedidoTurno.estado,
                  items:
                      <String>['en espera', 'listo', 'cancelado'].map((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      // TODO: Implement update logic
                      print('Updating ${pedidoTurno.id} to $newValue');
                      // _pedidoTurnoService.updatePedidoTurno(pedidoTurno.copyWith(estado: newValue));
                    }
                  },
                ),
                // TODO: Add more details if needed
              );
            },
          );
        },
      ),
    );
  }
}
