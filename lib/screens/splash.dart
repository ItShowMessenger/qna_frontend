import 'package:flutter/material.dart';
import 'login.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Login()),
      );
    });

    return Scaffold(
      //backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/Q&A.png',
          width: 160,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
