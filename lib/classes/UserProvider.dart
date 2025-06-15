// user_provider.dart
import 'package:flutter/material.dart';
import '../models/dto.dart';

class UserProvider extends ChangeNotifier {
  UserDto? _user;

  UserDto? get user => _user;

  void setUser(UserDto user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
