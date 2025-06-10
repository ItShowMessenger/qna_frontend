import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qna_frontend/screens/option_stu.dart';

import 'calendar.dart';
import 'chat.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isSearching = false;
  String _searchText = '';
  FocusNode _focusNode = FocusNode();

  List<Map<String, String>> _chats = [
    {'name': '선생님 이름', 'message': '최신 메시지 내용'},
    {'name': '김선생님', 'message': '오늘 과제 알려줘요'},
    {'name': '박선생님', 'message': '출석 확인했어요'},
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _isSearching = false;
          _searchText = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredChats = _chats.where((chat) =>
        chat['name']!.toLowerCase().contains(_searchText.toLowerCase())
    ).toList();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).unfocus();  // 키보드 닫기
              setState(() {
              _isSearching = false;
              _searchText = '';
                });
                  },
                  child: Stack(
                    children: [
    // 상단 네비게이션 바
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Image.asset('assets/images/topNav.png', fit: BoxFit.cover),),
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
                      _searchText = value;
                    });
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
                    Text('채팅', style: TextStyle(color: Colors.white, fontSize: 23)),
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
              top: 80,
              left: 0,
              right: 0,
              child: Container(
                height: 20,
                color: Color(0xFF3C72BD),
                padding: EdgeInsets.fromLTRB(25, 8, 25, 0),
              ),
            ),
            Positioned(
              top: 140,
              left: 0,
              right: 0,
              child: Column(
                children: filteredChats.map((chat) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Chat()),
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
                                  Text(chat['name']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  SizedBox(height: 4),
                                  Text(chat['message']!, style: TextStyle(color: Colors.grey[900])),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF3C72BD),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text('1', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                                SizedBox(height: 10),
                                Text('1시간 전', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
                      icon: Image.asset('assets/btns/mypgDis.png', width: 40, height: 40),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Image.asset('assets/btns/chatAct.png', width: 40, height: 40),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Image.asset('assets/btns/calDis.png', width: 40, height: 40),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Calendar()));
                      },
                    ),
                    IconButton(
                      icon: Image.asset('assets/btns/optDis.png', width: 40, height: 40),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Option_stu()));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),);
  }
}
