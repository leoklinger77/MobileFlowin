import 'package:first_app/screens/HomePage.dart';
import 'package:first_app/configs/MoreActionsPage.dart';
import 'package:first_app/screens/account/AccountPage.dart';
import 'package:first_app/screens/creditcard/CreditCardPage.dart';
import 'package:first_app/screens/planning/PlanningPage.dart';
import 'package:first_app/screens/shared/AppScaffold.dart';
import 'package:first_app/screens/transaction/TransactionPage.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedIndex = 0;

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getPageByIndex(int index) {
    switch (index) {
      case 0:
        return HomePage(selectedIndex: index, onTap: _onTap);
      case 1:
        return TransactionPage(selectedIndex: index, onTap: _onTap);
      case 3:
        return PlanningPage(selectedIndex: index, onTap: _onTap);
      case 4:
        return MoreActionsPage(selectedIndex: index, onTap: _onTap);
      case 5:
        return AccountPage();
      case 6:
        return CreditCardPage();
      default:
        return HomePage(selectedIndex: index, onTap: _onTap);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppMenuScaffold(
      body: Column(
        children: [Expanded(child: _getPageByIndex(_selectedIndex))],
      ),
      selectedIndex: _selectedIndex > 4 ? 4 : _selectedIndex, // ✅ CORRETO
      onTap: _onTap,
    );
  }
}
