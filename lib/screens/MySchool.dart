import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'calendar.dart';
import 'home.dart';
import 'option.dart';

class MySchool extends StatefulWidget {
  @override
  _MySchool createState() => _MySchool();
}

class _MySchool extends State<MySchool> {
  List<dynamic> _teachers = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _fetchTeachers(); // 전체 선생님 초기 로딩
  }

  Future<void> _fetchTeachers() async {
    try {
      final uri = Uri.parse('https://your-api-domain.com/api/teacher/search?search=$_searchText');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final result = jsonDecode(utf8.decode(response.bodyBytes)); // 인코딩 오류 방지용
        if (result['success'] == true && result['data'] != null) {
          setState(() {
            _teachers = result['data'];
          });
        }
      } else {
        print('선생님 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('에러 발생: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
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
                child: Text('우리 학교 선생님', style: TextStyle(color: Colors.white, fontSize: 23)),
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
                _fetchTeachers();
              },
              decoration: InputDecoration(
                hintText: '성함으로 찾기',
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
              child: _teachers.isEmpty
                  ? Align(
                alignment: Alignment(0, -0.3), // 중앙보다 위쪽으로 조정
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                    '아직 Q&A에 가입하신 선생님이 없어요!\n아래 버튼으로 초대해보세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: (){},
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
              )
              )
                  : ListView.builder(
                itemCount: _teachers.length,
                itemBuilder: (context, index) {
                  final teacher = _teachers[index];
                  return Container(
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
                          child: teacher['imgurl'] != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              teacher['imgurl'],
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
                                teacher['name'] ?? '이름 없음',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              SizedBox(height: 4),
                              Text(
                                teacher['subject'] ?? '과목 없음',
                                style: TextStyle(color: Colors.grey[900]),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => Option(user: user,)));
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
