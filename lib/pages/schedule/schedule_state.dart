import 'package:freezed_annotation/freezed_annotation.dart';
part 'schedule_state.freezed.dart';

@freezed
class ScheduleState with _$ScheduleState {
  const factory ScheduleState({
    @Default({}) Map<DateTime, List<String>> events,
    DateTime? selectedDay,
  }) = _ScheduleState;
}
