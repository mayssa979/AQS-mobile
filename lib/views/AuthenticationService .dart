import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  final String _baseUrl = 'http://192.168.1.118:8080/api/v1/auth';

  Future<Map<String, dynamic>> authenticate(
      String email, String password) async {
    final url = Uri.parse('$_baseUrl/authenticate');

    try {
      print('Sending authentication request to: $url');
      print('Request body: ${jsonEncode({
            'email': email,
            'password': password
          })}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody.containsKey('access_token') &&
            responseBody.containsKey('refresh_token')) {
          final accessToken = responseBody['access_token'];
          final refreshToken = responseBody['refresh_token'];

          await storeToken(accessToken, refreshToken);

          print('Authentication successful. Access Token: $accessToken');
          return responseBody;
        } else {
          throw Exception('Tokens not found in response.');
        }
      } else {
        throw Exception(
            'Failed to authenticate. Status code: ${response.statusCode}. Body: ${response.body}');
      }
    } catch (e) {
      print('Error during authentication: $e');
      rethrow;
    }
  }

  Future<void> storeToken(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  Future<String?> retrieveAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String?> retrieveRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  Future<http.Response> makeAuthenticatedRequest(String endpoint) async {
    final accessToken = await retrieveAccessToken();
    if (accessToken == null) {
      throw Exception('No access token found. Please authenticate first.');
    }

    final url = Uri.parse('$_baseUrl/$endpoint');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      print('Authenticated request successful: ${response.body}');
    } else {
      print('Authenticated request failed: ${response.body}');
      if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      }
    }

    return response;
  }

  Future<bool> isTokenValid() async {
    try {
      final response = await makeAuthenticatedRequest('verify-token');
      return response.statusCode == 200;
    } catch (e) {
      print('Token validation failed: $e');
      return false;
    }
  }
}
