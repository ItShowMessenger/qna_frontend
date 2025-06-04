import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

      final email = user.email!;
      final name = user.displayName ?? '';
      final uid = user.uid;

      // 도메인 검사
      if (!email.endsWith('@e-mirim.hs.kr')) {
        await _googleSignIn.signOut();
        await _auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('학교 이메일(@e-mirim.hs.kr)로만 로그인 가능합니다.')),
        );
        return;
      }

      // 서버로 POST 요청 보내기
      final response = await http.post(
        Uri.parse('http://<YOUR_BACKEND_IP>:8080/api/login'), // 실제 서버 주소로 교체
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': uid,
          'name': name,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        print('서버 로그인 성공');
        // TODO: 로그인 성공 후 다음 페이지로 이동
      } else {
        print('서버 오류: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류: ${response.statusCode}')),
        );
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
