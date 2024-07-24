import 'dart:convert';
import 'package:aqs/models/register_request_model.dart';
import 'package:http/http.dart' as http;

class RegistrationViewModel {
  final String baseUrl;

  RegistrationViewModel({required this.baseUrl});

  Future<bool> registerUser(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(request.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true; // Registration successful
      } else {
        print('Failed to register: ${response.body}');
        return false; // Registration failed
      }
    } catch (e) {
      print('Error during registration: $e');
      return false; // Error during registration
    }
  }
}
