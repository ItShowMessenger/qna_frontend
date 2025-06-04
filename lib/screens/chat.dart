import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _controller = TextEditingController();
  String _chatText = '';
  DateTime _sendTime = DateTime.now();

  void _sendMessage() {
    setState(() {
      _chatText = _controller.text.trim();
      _sendTime = DateTime.now(); // 보낸 시간 저장
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String todayDate =
        '${now.year % 100}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
    final String time =
        '${_sendTime.hour.toString().padLeft(2, '0')}:${_sendTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      body: Stack(
        children: [
          // 상단 네비 이미지
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/topNav.png',
              fit: BoxFit.cover,
            ),
          ),

          // 네비게이션 바
          Positioned(
            top: 42,
            left: 0,
            right: 0,
            child: Container(
              color: Color(0xFF566B92),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/icons/icon_back.png',
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
                  Expanded(
                    child: Center(
                      child: Text(
                        '6학년 6반 미림선생님',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 40),
                ],
              ),
            ),
          ),

          // 날짜 표시
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                todayDate,
                style: TextStyle(
                  color: Color(0xFF8D8D8D),
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // 채팅 말풍선
          Positioned(
            top: 210,
            left: 16,
            right: 16,
            child: _chatText.isNotEmpty
                ? Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.all(12),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF566B92),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _chatText,
                      style:
                      TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          '확인됨', // 또는 '확인안됨'
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
                : Container(),
          ),

          // 하단 입력창
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // 앞쪽 버튼 (예: 추가 버튼)
                  IconButton(
                    icon: Image.asset(
                      'assets/icons/icon_plusFile.png',
                      width: 28,
                      height: 28,
                    ),
                    onPressed: () {
                      // 추가 기능 구현
                    },
                  ),
                  SizedBox(width: 4),

                  // 입력창
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),

                  // 전송 버튼 (이미지 사용)
                  IconButton(
                    icon: Image.asset(
                      'assets/icons/icon_input.png',
                      width: 28,
                      height: 28,
                    ),
                    onPressed: _sendMessage,
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