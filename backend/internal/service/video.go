package service

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/repository"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/storage"
)

type VideoService struct {
	repo    repository.VideoRepository
	storage *storage.SupabaseStorage
}

func NewVideoService(repo repository.VideoRepository, storage *storage.SupabaseStorage) *VideoService {
	return &VideoService{repo: repo, storage: storage}
}

func (s *VideoService) Upload(ctx context.Context, userID uuid.UUID, fileName string, data []byte) (*model.Video, error) {
	uniqueName := fmt.Sprintf("%s/%s", userID.String(), fileName)
	storageURL, err := s.storage.UploadVideo(ctx, uniqueName, data)
	if err != nil {
		return nil, err
	}

	video := &model.Video{
		ID:         uuid.New(),
		UserID:     userID,
		StorageURL: storageURL,
		CreatedAt:  time.Now(),
	}
	if err := s.repo.Create(ctx, video); err != nil {
		return nil, err
	}
	return video, nil
}

func (s *VideoService) List(ctx context.Context, userID uuid.UUID) ([]*model.Video, error) {
	return s.repo.ListByUserID(ctx, userID)
}

func (s *VideoService) Get(ctx context.Context, id uuid.UUID) (*model.Video, error) {
	return s.repo.FindByID(ctx, id)
}
