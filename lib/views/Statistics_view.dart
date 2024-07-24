import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String selectedView = 'daily'; // Default view
  List<Map<String, dynamic>> data = [];
  Map<String, bool> selectedMetrics = {
    'co2': true,
    'hcho': true,
    'tvoc': true,
    'temp': true,
    'humidity': true,
  };

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response1 =
          await http.get(Uri.parse('http://192.168.43.223:8080/frame1'));
      final response2 =
          await http.get(Uri.parse('http://192.168.43.223:8080/frame2'));
      handleViewChange(
          selectedView, jsonDecode(response1.body), jsonDecode(response2.body));
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  void handleViewChange(
      String view, List<dynamic>? rawData1, List<dynamic>? rawData2) {
    setState(() {
      selectedView = view;
      switch (view) {
        case 'daily':
          data = processDailyData(rawData1, rawData2);
          break;
        case 'weekly':
          data = processWeeklyData(rawData1, rawData2);
          break;
        case 'monthly':
          data = processMonthlyData(rawData1, rawData2);
          break;
        case 'yearly':
          data = processYearlyData(rawData1, rawData2);
          break;
        default:
          data = []; // Handle unexpected view
          break;
      }
    });
  }

  List<Map<String, dynamic>> processDailyData(
      List<dynamic>? rawData1, List<dynamic>? rawData2) {
    if (rawData1 == null || rawData2 == null) {
      return [];
    }

    // Initialize the list to store the data and a map to count entries per hour
    List<Map<String, dynamic>> processedData = [];
    Map<int, int> countPerHour = {};
    Map<int, int> countPerHour2 = {};

    // Initialize data and countPerHour for each hour of the day
    for (int hour = 0; hour < 24; hour++) {
      processedData.add({
        'x': '$hour:00',
        'co2': 0,
        'hcho': 0,
        'tvoc': 0,
        'temp': 0,
        'humidity': 0,
      });
      countPerHour[hour] = 0;
      countPerHour2[hour] = 0;
    }

    // Get the current date in YYYY-MM-DD format
    DateTime now = DateTime.now();
    String today =
        DateTime(now.year, now.month, now.day).toIso8601String().split("T")[0];

    // Process rawData1 for CO2, HCHO, and TVOC values
    rawData1.forEach((entry1) {
      DateTime date1 = DateTime.parse(entry1['date']);
      if (date1.toIso8601String().split("T")[0] == today) {
        int hour = date1.hour;
        processedData[hour]['co2'] += entry1['co2'] ?? 0;
        processedData[hour]['hcho'] += entry1['hcho'] ?? 0;
        processedData[hour]['tvoc'] += entry1['tvoc'] ?? 0;
        countPerHour[hour] = (countPerHour[hour] ?? 0) + 1;
      }
    });

    // Process rawData2 for Temperature and Humidity values
    rawData2.forEach((entry2) {
      DateTime date2 = DateTime.parse(entry2['date']);
      if (date2.toIso8601String().split("T")[0] == today) {
        int hour = date2.hour;
        processedData[hour]['temp'] += entry2['temp'] ?? 0;
        processedData[hour]['humidity'] += entry2['humidity'] ?? 0;
        countPerHour2[hour] = (countPerHour2[hour] ?? 0) + 1;
      }
    });

    // Calculate the average for each hour
    for (int hour = 0; hour < 24; hour++) {
      if (countPerHour[hour]! > 0) {
        processedData[hour]['co2'] /= countPerHour[hour]!;
        processedData[hour]['hcho'] /= countPerHour[hour]!;
        processedData[hour]['tvoc'] /= countPerHour[hour]!;
        processedData[hour]['temp'] /= countPerHour2[hour]!;
        processedData[hour]['humidity'] /= countPerHour2[hour]!;
      }
    }

    return processedData;
  }

  List<Map<String, dynamic>> processWeeklyData(
      List<dynamic>? rawData1, List<dynamic>? rawData2) {
    if (rawData1 == null || rawData2 == null) {
      return [];
    }

    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<Map<String, dynamic>> processedData = [];
    Map<int, int> countPerDay1 = {}; // Counts for CO2, HCHO, TVOC
    Map<int, int> countPerDay2 = {}; // Counts for Temp, Humidity

    // Initialize processed data and counts
    daysOfWeek.forEach((day) {
      processedData.add({
        'x': day,
        'co2': 0,
        'hcho': 0,
        'tvoc': 0,
        'temp': 0,
        'humidity': 0,
      });
      countPerDay1[daysOfWeek.indexOf(day)] = 0;
      countPerDay2[daysOfWeek.indexOf(day)] = 0;
    });

    // Get the current week (Monday as the first day of the week)
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;
    DateTime startOfWeek = now
        .subtract(Duration(days: (currentWeekday - DateTime.monday))); // Monday
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6)); // Sunday

    print('Start of Week: $startOfWeek');
    print('End of Week: $endOfWeek');

    // Process rawData1 for CO2, HCHO, and TVOC values
    rawData1.forEach((entry1) {
      DateTime date1 = DateTime.parse(entry1['date']);
      if (date1.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
          date1.isBefore(endOfWeek.add(Duration(days: 1)))) {
        int dayIndex = date1.weekday - DateTime.monday;
        if (dayIndex >= 0 && dayIndex < 7) {
          // Ensure dayIndex is within the valid range
          processedData[dayIndex]['co2'] += entry1['co2'] ?? 0;
          processedData[dayIndex]['hcho'] += entry1['hcho'] ?? 0;
          processedData[dayIndex]['tvoc'] += entry1['tvoc'] ?? 0;
          countPerDay1[dayIndex] = (countPerDay1[dayIndex] ?? 0) + 1;
        }
      }
    });

    // Process rawData2 for Temperature and Humidity values
    rawData2.forEach((entry2) {
      DateTime date2 = DateTime.parse(entry2['date']);
      if (date2.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
          date2.isBefore(endOfWeek.add(Duration(days: 1)))) {
        int dayIndex = date2.weekday - DateTime.monday;
        if (dayIndex >= 0 && dayIndex < 7) {
          // Ensure dayIndex is within the valid range
          processedData[dayIndex]['temp'] += entry2['temp'] ?? 0;
          processedData[dayIndex]['humidity'] += entry2['humidity'] ?? 0;
          countPerDay2[dayIndex] = (countPerDay2[dayIndex] ?? 0) + 1;
        }
      }
    });

    // Calculate the average for each day of the week
    daysOfWeek.forEach((day) {
      int dayIndex = daysOfWeek.indexOf(day);
      if (countPerDay1[dayIndex]! > 0) {
        processedData[dayIndex]['co2'] /= countPerDay1[dayIndex]!;
        processedData[dayIndex]['hcho'] /= countPerDay1[dayIndex]!;
        processedData[dayIndex]['tvoc'] /= countPerDay1[dayIndex]!;
      }
      if (countPerDay2[dayIndex]! > 0) {
        processedData[dayIndex]['temp'] /= countPerDay2[dayIndex]!;
        processedData[dayIndex]['humidity'] /= countPerDay2[dayIndex]!;
      }
    });

    // Debugging output
    print('Processed Data: $processedData');

    return processedData;
  }

  List<Map<String, dynamic>> processMonthlyData(
      List<dynamic>? rawData1, List<dynamic>? rawData2) {
    if (rawData1 == null || rawData2 == null) {
      return [];
    }

    final daysInMonth = List<int>.generate(31, (index) => index + 1);
    List<Map<String, dynamic>> processedData = [];
    Map<int, int> countPerDay1 = {};
    Map<int, int> countPerDay2 = {};

    daysInMonth.forEach((day) {
      processedData.add({
        'x': day.toString(),
        'co2': 0,
        'hcho': 0,
        'tvoc': 0,
        'temp': 0,
        'humidity': 0,
      });
      countPerDay1[day] = 0; // Initialize countPerDay1 for each day
      countPerDay2[day] = 0; // Initialize countPerDay2 for each day
    });

    // Get the current month and year
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;

    // Process rawData1 for CO2, HCHO, and TVOC values
    rawData1.forEach((entry1) {
      DateTime date1 = DateTime.parse(entry1['date']);
      if (date1.month == currentMonth && date1.year == currentYear) {
        int day = date1.day;
        processedData[day - 1]['co2'] += entry1['co2'] ?? 0;
        processedData[day - 1]['hcho'] += entry1['hcho'] ?? 0;
        processedData[day - 1]['tvoc'] += entry1['tvoc'] ?? 0;
        countPerDay1[day] = (countPerDay1[day] ?? 0) + 1;
      }
    });

    // Process rawData2 for Temperature and Humidity values
    rawData2.forEach((entry2) {
      DateTime date2 = DateTime.parse(entry2['date']);
      if (date2.month == currentMonth && date2.year == currentYear) {
        int day = date2.day;
        processedData[day - 1]['temp'] += entry2['temp'] ?? 0;
        processedData[day - 1]['humidity'] += entry2['humidity'] ?? 0;
        countPerDay2[day] = (countPerDay2[day] ?? 0) + 1;
      }
    });

    // Calculate the average for each day of the month
    daysInMonth.forEach((day) {
      if (countPerDay1[day]! > 0) {
        processedData[day - 1]['co2'] /= countPerDay1[day]!;
        processedData[day - 1]['hcho'] /= countPerDay1[day]!;
        processedData[day - 1]['tvoc'] /= countPerDay1[day]!;
      }
      if (countPerDay2[day]! > 0) {
        processedData[day - 1]['temp'] /= countPerDay2[day]!;
        processedData[day - 1]['humidity'] /= countPerDay2[day]!;
      }
    });

    return processedData;
  }

  List<Map<String, dynamic>> processYearlyData(
      List<dynamic>? rawData1, List<dynamic>? rawData2) {
    if (rawData1 == null || rawData2 == null) {
      return [];
    }

    final monthsOfYear = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    List<Map<String, dynamic>> processedData = [];
    Map<int, int> countPerMonth = {};
    Map<int, int> countPerMonth2 = {};
    monthsOfYear.forEach((month) {
      processedData.add({
        'x': month,
        'co2': 0,
        'hcho': 0,
        'tvoc': 0,
        'temp': 0,
        'humidity': 0,
      });
      countPerMonth[monthsOfYear.indexOf(month) + 1] =
          0; // Initialize countPerMonth for each month
      countPerMonth2[monthsOfYear.indexOf(month) + 1] = 0;
    });

    // Get the current year
    DateTime now = DateTime.now();
    int currentYear = now.year;

    // Process rawData1 for CO2, HCHO, and TVOC values
    rawData1.forEach((entry1) {
      DateTime date1 = DateTime.parse(entry1['date']);
      if (date1.year == currentYear) {
        int month = date1.month;
        processedData[month - 1]['co2'] += entry1['co2'] ?? 0;
        processedData[month - 1]['hcho'] += entry1['hcho'] ?? 0;
        processedData[month - 1]['tvoc'] += entry1['tvoc'] ?? 0;
        countPerMonth[month] = (countPerMonth[month] ?? 0) + 1;
      }
    });

    // Process rawData2 for Temperature and Humidity values
    rawData2.forEach((entry2) {
      DateTime date2 = DateTime.parse(entry2['date']);
      if (date2.year == currentYear) {
        int month = date2.month;
        processedData[month - 1]['temp'] += entry2['temp'] ?? 0;
        processedData[month - 1]['humidity'] += entry2['humidity'] ?? 0;
        countPerMonth2[month] = (countPerMonth2[month] ?? 0) + 1;
      }
    });

    // Calculate the average for each month of the year
    monthsOfYear.forEach((month) {
      int monthIndex = monthsOfYear.indexOf(month);
      if (countPerMonth[monthIndex + 1]! > 0) {
        processedData[monthIndex]['co2'] /= countPerMonth[monthIndex + 1]!;
        processedData[monthIndex]['hcho'] /= countPerMonth[monthIndex + 1]!;
        processedData[monthIndex]['tvoc'] /= countPerMonth[monthIndex + 1]!;
        processedData[monthIndex]['temp'] /= countPerMonth2[monthIndex + 1]!;
        processedData[monthIndex]['humidity'] /=
            countPerMonth2[monthIndex + 1]!;
      }
    });

    return processedData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildDropdown(),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              legend: Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: _buildSeries(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButton<String>(
      value: selectedView,
      onChanged: (String? newValue) {
        if (newValue != null) {
          fetchData();
          handleViewChange(newValue, null, null);
        }
      },
      items: <String>['daily', 'weekly', 'monthly', 'yearly']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  List<ChartSeries<Map<String, dynamic>, String>> _buildSeries() {
    List<ChartSeries<Map<String, dynamic>, String>> seriesList = [];

    selectedMetrics.forEach((metric, isSelected) {
      if (isSelected) {
        seriesList.add(
          LineSeries<Map<String, dynamic>, String>(
            dataSource: data,
            xValueMapper: (Map<String, dynamic> data, _) =>
                data['x'].toString(),
            yValueMapper: (Map<String, dynamic> data, _) =>
                data[metric].toDouble(),
            name: metric.toUpperCase(),
          ),
        );
      }
    });

    return seriesList;
  }
}
