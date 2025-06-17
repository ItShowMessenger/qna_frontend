import 'package:flutter/material.dart';
import 'home.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class ChatMessage {
  final String text;
  final DateTime time;
  final bool isMe;
  final bool isRead;

  ChatMessage({
    required this.text,
    required this.time,
    required this.isMe,
    required this.isRead,
  });
}

class _ChatState extends State<Chat> {
  final TextEditingController _myController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool showAttachment = false;

  void _sendMessage({required bool isMe}) {
    final controller = isMe ? _myController : null;
    final text = controller?.text.trim() ?? '';
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        time: DateTime.now(),
        isMe: isMe,
        isRead: !isMe,
      ));
      controller?.clear();
    });

    // 자동 스크롤
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String todayDate =
        '${now.year % 100}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.white,
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
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              color: Color(0xFF3C72BD),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
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
                        'OOO 선생님',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(width: 40),
                ],
              ),
            ),
          ),

          // 날짜
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                todayDate,
                style: TextStyle(color: Color(0xFF8D8D8D), fontSize: 14),
              ),
            ),
          ),

          // 메시지 리스트
          Positioned(
            top: 180,
            left: 0,
            right: 0,
            bottom: 150,
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final time =
                    '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}';

                return Align(
                  alignment:
                  msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: msg.isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: msg.isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!msg.isMe) ...[
                              // 상대방 말풍선
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                margin: EdgeInsets.only(
                                  left: msg.isMe ? 50 : 0,
                                  right: msg.isMe ? 0 : 50,
                                  top: 4,
                                  bottom: 4,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                decoration: BoxDecoration(
                                  color: msg.isMe ? Color(0xFF3C72BD) : Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(18),
                                    topRight: Radius.circular(18),
                                    bottomLeft:
                                    Radius.circular(msg.isMe ? 18 : 0), // 본인이면 왼쪽도 둥글게
                                    bottomRight:
                                    Radius.circular(msg.isMe ? 0 : 18), // 상대방이면 오른쪽 둥글게
                                  ),
                                ),
                                child: Text(
                                  msg.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: msg.isMe ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                              SizedBox(width: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    time,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black45),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    msg.isRead ? '확인됨' : '확인안됨',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black45),
                                  ),
                                ],
                              ),
                            ],
                            if (msg.isMe) ...[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    time,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black45),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    msg.isRead ? '확인됨' : '확인안됨',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black45),
                                  ),
                                ],
                              ),
                              SizedBox(width: 4),
                              // 내 말풍선
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                margin: EdgeInsets.only(left: 4),
                                constraints: BoxConstraints(
                                  maxWidth:
                                  MediaQuery.of(context).size.width * 0.6,
                                ),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/my.png'),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: Text(
                                  msg.text,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
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
                  IconButton(
                    icon: Image.asset(
                      'assets/icons/icon_plusFile.png',
                      width: 28,
                      height: 28,
                    ),
                    onPressed: () {
                      setState(() {
                        showAttachment = !showAttachment;
                      });
                    },
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _myController,
                      decoration: InputDecoration(
                        hintText: '메세지를 입력해주세요.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Image.asset(
                      'assets/icons/icon_input.png',
                      width: 28,
                      height: 28,
                    ),
                    onPressed: () => _sendMessage(isMe: true),
                  ),
                ],
              ),
            ),
          ),

          // 첨부파일 영역 (showAttachment 상태에 따라)
          if (showAttachment)
            Positioned(
              bottom: 130,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 12),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // 첨부 버튼들 자리
                    //_attachmentButton(icon: Icons.photo, label: "사진"),
                    //_attachmentButton(icon: Icons.insert_drive_file, label: "파일"),
                    //_attachmentButton(icon: Icons.audiotrack, label: "오디오"),
                    //_attachmentButton(icon: Icons.calendar_today, label: "일정"),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
