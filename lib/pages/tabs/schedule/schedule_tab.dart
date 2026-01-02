import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fanclub_app/pages/schedule/schedule_controller.dart';

class ScheduleTab extends HookConsumerWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(scheduleControllerProvider.notifier);
    final state = ref.watch(scheduleControllerProvider);
    final selectedDay = state.selectedDay;
    final events = state.events;

    final textController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 🔹 カレンダー
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TableCalendar(
              locale: 'ja_JP',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: selectedDay ?? DateTime.now(),
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              eventLoader: (day) => events.entries
                  .where((e) =>
              e.key.year == day.year &&
                  e.key.month == day.month &&
                  e.key.day == day.day)
                  .expand((e) => e.value)
                  .toList(),
              onDaySelected: (selected, focused) {
                controller.selectDay(selected);
              },
              calendarStyle: const CalendarStyle(
                todayDecoration:
                BoxDecoration(color: Colors.pink, shape: BoxShape.circle),
                selectedDecoration:
                BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                markerDecoration:
                BoxDecoration(color: Colors.black, shape: BoxShape.circle),

                defaultTextStyle: TextStyle(color: Colors.black87), // 通常の日付
                weekendTextStyle: TextStyle(color: Colors.redAccent), // 土日
                outsideTextStyle: TextStyle(color: Colors.grey), // 月外の日付
              ),
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                leftChevronIcon:
                Icon(Icons.chevron_left, color: Colors.black87),
                rightChevronIcon:
                Icon(Icons.chevron_right, color: Colors.black87),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 🔹 日付が選ばれているときのみ入力欄を表示
          if (selectedDay != null) ...[
            Text(
              '${selectedDay.month}月${selectedDay.day}日の予定を追加',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
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
          ] else
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                '日付を選択してください',
                style: TextStyle(color: Colors.black54),
              ),
            ),

          const SizedBox(height: 16),

          // 🔹 イベントリスト
          if (selectedDay != null)
            Column(
              children: (events[selectedDay] ?? [])
                  .map(
                    (event) => Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.event_note,
                        color: Colors.black54),
                    title: Text(event),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.black45),
                      onPressed: () {
                        controller.removeEvent(selectedDay, event);
                      },
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
        ],
      ),
    );
  }
}
