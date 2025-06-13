import 'package:flutter/material.dart';
import 'package:qna_frontend/services/api_service.dart';
import 'package:qna_frontend/screens/option_stu.dart';
import 'calendar.dart';
import 'home.dart';
import 'profile_stu.dart';

class MySchoolTeachers extends StatefulWidget {
  @override
  _MySchoolTeachersState createState() => _MySchoolTeachersState();
}

class _MySchoolTeachersState extends State<MySchoolTeachers> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _teachers = [];

  void _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    try {
      final results = await ApiService.fetchUserList(query: query);
      setState(() => _teachers = results);
    } catch (e) {
      print('검색 오류: $e');
    }
  }

  void _openProfile(String userId) async {
    try {
      final profile = await ApiService.fetchUserProfile(userId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Profile_stu(data: profile),
        ),
      );
    } catch (e) {
      print('프로필 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 상단 네비게이션 이미지
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/topNav.png',
              fit: BoxFit.cover,
            ),
          ),
          // 검색 아이콘
          Positioned(
            top: 50,
            right: 16,
            child: Image.asset(
              'assets/icons/icon_search.png',
              color: Colors.white,
              width: 30,
              height: 30,
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
              padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '우리 학교 선생님',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                  ),
                ),
              ),
            ),
          ),
          // 검색창
          Positioned(
            top: 120,
            left: 16,
            right: 16,
            child: SizedBox(
              width: double.infinity,
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: '성함으로 찾기',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          // 검색 결과 리스트
          Positioned(
            top: 190,
            left: 16,
            right: 16,
            bottom: 70,
            child: SingleChildScrollView(
              child: Column(
                children: _teachers.map((teacher) {
                  return GestureDetector(
                    onTap: () => _openProfile(teacher['userDto']['userId']),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
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
                          CircleAvatar(
                            backgroundImage:
                            AssetImage('assets/images/def_photo.png'),
                            radius: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  teacher['userDto']?['name'] ?? '이름 없음',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  teacher['teacherDto']?['subject'] ?? '',
                                  style:
                                  TextStyle(color: Colors.grey[800]),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // 하단 탭바
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
                    icon: Image.asset(
                      'assets/btns/mypgAct.png',
                      width: 40,
                      height: 40,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Image.asset(
                      'assets/btns/chatDis.png',
                      width: 40,
                      height: 40,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Image.asset(
                      'assets/btns/calDis.png',
                      width: 40,
                      height: 40,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Calendar()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Image.asset(
                      'assets/btns/optDis.png',
                      width: 40,
                      height: 40,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Option_stu()),
                      );
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
