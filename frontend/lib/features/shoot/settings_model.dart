class SettingsModel {
  final String userId;
  final int timePomodoro;
  final int timeShortBreak;
  final int timeLongBreak;
  final bool isAutoStartSession;
  final int longBreakInterval;

  const SettingsModel({
    required this.userId,
    required this.timePomodoro,
    required this.timeShortBreak,
    required this.timeLongBreak,
    required this.isAutoStartSession,
    required this.longBreakInterval,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      userId: json['user_id'] as String,
      timePomodoro: json['time_pomodoro'] as int,
      timeShortBreak: json['time_short_break'] as int,
      timeLongBreak: json['time_long_break'] as int,
      isAutoStartSession: json['is_auto_start_session'] as bool,
      longBreakInterval: json['long_break_interval'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time_pomodoro': timePomodoro,
      'time_short_break': timeShortBreak,
      'time_long_break': timeLongBreak,
      'is_auto_start_session': isAutoStartSession,
      'long_break_interval': longBreakInterval,
    };
  }
}
