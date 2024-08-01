import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:aqs/Colors.dart';

class FrameTwoPage extends StatefulWidget {
  const FrameTwoPage({Key? key}) : super(key: key);

  @override
  _FrameOnePageState createState() => _FrameOnePageState();
}

class _FrameOnePageState extends State<FrameTwoPage> {
  List<Map<String, dynamic>> tableData = []; // List to store fetched data

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data when the widget initializes
    requestPermissions(); // Request permissions on startup
  }

  Future<void> requestPermissions() async {
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      final result = await Permission.storage.request();
      if (result.isDenied) {
        print('Storage permission denied');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
      }
    }
  }

  Future<void> fetchData() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.118:8080/frame2'));
      if (response.statusCode == 200) {
        List<dynamic> responseData = json.decode(response.body);
        List<Map<String, dynamic>> convertedData = responseData.map((item) {
          return item as Map<String, dynamic>;
        }).toList();
        setState(() {
          tableData = convertedData;
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteFrame(String id) async {
    try {
      final response = await http
          .delete(Uri.parse('http://192.168.1.118:8080/frame2/delete/$id'));

      if (response.statusCode == 200) {
        // If successful, update tableData by refetching data
        fetchData();
        print('Frame deleted successfully with id: $id');
      } else {
        print('Failed to delete frame: ${response.statusCode}');
        throw Exception('Failed to delete frame');
      }
    } catch (e) {
      print('Error deleting frame: $e');
    }
  }

  Future<void> showExportDialog(BuildContext context) async {
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    List<String> selectedMetrics = [];

    DateTimeRange? selectedDateRange;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Export Options'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Date Range Picker
                  TextButton(
                    onPressed: () async {
                      final dateRange = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (dateRange != null) {
                        setState(() {
                          startDateController.text =
                              DateFormat('yyyy-MM-dd').format(dateRange.start);
                          endDateController.text =
                              DateFormat('yyyy-MM-dd').format(dateRange.end);
                          selectedDateRange = dateRange;
                        });
                      }
                    },
                    child: Text('Select Date Range'),
                  ),
                  TextField(
                    controller: startDateController,
                    decoration: InputDecoration(labelText: 'Start Date'),
                    readOnly: true,
                  ),
                  TextField(
                    controller: endDateController,
                    decoration: InputDecoration(labelText: 'End Date'),
                    readOnly: true,
                  ),
                  // Checkboxes for metrics
                  CheckboxListTile(
                    title: Text('Temperature'),
                    value: selectedMetrics.contains('temp'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedMetrics.add('temp');
                        } else {
                          selectedMetrics.remove('temp');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Humidity'),
                    value: selectedMetrics.contains('humidity'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedMetrics.add('humidity');
                        } else {
                          selectedMetrics.remove('humidity');
                        }
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (startDateController.text.isNotEmpty &&
                        endDateController.text.isNotEmpty &&
                        selectedMetrics.isNotEmpty) {
                      Navigator.of(context).pop();
                      exportCSV(
                        startDateController.text,
                        endDateController.text,
                        selectedMetrics,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select date range and metrics'),
                        ),
                      );
                    }
                  },
                  child: Text('Export'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> exportCSV(
      String startDate, String endDate, List<String> metrics) async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        print('Storage permission denied');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }

      // Prepare CSV data
      List<List<dynamic>> rows = [
        ['ID', ...metrics, 'Date'], // Header
      ];

      final filteredData = tableData.where((item) {
        DateTime date = DateTime.parse(item['date']);
        DateTime start = DateTime.parse(startDate);
        DateTime end = DateTime.parse(endDate);
        return date.isAfter(start) && date.isBefore(end.add(Duration(days: 1)));
      }).toList();

      for (var item in filteredData) {
        List<dynamic> row = [item['id']];
        for (var metric in metrics) {
          row.add(item[metric.toLowerCase()]);
        }
        row.add(item['date']);
        rows.add(row);
      }

      String csv = const ListToCsvConverter().convert(rows);

      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        print('Directory not found');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get external storage directory')),
        );
        return;
      }

      final oldFilePath = '${directory.path}/frame2_data.csv';
      final tempFilePath = '${directory.path}/frame2_data_temp.csv';
      final oldFile = File(oldFilePath);
      final tempFile = File(tempFilePath);

      // Write CSV data to the temporary file
      await tempFile.writeAsString(csv, mode: FileMode.write);

      // Check if the old file exists and delete it
      if (await oldFile.exists()) {
        await oldFile.delete();
      }

      // Rename the temporary file to the original file name
      await tempFile.rename(oldFilePath);

      print('CSV file updated at $oldFilePath');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to $oldFilePath')),
      );
    } catch (e, stackTrace) {
      print('Error exporting CSV: $e');
      print('StackTrace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export CSV')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore Temperature and Humidity values',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.actiaGreen,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showExportDialog(context);
              },
              child: Text(
                'Export',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: AppColors.actiaGreen),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Temperature')),
                      DataColumn(label: Text('Humidity')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: List<DataRow>.generate(
                      tableData.length,
                      (index) => DataRow(cells: <DataCell>[
                        DataCell(
                            Text((index + 1).toString())), // Incremented ID
                        DataCell(Text(tableData[index]['temp'].toString())),
                        DataCell(Text(tableData[index]['humidity'].toString())),
                        DataCell(Text(tableData[index]['date'].toString())),
                        DataCell(IconButton(
                          icon:
                              Icon(Icons.delete_rounded, color: AppColors.red),
                          onPressed: () {
                            deleteFrame(tableData[index]['id']);
                          },
                        )),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
