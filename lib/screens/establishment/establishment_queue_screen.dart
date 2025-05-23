import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../../models/pedido_turno.dart';
import '../../services/pedido_turno_service.dart';
import '../../services/user_service.dart'; // Import UserService
import '../../models/app_user.dart'; // Import AppUser model

class EstablishmentQueueScreen extends StatelessWidget {
  final String establecimientoId;

  const EstablishmentQueueScreen({super.key, required this.establecimientoId});

  @override
  Widget build(BuildContext context) {
    final PedidoTurnoService _pedidoTurnoService = PedidoTurnoService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cola del Establecimiento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
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
  final UserService _userService = UserService(); // Instantiate UserService
  late String _selectedStatus; // State for the dropdown value
  AppUser? _customerUser; // Store the customer's AppUser object
  bool _isLoadingCustomer = true; // Loading state for fetching customer data

  @override
  void initState() {
    super.initState();
    _selectedStatus =
        widget.pedidoTurno.estado; // Initialize with the current status
    _loadCustomerUser(); // Load customer data
  }

  Future<void> _loadCustomerUser() async {
    try {
      final user = await _userService.getUserById(widget.pedidoTurno.clienteId);
      setState(() {
        _customerUser = user;
        _isLoadingCustomer = false;
      });
    } catch (e) {
      print('Error loading customer user: $e');
      setState(() {
        _isLoadingCustomer = false;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (_isLoadingCustomer) {
      return const ListTile(title: Text('Cargando cliente...'));
    }

    return ListTile(
      title: Text('Pedido/Turno ID: ${widget.pedidoTurno.id}'),
      subtitle: Text(
        'Cliente: ${_customerUser?.email ?? 'Desconocido'}\n' // Display customer email
                'Estado: ${widget.pedidoTurno.estado}' + // Display current state from the model
            (widget.pedidoTurno.mensaje != null &&
                    widget.pedidoTurno.mensaje!.isNotEmpty
                ? '\nMensaje: ${widget.pedidoTurno.mensaje}' // Display message if available
                : ''),
      ),
      trailing: Row(
        // Use a Row to place multiple widgets in the trailing position
        mainAxisSize: MainAxisSize.min, // Keep the row size to a minimum
        children: [
          DropdownButton<String>(
            value: _selectedStatus, // Use the state variable
            items:
                <String>['en espera', 'listo', 'cancelado'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
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
                  await _pedidoTurnoService.updatePedidoTurno(
                    updatedPedidoTurno,
                  );
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
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              try {
                await _pedidoTurnoService.deletePedidoTurno(
                  widget.pedidoTurno.id,
                );
                // TODO: Show success message
                print('Pedido/Turno ${widget.pedidoTurno.id} eliminado.');
              } catch (e) {
                // TODO: Show error message
                print(
                  'Error al eliminar pedido/turno ${widget.pedidoTurno.id}: $e',
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
