import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestor_de_herramientas/screens/perfil.dart';

DateTime ahora = DateTime.now();

class reportes extends StatefulWidget {
  const reportes({super.key});

  @override
  State<reportes> createState() => _reportesState();
}

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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reportes')
            .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay reportes',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index];
              DateTime fecha = (data['fecha'] as Timestamp).toDate();

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  tileColor: const Color(0xFF1F2C34),
                  title: Text(
                    "${data['nombre']}",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Id: ${data['idHerramienta']}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        "Descripción: ${data['descripcion']}",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  trailing: Text(
                    "Fecha: ${fecha.day}/${fecha.month} ${fecha.hour}:${fecha.minute}",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
