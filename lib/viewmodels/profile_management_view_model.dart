import 'dart:convert';
import 'package:aqs/models/change_password_request.dart';
import 'package:aqs/models/register_request_model.dart';
import 'package:http/http.dart' as http;

class ProfileViewModel {
  final String baseUrl;

  ProfileViewModel({required this.baseUrl});

  Future<bool> ChangePassword(ProfileRequest request) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/change-password'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(request.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to change password: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during changing password: $e');
      return false;
    }
  }
}
