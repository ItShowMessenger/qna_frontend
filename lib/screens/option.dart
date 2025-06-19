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

  final switchActiveColor = Color(0xFF566B92);
  final switchInactiveThumbColor = Colors.grey.shade400;
  final switchInactiveTrackColor = Colors.grey.shade300;

  final TextEditingController _deleteConfirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserFromProvider();
    _fetchUserProfile();
  }

  void _loadUserFromProvider() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      _user = userProvider.user;
      _teacher = userProvider.teacher;
      _faqs = userProvider.faqs;

      // ✅ 알림 설정도 불러오기
      final alarm = userProvider.alarmSetting;
      if (alarm != null) {
        _notificationsEnabled = alarm.alarm;
        _calendarNotification = alarm.schedule;
        _chatNotification = alarm.chat;
      }
    });
  }

  Future<void> _fetchUserProfile() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final idToken = await currentUser?.getIdToken();

      if (idToken == null) return;

      final response = await http.get(
        Uri.parse('https://qna-messenger.mirim-it-show.site/api/user/profile'),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
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
        userProvider.setTeacher(teacherDto);
        userProvider.setFaqs(faqList);
        userProvider.setAlarmSetting(alarmSettingDto);
      } else {
        print('프로필 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('프로필 조회 오류: $e');
    }
  }

  Future<void> _updateAlarmSettings() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final idToken = await currentUser?.getIdToken();

      if (idToken == null || _user == null) return;

      final alarmSettings = AlarmSettingDto(
        userid: _user!.userid,
        alarm: _notificationsEnabled,
        chat: _chatNotification,
        schedule: _calendarNotification,
      );

      final response = await http.patch(
        Uri.parse('https://qna-messenger.mirim-it-show.site/api/user/alarm'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(alarmSettings.toJson()),
      );

      if (response.statusCode != 200) {
        print('알림 설정 저장 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('알림 저장 오류: $e');
    }
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

      final updatedTeacher = _teacher!.copyWith(
        subject: _newSubject,
        office: _newOffice,
      );

      final response = await http.patch(
        Uri.parse('https://qna-messenger.mirim-it-show.site/api/user/teacher'),
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

  Future<void> _updateAlarmSetting() async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (_user == null || idToken == null) return;

    final updated = AlarmSettingDto(
      userid: _user!.userid, // 또는 _user!.userid, DTO에 따라
      alarm: _notificationsEnabled,
      chat: _chatNotification,
      schedule: _calendarNotification,
    );

    final response = await http.patch(
      Uri.parse('https://qna-messenger.mirim-it-show.site/api/user/alarm'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updated.toJson()),
    );

    if (response.statusCode == 200) {
      Provider.of<UserProvider>(context, listen: false).setAlarmSetting(updated);
    } else {
      print('알림 설정 저장 실패: ${response.statusCode}');
    }
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
            Text('- 채팅방에서 나가지며 대화 내역도 삭제됩니다.'),
            SizedBox(height: 8),
            Text('- 개인 프로필 설정이 모두 사라집니다.'),
            SizedBox(height: 16),
            Text('진행하시려면 이름: ${_user!.name} 을 입력해주세요.', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _deleteConfirmController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
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
          TextButton(child: Text('취소'), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: Text('로그아웃'),
            onPressed: () async {
              final googleSignIn = GoogleSignIn();
              Navigator.pop(context);

              try {
                await googleSignIn.disconnect();
                await googleSignIn.signOut();
              } catch (e) {
                print('Google 로그아웃 오류: $e');
              }

              await FirebaseAuth.instance.signOut();

              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Splash()));
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _deleteConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isTeacher = _user!.usertype == UserType.teacher;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(top: 0, left: 0, right: 0, child: Image.asset('assets/images/topNav.png', fit: BoxFit.cover)),
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
                          Text('${_user!.name} ${isTeacher ? '선생님' : '학생'}',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(_user!.email, style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),

                  if (isTeacher) ...[
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
                    // Card(
                    //   elevation: 2,
                    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    //   child: ExpansionTile(
                    //     title: Text('자주하는 질문', style: TextStyle(fontSize: 18)),
                    //     children: _faqs
                    //         .map((faq) => ListTile(
                    //       title: Text(faq.question),
                    //       subtitle: Text(faq.answer),
                    //     ))
                    //         .toList(),
                    //   ),
                    // ),
                    SizedBox(height: 20),
                  ],

                  /// 알림 설정 UI
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
                              activeColor: switchActiveColor,
                              inactiveThumbColor: switchInactiveThumbColor,
                              inactiveTrackColor: switchInactiveTrackColor,
                              onChanged: (bool value) {
                                setState(() {
                                  _notificationsEnabled = value;
                                  if (value) {
                                    _calendarNotification = true;
                                    _chatNotification = true;
                                  } else {
                                    _calendarNotification = false;
                                    _chatNotification = false;
                                  }
                                });
                                _updateAlarmSetting();
                              },
                            ),
                          ),

// 일정 알림 스위치
                          ListTile(
                            title: Text('일정 알림', style: TextStyle(fontSize: 15)),
                            trailing: Switch(
                              value: _calendarNotification,
                              activeColor: switchActiveColor,
                              inactiveThumbColor: switchInactiveThumbColor,
                              inactiveTrackColor: switchInactiveTrackColor,
                              onChanged: _notificationsEnabled
                                  ? (bool value) {
                                setState(() {
                                  _calendarNotification = value;
                                  // 전체 알림이나 다른 알림 상태는 건드리지 않음
                                });
                                _updateAlarmSetting();
                              }
                                  : null,
                            ),
                          ),

                          ListTile(
                            title: Text('채팅 알림', style: TextStyle(fontSize: 15)),
                            trailing: Switch(
                              value: _chatNotification,
                              activeColor: switchActiveColor,
                              inactiveThumbColor: switchInactiveThumbColor,
                              inactiveTrackColor: switchInactiveTrackColor,
                              onChanged: _notificationsEnabled
                                  ? (bool value) {
                                setState(() {
                                  _chatNotification = value;
                                  // 전체 알림이나 다른 알림 상태는 건드리지 않음
                                });
                                _updateAlarmSetting();
                              }
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
