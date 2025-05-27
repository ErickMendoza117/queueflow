import 'package:queueflow/models/app_user.dart';
import 'package:queueflow/screens/establishment/establishment_queue_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:queueflow/services/user_service.dart'; // Import UserService
import 'package:queueflow/screens/customer/pedido_turno_screen.dart'; // Import PedidoTurnoScreen
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService _userService = UserService();
  AppUser? _appUser; // Store the AppUser object
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndRole();
  }

  Future<void> _loadUserAndRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final appUser = await _userService.getUserById(user.uid);
      if (appUser != null) {
        setState(() {
          _appUser = appUser; // Store the AppUser object
          _isLoading = false;
        });
        // Navigate automatically if establishment has an associated establishmentId
        if (_appUser!.role == 'establecimiento' &&
            _appUser!.establecimientoId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => EstablishmentQueueScreen(
                      establecimientoId: _appUser!.establecimientoId!,
                    ),
              ),
            );
          });
        }
      } else {
        // TODO: Handle case where user document does not exist
        setState(() {
          _isLoading = false;
        });
        print('User document not found for ${user.uid}');
      }
    } else {
      // TODO: Handle case where user is not logged in (should not happen if navigated from login)
      setState(() {
        _isLoading = false;
      });
      print('User is not logged in');
      // Optionally navigate back to login
      // Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Widget bodyContent;
    if (_appUser?.role == 'establecimiento') {
      if (_appUser?.establecimientoId == null) {
        bodyContent = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenido Establecimiento!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aún no tienes un establecimiento registrado.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/register_establishment');
              },
              icon: const Icon(Icons.add_business),
              label: const Text('Registrar Nuevo Establecimiento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF9AA33), // Orange accent
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
            ),
          ],
        );
      } else {
        bodyContent = const Center(
          child: Text(
            'Redirigiendo a la cola del establecimiento...',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        );
      }
    } else {
      bodyContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Bienvenido Cliente!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/establishments');
            },
            icon: const Icon(Icons.store),
            label: const Text('Ver Establecimientos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF9AA33), // Orange accent
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final lastVisitedEstablishmentId = prefs.getString(
                'lastVisitedEstablishmentId',
              );

              if (lastVisitedEstablishmentId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => PedidoTurnoScreen(
                          establecimientoId: lastVisitedEstablishmentId,
                        ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No has visitado ningún establecimiento aún. Por favor, selecciona uno primero.',
                    ),
                  ),
                );
                Navigator.pushNamed(context, '/establishments');
              }
            },
            icon: const Icon(Icons.receipt_long),
            label: const Text('Ver Mis Pedidos/Turnos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF9AA33), // Orange accent
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.3),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QueueFlow',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
            child: bodyContent,
          ),
        ),
      ),
    );
  }
}
