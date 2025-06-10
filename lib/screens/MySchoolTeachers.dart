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

      body: Column(
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
          Container(
            padding: EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 15),
            color: Color(0xFF3C72BD),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
                Text(
                  '우리 학교 선생님',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),

          // 검색창
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

          // 선생님 항목 UI
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

          // Spacer
          Expanded(child: SizedBox()),

          // 하단 탭바
          Container(
            color: Color(0xFF3C72BD),
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Image.asset('assets/btns/mypgAct.png', width: 40, height: 40),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Image.asset('assets/btns/chatDis.png', width: 40, height: 40),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  },
                ),
                IconButton(
                  icon: Image.asset('assets/btns/calDis.png', width: 40, height: 40),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Calendar()),
                    );
                  },
                ),
                IconButton(
                  icon: Image.asset('assets/btns/optDis.png', width: 40, height: 40),
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
        ],
      ),
    );
  }
}