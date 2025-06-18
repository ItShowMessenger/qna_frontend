import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:qna_frontend/models/dto.dart';
import 'package:qna_frontend/screens/MySchool.dart';
import 'package:qna_frontend/screens/calendar.dart';
import 'package:qna_frontend/screens/login.dart';
import 'package:qna_frontend/screens/splash.dart';
import 'chat.dart';
import 'home.dart';
import '../classes/UserProvider.dart';

class Option extends StatefulWidget {
  @override
  _OptionState createState() => _OptionState();
}

class _OptionState extends State<Option> {
  String _newSubject = '';
  String _newOffice = '';

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
    _loadUserFromProvider();
    _fetchUserProfile();
  }

  void _showEditTeacherInfoPopup() {
    _newSubject = _teacher?.subject ?? '';
    _newOffice = _teacher?.office ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isModified = _newSubject != _teacher?.subject || _newOffice != _teacher?.office;

            return AlertDialog(
              title: Text('교사 정보 수정'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: '담당 과목'),
                    controller: TextEditingController(text: _newSubject)
                      ..selection = TextSelection.fromPosition(TextPosition(offset: _newSubject.length)),
                    onChanged: (value) {
                      setState(() => _newSubject = value);
                    },
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(labelText: '교무실'),
                    controller: TextEditingController(text: _newOffice)
                      ..selection = TextSelection.fromPosition(TextPosition(offset: _newOffice.length)),
                    onChanged: (value) {
                      setState(() => _newOffice = value);
                    },
                  ),
                ],
              ),
              actions: [
                if (!isModified)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('취소하기'),
                  ),
                if (isModified)
                  TextButton(
                    onPressed: () async {
                      await _updateTeacherInfo();
                      Navigator.pop(context);
                    },
                    child: Text('수정하기', style: TextStyle(color: Colors.blue)),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateTeacherInfo() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final idToken = await currentUser?.getIdToken();

      if (idToken == null || _teacher == null) return;

      // TeacherDto 업데이트
      final updatedTeacher = _teacher!.copyWith(
        subject: _newSubject,
        office: _newOffice,
      );

      final response = await http.patch(
        Uri.parse('https://qna-messenger.mirim-it-show.site/api/user/teacher'),  // 🔁 실제 API 경로로 교체
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedTeacher.toJson()),
      );

      if (response.statusCode == 200) {
        setState(() {
          _teacher = updatedTeacher;
        });
        _showAlert('정보가 성공적으로 수정되었습니다.');
        Navigator.pop(context);
      } else {
        _showAlert('수정 실패: ${response.statusCode}');
      }
    } catch (e) {
      _showAlert('오류 발생: $e');
    }
  }

  void _loadUserFromProvider() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _user = userProvider.user;

      // user가 teacher 타입일 때, 별도로 TeacherDto를 받아서 할당해야 함
      if (_user?.usertype == UserType.teacher) {
        // 예: userProvider가 teacher 데이터를 따로 가지고 있다고 가정
        _teacher = userProvider.teacher;  // 혹은 teacher 데이터를 가져오는 함수/변수를 사용
      } else {
        _teacher = null;
      }
      _faqs = [];
    });
  }



  Future<void> _fetchUserProfile() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final idToken = await currentUser?.getIdToken();

      if (idToken == null) {
        print('토큰 없음');
        return;
      }

      final response = await http.get(
        Uri.parse('https://qna-messenger.mirim-it-show.site/api/user/profile'),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        final data = responseData['data'];

        final userDto = UserDto.fromJson(data['user']);
        final teacherDto = data['teacher'] != null ? TeacherDto.fromJson(data['teacher']) : null;
        final faqList = (data['faqList'] as List?)?.map((e) => FaqDto.fromJson(e)).toList() ?? [];
        final alarmSettingDto = AlarmSettingDto.fromJson(data['alarm']);

        setState(() {
          _user = userDto;
          _teacher = teacherDto;
          _faqs = faqList;

          _notificationsEnabled = alarmSettingDto.alarm;
          _calendarNotification = alarmSettingDto.schedule;
          _chatNotification = alarmSettingDto.chat;
        });

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userDto);
      } else {
        print('프로필 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('프로필 조회 중 오류 발생: $e');
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
            onPressed: () async {
              final googleSignIn = GoogleSignIn();
              Navigator.pop(context);

              try {
                await googleSignIn.disconnect();  // ✅ await 가능
                await googleSignIn.signOut();
              } catch (e) {
                print('Google 로그아웃 중 오류: $e');
              }

              await FirebaseAuth.instance.signOut(); // ✅ Firebase 로그아웃 추가 (필수)

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => Splash()),
              );
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
      backgroundColor: Colors.white,  // 배경색 명시적으로 화이트 지정
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
            bottom: 70,  // 네비게이션 바와 겹치지 않도록 공간 확보
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
                          Text( '${_user!.name} ${isTeacher ? '선생님' : '학생'}',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(_user!.email, style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),

                  if (isTeacher && _teacher != null) ...[
                    GestureDetector(
                      onTap: _showEditTeacherInfoPopup,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Container(
                          width: double.infinity,
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

                  // 알림 설정 카드
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
                              activeColor: Color(0xFF566B92), // 전체 알림 버튼 색 유지
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

                  // 로그아웃 카드 (담당과목 / 교무실 카드 스타일과 동일)
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

          // 하단 내비게이션 바 유지
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
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MySchool())),
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