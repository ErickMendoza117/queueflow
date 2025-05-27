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
        title: const Text(
          'Cola del Establecimiento',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2C3E50),
              Color(0xFF4A6572),
            ], // Dark Blue-Grey to Muted Blue
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: StreamBuilder<List<PedidoTurno>>(
              stream: _pedidoTurnoService.getPedidosTurnosByEstablecimiento(
                establecimientoId,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final pedidosTurnos = snapshot.data ?? [];

                if (pedidosTurnos.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay pedidos o turnos en la cola.',
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
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
          ),
        ),
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white.withOpacity(0.95), // Slightly less transparent
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18), // More rounded
      ),
      elevation: 8, // More prominent shadow
      shadowColor: Colors.black.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(20.0), // More padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pedido/Turno ID: ${widget.pedidoTurno.id}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF34495E), // Dark blue-grey text
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cliente: ${_customerUser?.email ?? 'Desconocido'}',
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
            Text(
              'Mensaje: ${widget.pedidoTurno.mensaje != null && widget.pedidoTurno.mensaje!.isNotEmpty ? widget.pedidoTurno.mensaje : 'N/A'}',
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Estado',
                      labelStyle: const TextStyle(
                        color: Color(0xFF34495E),
                      ), // Darker label text
                      filled: true,
                      fillColor: Colors.white, // Solid white background
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFF9AA33),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                    ),
                    value: _selectedStatus,
                    dropdownColor: const Color(
                      0xFF4A6572,
                    ), // Muted Blue for dropdown background
                    items:
                        <String>['en espera', 'listo', 'cancelado'].map((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                color: Colors.white,
                              ), // White text for dropdown items
                            ),
                          );
                        }).toList(),
                    selectedItemBuilder: (BuildContext context) {
                      return <String>['en espera', 'listo', 'cancelado'].map((
                        String value,
                      ) {
                        return Text(
                          value,
                          style: const TextStyle(
                            color: Color(0xFF34495E),
                          ), // Dark blue-grey text for selected item
                        );
                      }).toList();
                    },
                    iconEnabledColor: const Color(
                      0xFF34495E,
                    ), // Dropdown arrow color
                    onChanged: (String? newValue) async {
                      if (newValue != null) {
                        setState(() {
                          _selectedStatus = newValue;
                        });
                        try {
                          final updatedPedidoTurno = widget.pedidoTurno
                              .copyWith(estado: newValue);
                          await _pedidoTurnoService.updatePedidoTurno(
                            updatedPedidoTurno,
                          );
                        } catch (e) {
                          setState(() {
                            _selectedStatus = widget.pedidoTurno.estado;
                          });
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                    size: 30,
                  ),
                  onPressed: () async {
                    try {
                      await _pedidoTurnoService.deletePedidoTurno(
                        widget.pedidoTurno.id,
                      );
                    } catch (e) {}
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
