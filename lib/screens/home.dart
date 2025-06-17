import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qna_frontend/screens/MySchool.dart';
import '../models/dto.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'MySchool.dart';
import 'calendar.dart';
import 'chat.dart';
import 'option.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<RoomDto> _rooms = [];
  String _search = '';
  bool _isSearching = false;
  final FocusNode _focusNode = FocusNode();
  late String _teacherId;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _isSearching = false;
        });
      }
    });
    _loadTeacherId();
  }

  Future<void> _loadTeacherId() async {
    final user = FirebaseAuth.instance.currentUser;
    _teacherId = user?.uid ?? '';
    await _loadRooms();
  }

  Future<void> _loadRooms() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final idToken = await currentUser?.getIdToken();
    try {
      final url = Uri.parse(
          'https://qna-messenger.mirim-it-show.site/api/chat/search?search=$_search');
      final response = await http.get(url,
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        final res = Response<List<dynamic>>.fromJson(decoded, (data) => data);

        final List<RoomDto> rooms = (res.data as List<dynamic>)
            .map((e) => RoomDto.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() => _rooms = rooms);
      } else {
        print('API 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('예외 발생: $e');
    }
  }

  Future<String> _fetchStudentName(String studentId) async {
    // 예시 API URL: 학생 정보 조회 API 주소를 적절히 수정하세요.
    final currentUser = FirebaseAuth.instance.currentUser;
    final idToken = await currentUser?.getIdToken();

    try {
      final url = Uri.parse(
          'https://qna-messenger.mirim-it-show.site/api/student/$studentId');
      final response = await http.get(url,
          headers: {'Authorization': 'Bearer $idToken'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['name'] ?? '알 수 없음';
      } else {
        print('학생 정보 API 오류: ${response.statusCode}');
        return '알 수 없음';
      }
    } catch (e) {
      print('학생 정보 조회 중 예외 발생: $e');
      return '알 수 없음';
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              _isSearching = false;
            });
          },
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child:
                Image.asset('assets/images/topNav.png', fit: BoxFit.cover),
              ),
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Container(
                  height: 50,
                  color: Color(0xFF3C72BD),
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: _isSearching
                      ? TextField(
                    focusNode: _focusNode,
                    onChanged: (value) {
                      setState(() {
                        _search = value;
                      });
                      _loadRooms(); // 검색어 변경 시 바로 조회
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '채팅방 검색',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('채팅',
                          style:
                          TextStyle(color: Colors.white, fontSize: 23)),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSearching = true;
                            FocusScope.of(context).requestFocus(_focusNode);
                          });
                        },
                        child: Image.asset(
                          'assets/icons/icon_search.png',
                          color: Colors.white,
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 140,
                left: 0,
                right: 0,
                bottom: 70,
                child: _rooms.isEmpty
                    ? Center(child: Text('채팅방이 없습니다.'))
                    : FutureBuilder<List<Widget>>(
                  future: _buildChatList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('채팅방을 불러오는 중 오류가 발생했습니다.'));
                    }

                    final chatWidgets = snapshot.data ?? [];
                    return SingleChildScrollView(
                      child: Column(children: chatWidgets),
                    );
                  },
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
                                  builder: (context) => MySchool()));
                        },
                      ),
                      IconButton(
                        icon: Image.asset('assets/btns/chatAct.png', width: 40),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Image.asset('assets/btns/calDis.png', width: 40),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Calendar()));
                        },
                      ),
                      IconButton(
                        icon: Image.asset('assets/btns/optDis.png', width: 40),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Option()));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Widget>> _buildChatList() async {
    List<Widget> widgets = [];

    for (final room in _rooms) {
      final parts = room.roomid.split('_');
      if (parts.length != 2) continue;

      final studentId = parts[0];
      // 학생 이름 API에서 가져오기
      final studentName = await _fetchStudentName(studentId);
      final lastMessage = room.lastmessageid ?? '';

      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Chat()));
          },
          child: Container(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(studentName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 4),
                      Text(lastMessage, style: TextStyle(color: Colors.grey[900])),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFF3C72BD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('1',
                          style:
                          TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    SizedBox(height: 10),
                    Text('1시간 전',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ));
    }

    return widgets;
  }
}
