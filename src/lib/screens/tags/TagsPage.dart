import 'package:flutter/material.dart';

class TagsPage extends StatefulWidget {
  @override
  State<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
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
