import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../classes/UserProvider.dart';
import '../models/dto.dart'; // UserProvider import
import 'home.dart';

class Login extends StatelessWidget {
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
      final idTokenResult = await user?.getIdTokenResult(true);

      final response = await http.post(
        Uri.parse('https://qna-messenger.mirim-it-show.site/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${idTokenResult?.token}',
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        final success = jsonResponse['success'] ?? false;
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('로그인 실패')));
          return;
        }
        final userJson = jsonResponse['data'];
        final userDto = UserDto.fromJson(userJson);

        // 로그인 성공 시 Provider에 저장
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userDto);

        if (jsonResponse['message']=="회원가입 성공") {
          await showDialog(
            context: context,
            builder: (context) {
              final TextEditingController officeController = TextEditingController();
              final TextEditingController subjectController = TextEditingController();
              final TextEditingController questionController = TextEditingController();
              final TextEditingController answerController = TextEditingController();
              List<Map<String, String>> faqs = [];

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text('선생님 정보 입력'),
                    content: SingleChildScrollView(
                      child: Column(
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
                          SizedBox(height: 20),
                          TextField(
                            controller: questionController,
                            decoration: InputDecoration(labelText: '자주 묻는 질문'),
                          ),
                          TextField(
                            controller: answerController,
                            decoration: InputDecoration(
                              labelText: '답변',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  final q = questionController.text.trim();
                                  final a = answerController.text.trim();
                                  if (q.isNotEmpty && a.isNotEmpty) {
                                    setState(() {
                                      faqs.add({'question': q, 'answer': a} as Map<String, String>);
                                      questionController.clear();
                                      answerController.clear();
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 100,
                            width: MediaQuery.of(context).size.width,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: faqs.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Chip(
                                    label: Text(faqs[index]['question'] ?? ''),
                                    deleteIcon: Icon(Icons.close),
                                    onDeleted: () {
                                      setState(() {
                                        faqs.removeAt(index);
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          final office = officeController.text.trim();
                          final subject = subjectController.text.trim();

                          if (office.isEmpty || subject.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('모든 정보를 입력해주세요.')),
                            );
                            return;
                          }


                          final profileResponse = await http.post(
                            Uri.parse('https://qna-messenger.mirim-it-show.site/api/teacher/profile'),
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer ${idTokenResult?.token}',
                            },
                            body: jsonEncode({
                              'teacher': {
                                'teacherid': userDto.userid, // ❗ 꼭 있어야 함
                                'subject': subject,
                                'office': office,
                              },
                              'faq': faqs,
                            }),
                          );
                          if (profileResponse.statusCode == 200) {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Home()),
                            );
                          } else {
                            print('로그인 실패: ${profileResponse.body}');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('프로필 저장 실패 ${profileResponse.statusCode}')),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Home()),
                            );
                          }
                        },
                        child: Text('확인'),
                      ),
                    ],
                  );
                },
              );
            },
          );

        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        }
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('학교 이메일이 아닙니다. 다른 계정으로 로그인해주세요.')),
        );
        await _googleSignIn.signOut();
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
      print('로그인 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('로그인 중 오류 발생')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              ),
              SizedBox(height: 40),
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