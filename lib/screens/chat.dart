import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../classes/UserProvider.dart';
import '../models/dto.dart'; // 여기에 모든 Dto 클래스가 정의되어 있음
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
  Map<String, String> _emojiMap = {};


  List<MessageDto> _messages = [];
  UserDto? _user;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _fetchMessages() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final idToken = await currentUser?.getIdToken();

      final url = Uri.parse(
        'https://qna-messenger.mirim-it-show.site/api/chat/${widget.roomId}',
      );

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

        final List<MessageDto> messages = [];

        for (var item in dataList) {
          if (item is Map<String, dynamic> && item.containsKey('message')) {
            try {
              final msg = MessageDto.fromJson(item['message']);
              messages.add(msg);
            } catch (e) {
              print('📛 메시지 파싱 중 오류: $e');
            }
          }
        }

        setState(() {
          _messages = messages;
        });
        _scrollToBottom();
      }
      else {
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
        url: 'wss://qna-messenger.mirim-it-show.site/ws-chat',
        // <- SockJS 제거된 WebSocket 엔드포인트
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

  Future<void> addEmojiToMessage(String messageId, String emoji) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final idToken = await currentUser?.getIdToken();

    final url = Uri.parse(
      'https://qna-messenger.mirim-it-show.site/api/chat/message/emoji/$messageId',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({'emoji': emoji}),
    );

    print('이모지 응답: ${response.statusCode}');
  }

  void _showEmojiPicker(Function(String) onEmojiSelected) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final emojis = ["😍", "👍", "🎉", "😭", "🤔", "✅"];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children:
                  emojis.map((emoji) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // 닫고
                        onEmojiSelected(emoji); // 선택한 이모지를 전달
                      },
                      child: Text(emoji, style: TextStyle(fontSize: 30)),
                    );
                  }).toList(),

            ),
          ),
        );
      },
    );
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
    if (text.isEmpty ||
        _user == null ||
        _stompClient == null ||
        !_stompClient!.connected)
      return;

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
    final todayDate =
        '${now.year % 100}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.white,
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
                    onPressed:
                        () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => Home()),
                        ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _user?.usertype == UserType.teacher
                            ? '${widget.they} 학생'
                            : '${widget.they} 선생님',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(width: 40),
                ],
              ),
            ),
          ),
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
                final time =
                    '${msg.createdat.hour.toString().padLeft(2, '0')}:${msg.createdat.minute.toString().padLeft(2, '0')}';

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
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
                                    Navigator.pop(context); // 기존 바텀시트 닫기
                                    _showEmojiPicker((selectedEmoji) async {
                                      print('선택된 이모지: $selectedEmoji');

                                      final currentUser =
                                          FirebaseAuth.instance.currentUser;
                                      final idToken =
                                          await currentUser?.getIdToken();

                                      final url = Uri.parse(
                                        'https://qna-messenger.mirim-it-show.site/api/chat/message/emoji/${msg.messageid}',
                                      );
                                      final response = await http.post(
                                        url,
                                        headers: {
                                          'Content-Type': 'application/json',
                                          'Authorization': 'Bearer $idToken',
                                        },
                                        body: jsonEncode({
                                          "emoji": selectedEmoji,
                                        }),
                                      );

                                      if (response.statusCode == 200) {
                                        print("✅ 이모지 저장 성공");

                                        // 서버 응답을 파싱해서 필요하면 출력
                                        final responseData = jsonDecode(
                                          response.body,
                                        );
                                        final emojiData = responseData['data'];
                                        print("서버에서 받은 이모지 데이터: $emojiData");

                                        // 이모지 UI만 갱신되도록 상태 업데이트
                                        setState(() {
                                          // 메시지 리스트에서 해당 메시지를 갱신하거나
                                          // 화면 다시 그리게만 하면 돼
                                        });
                                      } else {
                                        print("❌ 이모지 저장 실패: ${response.body}");
                                      }
                                    });
                                  },
                                ),
                                Divider(height: 1),
                                ListTile(
                                  leading: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  title: Text(
                                    '메시지 삭제',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                    onTap: () async {
                                      // ✅ 상위에서 context를 미리 저장
                                      final safeContext = Navigator.of(context).context;

                                      // 먼저 BottomSheet 닫기
                                      Navigator.pop(context);

                                      try {
                                        final currentUser = FirebaseAuth.instance.currentUser;
                                        final idToken = await currentUser?.getIdToken();

                                        final url = Uri.parse(
                                          'https://qna-messenger.mirim-it-show.site/api/chat/message/delete/${msg.messageid}',
                                        );

                                        final response = await http.delete(
                                          url,
                                          headers: {
                                            'Authorization': 'Bearer $idToken',
                                          },
                                        );

                                        final responseData = jsonDecode(response.body);

                                        if (response.statusCode == 200 && responseData['success'] == true) {
                                          print("✅ 메시지 삭제 성공");

                                          if (mounted) {
                                            setState(() {
                                              _messages.removeWhere((m) => m.messageid == msg.messageid);
                                            });
                                          }
                                        } else {
                                          final serverMessage = responseData['message'];

                                          String alertText;
                                          if (serverMessage.contains('5분 이내에만')) {
                                            alertText = '5분 이내의 메시지만 삭제 가능합니다.';
                                          } else if (serverMessage.contains('내가 작성한')) {
                                            alertText = '내 메시지만 삭제할 수 있습니다.';
                                          } else {
                                            alertText = '메시지 삭제에 실패했습니다.';
                                          }

                                          // ✅ 반드시 유효한 context 사용
                                          if (safeContext.mounted) {
                                            showDialog(
                                              context: safeContext,
                                              builder: (context) => AlertDialog(
                                                title: Text('삭제 실패'),
                                                content: Text(alertText),
                                                actions: [
                                                  TextButton(
                                                    child: Text('확인'),
                                                    onPressed: () => Navigator.of(context).pop(),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        print("❌ 메시지 삭제 중 오류 발생: $e");

                                        // 예외 처리용 다이얼로그
                                        if (safeContext.mounted) {
                                          showDialog(
                                            context: safeContext,
                                            builder: (context) => AlertDialog(
                                              title: Text('오류 발생'),
                                              content: Text('네트워크 오류 또는 알 수 없는 문제가 발생했습니다.'),
                                              actions: [
                                                TextButton(
                                                  child: Text('확인'),
                                                  onPressed: () => Navigator.of(context).pop(),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      }
                                    }
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
                        crossAxisAlignment:
                            isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                isMe
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isMe)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  margin: EdgeInsets.only(right: 50),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF0F0F0),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      topRight: Radius.circular(18),
                                      bottomRight: Radius.circular(18),
                                    ),
                                  ),
                                  child: Text(
                                    msg.text,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              if (!isMe) SizedBox(width: 4),
                              if (!isMe)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      msg.read ? '확인됨' : '확인안됨',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              if (isMe)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
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
                                      msg.read ? '확인됨' : '확인안됨',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              if (isMe) SizedBox(width: 4),
                              if (isMe)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
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
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white, // 입력 필드 배경을 흰색으로
                border: Border.all(color: Colors.black, width: 1), // 검은 테두리
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
                      decoration: BoxDecoration(shape: BoxShape.circle),
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
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        border: InputBorder.none,
                        // 테두리 없애고, 외부 컨테이너 테두리만 사용
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
