import 'package:first_app/screens/transaction/TransactionViewPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class AppMenuScaffold extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final Function(int) onTap;

  const AppMenuScaffold({
    Key? key,
    required this.body,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.green,
        children: [
          SpeedDialChild(
            child: Icon(Icons.compare_arrows),
            label: 'Transferência',
            onTap: () {
              // Navega pra transferência
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.attach_money),
            label: 'Receita',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TransactionViewPage(type: 'Receita',),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.credit_card),
            label: 'Despesa no Cartão',
            onTap: () {
              // Navega pra despesa cartão
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.money_off),
            label: 'Despesa',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TransactionViewPage(type: 'Despesa',),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Transações'),
          BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Planejamento',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Mais'),
        ],
      ),
    );
  }
}
