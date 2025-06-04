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
          Positioned( //백스페이스 + 코드 입력
            top: 42,
            left: 0,
            right: 0,
            child: Container(
              color: Color(0xFF566B92), // #566B92 배경
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Image.asset('assets/icons/icon_back.png', width: 40, height: 40,),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '코드 입력',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 40),
                ],
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 30), // 상단 여백 조절 (네비 영역 피하기 위해)
                  Text(
                    '선생님에게 받은 코드를 입력해주세요.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '코드 입력',
                      hintStyle: TextStyle(color: Colors.grey),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  SizedBox(height: 15),

                  // 버튼: 입력 박스와 너비 맞춤
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 채팅 시작 기능
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF566B92),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text(
                        '채팅 시작하기',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
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