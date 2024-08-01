// lib/models/user_model.dart

import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  String? _email;

  String? get email => _email;

  void setEmail(String? email) {
    _email = email;
    notifyListeners();
  }
}
