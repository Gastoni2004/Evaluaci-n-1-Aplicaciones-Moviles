import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestor_de_herramientas/screens/perfil.dart';

DateTime ahora = DateTime.now();

class reportes extends StatefulWidget {
  const reportes({super.key});

  @override
  State<reportes> createState() => _reportesState();
}

List<String> nueva = [];

final List<Map<String, String>> listaReportes = [];

class _reportesState extends State<reportes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B141B),
      appBar: AppBar(
        title: Text(
          'Reportes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1F2C34),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PerfilUsuario()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser?.photoURL ??
                      "https://i.pravatar.cc/150",
                ),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: listaReportes.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    tileColor: const Color(0xFF1F2C34),
                    title: Text(
                      listaReportes[index]['nombre']!,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Id: ${listaReportes[index]['id']!}",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "Descripción: ${listaReportes[index]['reporte']!}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    trailing: Text(
                      "Fecha: ${ahora.year}-${ahora.month}-${ahora.day}",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
