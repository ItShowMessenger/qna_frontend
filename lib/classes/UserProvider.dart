// user_provider.dart
import 'package:flutter/material.dart';
import '../models/dto.dart';

class UserProvider extends ChangeNotifier {
  UserDto? _user;
  UserDto? get user => _user;

  TeacherDto? _teacher;
  TeacherDto? get teacher => _teacher;

  void setUser(UserDto user) {
    _user = user;
    notifyListeners();
  }

  void setTeacher(TeacherDto teacher) {
    _teacher = teacher;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
