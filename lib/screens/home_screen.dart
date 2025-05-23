import 'package:queueflow/models/app_user.dart';
import 'package:queueflow/screens/establishment/establishment_queue_screen.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:queueflow/services/user_service.dart'; // Import UserService
import 'package:queueflow/screens/establishment/establishment_queue_screen.dart';
import 'package:flutter/material.dart';

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
      return Scaffold(
        appBar: AppBar(title: const Text('QueueFlow')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Build UI based on user role and establishment association
    Widget bodyWidget;
    if (_appUser?.role == 'establecimiento') {
      if (_appUser?.establecimientoId == null) {
        // UI for establishment role without an associated establishment
        bodyWidget = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Bienvenido Establecimiento!'),
              const SizedBox(height: 20),
              const Text('Aún no tienes un establecimiento registrado.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register_establishment');
                },
                child: const Text('Registrar Nuevo Establecimiento'),
              ),
            ],
          ),
        );
      } else {
        // UI for establishment role with an associated establishment (should have navigated automatically)
        bodyWidget = const Center(
          child: Text('Redirigiendo a la cola del establecimiento...'),
        );
      }
    } else {
      // Default to 'cliente' role or if role is not set
      // UI for client role
      bodyWidget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bienvenido Cliente!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/establishments');
              },
              child: const Text('Ver Establecimientos'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to client's orders/turns screen (requires passing client ID)
                print('Navigate to Client Orders');
                // Example navigation (requires client ID)
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => PedidoTurnoScreen(clienteId: FirebaseAuth.instance.currentUser!.uid),
                //   ),
                // );
              },
              child: const Text('Ver Mis Pedidos/Turnos'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('QueueFlow'),
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
      body: bodyWidget,
    );
  }
}
