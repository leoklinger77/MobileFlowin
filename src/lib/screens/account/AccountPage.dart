import 'package:first_app/utils/AvailableBanks.dart';
import 'package:first_app/screens/account/AccountViewPage.dart';
import 'package:first_app/services/AccountServices.dart';
import 'package:first_app/utils/AvailableMonth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountPage extends StatefulWidget {
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int _mesSelecionado = DateTime.now().month - 1;

  final List<String> _meses = AvailableMonth.month;

  List<Map<String, dynamic>> _contas = [];
  bool _isLoading = true;

  Future<void> _loadAccounts() async {
    try {
      final service = AccountServices();
      final response = await service.getAccounts(month: '');

      final contasConvertidas = response.map<Map<String, dynamic>>((item) {
        final bankIndex = item['bank'] as int;
        final colorInt = item['color'] ?? Colors.blue.value;
        final alias = item['alias'] as String;
        final color = Color(colorInt);

        // Escolhe ícone com base no nome do banco
        final nomeBanco = AvailableBanks.parseIntBank(bankIndex);
        // final icone = _getIconeBanco(nomeBanco);

        return {
          'id': item['id'],
          'nome': nomeBanco,
          'icone': Icons.account_balance,
          'alias': alias,
          'color': color,
          'saldoAtual': item['totalBalance'] ?? 0.0,
          'saldoPrevisto': item['expectedBalance'] ?? 0.0,
        };
      }).toList();

      setState(() {
        _contas = contasConvertidas;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar contas: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao carregar contas')));
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      _mesSelecionado = (_mesSelecionado - 1 + _meses.length) % _meses.length;
    });
  }

  void _goToNextMonth() {
    setState(() {
      _mesSelecionado = (_mesSelecionado + 1) % _meses.length;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    double saldoTotalAtual = _contas.fold(
      0.0,
      (sum, c) => sum + c['saldoAtual'],
    );
    double saldoTotalPrevisto = _contas.fold(
      0.0,
      (sum, c) => sum + c['saldoPrevisto'],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // Topo com título + mês + saldo total dentro do azul degradê
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3366FF), Color(0xFF00C6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título e botão "+"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Minhas Contas',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AccountViewPage(),
                            ),
                          );

                          if (result == true) {
                            await _loadAccounts(); // ou fetchAccounts(), ou qualquer função que você usa para buscar os dados
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Navegação de mês
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                        ),
                        onPressed: _goToPreviousMonth,
                      ),
                      Text(
                        _meses[_mesSelecionado],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onPressed: _goToNextMonth,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Saldo total atual e previsto — estilo TransactionPage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBalanceItem(
                        label: 'Saldo atual',
                        value: 'R\$ ${saldoTotalAtual.toStringAsFixed(2)}',
                        icon: Icons.account_balance_wallet_outlined,
                        color: Colors.white,
                        background: Colors.white.withOpacity(0.2),
                      ),
                      _buildBalanceItem(
                        label: 'Saldo previsto',
                        value: 'R\$ ${saldoTotalPrevisto.toStringAsFixed(2)}',
                        icon: Icons.trending_up,
                        color: Colors.white,
                        background: Colors.white.withOpacity(0.2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Lista de contas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    itemCount: _contas.length,
                    itemBuilder: (context, index) {
                      final conta = _contas[index];
                      return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AccountViewPage(accountId: conta['id']),
                            ),
                          );

                          if (result == true) {
                            await _loadAccounts();
                          }
                        },

                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: conta['color'],
                                  child: Icon(
                                    conta['icone'],
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        conta['alias'].isNotEmpty
                                            ? '${conta['nome']} • ${conta['alias']}'
                                            : conta['nome'],
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Saldo atual: R\$ ${conta['saldoAtual'].toStringAsFixed(2)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      Text(
                                        'Saldo previsto: R\$ ${conta['saldoPrevisto'].toStringAsFixed(2)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color background,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: background,
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
