import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home.dart';

class Login extends StatelessWidget {
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _handleGoogleLogin(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
          credential);
      final User? user = userCredential.user;

      if (user == null || user.email == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('로그인 실패')));
        return;
      }

      final email = user.email!;
      final name = user.displayName ?? '';
      final uid = user.uid;

      if (!email.endsWith('@e-mirim.hs.kr')) {
        await _googleSignIn.signOut();
        await _auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('학교 이메일(@e-mirim.hs.kr)로만 로그인 가능합니다.')),
        );
        return;
      }

      //요청 /api/login
      final response = await http.post(
        Uri.parse('http://172.30.1.94:8088/api/login'), // 실제 서버 주소로 교체
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${googleAuth.idToken}',
        },
        body: jsonEncode({
          'token': googleAuth.idToken,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final user = jsonResponse['data'];
          final userid = user['userid'];
          final name = user['name'];
          final email = user['email'];
          final userType = user['usertype'];

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('알림 수신 동의'),
                content: Text('Q&A 앱 내 채팅 관련 알림을 수신하시겠습니까?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 팝업 닫기
                      // ✅ 동의한 경우 처리 (예: 알림 설정 저장)
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    },
                    child: Text('동의'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // ✅ 비동의한 경우에도 페이지 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    },
                    child: Text('비동의'),
                  ),
                ],
              );
            },
          );
          Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home()),);
        } else {
          print('서버 오류: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('서버 오류: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      print('로그인 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('로그인 중 오류 발생')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/Q&A.png',
                width: 145,
                fit: BoxFit.contain,
              ), SizedBox(height: 40),

              Text(
                '학교 이메일로 로그인해주세요.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black45,
                ),
              ),

              SizedBox(height: 25),
              OutlinedButton.icon(
                onPressed: () => _handleGoogleLogin(context),
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  width: 20,
                  height: 20,
                ),
                label: Text('구글 로그인'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Color(0xFFFFFFFF),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 35),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
