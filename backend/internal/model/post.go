package model

import (
	"time"

	"github.com/google/uuid"
)

type VisibilityType string

const (
	VisibilityPublic  VisibilityType = "public"
	VisibilityFriends VisibilityType = "friends"
	VisibilityPrivate VisibilityType = "private"
)

type Post struct {
	ID         uuid.UUID      `json:"id"`
	UserID     uuid.UUID      `json:"user_id"`
	VideoID    uuid.UUID      `json:"video_id"`
	Content    *string        `json:"content,omitempty"`
	Visibility VisibilityType `json:"visibility"`
	CreatedAt  time.Time      `json:"created_at"`
}
