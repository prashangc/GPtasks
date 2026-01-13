import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebaseposts/features/scatterplot/data/model/plot_model.dart';
import 'package:flutterfirebaseposts/features/scatterplot/presentation/provider/plot_provider.dart';
import 'package:flutterfirebaseposts/features/scatterplot/presentation/widgets/year_button_util.dart';
import 'package:provider/provider.dart';

class PlotScreen extends StatefulWidget {
  const PlotScreen({super.key});

  @override
  State<PlotScreen> createState() => _PlotScreenState();
}

class _PlotScreenState extends State<PlotScreen>
    with SingleTickerProviderStateMixin {
  final List<String> years = const ['2022', '2023', '2024', '2025'];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlotProvider>().load();
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _controller.forward();
  }

  List<FlSpot> _spotsForYear(
    List<Plot> data,
    PlotProvider provider,
    String year,
  ) {
    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      final value = provider.valueForYear(data[i], year);
      if (value != null && value != 0) {
        spots.add(FlSpot(i.toDouble(), value.toDouble()));
      }
    }
    return spots;
  }

  double _maxYForSelections(
    List<Plot> data,
    PlotProvider provider,
  ) {
    double maxY = 0;
    for (final year in provider.selectedYears) {
      for (final point in data) {
        final value = provider.valueForYear(point, year);
        if (value != null && value > maxY) {
          maxY = value;
        }
      }
    }
    return maxY == 0 ? 1 : maxY * 1.05;
  }

  Color _colorForYear(String year) {
    switch (year) {
      case '2022':
        return Colors.orange;
      case '2023':
        return Colors.blue;
      case '2024':
        return Colors.green;
      case '2025':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _xLabel(List<Plot> data, double value) {
    final index = value.toInt();
    if (index < 0 || index >= data.length) return '';
    final dateString = data[index].date;
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final parsed = DateTime.parse(dateString);
      return '${parsed.month}/${parsed.day}';
    } catch (_) {
      return '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlotProvider>();
    final data = provider.data;
    final visibleYears =
        years.where((year) => provider.selectedYears.contains(year)).toList();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
      appBar: AppBar(title: const Text('Curve Scatter')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null
                  ? Center(child: Text(provider.error!))
                  : data.isEmpty
                      ? const Center(child: Text('No data available'))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 700),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                child: AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, _) {
                                      return LineChart(
                                        duration: Duration(seconds: 2),
                                        curve: Curves.easeInToLinear,
                                        key: ValueKey(visibleYears.join(',')),
                                        LineChartData(
                                          gridData: FlGridData(
                                            show: true,
                                          ),
                                          borderData: FlBorderData(
                                            show: true,
                                            border: Border.fromBorderSide(
                                              BorderSide(
                                                color: Colors.white,
                                                width: 0.2,
                                              ),
                                            ),
                                          ),
                                          minX: 0,
                                          maxX: data.isEmpty
                                              ? 0
                                              : data.length > 1
                                                  ? (data.length - 1).toDouble()
                                                  : 1,
                                          minY: 0,
                                          maxY: _maxYForSelections(
                                            data,
                                            provider,
                                          ),
                                          titlesData: FlTitlesData(
                                            bottomTitles: AxisTitles(
                                              axisNameWidget: Text(
                                                "Temperature",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              sideTitles: SideTitles(
                                                maxIncluded: true,
                                                minIncluded: false,
                                                showTitles: true,
                                                interval: (data.length / 5)
                                                    .clamp(1, 50)
                                                    .toDouble(),
                                                getTitlesWidget: (value, meta) {
                                                  final label =
                                                      _xLabel(data, value);
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8),
                                                    child: Text(
                                                      label,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                maxIncluded: false,
                                                minIncluded: false,
                                                showTitles: true,
                                                reservedSize: 40,
                                                getTitlesWidget: (value, meta) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8),
                                                    child: Text(
                                                      meta.formattedValue
                                                          .toString(),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            rightTitles: const AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false),
                                            ),
                                            topTitles: const AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false),
                                            ),
                                          ),
                                          baselineX: 50.0,
                                          baselineY: 50.0,
                                          lineBarsData:
                                              visibleYears.map((year) {
                                            List<FlSpot> visibleSpots =
                                                const [];
                                            try {
                                              final spots = _spotsForYear(
                                                  data, provider, year);
                                              final totalSpots = spots.length;
                                              final progress =
                                                  (_controller.value *
                                                          totalSpots)
                                                      .ceil()
                                                      .clamp(1, totalSpots);

                                              visibleSpots =
                                                  spots.sublist(0, progress);
                                            } catch (_) {}
                                            return LineChartBarData(
                                              spots: visibleSpots,
                                              isCurved: true,
                                              curveSmoothness: 0.25,
                                              color: _colorForYear(year),
                                              barWidth: 0,
                                              dotData:
                                                  const FlDotData(show: true),
                                              belowBarData:
                                                  BarAreaData(show: false),
                                              isStrokeCapRound: true,
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: years
                                  .map(
                                    (year) => CustomYearButton(
                                      callback: () => provider.toggleYear(year),
                                      selected:
                                          provider.selectedYears.contains(year),
                                      value: year,
                                      color: _colorForYear(year),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
        ),
      ),
    );
  }
}
