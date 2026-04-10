import 'package:flutter/material.dart';
import 'package:gestor_de_herramientas/screens/herramientas.dart';
import 'package:gestor_de_herramientas/screens/reportes.dart';

String herramientaEnUso = '';

DateTime ahora = DateTime.now();

class FormRep extends StatefulWidget {
  const FormRep({super.key});

  @override
  State<FormRep> createState() => _FormRepState();
}

class _FormRepState extends State<FormRep> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              const Icon(
                Icons.report_problem_outlined,
                size: 90,
                color: Colors.white,
              ),
              const SizedBox(height: 50),
              Text(
                'Reporte',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 50),
              TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Escriba El Reporte',
                  border: OutlineInputBorder(),
                ),

                onSaved: (value) {
                  if (value != null) {
                    setState(() {
                      listaReportes.add({
                        'nombre': herramientaEnUso,
                        'reporte': value,
                        'id': idHerramienta,
                        'fecha': "${ahora.day}/${ahora.month}/${ahora.year}",
                        'hora': "${ahora.hour}:${ahora.minute}",
                      });
                    });
                  }
                },

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa texto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    FocusScope.of(context).unfocus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reporte Enviado!')),
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
    );
  }
}
