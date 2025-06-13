import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qna_frontend/screens/profile_stu.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Firebase.initializeApp();

  // mock 데이터 정의
  final mockData = {
    'userDto': {
      'name': '홍길동',
      'email': 'hong@school.kr',
    }
  };

  runApp(QAApp(data: mockData));
}

class QAApp extends StatelessWidget {
  final dynamic data;
  QAApp({required this.data});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QA App',
      theme: ThemeData(
        fontFamily: 'Pretendard',
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
      ),
      home: Profile_stu(data: data),
      debugShowCheckedModeBanner: false,
    );
  }
}
