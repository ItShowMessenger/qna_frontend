import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qna_frontend/screens/calendar.dart';
import 'package:qna_frontend/screens/home_input.dart';

import 'chat.dart';
import 'home.dart';

class Option extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      body: Stack( //네비게이션 바
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
          Positioned( //옵션
            top: 46,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              color: Color(0xFF566B92),
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


          Positioned( // 하단 탭 바
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Color(0xFF566B92),
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Image.asset('assets/btns/mypgDis.png', width: 40, height: 40,),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Image.asset('assets/btns/chatDis.png', width: 40, height: 40,),
                    onPressed: () {Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );},
                  ),
                  IconButton(
                    icon: Image.asset('assets/btns/calDis.png', width: 40, height: 40,),
                    onPressed: () {Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Calendar()),
                    );},
                  ),
                  IconButton(
                    icon: Image.asset('assets/btns/optAct.png', width: 40, height: 40,),
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