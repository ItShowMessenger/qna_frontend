import 'package:flutter/material.dart';
import 'package:qna_frontend/screens/MySchool.dart';
import 'package:qna_frontend/screens/calendar.dart';
import 'package:qna_frontend/screens/login.dart';
import 'MySchool.dart';
import 'chat.dart';
import 'home.dart';

class Profile_stu extends StatefulWidget {
  final dynamic data;
  Profile_stu({required this.data});

  @override
  _Profile_stuState createState() => _Profile_stuState();
}

class _Profile_stuState extends State<Profile_stu> {
  @override
  Widget build(BuildContext context) {
    final name = widget.data['userDto']?['name'] ?? '이름 없음';
    final email = widget.data['userDto']?['email'] ?? '이메일 없음';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                  child: Text(
                    '프로필',
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              email,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
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
                          MaterialPageRoute(
                            builder: (context) => MySchool(),
                          ),
                        );
                      },
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
