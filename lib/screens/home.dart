import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qna_frontend/screens/MySchool.dart';
import '../classes/UserProvider.dart';
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
  UserDto? _user;
  List<RoomDto> _rooms = [];
  String _search = '';
  bool _isSearching = false;
  final FocusNode _focusNode = FocusNode();
  String? _teacherId;
  int? unreadCount;
  Map<String, String> _teacherNames = {}; // 선생님 ID → 이름 캐시

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() => _isSearching = false);
      }
    });
    _loadTeacherId();

  }

  String getTheyId(String roomId, String myId) {
    final parts = roomId.split('_');
    if (parts.length != 2 || myId == null) return '';
    return parts[0] == myId ? parts[1] : parts[0];
  }

  Future<void> _loadTeacherId() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    _user = userProvider.user;
    setState(() {
      _teacherId = user?.uid;
    });
    await _loadRooms();
  }



  Future<void> _loadRooms() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final idToken = await currentUser?.getIdToken();
    try {
      final url = Uri.parse(
          'https://qna-messenger.mirim-it-show.site/api/chat/search?search=${Uri.encodeComponent(_search)}');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $idToken'},
      );


      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        final List<dynamic> data = decoded['data'];
        final List<RoomDto> rooms = data.map((item) => RoomDto.fromJson(item)).toList();
        print('받아온 데이터: ${decoded['data']}');

        final myId = Provider.of<UserProvider>(context, listen: false).user?.userid;
        print(myId);
        final roomDate = decoded['data'][0];
        final RoomId = decoded['data'][0]['room']?['roomid'];
        final theyId = getTheyId(RoomId, myId!);
        final _unreadCount = decoded['unread'] ?? 0;


        setState(() {
          _teacherId = theyId;
          unreadCount = _unreadCount;
        });

        setState(() => _rooms = rooms);

        // 각 방의 선생님 이름 비동기 로드
        for (final room in rooms) {
          final parts = room.roomid.split('_');
          if (parts.length != 2) continue;
          final otherUserId = parts[0] == _teacherId ? parts[1] : parts[0];

          if (!_teacherNames.containsKey(otherUserId)) {
            _fetchTeacherName(otherUserId);
          }
        }
      } else {
        print('API 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('예외 발생: $e');
    }
  }

  Future<void> _fetchTeacherName(String teacherId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final idToken = await currentUser?.getIdToken();

      final url = Uri.parse(
          'https://qna-messenger.mirim-it-show.site/api/teacher/profile/$_teacherId');
      final response = await http.get(url, headers: {'Authorization': 'Bearer $idToken'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final name = data['data']?['user']?['name'];
        print(data);
        setState(() {
          _teacherNames[teacherId] = name;
        });
      } else {
        print('이름 정보 로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('선생님 정보 요청 실패: $e');
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
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() => _isSearching = false);
          },
          child: Stack(
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
                  height: 60,
                  color: Color(0xFF3C72BD),
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: _isSearching
                      ? TextField(
                    focusNode: _focusNode,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '채팅방 검색',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  )
                      : Center(
                    child: Text(
                      '채팅',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 120,
                left: 16,
                right: 16,
                child: TextField(
                  onChanged: (text) {
                    setState(() {
                      _search = text; // 검색어 상태 업데이트
                    });
                    _loadRooms(); // 검색어 반영하여 방 목록 재로드
                  },
                  decoration: InputDecoration(
                    hintText: _user?.usertype == UserType.teacher ? '학생 찾기' : '선생님 찾기',
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
              Positioned(
                top: 190,
                left: 0,
                right: 0,
                bottom: 70,
                child: Builder(
                  builder: (context) {
                    // 👉 검색어 기준으로 선생님 이름 필터링
                    final filteredRooms = _rooms.where((room) {
                      final parts = room.roomid.split('_');
                      if (parts.length != 2) return false;

                      final otherUserId = parts[0] == _teacherId ? parts[1] : parts[0];
                      final name = _teacherNames[otherUserId]?.toLowerCase() ?? '';
                      return name.contains(_search.toLowerCase());
                    }).toList();

                    return filteredRooms.isEmpty
                        ? (_rooms.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : Center(
                      child: Text(
                        '채팅방이 없습니다.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ))
                        : ListView.builder(
                      itemCount: filteredRooms.length,
                      itemBuilder: (context, index) {
                        final room = filteredRooms[index];
                        final parts = room.roomid.split('_');
                        if (parts.length != 2) return SizedBox();

                        final otherUserId = parts[0] == _teacherId ? parts[1] : parts[0];
                        final teacherName = _teacherNames[otherUserId] ?? '선생님 이름';

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Chat(
                                ),
                                ),
                              );
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
                                        Text(
                                          _user?.usertype == UserType.teacher ?
                                          '${teacherName} 학생' : '${teacherName} 선생님',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          room.lastmessageid ?? '',
                                          style: TextStyle(color: Colors.grey[900]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      (unreadCount != null && unreadCount! > 0)
                                          ? Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF3C72BD),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          unreadCount.toString(),
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      )
                                          : SizedBox.shrink(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // 하단 내비게이션
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MySchool()));
                        },
                      ),
                      IconButton(
                        icon: Image.asset('assets/btns/chatAct.png', width: 40),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Image.asset('assets/btns/calDis.png', width: 40),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Calendar()));
                        },
                      ),
                      IconButton(
                        icon: Image.asset('assets/btns/optDis.png', width: 40),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Option()));
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
}