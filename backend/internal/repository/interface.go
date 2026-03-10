package repository

import (
	"context"

	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
)

type UserRepository interface {
	Create(ctx context.Context, user *model.User) error
	FindByID(ctx context.Context, id uuid.UUID) (*model.User, error)
	GetSettings(ctx context.Context, userID uuid.UUID) (*model.UserSettings, error)
	UpsertSettings(ctx context.Context, settings *model.UserSettings) error
}

type SessionRepository interface {
	Create(ctx context.Context, session *model.PomodoroSession) error
	ListByUserID(ctx context.Context, userID uuid.UUID) ([]*model.PomodoroSession, error)
}

type VideoRepository interface {
	Create(ctx context.Context, video *model.Video) error
	ListByUserID(ctx context.Context, userID uuid.UUID) ([]*model.Video, error)
	FindByID(ctx context.Context, id uuid.UUID) (*model.Video, error)
}

type PostRepository interface {
	Create(ctx context.Context, post *model.Post) error
	ListFeed(ctx context.Context, userID uuid.UUID) ([]*model.Post, error)
	FindByID(ctx context.Context, id uuid.UUID) (*model.Post, error)
}

type FriendRepository interface {
	CreateRequest(ctx context.Context, friendship *model.Friendship) error
	ListPendingRequests(ctx context.Context, userID uuid.UUID) ([]*model.Friendship, error)
	FindByID(ctx context.Context, id uuid.UUID) (*model.Friendship, error)
	UpdateStatus(ctx context.Context, id uuid.UUID, status model.FriendshipStatus) error
	ListFriends(ctx context.Context, userID uuid.UUID) ([]*model.Friendship, error)
}
