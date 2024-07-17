import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/frame-two_model.dart';
import '../models/frame_one_model.dart';
import '../viewmodels/statistics_view_model.dart';

class StatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => StatisticsViewModel()..fetchData(),
        child: Consumer<StatisticsViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCheckbox(
                          viewModel,
                          'CO2',
                          Colors.blue,
                          viewModel.showCO2,
                          (value) => viewModel.toggleCO2(value ?? false),
                        ),
                        _buildCheckbox(
                          viewModel,
                          'HCHO',
                          Colors.green,
                          viewModel.showHCHO,
                          (value) => viewModel.toggleHCHO(value ?? false),
                        ),
                        _buildCheckbox(
                          viewModel,
                          'TVOC',
                          Colors.orange,
                          viewModel.showTVOC,
                          (value) => viewModel.toggleTVOC(value ?? false),
                        ),
                        _buildCheckbox(
                          viewModel,
                          'Temperature',
                          Colors.red,
                          viewModel.showTemp,
                          (value) => viewModel.toggleTemp(value ?? false),
                        ),
                        _buildCheckbox(
                          viewModel,
                          'Humidity',
                          Colors.purple,
                          viewModel.showHumidity,
                          (value) => viewModel.toggleHumidity(value ?? false),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButton<String>(
                      value: viewModel.selectedPeriod,
                      items: ['Daily', 'Weekly', 'Monthly', 'Yearly']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        viewModel.setPeriod(newValue!);
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 400,
                    padding: EdgeInsets.all(16),
                    child: SfCartesianChart(
                      primaryXAxis: DateTimeAxis(
                        interval: 1, // Interval for displaying labels
                        intervalType:
                            _getIntervalType(viewModel.selectedPeriod),
                        dateFormat: _getDateFormat(viewModel.selectedPeriod),
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        title: AxisTitle(
                          text: 'Time',
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      primaryYAxis: NumericAxis(
                        axisLine: AxisLine(width: 0), // Hide the axis line
                        labelFormat: '{value}',
                        title: AxisTitle(
                          text: 'Value',
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      legend: Legend(
                        isVisible: true,
                        overflowMode: LegendItemOverflowMode.wrap,
                        position: LegendPosition.bottom,
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      series: _getLineSeries(viewModel),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCheckbox(
    StatisticsViewModel viewModel,
    String label,
    Color color,
    bool value,
    void Function(bool?)? onChanged,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (onChanged != null) {
                onChanged(!value);
              }
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: value ? color : Colors.grey.shade400,
                  width: 2,
                ),
                color: value ? color : Colors.transparent,
              ),
              child: value
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  DateTimeIntervalType _getIntervalType(String period) {
    switch (period) {
      case 'Daily':
        return DateTimeIntervalType.hours; // Show hours for daily
      case 'Weekly':
        return DateTimeIntervalType.days; // Show days for weekly
      case 'Monthly':
        return DateTimeIntervalType.days; // Show days for monthly
      case 'Yearly':
        return DateTimeIntervalType.months; // Show months for yearly
      default:
        return DateTimeIntervalType.auto;
    }
  }

  DateFormat _getDateFormat(String period) {
    switch (period) {
      case 'Daily':
        return DateFormat('ha'); // Show hours from 1 AM to 12 PM for daily
      case 'Weekly':
        return DateFormat('E'); // Show weekdays for weekly
      case 'Monthly':
        return DateFormat('d'); // Show days of the month for monthly
      case 'Yearly':
        return DateFormat('MMM'); // Show months for yearly
      default:
        return DateFormat.yMd(); // Default format for others
    }
  }

  List<LineSeries<dynamic, DateTime>> _getLineSeries(
      StatisticsViewModel viewModel) {
    List<LineSeries<dynamic, DateTime>> series = [];
    if (viewModel.showCO2) {
      series.add(LineSeries<FrameOne, DateTime>(
        dataSource: viewModel.frame1Data,
        xValueMapper: (FrameOne frame, _) => frame.date!,
        yValueMapper: (FrameOne frame, _) => frame.co2!,
        name: 'CO2',
        markerSettings: MarkerSettings(
          isVisible: true,
          color: Colors.blue.withOpacity(0.7),
        ),
      ));
    }
    if (viewModel.showHCHO) {
      series.add(LineSeries<FrameOne, DateTime>(
        dataSource: viewModel.frame1Data,
        xValueMapper: (FrameOne frame, _) => frame.date!,
        yValueMapper: (FrameOne frame, _) => frame.hcho!,
        name: 'HCHO',
        markerSettings: MarkerSettings(
          isVisible: true,
          color: Colors.green.withOpacity(0.7),
        ),
      ));
    }
    if (viewModel.showTVOC) {
      series.add(LineSeries<FrameOne, DateTime>(
        dataSource: viewModel.frame1Data,
        xValueMapper: (FrameOne frame, _) => frame.date!,
        yValueMapper: (FrameOne frame, _) => frame.tvoc!,
        name: 'TVOC',
        markerSettings: MarkerSettings(
          isVisible: true,
          color: Colors.orange.withOpacity(0.7),
        ),
      ));
    }
    if (viewModel.showTemp) {
      series.add(LineSeries<Frame, DateTime>(
        dataSource: viewModel.frame2Data,
        xValueMapper: (Frame frame, _) => frame.date!,
        yValueMapper: (Frame frame, _) => frame.temp!,
        name: 'Temperature',
        markerSettings: MarkerSettings(
          isVisible: true,
          color: Colors.red.withOpacity(0.7),
        ),
      ));
    }
    if (viewModel.showHumidity) {
      series.add(LineSeries<Frame, DateTime>(
        dataSource: viewModel.frame2Data,
        xValueMapper: (Frame frame, _) => frame.date!,
        yValueMapper: (Frame frame, _) => frame.humidity!,
        name: 'Humidity',
        markerSettings: MarkerSettings(
          isVisible: true,
          color: Colors.purple.withOpacity(0.7),
        ),
      ));
    }
    return series;
  }
}
