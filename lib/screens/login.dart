import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

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
              ),
              // SizedBox(height: 40),
              // TextField(
              //   controller: idController,
              //   decoration: InputDecoration(
              //     labelText: '아이디',
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              // SizedBox(height: 16),
              // TextField(
              //   controller: pwController,
              //   obscureText: true,
              //   decoration: InputDecoration(
              //     labelText: '비밀번호',
              //     border: OutlineInputBorder(),
              //   ),
              // ),
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
                onPressed: () {
                  // TODO: 구글 로그인 기능 구현
                },
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
