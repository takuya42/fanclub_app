import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _controller = TextEditingController();

  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;
  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (_user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('schedule')
        .get();

    final loaded = <DateTime, List<String>>{};
    for (final doc in snapshot.docs) {
      final date = DateTime.parse(doc.id);
      final events = List<String>.from(doc['events'] ?? []);
      loaded[date] = events;
    }

    setState(() => _events = loaded);
  }

  Future<void> _saveEvents() async {
    if (_user == null || _selectedDay == null) return;

    final day = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    final events = _events[day] ?? [];

    await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('schedule')
        .doc('${day.toIso8601String().split("T").first}')
        .set({'events': events});
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events.entries
        .where((e) =>
    e.key.year == day.year &&
        e.key.month == day.month &&
        e.key.day == day.day)
        .expand((e) => e.value)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 AppBarにタイトル＋戻るボタン
      appBar: AppBar(
        title: const Text(
          'スケジュール',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // 🔹 背景グラデーション（上：黒 → 下：白）
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔹 カレンダー
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TableCalendar(
                      locale: 'ja_JP',
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      eventLoader: _getEventsForDay,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarStyle: const CalendarStyle(
                        defaultTextStyle: TextStyle(color: Colors.black87),
                        weekendTextStyle: TextStyle(color: Colors.redAccent),
                        outsideTextStyle: TextStyle(color: Colors.black26),
                        todayDecoration: BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: TextStyle(color: Colors.white),
                        markerDecoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        markersAlignment: Alignment.bottomCenter,
                      ),
                      headerStyle: const HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        titleTextStyle: TextStyle(color: Colors.black87, fontSize: 18),
                        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black87),
                        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black87),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: Colors.black54),
                        weekendStyle: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 選択した日付
                if (_selectedDay != null)
                  Text(
                    '${_selectedDay!.year}年${_selectedDay!.month}月${_selectedDay!.day}日',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 12),

                // 🔹 入力欄＋追加ボタン
                if (_selectedDay != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: '予定を入力...',
                            hintStyle: const TextStyle(color: Colors.black38),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () async {
                            final text = _controller.text.trim();
                            if (text.isEmpty || _selectedDay == null) return;

                            final day = DateTime(
                              _selectedDay!.year,
                              _selectedDay!.month,
                              _selectedDay!.day,
                            );

                            setState(() {
                              _events.putIfAbsent(day, () => []).add(text);
                              _controller.clear();
                            });

                            await _saveEvents();
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 🔹 予定リスト
                  Expanded(
                    child: ListView(
                      children: _getEventsForDay(_selectedDay!)
                          .map(
                            (event) => Card(
                          color: Colors.white.withOpacity(0.9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.event_note,
                                color: Colors.black54),
                            title: Text(
                              event,
                              style: const TextStyle(color: Colors.black87),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.black45),
                              onPressed: () async {
                                final day = DateTime(
                                  _selectedDay!.year,
                                  _selectedDay!.month,
                                  _selectedDay!.day,
                                );

                                setState(() {
                                  _events[day]!.remove(event);
                                  if (_events[day]!.isEmpty) {
                                    _events.remove(day);
                                  }
                                });

                                await _saveEvents();
                              },
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ] else
                  const Expanded(
                    child: Center(
                      child: Text(
                        '日付を選択してください',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
