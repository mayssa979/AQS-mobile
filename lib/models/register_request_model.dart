import 'dart:convert';

enum Role { USER, ADMIN }

// Convert Role to and from JSON
Role roleFromJson(String role) {
  switch (role) {
    case 'USER':
      return Role.USER;
    case 'ADMIN':
      return Role.ADMIN;
    default:
      throw Exception('Unknown role: $role');
  }
}

String roleToJson(Role role) {
  return role.toString().split('.').last;
}

class RegisterRequest {
  final String firstname;
  final String lastname;
  final String email;
  final String address;
  final int phoneNumber;
  final String password;
  final Role role;

  RegisterRequest({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.address,
    required this.phoneNumber,
    required this.password,
    required this.role,
  });

  // Convert RegisterRequest to JSON
  Map<String, dynamic> toJson() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'address': address,
      'phoneNumber': phoneNumber,
      'password': password,
      'role': roleToJson(role),
    };
  }

  // Create a RegisterRequest from JSON
  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      password: json['password'],
      role: roleFromJson(json['role']),
    );
  }
}
