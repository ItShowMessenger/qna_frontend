import 'package:flutter/material.dart';
import '../models/dto.dart'; // UserDto, TeacherDto, FaqDto, AlarmSettingDto가 정의된 파일

class UserProvider extends ChangeNotifier {
  UserDto? _user;
  TeacherDto? _teacher;
  List<FaqDto> _faqs = [];
  AlarmSettingDto? _alarmSetting;

  // getter
  UserDto? get user => _user;
  TeacherDto? get teacher => _teacher;
  List<FaqDto> get faqs => _faqs;
  AlarmSettingDto? get alarmSetting => _alarmSetting;

  // setter
  void setUser(UserDto? u) {
    _user = u;
    notifyListeners();
  }

  void setTeacher(TeacherDto? t) {
    _teacher = t;
    notifyListeners();
  }

  void setFaqs(List<FaqDto> f) {
    _faqs = f;
    notifyListeners();
  }

  void setAlarmSetting(AlarmSettingDto a) {
    _alarmSetting = a;
    notifyListeners();
  }
}
