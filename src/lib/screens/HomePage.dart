import 'package:first_app/services/UserSession.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const HomePage({super.key, required this.selectedIndex, required this.onTap});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final secureStorage = FlutterSecureStorage();
  final _firstName = UserSession().firstName ?? 'Usuário';  

  int currentMonthIndex = DateTime.now().month - 1;
  final List<String> months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  final List<Map<String, dynamic>> creditCards = [
    {'brand': 'Mastercard', 'color': Colors.deepPurple, 'number': '**** 1234'},
    {'brand': 'Visa', 'color': Colors.indigo, 'number': '**** 5678'},
  ];

  void _prevMonth() =>
      setState(() => currentMonthIndex = (currentMonthIndex - 1 + 12) % 12);
  void _nextMonth() =>
      setState(() => currentMonthIndex = (currentMonthIndex + 1) % 12);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // importante!
      backgroundColor: const Color(0xFFF2F3F7),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                _buildPieChartCarousel(),
                const SizedBox(height: 8),
                _buildSection('Cartões de crédito'),
                _buildCreditCardCarousel(),
                const SizedBox(height: 8),
                _buildSection('Orçamento'),
                _buildCard('Gráfico de Orçamento em construção...'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
            // Topo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Olá, ${_firstName ?? 'Usuário'} 👋',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Text(
                      'Bem-vindo de volta!',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.notifications_none, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 2),

            // Navegação de mês
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: _prevMonth,
                ),
                Text(
                  months[currentMonthIndex],
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 2),

            // Saldo
            Text(
              'Saldo em contas',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
            GestureDetector(
              onTap: () => widget.onTap(5),
              child: Text(
                'R\$ 3.000,00',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Entradas / Saídas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBalanceItem(
                  label: 'Entrada',
                  value: 'R\$ 2.500,00',
                  icon: Icons.arrow_downward_rounded,
                  color: const Color(0xFF4CAF50),
                  background: const Color(0x1A4CAF50),
                ),
                _buildBalanceItem(
                  label: 'Saída',
                  value: 'R\$ 1.200,00',
                  icon: Icons.arrow_upward_rounded,
                  color: const Color(0xFFF44336),
                  background: const Color(0x1AF44336),
                ),
              ],
            ),
          ],
        ),
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

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCard(String content) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(content, style: GoogleFonts.poppins()),
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.poppins(fontSize: 12)),
      ],
    );
  }

  Widget _buildPieChartCarousel() {
    final List<Map<String, dynamic>> chartData = [
      {
        'title': 'Despesas por Categoria',
        'sections': [
          PieChartSectionData(
            value: 40,
            color: Color(0xFF42A5F5),
            radius: 50,
            title: '40%',
            titleStyle: GoogleFonts.poppins(color: Colors.white),
          ),
          PieChartSectionData(
            value: 30,
            color: Color(0xFFFFA726),
            radius: 50,
            title: '30%',
            titleStyle: GoogleFonts.poppins(color: Colors.white),
          ),
          PieChartSectionData(
            value: 20,
            color: Color(0xFF66BB6A),
            radius: 50,
            title: '20%',
            titleStyle: GoogleFonts.poppins(color: Colors.white),
          ),
          PieChartSectionData(
            value: 10,
            color: Color(0xFFBDBDBD),
            radius: 50,
            title: '10%',
            titleStyle: GoogleFonts.poppins(color: Colors.white),
          ),
        ],
        'legends': [
          {'label': 'Alimentação', 'color': Color(0xFF42A5F5)},
          {'label': 'Transporte', 'color': Color(0xFFFFA726)},
          {'label': 'Lazer', 'color': Color(0xFF66BB6A)},
          {'label': 'Outros', 'color': Color(0xFFBDBDBD)},
        ],
      },
      {
        'title': 'Receitas por Categoria',
        'sections': [
          PieChartSectionData(
            value: 60,
            color: Color(0xFF66BB6A),
            radius: 50,
            title: '60%',
            titleStyle: GoogleFonts.poppins(color: Colors.white),
          ),
          PieChartSectionData(
            value: 40,
            color: Color(0xFF42A5F5),
            radius: 50,
            title: '40%',
            titleStyle: GoogleFonts.poppins(color: Colors.white),
          ),
        ],
        'legends': [
          {'label': 'Salário', 'color': Color(0xFF66BB6A)},
          {'label': 'Outros', 'color': Color(0xFF42A5F5)},
        ],
      },
    ];

    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: chartData.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, index) {
          final data = chartData[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          data['title'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 40,
                              startDegreeOffset: 180,
                              sections: List<PieChartSectionData>.from(
                                data['sections'],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 4,
                          children: List<Widget>.from(
                            data['legends'].map(
                              (legend) => _buildLegendDot(
                                legend['label'],
                                legend['color'],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreditCardCarousel() {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: creditCards.length,
        controller: PageController(viewportFraction: 0.85),
        itemBuilder: (context, index) {
          final card = creditCards[index];
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Card(
              color: card['color'],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      card['brand'],
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        card['number'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
