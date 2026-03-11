package model

import (
	"time"

	"github.com/google/uuid"
)

type PomodoroSession struct {
	ID          uuid.UUID `json:"id"`
	UserID      uuid.UUID `json:"user_id"`
	Duration    int       `json:"duration"`
	IsCompleted bool      `json:"is_completed"`
	CreatedAt   time.Time `json:"created_at"`
}
