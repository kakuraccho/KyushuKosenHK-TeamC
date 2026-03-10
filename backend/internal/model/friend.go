package model

import (
	"time"

	"github.com/google/uuid"
)

type FriendshipStatus string

const (
	FriendshipPending  FriendshipStatus = "pending"
	FriendshipAccepted FriendshipStatus = "accepted"
	FriendshipBlocked  FriendshipStatus = "blocked"
)

type Friendship struct {
	ID          uuid.UUID        `json:"id"`
	FollowerID  uuid.UUID        `json:"follower_id"`
	FollowingID uuid.UUID        `json:"following_id"`
	Status      FriendshipStatus `json:"status"`
	CreatedAt   time.Time        `json:"created_at"`
}
