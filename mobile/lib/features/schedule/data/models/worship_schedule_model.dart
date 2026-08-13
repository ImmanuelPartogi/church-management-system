import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/worship_schedule.dart';

part 'worship_schedule_model.freezed.dart';
part 'worship_schedule_model.g.dart';

@freezed
class WorshipScheduleModel with _$WorshipScheduleModel {
  const factory WorshipScheduleModel({
    required int id,
    required String title,
    String? description,
    required String day,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') String? endTime,
    String? location,
    required bool active,
  }) = _WorshipScheduleModel;

  const WorshipScheduleModel._();

  factory WorshipScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$WorshipScheduleModelFromJson(json);

  WorshipSchedule toEntity() {
    return WorshipSchedule(
      id: id,
      title: title,
      description: description,
      day: day,
      startTime: startTime,
      endTime: endTime,
      location: location,
      active: active,
    );
  }
}
