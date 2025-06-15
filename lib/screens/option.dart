import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:qna_frontend/models/dto.dart';
import 'package:qna_frontend/screens/MySchoolTeachers.dart';
import 'package:qna_frontend/screens/calendar.dart';
import 'package:qna_frontend/screens/login.dart';
import 'package:qna_frontend/screens/splash.dart';

import 'chat.dart';
import 'home.dart';

class Option extends StatefulWidget {
  Option({Key? key}) : super(key: key);

  @override
  _OptionState createState() => _OptionState();
}

class _OptionState extends State<Option> {
  UserDto? _user;
  TeacherDto? _teacher;
  List<FaqDto> _faqs = [];

  bool _notificationsEnabled = true;
  bool _calendarNotification = true;
  bool _chatNotification = true;

  final TextEditingController _deleteConfirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final idToken = await currentUser?.getIdToken();

    final response = await http.get(
      Uri.parse('https://qna-messenger.mirim-it-show.site/api/user/profile'),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];

      setState(() {
        _user = UserDto.fromJson(data);
        _teacher = data['teacher'] != null ? TeacherDto.fromJson(data['teacher']) : null;
        _faqs = (data['faqList'] as List?)?.map((e) => FaqDto.fromJson(e)).toList() ?? [];
      });
    } else {
      print('프로필 조회 실패: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _deleteConfirmController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmPopup() {
    if (_user == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('회원탈퇴를 하시기 전 확인 해주세요.'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('- 참여하고 있던 채팅방에서 나가지며 대화 내역도 같이 삭제됩니다.'),
            SizedBox(height: 8),
            Text('- 개인 프로필 설정이 모두 사라집니다.'),
            SizedBox(height: 16),
            Text(
              '진행하시겠다면 이름 : ${_user!.name} 을 입력해주세요.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _deleteConfirmController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (_deleteConfirmController.text.trim() == _user!.name) {
                Navigator.pop(context);
                _deleteConfirmController.clear();
                _showAlertThenMoveToLogin('회원탈퇴를 완료했습니다.');
              } else {
                _showAlert('입력값이 다릅니다.');
              }
            },
            child: Text('확인', style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  void _showAlertThenMoveToLogin(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Splash()));
            },
            child: Text('확인'),
          )
        ],
      ),
    );
  }

  void _showLogoutConfirmPopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('로그아웃시 초기화면으로 돌아갑니다.'),
        content: Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            child: Text('취소'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('로그아웃'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Splash()));
            },
          )
        ],
      ),
    );
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            child: Text('확인'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isTeacher = _user!.usertype == UserType.teacher;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset('assets/images/topNav.png', fit: BoxFit.cover),
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              color: Color(0xFF3C72BD),
              padding: EdgeInsets.fromLTRB(25, 8, 25, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text('옵션', style: TextStyle(color: Colors.white, fontSize: 23)),
              ),
            ),
          ),
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            bottom: 70,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          _user!.imgurl.isNotEmpty ? _user!.imgurl : 'https://via.placeholder.com/70',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${isTeacher ? '선생님' : '학생'} ${_user!.name}',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(_user!.email, style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  if (isTeacher && _teacher != null) ...[
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('담당과목 : ${_teacher!.subject}', style: TextStyle(fontSize: 18)),
                            SizedBox(height: 15),
                            Text('교무실 : ${_teacher!.office}', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        title: Text('자주하는 질문', style: TextStyle(fontSize: 18)),
                        children: _faqs
                            .map((faq) => ListTile(
                          title: Text(faq.question),
                          subtitle: Text(faq.answer),
                        ))
                            .toList(),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text('전체 알림 설정', style: TextStyle(fontSize: 18)),
                            trailing: Switch(
                              value: _notificationsEnabled,
                              activeColor: Color(0xFF566B92),
                              onChanged: (bool value) {
                                setState(() {
                                  _notificationsEnabled = value;
                                  if (!value) {
                                    _calendarNotification = false;
                                    _chatNotification = false;
                                  }
                                });
                              },
                            ),
                          ),
                          Divider(),
                          ListTile(
                            title: Text('일정 알림', style: TextStyle(fontSize: 15)),
                            trailing: Switch(
                              value: _calendarNotification,
                              onChanged: _notificationsEnabled
                                  ? (bool value) => setState(() => _calendarNotification = value)
                                  : null,
                            ),
                          ),
                          ListTile(
                            title: Text('채팅 알림', style: TextStyle(fontSize: 15)),
                            trailing: Switch(
                              value: _chatNotification,
                              onChanged: _notificationsEnabled
                                  ? (bool value) => setState(() => _chatNotification = value)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text('로그아웃', style: TextStyle(fontSize: 18)),
                      onTap: _showLogoutConfirmPopup,
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: _showDeleteConfirmPopup,
                      child: Text('회원탈퇴', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Color(0xFF3C72BD),
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Image.asset('assets/btns/mypgDis.png', width: 40),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MySchoolTeachers())),
                  ),
                  IconButton(
                    icon: Image.asset('assets/btns/chatDis.png', width: 40),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Home())),
                  ),
                  IconButton(
                    icon: Image.asset('assets/btns/calDis.png', width: 40),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Calendar())),
                  ),
                  IconButton(
                    icon: Image.asset('assets/btns/optAct.png', width: 40),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
