import 'package:flutter/material.dart';
import 'package:qna_frontend/screens/MySchoolTeachers.dart';
import 'package:qna_frontend/screens/calendar.dart';
import 'package:qna_frontend/screens/login.dart';
import 'chat.dart';
import 'home.dart';

class Profile_t extends StatefulWidget {
  final dynamic data;
  Profile_t({required this.data});

  @override
  _Profile_tState createState() => _Profile_tState();
}

class _Profile_tState extends State<Profile_t> {
  @override
  Widget build(BuildContext context) {
    final name = widget.data['userDto']?['name'] ?? '이름 없음';
    final subject = widget.data['teacherDto']?['subject'] ?? '과목 없음';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            // 상단 이미지, 타이틀 생략...
            Positioned(
              top: 140,
              left: 25,
              child: Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Positioned(
              top: 180,
              left: 25,
              child: Text("담당과목: $subject", style: TextStyle(fontSize: 18)),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                // 네비게이션 버튼 유지...
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => MySchoolTeachers())),
                      icon: Image.asset('assets/btns/mypgDis.png', width: 40),
                    ),
                    // ... 나머지 버튼 유지 ...
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
