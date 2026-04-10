import 'package:flutter/material.dart';
import 'qr.dart';

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
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: historialEntregas.length,
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
                      historialEntregas[index]['nombre']!,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Id: ${historialEntregas[index]['id']!}",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "Fecha: ${ahora.year}-${ahora.month}-${ahora.day} Hora: ${ahora.hour}:${ahora.minute}:${ahora.second}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    trailing: Text(
                      historialEntregas[index]['estado']!,
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
