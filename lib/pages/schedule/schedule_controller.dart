import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'schedule_state.dart';

final scheduleControllerProvider =
StateNotifierProvider<ScheduleController, ScheduleState>(
      (ref) => ScheduleController(),
);

class ScheduleController extends StateNotifier<ScheduleState> {
  ScheduleController() : super(const ScheduleState()) {
    loadEvents();
  }

  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  /// 🔹 Firestoreから予定を読み込み
  Future<void> loadEvents() async {
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

    state = state.copyWith(events: loaded);
  }

  /// 🔹 予定を追加
  Future<void> addEvent(DateTime day, String text) async {
    final newMap = Map<DateTime, List<String>>.from(state.events);
    newMap.putIfAbsent(day, () => []).add(text);
    state = state.copyWith(events: newMap);

    await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('schedule')
        .doc('${day.toIso8601String().split("T").first}')
        .set({'events': newMap[day]});
  }

  /// 🔹 予定を削除
  Future<void> removeEvent(DateTime day, String text) async {
    final newMap = Map<DateTime, List<String>>.from(state.events);
    newMap[day]?.remove(text);
    if (newMap[day]?.isEmpty ?? false) {
      newMap.remove(day);
    }
    state = state.copyWith(events: newMap);

    await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('schedule')
        .doc('${day.toIso8601String().split("T").first}')
        .set({'events': newMap[day] ?? []});
  }

  /// 🔹 選択日変更
  void selectDay(DateTime? day) {
    state = state.copyWith(selectedDay: day);
  }
}
