import 'package:flutter/material.dart';

class MySchoolTeachersList extends StatefulWidget {
  @override
  _MySchoolTeachersListState createState() => _MySchoolTeachersListState();
}

class _MySchoolTeachersListState extends State<MySchoolTeachersList> {
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
                  items: ['학년', ...grades].map((grade) {
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
                DropdownButton<String>(
                  value: selectedClass,
                  items: ['반', ...classes].map((cls) {
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

          // 여기에 선생님 리스트나 기타 내용 추가 가능
          Expanded(child: SizedBox()),

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
