import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChartData {
  final String category;
  final double amount;
  ChartData({required this.category, required this.amount});
}

class CategoryBarChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const CategoryBarChart({Key? key, required this.categoryTotals})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert the map to a list of ChartData objects.
    List<ChartData> data = categoryTotals.entries
        .map((e) => ChartData(category: e.key, amount: e.value))
        .toList();

    // Determine a max value for the y-axis.
    double maxValue = data.isNotEmpty
        ? data.map((e) => e.amount).reduce((a, b) => a > b ? a : b)
        : 1;

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelRotation: 45,
        title: AxisTitle(text: 'Category'),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Amount (£)'),
        maximum: maxValue + (maxValue * 0.1),
        interval: maxValue / 5,
        numberFormat: NumberFormat.currency(symbol: "£", decimalDigits: 0),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<ChartData, String>>[
        ColumnSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData datum, _) => datum.category,
          yValueMapper: (ChartData datum, _) => datum.amount,
          dataLabelSettings: const DataLabelSettings(
              isVisible: true, textStyle: TextStyle(fontSize: 10)),
          enableTooltip: true,
        ),
      ],
    );
  }
}
