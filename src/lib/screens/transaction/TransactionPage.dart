import 'package:first_app/services/AccountServices.dart';
import 'package:first_app/services/CategoryServices.dart';
import 'package:intl/intl.dart';
import 'package:first_app/services/TransactionServices.dart';
import 'package:first_app/utils/AvailableBanks.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionPage extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const TransactionPage({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final ScrollController _scrollController = ScrollController();
  bool _didScrollToToday = false;

  String _filtroSelecionado = 'Despesa';
  int _contaSelecionadaIndex = 0;

  // offset do mês relativo ao mês atual (0 = mês atual, +1 = mês seguinte, -1 = mês anterior, etc)
  int _mesSelecionado = 0;

  List<dynamic> transactions = [];
  bool isLoadingTransactions = false;
  Map<DateTime, List<dynamic>> grouped = {};
  double endOfMonthBalance = 0;
  double balanceOfTheMonth = 0;

  final List<String> _filtros = ['Despesa', 'Receita', 'Transação'];

  List<dynamic> allAccounts = [];
  List<dynamic> allCategories = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_didScrollToToday) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_didScrollToToday) {
            _scrollToToday(grouped.keys.toList());
            _didScrollToToday = true;
          }
        });
        _didScrollToToday = true;
      }
    });

    _loadingCategorys();
    _loadingAccounts();
  }

  Future<void> _loadingCategorys() async {
    final services = CategoryServices();
    final list = await services.fetchItems();
    setState(() {
      allCategories = list;
    });
  }

  Future<void> _loadingAccounts() async {
    final services = AccountServices();
    final list = await services.getAccounts();
    setState(() {
      allAccounts = list;
      // Garante que o índice da conta esteja válido após carregar
      if (_contaSelecionadaIndex >= allAccounts.length) {
        _contaSelecionadaIndex = 0;
      }
    });

    await _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (allAccounts.isEmpty) return;

    setState(() => isLoadingTransactions = true);

    final service = TransactionServices();

    final accountId = allAccounts[_contaSelecionadaIndex]['id'];

    final selectedDate = getDateFromOffset(_mesSelecionado);
    final start = DateTime(selectedDate.year, selectedDate.month, 1);
    final end = DateTime(selectedDate.year, selectedDate.month + 1, 0);

    final type = _filtroSelecionado == 'Despesa'
        ? 2
        : _filtroSelecionado == 'Receita'
        ? 1
        : 0;

    final result = await service.getListTransaction(
      accountId: accountId,
      type: type,
      start: start,
      end: end,
    );

    final List<dynamic> list = result['transactions'];
    endOfMonthBalance = (result['endOfMonthBalance'] as num).toDouble();
    balanceOfTheMonth = (result['balanceOfTheMonth'] as num).toDouble();

    setState(() {
      transactions = list;
      isLoadingTransactions = false;

      // Aqui você pode usar os valores de saldo como quiser:
      print('Saldo final do mês: $endOfMonthBalance');
      print('Saldo do mês: $balanceOfTheMonth');

      final Map<DateTime, List<dynamic>> groupedMap = {};
      for (var tx in list) {
        final date = DateTime.parse(tx['date']);
        final onlyDate = DateTime(date.year, date.month, date.day);
        groupedMap.putIfAbsent(onlyDate, () => []).add(tx);
      }

      grouped = Map.fromEntries(
        groupedMap.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // Topo azul com degradê e borda arredondada + padding maior
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3366FF), Color(0xFF00C6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seleção de conta centralizada
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                        ),
                        onPressed: allAccounts.isEmpty
                            ? null
                            : () {
                                setState(() {
                                  _contaSelecionadaIndex--;
                                  if (_contaSelecionadaIndex < 0) {
                                    _contaSelecionadaIndex =
                                        allAccounts.length - 1;
                                  }
                                });
                                _loadTransactions();
                              },
                      ),
                      if (allAccounts.isNotEmpty)
                        Text(
                          (() {
                            final conta = allAccounts[_contaSelecionadaIndex];
                            final alias = conta['alias'];
                            final bankName = AvailableBanks.parseIntBank(
                              conta['bank'],
                            );
                            return (alias != null &&
                                    alias.toString().isNotEmpty)
                                ? '$bankName $alias'
                                : bankName;
                          })(),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onPressed: allAccounts.isEmpty
                            ? null
                            : () {
                                setState(() {
                                  _contaSelecionadaIndex++;
                                  if (_contaSelecionadaIndex >=
                                      allAccounts.length) {
                                    _contaSelecionadaIndex = 0;
                                  }
                                });
                                _loadTransactions();
                              },
                      ),
                    ],
                  ),

                  // Linha filtros + mês
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filtroSelecionado,
                          iconEnabledColor: Colors.white,
                          dropdownColor: Colors.blueAccent,
                          style: GoogleFonts.poppins(color: Colors.white),
                          items: _filtros
                              .map(
                                (f) =>
                                    DropdownMenuItem(value: f, child: Text(f)),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _filtroSelecionado = value;
                              });
                              _loadTransactions();
                            }
                          },
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _mesSelecionado--;
                              });
                              _loadTransactions();
                            },
                          ),
                          Text(
                            getMonthYearLabel(_mesSelecionado),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _mesSelecionado++;
                              });
                              _loadTransactions();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Saldo atual e balanço mensal com ícones e texto branco
                 Center(
  child: IntrinsicWidth(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBalanceItem(
          label: _filtroSelecionado == 'Despesa'
              ? 'Pagas'
              : _filtroSelecionado == 'Receita'
                  ? 'Recebidas'
                  : 'Saldo atual',
          value: currencyFormat.format(balanceOfTheMonth),
          icon: _filtroSelecionado == 'Despesa'
              ? Icons.arrow_circle_down_outlined
              : _filtroSelecionado == 'Receita'
                  ? Icons.arrow_circle_up_outlined
                  : Icons.account_balance_wallet_outlined,
          color: Colors.white,
          background: Colors.white.withOpacity(0.2),
        ),
        const SizedBox(width: 64), // valor pequeno e fluido
        _buildBalanceItem(
          label: _filtroSelecionado == 'Despesa'
              ? 'Pendentes'
              : _filtroSelecionado == 'Receita'
                  ? 'Pendentes'
                  : 'Balanço mensal',
          value: currencyFormat.format(endOfMonthBalance),
          icon: _filtroSelecionado == 'Despesa'
              ? Icons.schedule
              : _filtroSelecionado == 'Receita'
                  ? Icons.schedule
                  : Icons.trending_down,
          color: Colors.white,
          background: Colors.white.withOpacity(0.2),
        ),
      ],
    ),
  ),
),

                ],
              ),
            ),
          ),

          // Conteúdo / lista de transações
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [_buildConteudoPorTipo()],
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
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _scrollToToday(List<DateTime> dates) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final index = dates.indexWhere(
      (date) =>
          date.year == todayOnly.year &&
          date.month == todayOnly.month &&
          date.day == todayOnly.day,
    );

    if (index != -1) {
      final estimatedHeight = 60.0 + 100.0;
      _scrollController.animateTo(
        index * estimatedHeight,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required bool isExpense,
    required String status,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isExpense
            ? Colors.red.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        child: Icon(icon, color: isExpense ? Colors.red : Colors.green),
      ),
      title: Text(title, style: GoogleFonts.poppins()),
      subtitle: Text(subtitle),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: isExpense ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                status == 'Pendente' ? Icons.close : Icons.check_circle,
                color: status == 'Pendente' ? Colors.redAccent : Colors.green,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(status, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConteudoPorTipo() {
    if (isLoadingTransactions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transactions.isEmpty || grouped.isEmpty) {
      return const Center(child: Text('Nenhuma transação encontrada.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        final date = entry.key;
        final formattedDate =
            DateFormat.EEEE('pt_BR').format(date).capitalize() +
            ', ' +
            DateFormat('dd/MM').format(date);
        final items = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((tx) {
              final isExpense = tx['type'] == 2;
              final status = tx['situation'] == 0 ? 'Pendente' : 'Pago';

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildTransactionItem(
                  icon: Icons.monetization_on,
                  title: tx['description']?.toString().isNotEmpty == true
                      ? tx['description']
                      : 'Sem descrição',
                  subtitle: _getCategoryFullName(
                    tx['categoryId'],
                    tx['subCategoryId'],
                  ),
                  value:
                      "${isExpense ? '-' : '+'} R\$ ${tx['value'].toStringAsFixed(2).replaceAll('.', ',')}",
                  isExpense: isExpense,
                  status: status,
                ),
              );
            }).toList(),
          ],
        );
      }).toList(),
    );
  }

  String _getCategoryFullName(dynamic categoryId, dynamic subCategoryId) {
    if (categoryId == null) return 'Sem categoria';

    try {
      final cat = allCategories.firstWhere((c) => c['id'] == categoryId);
      final catName = cat['name'] ?? 'Sem categoria';

      if (subCategoryId == null) return catName;

      final subcats = cat['subCategories'] as List<dynamic>?;

      if (subcats != null) {
        try {
          final subcat = subcats.firstWhere((s) => s['id'] == subCategoryId);
          final subcatName = subcat['name'] ?? '';
          if (subcatName.isNotEmpty) {
            return '$catName > $subcatName';
          }
        } catch (_) {
          // subcategoria não encontrada
        }
      }

      return catName;
    } catch (e) {
      return 'Sem categoria';
    }
  }

  String getMonthYearLabel(int offset) {
    final date = getDateFromOffset(offset);
    return DateFormat('MMM yy', 'pt_BR').format(date).capitalize();
  }

  DateTime getDateFromOffset(int offset) {
    final now = DateTime.now();
    final year = now.year + ((now.month - 1 + offset) ~/ 12);
    var month = ((now.month - 1 + offset) % 12) + 1;
    // Ajuste caso mês seja negativo após módulo (ex: -1 % 12 = -1)
    if (month <= 0) month += 12;
    return DateTime(year, month);
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
