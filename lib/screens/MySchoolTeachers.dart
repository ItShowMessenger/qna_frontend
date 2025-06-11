import 'package:flutter/material.dart';
import 'package:qna_frontend/screens/option_stu.dart';

import 'calendar.dart';
import 'home.dart';

class MySchoolTeachers extends StatefulWidget {
  @override
  _MySchoolTeachersState createState() => _MySchoolTeachersState();
}

class _MySchoolTeachersState extends State<MySchoolTeachers> {
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
          // 검색 아이콘 (원래 Positioned가 아니었던 부분을 Positioned로 감쌈)
          Positioned(
            top: 50, // 필요에 따라 위치 조정
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
            top: 120, // 타이틀 바 아래에 배치 (예시)
            left: 16,
            right: 16,
            child: SizedBox(
              width: double.infinity,
              child: TextField(
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
          // 선생님 항목 UI (Padding 대신 Positioned로 배치)
          Positioned(
            top: 190, // 검색창 아래에 배치 (예시)
            left: 16,
            right: 16,
            child: Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    child: Image.asset('assets/images/def_photo.png'),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '선생님 이름',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '담당 과목',
                          style: TextStyle(color: Colors.grey[900]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 하단 탭바 (원래 Container였던 부분도 Positioned로 배치)
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