import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qna_frontend/screens/chat.dart';
import 'package:qna_frontend/screens/home.dart';
import 'package:qna_frontend/screens/login.dart';
import 'package:qna_frontend/screens/option.dart';
import 'package:qna_frontend/screens/splash.dart';
import 'package:qna_frontend/classes/UserProvider.dart';
import 'package:qna_frontend/classes/mySchoolProvider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Firebase.initializeApp();
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MySchoolProvider()),
        ],
        child: QAApp(),
      ),
  );
}

class QAApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'QA App',
        theme: ThemeData(
          fontFamily: 'Pretendard',
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Color(0xFFF5F5F5),
        ),
        home: Splash(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}