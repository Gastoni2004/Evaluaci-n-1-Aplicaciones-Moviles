import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:math';

final List<Map<String, String>> herramienta = [
  {'id': 'CHI-001', 'nombre': 'Esmeril Angular'},
  {'id': 'CHI-002', 'nombre': 'Rotomartillo(Bosch)'},
  {'id': 'CHI-003', 'nombre': 'Martillo'},
  {'id': 'CHI-004', 'nombre': 'Taladro percutor(Stanley)'},
  {'id': 'CHI-005', 'nombre': 'Nivel de Mano de Aluminio'},
  {'id': 'CHI-006', 'nombre': 'Máquina de soldar'},
  {'id': 'CHI-007', 'nombre': 'Carretilla'},
  {'id': 'CHI-008', 'nombre': 'Picota'},
  {'id': 'CHI-009', 'nombre': 'Serrucho Carpintero'},
  {'id': 'CHI-010', 'nombre': 'Serrucho Eléctrico'},
];

final List<Map<String, String>> nueva = [];

List<Map<String, String>> historialEntregas = [];
var herramientaAzar = herramienta[Random().nextInt(herramienta.length)];

class MobileScannerSimple extends StatefulWidget {
  const MobileScannerSimple({super.key});

  @override
  State<MobileScannerSimple> createState() => _MobileScannerSimpleState();
}

class _MobileScannerSimpleState extends State<MobileScannerSimple> {
  Barcode? _barcode;

  bool _isLoading = false;

  Widget _barcodePreview(Barcode? value) {
    if (value == null) {
      return const Text(
        'Encuadre el código QR ',
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white),
      );
    }

    return Text(
      value.displayValue ?? 'No display value.',
      overflow: TextOverflow.fade,
      style: const TextStyle(color: Colors.white),
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted) {
      setState(() {
        _barcode = barcodes.barcodes.firstOrNull;
      });
    }
  }

  Future<void> azar() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    var elegida = herramienta[Random().nextInt(herramienta.length)];

    var query = await FirebaseFirestore.instance
        .collection('herramientas_en_uso')
        .where('id', isEqualTo: elegida['id'])
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (query.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta herramienta ya está en uso'),
          backgroundColor: Colors.orange,
        ),
      );

      setState(() => _isLoading = false);
      return;
    }

    await FirebaseFirestore.instance.collection('herramientas_en_uso').add({
      'id': elegida['id'],
      'nombre': elegida['nombre'],
      'fecha': DateTime.now(),
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'usuario': FirebaseAuth.instance.currentUser!.email,
    });

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Herramienta Registrada'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2C34),
      body: Stack(
        children: [
          MobileScanner(onDetect: _handleBarcode),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 100,
              color: const Color.fromRGBO(0, 0, 0, 0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: Center(child: _barcodePreview(_barcode))),
                  ElevatedButton(
                    onPressed: _isLoading ? null : azar,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20)
                        : const Icon(
                            Icons.add,
                            size: 30,
                            color: Color(0xFF1F2C34),
                          ),
                  ),
                ],
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
      ),
    );
  }
}
