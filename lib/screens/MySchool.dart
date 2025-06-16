import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qna_frontend/models/dto.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';

import 'calendar.dart';
import 'home.dart';
import 'option.dart';
import 'profile.dart';
import '../classes/UserProvider.dart';

class MySchool extends StatefulWidget {
  @override
  _MySchool createState() => _MySchool();
}

class _MySchool extends State<MySchool> {
  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];
  String _searchText = '';
  String _userType = '';
  UserDto? _my;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final idToken = await currentUser?.getIdToken();
      if (idToken == null) return;

      _my = userProvider.user;
      if (_my == null) return;

      setState(() {
        _userType = _my!.usertype.name.toUpperCase();
      });

      final uri = Uri.parse('https://qna-messenger.mirim-it-show.site/api/teacher/search?search=');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> data = decoded['data'];
        setState(() {
          _allUsers = data;
        });
        _filterUsers();
      } else {
        print('전체 유저 불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('에러 발생: $e');
    }
  }

  void _filterUsers() {
    final isTeacher = _userType == 'TEACHER';
    setState(() {
      _filteredUsers = _allUsers.where((item) {
        final user = item['user'];
        if (user == null) return false;
        final userType = user['usertype'];
        final name = user['name']?.toString().toLowerCase() ?? '';
        final search = _searchText.toLowerCase();
        final targetType = isTeacher ? 'STUDENT' : 'TEACHER';
        return userType == targetType && name.contains(search);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = _userType == 'TEACHER';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: Image.asset('assets/images/topNav.png', fit: BoxFit.cover),
          ),
          Positioned(
            top: 50, right: 16,
            child: Image.asset('assets/icons/icon_search.png', color: Colors.white, width: 30, height: 30),
          ),
          Positioned(
            top: 40, left: 0, right: 0,
            child: Container(
              height: 60,
              color: Color(0xFF3C72BD),
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  isTeacher ? '우리 학교 학생' : '우리 학교 선생님',
                  style: TextStyle(color: Colors.white, fontSize: 23),
                ),
              ),
            ),
          ),
          Positioned(
            top: 120, left: 16, right: 16,
            child: TextField(
              onChanged: (text) {
                setState(() {
                  _searchText = text;
                });
                _filterUsers();
              },
              decoration: InputDecoration(
                hintText: isTeacher ? '학생 이름으로 찾기' : '성함으로 찾기',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
          Positioned(
            top: 190,
            left: 0,
            right: 0,
            bottom: 70,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _filteredUsers.isEmpty
                  ? Align(
                alignment: Alignment(0, -0.3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isTeacher
                          ? '아직 Q&A에 가입한 학생이 없어요!\n아래 버튼으로 초대해보세요!'
                          : '아직 Q&A에 가입하신 선생님이 없어요!\n아래 버튼으로 초대해보세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    if (!isTeacher)
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await Share.share(
                              'Q&A에 가입해보세요!\n https://github.com/ItShowMessenger',
                              subject: 'Q&A 선생님 초대',
                            );
                          } catch (e) {
                            print("공유 실패: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('공유에 실패했습니다.')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3C72BD),
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        icon: Image.asset(
                          'assets/icons/icon_share.png',
                          width: 20,
                          height: 20,
                          color: Colors.white,
                        ),
                        label: Text(
                          '링크 공유하기',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final person = _filteredUsers[index];
                  final user = person['user'];
                  final roleInfo = isTeacher ? null : person['teacher'];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Profile(
                            userType: user['usertype'],
                            data: {
                              'userDto': user,
                              'teacherDto': roleInfo,
                            },
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            margin: EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[300],
                            ),
                            child: user['imgurl'] != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                user['imgurl'],
                                fit: BoxFit.cover,
                                width: 48,
                                height: 48,
                              ),
                            )
                                : Image.asset('assets/images/def_photo.png'),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isTeacher ? '${user['name']} 학생' : '${user['name']} 선생님',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  isTeacher
                                      ? user['email'] ?? ''
                                      : (roleInfo?['subject'] ?? '과목 없음'),
                                  style: TextStyle(color: Colors.grey[900]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              color: Color(0xFF3C72BD),
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Image.asset('assets/btns/mypgAct.png', width: 40),
                    onPressed: () {},
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
    );
  }
}
