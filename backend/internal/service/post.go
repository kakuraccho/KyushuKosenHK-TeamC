package service

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/repository"
)

type PostService struct {
	repo repository.PostRepository
}

func NewPostService(repo repository.PostRepository) *PostService {
	return &PostService{repo: repo}
}

type CreatePostInput struct {
	UserID     uuid.UUID
	VideoID    uuid.UUID
	Content    *string
	Visibility model.VisibilityType
}

func (s *PostService) Create(ctx context.Context, input CreatePostInput) (*model.Post, error) {
	post := &model.Post{
		ID:         uuid.New(),
		UserID:     input.UserID,
		VideoID:    input.VideoID,
		Content:    input.Content,
		Visibility: input.Visibility,
		CreatedAt:  time.Now(),
	}
	if err := s.repo.Create(ctx, post); err != nil {
		return nil, err
	}
	return post, nil
}

func (s *PostService) Feed(ctx context.Context, userID uuid.UUID) ([]*model.Post, error) {
	return s.repo.ListFeed(ctx, userID)
}

func (s *PostService) Get(ctx context.Context, id uuid.UUID) (*model.Post, error) {
	return s.repo.FindByID(ctx, id)
}
