import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home_input extends StatelessWidget {
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
          Positioned( //채팅 + 검색 아이콘
            top: 42,
            left: 0,
            right: 0,
            child: Container(
              color: Color(0xFF566B92), // #566B92 배경
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '채팅',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                    ),
                  ),
                  Image.asset(
                    'assets/icons/icon_search.png', // 또는 Image.asset('assets/icon.png')
                    color: Colors.white,
                    width: 40,
                    height: 40,
                  ),
                ],
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
                    icon: Image.asset('assets/btns/chatAct.png', width: 40, height: 40,),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Image.asset('assets/btns/calDis.png', width: 40, height: 40,),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Image.asset('assets/btns/optDis.png', width: 40, height: 40,),
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