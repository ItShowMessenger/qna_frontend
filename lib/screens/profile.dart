import 'package:flutter/material.dart';
import 'package:qna_frontend/screens/MySchool.dart';
import 'package:qna_frontend/screens/calendar.dart';
import 'package:qna_frontend/screens/chat.dart';
import 'package:qna_frontend/screens/home.dart';

class Profile extends StatelessWidget {
  final String userType; // 'TEACHER' or 'STUDENT'
  final dynamic data;

  const Profile({required this.userType, required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['userDto']?['name'] ?? '이름 없음';
    final email = data['userDto']?['email'] ?? '이메일 없음';
    final subject = data['teacherDto']?['subject'] ?? '';
    final office = data['teacherDto']?['office'] ?? '';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0, left: 0, right: 0,
              child: Image.asset('assets/images/topNav.png', fit: BoxFit.cover),
            ),
            Positioned(
              top: 40,
              left: 0, right: 0,
              child: Container(
                height: 60,
                color: Color(0xFF3C72BD),
                padding: EdgeInsets.fromLTRB(25, 8, 25, 0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '프로필',
                    style: TextStyle(color: Colors.white, fontSize: 23),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 140, left: 0, right: 0, bottom: 70,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/images/def_photo.png',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userType == 'TEACHER' ? '선생님 $name' : '$name 학생',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(email, style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                    if (userType == 'TEACHER') ...[
                      SizedBox(height: 30),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('담당과목 : $subject', style: TextStyle(fontSize: 18)),
                              SizedBox(height: 15),
                              Text('교무실 : $office', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 0), // Card 내부 padding 제거
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16), // 여기서 padding 직접 지정
                            title: Text('자주하는 질문', style: TextStyle(fontSize: 18)),
                            onTap: () {
                              // TODO: Add FAQ navigation
                            },
                          ),
                        ),
                      ),

                    ],
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0, right: 0,
              child: Container(
                color: Color(0xFF3C72BD),
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Image.asset('assets/btns/mypgDis.png', width: 40),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MySchool()));
                      },
                    ),
                    IconButton(
                      icon: Image.asset('assets/btns/chatDis.png', width: 40),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                      },
                    ),
                    IconButton(
                      icon: Image.asset('assets/btns/calDis.png', width: 40),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Calendar()));
                      },
                    ),
                    IconButton(
                      icon: Image.asset('assets/btns/optAct.png', width: 40),
                      onPressed: () {
                        // 현재 페이지
                      },
                    ),
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
