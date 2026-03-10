CREATE TABLE user_settings (
  user_id               UUID PRIMARY KEY REFERENCES users(id),
  time_pomodoro         INTEGER NOT NULL DEFAULT 25,
  time_short_break      INTEGER NOT NULL DEFAULT 5,
  time_long_break       INTEGER NOT NULL DEFAULT 15,
  is_auto_start_session BOOLEAN NOT NULL DEFAULT false,
  long_break_interval   INTEGER NOT NULL DEFAULT 4
);
