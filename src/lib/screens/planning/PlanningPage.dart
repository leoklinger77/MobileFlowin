
import 'package:flutter/material.dart';

class PlanningPage extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const PlanningPage({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });
  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Em brene aqui estaram seus planejamentos 💸', style: TextStyle(fontSize: 18)),
    );
  }
}
