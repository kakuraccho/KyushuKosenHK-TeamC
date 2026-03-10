package model

import (
	"time"

	"github.com/google/uuid"
)

type User struct {
	ID        uuid.UUID `json:"id"`
	Name      string    `json:"name"`
	Email     string    `json:"email"`
	CreatedAt time.Time `json:"created_at"`
}

type UserSettings struct {
	UserID              uuid.UUID `json:"user_id"`
	TimePomodoro        int       `json:"time_pomodoro"`
	TimeShortBreak      int       `json:"time_short_break"`
	TimeLongBreak       int       `json:"time_long_break"`
	IsAutoStartSession  bool      `json:"is_auto_start_session"`
	LongBreakInterval   int       `json:"long_break_interval"`
}
