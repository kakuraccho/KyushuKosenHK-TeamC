package service

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/repository"
)

type SessionService struct {
	repo repository.SessionRepository
}

func NewSessionService(repo repository.SessionRepository) *SessionService {
	return &SessionService{repo: repo}
}

type CreateSessionInput struct {
	UserID      uuid.UUID
	Duration    int
	IsCompleted bool
}

func (s *SessionService) Create(ctx context.Context, input CreateSessionInput) (*model.PomodoroSession, error) {
	session := &model.PomodoroSession{
		ID:          uuid.New(),
		UserID:      input.UserID,
		Duration:    input.Duration,
		IsCompleted: input.IsCompleted,
		CreatedAt:   time.Now(),
	}
	if err := s.repo.Create(ctx, session); err != nil {
		return nil, err
	}
	return session, nil
}

func (s *SessionService) List(ctx context.Context, userID uuid.UUID) ([]*model.PomodoroSession, error) {
	return s.repo.ListByUserID(ctx, userID)
}
