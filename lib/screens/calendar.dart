import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'home.dart';
import 'option_stu.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<String>> events = {
    DateTime.utc(2025, 6, 10): ['서울 식물원 현장 학습'],
    DateTime.utc(2025, 6, 20): ['서울 과학관 체험'],
  };

  List<String> _getEventsForDay(DateTime day) {
    return events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _showEventPopup(List<String> events) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('일정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: events
              .map((event) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(event),
          ))
              .toList(),
        ),
        actions: [
          TextButton(
            child: Text('닫기', style: TextStyle(color: Color(0xFF566B92))),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 상단 네비게이션 이미지
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/topNav.png',
              fit: BoxFit.cover,
            ),
          ),

          // 타이틀 바
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              color: Color(0xFF3C72BD),
              padding: EdgeInsets.fromLTRB(25, 8, 25, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '캘린더',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                  ),
                ),
              ),
            ),
          ),

          // 캘린더
          Positioned(
            top: 106,
            left: 0,
            right: 0,
            bottom: 70,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });

                  final selectedEvents = _getEventsForDay(selectedDay);
                  if (selectedEvents.isNotEmpty) {
                    _showEventPopup(selectedEvents);
                  }
                },
                eventLoader: (_) => [], // 점 제거
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date, _) {
                    bool isEventDay = _getEventsForDay(date).isNotEmpty;
                    if (isEventDay) {
                      return Center(
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Color(0xFF566B92), // 일정 있는 날: 고정 색상
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${date.day}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                  selectedBuilder: (context, date, _) {
                    return Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(0xFF566B92), // 선택한 날도 동일한 색
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${date.day}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // 하단 탭 바
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Color(0xFF3C72BD),
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Image.asset('assets/btns/mypgDis.png', width: 40),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Image.asset('assets/btns/chatDis.png', width: 40),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/btns/calAct.png', width: 40),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Image.asset('assets/btns/optDis.png', width: 40),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Option_stu()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}





