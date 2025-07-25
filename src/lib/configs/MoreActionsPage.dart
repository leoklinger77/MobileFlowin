import 'package:first_app/screens/creditcard/CreditCardPage.dart';
import 'package:first_app/screens/investment/InvestimentPage.dart';
import 'package:first_app/screens/categories/CategoryPage.dart';
import 'package:first_app/screens/onbarding/signin/SignInPage.dart';
import 'package:first_app/screens/tags/TagsPage.dart';
import 'package:first_app/configs/ImportDataPage.dart';
import 'package:first_app/screens/planning/ObjectivesPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoreActionsPage extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const MoreActionsPage({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });
  @override
  State<MoreActionsPage> createState() => _MoreActionsPageState();
}

class _MoreActionsPageState extends State<MoreActionsPage> {
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
  }

  Future<void> _loadBiometricPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('use_biometrics') ?? false;
    setState(() {
      _biometricEnabled = enabled;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      final email = prefs.getString('email');
      if (email != null) {
        await prefs.setBool('use_biometrics', true);
        await prefs.setString('biometric_email', email);
      }
    } else {
      await prefs.remove('use_biometrics');
      await prefs.remove('biometric_email');
    }

    setState(() {
      _biometricEnabled = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Login com biometria ativado'
              : 'Login com biometria desativado',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6FC),
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true, // 👈 garante centralização real
        title: Text(
          'Mais Opções',
          style: TextStyle(
            fontWeight: FontWeight.w600, // mais encorpado
            fontSize: 20, // fonte maior
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // ação para abrir configurações
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _buildMenuItem(Icons.account_balance, 'Contas', () {
                widget.onTap(5);
              }),
              _buildMenuItem(Icons.credit_card, 'Cartões de Crédito', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreditCardPage()),
                );
              }),
              _buildMenuItem(Icons.flag, 'Objetivos', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ObjectivesPage()),
                );
              }),
              _buildMenuItem(Icons.trending_up, 'Investimentos', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => InvestimentPage()),
                );
              }),
              _buildMenuItem(Icons.category, 'Categorias', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CategoryPage()),
                );
              }),
              _buildMenuItem(Icons.label, 'Tags', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TagsPage()),
                );
              }),
              _buildMenuItem(Icons.file_upload, 'Importar Dados', () {
                // ação Importar
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ImportDataPage()),
                );
              }),
              _buildMenuItem(Icons.logout, 'Sair', () async {
                final prefs = await SharedPreferences.getInstance();
                // Opcional: remover token salvo, se tiver
                await prefs.remove('access_token');

                // Navegar para a tela de login, limpando a pilha
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInPage()),
                    (Route<dynamic> route) => false,
                  );
                }
              }),

              SwitchListTile(
                value: _biometricEnabled,
                onChanged: _toggleBiometric,
                title: const Text('Usar biometria no login'),
                activeColor: Colors.green,
                secondary: const Icon(Icons.fingerprint, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String titulo, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(titulo),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
