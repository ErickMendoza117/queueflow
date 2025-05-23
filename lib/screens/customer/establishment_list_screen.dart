import 'package:queueflow/screens/customer/pedido_turno_screen.dart';
import 'package:flutter/material.dart';
import '../../models/establecimiento.dart';
import '../../services/establecimiento_service.dart';

class EstablishmentListScreen extends StatefulWidget {
  const EstablishmentListScreen({super.key});

  @override
  _EstablishmentListScreenState createState() =>
      _EstablishmentListScreenState();
}

class _EstablishmentListScreenState extends State<EstablishmentListScreen> {
  final EstablecimientoService _establecimientoService =
      EstablecimientoService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar Establecimiento')),
      body: Column(
        // Use a Column to include the search bar above the list
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar Establecimiento',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            // Wrap the StreamBuilder in Expanded to take remaining space
            child: StreamBuilder<List<Establecimiento>>(
              stream: _establecimientoService.getEstablecimientos(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final establecimientos = snapshot.data ?? [];

                // Filter the list based on the search query
                final filteredEstablecimientos =
                    establecimientos.where((establecimiento) {
                      final nameLower = establecimiento.nombre.toLowerCase();
                      final typeLower = establecimiento.tipo.toLowerCase();
                      final queryLower = _searchQuery.toLowerCase();
                      return nameLower.contains(queryLower) ||
                          typeLower.contains(queryLower);
                    }).toList();

                if (filteredEstablecimientos.isEmpty) {
                  return const Center(
                    child: Text('No hay establecimientos disponibles.'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredEstablecimientos.length,
                  itemBuilder: (context, index) {
                    final establecimiento = filteredEstablecimientos[index];
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
          ),
        ],
      ),
    );
  }
}
