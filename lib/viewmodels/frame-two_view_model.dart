import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/frame-two_model.dart';

class FrameViewModel extends ChangeNotifier {
  Frame? lastFrame;
  late WebSocketChannel channel;

  FrameViewModel() {
    fetchData();
    connectWebSocket();
  }

  Future<void> fetchData() async {
    try {
      print('Fetching latest frame...');
      final response = await http.get(Uri.parse(
          'http://192.168.1.118:8080/frame2/latest')); // Replace with your actual API endpoint

      if (response.statusCode == 200) {
        print('Data fetched successfully');
        final jsonData = jsonDecode(response.body);
        lastFrame = Frame.fromJson(jsonData);
        notifyListeners();
      } else {
        print('Failed to load data: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void connectWebSocket() {
    try {
      print('Connecting to WebSocket...');
      channel = WebSocketChannel.connect(Uri.parse(
          'ws://192.168.1.118:8080/websocket-frame2')); // Replace with your IP address

      channel.stream.listen((event) {
        try {
          print('Received data from WebSocket: $event');

          if (event is String) {
            final newData = Frame.fromJson(jsonDecode(event));
            lastFrame = newData;
            notifyListeners();
          } else {
            // Handle other types if needed (e.g., int, etc.)
            print(
                'Received unexpected data type from WebSocket: ${event.runtimeType}');
          }
        } catch (e) {
          print('Error parsing WebSocket data: $e');
        }
      }, onError: (error) {
        print('WebSocket error: $error');
      }, onDone: () {
        print('WebSocket connection closed');
      });
    } catch (e) {
      print('Error connecting to WebSocket: $e');
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
