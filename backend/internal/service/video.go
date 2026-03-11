package service

import (
	"context"
	"fmt"
	"io"
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

func (s *VideoService) Upload(ctx context.Context, userID uuid.UUID, contentType string, r io.Reader, size int64) (*model.Video, error) {
	// ユーザー入力ファイル名は使わず UUID をファイル名として使用（パストラバーサル対策）
	fileName := fmt.Sprintf("%s/%s.mp4", userID.String(), uuid.New().String())

	storageURL, err := s.storage.UploadVideo(ctx, fileName, contentType, r, size)
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
