import 'package:flutter/foundation.dart';

// ───── ENUMS ─────────────────────────────────────────────

enum UserType { student, teacher }
enum RoomStatus { student, teacher }
enum FileType { message, schedule }

// ───── 공통 응답 ─────────────────────────────────────────

class Response<T> {
  final bool success;
  final String message;
  final T data;

  Response({required this.success, required this.message, required this.data});

  factory Response.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic) fromJsonT,
      ) {
    return Response<T>(
      success: json['success'],
      message: json['message'],
      data: fromJsonT(json['data']),
    );
  }
}

// ───── UserDto ───────────────────────────────────────────

class UserDto {
  final String userid;
  final String email;
  final String name;
  final String imgurl;
  final UserType usertype;

  UserDto({
    required this.userid,
    required this.email,
    required this.name,
    required this.imgurl,
    required this.usertype,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      userid: json['userid'],
      email: json['email'],
      name: json['name'],
      imgurl: json['imgurl'],
      usertype: UserType.values.firstWhere((e) => describeEnum(e).toUpperCase() == json['usertype']),
    );
  }
}

// ───── TeacherDto ────────────────────────────────────────

class TeacherDto {
  final String teacherid;
  final String subject;
  final String office;

  TeacherDto({
    required this.teacherid,
    required this.subject,
    required this.office,
  });

  factory TeacherDto.fromJson(Map<String, dynamic> json) {
    return TeacherDto(
      teacherid: json['teacherid'],
      subject: json['subject'],
      office: json['office'],
    );
  }
}

// ───── FaqDto ─────────────────────────────────────────────

class FaqDto {
  final String faqid;
  final String teacherid;
  final String question;
  final String answer;

  FaqDto({
    required this.faqid,
    required this.teacherid,
    required this.question,
    required this.answer,
  });

  factory FaqDto.fromJson(Map<String, dynamic> json) {
    return FaqDto(
      faqid: json['faqid'],
      teacherid: json['teacherid'],
      question: json['question'],
      answer: json['answer'],
    );
  }
}

// ───── RoomDto ────────────────────────────────────────────

class RoomDto {
  final String roomid;
  final String? lastmessageid;
  final RoomStatus? status;

  RoomDto({
    required this.roomid,
    this.lastmessageid,
    this.status,
  });

  factory RoomDto.fromJson(Map<String, dynamic> json) {
    final room = json['room'];
    return RoomDto(
      roomid: room['roomid'] ?? '',
      lastmessageid: room['lastmessageid'],
      status: json['status'] == null
          ? null
          : RoomStatus.values.firstWhere((e) => describeEnum(e).toUpperCase() == json['status']),
    );
  }
}

// ───── MessageDto ─────────────────────────────────────────

class MessageDto {
  final String messageid;
  final String roomid;
  final String senderid;
  final String text;
  final bool hasfile;
  final bool read;
  final DateTime createdat;

  MessageDto({
    required this.messageid,
    required this.roomid,
    required this.senderid,
    required this.text,
    required this.hasfile,
    required this.read,
    required this.createdat,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    return MessageDto(
      messageid: json['messageid'],
      roomid: json['roomid'],
      senderid: json['senderid'],
      text: json['text'],
      hasfile: json['hasfile'],
      read: json['read'],
      createdat: DateTime.parse(json['createdat']),
    );
  }
}

// ───── EmojiDto ───────────────────────────────────────────

class EmojiDto {
  final String messageid;
  final String userid;
  final String emoji;
  final DateTime createdat;

  EmojiDto({
    required this.messageid,
    required this.userid,
    required this.emoji,
    required this.createdat,
  });

  factory EmojiDto.fromJson(Map<String, dynamic> json) {
    return EmojiDto(
      messageid: json['messageid'],
      userid: json['userid'],
      emoji: json['emoji'],
      createdat: DateTime.parse(json['createdat']),
    );
  }
}

// ───── FileDto ────────────────────────────────────────────

class FileDto {
  final String fileid;
  final FileType filetype;
  final String targetid;
  final String url;
  final String name;

  FileDto({
    required this.fileid,
    required this.filetype,
    required this.targetid,
    required this.url,
    required this.name,
  });

  factory FileDto.fromJson(Map<String, dynamic> json) {
    return FileDto(
      fileid: json['fileid'],
      filetype: FileType.values.firstWhere((e) => describeEnum(e).toUpperCase() == json['filetype']),
      targetid: json['targetid'],
      url: json['url'],
      name: json['name'],
    );
  }
}

// ───── ScheduleDto ────────────────────────────────────────

class ScheduleDto {
  final String scheduleid;
  final String userid;
  final String title;
  final String content;
  final String date;
  final String time;
  final DateTime? alarm;

  ScheduleDto({
    required this.scheduleid,
    required this.userid,
    required this.title,
    required this.content,
    required this.date,
    required this.time,
    this.alarm,
  });

  factory ScheduleDto.fromJson(Map<String, dynamic> json) {
    return ScheduleDto(
      scheduleid: json['scheduleid'],
      userid: json['userid'],
      title: json['title'],
      content: json['content'],
      date: json['date'],
      time: json['time'],
      alarm: json['alarm'] != null ? DateTime.parse(json['alarm']) : null,
    );
  }
}

// ───── SharedDto ──────────────────────────────────────────

class SharedDto {
  final String scheduleid;
  final String studentid;

  SharedDto({
    required this.scheduleid,
    required this.studentid,
  });

  factory SharedDto.fromJson(Map<String, dynamic> json) {
    return SharedDto(
      scheduleid: json['scheduleid'],
      studentid: json['studentid'],
    );
  }
}

// ───── AlarmSettingDto ────────────────────────────────────

class AlarmSettingDto {
  final String userid;
  final bool alarm;
  final bool chat;
  final bool schedule;

  AlarmSettingDto({
    required this.userid,
    required this.alarm,
    required this.chat,
    required this.schedule,
  });

  factory AlarmSettingDto.fromJson(Map<String, dynamic> json) {
    return AlarmSettingDto(
      userid: json['userid'],
      alarm: json['alarm'],
      chat: json['chat'],
      schedule: json['schedule'],
    );
  }
}
