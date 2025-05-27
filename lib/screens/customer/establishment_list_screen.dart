import 'package:queueflow/screens/customer/pedido_turno_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<void> _saveLastVisitedEstablishment(String establecimientoId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastVisitedEstablishmentId', establecimientoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seleccionar Establecimiento',
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
      extendBodyBehindAppBar:
          true, // Add this line to extend the body behind the app bar
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 100.0,
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ), // Adjusted top padding
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar Establecimiento',
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
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF34495E),
                  ), // Darker icon
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 20,
                  ),
                  labelStyle: TextStyle(color: Colors.grey[700]),
                ),
                style: TextStyle(color: Colors.grey[800]),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Establecimiento>>(
                stream: _establecimientoService.getEstablecimientos(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(
                          color: Colors.white,
                        ), // Keep white for error
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF9AA33),
                      ),
                    ); // Orange indicator
                  }

                  final establecimientos = snapshot.data ?? [];

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
                      child: Text(
                        'No hay establecimientos disponibles.',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.8),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredEstablecimientos.length,
                    itemBuilder: (context, index) {
                      final establecimiento = filteredEstablecimientos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        color: Colors.white.withOpacity(
                          0.95,
                        ), // Slightly less transparent
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            18,
                          ), // More rounded
                        ),
                        elevation: 8, // More prominent shadow
                        shadowColor: Colors.black.withOpacity(0.2),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(
                            20,
                          ), // More padding
                          leading: const Icon(
                            Icons.storefront,
                            color: Color(0xFFF9AA33), // Orange accent icon
                            size: 45, // Larger icon
                          ),
                          title: Text(
                            establecimiento.nombre,
                            style: const TextStyle(
                              fontSize: 20, // Larger title
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF34495E), // Dark blue-grey text
                            ),
                          ),
                          subtitle: Text(
                            establecimiento.tipo,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                            ), // Slightly lighter grey, larger font
                          ),
                          onTap: () async {
                            await _saveLastVisitedEstablishment(
                              establecimiento.id,
                            );
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
