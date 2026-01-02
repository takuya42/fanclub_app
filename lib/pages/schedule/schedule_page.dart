import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'schedule_controller.dart';

class SchedulePage extends HookConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(scheduleControllerProvider.notifier);
    final state = ref.watch(scheduleControllerProvider);
    final selectedDay = state.selectedDay;
    final events = state.events;
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'スケジュール',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                  child: TableCalendar(
                    locale: 'ja_JP',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: selectedDay ?? DateTime.now(),
                    selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                    eventLoader: (day) {
                      return events.entries
                          .where((e) =>
                      e.key.year == day.year &&
                          e.key.month == day.month &&
                          e.key.day == day.day)
                          .expand((e) => e.value)
                          .toList();
                    },
                    onDaySelected: (selected, focused) {
                      controller.selectDay(selected);
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
                      titleTextStyle:
                      TextStyle(color: Colors.black87, fontSize: 18),
                      leftChevronIcon:
                      Icon(Icons.chevron_left, color: Colors.black87),
                      rightChevronIcon:
                      Icon(Icons.chevron_right, color: Colors.black87),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.black54),
                      weekendStyle: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 選択した日付
                if (selectedDay != null)
                  Text(
                    '${selectedDay.year}年${selectedDay.month}月${selectedDay.day}日',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 12),

                // 🔹 入力欄＋追加ボタン
                if (selectedDay != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: '予定を入力...',
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
                          onPressed: () {
                            final text = textController.text.trim();
                            if (text.isEmpty) return;
                            controller.addEvent(selectedDay, text);
                            textController.clear();
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 🔹 予定リスト
                  Expanded(
                    child: ListView(
                      children: (events[selectedDay] ?? [])
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
                              onPressed: () {
                                controller.removeEvent(selectedDay, event);
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
