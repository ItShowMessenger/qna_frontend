import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../classes/UserProvider.dart';
import '../models/dto.dart';  // 여기에 모든 Dto 클래스가 정의되어 있음
import 'home.dart';
import 'dart:io';

StompClient? _stompClient;

class Chat extends StatefulWidget {
  final String roomId;
  final String they;

  Chat({required this.roomId, required this.they});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _myController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<MessageDto> _messages = [];
  UserDto? _user;

  Future<void> _fetchMessages() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final idToken = await currentUser?.getIdToken();

      final url = Uri.parse('https://qna-messenger.mirim-it-show.site/api/chat/${widget.roomId}');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      print('응답 코드: ${response.statusCode}');
      print('응답 바디: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);

        final List<dynamic> dataList = jsonMap['data'];

        // 'message' 키가 존재하는 요소만 필터링
        final List<MessageDto> messages = dataList
            .where((item) => item.containsKey('message'))
            .map((item) => MessageDto.fromJson(item['message']))
            .toList();

        setState(() {
          _messages = messages;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      } else {
        print('메시지 불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('에러 발생: $e');
    }
  }

  _connectWebSocket() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final idToken = await currentUser?.getIdToken();

    _stompClient = StompClient(
      config: StompConfig(
        url: 'wss://qna-messenger.mirim-it-show.site/ws-chat',  // <- SockJS 제거된 WebSocket 엔드포인트
        stompConnectHeaders: {
          'Authorization': 'Bearer $idToken',
          'Upgrade': 'websocket',
        },
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $idToken',
          'Upgrade': 'websocket',
        },
        onConnect: (StompFrame frame) {
          print('STOMP 연결 성공');

          _stompClient!.subscribe(
            destination: '/queue/chat/room/${widget.roomId}',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                final data = jsonDecode(frame.body!);
                if (data['message'] != null) {
                  final msg = MessageDto.fromJson(data['message']);
                  setState(() {
                    _messages.add(msg);
                  });
                }
              }
            },
          );
        },
        onWebSocketError: (dynamic error) => print('WebSocket 에러: $error'),
        onStompError: (frame) => print('STOMP 에러: ${frame.body}'),
        onDisconnect: (frame) => print('STOMP 연결 종료'),
      ),
    );

    _stompClient!.activate();
  }



  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _user = userProvider.user;
    _fetchMessages();
    _connectWebSocket();
  }

  void _sendMessage() {
    final text = _myController.text.trim();
    if (text.isEmpty || _user == null || _stompClient == null || !_stompClient!.connected) return;

    final payload = {
      "message": {
        "roomid": widget.roomId,
        "senderid": _user?.userid,
        "text": text,
        "hasfile": false,
        "read": false,
        "createdat": DateTime.now().toIso8601String(),
      },
      "files": [],
    };
    print(payload);

    _stompClient!.send(
      destination: '/app/chat/message',
      body: jsonEncode(payload),
    );

    _myController.clear();

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
  void dispose() {
    _myController.dispose();
    _scrollController.dispose();
    _stompClient?.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayDate = '${now.year % 100}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(top: 0, left: 0, right: 0, child: Image.asset('assets/images/topNav.png', fit: BoxFit.cover)),
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
                    icon: Image.asset('assets/icons/icon_back.png', width: 40, height: 40),
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home())),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _user?.usertype == UserType.teacher ? '${widget.they} 학생' : '${widget.they} 선생님',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(width: 40),
                ],
              ),
            ),
          ),
          Positioned(top: 150, left: 0, right: 0, child: Center(child: Text(todayDate, style: TextStyle(color: Color(0xFF8D8D8D), fontSize: 14)))),
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
                final isMe = msg.senderid == _user?.userid;
                final time = '${msg.createdat.hour.toString().padLeft(
                    2, '0')}:${msg.createdat.minute.toString().padLeft(
                    2, '0')}';

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment
                      .centerLeft,
                  child: GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: EdgeInsets.zero,
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.emoji_emotions),
                                  title: Text('이모지 추가'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    print('이모지 추가');
                                  },
                                ),
                                Divider(height: 1),
                                ListTile(
                                  leading: Icon(Icons.delete, color: Colors.red),
                                  title: Text('메시지 삭제', style: TextStyle(color: Colors.red)),
                                  onTap: () {
                                    Navigator.pop(context);
                                    print('메시지 삭제');
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },

                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isMe)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  margin: EdgeInsets.only(right: 50),
                                  constraints: BoxConstraints(
                                      maxWidth: MediaQuery
                                          .of(context)
                                          .size
                                          .width * 0.7),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF0F0F0),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      topRight: Radius.circular(18),
                                      bottomRight: Radius.circular(18),
                                    ),
                                  ),
                                  child: Text(
                                      msg.text, style: TextStyle(fontSize: 16)),
                                ),
                              if (!isMe) SizedBox(width: 4),
                              if (!isMe)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(time, style: TextStyle(
                                        fontSize: 12, color: Colors.black45)),
                                    SizedBox(height: 2),
                                    Text(msg.read ? '확인됨' : '확인안됨',
                                        style: TextStyle(fontSize: 12,
                                            color: Colors.black45)),
                                  ],
                                ),
                              if (isMe)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(time, style: TextStyle(
                                        fontSize: 12, color: Colors.black45)),
                                    SizedBox(height: 2),
                                    Text(msg.read ? '확인됨' : '확인안됨',
                                        style: TextStyle(fontSize: 12,
                                            color: Colors.black45)),
                                  ],
                                ),
                              if (isMe) SizedBox(width: 4),
                              if (isMe)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  margin: EdgeInsets.only(left: 4),
                                  constraints: BoxConstraints(
                                      maxWidth: MediaQuery
                                          .of(context)
                                          .size
                                          .width * 0.6),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('assets/images/my.png'),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  child: Text(msg.text, style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
          )),


          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,  // 입력 필드 배경을 흰색으로
                border: Border.all(color: Colors.black, width: 1),  // 검은 테두리
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  // 플러스 아이콘 (왼쪽)
                  GestureDetector(
                    onTap: () {
                      // 플러스 버튼 눌렀을 때 처리
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/icons/icon_plusChat.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // 입력 필드
                  Expanded(
                    child: TextField(
                      controller: _myController,
                      maxLines: null,
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: "메시지를 입력하세요.",
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        border: InputBorder.none,  // 테두리 없애고, 외부 컨테이너 테두리만 사용
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  // 전송 버튼
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Color(0xFF3C72BD),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.send, color: Colors.white),
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