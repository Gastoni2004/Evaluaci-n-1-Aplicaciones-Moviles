import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'editarper.dart';

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({super.key});

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  //Usamos los nombres que tú les pusiste
  String nombre = "";
  String email = "";
  String telefono = "";

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() {
      nombre = user.displayName ?? "Sin nombre";
      email = user.email ?? "";
    });
    FirebaseFirestore.instance
        .collection("usuarios")
        .doc(user.uid)
        .get()
        .then((doc) {
          if (doc.exists && mounted) {
            setState(() {
              nombre = doc.data()?['nombre'] ?? nombre;
              telefono = doc.data()?['telefono'] ?? "Sin fono";
            });
          }
        })
        .catchError((e) {
          debugPrint("Firestore no disponible: $e");
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1F2C34),
      ),

      body: Padding(
        padding: const EdgeInsets.all(100),
        child: Column(
          children: [
            CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(
                FirebaseAuth.instance.currentUser?.photoURL ??
                    "https://i.pravatar.cc/150",
              ),
            ),

            const SizedBox(height: 50),

            Text("Usuario: $nombre"),
            const SizedBox(height: 10),
            Text("Email: $email"),
            const SizedBox(height: 10),
            Text("Teléfono: $telefono"),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2C34),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditarPerfil()),
                ).then((value) {
                  cargarDatos();
                });
              },
              icon: const Icon(Icons.edit),
              label: const Text(
                "Editar perfil",
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => cerrarSesion(),
              icon: const Icon(Icons.logout),
              label: const Text("Cerrar Sesión"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> cerrarSesion() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
}
