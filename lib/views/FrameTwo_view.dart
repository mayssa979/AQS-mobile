import 'package:flutter/material.dart';
import 'package:aqs/Colors.dart'; // Adjust import based on your project structure
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  }

  Future<void> fetchData() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.221:8080/frame2'));
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
          .delete(Uri.parse('http://192.168.1.221:8080/frame2/delete/$id'));

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
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Temperature')),
                      DataColumn(label: Text('Humidity')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: List<DataRow>.generate(
                      tableData.length,
                      (index) => DataRow(cells: <DataCell>[
                        DataCell(
                            Text((index + 1).toString())), // Incremented ID
                        DataCell(Text(tableData[index]['temp'].toString())),
                        DataCell(Text(tableData[index]['humidity'].toString())),
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
