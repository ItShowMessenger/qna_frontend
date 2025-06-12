import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qna_frontend/screens/MySchoolTeachers.dart';
import 'package:qna_frontend/screens/calendar.dart';
import 'package:qna_frontend/screens/chat.dart';
import 'package:qna_frontend/screens/home.dart';
import 'package:qna_frontend/screens/login.dart';
import 'package:qna_frontend/screens/option_t.dart';
import 'package:qna_frontend/screens/option_stu.dart';
import 'package:qna_frontend/screens/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Firebase.initializeApp();
  runApp(QAApp());
}

class QAApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QA App',
      theme: ThemeData(
        fontFamily: 'Pretendard',
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
      ),
      home: Option_stu(),
      debugShowCheckedModeBanner: false,
    );
  }
}
