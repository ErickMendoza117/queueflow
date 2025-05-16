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
              return _PedidoTurnoListItem(
                pedidoTurno: pedidoTurno,
              ); // Use the new stateful widget
            },
          );
        },
      ),
    );
  }
}

// New Stateful Widget for each list item
class _PedidoTurnoListItem extends StatefulWidget {
  final PedidoTurno pedidoTurno;

  const _PedidoTurnoListItem({required this.pedidoTurno});

  @override
  _PedidoTurnoListItemState createState() => _PedidoTurnoListItemState();
}

class _PedidoTurnoListItemState extends State<_PedidoTurnoListItem> {
  final PedidoTurnoService _pedidoTurnoService = PedidoTurnoService();
  late String _selectedStatus; // State for the dropdown value

  @override
  void initState() {
    super.initState();
    _selectedStatus =
        widget.pedidoTurno.estado; // Initialize with the current status
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Pedido/Turno ID: ${widget.pedidoTurno.id}'),
      subtitle: Text(
        'Estado: ${widget.pedidoTurno.estado}',
      ), // Display current state from the model
      trailing: DropdownButton<String>(
        value: _selectedStatus, // Use the state variable
        items:
            <String>['en espera', 'listo', 'cancelado'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        onChanged: (String? newValue) async {
          if (newValue != null) {
            setState(() {
              _selectedStatus = newValue; // Update the state
            });
            try {
              final updatedPedidoTurno = widget.pedidoTurno.copyWith(
                estado: newValue,
              );
              await _pedidoTurnoService.updatePedidoTurno(updatedPedidoTurno);
              print('Updated ${widget.pedidoTurno.id} to $newValue');
            } catch (e) {
              // TODO: Show error message to user
              print('Error updating pedido/turno status: $e');
              // If update fails, revert the state (optional, but good for UX)
              setState(() {
                _selectedStatus = widget.pedidoTurno.estado;
              });
            }
          }
        },
      ),
      // TODO: Add more details if needed
    );
  }
}
