import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // ✅ 실제 백엔드 URL로 교체 (예: 로컬 테스트용 or 배포 서버 주소)
  static const String baseUrl = "https://qna-backend.com"; // 예: http://192.168.0.10:8080
  static final _storage = FlutterSecureStorage(); // ✅ 올바른 선언

  /// 토큰 가져오기
  static Future<String?> getToken() async {
    return await _storage.read(key: "token");
  }

  /// ✅ (선생님 or 학생) 목록 조회
  /// [query]가 비어 있으면 전체 조회, 있으면 검색
  static Future<List<dynamic>> fetchUserList({String query = ""}) async {
    final token = await getToken();
    final uri = Uri.parse(
      query.isEmpty
          ? '$baseUrl/api/teacher/search'
          : '$baseUrl/api/teacher/search?search=$query',
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data']; // 유저 목록
    } else {
      throw Exception("사용자 목록 조회 실패: ${response.body}");
    }
  }

  /// ✅ (선생님 or 학생) 프로필 조회
  static Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/api/teacher/profile/$userId');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data']; // user + teacher + faq 정보
    } else {
      throw Exception("프로필 조회 실패: ${response.body}");
    }
  }

  /// ✅ 선생님 프로필 저장 (teacherDto + faqDto)
  static Future<void> saveTeacherProfile({
    required Map<String, dynamic> teacher,
    required List<Map<String, dynamic>> faqs,
  }) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/api/teacher/profile');

    final body = jsonEncode({
      "teacher": teacher,
      "faqs": faqs,
    });

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception("선생님 프로필 저장 실패: ${response.body}");
    }
  }

  /// ✅ 선생님 FAQ만 수정
  static Future<void> saveTeacherFaqs(List<Map<String, dynamic>> faqs) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/api/teacher/teacherId'); // FAQ만 수정할 때 사용

    final body = jsonEncode({
      "faqs": faqs,
    });

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception("FAQ 저장 실패: ${response.body}");
    }
  }

  /// ✅ 채팅방 목록 조회
  static Future<List<dynamic>> fetchChatRooms({String query = ""}) async {
    final token = await getToken();
    final uri = Uri.parse(
      query.isEmpty
          ? '$baseUrl/api/chat/search'
          : '$baseUrl/api/chat/search?query=$query',
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data']; // RoomDto 리스트
    } else {
      throw Exception("채팅방 목록 조회 실패: ${response.body}");
    }
  }

  /// ✅ 채팅 메시지 조회
  static Future<Map<String, dynamic>> fetchChatMessages(String roomId) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/api/chat/$roomId');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data']; // messages, files, emojis
    } else {
      throw Exception("채팅 메시지 조회 실패: ${response.body}");
    }
  }
}
