import 'package:flutter/material.dart';

class InvestimentPage extends StatefulWidget {
  @override
  State<InvestimentPage> createState() => _InvestimentPageState();
}

class _InvestimentPageState extends State<InvestimentPage> {  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investimentos'),
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
