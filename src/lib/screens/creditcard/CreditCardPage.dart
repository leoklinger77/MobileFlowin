import 'package:flutter/material.dart';

class CreditCardPage extends StatefulWidget {
  @override
  State<CreditCardPage> createState() => _CreditCardPageState();
}

class _CreditCardPageState extends State<CreditCardPage> {  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas'),
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
