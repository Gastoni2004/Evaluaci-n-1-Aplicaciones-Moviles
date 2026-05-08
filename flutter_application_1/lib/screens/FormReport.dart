import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestor_de_herramientas/screens/herramientas.dart';

String herramientaEnUso = '';

DateTime ahora = DateTime.now();

class FormRep extends StatefulWidget {
  const FormRep({super.key});

  @override
  State<FormRep> createState() => _FormRepState();
}

class _FormRepState extends State<FormRep> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _descController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xFF0B141B),
          body: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2C34),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Text(
                    'Reporte',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Escriba el reporte sobre la herramienta defectuosa',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 50),
                  TextFormField(
                    controller: _descController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Escriba el reporte',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor escriba el reporte';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              _formKey.currentState?.save();
                              FocusScope.of(context).unfocus();

                              setState(() => _isLoading = true);
                              await Future.delayed(const Duration(seconds: 1));
                              await FirebaseFirestore.instance
                                  .collection('reportes')
                                  .add({
                                    'idHerramienta': idHerramienta,
                                    'nombre': herramientaEnUso,
                                    'descripcion': _descController.text,
                                    'fecha': DateTime.now(),
                                    'uid':
                                        FirebaseAuth.instance.currentUser!.uid,
                                    'usuario': FirebaseAuth
                                        .instance
                                        .currentUser!
                                        .email,
                                  });

                              if (!mounted) return;

                              setState(() => _isLoading = false);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Reporte Enviado!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                    child: const Text('Enviar'),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
