import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'editarper.dart';
import 'package:gestor_de_herramientas/screens/login_screen.dart';

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({super.key});

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  String nombre = "";
  String email = "";
  String telefono = "";

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(user.uid)
          .get();

      if (!mounted) return;

      setState(() {
        nombre = doc.data()?['nombre'] ?? "Sin nombre";
        telefono = doc.data()?['telefono'] ?? "Sin teléfono";
        email = user.email ?? "";
      });
    } catch (e) {
      debugPrint("Error cargando perfil: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1F2C34),
      ),

      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(
                user?.photoURL ?? "https://i.pravatar.cc/150",
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "Usuario: $nombre",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Email: $email",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Teléfono: $telefono",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2C34),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditarPerfil()),
                ).then((_) {
                  cargarDatos();
                });
              },
              icon: const Icon(Icons.edit),
              label: const Text("Editar perfil"),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: cerrarSesion,
              icon: const Icon(Icons.logout),
              label: const Text("Cerrar Sesión"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> cerrarSesion() async {
    bool confirmar =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar'),
            content: const Text('¿Cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sí'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmar) return;

    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MyCustomForm(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
        (route) => false,
      );
    }
  }
}
