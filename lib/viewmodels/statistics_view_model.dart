// viewmodels/statistics_viewmodel.dart
import 'package:aqs/models/frame_one_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/frame-two_model.dart';

class StatisticsViewModel extends ChangeNotifier {
  List<FrameOne> _frame1Data = [];
  List<Frame> _frame2Data = [];
  List<FrameOne> get frame1Data => _getFilteredFrame1Data();
  List<Frame> get frame2Data => _getFilteredFrame2Data();

  bool _showCO2 = true;
  bool _showHCHO = true;
  bool _showTVOC = true;
  bool _showTemp = true;
  bool _showHumidity = true;

  bool get showCO2 => _showCO2;
  bool get showHCHO => _showHCHO;
  bool get showTVOC => _showTVOC;
  bool get showTemp => _showTemp;
  bool get showHumidity => _showHumidity;

  String _selectedPeriod = 'Daily';
  String get selectedPeriod => _selectedPeriod;

  void toggleCO2(bool value) {
    _showCO2 = value;
    notifyListeners();
  }

  void toggleHCHO(bool value) {
    _showHCHO = value;
    notifyListeners();
  }

  void toggleTVOC(bool value) {
    _showTVOC = value;
    notifyListeners();
  }

  void toggleTemp(bool value) {
    _showTemp = value;
    notifyListeners();
  }

  void toggleHumidity(bool value) {
    _showHumidity = value;
    notifyListeners();
  }

  void setPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  Future<void> fetchData() async {
    final response1 =
        await http.get(Uri.parse('http://192.168.43.223:8080/frame1'));
    final response2 =
        await http.get(Uri.parse('http://192.168.43.223:8080/frame2'));

    if (response1.statusCode == 200 && response2.statusCode == 200) {
      final List<dynamic> data1 = json.decode(response1.body);
      final List<dynamic> data2 = json.decode(response2.body);

      _frame1Data = data1.map((json) => FrameOne.fromJson(json)).toList();
      _frame2Data = data2.map((json) => Frame.fromJson(json)).toList();

      notifyListeners();
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<FrameOne> _getFilteredFrame1Data() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Daily':
        return _frame1Data
            .where((data) =>
                data.date != null &&
                data.date!.isAfter(now.subtract(Duration(days: 1))))
            .toList();
      case 'Weekly':
        return _frame1Data
            .where((data) =>
                data.date != null &&
                data.date!.isAfter(now.subtract(Duration(days: 7))))
            .toList();
      case 'Monthly':
        return _frame1Data
            .where((data) =>
                data.date != null &&
                data.date!.isAfter(now.subtract(Duration(days: 30))))
            .toList();
      case 'Yearly':
        return _frame1Data
            .where((data) =>
                data.date != null &&
                data.date!.isAfter(now.subtract(Duration(days: 365))))
            .toList();
      default:
        return _frame1Data;
    }
  }

  List<Frame> _getFilteredFrame2Data() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Daily':
        return _frame2Data
            .where((data) =>
                data.date != null &&
                data.date!.isAfter(now.subtract(Duration(days: 1))))
            .toList();
      case 'Weekly':
        return _frame2Data
            .where((data) =>
                data.date != null &&
                data.date!.isAfter(now.subtract(Duration(days: 7))))
            .toList();
      case 'Monthly':
        return _frame2Data
            .where((data) =>
                data.date != null &&
                data.date!.isAfter(now.subtract(Duration(days: 30))))
            .toList();
      case 'Yearly':
        return _frame2Data
            .where((data) =>
                data.date != null &&
                data.date!.isAfter(now.subtract(Duration(days: 365))))
            .toList();
      default:
        return _frame2Data;
    }
  }
}
