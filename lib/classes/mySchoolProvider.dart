import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeacherDto {
  final String teacherid;
  final String subject;
  final String office;

  TeacherDto({
    required this.teacherid,
    required this.subject,
    required this.office,
  });

  factory TeacherDto.fromJson(Map<String, dynamic> json) {
    return TeacherDto(
      teacherid: json['teacherid'] ?? '',
      subject: json['subject'] ?? '',
      office: json['office'] ?? '',
    );
  }

  get imgurl => null;

  get user => null;
}

class FaqDto {
  final String question;
  final String answer;

  FaqDto({
    required this.question,
    required this.answer,
  });

  factory FaqDto.fromJson(Map<String, dynamic> json) {
    return FaqDto(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}

class MySchoolProvider with ChangeNotifier {
  List<TeacherDto> _teachers = [];
  bool _loading = false;

  List<TeacherDto> get teachers => _teachers;
  bool get loading => _loading;

  Future<void> fetchTeacherProfile() async {
    _loading = true;
    notifyListeners();

    try {
      final uri = Uri.parse('https://qna-messenger.mirim-it-show.site/api/teacher/search?search=');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> data = jsonResult['data'] ?? [];

        _teachers = data.map((item) => TeacherDto.fromJson(item)).toList();
      } else {
        print('선생님 목록 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('에러 발생: $e');
    }

    _loading = false;
    notifyListeners();
  }
}
