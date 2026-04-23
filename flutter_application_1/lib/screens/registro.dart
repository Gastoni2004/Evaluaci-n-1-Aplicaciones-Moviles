import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _userController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF0B141B),

      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Color(0xFF1F2C34),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 9),
              Text(
                'Registrarse',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // Usuario
              const SizedBox(height: 20),
              TextFormField(
                controller: _userController,
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese texto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              //Email
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Ingrese su correo';
                  if (!value.endsWith('@gmail.com'))
                    return 'Formato xxxx@gmail.com';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              //Contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obligatorio';
                  }
                  if (value.length < 8) {
                    return 'Mínimo 8 caracteres';
                  }
                  if (!value.contains(RegExp(r'[A-Z]'))) {
                    return 'Falta una Mayúscula';
                  }
                  if (!value.contains(RegExp(r'[a-z]'))) {
                    return 'Falta una Minúscula';
                  }
                  if (!value.contains(RegExp(r'[0-9]'))) {
                    return 'Falta un Número';
                  }
                  if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                    return 'Falta un Símbolo';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              //Confirmación de contraseña
              TextFormField(
                controller: _confirmPassController,
                obscureText: !_passwordVisible,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, confirma tu contraseña';
                  }
                  if (value != _passwordController.text)
                    return 'Las contraseñas no coinciden';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              //Botón de registro
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    fnResgistro(
                      _emailController.text,
                      _passwordController.text,
                      _userController.text,
                    );
                  }
                },
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void fnResgistro(String email, String password, String nombre) async {
    if (nombre.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, completa todos los campos"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((UserCredential) async {
            await FirebaseAuth.instance.currentUser!.updateDisplayName(nombre);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Registro exitoso"),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.pushReplacementNamed(context, '/');
          })
          .catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.message),
                backgroundColor: Colors.red,
              ),
            );
          });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }
}
