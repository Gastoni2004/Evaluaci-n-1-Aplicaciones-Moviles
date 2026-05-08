import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestor_de_herramientas/screens/perfil.dart';

DateTime ahora = DateTime.now();

class hola extends StatefulWidget {
  const hola({super.key});

  @override
  State<hola> createState() => _holaState();
}

class _holaState extends State<hola> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B141B),
      appBar: AppBar(
        title: Text(
          'Historial',
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

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('historial_entregas')
            .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay historial',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index];
              DateTime fecha = DateTime.now();

              if (data['fecha'] != null && data['fecha'] is Timestamp) {
                fecha = (data['fecha'] as Timestamp).toDate();
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  tileColor: const Color(0xFF1F2C34),
                  title: Text(
                    data['nombre'],
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Id: ${data['id']}",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "Fecha: ${fecha.day}/${fecha.month} ${fecha.hour}:${fecha.minute}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  trailing: Text(
                    data['estado'],
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
