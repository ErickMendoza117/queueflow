import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/establecimiento.dart';
import '../../services/establecimiento_service.dart';
import '../../services/user_service.dart'; // Import UserService
import '../establishment/establishment_queue_screen.dart'; // Import EstablishmentQueueScreen

class RegisterEstablishmentScreen extends StatefulWidget {
  const RegisterEstablishmentScreen({super.key});

  @override
  _RegisterEstablishmentScreenState createState() =>
      _RegisterEstablishmentScreenState();
}

class _RegisterEstablishmentScreenState
    extends State<RegisterEstablishmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final EstablecimientoService _establecimientoService =
      EstablecimientoService();
  final UserService _userService = UserService(); // Instantiate UserService
  String _nombre = '';
  String _tipo = '';
  String _direccion = '';

  Future<void> _registerEstablishment() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // TODO: Handle case where user is not logged in
        print('User not logged in');
        return;
      }

      final newEstablishment = Establecimiento(
        id:
            _establecimientoService
                .getNewEstablishmentId(), // Generate a new ID
        nombre: _nombre,
        tipo: _tipo,
        direccion: _direccion,
        ownerId: user.uid,
      );

      try {
        await _establecimientoService.addEstablecimiento(newEstablishment);

        // Update user document with the new establishment ID
        await _userService.updateEstablecimientoId(
          user.uid,
          newEstablishment.id,
        );

        // Navigate to establishment queue screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => EstablishmentQueueScreen(
                  establecimientoId: newEstablishment.id,
                ),
          ),
        );

        print('Establecimiento registrado y usuario actualizado: ${_nombre}');
      } catch (e) {
        // TODO: Show error message
        print('Error al registrar establecimiento o actualizar usuario: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Establecimiento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nombre del Establecimiento',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el nombre';
                  }
                  return null;
                },
                onSaved: (value) {
                  _nombre = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Establecimiento (ej: Restaurante)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el tipo';
                  }
                  return null;
                },
                onSaved: (value) {
                  _tipo = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa la dirección';
                  }
                  return null;
                },
                onSaved: (value) {
                  _direccion = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerEstablishment,
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
