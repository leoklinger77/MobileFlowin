import 'package:first_app/screens/account/AccountSkeletonLoader.dart';
import 'package:first_app/utils/AvailableBanks.dart';
import 'package:first_app/utils/AvailableColors.dart';
import 'package:first_app/services/AccountServices.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AccountViewPage extends StatefulWidget {
  final String? accountId;

  const AccountViewPage({Key? key, this.accountId}) : super(key: key);

  @override
  State<AccountViewPage> createState() => _AccountViewPageState();
}

class _AccountViewPageState extends State<AccountViewPage> {
  final List<String> bancos = AvailableBanks.bancos;
  final List<String> tiposConta = AvailableBanks.tiposConta;
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController saldoController = TextEditingController();

  bool _loading = false;
  int saldoCentavos = 0;
  String? bancoSelecionado;
  String? tipoContaSelecionado;
  Color? corSelecionada;
  bool exibirSaldo = true;

  @override
  void initState() {
    super.initState();
    if (widget.accountId != null) {
      _getAccount(widget.accountId!);
    }
    corSelecionada = Colors.blue;
    saldoController.addListener(_formatarInput);
  }

  Future<void> _getAccount(String accountId) async {
    setState(() => _loading = true); // começa o loading

    final service = AccountServices();
    final data = await service.getAccountById(accountId);

    setState(() {
      descricaoController.text = data['alias'] ?? '';
      tipoContaSelecionado = AvailableBanks.tiposConta[data['type'] ?? 0];
      bancoSelecionado = AvailableBanks.bancos[data['bank'] ?? 0];

      final corInt = data['color'] ?? Colors.blue.value;
      corSelecionada = Color(corInt);

      saldoController.text = (data['totalBalance'] ?? 0).toStringAsFixed(2);
      exibirSaldo = data['showBalanceOnHome'] ?? false;
      _loading = false; // terminou de carregar
    });
  }

  Future<void> _createAccount({
    required String alias,
    required int type,
    required int bank,
    required double initialBalance,
    required int color,
    required bool showBalanceOnHome,
  }) async {
    try {
      final service = AccountServices();
      await service.createAccount(
        alias: alias,
        type: type,
        bank: bank,
        initialBalance: initialBalance,
        color: color,
        showBalanceOnHome: showBalanceOnHome
      );
    } catch (e) {
      print('Erro ao criar categoria: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar categoria na API')),
      );
    }
  }

  Future<void> _updateAccount({
    required String id,
    required String alias,
    required int type,
    required int bank,
    required double initialBalance,
    required int color,
    required bool showBalanceOnHome,
  }) async {
    try {
      final service = AccountServices();
      await service.updateAccount(
        id: id,
        alias: alias,
        type: type,
        bank: bank,
        initialBalance: initialBalance,
        color: color,
        showBalanceOnHome: showBalanceOnHome
      );

      Navigator.pop(context, true); // volta após salvar
    } catch (e) {
      print('Erro ao atualizar conta: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao atualizar conta')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F3F7),
        body: AccountSkeletonLoader(),
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
                  DropdownButtonFormField<String>(
                    value: bancoSelecionado,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.account_balance),
                      labelText: 'Banco',
                    ),
                    items: bancos.map((banco) {
                      return DropdownMenuItem<String>(
                        value: banco,
                        child: Text(banco),
                      );
                    }).toList(),
                    onChanged: (valor) =>
                        setState(() => bancoSelecionado = valor),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: tipoContaSelecionado,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.wallet),
                      labelText: 'Tipo de Conta',
                    ),
                    items: tiposConta.map((tipo) {
                      return DropdownMenuItem<String>(
                        value: tipo,
                        child: Text(tipo),
                      );
                    }).toList(),
                    onChanged: (valor) =>
                        setState(() => tipoContaSelecionado = valor),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descricaoController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.description),
                      labelText: 'Apelido (opcional)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _abrirSeletorDeCores,
                    child: Row(
                      children: [
                        const Icon(Icons.color_lens),
                        const SizedBox(width: 12),
                        Text(
                          corSelecionada != null
                              ? 'Cor selecionada'
                              : 'Selecionar cor',
                        ),
                        const Spacer(),
                        if (corSelecionada != null)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: corSelecionada,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Exibir saldo na tela inicial'),
                      Switch(
                        value: exibirSaldo,
                        onChanged: (valor) =>
                            setState(() => exibirSaldo = valor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: salvarConta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: corSelecionada,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Salvar Conta',
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
          colors: [corSelecionada ?? Colors.indigo, Colors.blueAccent],
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
            // Topo com seta de voltar e título
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context, true),
                ),
                const SizedBox(width: 8),
                Text(
                  bancoSelecionado != null ? '$bancoSelecionado' : 'Nova Conta',
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
              controller: saldoController,
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

  String _formatarSaldo(int centavos) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '', // ← sem R$
      decimalDigits: 2,
    );
    return formatter.format(centavos / 100);
  }

  void _abrirSeletorDeCores() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        height: 300,
        child: GridView.count(
          crossAxisCount: 5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: AvailableColors.allColors.map((cor) {
            final selecionada = corSelecionada == cor;
            return GestureDetector(
              onTap: () {
                setState(() => corSelecionada = cor);
                Navigator.pop(context, true);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: cor,
                  shape: BoxShape.circle,
                  border: selecionada
                      ? Border.all(color: Colors.black, width: 2)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void salvarConta() {
    final saldo = double.tryParse(
      saldoController.text.replaceAll('.', '').replaceAll(',', '.'),
    );

    if (bancoSelecionado == null ||
        tipoContaSelecionado == null ||
        corSelecionada == null ||
        saldo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    final bancoIndex = AvailableBanks.parseStringBank(bancoSelecionado!);
    final tipoContaIndex = AvailableBanks.tiposConta.indexOf(
      tipoContaSelecionado!,
    );
    final corInt = corSelecionada!.value;

    if (bancoIndex == -1 || tipoContaIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banco ou tipo de conta inválido')),
      );
      return;
    }

    if (widget.accountId != null) {
      // Editar
      _updateAccount(
        id: widget.accountId!,
        alias: descricaoController.text,
        bank: bancoIndex,
        color: corInt,
        initialBalance: saldo,
        type: tipoContaIndex,
        showBalanceOnHome: exibirSaldo,
      );
    } else {
      // Criar
      _createAccount(
        alias: descricaoController.text,
        bank: bancoIndex,
        color: corInt,
        initialBalance: saldo,
        type: tipoContaIndex,
        showBalanceOnHome: exibirSaldo,
      );
    }
  }

  void _formatarInput() {
    final texto = saldoController.text.replaceAll(RegExp(r'[^0-9]'), '');

    saldoCentavos = int.tryParse(texto) ?? 0;

    final novoTexto = _formatarSaldo(saldoCentavos);

    saldoController
      ..removeListener(_formatarInput)
      ..text = novoTexto
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: novoTexto.length),
      )
      ..addListener(_formatarInput);
  }
}
