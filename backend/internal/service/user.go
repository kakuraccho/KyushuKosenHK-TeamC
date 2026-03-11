package service

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/repository"
)

type UserService struct {
	repo repository.UserRepository
}

func NewUserService(repo repository.UserRepository) *UserService {
	return &UserService{repo: repo}
}

type SignupInput struct {
	ID    uuid.UUID
	Name  string
	Email string
}

func (s *UserService) Signup(ctx context.Context, input SignupInput) (*model.User, error) {
	user := &model.User{
		ID:        input.ID,
		Name:      input.Name,
		Email:     input.Email,
		CreatedAt: time.Now(),
	}
	if err := s.repo.Create(ctx, user); err != nil {
		return nil, err
	}
	// create default settings
	settings := &model.UserSettings{
		UserID:             user.ID,
		TimePomodoro:       25,
		TimeShortBreak:     5,
		TimeLongBreak:      15,
		IsAutoStartSession: false,
		LongBreakInterval:  4,
	}
	if err := s.repo.UpsertSettings(ctx, settings); err != nil {
		return nil, err
	}
	return user, nil
}

func (s *UserService) GetSettings(ctx context.Context, userID uuid.UUID) (*model.UserSettings, error) {
	return s.repo.GetSettings(ctx, userID)
}

func (s *UserService) UpdateSettings(ctx context.Context, settings *model.UserSettings) error {
	return s.repo.UpsertSettings(ctx, settings)
}
