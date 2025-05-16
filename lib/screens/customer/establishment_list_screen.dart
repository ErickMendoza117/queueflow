import 'package:queueflow/screens/customer/pedido_turno_screen.dart';
import 'package:flutter/material.dart';
import '../../models/establecimiento.dart';
import '../../services/establecimiento_service.dart';

class EstablishmentListScreen extends StatelessWidget {
  const EstablishmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EstablecimientoService _establecimientoService =
        EstablecimientoService();

    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar Establecimiento')),
      body: StreamBuilder<List<Establecimiento>>(
        stream: _establecimientoService.getEstablecimientos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final establecimientos = snapshot.data ?? [];

          if (establecimientos.isEmpty) {
            return const Center(
              child: Text('No hay establecimientos disponibles.'),
            );
          }

          return ListView.builder(
            itemCount: establecimientos.length,
            itemBuilder: (context, index) {
              final establecimiento = establecimientos[index];
              return ListTile(
                title: Text(establecimiento.nombre),
                subtitle: Text(establecimiento.tipo),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PedidoTurnoScreen(
                            establecimientoId: establecimiento.id,
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
