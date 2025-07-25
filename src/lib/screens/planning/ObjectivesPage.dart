import 'package:flutter/material.dart';

class ObjectivesPage extends StatefulWidget {
  @override
  State<ObjectivesPage> createState() => _ObjectivesPageState();
}

class _ObjectivesPageState extends State<ObjectivesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objetivos'),
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
