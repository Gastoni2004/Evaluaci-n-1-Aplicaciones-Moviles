import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestor_de_herramientas/screens/option.dart';
import 'registro.dart';
import 'contrasena.dart';

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  State<MyCustomForm> createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF1F2C34),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(50),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Icon(
                    Icons.account_circle_outlined,
                    size: 90,
                    color: Colors.white,
                  ),
                  Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  //Usuario
                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Correo eléctronico',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email, color: Colors.white),
                    ),

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese texto';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(
                        Icons.password_outlined,
                        color: Colors.white,
                      ),
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
                        return 'Por favor ingrese texto';
                      }
                      if (value.length < 6) {
                        return 'Por favor ingrese texto';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      fnIniciarSesion(
                        _emailController.text,
                        _passwordController.text,
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text("OR", style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 5),
                  ElevatedButton.icon(
                    onPressed: () => signInWithGoogle(context),

                    icon: Image.asset('assets/images/google.png', height: 24),
                    label: const Text("Continuar con Google"),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const Contrasena(),
                        ),
                      );
                    },
                    child: const Text(
                      'Restablecer contraseña',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const Registro(),
                        ),
                      );
                    },
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void fnIniciarSesion(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, completa todos los campos"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = credential.user;

      if (user == null) {
        throw Exception("Usuario no encontrado");
      }

      await user.reload();
      user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("Error al actualizar usuario");
      }

      //Bloqueo si no esta verificado
      if (!user.emailVerified) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Correo no verificado"),
            content: const Text(
              "Debes verificar tu correo antes de iniciar sesión. ¿Quieres que te reenviemos el enlace?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await reenviarVerificacion();
                },
                child: const Text("Reenviar enlace"),
              ),
            ],
          ),
        );

        return;
      }

      //Acceso si esta verfificado
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Principal()),
      );
    } on FirebaseAuthException catch (e) {
      String mensaje = "Error de autenticación";

      if (e.code == 'user-not-found') {
        mensaje = "Usuario no encontrado";
      } else if (e.code == 'wrong-password') {
        mensaje = "Contraseña incorrecta";
      } else if (e.code == 'invalid-email') {
        mensaje = "Correo inválido";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId:
            '470914911392-aepleg72ertndomipb7hj95o5n51nr8m.apps.googleusercontent.com',
      );

      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      //Firebase login
      final result = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (!context.mounted) return null;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Principal()),
        (route) => false,
      );

      return result;
    } catch (e) {
      debugPrint("ERROR GOOGLE SIGN-IN: $e");
      return null;
    }
  }

  Future<void> reenviarVerificacion() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await credential.user?.sendEmailVerification();
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Correo reenviado, Revisa tu bandeja."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al reenviar el correo."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
