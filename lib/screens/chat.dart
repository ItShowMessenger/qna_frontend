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
  final TextEditingController _otherController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  void _sendMessage({required bool isMe}) {
    final controller = isMe ? _myController : _otherController;
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        time: DateTime.now(),
        isMe: isMe,
        isRead: !isMe,
      ));
      controller.clear();
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
    bool showAttachment = false;
    final String todayDate =
        '${now.year % 100}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

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
                        '6학년 6반 미림선생님',
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
                  alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment:
                      msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: msg.isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!msg.isMe) ...[
                              Container(
                                padding: EdgeInsets.all(12),
                                constraints: BoxConstraints(
                                  maxWidth:
                                  MediaQuery.of(context).size.width * 0.7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Color(0xFFCCCCCC)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  msg.text,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              SizedBox(width: 8),
                            ],
                            if (msg.isMe)
                              SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: msg.isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  time,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  msg.isRead ? '확인됨' : '확인안됨',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                            if (msg.isMe) ...[
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.all(12),
                                constraints: BoxConstraints(
                                  maxWidth:
                                  MediaQuery.of(context).size.width * 0.7,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFF3C72BD),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  msg.text,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
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

          // 하단 입력창 2개
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.grey[100],
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _otherController,
                      decoration: InputDecoration(
                        hintText: '상대방 메시지 입력',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    onPressed: () => _sendMessage(isMe: false),
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
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
            ),
          ),
        ],
      ),
    );
  }
}

