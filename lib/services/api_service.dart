class AlarmSettings {
  static bool? notificationsEnabled;
  static bool? calendarNotification;
  static bool? chatNotification;
  static bool isInitialized = false;

  static void setAll(bool noti, bool calendar, bool chat) {
    notificationsEnabled = noti;
    calendarNotification = calendar;
    chatNotification = chat;
    isInitialized = true;
  }
}

class ApiService {
  static Future<Map<String, bool>> getAlarmSettings() async {
    // TODO: 서버에서 가져오는 코드로 교체
    await Future.delayed(Duration(milliseconds: 500)); // 임시 딜레이
    return {
      'notificationsEnabled': true,
      'calendarNotification': true,
      'chatNotification': false,
    };
  }
}
