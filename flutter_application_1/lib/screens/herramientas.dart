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
        title: Text(
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: nueva.length,
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
                      nueva[index]['nombre']!,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Fecha: ${ahora.year}-${ahora.month}-${ahora.day}",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "Id: ${nueva[index]['id']!}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 110,
                      child: Row(
                        spacing: 12,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(
                              Icons.report_problem_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              herramientaEnUso = nueva[index]['nombre']!;
                              idHerramienta = nueva[index]['id']!;
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => const FormRep(),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              Map<String, String> herramientaEntregada =
                                  nueva[index];
                              String nombre = herramientaEntregada['nombre']!;
                              setState(() {
                                historialEntregas.add({
                                  'id': herramientaEntregada['id']!,
                                  'nombre': nombre,
                                  'estado': 'Entregada',
                                  'fecha':
                                      "${ahora.day}/${ahora.month} ${ahora.hour}:${ahora.minute}",
                                });
                                nueva.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
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
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1F2C34),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const MobileScannerSimple(),
            ),
          ).then((_) {
            setState(() {});
          });
        },
        child: Icon(Icons.qr_code_outlined, color: Colors.white),
      ),
    );
  }
}
