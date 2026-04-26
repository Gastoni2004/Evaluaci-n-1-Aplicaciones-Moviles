import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({super.key});

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController =
      TextEditingController(); //Controladores para los campos de texto
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _nameController.text = user.displayName ?? "";

    FirebaseFirestore.instance
        .collection("usuarios")
        .doc(user.uid)
        .get()
        .then((doc) {
          if (!mounted) return;

          setState(() {
            _phoneController.text = doc.data()?['telefono'] ?? "";
          });
        })
        .catchError((e) {
          print("ERROR AL CARGAR EDITAR: $e");
        });
  }

  Future<void> guardar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FocusScope.of(context).unfocus();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      print("Guardando en Firestore");

      await user.updateDisplayName(_nameController.text.trim());

      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(user.uid)
          .set({
            "nombre": _nameController.text.trim(),
            "telefono": _phoneController.text.trim(),
            "email": user.email,
          }, SetOptions(merge: true))
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              throw Exception("Timeout al guardar datos");
            },
          );
      print("Guardado exitoso");

      if (!mounted) return;

      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Datos guardados exitosamente"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      navigator.pop();
    } catch (e) {
      print("Error: $e");
      if (!mounted) return;

      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //Usuario actual
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1F2C34),
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(
                  user?.photoURL ?? "https://i.pravatar.cc/150",
                ),
              ),

              const SizedBox(height: 20),

              //Campo de nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),

              const SizedBox(height: 10),

              //Campo de teléfono
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Teléfono"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ingrese teléfono";
                  }

                  if (value.trim().length != 9 || !value.startsWith("9")) {
                    return "Debe tener 9 dígitos y empezar con 9";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              //Botón para guardar cambios
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2C34),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final form = _formKey.currentState;
                  if (form != null && form.validate()) {
                    await guardar();
                  }
                },
                child: const Text("Guardar cambios"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
