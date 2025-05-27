import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/pedido_turno.dart';
import '../../services/pedido_turno_service.dart';
import '../../models/establecimiento.dart'; // Import Establecimiento model
import '../../services/establecimiento_service.dart'; // Import EstablecimientoService

class PedidoTurnoScreen extends StatefulWidget {
  final String establecimientoId;

  const PedidoTurnoScreen({super.key, required this.establecimientoId});

  @override
  _PedidoTurnoScreenState createState() => _PedidoTurnoScreenState();
}

class _PedidoTurnoScreenState extends State<PedidoTurnoScreen> {
  final PedidoTurnoService _pedidoTurnoService = PedidoTurnoService();
  final EstablecimientoService _establecimientoService =
      EstablecimientoService(); // Initialize service
  final TextEditingController _messageController = TextEditingController();
  String _establecimientoName =
      'Cargando...'; // State variable for establishment name

  @override
  void initState() {
    super.initState();
    _fetchEstablecimientoName();
  }

  Future<void> _fetchEstablecimientoName() async {
    try {
      final establecimiento = await _establecimientoService
          .getEstablecimientoById(widget.establecimientoId);
      if (establecimiento != null) {
        setState(() {
          _establecimientoName = establecimiento.nombre;
        });
      } else {
        setState(() {
          _establecimientoName = 'Establecimiento no encontrado';
        });
      }
    } catch (e) {
      setState(() {
        _establecimientoName = 'Error al cargar nombre';
      });
      print('Error fetching establishment name: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Usuario no autenticado.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Pedidos/Turnos',
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
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF4A6572)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 100.0,
                left: 24.0,
                right: 24.0,
                bottom: 24.0,
              ), // Adjusted top padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Establecimiento: $_establecimientoName',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF9AA33),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Mensaje para el establecimiento (opcional)',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color(0xFFF9AA33),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                    ),
                    maxLines: 3,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final newPedidoTurno = PedidoTurno(
                          id: _pedidoTurnoService.getNewPedidoTurnoId(),
                          establecimientoId: widget.establecimientoId,
                          clienteId: user.uid,
                          estado: 'en espera',
                          timestamp: Timestamp.now(),
                          mensaje:
                              _messageController.text.trim().isEmpty
                                  ? null
                                  : _messageController.text.trim(),
                        );
                        try {
                          await _pedidoTurnoService.addPedidoTurno(
                            newPedidoTurno,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pedido/Turno creado con éxito!'),
                            ),
                          );
                          _messageController.clear();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al crear pedido/turno: $e'),
                            ),
                          );
                          print('Error al crear pedido/turno: $e');
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text(
                        'Generar Nuevo Pedido/Turno',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF9AA33),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<PedidoTurno>>(
                stream: _pedidoTurnoService
                    .getPedidosTurnosByEstablecimientoAndCliente(
                      widget.establecimientoId,
                      user.uid,
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
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF9AA33),
                      ),
                    );
                  }

                  final pedidosTurnos = snapshot.data ?? [];

                  if (pedidosTurnos.isEmpty) {
                    return const Center(
                      child: Text(
                        'No tienes pedidos o turnos activos.',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount: pedidosTurnos.length,
                    itemBuilder: (context, index) {
                      final pedidoTurno = pedidosTurnos[index];
                      Color statusColor;
                      String statusText;
                      IconData statusIcon;

                      switch (pedidoTurno.estado) {
                        case 'listo':
                          statusColor = Colors.greenAccent[400]!;
                          statusText = 'Listo';
                          statusIcon = Icons.check_circle;
                          break;
                        case 'cancelado':
                          statusColor = Colors.redAccent[400]!;
                          statusText = 'Cancelado';
                          statusIcon = Icons.cancel;
                          break;
                        case 'en espera':
                        default:
                          statusColor = Colors.orangeAccent[400]!;
                          statusText = 'En Espera';
                          statusIcon = Icons.hourglass_empty;
                          break;
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 8.0,
                        ), // Added horizontal margin to cards
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        color: Colors.white.withOpacity(0.95),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pedido/Turno ID: ${pedidoTurno.id.substring(0, 8)}...',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF34495E),
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Row(
                                children: [
                                  Icon(
                                    statusIcon,
                                    color: statusColor,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 10.0),
                                  Expanded(
                                    // Use Expanded to prevent overflow
                                    child: Text(
                                      'Estado: $statusText',
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: statusColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ), // Add spacing between status and time
                                  Text(
                                    'Hora: ${pedidoTurno.timestamp.toDate().toLocal().toString().split('.')[0]}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              if (pedidoTurno.mensaje != null &&
                                  pedidoTurno.mensaje!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    'Mensaje: ${pedidoTurno.mensaje}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                    size: 30,
                                  ),
                                  onPressed: () async {
                                    try {
                                      await _pedidoTurnoService
                                          .deletePedidoTurno(pedidoTurno.id);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Pedido/Turno ${pedidoTurno.id.substring(0, 8)}... eliminado.',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error al eliminar pedido/turno: $e',
                                          ),
                                        ),
                                      );
                                      print(
                                        'Error al eliminar pedido/turno ${pedidoTurno.id}: $e',
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
