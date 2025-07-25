import 'package:first_app/services/AccountServices.dart';
import 'package:first_app/services/CategoryServices.dart';
import 'package:first_app/services/TransactionServices.dart';
import 'package:first_app/utils/AvailableBanks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionViewPage extends StatefulWidget {
  final String? transactionId;
  final String type;
  const TransactionViewPage({
    super.key,
    required this.type,
    this.transactionId,
  });

  @override
  State<TransactionViewPage> createState() => _TransactionViewPageState();
}

class _TransactionViewPageState extends State<TransactionViewPage> {
  final TextEditingController valorController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? categoriaSelecionadaId;

  Map<String, dynamic>? categoriaSelecionadaMap;
  Map<String, dynamic>? recorrenciaSelecionada;

  DateTime? selectedDate;
  bool _loading = false;

  String? tipoSelecionado;
  Map<String, dynamic>? contaSelecionada;
  Map<String, dynamic>? categoriaSelecionada;

  int numeroParcelas = 0;
  dynamic subCategoriaSelecionada;
  bool isFixedExpense = false; // coloque isso no seu state
  bool isEffective = true; // coloque isso no seu state

  List<dynamic> allAccounts = [];
  List<dynamic> allCategories = [];

  @override
  void initState() {
    super.initState();
    tipoSelecionado = widget.type ?? 'Despesa';
    valorController.addListener(_formatarInput);

    recorrenciaSelecionada = recorrencias.firstWhere(
      (item) => item['label'] == 'Única',
      orElse: () => recorrencias.first,
    );

    if (widget.transactionId != null) {
      _getTransaction(widget.transactionId!);
    }

    selectedDate = DateTime.now();
    _dateController.text = _formatDate(selectedDate!);
    _loadingAccounts();
    _loadingCategorys();
  }

  //Accounts
  Future<void> _loadingAccounts() async {
    final services = AccountServices();
    final list = await services.getAccounts();
    setState(() {
      allAccounts = list;
    });
  }

  List<DropdownMenuItem<dynamic>> _buildContasDropdownItems() {
    return allAccounts.map((acc) {
      return DropdownMenuItem(
        value: acc,
        child: Text(
          // acc['alias']?.isNotEmpty == true ? acc['alias'] : 'Conta sem nome',
          (acc['alias'] != null && acc['alias'].toString().isNotEmpty)
              ? '${AvailableBanks.parseIntBank(acc['bank'])} ${acc['alias']}'
              : AvailableBanks.parseIntBank(acc['bank']),
        ),
      );
    }).toList();
  }

  //Categories

  Future<void> _loadingCategorys() async {
    final services = CategoryServices();
    final list = await services.fetchItems();
    setState(() {
      allCategories = list;
    });
  }

  List<DropdownMenuItem<String>> _buildCategoriaDropdownItems() {
    final items = <DropdownMenuItem<String>>[];

    for (var cat in allCategories) {
      final catId = cat['id'];
      // Categoria principal
      items.add(DropdownMenuItem(value: '$catId|', child: Text(cat['name'])));

      // Subcategorias
      for (var sub in cat['subCategories'] ?? []) {
        items.add(
          DropdownMenuItem(
            value: '$catId|${sub['id']}',
            child: Text('  • ${sub['name']}'),
          ),
        );
      }
    }

    return items;
  }

  //Recorrencia
  final List<Map<String, dynamic>> recorrencias = [
    {'label': 'Única', 'value': 'Single'},
    {'label': 'Diária', 'value': 'Daily'},
    {'label': 'Semanal', 'value': 'Weekly'},
    {'label': 'Mensal', 'value': 'Monthly'},
  ];
  List<DropdownMenuItem<Map<String, dynamic>>>
  _buildRecorrenciasDropdownItems() {
    return recorrencias.map((item) {
      return DropdownMenuItem(value: item, child: Text(item['label']));
    }).toList();
  }

  //FindTransaction
  Future<void> _getTransaction(String id) async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));

    // Define o tipo explicitamente como Map<String, dynamic>
    final Map<String, dynamic> categoriaMock = {
      'name': 'Transporte',
      'subCategories': [
        {'name': 'Uber'},
        {'name': 'Gasolina'},
      ],
    };

    final Map<String, dynamic> subCategoriaMock =
        (categoriaMock['subCategories'] as List)[0];

    setState(() {
      tipoSelecionado = 'Despesa';
      // contaSelecionada = 'Conta Corrente';

      categoriaSelecionadaMap = {
        'category': categoriaMock,
        'subCategory': subCategoriaMock,
      };

      categoriaSelecionada = categoriaMock[0];
      subCategoriaSelecionada = subCategoriaMock;

      numeroParcelas = 3;
      valorController.text = '1234,56';
      descricaoController.text = 'Uber mês de julho';
      _loading = false;
    });
  }

  Widget _buildDateSelector() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              final today = DateTime.now();
              _updateSelectedDate(today);
            },
            icon: const Icon(Icons.today),
            label: const Text('Hoje'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              final yesterday = DateTime.now().subtract(
                const Duration(days: 1),
              );
              _updateSelectedDate(yesterday);
            },
            icon: const Icon(Icons.history),
            label: const Text('Ontem'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_month),
            label: const Text('Outro...'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _updateSelectedDate(DateTime date) {
    setState(() {
      selectedDate = date;
      _dateController.text = DateFormat('dd/MM/yyyy').format(date);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  List<Color> _getGradientColorsByTipo(String? tipo) {
    if (tipo == 'Despesa') {
      return [Colors.red.shade400, Colors.redAccent];
    } else if (tipo == 'Receita') {
      return [Colors.green.shade400, Colors.greenAccent];
    } else {
      return [Colors.indigo, Colors.blueAccent];
    }
  }

  Color _getButtonColorByTipo(String? tipo) {
    if (tipo == 'Despesa') {
      return Colors.red;
    } else if (tipo == 'Receita') {
      return Colors.green;
    } else {
      return Colors.blue; // padrão
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F3F7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Situacai
                  SwitchListTile(
                    title: Text(
                      tipoSelecionado == 'Despesa' ? 'Pago' : 'Recebido',
                    ),
                    value: isEffective,
                    activeColor: tipoSelecionado == 'Despesa'
                        ? Colors.red
                        : Colors.green,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.shade400,
                    secondary: Icon(
                      isEffective ? Icons.check_circle : Icons.cancel,
                      color: isEffective
                          ? (tipoSelecionado == 'Despesa'
                                ? Colors.red
                                : Colors.green)
                          : Colors.grey,
                    ),
                    onChanged: (bool value) {
                      setState(() {
                        isEffective = value;
                      });
                    },
                  ),

                  //Data
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Campo de data (normal)
                            Expanded(
                              child: TextField(
                                controller: _dateController,
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.calendar_today),

                                  // Mantendo seu padrão, sem alterar decoration
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Chips de data
                            Wrap(
                              spacing: 6,
                              children: [
                                _buildDateChip('Hoje', () {
                                  _updateSelectedDate(DateTime.now());
                                }),
                                _buildDateChip('Ontem', () {
                                  _updateSelectedDate(
                                    DateTime.now().subtract(
                                      const Duration(days: 1),
                                    ),
                                  );
                                }),
                                // _buildDateChip('Outro...', () {
                                //   _selectDate(context);
                                // }),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: descricaoController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.description),
                      labelText: 'Descrição',
                    ),
                  ),
                  const SizedBox(height: 8),

                  //Conta
                  _buildDropdown(
                    label: 'Conta',
                    value: contaSelecionada,
                    items: _buildContasDropdownItems(),
                    icon: Icons.account_balance_wallet,
                    onChanged: (value) {
                      setState(() {
                        contaSelecionada = value;
                      });
                    },
                  ),

                  const SizedBox(height: 8),
                  _buildDropdown<String>(
                    label: 'Categoria',
                    value: categoriaSelecionadaId,
                    items: _buildCategoriaDropdownItems(),
                    icon: Icons.category,
                    onChanged: (value) {
                      setState(() {
                        categoriaSelecionadaId = value;

                        if (value != null) {
                          final parts = value.split('|');
                          final catId = parts[0];
                          final subId = parts.length > 1 ? parts[1] : null;

                          final categoria = allCategories.firstWhere(
                            (c) => c['id'] == catId,
                            orElse: () => null,
                          );

                          if (categoria != null) {
                            final subCategoria = subId != null
                                ? (categoria['subCategories'] as List?)
                                      ?.firstWhere(
                                        (s) => s['id'] == subId,
                                        orElse: () => null,
                                      )
                                : null;

                            categoriaSelecionadaMap = {
                              'category': categoria,
                              'subCategory': subCategoria,
                            };
                            categoriaSelecionada = categoria;
                            subCategoriaSelecionada = subCategoria;
                          } else {
                            // Categoria não encontrada, limpar seleção
                            categoriaSelecionadaMap = null;
                            categoriaSelecionada = null;
                            subCategoriaSelecionada = null;
                          }
                        }
                      });
                    },
                    selectedItemBuilder: (context) {
                      return _buildCategoriaDropdownItems().map((item) {
                        final parts = item.value!.split('|');
                        final catId = parts[0];
                        final subId = parts.length > 1 && parts[1].isNotEmpty
                            ? parts[1]
                            : null;

                        final categoria = allCategories.firstWhere(
                          (c) => c['id'] == catId,
                          orElse: () => {},
                        );
                        final subcategoria = subId != null
                            ? (categoria['subCategories'] as List?)?.firstWhere(
                                (s) => s['id'] == subId,
                                orElse: () => null,
                              )
                            : null;

                        final label = subcategoria != null
                            ? '${categoria['name']} > ${subcategoria['name']}'
                            : categoria['name'] ?? '';

                        return Text(label);
                      }).toList();
                    },
                  ),

                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDropdown<Map<String, dynamic>>(
                        label: 'Recorrência',
                        value: recorrenciaSelecionada,
                        items: _buildRecorrenciasDropdownItems(),
                        icon: Icons.repeat,
                        onChanged: (value) {
                          setState(() {
                            recorrenciaSelecionada = value;
                          });
                        },
                      ),

                      if (recorrenciaSelecionada?['label'] != 'Única') ...[
                        const SizedBox(height: 8),
                        SwitchListTile(
                          title: const Text('Despesa fixa'),
                          subtitle: const Text(
                            'Não será necessário informar a quantidade de vezes',
                          ),
                          // secondary: const Icon(Icons.repeat),
                          value: isFixedExpense,
                          onChanged: (bool value) {
                            setState(() {
                              isFixedExpense = value;
                            });
                          },
                        ),
                      ],

                      // const SizedBox(height: 16),
                      if (!isFixedExpense &&
                          recorrenciaSelecionada?['label'] != 'Única' &&
                          recorrenciaSelecionada?['label'] != 'Fixa')
                        Padding(
                          padding: const EdgeInsets.only(top: 0, bottom: 5),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.format_list_numbered),
                              labelText: 'Número de parcelas',
                            ),
                            onChanged: (value) {
                              final parsed = int.tryParse(value);
                              if (parsed != null && parsed > 0) {
                                setState(() => numeroParcelas = parsed);
                              }
                            },
                          ),
                        ),
                    ],
                  ),

                  //Salvar
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _salvar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getButtonColorByTipo(tipoSelecionado),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Salvar Transação',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getGradientColorsByTipo(tipoSelecionado),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context, true),
                ),
                const SizedBox(width: 8),
                Text(
                  'Nova $tipoSelecionado',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valorController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.poppins(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    'R\$ ',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                hintText: '0,00',
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 28),
              ),
              cursorColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required IconData icon,
    required ValueChanged<T?> onChanged,
    DropdownButtonBuilder? selectedItemBuilder,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(prefixIcon: Icon(icon), labelText: label),
      value: value,
      items: items,
      onChanged: onChanged,
      selectedItemBuilder: selectedItemBuilder,
      isExpanded: true, // <<< Isso ajuda a evitar overflow
    );
  }

  void _formatarInput() {
    final texto = valorController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final valorCentavos = int.tryParse(texto) ?? 0;
    final novoTexto = _formatarSaldo(valorCentavos);
    valorController
      ..removeListener(_formatarInput)
      ..text = novoTexto
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: novoTexto.length),
      )
      ..addListener(_formatarInput);
  }

  Widget _buildDateChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.grey.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  String _formatarSaldo(int centavos) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    );
    return formatter.format(centavos / 100);
  }

  void _salvar() {
    final saldo = double.tryParse(
      valorController.text.replaceAll('.', '').replaceAll(',', '.'),
    );
    final descricao = descricaoController.text;

    print(categoriaSelecionada);
    if (tipoSelecionado == null ||
        // contaSelecionada == null ||
        categoriaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    final serices = TransactionServices();
    if (tipoSelecionado == 'Receita') {
      serices.deposit(
        accountId: contaSelecionada!['id'],
        categoryId: categoriaSelecionada!['id'],
        subCategoryId: subCategoriaSelecionada?['id'],
        value: saldo!,
        date: selectedDate!,
        description: descricao,
        recurrence: recorrenciaSelecionada!['value'],
        totalOccurrences: numeroParcelas,
        isFixed: isFixedExpense,
        isEfetivado: isEffective,
      );
    } else if (tipoSelecionado == 'Despesa') {
      serices.withdraw(
        accountId: contaSelecionada!['id'],
        categoryId: categoriaSelecionada!['id'],
        subCategoryId: subCategoriaSelecionada?['id'],
        value: saldo!,
        date: selectedDate!,
        description: descricao,
        recurrence: recorrenciaSelecionada!['value'],
        totalOccurrences: numeroParcelas,
        isFixed: isFixedExpense,
        isEfetivado: isEffective,
      );
    }
    Navigator.pop(context, true);
  }
}
