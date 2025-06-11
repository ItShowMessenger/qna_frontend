import 'package:flutter/material.dart';
import 'package:qna_frontend/screens/MySchoolTeachers.dart';
import 'package:qna_frontend/screens/calendar.dart';
import 'package:qna_frontend/screens/login.dart'; // Login.dart import 필요
import 'package:qna_frontend/screens/splash.dart';

import 'chat.dart';
import 'home.dart';

class Option_t extends StatefulWidget {
  @override
  _OptionState createState() => _OptionState();
}

class _OptionState extends State<Option_t> {
  bool _notificationsEnabled = true;
  bool _calendarNotification = true;
  bool _chatNotification = true;
  final TextEditingController _statusMessageController = TextEditingController();
  final TextEditingController _deleteConfirmController = TextEditingController();
  final String _accountName = '000';

  @override
  void dispose() {
    _statusMessageController.dispose();
    _deleteConfirmController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmPopup() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
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
                  '진행하시겠다면 이름 : $_accountName 을 입력해주세요.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _deleteConfirmController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _deleteConfirmController.clear();
                  Navigator.pop(context);
                },
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  if (_deleteConfirmController.text.trim() == _accountName) {
                    Navigator.pop(context); // 입력 확인 다이얼로그 닫기
                    _deleteConfirmController.clear();
                    _showAlertThenMoveToLogin('회원탈퇴를 완료했습니다.');
                  } else {
                    _showAlert('입력값이 다릅니다.');
                  }
                },
                child: Text('확인', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Splash()),
              );
            },
            child: Text('확인'),
          ),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
          ),
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/topNav.png',
                fit: BoxFit.cover,
              ),
            ),

            // 타이틀 바
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
                  child: Text(
                    '옵션',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                    ),
                  ),
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
                          child: Image.asset(
                            'assets/images/def_photo.png',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
                          children: [
                            Text(
                              '선생님 000',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4), // 간격 조정
                            Text(
                              's2316@e-mirim.hs.kr',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('담당과목 : 수학', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 320, height: 15),
                            Text('교무실 : 2교무실', style: TextStyle(fontSize: 18)),
                            // TextField(
                            //   controller: _statusMessageController,
                            //   decoration: InputDecoration(
                            //     hintText: '(상태메시지가 없습니다)',
                            //     hintStyle: TextStyle(color: Colors.grey),
                            //     border: InputBorder.none,
                            //   ),
                            //   maxLines: null,
                            // ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text('자주하는 질문', style: TextStyle(fontSize: 18)),
                        //질문 리스트 작성
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                                    ? (bool value) {
                                  setState(() {
                                    _calendarNotification = value;
                                  });
                                }
                                    : null,
                              ),
                            ),
                            ListTile(
                              title: Text('채팅 알림', style: TextStyle(fontSize: 15)),
                              trailing: Switch(
                                value: _chatNotification,
                                onChanged: _notificationsEnabled
                                    ? (bool value) {
                                  setState(() {
                                    _chatNotification = value;
                                  });
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text('로그아웃', style: TextStyle(fontSize: 18)),
                        onTap: _showLogoutConfirmPopup,
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: _showDeleteConfirmPopup,
                        child: Text(
                          '회원탈퇴',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MySchoolTeachers()),
                        );},
                    ),
                    IconButton(
                      icon: Image.asset('assets/btns/chatDis.png', width: 40),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Home()),
                        );
                      },
                    ),
                    IconButton(
                      icon: Image.asset('assets/btns/calDis.png', width: 40),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Calendar()),
                        );
                      },
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
      ),
    );
  }
}