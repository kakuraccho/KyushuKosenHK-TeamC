package model

import (
	"time"

	"github.com/google/uuid"
)

type Video struct {
	ID           uuid.UUID `json:"id"`
	UserID       uuid.UUID `json:"user_id"`
	StorageURL   string    `json:"storage_url"`
	ThumbnailURL *string   `json:"thumbnail_url,omitempty"`
	Duration     *int      `json:"duration,omitempty"`
	CreatedAt    time.Time `json:"created_at"`
}
