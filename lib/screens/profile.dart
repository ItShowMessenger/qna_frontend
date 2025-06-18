import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qna_frontend/classes/UserProvider.dart';
import 'package:qna_frontend/screens/MySchool.dart';
import 'package:qna_frontend/screens/calendar.dart';
import 'package:qna_frontend/screens/chat.dart';
import 'package:qna_frontend/screens/home.dart';
import 'package:qna_frontend/screens/option.dart';

class Profile extends StatelessWidget {
  final String userType;
  final dynamic data;


  const Profile({required this.userType, required this.data});

  @override
  Widget build(BuildContext context) {
    final isTeacher = userType == 'TEACHER';
    final name = data['userDto']?['name'] ?? '이름 없음';
    final email = data['userDto']?['email'] ?? '이메일 없음';
    final subject = data['teacherDto']?['subject'] ?? '';
    final office = data['teacherDto']?['office'] ?? '';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
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
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🔙 뒤로가기 버튼
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),

                    // 프로필 텍스트 (가운데)
                    Expanded(
                      child: Center(
                        child: Text(
                          '프로필',
                          style: TextStyle(color: Colors.white, fontSize: 23),
                        ),
                      ),
                    ),

                    // 오른쪽 공간 확보용 (좌우 균형 맞추기용)
                    Opacity(
                      opacity: 0,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: null,
                      ),
                    ),
                  ],
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
                    if (isTeacher==false) ...[
                      SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            final currentUser = FirebaseAuth.instance.currentUser;
                            final idToken = await currentUser?.getIdToken();
                            final studentId = data['userDto']?['userid'];
                            final teacherId = Provider.of<UserProvider>(context, listen: false).user?.userid;

                            if (studentId == null || teacherId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('학생 또는 선생님의 ID가 없습니다.'))
                              );
                              return;
                            }

                            final roomId = '${studentId}_${teacherId}';
                            final url = 'https://qna-messenger.mirim-it-show.site/api/chat/$roomId';

                            try {
                              final response = await http.get(
                                Uri.parse(url),
                                headers: {'Authorization': 'Bearer $idToken'},
                              );

                              if (response.statusCode == 200) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Home(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('채팅방 생성 실패 (${response.statusCode}) (${roomId})')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('네트워크 오류: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3C72BD),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '채팅 하기',
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
                      icon: Image.asset('assets/btns/mypgAct.png', width: 40),
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
                      icon: Image.asset('assets/btns/optDis.png', width: 40),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Option()));
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