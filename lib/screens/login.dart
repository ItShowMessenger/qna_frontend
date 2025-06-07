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

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null || user.email == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('로그인 실패')));
        return;
      }

      // /api/login 요청
      final response = await http.post(
        Uri.parse('http://172.30.1.94:8088/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${googleAuth.idToken}',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final success = jsonResponse['success'] ?? false;

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('로그인 실패')));
          return;
        }

        final userType = jsonResponse['data']['userType'];
        final isNewUser = jsonResponse['data']['isNewUser'] ?? false;

        // 신규 교사 → 교무실 위치, 담당과목 입력 팝업
        if (userType == "TEACHER" && isNewUser) {
          await showDialog(
            context: context,
            builder: (context) {
              final TextEditingController officeController = TextEditingController();
              final TextEditingController subjectController = TextEditingController();

              return AlertDialog(
                title: Text('선생님 정보 입력'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: officeController,
                      decoration: InputDecoration(labelText: '교무실 위치'),
                    ),
                    TextField(
                      controller: subjectController,
                      decoration: InputDecoration(labelText: '담당 과목'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      // TODO: 서버에 추가 정보 전송 API가 있다면 여기에 요청
                      Navigator.of(context).pop();

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    },
                    child: Text('제출'),
                  ),
                ],
              );
            },
          );
        } else {
          // 학생 또는 기존 선생님
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        }
      } else if (response.statusCode == 403) {
        // 학교 이메일 아님
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('학교 이메일이 아닙니다. 다른 계정으로 로그인해주세요.')),
        );

        await _googleSignIn.signOut(); // 현재 계정 로그아웃
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증 실패: 유효하지 않은 토큰')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('로그인 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('에엑따')));
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
