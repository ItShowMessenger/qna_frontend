import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qna_frontend/screens/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}
