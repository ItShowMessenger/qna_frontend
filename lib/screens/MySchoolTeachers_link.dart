import 'package:flutter/material.dart';

class MySchoolTeachersLink extends StatefulWidget {
  @override
  _MySchoolTeachersLinkState createState() => _MySchoolTeachersLinkState();
}

class _MySchoolTeachersLinkState extends State<MySchoolTeachersLink> {
  String selectedGrade = '학년';
  String selectedClass = '반';
  final List<String> grades = ['1학년', '2학년', '3학년'];
  final List<String> classes = ['1반', '2반', '3반'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 상단 앱바
          Container(
            padding: EdgeInsets.only(top: 42, left: 16, right: 16, bottom: 12),
            color: Color(0xFF566B92),
            child: Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.white),
                SizedBox(width: 16),
                Text(
                  '우리 학교 선생님',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),

          // 필터 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: selectedGrade,
                  items:
                      ['학년', ...grades].map((grade) {
                        return DropdownMenuItem<String>(
                          value: grade,
                          child: Text(grade),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGrade = value!;
                    });
                  },
                ),
                SizedBox(width: 8),

                // 반 드롭다운
                DropdownButton<String>(
                  value: selectedClass,
                  items:
                      ['반', ...classes].map((cls) {
                        return DropdownMenuItem<String>(
                          value: cls,
                          child: Text(cls),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedClass = value!;
                    });
                  },
                ),
                SizedBox(width: 8),

                // 검색창
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '성함으로 찾기',
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          // 비어있는 상태 메시지 (중앙 정렬)
          Expanded(
            child: Align(
              alignment: Alignment(0, -0.2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '아직 Q&A에 가입하신 선생님이 없어요!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '아래 버튼으로 초대해보세요!',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: 270,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // 링크 공유 기능
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF566B92),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '링크 공유하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 15),
                          Image.asset(
                            'assets/images/share.png',
                            width: 20,
                            height: 20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 탭바
          Container(
            color: Color(0xFF566B92),
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Image.asset(
                    'assets/btns/mypgDis.png',
                    width: 40,
                    height: 40,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Image.asset(
                    'assets/btns/chatDis.png',
                    width: 40,
                    height: 40,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Image.asset(
                    'assets/btns/calDis.png',
                    width: 40,
                    height: 40,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Image.asset(
                    'assets/btns/optDis.png',
                    width: 40,
                    height: 40,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
