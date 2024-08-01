import 'dart:convert';

class ProfileRequest {
  final String email;
  final String currentPassword;
  final String newPassword;
  final String confirmationPassword;

  ProfileRequest({
    required this.email,
    required this.currentPassword,
    required this.newPassword,
    required this.confirmationPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmationPassword': confirmationPassword
    };
  }

  // Create a RegisterRequest from JSON
  factory ProfileRequest.fromJson(Map<String, dynamic> json) {
    return ProfileRequest(
      email: json['email'],
      currentPassword: json['currentPassword'],
      newPassword: json['newPassword'],
      confirmationPassword: json['confirmationPassword'],
    );
  }
}
