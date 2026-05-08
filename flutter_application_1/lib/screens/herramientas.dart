import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestor_de_herramientas/screens/FormReport.dart';
import 'package:gestor_de_herramientas/screens/perfil.dart';
import 'package:gestor_de_herramientas/screens/qr.dart';

String idHerramienta = '';
DateTime ahora = DateTime.now();

class Herramientas extends StatefulWidget {
  const Herramientas({super.key});

  @override
  State<Herramientas> createState() => _HerramientasState();
}

class _HerramientasState extends State<Herramientas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B141B),

      appBar: AppBar(
        title: const Text(
          'Herramientas',
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
            .collection('herramientas_en_uso')
            .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay herramientas en uso',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: docs.length,

            itemBuilder: (context, index) {
              var data = docs[index];
              var docId = data.id;

              DateTime fecha = (data['fecha'] as Timestamp).toDate();

              return Padding(
                padding: const EdgeInsets.all(8.0),

                child: ListTile(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black, width: 1),

                    borderRadius: BorderRadius.circular(5),
                  ),

                  tileColor: const Color(0xFF1F2C34),

                  title: Text(
                    data['nombre'],
                    style: const TextStyle(color: Colors.white),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        "Fecha: ${fecha.day}/${fecha.month} ${fecha.hour}:${fecha.minute}",
                        style: const TextStyle(color: Colors.white),
                      ),

                      Text(
                        "Id: ${data['id']}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  trailing: SizedBox(
                    width: 110,

                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.report_problem_outlined,
                            color: Colors.white,
                          ),

                          onPressed: () {
                            idHerramienta = data['id'];
                            herramientaEnUso = data['nombre'];

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FormRep(),
                              ),
                            );
                          },
                        ),

                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),

                          onPressed: () async {
                            bool confirmar =
                                await showDialog(
                                  context: context,

                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmar'),

                                    content: const Text(
                                      '¿Deseas entregar esta herramienta?',
                                    ),

                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, false);
                                        },

                                        child: const Text('No'),
                                      ),

                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },

                                        child: const Text('Sí'),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;

                            if (!confirmar) return;

                            final messenger = ScaffoldMessenger.of(context);

                            await Future.wait([
                              FirebaseFirestore.instance
                                  .collection('historial_entregas')
                                  .add({
                                    'id': data['id'],
                                    'nombre': data['nombre'],
                                    'estado': 'Entregada',
                                    'fecha': DateTime.now(),
                                    'uid':
                                        FirebaseAuth.instance.currentUser!.uid,
                                    'usuario': FirebaseAuth
                                        .instance
                                        .currentUser!
                                        .email,
                                  }),

                              FirebaseFirestore.instance
                                  .collection('herramientas_en_uso')
                                  .doc(docId)
                                  .delete(),
                            ]);

                            if (!mounted) return;

                            messenger.showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text('Herramienta entregada'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1F2C34),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MobileScannerSimple(),
            ),
          );
        },

        child: const Icon(Icons.qr_code_outlined, color: Colors.white),
      ),
    );
  }
}
