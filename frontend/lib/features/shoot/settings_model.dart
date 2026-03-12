class SettingsModel {
  const SettingsModel({
    required this.timePomodoro,
    required this.timeShortBreak,
    required this.timeLongBreak,
    required this.isAutoStartSession,
    required this.longBreakInterval,
  });

  final int timePomodoro;
  final int timeShortBreak;
  final int timeLongBreak;
  final bool isAutoStartSession;
  final int longBreakInterval;

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        timePomodoro: json['time_pomodoro'] as int,
        timeShortBreak: json['time_short_break'] as int,
        timeLongBreak: json['time_long_break'] as int,
        isAutoStartSession: json['is_auto_start_session'] as bool,
        longBreakInterval: json['long_break_interval'] as int,
      );

  Map<String, dynamic> toJson() => {
        'time_pomodoro': timePomodoro,
        'time_short_break': timeShortBreak,
        'time_long_break': timeLongBreak,
        'is_auto_start_session': isAutoStartSession,
        'long_break_interval': longBreakInterval,
      };

  SettingsModel copyWith({
    int? timePomodoro,
    int? timeShortBreak,
    int? timeLongBreak,
    bool? isAutoStartSession,
    int? longBreakInterval,
  }) =>
      SettingsModel(
        timePomodoro: timePomodoro ?? this.timePomodoro,
        timeShortBreak: timeShortBreak ?? this.timeShortBreak,
        timeLongBreak: timeLongBreak ?? this.timeLongBreak,
        isAutoStartSession: isAutoStartSession ?? this.isAutoStartSession,
        longBreakInterval: longBreakInterval ?? this.longBreakInterval,
      );
}
