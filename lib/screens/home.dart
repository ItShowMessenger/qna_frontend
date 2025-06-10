import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qna_frontend/screens/option_stu.dart';

import 'calendar.dart';
import 'chat.dart';

class Home extends StatelessWidget {
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
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              height: 50,
              color: Color(0xFF3C72BD), // #566B92 배경
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
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
                    width: 30,
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Container(
              height: 20,
              color: Color(0xFF3C72BD),
              padding: EdgeInsets.fromLTRB(25, 8, 25, 0),
            ),
          ),
          Positioned( // 채팅방 항목
            top: 140,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Chat()),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 프로필 이미지
                    Container(
                      width: 48,
                      height: 48,
                      margin: EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset('assets/images/def_photo.png'),
                    ),

                    // 이름과 메시지
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '선생님 이름',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '최신 메시지 내용',
                            style: TextStyle(color: Colors.grey[900]),
                          ),
                        ],
                      ),
                    ),

                    // 안읽은 메시지 수 + 시간
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(0xFF3C72BD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '1',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '1시간 전',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),


          Positioned( // 하단 탭 바
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
                    icon: Image.asset('assets/btns/mypgDis.png', width: 40, height: 40,),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Image.asset('assets/btns/chatAct.png', width: 40, height: 40,),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Image.asset('assets/btns/calDis.png', width: 40, height: 40,),
                    onPressed: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Calendar()),
                    );
                      },
                  ),
                  IconButton(
                    icon: Image.asset('assets/btns/optDis.png', width: 40, height: 40,),
                    onPressed: () {Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Option_stu()),
                    );},
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