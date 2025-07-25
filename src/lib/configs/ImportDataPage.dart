import 'package:flutter/material.dart';

class ImportDataPage extends StatefulWidget {
  @override
  State<ImportDataPage> createState() => _ImportDataPageState();
}

class _ImportDataPageState extends State<ImportDataPage> {  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar dados'),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: true,
      ),
      body: Text(
        'Em brene aqui estaram seus planejamentos 💸',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
