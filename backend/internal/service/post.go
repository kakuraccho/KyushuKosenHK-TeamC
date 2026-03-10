package service

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/repository"
)

type PostService struct {
	repo      repository.PostRepository
	videoRepo repository.VideoRepository
}

func NewPostService(repo repository.PostRepository, videoRepo repository.VideoRepository) *PostService {
	return &PostService{repo: repo, videoRepo: videoRepo}
}

type CreatePostInput struct {
	UserID     uuid.UUID
	VideoID    uuid.UUID
	Content    *string
	Visibility model.VisibilityType
}

func (s *PostService) Create(ctx context.Context, input CreatePostInput) (*model.Post, error) {
	// 動画のオーナーシップ確認
	video, err := s.videoRepo.FindByID(ctx, input.VideoID)
	if err != nil {
		return nil, fmt.Errorf("video not found")
	}
	if video.UserID != input.UserID {
		return nil, fmt.Errorf("forbidden: video does not belong to you")
	}

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
