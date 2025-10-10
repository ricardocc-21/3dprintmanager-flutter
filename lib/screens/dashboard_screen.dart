import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../db/DatabaseHelper.dart';
import '../../models/impresion.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Impresion> _impresiones = [];
  double _totalPeso = 0;
  double _totalHoras = 0;
  int _totalImpresiones = 0;
  Map<String, double> _filamentoPorColor = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;
    final impresiones = await db.getImpresiones();

    double pesoTotal = 0;
    double horasTotal = 0;
    Map<String, double> porColor = {};

    for (var imp in impresiones) {
      pesoTotal += imp.peso;
      horasTotal += imp.tiempo.inHours.toDouble();

      // Agrupar por material (puedes adaptar según tus datos)
      final filamento = await db.getFilamento(imp.filamentoId);
      if (filamento != null) {
        porColor[filamento.color] =
            (porColor[filamento.color] ?? 0) + imp.peso;
      }
    }

    setState(() {
      _impresiones = impresiones;
      _totalPeso = pesoTotal;
      _totalHoras = horasTotal;
      _totalImpresiones = impresiones.length;
      _filamentoPorColor = porColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSummaryCards(),
              const SizedBox(height: 20),
              _buildBarChart(),
              const SizedBox(height: 20),
              _buildPieChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _summaryCard(Icons.print, 'Impresiones', _totalImpresiones.toString()),
        _summaryCard(Icons.timer, 'Horas', _totalHoras.toStringAsFixed(1)),
        _summaryCard(Icons.scale, 'Peso (g)', _totalPeso.toStringAsFixed(0)),
      ],
    );
  }

  Widget _summaryCard(IconData icon, String label, String value) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    if (_impresiones.isEmpty) {
      return const Center(child: Text('No hay datos para mostrar'));
    }

    // Agrupar impresiones por mes
    final Map<String, int> impresionesPorMes = {};
    for (var imp in _impresiones) {
      final mes = DateFormat('MMM').format(imp.fecha);
      impresionesPorMes[mes] = (impresionesPorMes[mes] ?? 0) + 1;
    }

    final meses = impresionesPorMes.keys.toList();
    final valores = impresionesPorMes.values.toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Impresiones por mes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.7,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= meses.length) return const Text('');
                          return Text(meses[index]);
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(valores.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: valores[index].toDouble(),
                          color: AppColors.primary,
                          width: 16,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    if (_filamentoPorColor.isEmpty) {
      return const Center(child: Text('No hay datos de filamentos'));
    }

    final sections = _filamentoPorColor.entries.map((e) {
        return PieChartSectionData(
          title: e.key,
          value: e.value,
          radius: 60,
        );
      }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Uso de Filamentos por Color',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: PieChart(PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              )),
            ),
          ],
        ),
      ),
    );
  }
}
