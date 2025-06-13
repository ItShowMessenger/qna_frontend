import 'package:flutter/material.dart';
import 'package:qna_frontend/services/api_service.dart';
import 'profile_t.dart';

class MyStudent extends StatefulWidget {
  @override
  _MyStudent createState() => _MyStudent();
}

class _MyStudent extends State<MyStudent> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _students = [];

  void _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    try {
      final results = await ApiService.fetchUserList(query: query);
      setState(() => _students = results);
    } catch (e) {
      print('검색 오류: $e');
    }
  }

  void _openProfile(String userId) async {
    try {
      final profile = await ApiService.fetchUserProfile(userId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Profile_t(data: profile),
        ),
      );
    } catch (e) {
      print('프로필 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... UI 그대로 유지 ...
      body: Stack(
        children: [
          // 상단 이미지, 타이틀, 검색창 생략...
          Positioned(
            top: 190,
            left: 16,
            right: 16,
            child: Column(
              children: _students.map((student) {
                return GestureDetector(
                  onTap: () => _openProfile(student['userDto']['userId']),
                  child: Container(
                    // ... 꾸밈 코드 유지 ...
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                          AssetImage('assets/images/def_photo.png'),
                          radius: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student['userDto']?['name'] ?? '이름 없음',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              Text(
                                student['userDto']?['studentNumber'] ?? '',
                                style: TextStyle(color: Colors.grey[800]),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
