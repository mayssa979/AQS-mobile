// lib/viewmodels/logout_view_model.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LogoutViewModel {
  // Function to handle logout logic
  Future<bool> logout(String url) async {
    try {
      // Make the HTTP POST request
      final response = await http.post(Uri.parse(url));

      // Check if the request was successful
      if (response.statusCode == 200) {
        print("Logged out successfully");
        return true; // Logout successful
      } else {
        print("Logout failed: ${response.statusCode}");
        return false; // Logout failed
      }
    } catch (e) {
      // Handle any network or other errors
      debugPrint("An error occurred: $e");
      return false;
    }
  }

  // Function to show error dialog
  void showErrorDialog(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }
}
