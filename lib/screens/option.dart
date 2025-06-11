import 'package:flutter/material.dart';
import 'package:qna_frontend/models/dto.dart'; // dto.dart 경로에 맞게 수정

class OptionScreen extends StatelessWidget {
  final UserDto user;

  const OptionScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          // 공통 옵션
          const CommonOption(),

          const Divider(),

          // 학생/선생님에 따라 다른 UI 표시
          if (user.usertype == UserType.student) ...[
            const StudentOption(),
          ] else if (user.usertype == UserType.teacher) ...[
            const TeacherOption(),
          ],
        ],
      ),
    );
  }
}

// ───── 공통 옵션 위젯 ──────────────────────────────
class CommonOption extends StatelessWidget {
  const CommonOption({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ListTile(
          leading: Icon(Icons.notifications),
          title: Text('알림 설정'),
          subtitle: Text('채팅 및 일정 알림을 관리합니다'),
        ),
        ListTile(
          leading: Icon(Icons.privacy_tip),
          title: Text('개인정보 처리방침'),
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('로그아웃'),
        ),
      ],
    );
  }
}

// ───── 학생 전용 옵션 ─────────────────────────────
class StudentOption extends StatelessWidget {
  const StudentOption({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ListTile(
          leading: Icon(Icons.book),
          title: Text('수강 중인 과목'),
        ),
        ListTile(
          leading: Icon(Icons.schedule),
          title: Text('내 일정'),
        ),
      ],
    );
  }
}

// ───── 선생님 전용 옵션 ───────────────────────────
class TeacherOption extends StatelessWidget {
  const TeacherOption({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ListTile(
          leading: Icon(Icons.question_answer),
          title: Text('자주 묻는 질문 관리'),
        ),
        ListTile(
          leading: Icon(Icons.school),
          title: Text('과목 및 교무실 정보'),
        ),
        ListTile(
          leading: Icon(Icons.share),
          title: Text('일정 공유 관리'),
        ),
      ],
    );
  }
}
