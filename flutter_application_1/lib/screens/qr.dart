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

  void azar() {
    List<Map<String, String>> disponibles = [];

    for (var h in herramienta) {
      bool yaEsta = false;
      for (var n in nueva) {
        if (h['id'] == n['id']) {
          yaEsta = true;
        }
      }
      if (yaEsta == false) {
        disponibles.add(h);
      }
    }

    if (disponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay más herramientas en el catálogo')),
      );
      Navigator.pop(context);
      return;
    }

    setState(() {
      var elegida = disponibles[Random().nextInt(disponibles.length)];
      nueva.add(elegida);
    });

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
                    onPressed: azar,
                    child: Icon(Icons.add, size: 30, color: Color(0xFF1F2C34)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
